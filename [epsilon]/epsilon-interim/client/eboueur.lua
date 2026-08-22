local function attachGarbageBag(ped, propDef, carryAnim)
    if not propDef then return end
    if carryAnim then
        RequestAnimDict(carryAnim.dict)
        local t = 0
        while not HasAnimDictLoaded(carryAnim.dict) and t < 3000 do Wait(100); t = t + 100 end
        if HasAnimDictLoaded(carryAnim.dict) then
            TaskPlayAnim(ped, carryAnim.dict, carryAnim.clip, 8.0, -8.0, -1, 49, 0, false, false, false)
            IS.garbageBagCarryDict = carryAnim
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
    IS.garbageBagProp = prop
end

function removeGarbageBag()
    local ped = PlayerPedId()
    if IS.garbageBagCarryDict then
        StopAnimTask(ped, IS.garbageBagCarryDict.dict, IS.garbageBagCarryDict.clip, -8.0)
        IS.garbageBagCarryDict = nil
    end
    if IS.garbageBagProp and DoesEntityExist(IS.garbageBagProp) then
        DetachEntity(IS.garbageBagProp, true, true)
        DeleteObject(IS.garbageBagProp)
    end
    IS.garbageBagProp = nil
end

function doCollect()
    if IS.STATE ~= 'DRIVING_TARGET' then return end
    local def    = Config.Missions.eboueur
    local actDef = def.actions.collect
    IS.STATE = 'ANIMATING'

    if IS.targetBlip and DoesBlipExist(IS.targetBlip) then RemoveBlip(IS.targetBlip) end
    IS.targetBlip = nil

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    removeGarbageBag()
    playAnim(actDef.anim, actDef.duration or 3000)
    attachGarbageBag(ped, actDef.prop, actDef.carryAnim)
    FreezeEntityPosition(ped, false)

    TriggerServerEvent('epsilon:interim:action', IS.localCharId, 'eboueur', 'collect')
    IS.collectedCount = IS.collectedCount + 1

    IS.STATE = 'AT_TRUCK'
    sendHUD(true)
end

function doDump()
    local def = Config.Missions.eboueur
    if IS.STATE ~= 'AT_TRUCK' then return end
    local actDef = def.actions.dump
    IS.STATE = 'ANIMATING'

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)

    if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then
        SetVehicleDoorOpen(IS.spawnedVeh, 5, false, false)
        Wait(400)
    end

    playAnim(actDef.anim, actDef.duration or 2500)
    removeGarbageBag()

    if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then
        SetVehicleDoorShut(IS.spawnedVeh, 5, false)
    end

    FreezeEntityPosition(ped, false)

    TriggerServerEvent('epsilon:interim:action', IS.localCharId, 'eboueur', 'dump')
    IS.dumpedCount = IS.dumpedCount + 1

    if IS.dumpedCount >= IS.runStopTarget then
        IS.STATE = 'RETURNING'
        local sp = def.depot.vehSpawn
        local returnCoords = sp and vector3(sp.x, sp.y, sp.z) or def.depot.coords
        setGPS(returnCoords, def.blip.sprite, def.blip.color, 'Dépôt')
        TriggerEvent('epsilon:notify', {
            title = 'Tournée terminée !',
            msg   = 'Retournez au dépôt pour récupérer votre salaire.',
            type  = 'info', duration = 8,
        })
        sendHUD(true)
    else
        IS.runStep = IS.runStep + 1
        local nextStep = IS.run[IS.runStep]
        if nextStep then
            setTargetBlip(nextStep.coords, def)
        end
        IS.STATE = 'DRIVING_TARGET'
        sendHUD(true)
    end
end
