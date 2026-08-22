-- ============================================================
-- epsilon-admin / server/main.lua
-- ============================================================

local savedPositions    = {}
local frozenPlayers     = {}
local frozenVehicles    = {}
local onFirePlayers     = {}
local cagedPlayers      = {}
local pendingFreezeAdmin = {}

-- ── Ban check on connect ──────────────────────────────────────
AddEventHandler('playerConnecting', function(_, _, deferrals)
    local src        = source
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then return end

    deferrals.defer()
    Wait(0)

    local ban = MySQL.query.await([[
        SELECT reason, expires_at, duration FROM admin_sanctions
        WHERE identifier = ? AND type = 'ban' AND active = 1
        AND (expires_at = 0 OR expires_at > ?)
        ORDER BY id DESC LIMIT 1
    ]], { identifier, os.time() })

    if ban and #ban > 0 then
        local b   = ban[1]
        local dur = b.duration > 0 and (os.date('%d/%m/%Y %H:%M', b.expires_at)) or 'Permanent'
        deferrals.done(('Vous êtes banni.\nRaison: %s\nExpiration: %s'):format(b.reason, dur))
    else
        deferrals.done()
    end
end)

-- Nettoyer les bans expirés toutes les heures
CreateThread(function()
    while true do
        Wait(3600000)
        MySQL.update("UPDATE admin_sanctions SET active = 0 WHERE type = 'ban' AND expires_at > 0 AND expires_at < ? AND active = 1", { os.time() })
    end
end)

-- ── Weather / Time sync (vSync-style) ───────────────────────
local currentWeather = 'EXTRASUNNY'
local currentHour    = 12
local currentMinute  = 0
local freezeTime     = false
local freezeWeather  = false

-- Cycle météo dynamique
local WEATHER_CYCLE = {
    'EXTRASUNNY', 'EXTRASUNNY',
    'CLEAR',      'CLEAR',
    'CLOUDS',
    'OVERCAST',
    'RAIN',
    'CLOUDS',
    'CLEAR',
    'FOGGY',
    'CLEAR',
    'EXTRASUNNY',
}
local WEATHER_CYCLE_INTERVAL = 10 * 60 -- secondes réelles entre chaque météo (10 min)
local weatherCycleIdx   = 1
local weatherCycleTimer = 0

local function broadcastServerState(target)
    local nextIdx = (weatherCycleIdx % #WEATHER_CYCLE) + 1
    TriggerClientEvent('epsilon:admin:serverState', target, {
        weather       = currentWeather,
        nextWeather   = WEATHER_CYCLE[nextIdx],
        hour          = currentHour,
        minute        = currentMinute,
        freezeTime    = freezeTime,
        freezeWeather = freezeWeather,
    })
end

-- ── Cycle météo ───────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(1000)
        if not freezeWeather then
            weatherCycleTimer = weatherCycleTimer + 1
            if weatherCycleTimer >= WEATHER_CYCLE_INTERVAL then
                weatherCycleTimer = 0
                weatherCycleIdx   = (weatherCycleIdx % #WEATHER_CYCLE) + 1
                currentWeather    = WEATHER_CYCLE[weatherCycleIdx]
                TriggerClientEvent('epsilon:admin:syncWeather', -1, currentWeather)
                broadcastServerState(-1)
                Epsilon.Debug.Info('[Admin] Cycle météo → %s', currentWeather)
            end
        end
    end
end)

-- ── Horloge ───────────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(1000)
        if not freezeTime then
            currentMinute = currentMinute + 1
            if currentMinute >= 60 then
                currentMinute = 0
                currentHour   = (currentHour + 1) % 24
            end
        end
        TriggerClientEvent('epsilon:admin:syncTime', -1, currentHour, currentMinute)
    end
end)

AddEventHandler('playerJoining', function()
    local src = source
    Wait(2000)
    TriggerClientEvent('epsilon:admin:syncWeather', src, currentWeather)
    TriggerClientEvent('epsilon:admin:syncTime', src, currentHour, currentMinute)
end)

-- ── Permission helper ─────────────────────────────────────────
local function isAdmin(src)
    if IsPlayerAceAllowed(src, 'epsilon.admin') then return true end
    local identifier = GetPlayerIdentifierByType(src, 'license') or ''
    for _, v in ipairs(Epsilon.Admin.SuperAdmins or {}) do
        if v == identifier then return true end
    end
    return false
end

local function isSuperAdmin(src)
    if IsPlayerAceAllowed(src, 'epsilon.superadmin') then return true end
    local identifier = GetPlayerIdentifierByType(src, 'license') or ''
    for _, v in ipairs(Epsilon.Admin.SuperAdmins or {}) do
        if v == identifier then return true end
    end
    return false
end

-- Hash license sans préfixe "license:" (format stocké dans admin_players)
local function getLicenseHash(src)
    local id = GetPlayerIdentifierByType(src, 'license') or ''
    return id:match('^license:(.+)$') or id
end

-- ── Grade system ───────────────────────────────────────────────
local gradesById        = {} -- int → grade row
local playerGradeCache  = {} -- license → grade row | false

local function refreshGrades()
    gradesById = {}
    local rows = MySQL.query.await('SELECT * FROM admin_grades ORDER BY sort_order ASC, id ASC')
    if rows then
        for _, g in ipairs(rows) do gradesById[g.id] = g end
    end
end

local function getCachedGrade(src)
    local license = getLicenseHash(src)
    if license == '' then return nil end
    if playerGradeCache[license] ~= nil then
        return playerGradeCache[license] or nil
    end
    -- Si les grades ne sont pas encore chargés, les charger maintenant
    local hasGrades = false
    for _ in pairs(gradesById) do hasGrades = true; break end
    if not hasGrades then refreshGrades() end

    local row = MySQL.query.await(
        'SELECT grade_id FROM admin_players WHERE license = ?', { license })
    if row and #row > 0 then
        local g = gradesById[row[1].grade_id]
        playerGradeCache[license] = g or false
        return g
    end
    playerGradeCache[license] = false
    return nil
end

-- Vérifie une permission spécifique (colonne DB) pour un joueur
local function hasPerm(src, perm)
    if isSuperAdmin(src) then return true end
    local grade = getCachedGrade(src)
    if grade then return grade[perm] == 1 or grade[perm] == true end
    return isAdmin(src) -- legacy ACE sans grade DB = accès total
end

local function gradePayload(g)
    if not g then return nil end
    return {
        id    = g.id,   name  = g.name,
        label = g.label, color = g.color,
        perms = {
            perm_players   = g.perm_players   == 1 or g.perm_players   == true,
            perm_teleport  = g.perm_teleport  == 1 or g.perm_teleport  == true,
            perm_spectate  = g.perm_spectate  == 1 or g.perm_spectate  == true,
            perm_health    = g.perm_health    == 1 or g.perm_health    == true,
            perm_effects   = g.perm_effects   == 1 or g.perm_effects   == true,
            perm_vehicle   = g.perm_vehicle   == 1 or g.perm_vehicle   == true,
            perm_sanctions = g.perm_sanctions == 1 or g.perm_sanctions == true,
            perm_message   = g.perm_message   == 1 or g.perm_message   == true,
            perm_weather   = g.perm_weather   == 1 or g.perm_weather   == true,
            perm_announce  = g.perm_announce  == 1 or g.perm_announce  == true,
            perm_tools     = g.perm_tools     == 1 or g.perm_tools     == true,
            perm_grades    = g.perm_grades    == 1 or g.perm_grades    == true,
        }
    }
end

-- ── Chargement des grades depuis la DB ────────────────────────
-- (les tables sont créées par epsilon-database/migrations/004_admin_grades.sql)
CreateThread(function()
    Wait(1200) -- laisser epsilon-database terminer ses migrations
    refreshGrades()
    local n = 0; for _ in pairs(gradesById) do n = n + 1 end
    Epsilon.Debug.Success('[Admin] Grades chargés: %d', n)
end)

