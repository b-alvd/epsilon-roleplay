-- epsilon-core: global server configuration

Epsilon        = Epsilon or {}
Epsilon.Config = {

    -- General
    ServerName   = 'Epsilon Roleplay',
    Locale       = 'fr',
    MaxSlots     = 64,

    -- Debug (console prints only)
    Debug = {
        Enabled  = true,
        LogLevel = 'debug', -- info | debug | warn | error
    },

    -- Character system
    Characters = {
        MaxPerPlayer = 3,
        DefaultSpawn = { x = -1041.07, y = -2743.40, z = 13.94, heading = 329.15 },
        AutoSaveInterval = 120, -- seconds
    },

    -- Database logs
    Logs = {
        Enabled         = true,
        RetentionDays   = 90,  -- logs older than N days are pruned on restart
        BatchSize       = 50,  -- insert queue batch size
        FlushInterval   = 5,   -- seconds between batch flushes
    },

}
