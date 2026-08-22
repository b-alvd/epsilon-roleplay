local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1
L0_1 = Config
if not L0_1 then
  L0_1 = {}
end
Config = L0_1
L0_1 = {}
L1_1 = {}
L1_1.propModel = "prompt_sandy_boatramp_dweather_sunny"
L2_1 = vector4
L3_1 = 1406.14893
L4_1 = 3703.760578
L5_1 = 35.143572
L6_1 = 1.0
L2_1 = L2_1(L3_1, L4_1, L5_1, L6_1)
L1_1.spawnCoords = L2_1
L1_1.currentProp = nil
L2_1 = {}
L3_1 = "RAIN"
L4_1 = "THUNDER"
L5_1 = "BLIZZARD"
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L1_1.weatherTypesToDespawn = L2_1
L1_1.freeze = true
L1_1.checkWeather = true
L1_1.checkTime = true
L1_1.startHour = 5
L1_1.endHour = 20
L1_1.distanceCheck = true
L1_1.maxDistance = 50.0
L2_1 = {}
L2_1.propModel = "prompt_sandy_boatramp_dweather_rainy"
L3_1 = vector4
L4_1 = 1406.14893
L5_1 = 3703.760578
L6_1 = 35.143572
L7_1 = 1.0
L3_1 = L3_1(L4_1, L5_1, L6_1, L7_1)
L2_1.spawnCoords = L3_1
L2_1.currentProp = nil
L3_1 = {}
L4_1 = "CLEAR"
L5_1 = "EXTRASUNNY"
L6_1 = "CLOUDS"
L7_1 = "OVERCAST"
L8_1 = "THUNDER"
L9_1 = "CLEARING"
L10_1 = "SMOG"
L11_1 = "FOGGY"
L12_1 = "XMAS"
L13_1 = "SNOW"
L14_1 = "SNOWLIGHT"
L15_1 = "NEUTRAL"
L16_1 = "BLIZZARD"
L3_1[1] = L4_1
L3_1[2] = L5_1
L3_1[3] = L6_1
L3_1[4] = L7_1
L3_1[5] = L8_1
L3_1[6] = L9_1
L3_1[7] = L10_1
L3_1[8] = L11_1
L3_1[9] = L12_1
L3_1[10] = L13_1
L3_1[11] = L14_1
L3_1[12] = L15_1
L3_1[13] = L16_1
L2_1.weatherTypesToDespawn = L3_1
L2_1.freeze = false
L2_1.checkWeather = true
L2_1.checkTime = false
L2_1.distanceCheck = true
L2_1.maxDistance = 50.0
L3_1 = {}
L3_1.propModel = "prompt_sandy_boatramp_dweather_storm"
L4_1 = vector4
L5_1 = 1406.14893
L6_1 = 3703.760578
L7_1 = 35.143572
L8_1 = 1.0
L4_1 = L4_1(L5_1, L6_1, L7_1, L8_1)
L3_1.spawnCoords = L4_1
L3_1.currentProp = nil
L4_1 = {}
L5_1 = "CLEAR"
L6_1 = "EXTRASUNNY"
L7_1 = "CLOUDS"
L8_1 = "OVERCAST"
L9_1 = "RAIN"
L10_1 = "CLEARING"
L11_1 = "SMOG"
L12_1 = "FOGGY"
L13_1 = "XMAS"
L14_1 = "SNOW"
L15_1 = "SNOWLIGHT"
L16_1 = "NEUTRAL"
L4_1[1] = L5_1
L4_1[2] = L6_1
L4_1[3] = L7_1
L4_1[4] = L8_1
L4_1[5] = L9_1
L4_1[6] = L10_1
L4_1[7] = L11_1
L4_1[8] = L12_1
L4_1[9] = L13_1
L4_1[10] = L14_1
L4_1[11] = L15_1
L4_1[12] = L16_1
L3_1.weatherTypesToDespawn = L4_1
L3_1.freeze = false
L3_1.checkWeather = true
L3_1.checkTime = false
L3_1.distanceCheck = true
L3_1.maxDistance = 50.0
L4_1 = {}
L4_1.propModel = "prompt_sandy_boatramp_dweather_moon_clear"
L5_1 = vector4
L6_1 = 1406.14893
L7_1 = 3703.760578
L8_1 = 35.143572
L9_1 = 1.0
L5_1 = L5_1(L6_1, L7_1, L8_1, L9_1)
L4_1.spawnCoords = L5_1
L4_1.currentProp = nil
L5_1 = {}
L6_1 = "THUNDER"
L7_1 = "STORM"
L5_1[1] = L6_1
L5_1[2] = L7_1
L4_1.weatherTypesToDespawn = L5_1
L4_1.freeze = true
L4_1.checkWeather = true
L4_1.checkTime = true
L4_1.startHour = 20
L4_1.endHour = 6
L4_1.distanceCheck = true
L4_1.maxDistance = 50.0
L0_1[1] = L1_1
L0_1[2] = L2_1
L0_1[3] = L3_1
L0_1[4] = L4_1
function L1_1(A0_2, A1_2, A2_2)
  local L3_2
  if A1_2 <= A2_2 then
    L3_2 = A1_2 <= A0_2 and A0_2 < A2_2
    return L3_2
  else
    L3_2 = A1_2 <= A0_2 or A0_2 < A2_2
    return L3_2
  end
