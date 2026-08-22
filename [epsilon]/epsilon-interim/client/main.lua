-- ════════════════════════════════════════════════════════════════
--  epsilon-interim / client/main.lua  — thread principal + events
--
--  États :
--    IDLE             — menu dépôts
--    DRIVING_TARGET   — navigation vers le spot courant
--    TRAVELING        — GPS vers étape fixe (agent/ouvrier)
--    AT_ZONE          — à portée, attente [E]
--    ANIMATING        — animation en cours
--    AT_TRUCK         — éboueur : poubelle ramassée, retour camion
--    WAITING_TRUNK_LOAD — livreur : ranger le colis dans le véhicule
--    RETURNING        — retour dépôt pour paiement
-- ════════════════════════════════════════════════════════════════

-- ── Help notification helper ─────────────────────────────────────────────────
local _interimHint = nil
local function SetInterimHint(msg)
    if msg == _interimHint then return end
    _interimHint = msg
    if msg then
        exports['epsilon-ui']:ShowHelpNotification(msg)
    else
        exports['epsilon-ui']:HideHelpNotification()
    end
end

-- ── CharId recovery ──────────────────────────────────────────────────────────
AddEventHandler('epsilon:spawn:complete', function(data)
    if data and data.id then IS.localCharId = data.id end
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Citizen.CreateThread(function()
        Wait(2000)
        while not IS.localCharId do
            TriggerServerEvent('epsilon:interim:requestCharId', IS.localCharId)
            Wait(3000)
        end
    end)
end)

RegisterNetEvent('epsilon:interim:actionPay', function(amount)
    IS.runEarned = IS.runEarned + (amount or 0)
    sendHUD(true)
end)

RegisterNetEvent('epsilon:interim:earnedSync', function(total)
    IS.runEarned = total
    sendHUD(true)
end)

RegisterNetEvent('epsilon:interim:setCharId', function(id)
    IS.localCharId = id
    Epsilon.Debug.Info('[interim] charId recupere: ' .. tostring(id))
end)