local function getIdentifier(src)
    return GetPlayerIdentifierByType(src, 'license') or ''
end

local function getLicenses(pid)
    local out  = {}
    local types = { 'license', 'steam', 'discord', 'fivem', 'live', 'xbl' }
    for _, t in ipairs(types) do
        local v = GetPlayerIdentifierByType(pid, t)
        if v and v ~= '' then out[#out + 1] = v end
    end
    return out
end

-- ── Admin logs ────────────────────────────────────────────────
local function logAdmin(adminSrc, targetSrc, action, reason, meta)
    MySQL.insert(
        'INSERT INTO admin_logs (admin_id, admin_name, target_id, target_name, action, reason, metadata) VALUES (?,?,?,?,?,?,?)',
        {
            tonumber(adminSrc),
            GetPlayerName(adminSrc),
            targetSrc and tonumber(targetSrc) or nil,
            targetSrc and GetPlayerName(targetSrc) or nil,
            action,
            reason or nil,
            meta and json.encode(meta) or nil
        }
    )
end

-- ── Couleurs de notification ───────────────────────────────────
local NC = {
    green  = '#22c55e', red    = '#ef4444',
    amber  = '#f59e0b', purple = 'rgba(147,51,234,0.85)',
    blue   = '#3b82f6',
}

-- ── Notification helper ────────────────────────────────────────
local function notify(targetSrc, msg, color, icon, duration)
    TriggerClientEvent('epsilon:ui:notify', targetSrc, {
        text     = msg:gsub('~%w+~', ''),
        color    = color    or NC.purple,
        icon     = icon,
        duration = duration or 5,
    })
end

-- ── Check admin ───────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:checkAdmin', function()
    local src = source
    if not hasPerm(src, 'perm_players') then
        TriggerClientEvent('epsilon:admin:denied', src)
        return
    end
    local grade = getCachedGrade(src)
    local gp    = gradePayload(grade)
    local label = gp and gp.label or 'Admin'
    local myLicense = GetPlayerIdentifierByType(src, 'license') or ''
    TriggerClientEvent('epsilon:admin:granted', src, label, myLicense)
    TriggerClientEvent('epsilon:admin:syncWeather', src, currentWeather)
    TriggerClientEvent('epsilon:admin:syncTime', src, currentHour, currentMinute)
    broadcastServerState(src)
    if gp then TriggerClientEvent('epsilon:admin:gradeInfo', src, gp) end
end)

-- ── Player list ───────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:getPlayers', function()
    local src = source
    if not hasPerm(src, 'perm_players') then return end
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local pid    = tonumber(id)
        local ped    = GetPlayerPed(pid)
        local coords = GetEntityCoords(ped)
        -- Grade du joueur (s'il est admin)
        local lic    = getLicenseHash(pid)
        local pgrade = nil
        if playerGradeCache[lic] ~= nil then
            pgrade = playerGradeCache[lic] or nil
        else
            local row = MySQL.query.await('SELECT grade_id FROM admin_players WHERE license = ?', { lic })
            if row and #row > 0 then
                pgrade = gradesById[row[1].grade_id]
                playerGradeCache[lic] = pgrade or false
            else
                playerGradeCache[lic] = false
            end
        end
        list[#list + 1] = {
            id         = pid,
            name       = GetPlayerName(pid),
            ping       = GetPlayerPing(pid),
            identifier = getIdentifier(pid),
            licenses   = getLicenses(pid),
            x          = math.floor(coords.x),
            y          = math.floor(coords.y),
            z          = math.floor(coords.z),
            frozen        = frozenPlayers[pid]  or false,
            onFire     = onFirePlayers[pid] or false,
            caged      = cagedPlayers[pid]  or false,
            gradeId    = pgrade and pgrade.id or nil,
            gradeLabel = pgrade and pgrade.label or nil,
            gradeColor = pgrade and pgrade.color or nil,
        }
    end
    TriggerClientEvent('epsilon:admin:playersList', src, list)
end)

-- ── Tag data for showNames / showBlips ───────────────────────
RegisterNetEvent('epsilon:admin:getTagData', function()
    local src = source
    if not hasPerm(src, 'perm_players') then return end

    local tagData = {}
    for _, id in ipairs(GetPlayers()) do
        local pid     = tonumber(id)
        local lic     = getLicenseHash(pid)
        local pgrade  = getCachedGrade(pid)

        -- Récupérer le perso actif + db_id via export epsilon-characters
        local firstname, lastname, dbId = nil, nil, nil
        local ok, cached = pcall(function()
            return exports['epsilon-characters']:GetPlayer(pid)
        end)
        if ok and cached then
            dbId = cached.db_id
            if cached.characters then
                local best, bestTime = nil, 0
                for _, c in ipairs(cached.characters) do
                    local t = c.last_played and tonumber(c.last_played) or 0
                    if t > bestTime then bestTime = t; best = c end
                end
                if not best and #cached.characters > 0 then best = cached.characters[1] end
                if best then firstname = best.firstname; lastname = best.lastname end
            end
        end

        -- Fallback DB si export non disponible ou cache vide
        if not firstname or not dbId then
            local rows = MySQL.query.await([[
                SELECT p.id, c.firstname, c.lastname
                FROM characters c
                INNER JOIN players p ON c.player_id = p.id
                WHERE p.identifier = ?
                ORDER BY c.last_played DESC LIMIT 1
            ]], { 'license:' .. lic })
            if rows and #rows > 0 then
                dbId      = dbId      or rows[1].id
                firstname = firstname or rows[1].firstname
                lastname  = lastname  or rows[1].lastname
            end
        end

        tagData[pid] = {
            gradeLabel = pgrade and pgrade.label or nil,
            gradeColor = pgrade and pgrade.color or nil,
            dbId       = dbId or 0,
            firstname  = firstname or 'Inconnu',
            lastname   = lastname  or '',
            pseudo     = GetPlayerName(pid) or ('Joueur #' .. pid),
        }
    end
    TriggerClientEvent('epsilon:admin:tagData', src, tagData)
end)

-- ── Teleport ──────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:teleportTo', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_teleport') then return end
    local coords = GetEntityCoords(GetPlayerPed(targetId))
    TriggerClientEvent('epsilon:admin:doTeleport', src, coords.x, coords.y, coords.z + 1.0)
    notify(src, 'Téléporté vers ' .. GetPlayerName(targetId), NC.purple, 'bi-arrow-right-square', 3)
    logAdmin(src, targetId, 'teleport_to', nil)
end)

-- ax/ay/az = position exacte de l'admin côté client (sans offset)
RegisterNetEvent('epsilon:admin:bringPlayer', function(targetId, ax, ay, az)
    local src = source
    if not hasPerm(src, 'perm_teleport') then return end
    -- Sauvegarder la position originale une seule fois (pour Renvoi)
    if not savedPositions[targetId] then
        savedPositions[targetId] = GetEntityCoords(GetPlayerPed(targetId))
    end
    TriggerClientEvent('epsilon:admin:doTeleport', targetId, ax, ay, az)
    notify(targetId, 'Téléporté par un admin', NC.purple, 'bi-arrow-left-right')
    notify(src, GetPlayerName(targetId) .. ' rapproché', NC.purple, 'bi-arrow-left-right', 3)
    logAdmin(src, targetId, 'bring', nil)
end)

