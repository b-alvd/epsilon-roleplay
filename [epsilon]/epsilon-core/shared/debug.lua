-- epsilon-core: debug module (console prints ONLY — no DB)

local cfg = {
    enabled = true,
    prefix  = 'EPSILON',
}

local CLR = {
    reset   = '\27[0m',
    bold    = '\27[1m',
    grey    = '\27[90m',
    cyan    = '\27[36m',
    green   = '\27[32m',
    yellow  = '\27[33m',
    red     = '\27[31m',
    magenta = '\27[35m',
    blue    = '\27[34m',
}

local LEVELS = {
    info    = { color = CLR.cyan,    tag = 'INFO'  },
    success = { color = CLR.green,   tag = 'OK'    },
    warn    = { color = CLR.yellow,  tag = 'WARN'  },
    error   = { color = CLR.red,     tag = 'ERROR' },
    debug   = { color = CLR.magenta, tag = 'DEBUG' },
    db      = { color = CLR.blue,    tag = 'DB'    },
    event   = { color = CLR.grey,    tag = 'EVENT' },
}

local function emit(level, msg, ...)
    if not cfg.enabled and level ~= 'error' then return end

    local lvl  = LEVELS[level] or LEVELS.info
    local text = type(msg) == 'string' and (select('#', ...) > 0 and string.format(msg, ...) or msg) or tostring(msg)
    local resource = GetCurrentResourceName and GetCurrentResourceName() or cfg.prefix

    print(string.format(
        '%s[%s]%s %s[%s]%s %s',
        CLR.grey, resource, CLR.reset,
        lvl.color .. CLR.bold, lvl.tag, CLR.reset,
        text
    ))
end

Epsilon        = Epsilon or {}
Epsilon.Debug  = {
    Info     = function(m, ...) emit('info',    m, ...) end,
    Success  = function(m, ...) emit('success', m, ...) end,
    Warn     = function(m, ...) emit('warn',    m, ...) end,
    Error    = function(m, ...) emit('error',   m, ...) end,
    Debug    = function(m, ...) emit('debug',   m, ...) end,
    DB       = function(m, ...) emit('db',      m, ...) end,
    Event    = function(m, ...) emit('event',   m, ...) end,

    Toggle   = function(state)
        cfg.enabled = (state ~= nil) and state or (not cfg.enabled)
        emit('info', 'Debug mode: %s', cfg.enabled and 'ON' or 'OFF')
    end,

    IsEnabled = function() return cfg.enabled end,
}
