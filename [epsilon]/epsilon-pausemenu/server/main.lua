-- epsilon-pausemenu — server

-- ── Signalement ───────────────────────────────────────────────
local COOLDOWNS = {}

RegisterNetEvent('epsilon:pausemenu:sendReport', function(rType, category, targetName, description)
    local src     = source
    local license = GetPlayerIdentifierByType(src, 'license') or ''

    local now = os.time()
    if COOLDOWNS[license] and (now - COOLDOWNS[license]) < 60 then
        TriggerClientEvent('epsilon:ui:notify', src, { text = 'Attends une minute entre deux signalements', icon = 'bi-clock', color = '#f59e0b', duration = 5 })
        return
    end

    if #description < 10 or #description > 500 then return end

    COOLDOWNS[license] = now

    local reportId = MySQL.insert.await(
        'INSERT INTO reports (type, player_id, player_name, player_license, license, category, target_name, description) VALUES (?,?,?,?,?,?,?,?)',
        {
            rType,
            tonumber(src),
            GetPlayerName(src) or '',
            license,
            license,
            category,
            targetName,
            description,
        }
    )

    print(string.format('^3[PauseMenu] Report [%s/%s] reçu de %s^7', rType, category, GetPlayerName(src)))

    -- Notifier le joueur que son report a été reçu
    TriggerClientEvent('epsilon:ui:reportStatus', src, {
        id         = reportId,
        status     = 'open',
        created_at = os.date('%Y-%m-%dT%H:%M:%S'),
    })

    -- Notifier les admins en ligne (notification + mise à jour de leur liste)
    local report = {
        id          = reportId,
        type        = rType,
        player_id   = tonumber(src),
        player_name = GetPlayerName(src) or '',
        category    = category,
        target_name = targetName,
        description = description,
        status      = 'open',
        created_at  = os.date('%Y-%m-%d %H:%M:%S'),
    }

    for _, pid in ipairs(GetPlayers()) do
        local p = tonumber(pid)
        if IsPlayerAceAllowed(p, 'epsilon.admin') then
            local label = rType == 'signalement' and 'Signalement' or 'Report'
            TriggerClientEvent('epsilon:ui:notify', p, {
                text     = string.format('[%s] %s — %s', label, GetPlayerName(src), category),
                icon     = rType == 'signalement' and 'bi-flag-fill' or 'bi-clipboard-fill',
                color    = '#f59e0b',
                duration = 8,
            })
            TriggerClientEvent('epsilon:admin:newReport', p, report)
        end
    end
end)

-- ── Données joueur pour le panneau Personnage ─────────────────
local function buildJobsPayload(charId)
    local ok1, rawJobs = pcall(function() return exports['epsilon-jobs']:GetJobs(charId) end)
    local ok2, allDefs = pcall(function() return exports['epsilon-jobs']:GetAllDefs() end)
    if not ok1 or type(rawJobs) ~= 'table' then return {} end
    local defsMap = {}
    if ok2 and type(allDefs) == 'table' then
        for _, def in ipairs(allDefs) do defsMap[def.name] = def end
    end
    local out = {}
    for _, j in ipairs(rawJobs) do
        local def = defsMap[j.name] or {}
        local gradeInfo = {}
        if def.grades then
            for _, g in ipairs(def.grades) do
                if g.grade == j.grade then gradeInfo = g; break end
            end
        end
        out[#out+1] = {
            name       = j.name,
            label      = def.label or j.name,
            gradeLabel = gradeInfo.label or ('Échelon ' .. (j.grade or 0)),
            salary     = gradeInfo.salary or 0,
            color      = def.color or '#6b7280',
            type       = def.type or 'fixe',
        }
    end
    return out
end

RegisterNetEvent('epsilon:pausemenu:getData', function()
    local src    = source
    local player = exports['epsilon-characters']:GetPlayer(src)
    local charId = exports['epsilon-characters']:GetCharIdBySrc(src)

    local bankBalance = 0
    if charId then
        local ok, bal = pcall(function() return exports['epsilon-economy']:GetBalance(charId) end)
        if ok then bankBalance = tonumber(bal) or 0 end
    end

    local cash = 0
    if charId then
        local rows = MySQL.query.await(
            "SELECT COALESCE(SUM(pi.quantity),0) AS cash FROM player_items pi JOIN items i ON pi.name=i.name WHERE pi.character_id=? AND JSON_UNQUOTE(JSON_EXTRACT(i.data,'$.type'))='money'",
            { charId }
        )
        if rows and rows[1] then cash = tonumber(rows[1].cash) or 0 end
    end

    local playtime = 0
    if player and player.db_id then
        local rows = MySQL.query.await('SELECT total_playtime FROM players WHERE id=?', { player.db_id })
        if rows and rows[1] then playtime = tonumber(rows[1].total_playtime) or 0 end
    end

    local hunger, thirst = 100.0, 100.0
    if charId then
        local ok, status = pcall(function() return exports['epsilon-status']:GetStatus(charId) end)
        if ok and status then
            hunger = tonumber(status.hunger) or 100.0
            thirst = tonumber(status.thirst) or 100.0
        end
    end

    local characterName = ''
    if player and player.activeCharId and type(player.characters) == 'table' then
        for _, char in ipairs(player.characters) do
            if char.id == player.activeCharId then
                local fn = tostring(char.firstname or '')
                local ln = tostring(char.lastname  or '')
                characterName = (fn .. ' ' .. ln):gsub('^%s+',''):gsub('%s+$','')
                break
            end
        end
    end

    TriggerClientEvent('epsilon:pausemenu:dataResult', src, {
        playerName     = GetPlayerName(src) or '',
        characterName  = characterName,
        serverId       = src,
        ping           = GetPlayerPing(src),
        citizenId      = charId and tostring(charId) or nil,
        cash           = cash,
        bankBalance    = bankBalance,
        playtime       = playtime,
        hunger         = hunger,
        thirst         = thirst,
        jobs           = charId and buildJobsPayload(charId) or {},
    })
end)

-- ── Tile clicks ───────────────────────────────────────────────
RegisterNetEvent('epsilon:pausemenu:tileClicked', function(_tileId) end)