RegisterNetEvent('epsilon:admin:bringBack', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_teleport') then return end
    if savedPositions[targetId] then
        local p = savedPositions[targetId]
        TriggerClientEvent('epsilon:admin:doTeleport', targetId, p.x, p.y, p.z)
        savedPositions[targetId] = nil
        notify(targetId, 'Renvoyé à votre position', NC.purple, 'bi-arrow-return-left')
        notify(src, GetPlayerName(targetId) .. ' renvoyé', NC.purple, 'bi-arrow-return-left', 3)
        logAdmin(src, targetId, 'bring_back', nil)
    else
        notify(src, 'Aucune position sauvegardée', NC.red, 'bi-x-circle-fill')
    end
end)

RegisterNetEvent('epsilon:admin:teleportCoords', function(x, y, z)
    local src = source
    if not hasPerm(src, 'perm_tools') then return end
    TriggerClientEvent('epsilon:admin:doTeleport', src, x, y, z)
    logAdmin(src, nil, 'teleport_coords', nil, { x = x, y = y, z = z })
end)

-- ── Health / Revive ───────────────────────────────────────────
RegisterNetEvent('epsilon:admin:healPlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    TriggerClientEvent('epsilon:admin:doHeal', targetId)
    notify(targetId, 'Soigné par un admin', NC.green, 'bi-heart-fill')
    notify(src, GetPlayerName(targetId) .. ' soigné', NC.green, 'bi-heart-fill', 3)
    logAdmin(src, targetId, 'heal', nil)
end)

RegisterNetEvent('epsilon:admin:killPlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    TriggerClientEvent('epsilon:admin:doKill', targetId)
    notify(targetId, 'Tué par un admin', NC.red, 'bi-x-circle-fill')
    notify(src, GetPlayerName(targetId) .. ' tué', NC.red, 'bi-x-circle-fill', 3)
    logAdmin(src, targetId, 'kill', nil)
end)

RegisterNetEvent('epsilon:admin:revivePlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    TriggerClientEvent('epsilon:admin:doRevive', targetId)
    notify(targetId, 'Réanimé par un admin', NC.green, 'bi-activity')
    notify(src, GetPlayerName(targetId) .. ' réanimé', NC.green, 'bi-activity', 3)
    logAdmin(src, targetId, 'revive', nil)
end)

-- ── Freeze ────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:freezePlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_effects') then return end
    frozenPlayers[targetId] = not frozenPlayers[targetId]
    local state = frozenPlayers[targetId]
    TriggerClientEvent('epsilon:admin:setFreeze', targetId, state)
    notify(targetId, state and 'Freeze par un admin' or 'Unfreeze', state and NC.amber or NC.green, 'bi-snow')
    notify(src, GetPlayerName(targetId) .. (state and ' freeze' or ' unfreeze'), state and NC.amber or NC.green, 'bi-snow', 3)
    TriggerClientEvent('epsilon:admin:toggleFreezeState', src, targetId, state)
    logAdmin(src, targetId, state and 'freeze' or 'unfreeze', nil)
end)

-- ── Fire ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:toggleFire', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_effects') then return end
    onFirePlayers[targetId] = not onFirePlayers[targetId]
    local fireState = onFirePlayers[targetId]
    TriggerClientEvent('epsilon:admin:setFire', targetId, fireState)
    notify(targetId, fireState and 'Enflammé par un admin' or 'Feu éteint', fireState and NC.red or NC.green, 'bi-fire')
    notify(src, GetPlayerName(targetId) .. (fireState and ' enflammé' or ' feu éteint'), fireState and NC.red or NC.green, 'bi-fire', 3)
    logAdmin(src, targetId, fireState and 'fire_on' or 'fire_off', nil)
end)

-- ── Cage ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:toggleCage', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_effects') then return end
    cagedPlayers[targetId] = not cagedPlayers[targetId]
    local cageState = cagedPlayers[targetId]
    TriggerClientEvent('epsilon:admin:setCage', targetId, cageState)
    notify(targetId, cageState and 'Mis en cage' or 'Libéré', cageState and NC.amber or NC.green, 'bi-lock-fill')
    notify(src, GetPlayerName(targetId) .. (cageState and ' mis en cage' or ' libéré'), cageState and NC.amber or NC.green, 'bi-lock-fill', 3)
    logAdmin(src, targetId, cageState and 'cage_on' or 'cage_off', nil)
end)

-- ── Spectate ─────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:spectatePlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_spectate') then return end
    TriggerClientEvent('epsilon:admin:doSpectate', src, targetId)
    notify(src, 'Spectate → ' .. GetPlayerName(targetId), NC.blue, 'bi-eye-fill', 3)
    logAdmin(src, targetId, 'spectate', nil)
end)

-- ── Sanctions helpers ─────────────────────────────────────────
local function parseDuration(input)
    if not input or input == '' then return 0 end
    local n = tonumber(input:match('%d+'))
    if not n then return 0 end
    local u = (input:match('%a+') or ''):lower()
    if     u == 'm' or u == 'min'              then return n * 60
    elseif u == 'h' or u == 'heure'            then return n * 3600
    elseif u == 'j' or u == 'd' or u == 'jour' then return n * 86400
    elseif u == 'w' or u == 's'                then return n * 604800
    else return n * 86400 end
end

local function formatDuration(s)
    if s <= 0        then return 'Permanent'
    elseif s < 3600  then return math.floor(s/60)    .. ' min'
    elseif s < 86400 then return math.floor(s/3600)  .. ' h'
    elseif s < 604800 then return math.floor(s/86400) .. ' j'
    else return math.floor(s/604800) .. ' sem' end
end

local function checkAutoBan(targetId, identifier)
    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM admin_sanctions WHERE identifier = ? AND type = "warn" AND active = 1',
        { identifier }
    )
    if count and count >= 3 then
        local expires = os.time() + 86400
        MySQL.insert('INSERT INTO admin_sanctions (type, identifier, player_name, reason, sanctioned_by, sanctioned_at, duration, expires_at, active) VALUES (?,?,?,?,?,?,?,?,1)', {
            'ban', identifier, GetPlayerName(targetId),
            'Auto-ban: 3 avertissements actifs', 'SYSTÈME',
            os.time(), 86400, expires
        })
        MySQL.update('UPDATE admin_sanctions SET active = 0 WHERE identifier = ? AND type = "warn" AND active = 1', { identifier })
        DropPlayer(targetId, 'Banni automatiquement\nRaison: 3 avertissements actifs\nDurée: 24h')
        Epsilon.Debug.Warn('[Admin] Auto-ban: %s (3 warns)', identifier)
    end
end

-- ── Warn ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:warnPlayer', function(targetId, reason)
    local src = source
    if not hasPerm(src, 'perm_sanctions') then return end
    reason = (reason ~= '' and reason) or 'Aucune raison'
    local adminName  = GetPlayerName(src)
    local targetName = GetPlayerName(targetId)
    local identifier = GetPlayerIdentifierByType(targetId, 'license')
    if not identifier then return end

    MySQL.insert.await('INSERT INTO admin_sanctions (type, identifier, player_name, reason, sanctioned_by, sanctioned_at, active) VALUES (?,?,?,?,?,?,1)', {
        'warn', identifier, targetName, reason, adminName, os.time()
    })

    local warnCount = MySQL.scalar.await(
        'SELECT COUNT(*) FROM admin_sanctions WHERE identifier = ? AND type = "warn" AND active = 1',
        { identifier }
    ) or 0

    TriggerClientEvent('epsilon:ui:notifyAdvanced', targetId, {
        title    = 'Avertissement',
        subtitle = ('Sanction %d/3 — par %s'):format(warnCount, adminName),
        text     = reason,
        image    = 'epsilon',
        color    = NC.amber,
        duration = 10,
    })
    notify(src, ('Warn envoyé à %s (%d/3)'):format(targetName, warnCount), NC.amber, 'bi-exclamation-triangle-fill')
    logAdmin(src, targetId, 'warn', reason, { count = warnCount })
    Epsilon.Debug.Warn('[Admin] %s warn %s: %s (%d/3)', adminName, targetName, reason, warnCount)
    Wait(100); checkAutoBan(targetId, identifier)
