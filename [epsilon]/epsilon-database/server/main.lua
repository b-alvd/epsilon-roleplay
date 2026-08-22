-- epsilon-database: auto-migrations + DB wrapper exports

local MIGRATION_FILES = {
    'migrations/schema.sql',
}

-- Split SQL file into individual statements and run each
local function runFile(file)
    local content = LoadResourceFile(GetCurrentResourceName(), file)
    if not content then
        Epsilon.Debug.Error('[DB] Fichier de migration introuvable: %s', file)
        return 0, 0
    end

    local stripped = content:gsub('%-%-[^\n]*', '')
    local statements = {}
    for stmt in stripped:gmatch('([^;]+)') do
        local trimmed = stmt:match('^%s*(.-)%s*$')
        if trimmed and #trimmed > 10 then
            statements[#statements + 1] = trimmed
        end
    end

    local ok_count, fail_count = 0, 0
    for _, stmt in ipairs(statements) do
        local success, err = pcall(function()
            MySQL.query.await(stmt, {})
        end)
        if success then
            ok_count = ok_count + 1
        else
            fail_count = fail_count + 1
            Epsilon.Debug.Warn('[DB] %s — stmt ignoré: %s', file, tostring(err))
        end
    end
    return ok_count, fail_count
end

local function runMigrations()
    local total_ok, total_fail = 0, 0
    for _, file in ipairs(MIGRATION_FILES) do
        local ok, fail = runFile(file)
        total_ok   = total_ok   + ok
        total_fail = total_fail + fail
    end
    Epsilon.Debug.Success('[DB] Migrations terminées — %d OK / %d erreurs', total_ok, total_fail)
end

-- Prune old logs (called on start based on retention config)
local function pruneOldLogs()
    local days = Epsilon.Config.Logs.RetentionDays or 90
    local deleted = MySQL.query.await(
        'DELETE FROM server_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)',
        { days }
    )
    if deleted and deleted.affectedRows and deleted.affectedRows > 0 then
        Epsilon.Debug.Info('[DB] Purge logs: %d entrées supprimées (> %dj)', deleted.affectedRows, days)
    end
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(800) -- laisser oxmysql s'initialiser
    runMigrations()
    pruneOldLogs()
    Epsilon.Debug.Success('epsilon-database prêt')
end)
