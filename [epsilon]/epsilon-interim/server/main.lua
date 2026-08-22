-- ════════════════════════════════════════════════════════════════
--  epsilon-interim / server/main.lua
-- ════════════════════════════════════════════════════════════════

-- math.random non fiable côté serveur FiveM — LCG avec entropy du game timer
local _rng = (os.time() ~ 0xDEAD)
local _callN = 0
local function randInt(min, max)
    _callN = _callN + 1
    _rng = (_rng * 1664525 + 1013904223 + GetGameTimer() + _callN) & 0x7FFFFFFF
    if min >= max then return min end
    return min + (_rng % (max - min + 1))
end

local liveSessions = {}   -- { [charId]  = { sessionId, missionName, actions, total, startedAt, src } }
local srcToChar    = {}   -- { [src]     = charId }  — pour playerDropped

-- ── Récupération charId après restart resource ───────────────────────────────
local function getCharIdForSrc(src)
    -- 1. epsilon-jobs (source principale)
    local ok1, v1 = pcall(function() return exports['epsilon-jobs']:GetCharIdBySrc(src) end)
    if ok1 and v1 then return v1 end

    -- 2. epsilon-characters (stocké depuis la sélection du perso, survit aux restarts partiels)
    local ok2, v2 = pcall(function() return exports['epsilon-characters']:GetCharIdBySrc(src) end)
    if ok2 and v2 then return v2 end

    -- 3. epsilon-economy
    local ok3, v3 = pcall(function() return exports['epsilon-economy']:GetCharIdBySrc(src) end)
    if ok3 and v3 then return v3 end

    -- 4. DB : dernier personnage joué par la license du joueur
    local license
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id:sub(1,8) == 'license:' then license = id:sub(9); break end
    end
    if license then
        local rows = MySQL.query.await([[
            SELECT c.id FROM characters c
            JOIN players p ON p.id = c.player_id
            WHERE p.license = ?
            ORDER BY c.last_played DESC
            LIMIT 1
        ]], { license })
        if rows and rows[1] then return rows[1].id end
    end

    return nil
end

RegisterNetEvent('epsilon:interim:requestCharId', function()
    local src    = source
    local charId = getCharIdForSrc(src)
    Epsilon.Debug.Info('[interim] requestCharId src=%d → charId=%s', src, tostring(charId))
    if charId then
        TriggerClientEvent('epsilon:interim:setCharId', src, charId)
    end
end)

-- ── Démarrage session ─────────────────────────────────────────────────────────
RegisterNetEvent('epsilon:interim:start', function(charId, missionName)
    local src = source
    if not charId or not missionName then return end

    if liveSessions[charId] then
        TriggerClientEvent('epsilon:ui:notify', src, {
            title = 'Intérim', msg = 'Vous êtes déjà en mission.', type = 'warning',
        })
        return
    end
    if not Config.Missions[missionName] then
        Epsilon.Debug.Warn('[interim] Mission inconnue: %s', missionName)
        return
    end

    local result = MySQL.insert.await(
        'INSERT INTO mission_sessions (character_id, mission_name) VALUES (?, ?)',
        { charId, missionName }
    )
    if not result then return end

    liveSessions[charId] = {
        sessionId   = result,
        missionName = missionName,
        actions     = 0,
        total       = 0.0,
        startedAt   = os.time(),
        src         = src,
    }
    srcToChar[src] = charId

    TriggerEvent('epsilon:log', {
        action  = 'interim_start',
        charId  = charId,
        details = ('mission=%s sessionId=%d'):format(missionName, result),
        src     = src,
    })

    local label = Config.Missions[missionName] and Config.Missions[missionName].label or missionName
    TriggerClientEvent('epsilon:ui:notify', src, {
        title = 'Intérim — ' .. label,
        msg   = 'Mission démarrée. Bonne chance !',
        type  = 'info',
    })
end)

