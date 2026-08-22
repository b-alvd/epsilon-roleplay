local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1
L0_1 = false
L1_1 = AddScenarioBlockingArea
L2_1 = 433.3967590332
L3_1 = -970.45172119141
L4_1 = 33.356460571289
L5_1 = 419.02282714844
L6_1 = -988.55102539062
L7_1 = 29.450477600098
L8_1 = false
L9_1 = true
L10_1 = true
L11_1 = true
L1_1 = L1_1(L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1)
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = A0_2
  L3_2 = SetPlayerControl
  L4_2 = L2_2
  L5_2 = not A1_2
  L6_2 = false
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = GetPlayerPed
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if not A1_2 then
    L4_2 = IsEntityVisible
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if not L4_2 then
      L4_2 = SetEntityVisible
      L5_2 = L3_2
      L6_2 = true
      L4_2(L5_2, L6_2)
    end
    L4_2 = IsPedInAnyVehicle
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if not L4_2 then
      L4_2 = SetEntityCollision
      L5_2 = L3_2
      L6_2 = true
      L4_2(L5_2, L6_2)
    end
    L4_2 = FreezeEntityPosition
    L5_2 = L3_2
    L6_2 = false
    L4_2(L5_2, L6_2)
    L4_2 = SetPlayerInvincible
    L5_2 = L2_2
    L6_2 = false
    L4_2(L5_2, L6_2)
  else
    L4_2 = IsEntityVisible
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if L4_2 then
      L4_2 = SetEntityVisible
      L5_2 = L3_2
      L6_2 = false
      L4_2(L5_2, L6_2)
    end
    L4_2 = SetEntityCollision
    L5_2 = L3_2
    L6_2 = false
    L4_2(L5_2, L6_2)
    L4_2 = FreezeEntityPosition
    L5_2 = L3_2
    L6_2 = true
    L4_2(L5_2, L6_2)
    L4_2 = SetPlayerInvincible
    L5_2 = L2_2
    L6_2 = true
    L4_2(L5_2, L6_2)
    L4_2 = IsPedFatallyInjured
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if not L4_2 then
      L4_2 = ClearPedTasksImmediately
      L5_2 = L3_2
      L4_2(L5_2)
    end
  end
end
L3_1 = RequestAmbientAudioBank
L4_1 = "MP_PROPERTIES_ELEVATOR_DOORS"
L5_1 = 0
L6_1 = 0
L3_1(L4_1, L5_1, L6_1)
function L3_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "BUTTON"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "OPENING"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "OPENED"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
end
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "FAKE_ARRIVE"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "CLOSING"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  L0_2 = PlaySoundFrontend
  L1_2 = -1
  L2_2 = "CLOSED"
  L3_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
  L4_2 = 1
  L0_2(L1_2, L2_2, L3_2, L4_2)
end
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = DoScreenFadeOut
  L3_2 = 1000
  L2_2(L3_2)
  while true do
    L2_2 = IsScreenFadedOut
    L2_2 = L2_2()
    if L2_2 then
      break
    end
    L2_2 = Citizen
    L2_2 = L2_2.Wait
    L3_2 = 0
    L2_2(L3_2)
  end
  L2_2 = L2_1
  L3_2 = PlayerId
  L3_2 = L3_2()
  L4_2 = true
  L2_2(L3_2, L4_2)
  while true do
    L2_2 = IsScreenFadedOut
    L2_2 = L2_2()
    if L2_2 then
      break
    end
    L2_2 = Citizen
    L2_2 = L2_2.Wait
    L3_2 = 0
    L2_2(L3_2)
  end
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = SetEntityCoordsNoOffset
  L4_2 = L2_2
  L5_2 = A0_2
  L6_2 = false
  L7_2 = false
  L8_2 = false
  L9_2 = true
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L3_2 = GetGameTimer
  L3_2 = L3_2()
  L4_2 = RequestCollisionAtCoord
  L5_2 = A0_2
  L4_2(L5_2)
  while true do
    L4_2 = HasCollisionLoadedAroundEntity
    L5_2 = L2_2
    L4_2 = L4_2(L5_2)
    if L4_2 then
      break
    end
    L4_2 = GetGameTimer
    L4_2 = L4_2()
    L4_2 = L4_2 - L3_2
    L5_2 = 5000
    if not (L4_2 < L5_2) then
      break
    end
    L4_2 = Citizen
    L4_2 = L4_2.Wait
    L5_2 = 0
    L4_2(L5_2)
  end
  L4_2 = Citizen
  L4_2 = L4_2.Wait
  L5_2 = 1000
  L4_2(L5_2)
  L4_2 = SetEntityCoordsNoOffset
  L5_2 = L2_2
  L6_2 = A0_2
  L7_2 = false
  L8_2 = false
  L9_2 = false
  L10_2 = true
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L4_2 = NetworkResurrectLocalPlayer
  L5_2 = A0_2
  L6_2 = 0.0
  L7_2 = true
  L8_2 = true
  L9_2 = false
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  L4_2 = ClearPedTasksImmediately
  L5_2 = L2_2
  L4_2(L5_2)
  L4_2 = RemoveAllPedWeapons
  L5_2 = L2_2
  L4_2(L5_2)
  L4_2 = ClearPlayerWantedLevel
  L5_2 = PlayerId
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L5_2()
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L4_2 = SetEntityHeading
  L5_2 = L2_2
  L6_2 = A1_2
  L4_2(L5_2, L6_2)
  L4_2 = L2_1
  L5_2 = PlayerId
  L5_2 = L5_2()
  L6_2 = false
  L4_2(L5_2, L6_2)
  L4_2 = DoScreenFadeIn
  L5_2 = 1000
  L4_2(L5_2)
  L4_2 = L4_1
  L4_2()
end
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = SetCloudHatOpacity
  L1_2 = cloudOpacity
  L0_2(L1_2)
  L0_2 = HideHudAndRadarThisFrame
  L0_2()
  L0_2 = SetDrawOrigin
  L1_2 = 0.0
  L2_2 = 0.0
  L3_2 = 0.0
  L4_2 = 0
  L0_2(L1_2, L2_2, L3_2, L4_2)
end
function L7_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = Config
  L0_2 = L0_2.Locations
  L1_2 = 1
  L2_2 = #L0_2
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = L0_2[L4_2]
    L5_2 = L5_2.blipType
    if L5_2 then
      L5_2 = AddBlipForCoord
      L6_2 = L0_2[L4_2]
      L6_2 = L6_2.blipCoords
      L5_2 = L5_2(L6_2)
      L6_2 = SetBlipSprite
      L7_2 = L5_2
      L8_2 = L0_2[L4_2]
      L8_2 = L8_2.blipType
      L6_2(L7_2, L8_2)
      L6_2 = SetBlipColour
      L7_2 = L5_2
      L8_2 = L0_2[L4_2]
      L8_2 = L8_2.blipColor
      L6_2(L7_2, L8_2)
      L6_2 = SetBlipAsShortRange
      L7_2 = L5_2
      L8_2 = true
      L6_2(L7_2, L8_2)
      L6_2 = BeginTextCommandSetBlipName
      L7_2 = "STRING"
      L6_2(L7_2)
      L6_2 = AddTextComponentString
      L7_2 = L0_2[L4_2]
      L7_2 = L7_2.label
      L6_2(L7_2)
      L6_2 = EndTextCommandSetBlipName
      L7_2 = L5_2
      L6_2(L7_2)
    end
  end
end
function L8_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = L5_1
  L3_2 = A0_2
  L4_2 = A1_2
  L2_2(L3_2, L4_2)
end
Teleport = L8_1
