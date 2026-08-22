-- epsilon-ui — point d'entrée NUI centralisé
-- Relaie les events FiveM vers la page React

local nuiOpen = false

-- ── Ouvre un panel ────────────────────────────────────────────────────────────
AddEventHandler('epsilon:ui:open', function(panelName, data)
    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:ui:open', data = { panel = panelName, data = data } })
end)

-- ── Ferme l'UI ────────────────────────────────────────────────────────────────
AddEventHandler('epsilon:ui:close', function()
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'epsilon:ui:close', data = {} })
end)

-- ── Update données sans changer de panel ─────────────────────────────────────
AddEventHandler('epsilon:ui:update', function(panelName, data)
    SendNUIMessage({ action = 'epsilon:ui:update', data = { panel = panelName, data = data } })
end)

-- ── Désactive toutes les actions clavier pendant l'UI ────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        if nuiOpen then DisableAllControlActions(0) end
    end
end)

-- ── Callbacks NUI → relayés vers la resource métier ──────────────────────────
RegisterNUICallback('selectPreview', function(data, cb)
    TriggerEvent('epsilon:characters:nui:selectPreview', data)
    cb({ ok = true })
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerEvent('epsilon:characters:nui:selectCharacter', data)
    cb({ ok = true })
end)

RegisterNUICallback('createCharacter', function(data, cb)
    TriggerEvent('epsilon:characters:nui:createCharacter', data)
    cb({ ok = true })
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    TriggerEvent('epsilon:characters:nui:updateAppearance', data)
    cb({ ok = true })
end)

RegisterNUICallback('updateOutfit', function(data, cb)
    TriggerEvent('epsilon:characters:nui:updateOutfit', data)
    cb({ ok = true })
end)

RegisterNUICallback('clearPreview', function(data, cb)
    TriggerEvent('epsilon:characters:nui:clearPreview')
    cb({ ok = true })
end)

RegisterNUICallback('setCamPreset', function(data, cb)
    TriggerEvent('epsilon:characters:nui:setCamPreset', data)
    cb({ ok = true })
end)

RegisterNUICallback('rotatePreview', function(data, cb)
    TriggerEvent('epsilon:characters:nui:rotatePreview', data)
    cb({ ok = true })
end)

-- ── Admin: relay NUI → epsilon-admin via TriggerEvent ────────────────────────
local function adminRelay(name)
    RegisterNUICallback(name, function(data, cb)
        TriggerEvent('epsilon:admin:nui:' .. name, data)
        cb({ ok = true })
    end)
end

adminRelay('admin:close')
adminRelay('admin:getPlayers')
adminRelay('admin:teleportTo')
adminRelay('admin:bringPlayer')
adminRelay('admin:bringBack')
adminRelay('admin:healPlayer')
adminRelay('admin:revivePlayer')
adminRelay('admin:killPlayer')
adminRelay('admin:freezePlayer')
adminRelay('admin:toggleFire')
adminRelay('admin:toggleCage')
adminRelay('admin:spectate')
adminRelay('admin:warnPlayer')
adminRelay('admin:kick')
adminRelay('admin:ban')
adminRelay('admin:sendMessage')
adminRelay('admin:fixVehicle')
adminRelay('admin:deleteVehicle')
adminRelay('admin:refuelVehicle')
adminRelay('admin:burstTyres')
adminRelay('admin:breakWindows')
adminRelay('admin:setWeather')
adminRelay('admin:setTime')
adminRelay('admin:announce')
adminRelay('admin:teleportCoords')
adminRelay('admin:teleportWaypoint')
adminRelay('admin:toggleGod')
adminRelay('admin:toggleNoclip')
adminRelay('admin:toggleGhost')
adminRelay('admin:toggleSuperSprint')
adminRelay('admin:toggleSuperJump')
adminRelay('admin:toggleSuperSwim')
adminRelay('admin:toggleStamina')
adminRelay('admin:toggleShowNames')
adminRelay('admin:toggleShowBlips')
adminRelay('admin:selfHealHealth')
adminRelay('admin:selfHealArmour')
adminRelay('admin:selfDamage')
adminRelay('admin:suicide')
adminRelay('admin:selfRevive')
adminRelay('admin:toggleFreezeWeather')
adminRelay('admin:getServerState')
adminRelay('admin:healArmour')
adminRelay('admin:damagePlayer')
adminRelay('admin:cleanVehicle')
adminRelay('admin:engineDamage')
adminRelay('admin:freezeVehicle')
adminRelay('admin:queryPlayerVehicleFreezeState')
adminRelay('admin:spawnVehicleFor')
adminRelay('admin:getGrades')
adminRelay('admin:selfFixVehicle')
adminRelay('admin:selfCleanVehicle')
adminRelay('admin:selfRefuel')
adminRelay('admin:selfChangePlate')
adminRelay('admin:selfEngineDamage')
adminRelay('admin:selfBreakWindows')
adminRelay('admin:selfBurstTyres')
adminRelay('admin:selfToggleFreezeVehicle')
adminRelay('admin:selfSpawnVehicle')
adminRelay('admin:selfDeleteVehicle')
adminRelay('admin:massDeleteVehicles')
adminRelay('admin:massDeletePeds')
adminRelay('admin:selfFillHunger')
adminRelay('admin:selfFillThirst')
adminRelay('admin:selfDrainHunger')
adminRelay('admin:selfDrainThirst')
adminRelay('admin:togglePauseStatus')
adminRelay('admin:fillPlayerHunger')
adminRelay('admin:fillPlayerThirst')
adminRelay('admin:drainPlayerHunger')
adminRelay('admin:drainPlayerThirst')
adminRelay('admin:giveSelfItem')

