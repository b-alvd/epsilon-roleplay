-- ═══════════════════════════════════════════════════════════════════
-- epsilon-inventory / client/main.lua
-- ═══════════════════════════════════════════════════════════════════

local isOpen       = false
local charId       = nil
local currentInv   = nil
local activeSlot         = nil
local activeHash         = nil
local activeWeaponItemId = nil
local activeMaxAmmo      = 0
local clipAmmo           = 0   -- source de vérité Lua (balles dans le chargeur)

-- Envoyer un message NUI via epsilon-ui (seule resource avec une page NUI)
local function uiSend(msg)
    TriggerEvent('epsilon:inventory:ui:relay', msg)
end

-- ── Spawn personnage ─────────────────────────────────────────────────────────
-- epsilon:spawn:complete est un event LOCAL déclenché par epsilon-characters après le spawn
AddEventHandler('epsilon:spawn:complete', function(data)
    charId = data.id
    TriggerServerEvent('epsilon:inventory:setActiveChar', data.id, data.firstname, data.lastname)
end)

-- ── Récupérer le perso actif si la resource démarre en cours de session ───────
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetTimeout(1500, function()
        TriggerServerEvent('epsilon:inventory:requestInventory')
    end)
end)

RegisterNetEvent('epsilon:inventory:setCharId', function(id)
    charId = id
end)

-- ── Recevoir l'inventaire ────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:load', function(inv)
    currentInv = inv
    -- Si l'arme active n'est plus dans l'inventaire, la retirer
    if activeHash then
        local stillHas = false
        for _, wi in ipairs(inv.weapons or {}) do
            if GetHashKey(wi.name) == activeHash then
                stillHas = true; break
            end
        end
        if not stillHas then
            RemoveWeaponFromPed(PlayerPedId(), activeHash)
            activeHash = nil; activeSlot = nil
            uiSend({ action = 'epsilon:inventory:activeSlot', data = nil })
        end
    end
    uiSend({ action = 'epsilon:inventory:hotbar', data = inv.hotbar or {} })
    if isOpen then
        uiSend({ action = 'epsilon:inventory:update', data = inv })
    end
end)

-- ── Ouvrir / fermer ──────────────────────────────────────────────────────────
local function openInventory()
    if not charId or not currentInv then
        print('[epsilon-inventory] openInventory: charId=' .. tostring(charId) .. ' inv=' .. tostring(currentInv ~= nil))
        return
    end
    isOpen = true
    -- Charger les items au sol immédiatement à l'ouverture
    local c = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('epsilon:inventory:getGroundItems', c.x, c.y, c.z)
    TriggerEvent('epsilon:ui:open', 'inventory', currentInv)
end

local function closeInventory()
    isOpen = false
    TriggerEvent('epsilon:ui:close')
end

RegisterCommand('+inv', function()
    if isOpen then closeInventory() else openInventory() end
end, false)

RegisterKeyMapping('+inv', 'Ouvrir l\'inventaire', 'keyboard', 'TAB')

-- Permet à d'autres ressources d'ouvrir l'inventaire (ex: ATM drag)
AddEventHandler('epsilon:inventory:open', function()
    if not isOpen then openInventory() end
end)

-- ── NUI callbacks depuis epsilon-ui ─────────────────────────────────────────
AddEventHandler('epsilon:inventory:nui:inventory:close', function()
    closeInventory()
end)

AddEventHandler('epsilon:inventory:nui:inventory:useItem', function(d)
    TriggerServerEvent('epsilon:inventory:useItem', d.id)
end)

AddEventHandler('epsilon:inventory:nui:inventory:moveItem', function(d)
    TriggerServerEvent('epsilon:inventory:moveItem', d.id, d.toSlot, d.toCategory)
end)

AddEventHandler('epsilon:inventory:nui:inventory:dropItem', function(d)
    local c = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('epsilon:inventory:dropItem', d.id, d.quantity or 1, c.x, c.y, c.z)
end)

AddEventHandler('epsilon:inventory:nui:inventory:pickupItem', function(d)
    TriggerServerEvent('epsilon:inventory:pickupItem', d.id)
end)

AddEventHandler('epsilon:inventory:nui:inventory:giveItem', function(d)
    TriggerServerEvent('epsilon:inventory:giveItem', d.id, d.quantity or 1, d.targetSrc)
end)

AddEventHandler('epsilon:inventory:nui:inventory:setHotbar', function(d)
    TriggerServerEvent('epsilon:inventory:setHotbar', d.slot, d.itemName)
end)

AddEventHandler('epsilon:inventory:nui:inventory:getGroundItems', function()
    local c = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('epsilon:inventory:getGroundItems', c.x, c.y, c.z)
end)

-- ── Items au sol + props ─────────────────────────────────────────────────────
local groundItems  = {}
local groundProps  = {}   -- [groundId] = entityHandle

local DROP_PROP = 'prop_cs_box_clothes'   -- boîte carton

