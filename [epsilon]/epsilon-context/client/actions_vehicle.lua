-- Actions sur un véhicule

ECM_Register(function(screenPos, hitSomething, worldPos, hitEntity, normalDir)
    if not DoesEntityExist(hitEntity) then return end
    if not IsEntityAVehicle(hitEntity) then return end
    if not IsAdmin() then return end

    local plate = GetVehicleNumberPlateText(hitEntity)

    local subVeh = ECM_AddSubmenu(0, "(admin) Véhicule [" .. plate .. "]")

    local iFix    = ECM_AddItem(subVeh, "Réparer")
    local iDelete = ECM_AddItem(subVeh, "Supprimer")
    local iRefuel = ECM_AddItem(subVeh, "Faire le plein")

    ECM_OnActivate(iFix, function()
        SetVehicleFixed(hitEntity)
        SetVehicleDeformationFixed(hitEntity)
        SetVehicleEngineOn(hitEntity, true, true, false)
        TriggerServerEvent('epsilon:admin:logAction', 'fix_vehicle', nil, { plate = plate })
        Notify('Véhicule réparé [' .. plate .. ']', '#22c55e', 'bi-tools')
    end)
    ECM_OnActivate(iDelete, function()
        SetEntityAsMissionEntity(hitEntity, true, true)
        DeleteEntity(hitEntity)
        TriggerServerEvent('epsilon:admin:logAction', 'delete_vehicle', nil, { plate = plate })
        Notify('Véhicule supprimé [' .. plate .. ']', '#ef4444', 'bi-trash3-fill')
    end)
    ECM_OnActivate(iRefuel, function()
        SetVehicleFuelLevel(hitEntity, 100.0)
        TriggerServerEvent('epsilon:admin:logAction', 'refuel_vehicle', nil, { plate = plate })
        Notify('Véhicule ravitaillé [' .. plate .. ']', '#22c55e', 'bi-fuel-pump-fill')
    end)
end)