-- admin:getVehicleInfo retourne des données via cb → relay spécial
RegisterNUICallback('admin:getVehicleInfo', function(data, cb)
    TriggerEvent('epsilon:admin:nui:admin:getVehicleInfo', data, cb)
end)

RegisterNUICallback('admin:devGetCoords', function(data, cb)
    TriggerEvent('epsilon:admin:nui:admin:devGetCoords', data, cb)
end)

adminRelay('admin:saveGrade')
adminRelay('admin:deleteGrade')
adminRelay('admin:setPlayerGrade')
adminRelay('admin:getReports')
adminRelay('admin:updateReport')
adminRelay('admin:deleteReport')
adminRelay('admin:joinReport')

-- ── Inventory: relay NUI → epsilon-inventory (via client) ────────────────────
local function invRelay(name)
    RegisterNUICallback('inventory:' .. name, function(data, cb)
        TriggerEvent('epsilon:inventory:nui:inventory:' .. name, data)
        cb({ ok = true })
    end)
end

invRelay('close')
invRelay('useItem')
invRelay('moveItem')
invRelay('dropItem')
invRelay('pickupItem')
invRelay('giveItem')
invRelay('setHotbar')
invRelay('getGroundItems')

-- Admin inventory: relay direct → server
local function invAdminRelay(name)
    RegisterNUICallback('inventory:admin:' .. name, function(data, cb)
        TriggerServerEvent('epsilon:inventory:admin:' .. name,
            data.targetSrc, data.itemName or data.name, data.quantity,
            data.item, data.label, data.weight, data.image)
        cb({ ok = true })
    end)
end

RegisterNUICallback('inventory:admin:getItems', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:getItems')
    cb({ ok = true })
end)

RegisterNUICallback('inventory:admin:saveItem', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:saveItem', data.item)
    cb({ ok = true })
end)

RegisterNUICallback('inventory:admin:deleteItem', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:deleteItem', data.name)
    cb({ ok = true })
end)

RegisterNUICallback('inventory:admin:duplicateItem', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:duplicateItem', data.name)
    cb({ ok = true })
end)

RegisterNUICallback('inventory:admin:giveItem', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:giveItem', data.targetSrc, data.itemName, data.quantity)
    cb({ ok = true })
end)

RegisterNUICallback('admin:getLogs', function(data, cb)
    TriggerServerEvent('epsilon:admin:getLogs', data)
    cb({ ok = true })
end)

RegisterNetEvent('epsilon:admin:logsResult', function(result)
    SendNUIMessage({ action = 'epsilon:admin:logsResult', data = result })
end)

RegisterNUICallback('inventory:admin:getPlayerInventory', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:getPlayerInventory', data.targetSrc)
    cb({ ok = true })
end)

RegisterNUICallback('inventory:admin:removePlayerItem', function(data, cb)
    TriggerServerEvent('epsilon:inventory:admin:removePlayerItem', data.targetSrc, data.itemId, data.quantity)
    cb({ ok = true })
end)

-- ── Bank: NUI callbacks + relais serveur → NUI ───────────────────────────────

-- Relay dataResult → NUI (mise à jour solde en temps réel)
RegisterNetEvent('epsilon:bank:dataResult', function(data)
    SendNUIMessage({ action = 'epsilon:bank:dataResult', data = data })
end)

-- Relay notif banque inline → NUI
RegisterNetEvent('epsilon:bank:notify', function(data)
    SendNUIMessage({ action = 'epsilon:bank:notify', data = data })
end)

