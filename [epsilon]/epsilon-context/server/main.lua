-- Notifier un joueur cible (suggestions de voix, messages staff)
RegisterNetEvent('epsilon:context:notifyPlayer')
AddEventHandler('epsilon:context:notifyPlayer', function(targetSrc, msg)
    TriggerClientEvent('epsilon:context:cl:notify', targetSrc, msg)
end)

-- Spawn d'un véhicule admin (admin côté server pour éviter l'abus client)
RegisterNetEvent('epsilon:context:spawnVehicle')
AddEventHandler('epsilon:context:spawnVehicle', function(x, y, z, heading, model)
    local src = source
    TriggerClientEvent('epsilon:context:cl:requestVehicleSpawn', src, x, y, z, heading, model or 'sultan')
end)