local function spawnGroundProp(item)
    local model = GetHashKey(DROP_PROP)
    if not HasModelLoaded(model) then
        RequestModel(model)
        local t = GetGameTimer() + 3000
        while not HasModelLoaded(model) and GetGameTimer() < t do Wait(0) end
    end
    if not HasModelLoaded(model) then return end
    local obj = CreateObject(model, item.x, item.y, item.z, true, true, false)
    PlaceObjectOnGroundProperly(obj)
    SetEntityAsMissionEntity(obj, true, true)
    FreezeEntityPosition(obj, true)
    groundProps[item.id] = obj
    SetModelAsNoLongerNeeded(model)
end

local function removeGroundProp(groundId)
    local obj = groundProps[groundId]
    if obj and DoesEntityExist(obj) then
        DeleteObject(obj)
    end
    groundProps[groundId] = nil
end

RegisterNetEvent('epsilon:inventory:groundItems', function(items)
    -- Spawner les nouveaux props uniquement (ne pas supprimer ceux hors rayon)
    for _, it in ipairs(items) do
        if not groundProps[it.id] then spawnGroundProp(it) end
    end
    groundItems = items
    if isOpen then
        uiSend({ action = 'epsilon:inventory:groundItems', data = items })
    end
end)

RegisterNetEvent('epsilon:inventory:itemDropped', function(item)
    local c    = GetEntityCoords(PlayerPedId())
    local dist = #(vector3(c.x,c.y,c.z) - vector3(item.x,item.y,item.z))
    if dist < 15 then
        if not groundProps[item.id] then spawnGroundProp(item) end
        local c2 = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('epsilon:inventory:getGroundItems', c2.x, c2.y, c2.z)
    end
end)

RegisterNetEvent('epsilon:inventory:groundRemoved', function(groundId)
    removeGroundProp(groundId)
    for i, gi in ipairs(groundItems) do
        if gi.id == groundId then table.remove(groundItems, i); break end
    end
    if isOpen then
        uiSend({ action = 'epsilon:inventory:groundItems', data = groundItems })
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        if charId then
            local c = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('epsilon:inventory:getGroundItems', c.x, c.y, c.z)
        end
    end
end)

-- ── Relay serveur → NUI (admin) ──────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:itemsList', function(items)
    uiSend({ action = 'epsilon:inventory:admin:itemsList', data = items })
end)

-- ── Item utilisé : effets ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:itemUsed', function(item)
    TriggerEvent('epsilon:ui:notifyLocal', {
        type  = 'success',
        title = item.label,
        msg   = 'Utilisé',
        icon  = 'bi-check-circle-fill',
    })
end)

-- ── Gestion armes (approche ox_inventory) ────────────────────────────────────

local isReloading      = false
local isEquipping      = false
local wasShooting      = false
local lastSentClipAmmo = -1
local activeCategory   = nil   -- 'throwable' | 'melee' | 'pistol' | etc.
local sendAmmoUI       -- forward declaration (définie plus bas)

local function unequipCurrent()
    if not activeHash then return end
    if activeWeaponItemId and activeCategory ~= 'throwable' then
        -- Mettre à jour currentInv localement pour que le re-équip immédiat utilise la bonne valeur
        if currentInv then
            for _, wi in ipairs(currentInv.weapons or {}) do
                if wi.id == activeWeaponItemId then
                    wi.data = wi.data or {}
                    wi.data.loadedAmmo = clipAmmo
                    break
                end
            end
        end
        TriggerServerEvent('epsilon:inventory:saveWeaponAmmo', activeWeaponItemId, clipAmmo)
    end
    RemoveAllPedWeapons(PlayerPedId(), true)
    activeHash         = nil
    activeWeaponItemId = nil
    activeMaxAmmo      = 0
    activeCategory     = nil
    clipAmmo           = 0
    isReloading        = false
    sendAmmoUI()
end

local function getHotbarWeapon(slot)
    if not currentInv then return nil end
    local hotbar = currentInv.hotbar or {}
    local entry
    for _, v in pairs(hotbar) do
        if type(v) == 'table' and v.slot == slot then entry = v; break end
    end
    if not entry then return nil end
    for _, wi in ipairs(currentInv.weapons or {}) do
        if wi.name == entry.name then return wi end
    end
    return nil
end

local function equipSlot(slot)
    if not currentInv or isEquipping then return end
    if activeSlot == slot then
        unequipCurrent()
        activeSlot = nil
        uiSend({ action = 'epsilon:inventory:activeSlot', data = nil })
        return
    end
    unequipCurrent()
    local wi = getHotbarWeapon(slot)
    if not wi then return end
    local idata    = wi.idata or {}
    local instdata = wi.data  or {}
    if idata.type ~= 'weapon' then return end

    local ped      = PlayerPedId()
    local hash     = GetHashKey(wi.name)
    local cat      = idata.category or ''
    local maxAmmo  = idata.maxAmmo or 0
    local loaded

    if cat == 'throwable' then
        loaded = wi.quantity or 1
    elseif cat == 'melee' then
        loaded = 0
    else
        loaded = math.min(instdata.loadedAmmo or 0, maxAmmo)
    end

    RemoveAllPedWeapons(ped, true)
    GiveWeaponToPed(ped, hash, loaded, false, true)
    SetCurrentPedWeapon(ped, hash, true)
    SetPedCurrentWeaponVisible(ped, true, false, false, false)
    SetWeaponsNoAutoswap(true)
    isEquipping = true
    local _hash = hash
    CreateThread(function()
        Wait(0)
        if activeHash == _hash and cat ~= 'throwable' and cat ~= 'melee' then
            SetWeaponsNoAutoreload(true)
        end
        isEquipping = false
    end)

    activeHash         = hash
    activeWeaponItemId = wi.id
    activeMaxAmmo      = maxAmmo
    activeCategory     = cat
    activeSlot         = slot
    clipAmmo           = loaded
    lastSentClipAmmo   = -1
    uiSend({ action = 'epsilon:inventory:activeSlot', data = slot })