-- Relay ATM nearby (depuis epsilon-bank/client via TriggerEvent local)
AddEventHandler('epsilon:bank:atmNearbyChanged', function(nearby)
    SendNUIMessage({ action = 'epsilon:bank:atmNearby', data = nearby })
end)

-- Relay PIN prompt → NUI (+ rétablit le focus si inventaire fermé)
RegisterNetEvent('epsilon:bank:pinPrompt', function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:bank:pinPrompt', data = data })
end)

-- Relay PIN result (erreur) → NUI
RegisterNetEvent('epsilon:bank:pinResult', function(data)
    SendNUIMessage({ action = 'epsilon:bank:pinResult', data = data })
end)

RegisterNUICallback('bank:close', function(_, cb)
    TriggerEvent('epsilon:bank:close')
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('bank:deposit', function(data, cb)
    TriggerServerEvent('epsilon:bank:deposit', tonumber(data) or tonumber(data.amount) or 0)
    cb({ ok = true })
end)

RegisterNUICallback('bank:withdraw', function(data, cb)
    TriggerServerEvent('epsilon:bank:withdraw', tonumber(data.amount) or tonumber(data) or 0, data.mode or 'bank')
    cb({ ok = true })
end)

RegisterNUICallback('bank:transfer', function(data, cb)
    TriggerServerEvent('epsilon:bank:transfer', data)
    cb({ ok = true })
end)

RegisterNUICallback('bank:useCard', function(data, cb)
    TriggerServerEvent('epsilon:bank:useCard', data.itemId)
    cb({ ok = true })
end)

RegisterNUICallback('bank:setPin', function(data, cb)
    TriggerServerEvent('epsilon:bank:setPin', data.pin, data.mode or 'bank')
    cb({ ok = true })
end)

RegisterNUICallback('bank:verifyPin', function(data, cb)
    TriggerServerEvent('epsilon:bank:verifyPin', data.itemId, data.pin)
    cb({ ok = true })
end)

RegisterNUICallback('bank:buyCard', function(data, cb)
    TriggerServerEvent('epsilon:bank:buyCard', data.tierId)
    cb({ ok = true })
end)

RegisterNUICallback('bank:renewCard', function(data, cb)
    TriggerServerEvent('epsilon:bank:renewCard')
    cb({ ok = true })
end)

RegisterNUICallback('bank:upgradeCard', function(data, cb)
    TriggerServerEvent('epsilon:bank:upgradeCard', data.tierId)
    cb({ ok = true })
end)

RegisterNUICallback('bank:savings:deposit', function(data, cb)
    TriggerServerEvent('epsilon:bank:savings:deposit', data)
    cb({ ok = true })
end)

RegisterNUICallback('bank:savings:withdraw', function(data, cb)
    TriggerServerEvent('epsilon:bank:savings:withdraw')
    cb({ ok = true })
end)

-- ── Economy: NUI callbacks + relais serveur → NUI ────────────────────────────

RegisterNUICallback('economy:admin:getData', function(data, cb)
    TriggerServerEvent('epsilon:economy:admin:getData', data)
    cb({ ok = true })
end)

RegisterNUICallback('economy:admin:adjustMarket', function(data, cb)
    TriggerServerEvent('epsilon:economy:admin:adjustMarket', data)
    cb({ ok = true })
end)

RegisterNetEvent('epsilon:economy:admin:dataResult', function(data)
    SendNUIMessage({ action = 'epsilon:economy:admin:dataResult', data = data })
end)

RegisterNetEvent('epsilon:economy:marketUpdate', function(data)
    SendNUIMessage({ action = 'epsilon:economy:marketUpdate', data = data })
end)

-- ── Inventory: relay epsilon-inventory → NUI ──────────────────────────────────
AddEventHandler('epsilon:inventory:ui:relay', function(msg)
    if msg.action then
        SendNUIMessage(msg)
    end
end)

-- ── PauseMenu: relay NUI → epsilon-pausemenu ─────────────────────────────────
RegisterNUICallback('pausemenu:openUrl', function(data, cb)
    TriggerEvent('epsilon:pausemenu:nui:openUrl', data)
    cb({ ok = true })
end)

RegisterNUICallback('pausemenu:copyToClipboard', function(data, cb)
    TriggerEvent('epsilon:pausemenu:nui:copyToClipboard', data)
    cb({ ok = true })
end)

RegisterNUICallback('pausemenu:close', function(data, cb)
    TriggerEvent('epsilon:pausemenu:nui:close', data)
    cb({ ok = true })
end)

RegisterNUICallback('pausemenu:tile', function(data, cb)
    TriggerEvent('epsilon:pausemenu:nui:tile', data)
    cb({ ok = true })
end)

RegisterNUICallback('pausemenu:sendReport', function(data, cb)
    TriggerEvent('epsilon:pausemenu:nui:sendReport', data)
    cb({ ok = true })
end)

-- ── Interim HUD → NUI (relay depuis epsilon-interim/client via TriggerEvent) ──
AddEventHandler('epsilon:interim:hud', function(data)
    SendNUIMessage({ action = 'epsilon:interim:hud', data = data })
end)

-- ── Interim Select : ouvre le panel de sélection mission ─────────────────────
AddEventHandler('epsilon:interim:openSelect', function(data)
    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:interim:openSelect', data = data })
end)

RegisterNUICallback('interim:start', function(data, cb)
    nuiOpen = false
    SetNuiFocus(false, false)
    TriggerEvent('epsilon:interim:nui:start', data)
    cb({ ok = true })
end)

RegisterNUICallback('interim:close', function(data, cb)
    nuiOpen = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- ── Notifications → NUI ──────────────────────────────────────────────────────
RegisterNetEvent('epsilon:ui:notify', function(data)
    SendNUIMessage({ action = 'epsilon:notify', data = data })
end)

-- Fallback local (depuis epsilon-admin/client via TriggerEvent)
AddEventHandler('epsilon:ui:notifyLocal', function(data)
    SendNUIMessage({ action = 'epsilon:notify', data = data })
end)

RegisterNetEvent('epsilon:ui:notifyAdvanced', function(data)
    SendNUIMessage({ action = 'epsilon:notifyAdvanced', data = data })
end)

RegisterNetEvent('epsilon:ui:notifyStaff', function(data)
    SendNUIMessage({ action = 'epsilon:notifyStaff', data = data })
end)

RegisterNetEvent('epsilon:ui:notifyAnnouncement', function(data)
    SendNUIMessage({ action = 'epsilon:notifyAnnouncement', data = data })
end)
AddEventHandler('epsilon:ui:notifyAnnouncementLocal', function(data)
    SendNUIMessage({ action = 'epsilon:notifyAnnouncement', data = data })
end)

RegisterNetEvent('epsilon:ui:notifyWeazel', function(data)
    SendNUIMessage({ action = 'epsilon:notifyWeazel', data = data })
end)
AddEventHandler('epsilon:ui:notifyWeazelLocal', function(data)
    SendNUIMessage({ action = 'epsilon:notifyWeazel', data = data })
end)

-- ── Progress bar ──────────────────────────────────────────────────────────────
local _pbCallback = nil
local _pbOpen = false

function ShowProgressBar(data, cb)
    if _pbOpen then return end
    _pbOpen = true
    _pbCallback = cb
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'epsilon:progressBar', data = data })
end
exports('ShowProgressBar', ShowProgressBar)

