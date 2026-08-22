-- ============================================================
-- epsilon-admin / client/main.lua
-- ============================================================

local isAdmin    = false
local isOpen     = false
local adminRank    = 'Admin'
local adminGrade   = nil
local adminLicense = ''

-- État serveur connu côté client (pour initialiser l'UI sans flash)
local clientFreezeTime    = false
local clientFreezeWeather = false

-- ── Self-tools state ─────────────────────────────────────────
local godMode         = false
local noclipOn        = false
local ghostOn         = false
local superSprint     = false
local superJump       = false
local superSwim       = false
local infiniteStamina = false
local showNames       = false
local showBlips       = false
local statusPaused    = false
local isOnFire        = false
local cageObject      = nil
local spectating      = false
local spectateTarget  = nil
local playerBlips     = {}
local playerTagData   = {} -- [serverId] = { gradeLabel, gradeColor, firstname, lastname, pseudo }
local tagDataTimer    = 0

-- ── Tag data ──────────────────────────────────────────────────
RegisterNetEvent('epsilon:admin:tagData', function(data)
    playerTagData = data
end)

local function refreshTagData()
    TriggerServerEvent('epsilon:admin:getTagData')
end

-- Mappe une couleur hex (#rrggbb) vers le code couleur GTA le plus proche
local function hexToGtaColor(hex)
    if not hex then return '~g~' end
    local h = hex:lower():gsub('#', '')
    local r = tonumber(h:sub(1,2), 16) or 128
    local g = tonumber(h:sub(3,4), 16) or 128
    local b = tonumber(h:sub(5,6), 16) or 128
    if r > 180 and g < 100 and b > 150 then return '~p~' end -- violet/rose → purple
    if r > 200 and g < 80  and b < 80  then return '~r~' end -- rouge
    if r < 80  and g < 80  and b > 180 then return '~b~' end -- bleu
    if r < 80  and g > 160 and b < 100 then return '~g~' end -- vert
    if r > 200 and g > 150 and b < 60  then return '~y~' end -- jaune
    if r > 200 and g > 90  and b < 60  then return '~o~' end -- orange
    return '~s~'                                               -- gris
end

-- ── DrawText3d helper (usage interne) ────────────────────────
local function DrawText3d(x, y, z, text)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(x, y, z) - camCoords)
    if dist > 35.0 then return end
    local scale = math.min((1 / dist) * 1.2 * ((1 / GetGameplayCamFov()) * 100), 0.32)
    SetTextScale(0.0, scale)
    SetTextFont(4); SetTextProportional(1)
    SetTextColour(255, 255, 255, 210)
    SetTextDropShadow(); SetTextOutline()
    SetTextEntry('STRING'); AddTextComponentString(text)
    SetDrawOrigin(x, y, z + 1.05, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- ── Nametag fixe avec couleur de grade réelle ─────────────────
local function hexToRGB(hex)
    if not hex then return 255, 255, 255 end
    local h = hex:lower():gsub('#', '')
    return tonumber(h:sub(1,2), 16) or 255,
           tonumber(h:sub(3,4), 16) or 255,
           tonumber(h:sub(5,6), 16) or 255
end

local function letterSpaced(str)
    local out = ''
    for i = 1, #str do
        out = out .. str:sub(i, i)
        if i < #str then out = out .. ' ' end
    end
    return out
end

-- stackIdx: 0 = premier joueur, 1+ = passagers supplémentaires (décalage vertical)
local function DrawNameTag(x, y, z, tag, stackIdx, talking)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    local dist = #(vector3(x, y, z) - GetGameplayCamCoords())
    if dist > 40.0 then return end
    local alpha = math.max(60, math.floor(220 * (1.0 - dist / 40.0)))

    local yOff   = (stackIdx or 0) * 0.072
    local gr, gg, gb = 0, 0, 0
    local gl     = (tag.gradeLabel or 'Joueur'):upper()
    if not tag.gradeLabel then gr, gg, gb = 80, 210, 80 end

    local nameColor = talking and '~g~' or '~w~'
    local main = '~y~UID ' .. (tag.dbId or '?') .. ' ~w~| ' .. nameColor .. tag.firstname .. ' ' .. tag.lastname .. ' ~s~[' .. tag.pseudo .. ']'

    -- Ligne grade (noir pur, aucun effet)
    SetTextFont(4); SetTextProportional(1); SetTextScale(0.30, 0.30)
    SetTextColour(gr, gg, gb, alpha)
    SetTextCentre(true)
    SetTextEntry('STRING'); AddTextComponentString(gl)
    DrawText(sx, sy - 0.026 - yOff)

    -- Ligne principale (blanc + jaune UID + gris pseudo)
    SetTextFont(4); SetTextProportional(1); SetTextScale(0.36, 0.36)
    SetTextColour(255, 255, 255, alpha)
    SetTextDropShadow(); SetTextOutline(); SetTextCentre(true)
    SetTextEntry('STRING'); AddTextComponentString(main)
    DrawText(sx, sy - yOff)
end

-- Helper: relayer un message vers epsilon-ui → React
local function uiRelay(msg)
    TriggerEvent('epsilon:admin:ui:relay', msg)
end

local NC = {
    green  = '#22c55e', red    = '#ef4444',
    amber  = '#f59e0b', purple = 'rgba(147,51,234,0.85)',
    blue   = '#3b82f6',
}

local function notifyLocal(text, color, icon, duration)
    TriggerEvent('epsilon:ui:notifyLocal', {
        text     = text,
        color    = color    or NC.purple,
        icon     = icon,
        duration = duration or 3,
    })
end

-- ── Notifications (fallback → epsilon-ui via event local) ─────
RegisterNetEvent('epsilon:admin:notify', function(msg)
    TriggerEvent('epsilon:ui:notifyLocal', {
        text     = msg:gsub('~%w+~', ''),
        color    = 'rgba(147,51,234,0.85)',
        duration = 5,
    })
end)

-- ── Weather sync ──────────────────────────────────────────────
local syncedWeather = 'EXTRASUNNY'
local lastWeather   = 'EXTRASUNNY'

RegisterNetEvent('epsilon:admin:syncWeather', function(weather)
    syncedWeather = weather
end)

-- Approche vSync: 5 natives combinées toutes les 100ms
-- ClearOverrideWeather + ClearWeatherTypePersist empêchent les interférences internes GTA
CreateThread(function()
    while true do
        Wait(100)
        if syncedWeather ~= lastWeather then
            SetWeatherTypeOverTime(syncedWeather, 15.0)
            lastWeather = syncedWeather
        end
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
    end
end)

-- ── Time sync ─────────────────────────────────────────────────
local syncedHour   = 12
local syncedMinute = 0
local lastSyncMs   = GetGameTimer()

RegisterNetEvent('epsilon:admin:syncTime', function(h, m)
    syncedHour   = h
    syncedMinute = m
    lastSyncMs   = GetGameTimer()
    if isOpen then
        uiRelay({ type = 'liveTime', hour = h, minute = m })
    end
end)

-- Interpole les secondes (1s réelle = 1min jeu = 60s jeu)
-- GTA lit les secondes pour positionner le soleil → smooth si on les anime
CreateThread(function()
    while true do
        local elapsedSec = (GetGameTimer() - lastSyncMs) / 1000.0
        local interpSec  = math.min(math.floor(elapsedSec * 60), 59)
        NetworkOverrideClockTime(syncedHour, syncedMinute, interpSec)
        Wait(0)
    end
end)

-- ── Admin check ───────────────────────────────────────────────
AddEventHandler('epsilon:spawn:complete', function()
    TriggerServerEvent('epsilon:admin:checkAdmin')
end)

-- Re-check quand epsilon-admin redémarre (ensure, crash, etc.)
AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    isOpen     = false
    isAdmin    = false
    adminGrade = nil
    Wait(500) -- laisser le serveur finir son init
    TriggerServerEvent('epsilon:admin:checkAdmin')
end)

RegisterNetEvent('epsilon:admin:granted', function(rank, license)
    isAdmin      = true
    adminRank    = rank
    adminLicense = license or ''
    Epsilon.Debug.Success('[Admin] Accès accordé: %s', rank)
end)

RegisterNetEvent('epsilon:admin:gradeInfo', function(grade)
    adminGrade = grade
    -- Si le panel est déjà ouvert, relayer avec les champs à plat (pas imbriqués)
    if isOpen then
        local msg = { type = 'gradeInfo' }
        for k, v in pairs(grade) do msg[k] = v end
        uiRelay(msg)
    end
end)

RegisterNetEvent('epsilon:admin:denied', function()
    isAdmin = false
end)

-- ── Panel toggle ─────────────────────────────────────────
RegisterKeyMapping('+epsilon_admin', 'Ouvrir le panel admin', 'keyboard', 'INSERT')

CreateThread(function()
    while true do
        Wait(0)
        if isOpen then
            DisableControlAction(0, 200, true) -- INPUT_FRONTEND_PAUSE (Echap)
            DisableControlAction(0, 199, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE
        end
    end
end)

RegisterCommand('+epsilon_admin', function()
    if not isAdmin then return end
    isOpen = not isOpen
    if isOpen then
        TriggerEvent('epsilon:ui:open', 'admin', {
            rank          = adminRank,
            myLicense     = adminLicense,
            myName        = GetPlayerName(PlayerId()),
            grade         = adminGrade,
            weather       = syncedWeather,
            hour          = syncedHour,
            minute        = syncedMinute,
            freezeTime    = clientFreezeTime,
            freezeWeather = clientFreezeWeather,
            tools         = {
                god       = godMode,
                noclip    = noclipOn,
                ghost     = ghostOn,
                sprint    = superSprint,
                jump      = superJump,
                swim      = superSwim,
                stamina   = infiniteStamina,
                showNames    = showNames,
                showBlips    = showBlips,
                statusPaused = statusPaused,
            },
        })
        -- Request current weather/time/freeze states from server
        TriggerServerEvent('epsilon:admin:getServerState')
    else
        TriggerEvent('epsilon:ui:close')
    end
end, false)

-- ── NUI callbacks (via epsilon:admin:nui:* events) ───────────
AddEventHandler('epsilon:admin:nui:admin:close', function()
    isOpen = false
    TriggerEvent('epsilon:ui:close')
end)

AddEventHandler('epsilon:admin:nui:admin:getPlayers', function()
    TriggerServerEvent('epsilon:admin:getPlayers')
end)

-- Player actions
AddEventHandler('epsilon:admin:nui:admin:teleportTo',   function(d) TriggerServerEvent('epsilon:admin:teleportTo',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:bringBack',    function(d) TriggerServerEvent('epsilon:admin:bringBack',    d.id) end)
AddEventHandler('epsilon:admin:nui:admin:healPlayer',   function(d) TriggerServerEvent('epsilon:admin:healPlayer',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:killPlayer',   function(d) TriggerServerEvent('epsilon:admin:killPlayer',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:revivePlayer', function(d) TriggerServerEvent('epsilon:admin:revivePlayer', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:freezePlayer', function(d) TriggerServerEvent('epsilon:admin:freezePlayer', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:toggleFire',   function(d) TriggerServerEvent('epsilon:admin:toggleFire',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:toggleCage',   function(d) TriggerServerEvent('epsilon:admin:toggleCage',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:spectate',     function(d) TriggerServerEvent('epsilon:admin:spectatePlayer', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:warnPlayer',   function(d) TriggerServerEvent('epsilon:admin:warnPlayer',   d.id, d.reason or '') end)
AddEventHandler('epsilon:admin:nui:admin:kick',         function(d) TriggerServerEvent('epsilon:admin:kick',         d.id, d.reason or '') end)
AddEventHandler('epsilon:admin:nui:admin:ban',          function(d) TriggerServerEvent('epsilon:admin:ban',          d.id, d.reason or '', d.duration or '') end)
AddEventHandler('epsilon:admin:nui:admin:sendMessage',  function(d) TriggerServerEvent('epsilon:admin:sendMessage',  d.id, d.message or '') end)

-- bringPlayer: envoie les coords de l'admin côté client pour précision
AddEventHandler('epsilon:admin:nui:admin:bringPlayer', function(d)
    local ped = PlayerPedId()
    local c   = GetEntityCoords(ped)
    TriggerServerEvent('epsilon:admin:bringPlayer', d.id, c.x, c.y, c.z)
end)

-- Health extras
AddEventHandler('epsilon:admin:nui:admin:healArmour',   function(d) TriggerServerEvent('epsilon:admin:healArmour',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:damagePlayer', function(d) TriggerServerEvent('epsilon:admin:damagePlayer', d.id) end)

-- Vehicle actions
AddEventHandler('epsilon:admin:nui:admin:fixVehicle',      function(d) TriggerServerEvent('epsilon:admin:fixVehicle',      d.id) end)
AddEventHandler('epsilon:admin:nui:admin:deleteVehicle',   function(d) TriggerServerEvent('epsilon:admin:deleteVehicle',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:refuelVehicle',   function(d) TriggerServerEvent('epsilon:admin:refuelVehicle',   d.id) end)
AddEventHandler('epsilon:admin:nui:admin:burstTyres',      function(d) TriggerServerEvent('epsilon:admin:burstTyres',      d.id) end)
AddEventHandler('epsilon:admin:nui:admin:breakWindows',    function(d) TriggerServerEvent('epsilon:admin:breakWindows',    d.id) end)
AddEventHandler('epsilon:admin:nui:admin:cleanVehicle',    function(d) TriggerServerEvent('epsilon:admin:cleanVehicle',    d.id) end)
AddEventHandler('epsilon:admin:nui:admin:engineDamage',    function(d) TriggerServerEvent('epsilon:admin:engineDamage',    d.id) end)
AddEventHandler('epsilon:admin:nui:admin:freezeVehicle',              function(d) TriggerServerEvent('epsilon:admin:freezeVehicle',              d.id) end)
AddEventHandler('epsilon:admin:nui:admin:queryPlayerVehicleFreezeState', function(d) TriggerServerEvent('epsilon:admin:queryPlayerVehicleFreezeState', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:spawnVehicleFor', function(d) TriggerServerEvent('epsilon:admin:spawnVehicleFor', d.id, d.model) end)

-- Server actions
AddEventHandler('epsilon:admin:nui:admin:setWeather',         function(d) TriggerServerEvent('epsilon:admin:setWeather', d.weather) end)
AddEventHandler('epsilon:admin:nui:admin:setTime',            function(d) TriggerServerEvent('epsilon:admin:setTime', d.hour, d.minute, d.freeze) end)
AddEventHandler('epsilon:admin:nui:admin:announce',           function(d) TriggerServerEvent('epsilon:admin:announce', d.staffName or '', d.message or '', d.duration or 10) end)
AddEventHandler('epsilon:admin:nui:admin:toggleFreezeWeather',function()  TriggerServerEvent('epsilon:admin:toggleFreezeWeather') end)
AddEventHandler('epsilon:admin:nui:admin:getServerState',     function()  TriggerServerEvent('epsilon:admin:getServerState') end)

-- Teleport (local)
AddEventHandler('epsilon:admin:nui:admin:teleportCoords', function(d)
    SetEntityCoordsNoOffset(PlayerPedId(), d.x, d.y, d.z, false, false, false)
    notifyLocal(('Téléporté → %.0f / %.0f / %.0f'):format(d.x, d.y, d.z), NC.purple, 'bi-geo-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'teleport_coords', nil, { x = d.x, y = d.y, z = d.z })
end)

AddEventHandler('epsilon:admin:nui:admin:teleportWaypoint', function()
    local wp = GetFirstBlipInfoId(8)
    if DoesBlipExist(wp) then
        local c = GetBlipCoords(wp)
        SetEntityCoordsNoOffset(PlayerPedId(), c.x, c.y, c.z + 2.0, false, false, false)
        notifyLocal('Téléporté au waypoint', NC.purple, 'bi-geo-fill')
        TriggerServerEvent('epsilon:admin:logSelf', 'teleport_waypoint', nil, { x = math.floor(c.x), y = math.floor(c.y), z = math.floor(c.z) })
    end
end)

-- Self-tools
AddEventHandler('epsilon:admin:nui:admin:toggleNoclip', function()
    TriggerServerEvent('epsilon:admin:toggleNoclip')
end)

AddEventHandler('epsilon:admin:nui:admin:toggleGod', function()
    TriggerServerEvent('epsilon:admin:toggleGod')
end)

AddEventHandler('epsilon:admin:nui:admin:toggleGhost', function()
    TriggerServerEvent('epsilon:admin:toggleGhost')
end)

AddEventHandler('epsilon:admin:nui:admin:toggleSuperSprint', function()
    superSprint = not superSprint
    if not superSprint then
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
    uiRelay({ type = 'toolState', tool = 'sprint', state = superSprint })
    notifyLocal(superSprint and 'Super sprint ON' or 'Super sprint OFF', superSprint and NC.green or NC.amber, 'bi-lightning-fill')
    TriggerServerEvent('epsilon:admin:logSelf', superSprint and 'super_sprint_on' or 'super_sprint_off', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:toggleSuperJump', function()
    superJump = not superJump
    uiRelay({ type = 'toolState', tool = 'jump', state = superJump })
    notifyLocal(superJump and 'Super jump ON' or 'Super jump OFF', superJump and NC.green or NC.amber, 'bi-chevron-double-up')
    TriggerServerEvent('epsilon:admin:logSelf', superJump and 'super_jump_on' or 'super_jump_off', nil)
end)

-- New self-tools
AddEventHandler('epsilon:admin:nui:admin:toggleSuperSwim', function()
    superSwim = not superSwim
    if not superSwim then SetSwimMultiplierForPlayer(PlayerId(), 1.0) end
    uiRelay({ type = 'toolState', tool = 'swim', state = superSwim })
    notifyLocal(superSwim and 'Super swim ON' or 'Super swim OFF', superSwim and NC.green or NC.amber, 'bi-water')
    TriggerServerEvent('epsilon:admin:logSelf', superSwim and 'super_swim_on' or 'super_swim_off', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:toggleStamina', function()
    infiniteStamina = not infiniteStamina
    uiRelay({ type = 'toolState', tool = 'stamina', state = infiniteStamina })
    notifyLocal(infiniteStamina and 'Stamina infinie ON' or 'Stamina infinie OFF', infiniteStamina and NC.green or NC.amber, 'bi-battery-full')
    TriggerServerEvent('epsilon:admin:logSelf', infiniteStamina and 'stamina_on' or 'stamina_off', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:toggleShowNames', function()
    showNames = not showNames
    if showNames then refreshTagData() end
    uiRelay({ type = 'toolState', tool = 'showNames', state = showNames })
    notifyLocal(showNames and 'Noms affichés' or 'Noms masqués', showNames and NC.blue or NC.amber, 'bi-person-badge')
    TriggerServerEvent('epsilon:admin:logSelf', showNames and 'show_names_on' or 'show_names_off', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:toggleShowBlips', function()
    showBlips = not showBlips
    if showBlips then
        refreshTagData()
    else
        for _, blip in pairs(playerBlips) do
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end
        playerBlips = {}
    end
    uiRelay({ type = 'toolState', tool = 'showBlips', state = showBlips })
    notifyLocal(showBlips and 'Blips activés' or 'Blips désactivés', showBlips and NC.blue or NC.amber, 'bi-map-fill')
    TriggerServerEvent('epsilon:admin:logSelf', showBlips and 'show_blips_on' or 'show_blips_off', nil)
end)

-- Self health/actions
AddEventHandler('epsilon:admin:nui:admin:selfHealHealth', function()
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
    notifyLocal('Santé restaurée', NC.green, 'bi-heart-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_heal_health', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfHealArmour', function()
    SetPedArmour(PlayerPedId(), 100)
    notifyLocal('Armure restaurée', NC.green, 'bi-shield-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_heal_armour', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfDamage', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, math.max(101, GetEntityHealth(ped) - 10))
    notifyLocal('Dégâts infligés', NC.red, 'bi-bandaid-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_damage', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:suicide', function()
    SetEntityHealth(PlayerPedId(), 0)
    notifyLocal('Suicide', NC.red, 'bi-x-circle-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_suicide', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfFillHunger', function()
    TriggerServerEvent('epsilon:admin:selfFillHunger')
end)

AddEventHandler('epsilon:admin:nui:admin:selfFillThirst', function()
    TriggerServerEvent('epsilon:admin:selfFillThirst')
end)

AddEventHandler('epsilon:admin:nui:admin:selfDrainHunger', function()
    TriggerServerEvent('epsilon:admin:selfDrainHunger')
end)

AddEventHandler('epsilon:admin:nui:admin:selfDrainThirst', function()
    TriggerServerEvent('epsilon:admin:selfDrainThirst')
end)

AddEventHandler('epsilon:admin:nui:admin:togglePauseStatus', function()
    TriggerServerEvent('epsilon:admin:togglePauseStatus')
end)

RegisterNetEvent('epsilon:admin:setPauseState', function(state)
    statusPaused = state
    uiRelay({ type = 'toolState', tool = 'statusPaused', state = state })
end)

AddEventHandler('epsilon:admin:nui:admin:fillPlayerHunger', function(d)
    TriggerServerEvent('epsilon:admin:fillPlayerHunger', d.id)
end)

AddEventHandler('epsilon:admin:nui:admin:fillPlayerThirst', function(d)
    TriggerServerEvent('epsilon:admin:fillPlayerThirst', d.id)
end)

AddEventHandler('epsilon:admin:nui:admin:drainPlayerHunger', function(d)
    TriggerServerEvent('epsilon:admin:drainPlayerHunger', d.id)
end)

AddEventHandler('epsilon:admin:nui:admin:drainPlayerThirst', function(d)
    TriggerServerEvent('epsilon:admin:drainPlayerThirst', d.id)
end)

AddEventHandler('epsilon:admin:nui:admin:selfRevive', function()
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    notifyLocal('Réanimé', NC.green, 'bi-activity')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_revive', nil)
end)

-- ── Actions en masse ─────────────────────────────────────────
AddEventHandler('epsilon:admin:nui:admin:massDeleteVehicles', function(d)
    local radius  = tonumber(d.radius) or 100
    local coords  = GetEntityCoords(PlayerPedId())
    local global  = radius == 0
    local count   = 0
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if global or #(coords - GetEntityCoords(veh)) <= radius then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteEntity(veh)
            count = count + 1
        end
    end
    TriggerEvent('epsilon:ui:notifyLocal', {
        icon = 'bi-car-front-fill', color = 'rgba(245,158,11,0.85)',
        text = count .. ' véhicule(s) supprimé(s)' .. (global and ' (serveur)' or (' (' .. radius .. 'm)')),
        duration = 4,
    })
    TriggerServerEvent('epsilon:admin:logSelf', 'mass_delete_vehicles', nil, { count = count, radius = radius, global = global })
end)

AddEventHandler('epsilon:admin:nui:admin:massDeletePeds', function(d)
    local radius  = tonumber(d.radius) or 100
    local myPed   = PlayerPedId()
    local coords  = GetEntityCoords(myPed)
    local global  = radius == 0
    local count   = 0
    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped == myPed or IsPedAPlayer(ped) then goto continue end
        if global or #(coords - GetEntityCoords(ped)) <= radius then
            SetEntityAsMissionEntity(ped, true, true)
            DeleteEntity(ped)
            count = count + 1
        end
        ::continue::
    end
    TriggerEvent('epsilon:ui:notifyLocal', {
        icon = 'bi-people-fill', color = 'rgba(245,158,11,0.85)',
        text = count .. ' ped(s) supprimé(s)' .. (global and ' (serveur)' or (' (' .. radius .. 'm)')),
        duration = 4,
    })
    TriggerServerEvent('epsilon:admin:logSelf', 'mass_delete_peds', nil, { count = count, radius = radius, global = global })
end)

-- ── Self vehicle actions ──────────────────────────────────────
local selfVehFrozen = false

AddEventHandler('epsilon:admin:nui:admin:getVehicleInfo', function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local info
    if veh == 0 then
        info = { inVehicle = false }
    else
        info = {
            inVehicle    = true,
            model        = GetDisplayNameFromVehicleModel(GetEntityModel(veh)) or '???',
            plate        = GetVehicleNumberPlateText(veh) or '',
            engineHealth = math.floor(GetVehicleEngineHealth(veh)),
            bodyHealth   = math.floor(GetVehicleBodyHealth(veh)),
            fuelLevel    = math.floor(GetVehicleFuelLevel(veh)),
            dirtLevel    = math.floor(GetVehicleDirtLevel(veh) * 10) / 10,
            frozen       = IsEntityPositionFrozen(veh),
        }
    end
    if cb then cb({ ok = true }) end
    uiRelay({ type = 'vehicleInfo', info = info })
end)

AddEventHandler('epsilon:admin:nui:admin:selfFixVehicle', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleEngineOn(veh, true, true, false)
    notifyLocal('Véhicule réparé', NC.green, 'bi-tools')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_fix_vehicle', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfCleanVehicle', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    SetVehicleDirtLevel(veh, 0.0)
    notifyLocal('Véhicule nettoyé', NC.green, 'bi-stars')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_clean_vehicle', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfRefuel', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    SetVehicleFuelLevel(veh, 100.0)
    notifyLocal('Véhicule ravitaillé', NC.green, 'bi-fuel-pump-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_refuel', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfChangePlate', function(d)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 or not d.plate then return end
    SetVehicleNumberPlateText(veh, d.plate)
    notifyLocal('Plaque → ' .. d.plate, NC.blue, 'bi-123')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_change_plate', d.plate)
end)

AddEventHandler('epsilon:admin:nui:admin:selfEngineDamage', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    SetVehicleEngineHealth(veh, -4000.0)
    notifyLocal('Moteur endommagé', NC.red, 'bi-exclamation-octagon-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_engine_damage', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfBreakWindows', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    for i = 0, 7 do SmashVehicleWindow(veh, i) end
    notifyLocal('Vitres brisées', NC.amber, 'bi-columns-gap')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_break_windows', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfBurstTyres', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    for i = 0, 7 do SetVehicleTyreBurst(veh, i, true, 1000.0) end
    notifyLocal('Pneus crevés', NC.red, 'bi-circle-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_burst_tyres', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfSpawnVehicle', function(d)
    if not d.model then return end
    local hash = GetHashKey(d.model)
    if not IsModelValid(hash) then return end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do Wait(50); timeout = timeout + 1 end
    if not HasModelLoaded(hash) then return end
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh    = CreateVehicle(hash, coords.x, coords.y, coords.z + 0.5, GetEntityHeading(ped), true, false)
    SetVehicleFuelLevel(veh, 100.0)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetModelAsNoLongerNeeded(hash)
    notifyLocal('Véhicule spawné: ' .. d.model, NC.green, 'bi-car-front-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_spawn_vehicle', d.model)
end)

AddEventHandler('epsilon:admin:nui:admin:selfToggleFreezeVehicle', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    selfVehFrozen = not IsEntityPositionFrozen(veh) -- lire l'état réel, pas le cache
    FreezeEntityPosition(veh, selfVehFrozen)
    notifyLocal(selfVehFrozen and 'Véhicule freeze' or 'Véhicule unfreeze', NC.amber, 'bi-snow')
    TriggerServerEvent('epsilon:admin:logSelf', selfVehFrozen and 'self_freeze_vehicle' or 'self_unfreeze_vehicle', nil)
end)

AddEventHandler('epsilon:admin:nui:admin:selfDeleteVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        -- Chercher le véhicule le plus proche (10m)
        local coords = GetEntityCoords(ped)
        local closest, closestDist = nil, 10.0
        for _, v in ipairs(GetGamePool('CVehicle')) do
            local d = #(coords - GetEntityCoords(v))
            if d < closestDist then closestDist = d; closest = v end
        end
        veh = closest
    end
    if not veh then return end
    SetEntityAsMissionEntity(veh, true, true)
    DeleteEntity(veh)
    notifyLocal('Véhicule supprimé', NC.red, 'bi-trash3-fill')
    TriggerServerEvent('epsilon:admin:logSelf', 'self_delete_vehicle', nil)
end)

-- Inventaire
AddEventHandler('epsilon:admin:nui:admin:giveSelfItem', function(d)
    TriggerServerEvent('epsilon:admin:giveSelfItem', d.itemName, d.quantity)
end)

-- Grades
AddEventHandler('epsilon:admin:nui:admin:getGrades',      function()  TriggerServerEvent('epsilon:admin:getGrades') end)
AddEventHandler('epsilon:admin:nui:admin:saveGrade',      function(d) TriggerServerEvent('epsilon:admin:saveGrade', d) end)
AddEventHandler('epsilon:admin:nui:admin:deleteGrade',    function(d) TriggerServerEvent('epsilon:admin:deleteGrade', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:setPlayerGrade', function(d) TriggerServerEvent('epsilon:admin:setPlayerGrade', d.id, d.gradeId) end)

-- Reports
AddEventHandler('epsilon:admin:nui:admin:getReports',   function(d) TriggerServerEvent('epsilon:admin:getReports',   d) end)
AddEventHandler('epsilon:admin:nui:admin:updateReport', function(d) TriggerServerEvent('epsilon:admin:updateReport', d) end)
AddEventHandler('epsilon:admin:nui:admin:deleteReport', function(d) TriggerServerEvent('epsilon:admin:deleteReport', d) end)
AddEventHandler('epsilon:admin:nui:admin:joinReport',   function(d) TriggerServerEvent('epsilon:admin:joinReport',   d) end)

-- ── Server state sync (weather / time / freeze) ──────────────
RegisterNetEvent('epsilon:admin:serverState', function(state)
    if state.weather          then syncedWeather       = state.weather       end
    if state.hour   ~= nil    then syncedHour          = state.hour          end
    if state.minute ~= nil    then syncedMinute        = state.minute        end
    if state.freezeTime    ~= nil then clientFreezeTime    = state.freezeTime    end
    if state.freezeWeather ~= nil then clientFreezeWeather = state.freezeWeather end
    uiRelay({ type         = 'serverState',
              weather       = state.weather,
              hour          = state.hour,
              minute        = state.minute,
              freezeTime    = state.freezeTime,
              freezeWeather = state.freezeWeather })
end)

-- ── Server → Client events ────────────────────────────────────
RegisterNetEvent('epsilon:admin:playersList', function(list)
    uiRelay({ type = 'playersList', players = list })
end)

RegisterNetEvent('epsilon:admin:gradesList', function(list)
    uiRelay({ type = 'gradesList', grades = list })
end)

RegisterNetEvent('epsilon:admin:reportsList', function(list)
    uiRelay({ type = 'reportsList', reports = list })
end)

RegisterNetEvent('epsilon:admin:newReport', function(report)
    uiRelay({ type = 'newReport', report = report })
end)

RegisterNetEvent('epsilon:admin:reportUpdate', function(data)
    uiRelay({ type = 'reportUpdate', id = data.id, collaborators = data.collaborators, collab_name = data.collab_name })
end)

RegisterNetEvent('epsilon:admin:doTeleport', function(x, y, z)
    SetEntityCoordsNoOffset(PlayerPedId(), x, y, z, false, false, false)
end)

RegisterNetEvent('epsilon:admin:setFreeze', function(state)
    FreezeEntityPosition(PlayerPedId(), state)
end)

RegisterNetEvent('epsilon:admin:toggleFreezeState', function(targetId, state)
    uiRelay({ type = 'freezeState', id = targetId, frozen = state })
end)

RegisterNetEvent('epsilon:admin:vehicleFreezeState', function(targetId, state, inVehicle)
    uiRelay({ type = 'vehicleFreezeState', id = targetId, vehicleFrozen = state, inVehicle = inVehicle })
end)

RegisterNetEvent('epsilon:admin:doHeal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
end)

RegisterNetEvent('epsilon:admin:doKill', function()
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('epsilon:admin:doRevive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent('epsilon:admin:showAnnounce', function(staffName, msg, duration)
    uiRelay({ type = 'announce', admin = staffName, message = msg, duration = duration or 10 })
end)

-- Vehicle actions
RegisterNetEvent('epsilon:admin:doFixVehicle', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then return end
    SetVehicleFixed(v); SetVehicleDeformationFixed(v)
    SetVehicleEngineOn(v, true, true, false)
end)

RegisterNetEvent('epsilon:admin:doDeleteVehicle', function()
    local ped = PlayerPedId()
    local v = GetVehiclePedIsIn(ped, false)
    if v ~= 0 then
        TaskLeaveVehicle(ped, v, 0)
        Wait(400)
        SetEntityAsMissionEntity(v, true, true)
        DeleteEntity(v)
    else
        local coords = GetEntityCoords(ped)
        local closest = nil; local closestDist = 10.0
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            local d = #(coords - GetEntityCoords(veh))
            if d < closestDist then closestDist = d; closest = veh end
        end
        if closest then SetEntityAsMissionEntity(closest, true, true); DeleteEntity(closest) end
    end
end)

RegisterNetEvent('epsilon:admin:doRefuelVehicle', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v ~= 0 then SetVehicleFuelLevel(v, 100.0) end
end)

RegisterNetEvent('epsilon:admin:doBurstTyres', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then return end
    for i = 0, 7 do SetVehicleTyreBurst(v, i, true, 1000.0) end
end)

RegisterNetEvent('epsilon:admin:doBreakWindows', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then return end
    for i = 0, 7 do SmashVehicleWindow(v, i) end
end)

RegisterNetEvent('epsilon:admin:doHealArmour', function()
    SetPedArmour(PlayerPedId(), 100)
end)

RegisterNetEvent('epsilon:admin:doDamage', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, math.max(101, GetEntityHealth(ped) - 10))
end)

RegisterNetEvent('epsilon:admin:doCleanVehicle', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then return end
    SetVehicleDirtLevel(v, 0.0)
end)

RegisterNetEvent('epsilon:admin:doEngineDamage', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then return end
    SetVehicleEngineHealth(v, -4000.0)
end)

RegisterNetEvent('epsilon:admin:queryVehicleFreezeState', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    TriggerServerEvent('epsilon:admin:reportVehicleFreezeState', v ~= 0 and IsEntityPositionFrozen(v), false, v ~= 0)
end)

RegisterNetEvent('epsilon:admin:doFreezeVehicle', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), false)
    if v == 0 then
        TriggerServerEvent('epsilon:admin:reportVehicleFreezeState', false, true, false)
        return
    end
    local newState = not IsEntityPositionFrozen(v)
    FreezeEntityPosition(v, newState)
    TriggerServerEvent('epsilon:admin:reportVehicleFreezeState', newState, true, true)
end)

RegisterNetEvent('epsilon:admin:doSpawnVehicleFor', function(model)
    local hash = GetHashKey(model)
    if not IsModelValid(hash) then
        notify(source, '~r~Modèle invalide: ' .. tostring(model))
        return
    end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(50); timeout = timeout + 1
    end
    if not HasModelLoaded(hash) then return end
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh    = CreateVehicle(hash, coords.x, coords.y, coords.z + 0.5, GetEntityHeading(ped), true, false)
    SetVehicleFuelLevel(veh, 100.0)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetModelAsNoLongerNeeded(hash)
end)

-- ── Self-tool events from server ──────────────────────────────
local noclipEntity = nil

RegisterNetEvent('epsilon:admin:doToggleNoclip', function()
    noclipOn = not noclipOn
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        noclipEntity = GetVehiclePedIsIn(ped, false)
    else
        noclipEntity = ped
    end
    SetEntityCollision(noclipEntity, not noclipOn, not noclipOn)
    FreezeEntityPosition(noclipEntity, noclipOn)
    SetEntityInvincible(noclipEntity, noclipOn)
    SetEveryoneIgnorePlayer(ped, noclipOn)
    SetPoliceIgnorePlayer(ped, noclipOn)
    if noclipOn then
        SetEntityAlpha(ped, 150, false)
        uiRelay({ type = 'noclipHUD', active = true, speedIdx = noclipSpeedIdx, speed = currentNoclipSpeed })
    else
        ResetEntityAlpha(ped)
        noclipEntity = nil
        uiRelay({ type = 'noclipHUD', active = false })
    end
    uiRelay({ type = 'toolState', tool = 'noclip', state = noclipOn })
    notifyLocal(noclipOn and 'Noclip activé' or 'Noclip désactivé', noclipOn and NC.purple or NC.amber, 'bi-eyeglasses')
end)

RegisterNetEvent('epsilon:admin:doToggleGod', function()
    godMode = not godMode
    if not godMode then
        local ped = PlayerPedId()
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        SetPedCanRagdoll(ped, true)
    end
    uiRelay({ type = 'toolState', tool = 'god', state = godMode })
    notifyLocal(godMode and 'God mode activé' or 'God mode désactivé', godMode and NC.green or NC.amber, 'bi-shield-fill')
end)

RegisterNetEvent('epsilon:admin:doToggleGhost', function()
    ghostOn = not ghostOn
    SetEntityVisible(PlayerPedId(), not ghostOn, false)
    uiRelay({ type = 'toolState', tool = 'ghost', state = ghostOn })
    notifyLocal(ghostOn and 'Ghost mode activé' or 'Ghost mode désactivé', ghostOn and NC.purple or NC.amber, 'bi-eye-slash-fill')
end)

RegisterNetEvent('epsilon:admin:setFire', function(state)
    local ped = PlayerPedId()
    if state then
        isOnFire = true
        StartEntityFire(ped)
        CreateThread(function()
            while isOnFire do
                Wait(0)
                SetEntityProofs(ped, false, true, false, false, false, false, false, false)
                if not IsEntityOnFire(ped) then StartEntityFire(ped) end
            end
            StopEntityFire(ped)
            local coords = GetEntityCoords(ped)
            StopFireInRange(coords.x, coords.y, coords.z, 5.0)
            SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        end)
    else
        isOnFire = false
        StopEntityFire(ped)
        local coords = GetEntityCoords(ped)
        StopFireInRange(coords.x, coords.y, coords.z, 5.0)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
    end
end)

RegisterNetEvent('epsilon:admin:setCage', function(state)
    if state then
        local coords = GetEntityCoords(PlayerPedId())
        RequestModel('prop_gascage01')
        while not HasModelLoaded('prop_gascage01') do Wait(100) end
        cageObject = CreateObject('prop_gascage01', coords.x, coords.y, coords.z - 1.0, false, false, false)
        FreezeEntityPosition(cageObject, true)
    else
        if cageObject and DoesEntityExist(cageObject) then
            DeleteObject(cageObject); cageObject = nil
        end
    end
end)

RegisterNetEvent('epsilon:admin:doSpectate', function(targetId)
    local ped = PlayerPedId()
    if spectating then
        spectating     = false
        spectateTarget = nil
        NetworkSetInSpectatorMode(false, ped)
        Wait(200)
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, false)
        FreezeEntityPosition(ped, false)
        uiRelay({ type = 'spectateState', state = false })
    else
        spectating     = true
        spectateTarget = targetId
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
        local targetHandle = GetPlayerFromServerId(targetId)
        local targetPed    = GetPlayerPed(targetHandle)
        NetworkSetInSpectatorMode(true, targetPed)
        local name = GetPlayerName(targetHandle) or ('Joueur #' .. targetId)
        uiRelay({ type = 'spectateState', state = true, target = name, serverId = targetId })
    end
end)

-- ── God mode thread ───────────────────────────────────────────
CreateThread(function()
    while true do
        if godMode then
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
            SetEntityProofs(ped, true, true, true, true, true, true, true, true)
            SetPedCanRagdoll(ped, false)
            if GetEntityHealth(ped) < GetEntityMaxHealth(ped) then
                SetEntityHealth(ped, GetEntityMaxHealth(ped))
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

local noclipSpeeds   = { 0.0, 0.5, 2.0, 4.0, 6.0, 10.0, 20.0, 25.0 }
local noclipSpeedIdx = 2
local currentNoclipSpeed = 0.5

-- ── Noclip thread — Wait(1) = ~1000Hz, override le freeze ─────
CreateThread(function()
    while true do
        Wait(1)
        if noclipOn and noclipEntity then
            local yoff, zoff = 0.0, 0.0

            if IsControlPressed(0, 32)  then yoff =  0.5 end  -- W
            if IsControlPressed(0, 33)  then yoff = -0.5 end  -- S
            if IsControlPressed(0, 85)  then zoff =  0.2 end  -- Q monter
            if IsControlPressed(0, 48)  then zoff = -0.2 end  -- Z descendre

            if IsControlPressed(0, 34) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) + 3.0)
            end
            if IsControlPressed(0, 35) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) - 3.0)
            end

            if IsControlJustPressed(0, 21) then
                noclipSpeedIdx = (noclipSpeedIdx % #noclipSpeeds) + 1
                currentNoclipSpeed = noclipSpeeds[noclipSpeedIdx]
                uiRelay({ type = 'noclipHUD', active = true, speedIdx = noclipSpeedIdx, speed = currentNoclipSpeed })
            end

            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentNoclipSpeed + 0.3), zoff * (currentNoclipSpeed + 0.3))
            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)
            SetEntityAlpha(GetPlayerPed(-1), 127, false)
            SetPlayerInvincible(PlayerId(), true)
        end
    end
end)

-- ── Super sprint thread ───────────────────────────────────────
CreateThread(function()
    while true do
        if superSprint then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ── Super jump thread ─────────────────────────────────────────
CreateThread(function()
    while true do
        if superJump then
            SetSuperJumpThisFrame(PlayerId())
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ── Super swim thread ─────────────────────────────────────────
CreateThread(function()
    while true do
        if superSwim then
            SetSwimMultiplierForPlayer(PlayerId(), 3.0)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ── Stamina infinie thread ────────────────────────────────────
CreateThread(function()
    while true do
        if infiniteStamina then
            ResetPedStamina(PlayerPedId())
            SetPlayerStamina(PlayerId(), 100.0)
            Wait(100)
        else
            Wait(500)
        end
    end
end)

-- Retourne le sprite blip selon le véhicule du joueur
local function getPlayerBlipSprite(pid)
    local ped = GetPlayerPed(pid)
    if not IsPedInAnyVehicle(ped, false) then return 1 end -- à pied
    local veh   = GetVehiclePedIsIn(ped, false)
    local model = GetEntityModel(veh)
    if IsThisModelAHeli(model)  then return 422 end -- hélicoptère
    if IsThisModelAPlane(model) then return 423 end -- avion
    if IsThisModelABoat(model)  then return 427 end -- bateau
    if IsThisModelABike(model)  then return 226 end -- moto
    if GetVehicleClass(veh) == 18 then return 56 end -- véhicule urgence
    return 225 -- voiture standard
end

-- ── Show names thread ─────────────────────────────────────────
CreateThread(function()
    while true do
        if showNames then
            local now = GetGameTimer()
            if now - tagDataTimer > 8000 then
                tagDataTimer = now
                refreshTagData()
            end

            -- Regrouper les joueurs par véhicule
            local vehicleOccupants = {}  -- vehHandle → { pid, ... }
            local soloPlayers      = {}

            for _, pid in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(pid)
                if DoesEntityExist(ped) then
                    if IsPedInAnyVehicle(ped, false) then
                        local veh = GetVehiclePedIsIn(ped, false)
                        if not vehicleOccupants[veh] then vehicleOccupants[veh] = {} end
                        table.insert(vehicleOccupants[veh], pid)
                    else
                        table.insert(soloPlayers, pid)
                    end
                end
            end

            -- Joueurs à pied : tag au-dessus de la tête
            for _, pid in ipairs(soloPlayers) do
                local ped    = GetPlayerPed(pid)
                local coords = GetEntityCoords(ped)
                local sid    = GetPlayerServerId(pid)
                local tag    = playerTagData[sid]
                if tag then
                    DrawNameTag(coords.x, coords.y, coords.z + 1.1, tag, 0, NetworkIsPlayerTalking(pid))
                end
            end

            -- Joueurs en véhicule : tous les tags stackés au-dessus du véhicule
            for veh, pids in pairs(vehicleOccupants) do
                local vc   = GetEntityCoords(veh)
                local topZ = vc.z + 2.0
                for i, pid in ipairs(pids) do
                    local sid = GetPlayerServerId(pid)
                    local tag = playerTagData[sid]
                    if tag then
                        DrawNameTag(vc.x, vc.y, topZ, tag, i - 1, NetworkIsPlayerTalking(pid))
                    end
                end
            end

            Wait(0)
        else
            tagDataTimer = 0
            Wait(500)
        end
    end
end)

-- ── Show blips thread ─────────────────────────────────────────
-- Recrée les blips si le joueur change de véhicule (sprite change)
local blipSpriteCache = {}

CreateThread(function()
    while true do
        if showBlips then
            local active = {}
            for _, pid in ipairs(GetActivePlayers()) do
                active[pid] = true
                local ped = GetPlayerPed(pid)
                if DoesEntityExist(ped) then
                    local sprite = getPlayerBlipSprite(pid)
                    -- Recréer le blip si sprite change ou s'il n'existe plus
                    if blipSpriteCache[pid] ~= sprite
                    or not playerBlips[pid] or not DoesBlipExist(playerBlips[pid]) then
                        if playerBlips[pid] and DoesBlipExist(playerBlips[pid]) then
                            RemoveBlip(playerBlips[pid])
                        end
                        local blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, sprite)
                        SetBlipColour(blip, pid == PlayerId() and 2 or 3)
                        SetBlipNameToPlayerName(blip, pid)
                        playerBlips[pid]     = blip
                        blipSpriteCache[pid] = sprite
                    end
                end
            end
            for pid, blip in pairs(playerBlips) do
                if not active[pid] then
                    if DoesBlipExist(blip) then RemoveBlip(blip) end
                    playerBlips[pid]     = nil
                    blipSpriteCache[pid] = nil
                end
            end
            Wait(1000) -- vérification sprite toutes les secondes
        else
            Wait(1000)
        end
    end
end)

-- Jobs
AddEventHandler('epsilon:admin:nui:admin:getJobs',        function()  TriggerServerEvent('epsilon:admin:getJobs') end)
AddEventHandler('epsilon:admin:nui:admin:getPlayerJobs',  function(d) TriggerServerEvent('epsilon:admin:getPlayerJobs', d.id) end)
AddEventHandler('epsilon:admin:nui:admin:setJob',         function(d) TriggerServerEvent('epsilon:admin:setJob', d.id, d.jobName, d.grade) end)
AddEventHandler('epsilon:admin:nui:admin:removeJob',      function(d) TriggerServerEvent('epsilon:admin:removeJob', d.id, d.jobName) end)
AddEventHandler('epsilon:admin:nui:admin:setGrade',       function(d) TriggerServerEvent('epsilon:admin:setGrade', d.id, d.jobName, d.grade) end)

RegisterNetEvent('epsilon:admin:jobsList', function(list)
    uiRelay({ type = 'jobsList', jobs = list })
end)

RegisterNetEvent('epsilon:admin:playerJobs', function(data)
    uiRelay({ type = 'playerJobs', targetId = data.targetId, charId = data.charId, jobs = data.jobs })
end)

RegisterNetEvent('epsilon:admin:refreshPlayerJobs', function(targetId)
    TriggerServerEvent('epsilon:admin:getPlayerJobs', targetId)
end)

AddEventHandler('epsilon:admin:nui:admin:devGetCoords', function(data, cb)
    local ped = PlayerPedId()
    local c   = GetEntityCoords(ped)
    local h   = GetEntityHeading(ped)
    cb({ x = math.floor(c.x * 100) / 100, y = math.floor(c.y * 100) / 100, z = math.floor(c.z * 100) / 100, h = math.floor(h * 10) / 10 })
end)