end
isWithinTimeRange = L1_1
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = A0_2.currentProp
  if nil == L1_2 then
    L1_2 = Config
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = print
      L2_2 = "Spawning prop:"
      L3_2 = A0_2.propModel
      L1_2(L2_2, L3_2)
      L1_2 = print
      L2_2 = "Spawn coordinates: x="
      L3_2 = A0_2.spawnCoords
      L3_2 = L3_2.x
      L4_2 = ", y="
      L5_2 = A0_2.spawnCoords
      L5_2 = L5_2.y
      L6_2 = ", z="
      L7_2 = A0_2.spawnCoords
      L7_2 = L7_2.z
      L8_2 = ", heading="
      L9_2 = A0_2.spawnCoords
      L9_2 = L9_2.w
      L2_2 = L2_2 .. L3_2 .. L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2
      L1_2(L2_2)
    end
    L1_2 = GetHashKey
    L2_2 = A0_2.propModel
    L1_2 = L1_2(L2_2)
    L2_2 = RequestModel
    L3_2 = L1_2
    L2_2(L3_2)
    while true do
      L2_2 = HasModelLoaded
      L3_2 = L1_2
      L2_2 = L2_2(L3_2)
      if L2_2 then
        break
      end
      L2_2 = Wait
      L3_2 = 1
      L2_2(L3_2)
    end
    L2_2 = A0_2.spawnCoords
    L2_2 = L2_2.x
    L3_2 = A0_2.spawnCoords
    L3_2 = L3_2.y
    L4_2 = A0_2.spawnCoords
    L4_2 = L4_2.z
    L5_2 = A0_2.spawnCoords
    L5_2 = L5_2.w
    L6_2 = CreateObject
    L7_2 = L1_2
    L8_2 = L2_2
    L9_2 = L3_2
    L10_2 = L4_2
    L11_2 = false
    L12_2 = false
    L13_2 = true
    L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    A0_2.currentProp = L6_2
    L6_2 = SetEntityAsMissionEntity
    L7_2 = A0_2.currentProp
    L8_2 = true
    L9_2 = true
    L6_2(L7_2, L8_2, L9_2)
    L6_2 = SetEntityRotation
    L7_2 = A0_2.currentProp
    L8_2 = 0.0
    L9_2 = 0.0
    L10_2 = L5_2
    L11_2 = 2
    L12_2 = true
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L6_2 = Config
    L6_2 = L6_2.Debug
    if L6_2 then
      L6_2 = print
      L7_2 = "Prop spawned:"
      L8_2 = A0_2.propModel
      L6_2(L7_2, L8_2)
      L6_2 = A0_2.freeze
      if L6_2 then
        L6_2 = print
        L7_2 = "Prop is frozen in position"
        L6_2(L7_2)
      end
    end
    L6_2 = A0_2.freeze
    if L6_2 then
      L6_2 = FreezeEntityPosition
      L7_2 = A0_2.currentProp
      L8_2 = true
      L6_2(L7_2, L8_2)
    end
  else
    L1_2 = Config
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = print
      L2_2 = "Prop already spawned:"
      L3_2 = A0_2.propModel
      L1_2(L2_2, L3_2)
    end
  end
