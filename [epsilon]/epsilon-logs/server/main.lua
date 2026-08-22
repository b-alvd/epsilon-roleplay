-- epsilon-logs: logging universel de TOUS les événements serveur importants
-- Chaque action est insérée en batch dans server_logs (MySQL)
-- Le debug console est géré séparément par epsilon-core/shared/debug.lua

local queue   = {}
local FLUSH   = (Epsilon.Config.Logs.FlushInterval or 5) * 1000
local BATCH   = Epsilon.Config.Logs.BatchSize or 50

-- json.null est le sentinel FiveM pour NULL SQL (évite les trous dans les arrays Lua)
local NULL = json.null

-- ============================================================
-- Insert batch — un INSERT par entrée pour éviter les trous nil dans les params
-- ============================================================
local SQL_INSERT = 'INSERT INTO server_logs (type, source_id, source_name, target_id, target_name, action, details, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'

local function flushQueue()
    if #queue == 0 then return end

    local count = math.min(#queue, BATCH)
    for i = 1, count do
        local entry = table.remove(queue, 1)
        -- On construit les params avec des indices explicites (pas de trous nil)
        local p = {}
        p[1] = entry.type        or 'generic'
        p[2] = entry.source_id   or NULL
        p[3] = entry.source_name or NULL
        p[4] = entry.target_id   or NULL
        p[5] = entry.target_name or NULL
        p[6] = entry.action
        p[7] = entry.details     or NULL
        p[8] = entry.metadata and json.encode(entry.metadata) or NULL
        MySQL.query.await(SQL_INSERT, p)
    end
end

-- Flush periodically
CreateThread(function()
    while true do
        Wait(FLUSH)
        if Epsilon.Config.Logs.Enabled then
            local ok, err = pcall(flushQueue)
            if not ok then
                Epsilon.Debug.Error('[Logs] Erreur flush: %s', tostring(err))
            end
        end
    end
end)

-- ============================================================
-- Public API — TriggerEvent('epsilon:log', { ... })
-- ============================================================
-- Champs:
--   type        (string)  — catégorie: connection|character|chat|admin|vehicle|money|death|...
--   source_id   (number)  — server id du joueur source (optionnel)
--   source_name (string)  — nom du joueur source
--   target_id   (number)  — server id de la cible (optionnel)
--   target_name (string)  — nom de la cible
--   action      (string)  — action courte: 'connect', 'disconnect', 'create_character', ...
--   details     (string)  — description lisible
--   metadata    (table)   — données arbitraires supplémentaires

AddEventHandler('epsilon:log', function(entry)
    if not Epsilon.Config.Logs.Enabled then return end
    if not entry or not entry.action then return end

    queue[#queue + 1] = {
        type        = entry.type        or 'generic',
        source_id   = entry.source_id   or nil,
        source_name = entry.source_name or nil,
        target_id   = entry.target_id   or nil,
        target_name = entry.target_name or nil,
        action      = entry.action,
        details     = entry.details     or nil,
        metadata    = entry.metadata    or nil,
    }

    Epsilon.Debug.Event('[LOG] [%s] %s — %s', entry.type or '?', entry.action, entry.details or '')
end)

-- Alias réseau (depuis client si nécessaire)
RegisterNetEvent('epsilon:log:client', function(entry)
    if not entry then return end
    local src = source
    entry.source_id   = entry.source_id   or src
    entry.source_name = entry.source_name or GetPlayerName(src)
    TriggerEvent('epsilon:log', entry)
end)

-- ============================================================
-- Hooks automatiques — événements FiveM natifs
-- ============================================================

AddEventHandler('playerConnecting', function(name, _, deferrals)
    TriggerEvent('epsilon:log', {
        type        = 'connection',
        source_id   = source,
        source_name = name,
        action      = 'connecting',
        details     = string.format('%s tente de se connecter', name),
    })
end)

AddEventHandler('playerDropped', function(reason)
    local src  = source
    local name = GetPlayerName(src) or 'Inconnu'
    TriggerEvent('epsilon:log', {
        type        = 'connection',
        source_id   = src,
        source_name = name,
        action      = 'disconnect',
        details     = string.format('%s déconnecté — %s', name, reason),
        metadata    = { reason = reason },
    })
end)

-- Flush immédiat à l'arrêt du serveur
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    pcall(flushQueue)
end)

Epsilon.Debug.Success('epsilon-logs prêt — flush toutes les %ds, batch %d', FLUSH / 1000, BATCH)
