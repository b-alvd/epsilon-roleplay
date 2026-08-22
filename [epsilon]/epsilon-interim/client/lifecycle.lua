function resetState()
    IS.STATE               = 'IDLE'
    IS.activeMission       = nil
    IS.run                 = {}
    IS.runStep             = 0
    IS.runEarned           = 0.0
    IS.spawnedVeh          = nil
    IS.collectedCount      = 0
    IS.dumpedCount         = 0
    IS.targetProp          = nil
    IS.missionBins         = {}
    IS.livreurLoaded       = false
    IS.nearTruck           = false
    IS.runStopTarget       = 0
    IS.activeQuartierLabel = ''
    IS.arrivedAtQuartier   = false
    if IS.targetBlip and DoesBlipExist(IS.targetBlip) then RemoveBlip(IS.targetBlip) end
    if IS.navBlip    and DoesBlipExist(IS.navBlip)    then RemoveBlip(IS.navBlip)    end
    IS.targetBlip = nil
    IS.navBlip    = nil
    removeGarbageBag()
    removeNewspaper()
end

function endRun(abandoned)
    sendHUD(false)
    TriggerServerEvent('epsilon:interim:stop', IS.localCharId)
    clearGPS()
    deleteVehicle()
    if abandoned then
        TriggerEvent('epsilon:notify', {
            title = 'Mission abandonnee',
            msg   = ('%.0f$ gagnes avant abandon'):format(IS.runEarned),
            type  = 'warning',
        })
    end
    resetState()
end

local function advanceStep()
    IS.runStep = IS.runStep + 1
    if IS.runStep > #IS.run then
        local def = Config.Missions[IS.activeMission]
        IS.STATE = 'RETURNING'
        setGPS(def.depot.coords, def.blip.sprite, def.blip.color, 'Dépôt')
        TriggerEvent('epsilon:notify', {
            title = 'Tâches terminées !',
            msg   = 'Retournez au dépôt pour récupérer votre salaire.',
            type  = 'info', duration = 8,
        })
        sendHUD(true)
    else
        local def = Config.Missions[IS.activeMission]
        setGPS(IS.run[IS.runStep].coords, def.blip and def.blip.sprite or 8, def.blip and def.blip.color or 2, IS.run[IS.runStep].label)
        IS.STATE = 'TRAVELING'
        sendHUD(true)
    end
end

function doFixedStep()
    local step = IS.run[IS.runStep]
    if not step then endRun(false); return end
    local def    = Config.Missions[IS.activeMission]
    local actDef = def.actions[step.action]
    if not actDef then advanceStep(); return end

    IS.STATE = 'ANIMATING'
    local ped = PlayerPedId()

    if actDef.anim and actDef.anim.type == 'carry' and step.carryTo then
        playCarry(step.coords, step.carryTo)
    else
        FreezeEntityPosition(ped, true)
        playAnim(actDef.anim, actDef.duration or 2000)
        FreezeEntityPosition(ped, false)
    end

    TriggerServerEvent('epsilon:interim:action', IS.localCharId, IS.activeMission, step.action)
    advanceStep()
end

function startRun(missionName, quartierName, stopCount)
    if not IS.localCharId then
        TriggerEvent('epsilon:notify', { title='Interim', msg='Personnage non charge, reessayez.', type='warning' })
        return
    end

    local def = Config.Missions[missionName]
    IS.activeMission  = missionName
    IS.runEarned      = 0.0
    IS.collectedCount = 0
    IS.dumpedCount    = 0
    IS.livreurLoaded  = false
    IS.run            = {}
    IS.runStep        = 0

    TriggerServerEvent('epsilon:interim:start', IS.localCharId, missionName)

    if missionName == 'eboueur' then
        spawnVehicle(missionName)
        local spots, quartierLabel = {}, quartierName or ''
        if quartierName and def.quartiers then
            for _, q in ipairs(def.quartiers) do
                if q.name == quartierName then
                    spots = shuffleCopy(q.spots)
                    quartierLabel = q.label
                    IS.activeQuartierLabel = q.label
                    break
                end
            end
        end
        IS.runStopTarget = math.min(stopCount or #spots, #spots)
        for i = 1, IS.runStopTarget do
            IS.run[i] = { coords = spots[i], action = 'collect', label = def.actions.collect.label }
        end
        IS.runStep = 1
        setTargetBlip(IS.run[1].coords, def)
        IS.STATE = 'DRIVING_TARGET'
        TriggerEvent('epsilon:notify', {
            title = 'Tournée démarrée — Eboueur',
            msg   = 'Conduisez jusqu\'au quartier : ' .. quartierLabel,
            type  = 'info', duration = 7,
        })

    elseif missionName == 'livreur_colis' then
        spawnVehicle(missionName)
        local spots, quartierLabel = {}, quartierName or ''
        if quartierName and def.quartiers then
            for _, q in ipairs(def.quartiers) do
                if q.name == quartierName then
                    spots = shuffleCopy(q.spots)
                    quartierLabel = q.label
                    break
                end
            end
        end
        IS.runStopTarget = math.min(stopCount or #spots, #spots)
        local pickupCoords = (def.pickupDepot and def.pickupDepot.coords) or def.depot.coords
        IS.run = {{ coords = pickupCoords, action = 'pickup', label = def.actions.pickup.label }}
        for i = 1, IS.runStopTarget do
            IS.run[#IS.run + 1] = { coords = spots[i], action = 'deliver', label = def.actions.deliver.label }
        end
        IS.runStep = 1
        IS.STATE   = 'TRAVELING'
        setGPS(pickupCoords, def.blip.sprite, def.blip.color, 'Entrepôt colis')
        TriggerEvent('epsilon:notify', {
            title = 'Livreur de colis',
            msg   = 'Récupérez les colis à l\'entrepôt, puis livrez ' .. IS.runStopTarget .. ' adresses — ' .. quartierLabel,
            type  = 'info', duration = 8,
        })

    else
        local pool = shuffleCopy(def.stepPool)
        for i = 1, math.min(def.stepCount, #pool) do
            IS.run[#IS.run + 1] = {
                coords = pool[i].coords,
                action = pool[i].action,
                label  = def.actions[pool[i].action].label,
            }
        end
        IS.runStep = 1
        IS.STATE   = 'TRAVELING'
        setGPS(IS.run[1].coords, def.blip and def.blip.sprite or 8, def.blip and def.blip.color or 2, IS.run[1].label)
    end

    sendHUD(true)
end
