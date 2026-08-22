local function openRearDoors(veh, doors)
    if not veh or not DoesEntityExist(veh) then return end
    for _, d in ipairs(doors) do SetVehicleDoorOpen(veh, d, false, false) end
end

local function closeRearDoors(veh, doors)
    if not veh or not DoesEntityExist(veh) then return end
    for _, d in ipairs(doors) do SetVehicleDoorShut(veh, d, false) end
end

local function attachNewspaper(ped, propDef, carryAnim)
    if not propDef then return end
    if IS.newspaperProp and DoesEntityExist(IS.newspaperProp) then return end
    if carryAnim then
        RequestAnimDict(carryAnim.dict)
        local t = 0
        while not HasAnimDictLoaded(carryAnim.dict) and t < 3000 do Wait(100); t = t + 100 end
        if HasAnimDictLoaded(carryAnim.dict) then
            TaskPlayAnim(ped, carryAnim.dict, carryAnim.clip, 8.0, -8.0, -1, 49, 0, false, false, false)
            IS.parcelCarryDict = carryAnim
        end
    end
    local hash = joaat(propDef.model)
    RequestModel(hash)
    local t = 0
    while not HasModelLoaded(hash) and t < 3000 do Wait(100); t = t + 100 end
    if not HasModelLoaded(hash) then return end
    local coords = GetEntityCoords(ped)
    local prop   = CreateObject(hash, coords.x, coords.y, coords.z, true, true, true)
    local pl     = propDef.placement
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, propDef.bone),
        pl[1], pl[2], pl[3], pl[4], pl[5], pl[6],
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(hash)
    IS.newspaperProp = prop
end

function removeNewspaper()
    local ped = PlayerPedId()
    if IS.parcelCarryDict then
        StopAnimTask(ped, IS.parcelCarryDict.dict, IS.parcelCarryDict.clip, -8.0)
        IS.parcelCarryDict = nil
    end
    if IS.newspaperProp and DoesEntityExist(IS.newspaperProp) then
        DetachEntity(IS.newspaperProp, true, true)
        DeleteObject(IS.newspaperProp)
    end
    IS.newspaperProp = nil
end

function doPickup()
    local def    = Config.Missions.livreur_colis
    local actDef = def.actions.pickup
    IS.STATE = 'ANIMATING'

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
        Wait(1800)
    end
    FreezeEntityPosition(ped, true)
    playAnim(actDef.anim, actDef.duration or 800, 0)
    attachNewspaper(ped, actDef.prop, actDef.carryAnim)
    FreezeEntityPosition(ped, false)

    TriggerServerEvent('epsilon:interim:action', IS.localCharId, 'livreur_colis', 'pickup')
    IS.livreurLoaded = true

    TriggerEvent('epsilon:notify', {
        title = 'Livreur de colis',
        msg   = 'Retournez au véhicule et rangez le colis dans le coffre.',
        type  = 'info', duration = 6,
    })
    IS.STATE = 'WAITING_TRUNK_LOAD'
end

function doLoadTrunk()
    local def   = Config.Missions.livreur_colis
    local doors = def.vehicle and def.vehicle.rearDoors or { 5 }
    IS.STATE = 'ANIMATING'

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
        Wait(1800)
    end
    FreezeEntityPosition(ped, true)
    openRearDoors(IS.spawnedVeh, doors)
    Wait(500)
    if IS.parcelCarryDict then
        StopAnimTask(ped, IS.parcelCarryDict.dict, IS.parcelCarryDict.clip, -8.0)
        IS.parcelCarryDict = nil
    end
    playAnim(def.actions.deliver.anim, def.actions.deliver.duration or 800, 0)
    removeNewspaper()
    Wait(300)
    closeRearDoors(IS.spawnedVeh, doors)
    FreezeEntityPosition(ped, false)

    IS.runStep = IS.runStep + 1
    if IS.run[IS.runStep] then
        setTargetBlip(IS.run[IS.runStep].coords, def, 525, 'Livraison')
    end
    IS.STATE = 'DRIVING_TARGET'
    sendHUD(true)
end

function doTakeParcel()
    local def   = Config.Missions.livreur_colis
    local doors = def.vehicle and def.vehicle.rearDoors or { 5 }
    IS.STATE = 'ANIMATING'

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
        Wait(1500)
    end
    FreezeEntityPosition(ped, true)
    openRearDoors(IS.spawnedVeh, doors)
    Wait(300)
    playAnim(def.actions.pickup.anim, 800, 0)
    attachNewspaper(ped, def.actions.pickup.prop, def.actions.pickup.carryAnim)
    Wait(300)
    closeRearDoors(IS.spawnedVeh, doors)
    FreezeEntityPosition(ped, false)

    IS.STATE = 'DRIVING_TARGET'
end

function doDeposit()
    local def    = Config.Missions.livreur_colis
    local actDef = def.actions.deliver
    IS.STATE = 'ANIMATING'

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    if IS.parcelCarryDict then
        StopAnimTask(ped, IS.parcelCarryDict.dict, IS.parcelCarryDict.clip, -8.0)
        IS.parcelCarryDict = nil
    end
    playAnim(actDef.anim, 800, 0)
    removeNewspaper()
    FreezeEntityPosition(ped, false)

    if IS.targetProp and IS.targetProp.visited ~= nil then IS.targetProp.visited = true end
    if IS.targetBlip and DoesBlipExist(IS.targetBlip) then RemoveBlip(IS.targetBlip) end
    IS.targetBlip = nil
    IS.targetProp = nil

    TriggerServerEvent('epsilon:interim:action', IS.localCharId, 'livreur_colis', 'deliver')
    IS.collectedCount = IS.collectedCount + 1

    if IS.collectedCount >= IS.runStopTarget then
        removeNewspaper()
        IS.STATE = 'RETURNING'
        setTargetBlip(def.depot.coords, def, 478, 'Dépôt')
        TriggerEvent('epsilon:notify', {
            title = 'Tournée terminée !',
            msg   = 'Tous les colis livrés. Retournez au dépôt pour votre salaire.',
            type  = 'info', duration = 8,
        })
        sendHUD(true)
    else
        IS.runStep = IS.runStep + 1
        if IS.run[IS.runStep] then
            setTargetBlip(IS.run[IS.runStep].coords, def, 525, 'Livraison')
        end
        IS.STATE = 'DRIVING_TARGET'
        sendHUD(true)
    end
end
