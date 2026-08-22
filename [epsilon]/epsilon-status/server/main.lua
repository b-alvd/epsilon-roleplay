-- ═══════════════════════════════════════════════════════════════════
-- epsilon-status / server/main.lua
-- Faim & Soif — tick toutes les 60s
-- ═══════════════════════════════════════════════════════════════════

local statuses    = {}   -- [charId] = { hunger, thirst }
local charToSrc   = {}   -- [charId] = src
local srcToChar   = {}   -- [src]    = charId
local pausedChars = {}   -- [charId] = true

-- Diminution par tick (60s)
local HUNGER_TICK = 0.8   -- faim  (~2h05 pour vider)
local THIRST_TICK = 1.0   -- soif  (~1h40 pour vider)

local ALERT_THRESHOLDS = { 30, 25, 20, 15, 10, 5 }

local function checkThresholds(src, prev, new, label, icon)
    for _, t in ipairs(ALERT_THRESHOLDS) do
        if prev > t and new <= t then
            TriggerClientEvent('epsilon:ui:notify', src, {
                type  = 'warning',
                title = label,
                msg   = ('Vous avez %s (%d%%)'):format(label:lower(), math.floor(new)),
                icon  = icon,
            })
            break  -- une seule notif par tick
        end
    end
end

local function clamp(v)
    return math.max(0.0, math.min(100.0, v))
end

local function pushStatus(charId)
    local src = charToSrc[charId]
    if not src then return end
    -- Ré-envoie l'inventaire complet avec les nouvelles valeurs
    local ok = pcall(function()
        exports['epsilon-inventory']:PushInventory(src)
    end)
    if not ok then
        -- epsilon-inventory pas encore prêt, on réessaie au prochain tick
    end
end

local function saveStatus(charId)
    local s = statuses[charId]
    if not s then return end
    MySQL.update.await(
        'UPDATE characters SET hunger=?, thirst=? WHERE id=?',
        { s.hunger, s.thirst, charId }
    )
end

-- ── Exports ──────────────────────────────────────────────────────────────────

exports('GetStatus', function(charId)
    return statuses[charId] or { hunger = 100.0, thirst = 100.0 }
end)

exports('ModifyStatus', function(charId, hungerDelta, thirstDelta)
    local s = statuses[charId]
    if not s then return end
    s.hunger = clamp(s.hunger + (hungerDelta or 0))
    s.thirst = clamp(s.thirst + (thirstDelta or 0))
    saveStatus(charId)
    pushStatus(charId)
end)

local function adminModify(src, hungerDelta, thirstDelta)
    local charId = srcToChar[src]
    if not charId then return end
    local s = statuses[charId]
    if not s then return end
    s.hunger = clamp(s.hunger + (hungerDelta or 0))
    s.thirst = clamp(s.thirst + (thirstDelta or 0))
    MySQL.update('UPDATE characters SET hunger=?, thirst=? WHERE id=?', { s.hunger, s.thirst, charId })
    pushStatus(charId)
end

exports('FillHunger', function(src)
    local charId = srcToChar[src]
    if not charId or not statuses[charId] then return end
    adminModify(src, 100 - statuses[charId].hunger, 0)
end)

exports('FillThirst', function(src)
    local charId = srcToChar[src]
    if not charId or not statuses[charId] then return end
    adminModify(src, 0, 100 - statuses[charId].thirst)
end)

exports('DrainHunger', function(src, amt)
    adminModify(src, -(amt or 10), 0)
end)

exports('DrainThirst', function(src, amt)
    adminModify(src, 0, -(amt or 10))
end)

exports('TogglePauseStatus', function(src)
    local charId = srcToChar[src]
    if not charId then return false end
    pausedChars[charId] = not (pausedChars[charId] or false)
    pushStatus(charId)
    return pausedChars[charId]
end)

exports('IsPaused', function(charId)
    return pausedChars[charId] or false
end)

-- ── Chargement personnage ─────────────────────────────────────────────────────

RegisterNetEvent('epsilon:status:activate', function(charId)
    local src = source
    srcToChar[src] = charId
    charToSrc[charId] = src

    local rows = MySQL.query.await(
        'SELECT hunger, thirst FROM characters WHERE id=?', { charId }
    )
    if rows and rows[1] then
        statuses[charId] = {
            hunger = clamp(rows[1].hunger or 100.0),
            thirst = clamp(rows[1].thirst or 100.0),
        }
    else
        statuses[charId] = { hunger = 100.0, thirst = 100.0 }
    end
end)

AddEventHandler('playerDropped', function()
    local src    = source
    local charId = srcToChar[src]
    if charId then
        saveStatus(charId)
        statuses[charId]  = nil
        charToSrc[charId] = nil
    end
    srcToChar[src] = nil
    if charId then pausedChars[charId] = nil end
end)

-- ── Tick ─────────────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(60000)
        for charId, s in pairs(statuses) do
            local src        = charToSrc[charId]
            local prevHunger = s.hunger
            local prevThirst = s.thirst
            if not pausedChars[charId] then
                s.hunger = clamp(s.hunger - HUNGER_TICK)
                s.thirst = clamp(s.thirst - THIRST_TICK)
            end
            saveStatus(charId)
            pushStatus(charId)
            if src then
                checkThresholds(src, prevHunger, s.hunger, 'Faim',  'bi-egg-fried')
                checkThresholds(src, prevThirst, s.thirst, 'Soif',  'bi-droplet-fill')
            end
        end
    end
end)