-- ════════════════════════════════════════════════════════════════
--  Thread principal
-- ════════════════════════════════════════════════════════════════
Citizen.CreateThread(function()
    Wait(5000)
    createStartBlips()
    if Config.DevMode then createDevBlips() end

    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local frameHint = nil

        -- ── IDLE ─────────────────────────────────────────────────────────────
        if IS.STATE == 'IDLE' then
            for key, def in pairs(Config.Missions) do
                local d = vdist(pos, def.depot.coords)
                if d < 40.0 then
                    local c = def.color
                    DrawMarker(1,
                        def.depot.coords.x, def.depot.coords.y, getGroundZ(def.depot.coords.x, def.depot.coords.y, def.depot.coords.z),
                        0,0,0, 0,0,0, 1.5, 1.5, 0.4,
                        c.r, c.g, c.b, 160,
                        false, true, 2, false, nil, nil, false)
                end
                if d < 5.0 then
                    frameHint = '[E] Commencer une mission intérimaire'
                end
                if d < 5.0 and IsControlJustPressed(0, 38) then
                    local payMin, payMax = 0, 0
                    for _, actDef in pairs(def.actions) do
                        local p = actDef.pay
                        if type(p) == 'table' then
                            payMin = payMin + (p.min or 0)
                            payMax = payMax + (p.max or 0)
                        else
                            payMin = payMin + (p or 0)
                            payMax = payMax + (p or 0)
                        end
                    end
                    local q = {}
                    if def.quartiers then
                        for _, qd in ipairs(def.quartiers) do
                            q[#q+1] = { name=qd.name, label=qd.label, spotCount=#qd.spots }
                        end
                    end
                    TriggerEvent('epsilon:interim:openSelect', {
                        mission       = key,
                        label         = def.label,
                        color         = rgbToHex(def.color),
                        quartiers     = q,
                        stopOptions   = def.stopOptions or {},
                        timePerStop   = def.timePerStop or 2.0,
                        payMinPerStop = payMin,
                        payMaxPerStop = payMax,
                    })
                    break
                end
            end

        -- ── DRIVING_TARGET ───────────────────────────────────────────────────
        elseif IS.STATE == 'DRIVING_TARGET' then
            local def  = Config.Missions[IS.activeMission]
            local step = IS.run[IS.runStep]
            if step then
                local tc     = step.coords
                local dist2d = math.sqrt((pos.x - tc.x)^2 + (pos.y - tc.y)^2)
                local c      = def.color

                if IS.activeMission == 'eboueur' then
                    DrawMarker(2, tc.x, tc.y, tc.z + 1.5, 0,0,0, 0,180,0, 0.6,0.6,0.6, c.r,c.g,c.b,220, false,true,2,false,nil,nil,false)
                    if dist2d < 25.0 then
                        DrawMarker(1, tc.x, tc.y, getGroundZ(tc.x,tc.y,tc.z), 0,0,0, 0,0,0, 1.2,1.2,0.5, c.r,c.g,c.b,120, false,true,2,false,nil,nil,false)
                    end
                    if not IS.arrivedAtQuartier and dist2d < 80.0 then
                        IS.arrivedAtQuartier = true
                        sendHUD(true)
                    end
                    if dist2d < 4.0 and not IsPedInAnyVehicle(ped, false) then
                        frameHint = '[E] ' .. Config.Missions.eboueur.actions.collect.label
                        if IsControlJustPressed(0, 38) then doCollect() end
                    end

                elseif IS.activeMission == 'livreur_colis' then
                    if not IS.newspaperProp then
                        -- Pas de colis : flèche vers le spot, marker sur le véhicule quand on est arrivé
                        DrawMarker(2, tc.x, tc.y, tc.z + 1.5, 0,0,0, 0,180,0, 0.6,0.6,0.6, c.r,c.g,c.b,220, false,true,2,false,nil,nil,false)
                        local isNear = dist2d < 20.0 and not IsPedInAnyVehicle(ped, false) and IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh)
                        if isNear ~= IS.nearTruck then
                            IS.nearTruck = isNear
                            sendHUD(true)
                        end
                        if isNear then
                            local ro = def.vehicle and def.vehicle.rearOffset or vector3(0.0, -3.5, 0.0)
                            local vp = GetOffsetFromEntityInWorldCoords(IS.spawnedVeh, ro.x, ro.y, ro.z)
                            local vd = math.sqrt((pos.x - vp.x)^2 + (pos.y - vp.y)^2)
                            DrawMarker(1, vp.x, vp.y, getGroundZ(vp.x,vp.y,vp.z), 0,0,0, 0,0,0, 1.0,1.0,0.5, c.r,c.g,c.b,160, false,true,2,false,nil,nil,false)
                            if vd < 2.0 then
                                frameHint = '[E] Prendre le colis'
                                if IsControlJustPressed(0, 38) then doTakeParcel() end
                            end
                        end
                    else
                        -- Colis en mains : flèche + marker sur la boîte aux lettres
                        DrawMarker(2, tc.x, tc.y, tc.z + 1.5, 0,0,0, 0,180,0, 0.6,0.6,0.6, c.r,c.g,c.b,220, false,true,2,false,nil,nil,false)
                        if dist2d < 10.0 then
                            DrawMarker(1, tc.x, tc.y, getGroundZ(tc.x,tc.y,tc.z), 0,0,0, 0,0,0, 1.2,1.2,0.5, c.r,c.g,c.b,120, false,true,2,false,nil,nil,false)
                        end
                        if dist2d < 2.0 then
                            frameHint = '[E] Déposer le colis'
                            if IsControlJustPressed(0, 38) then doDeposit() end
                        end
                    end
                end
            end

        -- ── WAITING_TRUNK_LOAD ───────────────────────────────────────────────
        elseif IS.STATE == 'WAITING_TRUNK_LOAD' then
            if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then
                local def = Config.Missions.livreur_colis
                local ro  = def.vehicle and def.vehicle.rearOffset or vector3(0.0, -3.5, 0.0)
                local vp  = GetOffsetFromEntityInWorldCoords(IS.spawnedVeh, ro.x, ro.y, ro.z)
                local vd  = vdist(pos, vp)
                local c   = def.color
                DrawMarker(1, vp.x, vp.y, getGroundZ(vp.x,vp.y,vp.z), 0,0,0, 0,0,0, 1.2,1.2,0.5, c.r,c.g,c.b,180, false,true,2,false,nil,nil,false)
                if vd < 2.0 then
                    frameHint = '[E] Ranger dans le coffre'
                    if IsControlJustPressed(0, 38) then doLoadTrunk() end
                end
            end

        -- ── AT_ZONE ──────────────────────────────────────────────────────────
        elseif IS.STATE == 'AT_ZONE' then
            local step = IS.run[IS.runStep]
            if step then
                local d   = vdist(pos, step.coords)
                local def = Config.Missions[IS.activeMission]
                local c   = def and def.color or { r=100, g=220, b=100 }
                DrawMarker(1,
                    step.coords.x, step.coords.y, getGroundZ(step.coords.x, step.coords.y, step.coords.z),
                    0,0,0, 0,0,0,
                    Config.MarkerSize, Config.MarkerSize, 0.8,
                    c.r, c.g, c.b, 200,
                    false, true, 2, false, nil, nil, false)
                if d < Config.ArrivalRadius + 4.0 then
                    if not (def.vehicle and IsPedInAnyVehicle(ped, false)) then
                        if d < Config.InteractRadius then
                            local hint = step.action == 'pickup'
                                and ('[E] ' .. (def.actions.pickup and def.actions.pickup.label or 'Charger'))
                                or  ('[E] ' .. (def.actions[step.action] and def.actions[step.action].label or step.action))
                            frameHint = hint
                            if IsControlJustPressed(0, 38) then
                                if step.action == 'pickup' then doPickup()
                                else doFixedStep() end
                            end
                        end
                    end
                else
                    IS.STATE = 'TRAVELING'
                    setGPS(step.coords)
                end
            end

        -- ── TRAVELING ────────────────────────────────────────────────────────
        elseif IS.STATE == 'TRAVELING' then
            local step = IS.run[IS.runStep]
            if step then
                local d   = vdist(pos, step.coords)
                local def = Config.Missions[IS.activeMission]
                local c   = def and def.color or { r=100, g=220, b=100 }
                if d < 40.0 then
                    DrawMarker(1,
                        step.coords.x, step.coords.y, getGroundZ(step.coords.x, step.coords.y, step.coords.z),
                        0,0,0, 0,0,0,
                        Config.MarkerSize, Config.MarkerSize, 0.8,
                        c.r, c.g, c.b, 80,
                        false, true, 2, false, nil, nil, false)
                end
                if d < Config.ArrivalRadius then
                    IS.STATE = 'AT_ZONE'
                    clearGPS()
                end
            end

        -- ── RETURNING ────────────────────────────────────────────────────────
        elseif IS.STATE == 'RETURNING' then
            local def   = Config.Missions[IS.activeMission]
            local sp    = def.depot.vehSpawn
            local depot = sp and vector3(sp.x, sp.y, sp.z) or def.depot.coords
            local d     = vdist(pos, depot)
            local c     = def.color
            local doneCount = IS.activeMission == 'eboueur'           and IS.dumpedCount
                           or (IS.activeMission == 'livreur_colis' and IS.collectedCount)
                           or (IS.runStep - 1)
            if d < 30.0 then
                DrawMarker(1, depot.x, depot.y, getGroundZ(depot.x, depot.y, depot.z), 0,0,0, 0,0,0, 1.5,1.5,0.4, c.r,c.g,c.b,160, false,true,2,false,nil,nil,false)
            end
            if d < 5.0 then
                frameHint = '[E] Terminer la mission et récupérer votre salaire'
            end
            if d < 5.0 and IsControlJustPressed(0, 38) then
                IS.STATE = 'ANIMATING'
                TriggerServerEvent('epsilon:interim:complete', IS.localCharId, IS.activeMission, doneCount)
                Wait(500)
                sendHUD(false)
                TriggerServerEvent('epsilon:interim:stop', IS.localCharId)
                clearGPS()
                deleteVehicle()
                resetState()
            end

        -- ── AT_TRUCK (éboueur) ───────────────────────────────────────────────
        elseif IS.STATE == 'AT_TRUCK' then
            if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then
                local rearPos = GetOffsetFromEntityInWorldCoords(IS.spawnedVeh, 0.0, -4.5, 0.0)
                local d       = #(pos - rearPos)
                local c       = Config.Missions.eboueur.color
                if d < 25.0 then
                    DrawMarker(1, rearPos.x, rearPos.y, getGroundZ(rearPos.x,rearPos.y,rearPos.z), 0,0,0, 0,0,0, Config.MarkerSize+1.0, Config.MarkerSize+1.0, 0.8, c.r,c.g,c.b,160, false,true,2,false,nil,nil,false)
                end
                if d < 3.0 and not IsPedInAnyVehicle(ped, false) then
                    frameHint = '[E] ' .. Config.Missions.eboueur.actions.dump.label
                    if IsControlJustPressed(0, 38) then doDump() end
                end
            else
                TriggerEvent('epsilon:notify', { title='Eboueur', msg='Le camion a ete detruit ! Mission annulee.', type='error' })
                endRun(true)
            end
        end
        SetInterimHint(frameHint)
    end
end)

