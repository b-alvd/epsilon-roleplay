-- Utilitaires purs + helpers GPS/blip/HUD

function vdist(a, b)
    return #(vector3(a.x, a.y, a.z) - vector3(b.x, b.y, b.z))
end

function shuffleCopy(t)
    local c = {}
    for _, v in ipairs(t) do c[#c + 1] = v end
    for i = #c, 2, -1 do
        local j = math.random(i)
        c[i], c[j] = c[j], c[i]
    end
    return c
end

function DrawText3D(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(sx, sy)
end

function getGroundZ(x, y, z)
    local found, gz = GetGroundZFor_3dCoord(x, y, z + 3.0, false)
    return found and gz or z
end

function rgbToHex(c)
    return ('#%02x%02x%02x'):format(c.r, c.g, c.b)
end

-- flags : 49 = loop+moving (défaut), 48 = upper body + secondary task (vélo), 0 = one-shot
function playAnim(anim, duration, flags)
    if not anim then Wait(duration or 2000); return end
    if anim.type == 'scenario' then
        local ped = PlayerPedId()
        TaskStartScenarioInPlace(ped, anim.name, 0, true)
        Wait(duration)
        ClearPedTasksImmediately(ped)
        return
    end
    if anim.type == 'carry' then return end -- géré séparément dans doFixedStep
    RequestAnimDict(anim.dict)
    local t = 0
    while not HasAnimDictLoaded(anim.dict) and t < 3000 do Wait(100); t = t + 100 end
    if not HasAnimDictLoaded(anim.dict) then Wait(duration or 2000); return end
    local ped = PlayerPedId()

    local attachedProps = {}
    if anim.props then
        for _, p in ipairs(anim.props) do
            local hash = GetHashKey(p.model)
            RequestModel(hash)
            local pt = 0
            while not HasModelLoaded(hash) and pt < 2000 do Wait(100); pt = pt + 100 end
            if HasModelLoaded(hash) then
                local obj = CreateObject(hash, 0.0, 0.0, 0.0, true, true, false)
                local pl = p.placement
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, p.bone),
                    pl[1], pl[2], pl[3], pl[4], pl[5], pl[6], true, true, false, true, 1, true)
                attachedProps[#attachedProps + 1] = obj
            end
        end
    end

    TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, duration, flags or 49, 0, false, false, false)
    Wait(duration)
    StopAnimTask(ped, anim.dict, anim.clip, -8.0)

    for _, obj in ipairs(attachedProps) do
        DetachEntity(obj, true, true)
        DeleteObject(obj)
    end
end

function playCarry(fromCoords, toCoords)
    local ped      = PlayerPedId()
    local dict     = 'anim@heists@box_carry@'
    local clipset  = 'move_m@carry_object@low'

    RequestAnimDict(dict)
    RequestAnimSet(clipset)
    local t = 0
    while (not HasAnimDictLoaded(dict) or not HasAnimSetLoaded(clipset)) and t < 3000 do
        Wait(100); t = t + 100
    end

    -- Ramassage
    FreezeEntityPosition(ped, true)
    TaskPlayAnim(ped, dict, 'pickup_low', 8.0, -8.0, 1200, 0, 0, false, false, false)
    Wait(1200)
    FreezeEntityPosition(ped, false)

    -- Marche avec clipset de portage (TaskGoStraightToCoord gère le déplacement)
    SetPedMovementClipset(ped, clipset, 0.25)
    TaskGoStraightToCoord(ped, toCoords.x, toCoords.y, toCoords.z, 1.0, 12000, 0.0, 0.5)
    local elapsed = 0
    while elapsed < 12000 do
        local pos = GetEntityCoords(ped)
        if #(vector3(pos.x, pos.y, pos.z) - vector3(toCoords.x, toCoords.y, toCoords.z)) < 1.5 then break end
        Wait(200)
        elapsed = elapsed + 200
    end
    ClearPedTasks(ped)
    ResetPedMovementClipset(ped, 0.0)

    -- Dépôt
    FreezeEntityPosition(ped, true)
    TaskPlayAnim(ped, dict, 'drop_low', 8.0, -8.0, 1200, 0, 0, false, false, false)
    Wait(1200)
    FreezeEntityPosition(ped, false)