end)

-- ── Kick ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:kick', function(targetId, reason)
    local src = source
    if not hasPerm(src, 'perm_sanctions') then return end
    reason = (reason ~= '' and reason) or 'Aucune raison'
    local adminName  = GetPlayerName(src)
    local targetName = GetPlayerName(targetId)
    local identifier = GetPlayerIdentifierByType(targetId, 'license')
    if not identifier then return end

    MySQL.insert('INSERT INTO admin_sanctions (type, identifier, player_name, reason, sanctioned_by, sanctioned_at, active) VALUES (?,?,?,?,?,?,1)', {
        'kick', identifier, targetName, reason, adminName, os.time()
    })

    DropPlayer(targetId, ('Expulsé\nRaison: %s'):format(reason))
    notify(src, ('%s expulsé'):format(targetName), NC.red, 'bi-door-open-fill')
    logAdmin(src, targetId, 'kick', reason)
    Epsilon.Debug.Warn('[Admin] %s kick %s: %s', adminName, targetName, reason)
end)

-- ── Ban ───────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:ban', function(targetId, reason, durationStr)
    local src = source
    if not hasPerm(src, 'perm_sanctions') then return end
    reason = (reason ~= '' and reason) or 'Aucune raison'
    local adminName  = GetPlayerName(src)
    local targetName = GetPlayerName(targetId)
    local identifier = GetPlayerIdentifierByType(targetId, 'license')
    if not identifier then return end

    local dur     = parseDuration(durationStr)
    local expires = dur > 0 and (os.time() + dur) or 0

    MySQL.insert('INSERT INTO admin_sanctions (type, identifier, player_name, reason, sanctioned_by, sanctioned_at, duration, expires_at, active) VALUES (?,?,?,?,?,?,?,?,1)', {
        'ban', identifier, targetName, reason, adminName, os.time(), dur, expires
    })

    local label = formatDuration(dur)
    DropPlayer(targetId, ('Banni\nRaison: %s\nDurée: %s'):format(reason, label))
    notify(src, ('%s banni (%s)'):format(targetName, label), NC.red, 'bi-slash-circle-fill')
    logAdmin(src, targetId, 'ban', reason, { duration = label })
    Epsilon.Debug.Warn('[Admin] %s ban %s: %s / %s', adminName, targetName, reason, label)
end)

-- ── Message direct ────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:sendMessage', function(targetId, message)
    local src = source
    if not hasPerm(src, 'perm_message') then return end
    if not message or message == '' then return end
    local targetName = GetPlayerName(targetId)
    local adminName  = GetPlayerName(src)
    TriggerClientEvent('epsilon:ui:notifyAdvanced', targetId, {
        title    = 'Message Administrateur',
        subtitle = adminName,
        text     = message,
        image    = 'epsilon',
        color    = NC.blue,
        duration = 10,
    })
    notify(src, ('Message envoyé à %s'):format(targetName), NC.blue, 'bi-chat-fill')
    logAdmin(src, targetId, 'message', message)
end)

-- ── Heal armure ───────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:healArmour', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    TriggerClientEvent('epsilon:admin:doHealArmour', targetId)
    notify(targetId, 'Armure restaurée', NC.green, 'bi-shield-fill')
    notify(src, GetPlayerName(targetId) .. ' — armure restaurée', NC.green, 'bi-shield-fill', 3)
    logAdmin(src, targetId, 'heal_armour', nil)
end)

-- ── Infliger dégâts (50 % HP) ─────────────────────────────────
RegisterNetEvent('epsilon:admin:damagePlayer', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    TriggerClientEvent('epsilon:admin:doDamage', targetId)
    notify(targetId, 'Dégâts infligés par un admin', NC.red, 'bi-bandaid-fill')
    notify(src, GetPlayerName(targetId) .. ' — dégâts infligés', NC.red, 'bi-bandaid-fill', 3)
    logAdmin(src, targetId, 'damage', nil)
end)

-- ── Log externe (epsilon-context, etc.) ──────────────────────
RegisterNetEvent('epsilon:admin:logAction')
AddEventHandler('epsilon:admin:logAction', function(action, targetSrc, meta)
    local src = source
    if not isAdmin(src) then return end
    local fullMeta = meta or {}
    fullMeta.source = 'Context menu'
    logAdmin(src, targetSrc or nil, 'ctx_' .. action, nil, fullMeta)
end)

-- ── Vehicle actions ───────────────────────────────────────────
RegisterNetEvent('epsilon:admin:fixVehicle', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doFixVehicle', targetId)
    notify(targetId, 'Véhicule réparé', NC.green, 'bi-tools')
    notify(src, GetPlayerName(targetId) .. ' — véhicule réparé', NC.green, 'bi-tools', 3)
    logAdmin(src, targetId, 'fix_vehicle', nil)
end)

RegisterNetEvent('epsilon:admin:deleteVehicle', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doDeleteVehicle', targetId)
    notify(targetId, 'Véhicule supprimé', NC.red, 'bi-trash3-fill')
    notify(src, GetPlayerName(targetId) .. ' — véhicule supprimé', NC.red, 'bi-trash3-fill', 3)
    logAdmin(src, targetId, 'delete_vehicle', nil)
end)

RegisterNetEvent('epsilon:admin:refuelVehicle', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doRefuelVehicle', targetId)
    notify(targetId, 'Véhicule ravitaillé', NC.green, 'bi-fuel-pump-fill')
    notify(src, GetPlayerName(targetId) .. ' — véhicule ravitaillé', NC.green, 'bi-fuel-pump-fill', 3)
    logAdmin(src, targetId, 'refuel_vehicle', nil)
end)

RegisterNetEvent('epsilon:admin:burstTyres', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doBurstTyres', targetId)
    notify(targetId, 'Pneus crevés', NC.red, 'bi-circle-fill')
    notify(src, GetPlayerName(targetId) .. ' — pneus crevés', NC.red, 'bi-circle-fill', 3)
    logAdmin(src, targetId, 'burst_tyres', nil)
end)

RegisterNetEvent('epsilon:admin:breakWindows', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doBreakWindows', targetId)
    notify(targetId, 'Vitres brisées', NC.amber, 'bi-columns-gap')
    notify(src, GetPlayerName(targetId) .. ' — vitres brisées', NC.amber, 'bi-columns-gap', 3)
    logAdmin(src, targetId, 'break_windows', nil)
end)

RegisterNetEvent('epsilon:admin:cleanVehicle', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doCleanVehicle', targetId)
    notify(targetId, 'Véhicule nettoyé', NC.green, 'bi-stars')
    notify(src, GetPlayerName(targetId) .. ' — véhicule nettoyé', NC.green, 'bi-stars', 3)
    logAdmin(src, targetId, 'clean_vehicle', nil)
end)

RegisterNetEvent('epsilon:admin:engineDamage', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doEngineDamage', targetId)
    notify(targetId, 'Moteur endommagé', NC.red, 'bi-exclamation-octagon-fill')
    notify(src, GetPlayerName(targetId) .. ' — moteur endommagé', NC.red, 'bi-exclamation-octagon-fill', 3)
    logAdmin(src, targetId, 'engine_damage', nil)
end)

RegisterNetEvent('epsilon:admin:queryPlayerVehicleFreezeState', function(targetId)
    local src = source
    pendingFreezeAdmin[targetId] = src
    TriggerClientEvent('epsilon:admin:queryVehicleFreezeState', targetId)
end)

RegisterNetEvent('epsilon:admin:freezeVehicle', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    pendingFreezeAdmin[targetId] = src
    TriggerClientEvent('epsilon:admin:doFreezeVehicle', targetId)
end)