-- ── Abandon F6 ───────────────────────────────────────────────────────────────
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IS.STATE ~= 'IDLE' and IsControlJustPressed(0, 246) then
            endRun(true)
        end
    end
end)

-- ── NUI ──────────────────────────────────────────────────────────────────────
local function buildMissionList()
    local list = {}
    for key, def in pairs(Config.Missions) do
        local payMin, payMax = 0, 0
        for _, actDef in pairs(def.actions) do
            local p = actDef.pay
            if type(p) == 'table' then
                payMin = payMin + (p.min or 0)
                payMax = payMax + (p.max or 0)
            else
                payMin = payMin + (p or 0)
                payMax = payMax + (p or 0)
            end
        end
        local q = {}
        if def.quartiers then
            for _, qd in ipairs(def.quartiers) do
                q[#q+1] = { name=qd.name, label=qd.label, spotCount=#qd.spots }
            end
        end
        list[#list+1] = {
            mission       = key,
            label         = def.label,
            color         = rgbToHex(def.color),
            quartiers     = q,
            stopOptions   = def.stopOptions or {},
            timePerStop   = def.timePerStop or 2.0,
            payMinPerStop = payMin,
            payMaxPerStop = payMax,
        }
    end
    return list
end

AddEventHandler('epsilon:interim:requestList', function()
    TriggerEvent('epsilon:interim:openList', buildMissionList())
end)

AddEventHandler('epsilon:interim:nui:start', function(data)
    startRun(data.mission, data.quartier, data.stops)
end)

RegisterNetEvent('epsilon:interim:stopped', function()
    sendHUD(false)
    if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then DeleteVehicle(IS.spawnedVeh) end
    resetState()
    clearGPS()
end)

-- ── Debug ─────────────────────────────────────────────────────────────────────
RegisterCommand('interimdbg', function()
    local p = GetEntityCoords(PlayerPedId())
    print('[INTERIM] Pos: ' .. p.x .. ', ' .. p.y .. ', ' .. p.z)
    print('[INTERIM] STATE=' .. IS.STATE .. '  charId=' .. tostring(IS.localCharId))
    print('[INTERIM] Mission: ' .. tostring(IS.activeMission) .. '  collected=' .. IS.collectedCount)
    for key, def in pairs(Config.Missions) do
        print(('[INTERIM] depot %s : %.1fm'):format(key, vdist(p, def.depot.coords)))
    end
end, false)

RegisterCommand('interimdump', function()
    local pos    = GetEntityCoords(PlayerPedId())
    local counts = {}
    local total  = 0
    for _, obj in ipairs(GetGamePool('CObject')) do
        local hash = GetEntityModel(obj)
        if #(GetEntityCoords(obj) - pos) < 100.0 then
            counts[hash] = (counts[hash] or 0) + 1
            total = total + 1
        end
    end
    print('[DUMP] ' .. total .. ' objets dans 100m:')
    for hash, cnt in pairs(counts) do
        print(('[DUMP]   hash=%u  x%d'):format(hash, cnt))
    end
end, false)
