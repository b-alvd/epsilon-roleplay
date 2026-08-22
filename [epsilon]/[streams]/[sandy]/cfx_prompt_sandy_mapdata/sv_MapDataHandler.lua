local maps = {
	"prompt_sandy_roads",
	"prompt_sandy_downtown",
	"prompt_sandy_fire2",
	"prompt_sandy_hospital2",
	"prompt_sandy_university",
	"prompt_sandy_corner",
	"prompt_sandy_apts",
	"prompt_sandy_bank",
	"prompt_sandy_market",
	"prompt_sandy_motel",
	"prompt_sandy_gasstation_carwash",
	"prompt_sandy_compound",
	"prompt_sandy_church",
	"prompt_sandy_classic_car_dealership",
	"prompt_sandy_cityhall",
	"sandy_shores_houses_pt1",
	"prompt_sandy_train_station",
	"prompt_sandy_beaches",
	"cfx_chuz_sandy_shores_boat_house",
	"prompt_sandy_sheriff",
	"prompt_sandy_airfield"
}

local events = {}

-- Sandy mapdata exists event
RegisterNetEvent("prompt:mapdata_exists", function(cb)
  cb(true)
end)

-- Sandy mapdata list event
RegisterNetEvent("prompt:mapdata_sendList", function(returnevent)
  TriggerEvent(returnevent, maps)
end)

-- Legacy mapdata exists event
RegisterNetEvent("lyn-mapdata:exists", function(cb)
  cb(true)
end)

-- Legacy support for individual map checks
for i = 1, #maps do
  local eventName = maps[i] .. ":mapDataExists"
  if Debug == true then
    print("Creating event: ", eventName)
  end
  local event = RegisterNetEvent(eventName, function(cb)
    cb(true)
  end)
  table.insert(events, event)
end