-- ── Action réalisée (tracking uniquement, pas de paiement) ──────────────────
RegisterNetEvent('epsilon:interim:action', function(charId, missionName, actionName)
    local src = source
    if not charId then return end

    local sess = liveSessions[charId]
    if not sess or sess.missionName ~= missionName then return end

    sess.actions = sess.actions + 1
    MySQL.query.await(
        'UPDATE mission_sessions SET actions_count = ? WHERE id = ?',
        { sess.actions, sess.sessionId }
    )

    -- Calcul du pay de cette action et envoi immédiat au client pour affichage live
    local def = Config.Missions[missionName]
    if def and def.actions and actionName then
        local actDef = def.actions[actionName]
        if actDef then
            local p = actDef.pay
            local earned = 0
            if type(p) == 'table' then
                earned = randInt(p.min or 0, p.max or 0)
            else
                earned = p or 0
            end
            sess.total = (sess.total or 0) + earned
            TriggerClientEvent('epsilon:interim:actionPay', src, earned)
        end
    end
end)

-- ── Fin de tournée : paiement unique au dépôt ────────────────────────────────
RegisterNetEvent('epsilon:interim:complete', function(charId, missionName, doneCount)
    local src = source
    if not charId then return end

    local sess = liveSessions[charId]
    if not sess or sess.missionName ~= missionName then return end

    local def = Config.Missions[missionName]
    if not def then return end

    -- Le total a été accumulé en temps réel via epsilon:interim:action
    local total = sess.total or 0

    -- Sync du total exact vers le client (évite décalage réseau avec runEarned)
    TriggerClientEvent('epsilon:interim:earnedSync', src, total)

    -- Advanced notification (avant tout appel externe qui pourrait planter)
    TriggerClientEvent('epsilon:ui:notifyAdvanced', src, {
        title    = 'Salaire reçu',
        subtitle = def.label,
        text     = ('+%d$ pour %d arrêts'):format(total, doneCount),
        image    = 'argent',
        duration = 8,
    })

    -- Paiement
    local label = ('%s — %d %s'):format(
        def.label,
        doneCount,
        doneCount > 1 and 'actions' or 'action'
    )
    local ok, err = pcall(function()
        exports['epsilon-economy']:AddMoney(charId, total, label, 'mission')
    end)
    if not ok then
        Epsilon.Debug.Warn('[interim] AddMoney failed: %s', tostring(err))
    end

    MySQL.query.await(
        'UPDATE mission_sessions SET ended_at = NOW(), total_earned = ? WHERE id = ?',
        { total, sess.sessionId }
    )

    TriggerEvent('epsilon:log', {
        action  = 'interim_complete',
        charId  = charId,
        details = ('mission=%s done=%d total=%d$'):format(missionName, doneCount, total),
        src     = src,
    })
end)

-- ── Fin session ───────────────────────────────────────────────────────────────
local function closeSession(charId, src)
    local sess = liveSessions[charId]
    if not sess then return end

    MySQL.query.await(
        'UPDATE mission_sessions SET ended_at = NOW(), actions_count = ?, total_earned = ? WHERE id = ?',
        { sess.actions, sess.total, sess.sessionId }
    )

    TriggerEvent('epsilon:log', {
        action  = 'interim_stop',
        charId  = charId,
        details = ('mission=%s actions=%d total=%.2f$ duration=%ds'):format(
            sess.missionName, sess.actions, sess.total, os.time() - sess.startedAt
        ),
        src = src,
    })

    liveSessions[charId] = nil
    if src then srcToChar[src] = nil end
end

RegisterNetEvent('epsilon:interim:stop', function(charId)
    local src = source
    if not charId then return end

    local sess = liveSessions[charId]
    if not sess then return end

    TriggerClientEvent('epsilon:interim:stopped', src)

    closeSession(charId, src)
end)

-- ── Déconnexion ───────────────────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src     = source
    local charId  = srcToChar[src]
    if charId then closeSession(charId, nil) end
end)

-- ── Exports panel admin ───────────────────────────────────────────────────────
exports('GetLiveSession', function(charId)
    return liveSessions[charId]
end)

exports('GetAllLiveSessions', function()
    local out = {}
    for charId, sess in pairs(liveSessions) do
        out[#out + 1] = {
            charId      = charId,
            missionName = sess.missionName,
            actions     = sess.actions,
            total       = sess.total,
            elapsed     = os.time() - sess.startedAt,
        }
    end
    return out
end)