end
spawnProp = L1_1
function L1_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = A0_2.currentProp
  if nil ~= L1_2 then
    L1_2 = Config
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = print
      L2_2 = "Despawning prop:"
      L3_2 = A0_2.propModel
      L1_2(L2_2, L3_2)
    end
    L1_2 = DeleteObject
    L2_2 = A0_2.currentProp
    L1_2(L2_2)
    A0_2.currentProp = nil
    L1_2 = Config
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = print
      L2_2 = "Prop despawned:"
      L3_2 = A0_2.propModel
      L1_2(L2_2, L3_2)
    end
  else
    L1_2 = Config
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = print
      L2_2 = "No prop to despawn:"
      L3_2 = A0_2.propModel
      L1_2(L2_2, L3_2)
    end
  end
end
despawnProp = L1_1
function L1_1()
  local L0_2, L1_2, L2_2
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = GetEntityCoords
  L2_2 = L0_2
  return L1_2(L2_2)
end
getPlayerPosition = L1_1
L1_1 = Citizen
L1_1 = L1_1.CreateThread
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  while true do
    L0_2 = Wait
    L1_2 = 5000
    L0_2(L1_2)
    L0_2 = GetPrevWeatherTypeHashName
    L0_2 = L0_2()
    L1_2 = GetClockHours
    L1_2 = L1_2()
    L2_2 = getPlayerPosition
    L2_2 = L2_2()
    L3_2 = Config
    L3_2 = L3_2.Debug
    if L3_2 then
      L3_2 = print
      L4_2 = "Current weather:"
      L5_2 = L0_2
      L3_2(L4_2, L5_2)
      L3_2 = print
      L4_2 = "Current hour:"
      L5_2 = L1_2
      L3_2(L4_2, L5_2)
      L3_2 = print
      L4_2 = "playercoords:"
      L5_2 = L2_2
      L3_2(L4_2, L5_2)
    end
    L3_2 = nil
    L4_2 = ipairs
    L5_2 = L0_1
    L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
    for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
      L10_2 = false
      L11_2 = L9_2.distanceCheck
      if L11_2 then
        L11_2 = Vdist
        L12_2 = L2_2
        L13_2 = L9_2.spawnCoords
        L13_2 = L13_2.x
        L14_2 = L9_2.spawnCoords
        L14_2 = L14_2.y
        L15_2 = L9_2.spawnCoords
        L15_2 = L15_2.z
        L11_2 = L11_2(L12_2, L13_2, L14_2, L15_2)
        L12_2 = L9_2.maxDistance
        if L11_2 > L12_2 then
          L10_2 = true
        end
      end
      if not L10_2 then
        L11_2 = L9_2.checkWeather
        if L11_2 then
          L11_2 = ipairs
          L12_2 = L9_2.weatherTypesToDespawn
          L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
          for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
            L17_2 = GetHashKey
            L18_2 = L16_2
            L17_2 = L17_2(L18_2)
            if L17_2 == L0_2 then
              L10_2 = true
              break
            end
          end
        end
        L11_2 = L9_2.checkTime
        if L11_2 then
          L11_2 = isWithinTimeRange
          L12_2 = L1_2
          L13_2 = L9_2.startHour
          L14_2 = L9_2.endHour
          L11_2 = L11_2(L12_2, L13_2, L14_2)
          if not L11_2 then
            L10_2 = true
          end
        end
      end
      if not L10_2 then
        L3_2 = L9_2
        break
      end
    end
    L4_2 = ipairs
    L5_2 = L0_1
    L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
    for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
      if L9_2 == L3_2 then
        L10_2 = L9_2.currentProp
        if nil == L10_2 then
          L10_2 = spawnProp
          L11_2 = L9_2
          L10_2(L11_2)
        end
      else
        L10_2 = L9_2.currentProp
        if nil ~= L10_2 then
          L10_2 = despawnProp
          L11_2 = L9_2
          L10_2(L11_2)
        end
      end
    end
  end
end
L1_1(L2_1)