RegisterNUICallback('progressBarDone', function(data, cb)
    _pbOpen = false
    if _pbCallback then _pbCallback(data.success); _pbCallback = nil end
    cb('ok')
end)

AddEventHandler('epsilon:ui:showProgressBar', function(data, cb) ShowProgressBar(data, cb) end)
AddEventHandler('epsilon:ui:hideProgressBar', function()
    _pbOpen = false; _pbCallback = nil
    SendNUIMessage({ action = 'epsilon:progressBarHide', data = {} })
end)

-- ── Keyboard input ────────────────────────────────────────────────────────────
local _kbCallback = nil
local _kbOpen = false

function ShowKeyboardInput(data, cb)
    if _kbOpen then return end
    _kbOpen = true
    _kbCallback = cb
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:keyboardInput', data = data })
end
exports('ShowKeyboardInput', ShowKeyboardInput)

RegisterNUICallback('keyboardInputDone', function(data, cb)
    SetNuiFocus(false, false)
    _kbOpen = false
    if _kbCallback then _kbCallback(data.value); _kbCallback = nil end
    cb('ok')
end)

AddEventHandler('epsilon:ui:showKeyboardInput', function(data, cb) ShowKeyboardInput(data, cb) end)

-- ── Choice input ──────────────────────────────────────────────────────────────
local _choiceCallback = nil
local _choiceOpen = false

function ShowChoiceInput(data, cb)
    if _choiceOpen then return end
    _choiceOpen = true
    _choiceCallback = cb
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:choiceInput', data = data })
end
exports('ShowChoiceInput', ShowChoiceInput)