RegisterNetEvent('epsilon:admin:reportVehicleFreezeState', function(state, isToggle, inVehicle)
    local targetId = source
    frozenVehicles[targetId] = state or false
    local adminSrc = pendingFreezeAdmin[targetId]
    if adminSrc then
        TriggerClientEvent('epsilon:admin:vehicleFreezeState', adminSrc, targetId, state or false, inVehicle or false)
        pendingFreezeAdmin[targetId] = nil
    end
    if isToggle and adminSrc then
        notify(targetId, state and 'Véhicule freeze' or 'Véhicule unfreeze', NC.amber, 'bi-snow')
        notify(adminSrc, GetPlayerName(targetId) .. (state and ' — véhicule freeze' or ' — véhicule unfreeze'), NC.amber, 'bi-snow', 3)
        logAdmin(adminSrc, targetId, state and 'freeze_vehicle' or 'unfreeze_vehicle', nil)
    end
end)

RegisterNetEvent('epsilon:admin:spawnVehicleFor', function(targetId, model)
    local src = source
    if not hasPerm(src, 'perm_vehicle') then return end
    TriggerClientEvent('epsilon:admin:doSpawnVehicleFor', targetId, model)
    notify(targetId, ('Un véhicule (%s) vous a été fourni par un admin'):format(model), NC.green, 'bi-car-front-fill')
    notify(src, GetPlayerName(targetId) .. ' — véhicule spawné: ' .. model, NC.green, 'bi-car-front-fill', 3)
    logAdmin(src, targetId, 'spawn_vehicle', model)
end)

-- ── Weather ───────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:setWeather', function(weather)
    local src = source
    if not hasPerm(src, 'perm_weather') then return end
    currentWeather    = weather
    weatherCycleTimer = 0 -- reset: la météo choisie dure un cycle complet
    -- Aligner le cycle sur la météo choisie si elle est dedans
    for i, w in ipairs(WEATHER_CYCLE) do
        if w == weather then weatherCycleIdx = i; break end
    end
    TriggerClientEvent('epsilon:admin:syncWeather', -1, weather)
    broadcastServerState(-1)
    notify(src, 'Météo → ' .. weather, NC.blue, 'bi-cloud-fill', 3)
    logAdmin(src, nil, 'set_weather', weather)
    Epsilon.Debug.Info('[Admin] %s → météo: %s', GetPlayerName(src), weather)
end)

RegisterNetEvent('epsilon:admin:toggleFreezeWeather', function()
    local src = source
    if not hasPerm(src, 'perm_weather') then return end
    freezeWeather = not freezeWeather
    broadcastServerState(-1)
    notify(src, freezeWeather and 'Météo figée' or 'Météo dynamique', NC.blue, 'bi-snow', 3)
    logAdmin(src, nil, freezeWeather and 'freeze_weather' or 'unfreeze_weather', nil)
    Epsilon.Debug.Info('[Admin] %s → freeze météo: %s', GetPlayerName(src), tostring(freezeWeather))
end)

RegisterNetEvent('epsilon:admin:getServerState', function()
    local src = source
    if not hasPerm(src, 'perm_players') then return end
    broadcastServerState(src)
    -- Renvoyer le grade à chaque ouverture du panel (fix race condition)
    local gp = gradePayload(getCachedGrade(src))
    if gp then TriggerClientEvent('epsilon:admin:gradeInfo', src, gp) end
end)

-- ── Time ──────────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:setTime', function(hour, minute, freeze)
    local src = source
    if not hasPerm(src, 'perm_weather') then return end
    currentHour   = math.max(0, math.min(23, tonumber(hour)   or 12))
    currentMinute = math.max(0, math.min(59, tonumber(minute) or 0))
    freezeTime    = freeze == true
    TriggerClientEvent('epsilon:admin:syncTime', -1, currentHour, currentMinute)
    broadcastServerState(-1)
    notify(src, ('Heure → %02d:%02d%s'):format(currentHour, currentMinute, freezeTime and ' (figée)' or ''), NC.blue, 'bi-clock-fill', 3)
    logAdmin(src, nil, 'set_time', nil, { hour = currentHour, minute = currentMinute, freeze = freezeTime })
    Epsilon.Debug.Info('[Admin] %s → heure: %02d:%02d (freeze=%s)', GetPlayerName(src), currentHour, currentMinute, tostring(freezeTime))
end)

-- ── Announce ──────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:announce', function(staffName, msg, duration)
    local src = source
    if not hasPerm(src, 'perm_announce') then return end
    if not msg or msg == '' then return end
    local dur = math.max(5, math.min(120, tonumber(duration) or 10))
    TriggerClientEvent('epsilon:admin:showAnnounce', -1, staffName or GetPlayerName(src), msg, dur)
    logAdmin(src, nil, 'announce', msg, { staff = staffName, duration = dur })
end)

-- ── NoClip / God / Ghost ─────────────────────────────────────
RegisterNetEvent('epsilon:admin:toggleNoclip', function()
    local src = source
    if not hasPerm(src, 'perm_tools') then return end
    TriggerClientEvent('epsilon:admin:doToggleNoclip', src)
    logAdmin(src, nil, 'toggle_noclip', nil)
end)

RegisterNetEvent('epsilon:admin:toggleGod', function()
    local src = source
    if not hasPerm(src, 'perm_tools') then return end
    TriggerClientEvent('epsilon:admin:doToggleGod', src)
    logAdmin(src, nil, 'toggle_god', nil)
end)

RegisterNetEvent('epsilon:admin:toggleGhost', function()
    local src = source
    if not hasPerm(src, 'perm_tools') then return end
    TriggerClientEvent('epsilon:admin:doToggleGhost', src)
    logAdmin(src, nil, 'toggle_ghost', nil)
end)

-- ── Cleanup ───────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    frozenPlayers[src]  = nil
    onFirePlayers[src]  = nil
    cagedPlayers[src]   = nil
    savedPositions[src] = nil
    local lic = getLicenseHash(src)
    if lic ~= '' then playerGradeCache[lic] = nil end
end)

-- ── Grade CRUD ────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:getGrades', function()
    local src = source
    if not hasPerm(src, 'perm_players') then return end
    local list = {}
    for _, g in pairs(gradesById) do list[#list + 1] = gradePayload(g) end
    table.sort(list, function(a, b)
        local ga, gb = gradesById[a.id], gradesById[b.id]
        return (ga and ga.sort_order or 0) < (gb and gb.sort_order or 0)
    end)
    TriggerClientEvent('epsilon:admin:gradesList', src, list)
end)