end

-- ── Thread : contrôles armes ──────────────────────────────────────────────────
sendAmmoUI = function()
    if activeHash then
        uiSend({ action = 'epsilon:inventory:ammo', data = {
            clip      = clipAmmo,
            max       = activeMaxAmmo,
            throwable = activeCategory == 'throwable',
        }})
    else
        uiSend({ action = 'epsilon:inventory:ammo', data = nil })
    end
    lastSentClipAmmo = clipAmmo
end

CreateThread(function()
    while true do
        Wait(0)
        DisableControlAction(0, 37,  true)   -- weapon wheel (TAB)
        DisableControlAction(0, 14,  true)   -- next weapon
        DisableControlAction(0, 15,  true)   -- prev weapon
        DisableControlAction(0, 45,  true)   -- melee / R
        DisableControlAction(0, 140, true)   -- melee light
        DisableControlAction(0, 99,  true)   -- veh next weapon
        DisableControlAction(0, 100, true)   -- veh prev weapon
        DisableControlAction(0, 150, true)   -- veh weapon wheel
        if activeHash then
            DisplayAmmoThisFrame(false)
            HideHudComponentThisFrame(2)    -- ammo counter
            HideHudComponentThisFrame(20)   -- weapon icon / ammo area
            local ped = PlayerPedId()
            if activeCategory == 'throwable' then
                -- GTA gère l'ammo des throwables directement; on suit via GetAmmoInPedWeapon
                local gtaAmmo = GetAmmoInPedWeapon(ped, activeHash)
                if gtaAmmo ~= clipAmmo then
                    local thrown = clipAmmo - gtaAmmo
                    if thrown > 0 and activeWeaponItemId then
                        TriggerServerEvent('epsilon:inventory:consumeThrowable', activeWeaponItemId, thrown)
                    end
                    clipAmmo = gtaAmmo
                    if clipAmmo <= 0 then
                        -- Plus rien à lancer : déséquiper
                        local _slot = activeSlot
                        unequipCurrent()
                        activeSlot = nil
                        uiSend({ action = 'epsilon:inventory:activeSlot', data = nil })
                    end
                end
            elseif activeCategory ~= 'melee' and not isReloading then
                if IsPedShooting(ped) then
                    if not wasShooting then
                        clipAmmo = math.max(0, clipAmmo - 1)
                    end
                    wasShooting = true
                else
                    wasShooting = false
                end
            else
                wasShooting = false
            end
            if clipAmmo ~= lastSentClipAmmo then
                sendAmmoUI()
            end
        else
            wasShooting = false
        end
    end
end)

-- RegisterKeyMapping bypasse DisableControlAction → pas de conflit avec le coup de crosse
RegisterCommand('epsilon_reload', function()
    if not activeHash or not activeWeaponItemId or isReloading then return end
    if clipAmmo >= activeMaxAmmo then return end
    isReloading = true
    TriggerServerEvent('epsilon:inventory:reloadWeapon', activeWeaponItemId, clipAmmo)
end, false)
RegisterKeyMapping('epsilon_reload', 'Recharger arme', 'keyboard', 'r')

RegisterNetEvent('epsilon:inventory:reloadResult', function(granted)
    isReloading = false
    if granted > 0 and activeHash then
        local ped   = PlayerPedId()
        clipAmmo    = math.min(clipAmmo + granted, activeMaxAmmo)
        lastSentClipAmmo = -1
        sendAmmoUI()
        SetPedAmmo(ped, activeHash, granted)
        TaskReloadWeapon(ped, true)
    else
        TriggerEvent('epsilon:ui:notifyLocal', {
            type  = 'warning',
            title = 'Arme',
            msg   = 'Plus de munitions !',
            icon  = 'bi-exclamation-triangle-fill',
        })
    end
end)

-- Touches hotbar 1-5
for i = 1, 5 do
    local slot = i
    RegisterCommand('epsilon_hotbar_' .. i, function()
        uiSend({ action = 'epsilon:inventory:hotbarFlash' })
        equipSlot(slot)
    end, false)
    RegisterKeyMapping('epsilon_hotbar_' .. i, 'Hotbar slot ' .. i, 'keyboard', tostring(i))
end
