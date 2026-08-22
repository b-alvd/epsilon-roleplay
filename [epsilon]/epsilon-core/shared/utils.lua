-- epsilon-core: shared utilities

Epsilon = Epsilon or {}
Epsilon.Utils = {}

-- Safe JSON encode
function Epsilon.Utils.ToJSON(data)
    local ok, result = pcall(json.encode, data)
    return ok and result or '{}'
end

-- Safe JSON decode
function Epsilon.Utils.FromJSON(str)
    if not str or str == '' then return {} end
    local ok, result = pcall(json.decode, str)
    return ok and result or {}
end

-- Get player identifiers as table
function Epsilon.Utils.GetIdentifiers(src)
    local ids = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id then
            local type_ = id:match('^([^:]+):')
            if type_ then ids[type_] = id end
        end
    end
    return ids
end

-- Get primary license
function Epsilon.Utils.GetLicense(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 8) == 'license:' then
            return id
        end
    end
    return nil
end

-- Trim whitespace
function Epsilon.Utils.Trim(s)
    return s and s:match('^%s*(.-)%s*$') or ''
end

-- Format timestamp
function Epsilon.Utils.Timestamp()
    return os.date('%Y-%m-%d %H:%M:%S')
end

-- Table contains value
function Epsilon.Utils.Contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

-- Deep copy table
function Epsilon.Utils.DeepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = type(v) == 'table' and Epsilon.Utils.DeepCopy(v) or v
    end
    return copy
end

-- Clamp number
function Epsilon.Utils.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Round float
function Epsilon.Utils.Round(val, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(val * mult + 0.5) / mult
end
