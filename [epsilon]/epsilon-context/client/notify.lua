RegisterNetEvent('epsilon:context:cl:notify')
AddEventHandler('epsilon:context:cl:notify', function(msg)
    Notify(msg)
end)

RegisterNetEvent('epsilon:context:cl:requestVehicleSpawn')
AddEventHandler('epsilon:context:cl:requestVehicleSpawn', function(x, y, z, heading, model)
    local hash = GetHashKey(model or 'sultan')
    if not IsModelValid(hash) then
        Notify('Modèle invalide : ' .. tostring(model), '#ef4444', 'bi-x-circle-fill')
        return
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    local veh = CreateVehicle(hash, x, y, z, heading, true, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end)
