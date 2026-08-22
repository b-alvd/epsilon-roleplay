-- Actions sur le sol / rien (admin uniquement)

ECM_Register(function(screenPos, hitSomething, worldPos, hitEntity, normalDir)
    if not IsAdmin() then return end
    -- ne s'affiche que si on clique sur rien (ou décor non-entité)
    if DoesEntityExist(hitEntity) and
       (IsPedAPlayer(hitEntity) or IsEntityAVehicle(hitEntity) or IsEntityAPed(hitEntity)) then
        return
    end

    local subWorld = ECM_AddSubmenu(0, "(admin) Monde")

    local iTP  = ECM_AddItem(subWorld, "Se TP ici")
    local iVeh = ECM_AddItem(subWorld, "Créer un véhicule")
    local iExp = ECM_AddItem(subWorld, "Explosion")

    ECM_OnActivate(iTP, function()
        SetEntityCoords(PlayerPedId(), worldPos.x, worldPos.y, worldPos.z)
        TriggerServerEvent('epsilon:admin:logAction', 'teleport_coords', nil, { x = math.floor(worldPos.x), y = math.floor(worldPos.y), z = math.floor(worldPos.z) })
        Notify('TP effectué', '#3b82f6', 'bi-geo-alt-fill')
    end)
    ECM_OnActivate(iVeh, function()
        exports['epsilon-ui']:ShowKeyboardInput({
            title       = 'Spawn véhicule',
            placeholder = 'Nom du modèle (ex: adder)',
            icon        = 'bi-car-front-fill',
        }, function(model)
            if not model or model == '' then return end
            model = model:lower():gsub('%s+', '')
            TriggerServerEvent('epsilon:context:spawnVehicle', worldPos.x, worldPos.y, worldPos.z, GetEntityHeading(PlayerPedId()), model)
            TriggerServerEvent('epsilon:admin:logAction', 'spawn_vehicle', nil, { model = model })
            Notify('Véhicule spawné : ' .. model, 'rgba(147,51,234,0.85)', 'bi-car-front-fill')
        end)
    end)
    ECM_OnActivate(iExp, function()
        AddExplosion(worldPos.x, worldPos.y, worldPos.z, 0, 10.0, true, false, 2.0)
        TriggerServerEvent('epsilon:admin:logAction', 'explosion', nil, { x = math.floor(worldPos.x), y = math.floor(worldPos.y), z = math.floor(worldPos.z) })
        Notify('Explosion créée', '#ef4444', 'bi-fire')
    end)
end)