RegisterNUICallback('choiceInputDone', function(data, cb)
    SetNuiFocus(false, false)
    _choiceOpen = false
    if _choiceCallback then _choiceCallback(data.value); _choiceCallback = nil end
    cb('ok')
end)

AddEventHandler('epsilon:ui:showChoiceInput', function(data, cb) ShowChoiceInput(data, cb) end)

-- ── Choice paiement ───────────────────────────────────────────────────────────
local _paiCallback = nil
local _paiOpen = false

function ShowChoicePaiement(data, cb)
    if _paiOpen then return end
    _paiOpen = true
    _paiCallback = cb
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'epsilon:choicePaiement', data = data })
end
exports('ShowChoicePaiement', ShowChoicePaiement)

RegisterNUICallback('choicePaiementDone', function(data, cb)
    SetNuiFocus(false, false)
    _paiOpen = false
    if _paiCallback then _paiCallback(data.value); _paiCallback = nil end
    cb('ok')
end)

AddEventHandler('epsilon:ui:showChoicePaiement', function(data, cb) ShowChoicePaiement(data, cb) end)

-- ── Help notification ─────────────────────────────────────────────────────────
function ShowHelpNotification(message, duration)
    SendNUIMessage({ action = 'epsilon:helpNotif', data = { text = message, duration = duration } })
end
function HideHelpNotification()
    SendNUIMessage({ action = 'epsilon:helpNotifHide', data = {} })
end
exports('ShowHelpNotification', ShowHelpNotification)
exports('HideHelpNotification', HideHelpNotification)
AddEventHandler('epsilon:ui:showHelpNotif', function(msg, dur) ShowHelpNotification(msg, dur) end)
AddEventHandler('epsilon:ui:hideHelpNotif', HideHelpNotification)

-- ── Instructional buttons ─────────────────────────────────────────────────────
function ShowInstructionalButtons(buttons)
    SendNUIMessage({ action = 'epsilon:instructionalButtons', data = { show = true, buttons = buttons } })
end
function HideInstructionalButtons()
    SendNUIMessage({ action = 'epsilon:instructionalButtons', data = { show = false } })
end
exports('ShowInstructionalButtons', ShowInstructionalButtons)
exports('HideInstructionalButtons', HideInstructionalButtons)
AddEventHandler('epsilon:ui:showInstructionalButtons', function(buttons) ShowInstructionalButtons(buttons) end)
AddEventHandler('epsilon:ui:hideInstructionalButtons', HideInstructionalButtons)

-- ── Report status → NUI (HUD joueur) ─────────────────────────────────────────
local activeReportId = nil

RegisterNetEvent('epsilon:ui:reportStatus', function(data)
    SendNUIMessage({ action = 'epsilon:report:status', data = data })
    if data.status == 'closed' then
        SetTimeout(5500, function() activeReportId = nil end)
    else
        activeReportId = data.id
    end
end)


-- ── Admin: relay epsilon-admin → NUI (SendNUIMessage en proxy) ───────────────
AddEventHandler('epsilon:admin:ui:relay', function(msg)
    if msg.type then
        SendNUIMessage({ action = 'epsilon:admin:' .. msg.type, data = msg })
    end
end)

RegisterNetEvent('epsilon:admin:playerInventory', function(inv)
    SendNUIMessage({ action = 'epsilon:admin:playerInventory', data = inv })
end)



-- ── Emotes : open/close ───────────────────────────────────────────────────────
AddEventHandler('epsilon:emotes:open', function(data)
    nuiOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({ action = 'epsilon:emotes:open', data = data })
end)

AddEventHandler('epsilon:emotes:close', function()
    nuiOpen = false
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'epsilon:emotes:close', data = {} })
end)

AddEventHandler('epsilon:emotes:updateNumpad', function(slots)
    SendNUIMessage({ action = 'epsilon:emotes:updateNumpad', data = slots })
end)

-- NUI → epsilon-emotes relay
RegisterNUICallback('emotes:play', function(data, cb)
    TriggerEvent('epsilon:emotes:nui:play', data)
    cb({ ok = true })
end)

RegisterNUICallback('emotes:stop', function(data, cb)
    TriggerEvent('epsilon:emotes:nui:stop')
    cb({ ok = true })
end)

RegisterNUICallback('emotes:close', function(data, cb)
    TriggerEvent('epsilon:emotes:nui:close')
    cb({ ok = true })
end)

RegisterNUICallback('emotes:saveNumpad', function(data, cb)
    TriggerEvent('epsilon:emotes:nui:saveNumpad', data)
    cb({ ok = true })
end)