RegisterNetEvent('epsilon:admin:saveGrade', function(data)
    local src = source
    if not hasPerm(src, 'perm_grades') then return end
    if not data or not data.label or not data.color then return end
    local perms = data.perms or {}
    local function p(k) return (perms[k] == true) and 1 or 0 end

    if data.id then
        MySQL.query.await([[
            UPDATE admin_grades SET label=?,color=?,
                perm_players=?,perm_teleport=?,perm_spectate=?,
                perm_health=?,perm_effects=?,perm_vehicle=?,
                perm_sanctions=?,perm_message=?,perm_weather=?,
                perm_announce=?,perm_tools=?,perm_grades=?
            WHERE id=?
        ]], {
            data.label, data.color,
            p('perm_players'),p('perm_teleport'),p('perm_spectate'),
            p('perm_health'),p('perm_effects'),p('perm_vehicle'),
            p('perm_sanctions'),p('perm_message'),p('perm_weather'),
            p('perm_announce'),p('perm_tools'),p('perm_grades'),
            data.id
        })
        playerGradeCache = {}
        refreshGrades()
        logAdmin(src, nil, 'grade_update', data.label, { id = data.id })
    else
        if not data.name or data.name == '' then return end
        local id = MySQL.insert.await([[
            INSERT INTO admin_grades (name,label,color,
                perm_players,perm_teleport,perm_spectate,
                perm_health,perm_effects,perm_vehicle,
                perm_sanctions,perm_message,perm_weather,
                perm_announce,perm_tools,perm_grades,sort_order)
            VALUES (?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?)
        ]], {
            data.name, data.label, data.color,
            p('perm_players'),p('perm_teleport'),p('perm_spectate'),
            p('perm_health'),p('perm_effects'),p('perm_vehicle'),
            p('perm_sanctions'),p('perm_message'),p('perm_weather'),
            p('perm_announce'),p('perm_tools'),p('perm_grades'),
            data.sort_order or 0
        })
        refreshGrades()
        logAdmin(src, nil, 'grade_create', data.label, { id = id })
    end

    local list = {}
    for _, g in pairs(gradesById) do list[#list+1] = gradePayload(g) end
    TriggerClientEvent('epsilon:admin:gradesList', src, list)
    notify(src, 'Grade sauvegardé', NC.green, 'bi-check2')
end)

RegisterNetEvent('epsilon:admin:deleteGrade', function(gradeId)
    local src = source
    if not hasPerm(src, 'perm_grades') then return end
    local grade = gradesById[gradeId]
    if not grade then return end
    if grade.name == 'fondateur' then
        notify(src, 'Impossible de supprimer le grade Fondateur', NC.red, 'bi-x-circle-fill'); return
    end
    MySQL.query.await('DELETE FROM admin_grades WHERE id = ?', { gradeId })
    MySQL.query.await('DELETE FROM admin_players WHERE grade_id = ?', { gradeId })
    playerGradeCache = {}
    refreshGrades()
    logAdmin(src, nil, 'grade_delete', grade.label, { id = gradeId })
    local list = {}
    for _, g in pairs(gradesById) do list[#list+1] = gradePayload(g) end
    TriggerClientEvent('epsilon:admin:gradesList', src, list)
    notify(src, 'Grade supprimé', NC.green, 'bi-check2')
end)

RegisterNetEvent('epsilon:admin:setPlayerGrade', function(targetId, gradeId)
    local src = source
    if not hasPerm(src, 'perm_grades') then return end
    local license = getLicenseHash(targetId)
    if license == '' then return end
    if gradeId == 0 then
        MySQL.query.await('DELETE FROM admin_players WHERE license = ?', { license })
        playerGradeCache[license] = nil
        local tName = GetPlayerName(targetId) or '?'
        notify(src, ('Grade retiré à %s'):format(tName), NC.amber, 'bi-shield-x')
        if GetPlayerPing(targetId) > 0 then
            notify(targetId, 'Grade staff retiré', NC.amber, 'bi-shield-x')
        end
        logAdmin(src, targetId, 'grade_remove', nil)
    else
        local grade = gradesById[gradeId]
        if not grade then return end
        MySQL.query.await([[
            INSERT INTO admin_players (license,grade_id,assigned_by,assigned_at)
            VALUES (?,?,?,?)
            ON DUPLICATE KEY UPDATE grade_id=?,assigned_by=?,assigned_at=?
        ]], { license, gradeId, GetPlayerName(src), os.time(),
              gradeId, GetPlayerName(src), os.time() })
        playerGradeCache[license] = nil
        local tName = GetPlayerName(targetId) or '?'
        notify(src, ('Grade %s assigné à %s'):format(grade.label, tName), NC.green, 'bi-shield-fill')
        if GetPlayerPing(targetId) > 0 then
            notify(targetId, ('Vous avez reçu le grade %s'):format(grade.label), NC.green, 'bi-shield-fill')
        end
        logAdmin(src, targetId, 'grade_assign', grade.label, { grade_id = gradeId })
    end
end)

-- ── Reports ───────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:getReports', function(data)
    local src    = source
    local status = data and data.status or nil

    local query, params
    if status and status ~= 'all' then
        query  = 'SELECT * FROM reports WHERE status = ? ORDER BY created_at DESC LIMIT 200'
        params = { status }
    else
        query  = 'SELECT * FROM reports ORDER BY created_at DESC LIMIT 200'
        params = {}
    end

    local rows = MySQL.query.await(query, params)
    TriggerClientEvent('epsilon:admin:reportsList', src, rows or {})
end)

local function canActOnReport(license, report)
    if not report.assigned_license or report.assigned_license == '' then return true end
    if report.assigned_license == license then return true end
    if report.collaborators then
        local collabs = json.decode(report.collaborators) or {}
        for _, c in ipairs(collabs) do
            if c == license then return true end
        end
    end
    return false
end

RegisterNetEvent('epsilon:admin:updateReport', function(data)
    local src     = source
    if not data or not data.id then return end
    local license = GetPlayerIdentifierByType(src, 'license') or ''
    local name    = GetPlayerName(src) or ''
    local status  = data.status or 'open'

    local rows = MySQL.query.await('SELECT assigned_license, collaborators FROM reports WHERE id = ?', { data.id })
    if not rows or #rows == 0 then return end

    -- Prendre en charge un report ouvert : toujours autorisé
    -- Toute autre action : doit être assigné ou collaborateur
    if status ~= 'in_progress' and not canActOnReport(license, rows[1]) then
        TriggerClientEvent('epsilon:admin:notify', src, '⛔ Ce report est pris en charge par quelqu\'un d\'autre.')
        return
    end

    local now = os.date('%Y-%m-%dT%H:%M:%S')

    if status == 'in_progress' then
        MySQL.update(
            'UPDATE reports SET status=?, assigned_name=?, assigned_license=?, assigned_at=NOW() WHERE id=?',
            { status, name, license, data.id }
        )
    elseif status == 'closed' then
        MySQL.update(
            'UPDATE reports SET status=?, closed_by_name=?, closed_at=NOW() WHERE id=?',
            { status, name, data.id }
        )
    else
        MySQL.update(
            'UPDATE reports SET status=?, assigned_name=NULL, assigned_license=NULL, assigned_at=NULL, closed_by_name=NULL, closed_at=NULL, collaborators=NULL WHERE id=?',
            { status, data.id }
        )
    end
    logAdmin(src, nil, 'report_update', status, { report_id = data.id })

    -- Notifier le joueur qui a soumis le report
    local rrows = MySQL.query.await('SELECT player_license FROM reports WHERE id = ?', { data.id })
    if rrows and rrows[1] then
        local r = rrows[1]
        local notify = {
            id             = data.id,
            status         = status,
            assigned_name  = status == 'in_progress' and name or nil,
            assigned_at    = status == 'in_progress' and now or nil,
            closed_by_name = status == 'closed' and name or nil,
            closed_at      = status == 'closed' and now or nil,
        }
        -- Chercher le joueur par license
        if r.player_license and r.player_license ~= '' then
            for _, pid in ipairs(GetPlayers()) do
                local p = tonumber(pid)
                local lic = GetPlayerIdentifierByType(p, 'license') or ''
                if lic == r.player_license then
                    TriggerClientEvent('epsilon:ui:reportStatus', p, notify)
                    break
                end
            end
        end
    end
end)

-- Appelé par le staff ASSIGNÉ pour ajouter un collaborateur (data.targetId = server id du joueur à ajouter)
RegisterNetEvent('epsilon:admin:joinReport', function(data)
    local src     = source
    if not data or not data.id or not data.targetId then return end
    local callerLicense = GetPlayerIdentifierByType(src, 'license') or ''

    local rows = MySQL.query.await('SELECT assigned_license, collaborators FROM reports WHERE id = ?', { data.id })
    if not rows or #rows == 0 then return end
    local r = rows[1]

    -- Seul le staff assigné peut ajouter des collaborateurs
    if r.assigned_license ~= callerLicense then
        TriggerClientEvent('epsilon:admin:notify', src, '⛔ Seul le staff assigné peut ajouter des collaborateurs.')
        return
    end

    local targetLicense = GetPlayerIdentifierByType(tonumber(data.targetId), 'license') or ''
    local targetName    = GetPlayerName(tonumber(data.targetId)) or tostring(data.targetId)

    if targetLicense == '' then
        TriggerClientEvent('epsilon:admin:notify', src, '⚠️ Joueur introuvable.')
        return
    end
    if targetLicense == callerLicense then return end

    local collabs = json.decode(r.collaborators or '[]') or {}
    for _, c in ipairs(collabs) do
        if c == targetLicense then
            TriggerClientEvent('epsilon:admin:notify', src, '⚠️ Ce joueur collabore déjà sur ce report.')
            return
        end
    end
    table.insert(collabs, targetLicense)

    MySQL.update('UPDATE reports SET collaborators = ? WHERE id = ?', { json.encode(collabs), data.id })
    logAdmin(src, tonumber(data.targetId), 'report_join', nil, { report_id = data.id })

    for _, pid in ipairs(GetPlayers()) do
        local p = tonumber(pid)
        if IsPlayerAceAllowed(p, 'epsilon.admin') then
            TriggerClientEvent('epsilon:admin:reportUpdate', p, {
                id            = data.id,
                collaborators = json.encode(collabs),
                collab_name   = targetName,
            })
        end
    end
    TriggerClientEvent('epsilon:admin:notify', src, '✅ ' .. targetName .. ' ajouté comme collaborateur.')
end)

RegisterNetEvent('epsilon:admin:deleteReport', function(data)
    local src = source
    if not data or not data.id then return end
    MySQL.query('DELETE FROM reports WHERE id = ?', { data.id })
    logAdmin(src, nil, 'report_delete', nil, { report_id = data.id })
end)

-- ── Status (faim / soif) ─────────────────────────────────────────────────────

RegisterNetEvent('epsilon:admin:selfFillHunger', function()
    local src = source
    exports['epsilon-status']:FillHunger(src)
    notify(src, 'Faim remplie', NC.green, 'bi-egg-fried', 3)
    logAdmin(src, nil, 'self_fill_hunger', nil)
end)

RegisterNetEvent('epsilon:admin:selfFillThirst', function()
    local src = source
    exports['epsilon-status']:FillThirst(src)
    notify(src, 'Soif remplie', NC.green, 'bi-droplet-fill', 3)
    logAdmin(src, nil, 'self_fill_thirst', nil)
end)

RegisterNetEvent('epsilon:admin:selfDrainHunger', function()
    local src = source
    exports['epsilon-status']:DrainHunger(src, 10)
    notify(src, 'Faim drainée', NC.amber, 'bi-egg', 3)
    logAdmin(src, nil, 'self_drain_hunger', nil)
end)

RegisterNetEvent('epsilon:admin:selfDrainThirst', function()
    local src = source
    exports['epsilon-status']:DrainThirst(src, 10)
    notify(src, 'Soif drainée', NC.amber, 'bi-droplet', 3)
    logAdmin(src, nil, 'self_drain_thirst', nil)
end)

RegisterNetEvent('epsilon:admin:togglePauseStatus', function()
    local src    = source
    local paused = exports['epsilon-status']:TogglePauseStatus(src)
    TriggerClientEvent('epsilon:admin:setPauseState', src, paused or false)
    notify(src, paused and 'Status en pause' or 'Status actif', NC.amber, 'bi-pause-circle', 3)
    logAdmin(src, nil, paused and 'pause_status_on' or 'pause_status_off', nil)
end)

RegisterNetEvent('epsilon:admin:fillPlayerHunger', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    exports['epsilon-status']:FillHunger(targetId)
    notify(targetId, 'Faim remplie par un admin', NC.green, 'bi-egg-fried')
    notify(src, GetPlayerName(targetId) .. ' — faim remplie', NC.green, 'bi-egg-fried', 3)
    logAdmin(src, targetId, 'fill_player_hunger', nil)
end)

RegisterNetEvent('epsilon:admin:fillPlayerThirst', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    exports['epsilon-status']:FillThirst(targetId)
    notify(targetId, 'Soif remplie par un admin', NC.green, 'bi-droplet-fill')
    notify(src, GetPlayerName(targetId) .. ' — soif remplie', NC.green, 'bi-droplet-fill', 3)
    logAdmin(src, targetId, 'fill_player_thirst', nil)
end)

RegisterNetEvent('epsilon:admin:drainPlayerHunger', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    exports['epsilon-status']:DrainHunger(targetId, 10)
    notify(targetId, 'Faim drainée par un admin', NC.amber, 'bi-egg')
    notify(src, GetPlayerName(targetId) .. ' — faim drainée', NC.amber, 'bi-egg', 3)
    logAdmin(src, targetId, 'drain_player_hunger', nil)
end)

RegisterNetEvent('epsilon:admin:drainPlayerThirst', function(targetId)
    local src = source
    if not hasPerm(src, 'perm_health') then return end
    exports['epsilon-status']:DrainThirst(targetId, 10)
    notify(targetId, 'Soif drainée par un admin', NC.amber, 'bi-droplet')
    notify(src, GetPlayerName(targetId) .. ' — soif drainée', NC.amber, 'bi-droplet', 3)
    logAdmin(src, targetId, 'drain_player_thirst', nil)
end)

RegisterNetEvent('epsilon:admin:giveSelfItem', function(itemName, quantity)
    local src    = source
    local charId = exports['epsilon-inventory']:GetCharId(src)
    if not charId then return end
    local qty = math.max(1, math.floor(quantity or 1))
    local ok, err = exports['epsilon-inventory']:AddItem(charId, itemName, qty, {})
    if ok then
        exports['epsilon-inventory']:PushInventory(src)
        TriggerClientEvent('epsilon:ui:notify', src, { type='success', title='Inventaire', msg=itemName .. ' x' .. qty })
        logAdmin(src, nil, 'give_self_item', itemName, { quantity = qty })
    else
        TriggerClientEvent('epsilon:ui:notify', src, { type='error', title='Inventaire', msg=err or 'Erreur' })
    end
end)

-- ── Log action auto (client-side tools) ──────────────────────
RegisterNetEvent('epsilon:admin:logSelf', function(action, details, meta)
    local src = source
    if not isAdmin(src) then return end
    logAdmin(src, nil, action, details, meta)
end)

-- ── Log depuis une autre resource (ex: epsilon-inventory) ─────
AddEventHandler('epsilon:admin:log', function(adminSrc, targetSrc, action, reason, meta)
    logAdmin(adminSrc, targetSrc, action, reason, meta)
end)

-- ── Fetch admin logs ──────────────────────────────────────────────────────────
local LOG_FILTERS = {
    sanctions      = "action IN ('warn','kick','ban')",
    inventaire     = "(action LIKE '%item%' OR action = 'give_self_item')",
    joueur         = "(action IN ('heal_player','kill_player','revive_player','freeze_player','toggle_fire','toggle_cage','damage_player','teleport_to','bring_player','bring_back','heal_armour','fill_player_hunger','fill_player_thirst','drain_player_hunger','drain_player_thirst') OR action LIKE 'spawn_vehicle%')",
    outils         = "(action LIKE 'self_%' OR action LIKE 'super_%' OR action LIKE '%noclip%' OR action LIKE 'god%' OR action LIKE 'ghost%' OR action LIKE '%stamina%' OR action LIKE 'show_%' OR action LIKE 'teleport_coords%' OR action LIKE 'teleport_waypoint%' OR action LIKE 'mass_%')",
    serveur        = "(action = 'announce' OR action LIKE 'set_%' OR action LIKE 'mass_%')",
    context_menu   = "action LIKE 'ctx_%'",
}

RegisterNetEvent('epsilon:admin:getLogs', function(opts)
    local src = source
    if not isAdmin(src) then return end
    local limit  = 50
    local offset = math.max(0, tonumber(opts.offset) or 0)
    local cat    = opts.category or 'all'
    local search = opts.search   or ''

    -- Catégorie spéciale : reports (table séparée)
    if cat == 'reports' then
        local clauses = {}
        local params  = {}
        if search ~= '' then
            clauses[#clauses+1] = '(player_name LIKE ? OR target_name LIKE ? OR category LIKE ? OR description LIKE ?)'
            local like = '%'..search..'%'
            for _ = 1, 4 do params[#params+1] = like end
        end
        local where = #clauses > 0 and ('WHERE ' .. table.concat(clauses,' AND ')) or ''
        params[#params+1] = limit + 1
        params[#params+1] = offset
        local rows = MySQL.query.await(
            'SELECT id, player_name AS admin_name, target_name, category AS action, description AS reason, status, assigned_name, created_at FROM reports '..where..' ORDER BY created_at DESC LIMIT ? OFFSET ?',
            params
        )
        rows = rows or {}
        local hasMore = #rows > limit
        if hasMore then rows[#rows] = nil end
        TriggerClientEvent('epsilon:admin:logsResult', src, { logs = rows, hasMore = hasMore, offset = offset, isReports = true })
        return
    end

    local clauses = {}
    local params  = {}

    if LOG_FILTERS[cat] then
        clauses[#clauses+1] = LOG_FILTERS[cat]
    end

    if search ~= '' then
        clauses[#clauses+1] = '(admin_name LIKE ? OR target_name LIKE ? OR action LIKE ?)'
        local like = '%'..search..'%'
        params[#params+1] = like
        params[#params+1] = like
        params[#params+1] = like
    end

    local where = #clauses > 0 and ('WHERE ' .. table.concat(clauses,' AND ')) or ''
    params[#params+1] = limit + 1
    params[#params+1] = offset

    local rows = MySQL.query.await(
        'SELECT id,admin_name,target_name,action,reason,created_at FROM admin_logs '..where..' ORDER BY created_at DESC LIMIT ? OFFSET ?',
        params
    )
    rows = rows or {}

    local hasMore = #rows > limit
    if hasMore then rows[#rows] = nil end

    TriggerClientEvent('epsilon:admin:logsResult', src, { logs = rows, hasMore = hasMore, offset = offset })
end)

-- ── Jobs management ──────────────────────────────────────────
RegisterNetEvent('epsilon:admin:getJobs', function()
    local src = source
    if not isAdmin(src) then return end

    local jobs = MySQL.query.await('SELECT j.id, j.name, j.label, g.grade, g.label AS grade_label FROM jobs j LEFT JOIN job_grades g ON g.job_id = j.id WHERE j.is_active=1 ORDER BY j.label, g.grade') or {}

    local byJob = {}
    local order = {}
    for _, row in ipairs(jobs) do
        if not byJob[row.name] then
            byJob[row.name] = { id = row.id, name = row.name, label = row.label, grades = {} }
            order[#order + 1] = row.name
        end
        if row.grade ~= nil then
            byJob[row.name].grades[#byJob[row.name].grades + 1] = { grade = row.grade, label = row.grade_label or ('Grade ' .. row.grade) }
        end
    end

    local list = {}
    for _, name in ipairs(order) do list[#list + 1] = byJob[name] end
    TriggerClientEvent('epsilon:admin:jobsList', src, list)
end)

RegisterNetEvent('epsilon:admin:getPlayerJobs', function(targetId)
    local src = source
    if not isAdmin(src) then return end

    local charId = exports['epsilon-characters']:GetCharIdBySrc(targetId)
    if not charId then
        TriggerClientEvent('epsilon:admin:playerJobs', src, { targetId = targetId, jobs = {} })
        return
    end

    local rows = MySQL.query.await('SELECT jobs FROM characters WHERE id=?', { charId }) or {}
    local jobs = (rows[1] and json.decode(rows[1].jobs or '[]')) or {}

    -- Enrichir avec les labels
    local jobRows = MySQL.query.await('SELECT j.id, j.name, j.label, g.grade, g.label AS grade_label FROM jobs j LEFT JOIN job_grades g ON g.job_id = j.id ORDER BY j.id, g.grade') or {}
    local defs = {}
    for _, r in ipairs(jobRows) do
        if not defs[r.name] then defs[r.name] = { label = r.label, grades = {} } end
        if r.grade ~= nil then defs[r.name].grades[r.grade] = r.grade_label end
    end

    local result = {}
    for _, j in ipairs(jobs) do
        local def = defs[j.name]
        local gl  = def and def.grades[j.grade or 0] or ('Grade ' .. (j.grade or 0))
        result[#result + 1] = {
            name       = j.name,
            label      = def and def.label or j.name,
            grade      = j.grade or 0,
            gradeLabel = gl,
        }
    end

    TriggerClientEvent('epsilon:admin:playerJobs', src, { targetId = targetId, charId = charId, jobs = result })
end)

RegisterNetEvent('epsilon:admin:setJob', function(targetId, jobName, grade)
    local src = source
    if not isAdmin(src) then return end
    local charId = exports['epsilon-characters']:GetCharIdBySrc(targetId)
    if not charId then
        notify(src, 'Personnage non actif', NC.red, 'bi-x-circle-fill'); return
    end
    local ok, err = exports['epsilon-jobs']:AddJob(targetId, charId, jobName, grade or 0)
    if ok then
        notify(src, 'Job assigné: ' .. jobName, NC.green, 'bi-briefcase-fill')
        logAdmin(src, targetId, 'set_job', jobName, { grade = grade, charId = charId })
        TriggerServerEvent('epsilon:admin:getPlayerJobs', targetId)
        TriggerClientEvent('epsilon:admin:refreshPlayerJobs', src, targetId)
    else
        notify(src, err or 'Erreur', NC.red, 'bi-x-circle-fill')
    end
end)

RegisterNetEvent('epsilon:admin:removeJob', function(targetId, jobName)
    local src = source
    if not isAdmin(src) then return end
    local charId = exports['epsilon-characters']:GetCharIdBySrc(targetId)
    if not charId then
        notify(src, 'Personnage non actif', NC.red, 'bi-x-circle-fill'); return
    end
    local ok, err = exports['epsilon-jobs']:RemoveJob(targetId, charId, jobName)
    if ok then
        notify(src, 'Job retiré: ' .. jobName, NC.amber, 'bi-briefcase')
        logAdmin(src, targetId, 'remove_job', jobName, { charId = charId })
        TriggerClientEvent('epsilon:admin:refreshPlayerJobs', src, targetId)
    else
        notify(src, err or 'Erreur', NC.red, 'bi-x-circle-fill')
    end
end)

RegisterNetEvent('epsilon:admin:setGrade', function(targetId, jobName, grade)
    local src = source
    if not isAdmin(src) then return end
    local charId = exports['epsilon-characters']:GetCharIdBySrc(targetId)
    if not charId then
        notify(src, 'Personnage non actif', NC.red, 'bi-x-circle-fill'); return
    end
    local ok, err = exports['epsilon-jobs']:SetGrade(targetId, charId, jobName, grade)
    if ok then
        notify(src, 'Grade mis à jour', NC.green, 'bi-briefcase-fill')
        logAdmin(src, targetId, 'set_grade', jobName, { grade = grade, charId = charId })
        TriggerClientEvent('epsilon:admin:refreshPlayerJobs', src, targetId)
    else
        notify(src, err or 'Erreur', NC.red, 'bi-x-circle-fill')
    end
end)

Epsilon.Debug.Success('epsilon-admin server prêt')
