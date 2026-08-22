function spawnVehicle(missionName)
    local def = Config.Missions[missionName]
    if not def.vehicle or not def.depot.vehSpawn then return end
    local model = GetHashKey(def.vehicle.model)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 5000 do Wait(100); t = t + 100 end
    if not HasModelLoaded(model) then return end
    local sp  = def.depot.vehSpawn
    local veh = CreateVehicle(model, sp.x, sp.y, sp.z, sp.w, false, false)
    SetEntityAsMissionEntity(veh, true, true)
    SetModelAsNoLongerNeeded(model)
    IS.spawnedVeh = veh
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
end

function deleteVehicle()
    if IS.spawnedVeh and DoesEntityExist(IS.spawnedVeh) then
        local ped = PlayerPedId()
        if IsPedInVehicle(ped, IS.spawnedVeh, false) then
            TaskLeaveVehicle(ped, IS.spawnedVeh, 0)
            Wait(1500)
        end
        DeleteVehicle(IS.spawnedVeh)
    end
    IS.spawnedVeh = nil
end
