-- epsilon-bank / client/main.lua

local inAgency   = false
local agencyLabel = ''
local atmNearby  = false

-- Modèles de props ATM présents dans GTA V
local ATM_MODELS = {
    GetHashKey('prop_atm_01'),
    GetHashKey('prop_atm_02'),
    GetHashKey('prop_atm_03'),
    GetHashKey('prop_fleeca_atm'),
}
local ATM_RADIUS = 1.5

-- ── Blips agences ────────────────────────────────────────────────────────────

CreateThread(function()
    for _, loc in ipairs(Config.Agencies) do
        local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
        SetBlipSprite(blip, 108)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 2)
        SetBlipCategory(blip, 253)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ── Détection agences (proximité) ────────────────────────────────────────────

local function distSq(x1, y1, z1, x2, y2, z2)
    local dx, dy, dz = x1-x2, y1-y2, z1-z2
    return dx*dx + dy*dy + dz*dz
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local px, py, pz = table.unpack(GetEntityCoords(ped))
        local found, label = false, ''

        for _, loc in ipairs(Config.Agencies) do
            if distSq(px, py, pz, loc.x, loc.y, loc.z) < loc.radius * loc.radius then
                found = true; label = loc.label; break
            end
        end

        if found ~= inAgency or (found and label ~= agencyLabel) then
            inAgency   = found
            agencyLabel = label
        end

        Wait(found and 0 or 500)
    end
end)

-- ── Détection ATM (scan de props monde) ──────────────────────────────────────

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local px, py, pz = table.unpack(GetEntityCoords(ped))
        local found = false

        for _, model in ipairs(ATM_MODELS) do
            local obj = GetClosestObjectOfType(px, py, pz, ATM_RADIUS, model, false, false, false)
            if obj ~= 0 then found = true; break end
        end

        if found ~= atmNearby then
            atmNearby = found
            TriggerEvent('epsilon:bank:atmNearbyChanged', atmNearby)
        end

        Wait(found and 0 or 500)
    end
end)

-- ── Hint [E] + interaction agences ───────────────────────────────────────────

local _helpState = nil -- 'agency' | 'atm' | nil

local function UpdateHelpNotif(newState)
    if newState == _helpState then return end
    _helpState = newState
    if newState == 'agency' then
        exports['epsilon-ui']:ShowHelpNotification('[E] Ouvrir le menu de l\'agence')
    elseif newState == 'atm' then
        exports['epsilon-ui']:ShowHelpNotification('Ouvrez votre inventaire et glissez la carte bancaire sur l\'ATM')
    else
        exports['epsilon-ui']:HideHelpNotification()
    end
end

CreateThread(function()
    while true do
        if inAgency then
            UpdateHelpNotif('agency')
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('epsilon:bank:getData', { mode = 'bank' })
            end
            Wait(0)
        elseif atmNearby then
            UpdateHelpNotif('atm')
            if IsControlJustPressed(0, 38) then
                TriggerEvent('epsilon:inventory:open')
            end
            Wait(0)
        else
            UpdateHelpNotif(nil)
            Wait(200)
        end
    end
end)

-- Re-envoyer l'état ATM quand l'inventaire s'ouvre (React monte après l'event initial)
AddEventHandler('epsilon:ui:open', function(panelName)
    if panelName == 'inventory' then
        SetTimeout(150, function()
            TriggerEvent('epsilon:bank:atmNearbyChanged', atmNearby)
        end)
    end
end)

-- ── Réception données banque → ouverture UI selon mode ───────────────────────

RegisterNetEvent('epsilon:bank:dataResult', function(data)
    exports['epsilon-ui']:HideHelpNotification()
    if data and data.mode == 'atm' then
        -- Panel ATM déjà ouvert — epsilon-ui/client relaie la data via NUI message
    else
        TriggerEvent('epsilon:ui:open', 'bank', data)
        SetNuiFocus(true, true)
    end
end)

-- ── Prompt ATM (PIN) → NUI focus rétabli ─────────────────────────────────────

RegisterNetEvent('epsilon:bank:atmOpen', function(data)
    exports['epsilon-ui']:HideHelpNotification()
    TriggerEvent('epsilon:ui:open', 'atm', data)
    SetNuiFocus(true, true)
end)

-- ── Fermeture UI ─────────────────────────────────────────────────────────────

AddEventHandler('epsilon:bank:close', function()
    SetNuiFocus(false, false)
    TriggerEvent('epsilon:ui:close')
    local prev = _helpState
    _helpState = nil
    UpdateHelpNotif(prev)
end)