end

function setGPS(coords, sprite, color, label, scale)
    if IS.navBlip and DoesBlipExist(IS.navBlip) then RemoveBlip(IS.navBlip) end
    IS.navBlip = nil
    if not coords then return end
    local b = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(b, sprite or 8)
    SetBlipColour(b, color or 0)
    SetBlipScale(b, scale or 0.55)
    SetBlipAsShortRange(b, false)
    SetBlipRoute(b, true)
    SetBlipRouteColour(b, color or 0)
    if label then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(b)
    end
    IS.navBlip = b
end

function clearGPS()
    if IS.navBlip and DoesBlipExist(IS.navBlip) then RemoveBlip(IS.navBlip) end
    IS.navBlip = nil
end

function setTargetBlip(coords, def, sprite, label)
    if IS.targetBlip and DoesBlipExist(IS.targetBlip) then RemoveBlip(IS.targetBlip) end
    IS.targetBlip = nil
    if not coords then return end
    local b = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(b, sprite or (def.blip and def.blip.sprite) or 365)
    SetBlipColour(b, def.blip and def.blip.color or 24)
    SetBlipScale(b, 0.55)
    SetBlipAsShortRange(b, false)
    SetBlipRoute(b, true)
    SetBlipRouteColour(b, def.blip and def.blip.color or 24)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label or 'Destination')
    EndTextCommandSetBlipName(b)
    IS.targetBlip = b
end

function sendHUD(visible)
    if visible and IS.activeMission then
        local def   = Config.Missions[IS.activeMission]
        local total = IS.runStopTarget > 0 and IS.runStopTarget or (def.binCount or def.mailboxCount or #IS.run)
        local step  = IS.activeMission == 'eboueur'           and IS.dumpedCount
                   or (IS.activeMission == 'livreur_colis' and IS.collectedCount)
                   or math.max(0, IS.runStep - 1)
        local label = ''
        if IS.activeMission == 'eboueur' then
            if IS.STATE == 'RETURNING' then
                label = 'Retournez au dépôt'
            elseif IS.STATE == 'AT_TRUCK' then
                label = def.actions.dump.label
            elseif IS.STATE == 'DRIVING_TARGET' then
                label = not IS.arrivedAtQuartier
                    and ('Conduisez jusqu\'au quartier : ' .. IS.activeQuartierLabel)
                    or def.actions.collect.label
            else
                label = 'Explorez le quartier...'
            end
        elseif IS.activeMission == 'livreur_colis' then
            if IS.STATE == 'RETURNING' then
                label = 'Retournez au dépôt'
            elseif not IS.livreurLoaded then
                label = 'Rendez-vous à l\'entrepôt de colis'
            elseif IS.STATE == 'WAITING_TRUNK_LOAD' then
                label = 'Retournez au véhicule, rangez le colis dans le coffre'
            elseif IS.STATE == 'DRIVING_TARGET' and IS.newspaperProp then
                label = 'Déposez le colis'
            elseif IS.STATE == 'DRIVING_TARGET' and IS.nearTruck then
                label = 'Prenez un colis dans le coffre'
            elseif IS.STATE == 'DRIVING_TARGET' then
                label = 'Rendez-vous au prochain point de livraison'
            else
                label = def.actions.deliver.label
            end
        else
            local s = IS.run[IS.runStep]
            label = s and s.label or ''
        end
        TriggerEvent('epsilon:interim:hud', {
            visible = true,
            mission = def.label,
            step    = step,
            total   = total,
            label   = label,
            earned  = math.floor(IS.runEarned),
            color   = rgbToHex(def.color),
        })
    else
        TriggerEvent('epsilon:interim:hud', { visible = false })
    end
end
