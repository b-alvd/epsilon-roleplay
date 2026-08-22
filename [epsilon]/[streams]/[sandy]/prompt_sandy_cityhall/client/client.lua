local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1
L0_1 = GetResourceState
L1_1 = "ox_lib"
L0_1 = L0_1(L1_1)
L0_1 = "started" == L0_1
L1_1 = GetInteriorAtCoords
L2_1 = 1753.6223
L3_1 = 3804.645
L4_1 = 35.4474
L1_1 = L1_1(L2_1, L3_1, L4_1)
if not L0_1 then
  L2_1 = print
  L3_1 = "[PROMPT ELEVATOR DISABLED - ox_lib not found]"
  L2_1(L3_1)
  L2_1 = ActivateInteriorEntitySet
  L3_1 = L1_1
  L4_1 = "static_elevator"
  L2_1(L3_1, L4_1)
  L2_1 = RefreshInterior
  L3_1 = L1_1
  L2_1(L3_1)
  return
end
L2_1 = Config
L2_1 = L2_1.FunctionalElevator
if L2_1 then
  L2_1 = DeactivateInteriorEntitySet
  L3_1 = L1_1
  L4_1 = "static_elevator"
  L2_1(L3_1, L4_1)
  L2_1 = RefreshInterior
  L3_1 = L1_1
  L2_1(L3_1)
  L2_1 = nil
  L3_1 = nil
  L4_1 = nil
  L5_1 = {}
  L6_1 = false
  L7_1 = {}
  L8_1 = {}
  function L9_1()
    local L0_2, L1_2, L2_2
    L0_2 = GlobalState
    L0_2 = L0_2.elevator
    if not L0_2 then
      L0_2 = TriggerServerEvent
      L1_2 = "elevator:initializeState"
      L2_2 = {}
      L2_2.currentFloor = 1
      L2_2.targetFloor = nil
      L2_2.isMoving = false
      L2_2.doorsOpen = true
      L0_2(L1_2, L2_2)
    end
  end
  function L10_1(A0_2, A1_2, A2_2, A3_2, A4_2)
    local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
    if not A1_2 or not A2_2 then
      return
    end
    L5_2 = GetEntityCoords
    L6_2 = A1_2
    L5_2 = L5_2(L6_2)
    L6_2 = playDoorElevatorSound
    L7_2 = A0_2
    L8_2 = L5_2
    L9_2 = A4_2
    L6_2(L7_2, L8_2, L9_2)
    if A0_2 then
      L6_2 = Config
      L6_2 = L6_2.Elevator
      L6_2 = L6_2.door
      L6_2 = L6_2.animations
      L6_2 = L6_2.open
      L6_2 = L6_2.name
      if L6_2 then
        goto lbl_30
      end
    end
    L6_2 = Config
    L6_2 = L6_2.Elevator
    L6_2 = L6_2.door
    L6_2 = L6_2.animations
    L6_2 = L6_2.close
    L6_2 = L6_2.name
    ::lbl_30::
    L7_2 = lib
    L7_2 = L7_2.requestAnimDict
    L8_2 = Config
    L8_2 = L8_2.Elevator
    L8_2 = L8_2.door
    L8_2 = L8_2.animations
    L8_2 = L8_2.dict
    L7_2(L8_2)
    L7_2 = PlayEntityAnim
    L8_2 = A1_2
    L9_2 = L6_2
    L10_2 = Config
    L10_2 = L10_2.Elevator
    L10_2 = L10_2.door
    L10_2 = L10_2.animations
    L10_2 = L10_2.dict
    L11_2 = 8.0
    L12_2 = false
    L13_2 = true
    L14_2 = false
    L15_2 = 0.0
    L16_2 = 0
    L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
    L7_2 = 900
    L8_2 = GetGameTimer
    L8_2 = L8_2()
    L9_2 = CreateThread
    function L10_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3
      while true do
        L0_3 = GetGameTimer
        L0_3 = L0_3()
        L1_3 = L8_2
        L0_3 = L0_3 - L1_3
        L1_3 = L7_2
        if not (L0_3 < L1_3) then
          break
        end
        L0_3 = GetGameTimer
        L0_3 = L0_3()
        L1_3 = L8_2
        L0_3 = L0_3 - L1_3
        L1_3 = L7_2
        L0_3 = L0_3 / L1_3
        L1_3 = A3_2
        if L1_3 then
          L1_3 = Config
          L1_3 = L1_3.Elevator
          L1_3 = L1_3.door
          L1_3 = L1_3.offset
          L2_3 = A0_2
          if L2_3 then
            L2_3 = -0.8
            if L2_3 then
              goto lbl_31
            end
          end
          L2_3 = 0.0
          ::lbl_31::
          L3_3 = vector3
          L4_3 = L1_3.x
          L5_3 = L2_3 * L0_3
          L4_3 = L4_3 + L5_3
          L5_3 = L1_3.y
          L6_3 = L1_3.z
          L3_3 = L3_3(L4_3, L5_3, L6_3)
          L4_3 = DetachEntity
          L5_3 = A2_2
          L6_3 = false
          L7_3 = false
          L4_3(L5_3, L6_3, L7_3)
          L4_3 = AttachEntityToEntity
          L5_3 = A2_2
          L6_3 = A3_2
          L7_3 = 0
          L8_3 = L3_3.x
          L9_3 = L3_3.y
          L10_3 = L3_3.z
          L11_3 = 0.0
          L12_3 = 0.0
          L13_3 = 0.0
          L14_3 = false
          L15_3 = false
          L16_3 = true
          L17_3 = false
          L18_3 = 2
          L19_3 = true
          L4_3(L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
        else
          L1_3 = GetEntityCoords
          L2_3 = A1_2
          L1_3 = L1_3(L2_3)
          L2_3 = nil
          L3_3 = pairs
          L4_3 = Config
          L4_3 = L4_3.Elevator
          L4_3 = L4_3.floorDoors
          L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
          for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
            L9_3 = L7_1
            L9_3 = L9_3[L7_3]
            L10_3 = A1_2
            if L9_3 == L10_3 then
              L2_3 = L8_3
              break
            end
          end
          if L2_3 then
            L3_3 = A0_2
            if L3_3 then
              L3_3 = L2_3.offset
              if L3_3 then
                goto lbl_96
              end
            end
            L3_3 = vector3
            L4_3 = 0.0
            L5_3 = 0.0
            L6_3 = 0.0
            L3_3 = L3_3(L4_3, L5_3, L6_3)
            ::lbl_96::
            L4_3 = vector3
            L5_3 = math
            L5_3 = L5_3.lerp
            L6_3 = 0
            L7_3 = L3_3.x
            L8_3 = L0_3
            L5_3 = L5_3(L6_3, L7_3, L8_3)
            L6_3 = math
            L6_3 = L6_3.lerp
            L7_3 = 0
            L8_3 = L3_3.y
            L9_3 = L0_3
            L6_3 = L6_3(L7_3, L8_3, L9_3)
            L7_3 = 0.0
            L4_3 = L4_3(L5_3, L6_3, L7_3)
            L5_3 = SetEntityCoords
            L6_3 = A2_2
            L7_3 = L1_3.x
            L8_3 = L4_3.x
            L7_3 = L7_3 + L8_3
            L8_3 = L1_3.y
            L9_3 = L4_3.y
            L8_3 = L8_3 + L9_3
            L9_3 = L1_3.z
            L10_3 = false
            L11_3 = false
            L12_3 = false
            L13_3 = false
            L5_3(L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3)
          end
        end
        L1_3 = Wait
        L2_3 = 0
        L1_3(L2_3)
      end
    end
    L9_2(L10_2)
    L9_2 = Wait
    L10_2 = L7_2
    L9_2(L10_2)
  end
  function L11_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
    L1_2 = Config
    L1_2 = L1_2.Elevator
    L1_2 = L1_2.floors
    L2_2 = 1
    L3_2 = math
    L3_2 = L3_2.abs
    L4_2 = L1_2[1]
    L4_2 = L4_2.coords
    L4_2 = L4_2.z
    L4_2 = L4_2 - A0_2
    L3_2 = L3_2(L4_2)
    L4_2 = 2
    L5_2 = #L1_2
    L6_2 = 1
    for L7_2 = L4_2, L5_2, L6_2 do
      L8_2 = math
      L8_2 = L8_2.abs
      L9_2 = L1_2[L7_2]
      L9_2 = L9_2.coords
      L9_2 = L9_2.z
      L9_2 = L9_2 - A0_2
      L8_2 = L8_2(L9_2)
      if L3_2 > L8_2 then
        L3_2 = L8_2
        L2_2 = L7_2
      end
    end
    return L2_2
  end
  getNearestFloor = L11_1
  function L11_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
    L1_2 = L2_1
    if L1_2 then
      return
    end
    L1_2 = Config
    L1_2 = L1_2.Elevator
    L1_2 = L1_2.floors
    L1_2 = L1_2[A0_2]
    if not L1_2 then
      return
    end
    while true do
      L2_2 = IsModelValid
      L3_2 = joaat
      L4_2 = Config
      L4_2 = L4_2.Elevator
      L4_2 = L4_2.model
      L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2 = L3_2(L4_2)
      L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
      if L2_2 then
        break
      end
      L2_2 = Wait
      L3_2 = 0
      L2_2(L3_2)
    end
    L2_2 = lib
    L2_2 = L2_2.requestModel
    L3_2 = Config
    L3_2 = L3_2.Elevator
    L3_2 = L3_2.model
    L2_2(L3_2)
    L2_2 = CreateObjectNoOffset
    L3_2 = joaat
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.model
    L3_2 = L3_2(L4_2)
    L4_2 = L1_2.coords
    L4_2 = L4_2.x
    L5_2 = L1_2.coords
    L5_2 = L5_2.y
    L6_2 = L1_2.coords
    L6_2 = L6_2.z
    L7_2 = false
    L8_2 = false
    L9_2 = false
    L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
    L2_1 = L2_2
    L2_2 = SetEntityRotation
    L3_2 = L2_1
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.position
    L4_2 = L4_2.rotation
    L4_2 = L4_2.x
    L5_2 = Config
    L5_2 = L5_2.Elevator
    L5_2 = L5_2.position
    L5_2 = L5_2.rotation
    L5_2 = L5_2.y
    L6_2 = Config
    L6_2 = L6_2.Elevator
    L6_2 = L6_2.position
    L6_2 = L6_2.rotation
    L6_2 = L6_2.z
    L7_2 = 2
    L8_2 = true
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2)
    L2_2 = GetEntityCoords
    L3_2 = L2_1
    L2_2 = L2_2(L3_2)
    L3_2 = Config
    L3_2 = L3_2.Elevator
    L3_2 = L3_2.door
    L3_2 = L3_2.offset
    L4_2 = L2_2 + L3_2
    L5_2 = lib
    L5_2 = L5_2.requestModel
    L6_2 = Config
    L6_2 = L6_2.Elevator
    L6_2 = L6_2.door
    L6_2 = L6_2.model
    L5_2(L6_2)
    L5_2 = CreateObject
    L6_2 = joaat
    L7_2 = Config
    L7_2 = L7_2.Elevator
    L7_2 = L7_2.door
    L7_2 = L7_2.model
    L6_2 = L6_2(L7_2)
    L7_2 = L4_2.x
    L8_2 = L4_2.y
    L9_2 = L4_2.z
    L10_2 = false
    L11_2 = false
    L12_2 = false
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L3_1 = L5_2
    L5_2 = SetEntityRotation
    L6_2 = L3_1
    L7_2 = Config
    L7_2 = L7_2.Elevator
    L7_2 = L7_2.position
    L7_2 = L7_2.rotation
    L7_2 = L7_2.x
    L8_2 = Config
    L8_2 = L8_2.Elevator
    L8_2 = L8_2.position
    L8_2 = L8_2.rotation
    L8_2 = L8_2.y
    L9_2 = Config
    L9_2 = L9_2.Elevator
    L9_2 = L9_2.position
    L9_2 = L9_2.rotation
    L9_2 = L9_2.z
    L10_2 = 2
    L11_2 = true
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
    L5_2 = lib
    L5_2 = L5_2.requestModel
    L6_2 = Config
    L6_2 = L6_2.Elevator
    L6_2 = L6_2.door
    L6_2 = L6_2.collisionModel
    L5_2(L6_2)
    L5_2 = CreateObject
    L6_2 = joaat
    L7_2 = Config
    L7_2 = L7_2.Elevator
    L7_2 = L7_2.door
    L7_2 = L7_2.collisionModel
    L6_2 = L6_2(L7_2)
    L7_2 = L4_2.x
    L8_2 = L4_2.y
    L9_2 = L4_2.z
    L10_2 = false
    L11_2 = false
    L12_2 = true
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L4_1 = L5_2
    L5_2 = SetEntityRotation
    L6_2 = L4_1
    L7_2 = Config
    L7_2 = L7_2.Elevator
    L7_2 = L7_2.position
    L7_2 = L7_2.rotation
    L7_2 = L7_2.x
    L8_2 = Config
    L8_2 = L8_2.Elevator
    L8_2 = L8_2.position
    L8_2 = L8_2.rotation
    L8_2 = L8_2.y
    L9_2 = Config
    L9_2 = L9_2.Elevator
    L9_2 = L9_2.position
    L9_2 = L9_2.rotation
    L9_2 = L9_2.z
    L10_2 = 2
    L11_2 = true
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
    L5_2 = SetEntityCollision
    L6_2 = L3_1
    L7_2 = false
    L8_2 = false
    L5_2(L6_2, L7_2, L8_2)
    L5_2 = SetEntityCollision
    L6_2 = L4_1
    L7_2 = true
    L8_2 = true
    L5_2(L6_2, L7_2, L8_2)
    L5_2 = FreezeEntityPosition
    L6_2 = L4_1
    L7_2 = true
    L5_2(L6_2, L7_2)
    L5_2 = SetEntityVisible
    L6_2 = L4_1
    L7_2 = false
    L5_2(L6_2, L7_2)
    L5_2 = AttachEntityToEntity
    L6_2 = L3_1
    L7_2 = L2_1
    L8_2 = 0
    L9_2 = L3_2.x
    L10_2 = L3_2.y
    L11_2 = L3_2.z
    L12_2 = 0.0
    L13_2 = 0.0
    L14_2 = 0.0
    L15_2 = false
    L16_2 = false
    L17_2 = false
    L18_2 = false
    L19_2 = 2
    L20_2 = true
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
    L5_2 = GlobalState
    L5_2 = L5_2.elevator
    if L5_2 then
      L5_2 = GlobalState
      L5_2 = L5_2.elevator
      L5_2 = L5_2.doorsOpen
      if L5_2 then
        L5_2 = Config
        L5_2 = L5_2.Elevator
        L5_2 = L5_2.door
        L5_2 = L5_2.animations
        L5_2 = L5_2.open
        L5_2 = L5_2.collisionOffset
        if L5_2 then
          goto lbl_219
        end
      end
    end
    L5_2 = Config
    L5_2 = L5_2.Elevator
    L5_2 = L5_2.door
    L5_2 = L5_2.animations
    L5_2 = L5_2.close
    L5_2 = L5_2.collisionOffset
    ::lbl_219::
    L6_2 = AttachEntityToEntity
    L7_2 = L4_1
    L8_2 = L2_1
    L9_2 = 0
    L10_2 = L3_2.x
    L11_2 = L5_2.x
    L10_2 = L10_2 + L11_2
    L11_2 = L3_2.y
    L12_2 = L5_2.y
    L11_2 = L11_2 + L12_2
    L12_2 = L3_2.z
    L13_2 = L5_2.z
    L12_2 = L12_2 + L13_2
    L13_2 = 0.0
    L14_2 = 0.0
    L15_2 = 0.0
    L16_2 = false
    L17_2 = false
    L18_2 = true
    L19_2 = false
    L20_2 = 2
    L21_2 = true
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
    L6_2 = createFloorDoors
    L6_2()
    L6_2 = GlobalState
    L6_2 = L6_2.elevator
    if L6_2 then
      L6_2 = L10_1
      L7_2 = GlobalState
      L7_2 = L7_2.elevator
      L7_2 = L7_2.doorsOpen
      L8_2 = L3_1
      L9_2 = L4_1
      L10_2 = L2_1
      L11_2 = GlobalState
      L11_2 = L11_2.elevator
      L11_2 = L11_2.currentFloor
      L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
      L6_2 = GlobalState
      L6_2 = L6_2.elevator
      L6_2 = L6_2.currentFloor
      L7_2 = L7_1
      L7_2 = L7_2[L6_2]
      if L7_2 then
        L7_2 = L8_1
        L7_2 = L7_2[L6_2]
        if L7_2 then
          L7_2 = L10_1
          L8_2 = GlobalState
          L8_2 = L8_2.elevator
          L8_2 = L8_2.doorsOpen
          L9_2 = L7_1
          L9_2 = L9_2[L6_2]
          L10_2 = L8_1
          L10_2 = L10_2[L6_2]
          L11_2 = nil
          L12_2 = GlobalState
          L12_2 = L12_2.elevator
          L12_2 = L12_2.currentFloor
          L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
        end
      end
    end
  end
  function L12_1()
    local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
    L0_2 = pairs
    L1_2 = Config
    L1_2 = L1_2.Elevator
    L1_2 = L1_2.floorDoors
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = lib
      L6_2 = L6_2.requestModel
      L7_2 = Config
      L7_2 = L7_2.Elevator
      L7_2 = L7_2.door
      L7_2 = L7_2.model
      L6_2(L7_2)
      L6_2 = CreateObjectNoOffset
      L7_2 = joaat
      L8_2 = Config
      L8_2 = L8_2.Elevator
      L8_2 = L8_2.door
      L8_2 = L8_2.model
      L7_2 = L7_2(L8_2)
      L8_2 = L5_2.coords
      L8_2 = L8_2.x
      L9_2 = L5_2.coords
      L9_2 = L9_2.y
      L10_2 = L5_2.coords
      L10_2 = L10_2.z
      L11_2 = false
      L12_2 = false
      L13_2 = false
      L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
      L7_2 = lib
      L7_2 = L7_2.requestModel
      L8_2 = Config
      L8_2 = L8_2.Elevator
      L8_2 = L8_2.door
      L8_2 = L8_2.collisionModel
      L7_2(L8_2)
      L7_2 = CreateObjectNoOffset
      L8_2 = joaat
      L9_2 = Config
      L9_2 = L9_2.Elevator
      L9_2 = L9_2.door
      L9_2 = L9_2.collisionModel
      L8_2 = L8_2(L9_2)
      L9_2 = L5_2.coords
      L9_2 = L9_2.x
      L10_2 = L5_2.coords
      L10_2 = L10_2.y
      L11_2 = L5_2.coords
      L11_2 = L11_2.z
      L12_2 = false
      L13_2 = false
      L14_2 = false
      L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L8_2 = SetEntityRotation
      L9_2 = L6_2
      L10_2 = L5_2.rotation
      L10_2 = L10_2.x
      L11_2 = L5_2.rotation
      L11_2 = L11_2.y
      L12_2 = L5_2.rotation
      L12_2 = L12_2.z
      L13_2 = 2
      L14_2 = true
      L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L8_2 = SetEntityRotation
      L9_2 = L7_2
      L10_2 = L5_2.rotation
      L10_2 = L10_2.x
      L11_2 = L5_2.rotation
      L11_2 = L11_2.y
      L12_2 = L5_2.rotation
      L12_2 = L12_2.z
      L13_2 = 2
      L14_2 = true
      L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L8_2 = SetEntityCollision
      L9_2 = L6_2
      L10_2 = false
      L11_2 = false
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = SetEntityCollision
      L9_2 = L7_2
      L10_2 = true
      L11_2 = true
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = FreezeEntityPosition
      L9_2 = L7_2
      L10_2 = true
      L8_2(L9_2, L10_2)
      L8_2 = FreezeEntityPosition
      L9_2 = L6_2
      L10_2 = true
      L8_2(L9_2, L10_2)
      L8_2 = SetEntityVisible
      L9_2 = L7_2
      L10_2 = false
      L8_2(L9_2, L10_2)
      L8_2 = L7_1
      L8_2[L4_2] = L6_2
      L8_2 = L8_1
      L8_2[L4_2] = L7_2
    end
  end
  createFloorDoors = L12_1
  function L12_1()
    local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
    L0_2 = L5_1
    if L0_2 then
      L0_2 = ipairs
      L1_2 = L5_1
      L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
      for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
        L6_2 = DeleteEntity
        L7_2 = L5_2
        L6_2(L7_2)
      end
    end
    L0_2 = {}
    L5_1 = L0_2
    L0_2 = GlobalState
    L0_2 = L0_2.elevator
    if L0_2 then
      L0_2 = GlobalState
      L0_2 = L0_2.elevator
      L0_2 = L0_2.currentFloor
      if L0_2 then
        goto lbl_27
      end
    end
    L0_2 = 1
    ::lbl_27::
    L1_2 = ipairs
    L2_2 = Config
    L2_2 = L2_2.Elevator
    L2_2 = L2_2.indicators
    L2_2 = L2_2.positions
    L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
    for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
      L7_2 = lib
      L7_2 = L7_2.requestModel
      L8_2 = Config
      L8_2 = L8_2.Elevator
      L8_2 = L8_2.indicators
      L8_2 = L8_2.model
      L7_2(L8_2)
      L7_2 = CreateObject
      L8_2 = joaat
      L9_2 = Config
      L9_2 = L9_2.Elevator
      L9_2 = L9_2.indicators
      L9_2 = L9_2.model
      L8_2 = L8_2(L9_2)
      L9_2 = L6_2.coords
      L9_2 = L9_2.x
      L10_2 = L6_2.coords
      L10_2 = L10_2.y
      L11_2 = L6_2.coords
      L11_2 = L11_2.z
      L12_2 = false
      L13_2 = false
      L14_2 = false
      L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L8_2 = Config
      L8_2 = L8_2.Elevator
      L8_2 = L8_2.indicators
      L8_2 = L8_2.positions
      L8_2 = L8_2[L0_2]
      L8_2 = L8_2.rotation
      L9_2 = SetEntityRotation
      L10_2 = L7_2
      L11_2 = L8_2.x
      L12_2 = L8_2.y
      L13_2 = L8_2.z
      L14_2 = 2
      L15_2 = true
      L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
      L9_2 = FreezeEntityPosition
      L10_2 = L7_2
      L11_2 = true
      L9_2(L10_2, L11_2)
      L9_2 = table
      L9_2 = L9_2.insert
      L10_2 = L5_1
      L11_2 = L7_2
      L9_2(L10_2, L11_2)
    end
  end
  function L13_1(A0_2, A1_2, A2_2)
    local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
    L3_2 = L5_1
    if L3_2 then
      L3_2 = L5_1
      L3_2 = #L3_2
      if 0 ~= L3_2 then
        goto lbl_9
      end
    end
    do return end
    ::lbl_9::
    L3_2 = GlobalState
    L3_2 = L3_2.elevator
    L3_2 = L3_2.currentFloor
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.indicators
    L4_2 = L4_2.positions
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.rotation
    L5_2 = Config
    L5_2 = L5_2.Elevator
    L5_2 = L5_2.indicators
    L5_2 = L5_2.positions
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.rotation
    if not L5_2 then
      return
    end
    L6_2 = A2_2 or L6_2
    if not A2_2 then
      L6_2 = GetNetworkTimeAccurate
      L6_2 = L6_2()
    end
    L7_2 = bezier
    L8_2 = 0.42
    L9_2 = 0
    L10_2 = 0.58
    L11_2 = 1
    L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2)
    function L8_2(A0_3)
      local L1_3, L2_3, L3_3, L4_3
      L1_3 = math
      L1_3 = L1_3.lerp
      L2_3 = L4_2.y
      L3_3 = L5_2.y
      L4_3 = A0_3
      return L1_3(L2_3, L3_3, L4_3)
    end
    L9_2 = CreateThread
    function L10_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
      while true do
        L0_3 = GetNetworkTimeAccurate
        L0_3 = L0_3()
        L1_3 = math
        L1_3 = L1_3.min
        L2_3 = L6_2
        L2_3 = L0_3 - L2_3
        L3_3 = A1_2
        L2_3 = L2_3 / L3_3
        L3_3 = 1.0
        L1_3 = L1_3(L2_3, L3_3)
        if L1_3 >= 1.0 then
          L2_3 = ipairs
          L3_3 = L5_1
          L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
          for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
            L8_3 = SetEntityRotation
            L9_3 = L7_3
            L10_3 = L5_2.x
            L11_3 = L5_2.y
            L12_3 = L5_2.z
            L13_3 = 2
            L14_3 = true
            L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
          end
          break
        end
        L2_3 = L7_2
        L3_3 = L1_3
        L2_3 = L2_3(L3_3)
        L3_3 = L8_2
        L4_3 = L2_3
        L3_3 = L3_3(L4_3)
        L4_3 = ipairs
        L5_3 = L5_1
        L4_3, L5_3, L6_3, L7_3 = L4_3(L5_3)
        for L8_3, L9_3 in L4_3, L5_3, L6_3, L7_3 do
          L10_3 = vector3
          L11_3 = L4_2.x
          L12_3 = L3_3
          L13_3 = L4_2.z
          L10_3 = L10_3(L11_3, L12_3, L13_3)
          L11_3 = SetEntityRotation
          L12_3 = L9_3
          L13_3 = L10_3.x
          L14_3 = L10_3.y
          L15_3 = L10_3.z
          L16_3 = 2
          L17_3 = true
          L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
        end
        L4_3 = Wait
        L5_3 = 0
        L4_3(L5_3)
      end
    end
    L9_2(L10_2)
  end
  L14_1 = lib
  L14_1 = L14_1.points
  L14_1 = L14_1.new
  L15_1 = {}
  L16_1 = Config
  L16_1 = L16_1.Elevator
  L16_1 = L16_1.spawnZone
  L16_1 = L16_1.coords
  L15_1.coords = L16_1
  L16_1 = Config
  L16_1 = L16_1.Elevator
  L16_1 = L16_1.spawnZone
  L16_1 = L16_1.radius
  L15_1.distance = L16_1
  function L16_1()
    local L0_2, L1_2, L2_2, L3_2
    L0_2 = cache
    L0_2 = L0_2.coords
    L1_2 = getNearestFloor
    L2_2 = L0_2.z
    L1_2 = L1_2(L2_2)
    L2_2 = L11_1
    L3_2 = GlobalState
    L3_2 = L3_2.elevator
    L3_2 = L3_2.currentFloor
    if not L3_2 then
      L3_2 = L1_2
    end
    L2_2(L3_2)
    L2_2 = L12_1
    L2_2()
  end
  L15_1.onEnter = L16_1
  function L16_1()
    local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
    L0_2 = L2_1
    if L0_2 then
      L0_2 = DeleteEntity
      L1_2 = L2_1
      L0_2(L1_2)
      L0_2 = DeleteEntity
      L1_2 = L3_1
      L0_2(L1_2)
      L0_2 = DeleteEntity
      L1_2 = L4_1
      L0_2(L1_2)
      L0_2 = nil
      L2_1 = L0_2
      L0_2 = nil
      L3_1 = L0_2
      L0_2 = nil
      L4_1 = L0_2
    end
    L0_2 = L5_1
    if L0_2 then
      L0_2 = ipairs
      L1_2 = L5_1
      L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
      for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
        L6_2 = DeleteEntity
        L7_2 = L5_2
        L6_2(L7_2)
      end
      L0_2 = {}
      L5_1 = L0_2
    end
    L0_2 = pairs
    L1_2 = L7_1
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = DeleteEntity
      L7_2 = L5_2
      L6_2(L7_2)
      L6_2 = L8_1
      L6_2 = L6_2[L4_2]
      if L6_2 then
        L6_2 = DeleteEntity
        L7_2 = L8_1
        L7_2 = L7_2[L4_2]
        L6_2(L7_2)
      end
    end
    L0_2 = {}
    L7_1 = L0_2
    L0_2 = {}
    L8_1 = L0_2
  end
  L15_1.onExit = L16_1
  L14_1 = L14_1(L15_1)
  function L15_1(A0_2, A1_2)
    local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
    L2_2 = math
    L2_2 = L2_2.abs
    L3_2 = A1_2 - A0_2
    L2_2 = L2_2(L3_2)
    L3_2 = math
    L3_2 = L3_2.abs
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.floors
    L4_2 = L4_2[2]
    L4_2 = L4_2.coords
    L4_2 = L4_2.z
    L5_2 = Config
    L5_2 = L5_2.Elevator
    L5_2 = L5_2.floors
    L5_2 = L5_2[1]
    L5_2 = L5_2.coords
    L5_2 = L5_2.z
    L4_2 = L4_2 - L5_2
    L3_2 = L3_2(L4_2)
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.moveSpeed
    L4_2 = L3_2 / L4_2
    L4_2 = L4_2 * 5000
    L5_2 = L4_2 * L2_2
    L6_2 = math
    L6_2 = L6_2.max
    L7_2 = 3000
    L8_2 = math
    L8_2 = L8_2.min
    L9_2 = L5_2
    L10_2 = 15000
    L8_2, L9_2, L10_2 = L8_2(L9_2, L10_2)
    L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
    L5_2 = L6_2
    return L5_2
  end
  calculateElevatorDuration = L15_1
  function L15_1(A0_2, A1_2)
    local L2_2, L3_2, L4_2, L5_2, L6_2
    L2_2 = calculateElevatorDuration
    L3_2 = A1_2
    L4_2 = A0_2
    L2_2 = L2_2(L3_2, L4_2)
    L3_2 = {}
    L3_2.currentFloor = A1_2
    L3_2.targetFloor = A0_2
    L3_2.isMoving = true
    L3_2.doorsOpen = false
    L3_2.duration = L2_2
    L4_2 = Config
    L4_2 = L4_2.EnablePlayerAnimations
    if L4_2 then
      L4_2 = GetPlayerServerId
      L5_2 = PlayerId
      L5_2, L6_2 = L5_2()
      L4_2 = L4_2(L5_2, L6_2)
      if L4_2 then
        goto lbl_23
      end
    end
    L4_2 = nil
    ::lbl_23::
    L3_2.serverId = L4_2
    L4_2 = playSelectFloorSound
    L4_2()
    L4_2 = TriggerServerEvent
    L5_2 = "elevator:updateState"
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
  end
  SelectFloor = L15_1
  function L15_1(A0_2, A1_2)
    local L2_2, L3_2, L4_2, L5_2, L6_2
    L2_2 = calculateElevatorDuration
    L3_2 = GlobalState
    L3_2 = L3_2.elevator
    L3_2 = L3_2.currentFloor
    L4_2 = A1_2
    L2_2 = L2_2(L3_2, L4_2)
    L3_2 = {}
    L4_2 = GlobalState
    L4_2 = L4_2.elevator
    L4_2 = L4_2.currentFloor
    L3_2.currentFloor = L4_2
    L3_2.targetFloor = A1_2
    L3_2.isMoving = true
    L3_2.doorsOpen = false
    L3_2.duration = L2_2
    L4_2 = TriggerServerEvent
    L5_2 = "elevator:updateState"
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
    L4_2 = Config
    L4_2 = L4_2.EnablePlayerAnimations
    if L4_2 then
      L4_2 = playPlayerButtonAnimation
      L5_2 = A1_2
      L4_2(L5_2)
      L4_2 = Wait
      L5_2 = 1300
      L4_2(L5_2)
    end
    L4_2 = playSelectFloorSound
    L5_2 = A0_2
    L4_2(L5_2)
  end
  CallElevator = L15_1
  L15_1 = AddEventHandler
  L16_1 = "onResourceStop"
  function L17_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
    L1_2 = GetCurrentResourceName
    L1_2 = L1_2()
    if L1_2 ~= A0_2 then
      return
    end
    L1_2 = L2_1
    if L1_2 then
      L1_2 = DeleteEntity
      L2_2 = L2_1
      L1_2(L2_2)
      L1_2 = DeleteEntity
      L2_2 = L3_1
      L1_2(L2_2)
      L1_2 = DeleteEntity
      L2_2 = L4_1
      L1_2(L2_2)
    end
    L1_2 = L5_1
    if L1_2 then
      L1_2 = ipairs
      L2_2 = L5_1
      L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
      for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
        L7_2 = DeleteEntity
        L8_2 = L6_2
        L7_2(L8_2)
      end
    end
    L1_2 = pairs
    L2_2 = L7_1
    L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
    for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
      L7_2 = DeleteEntity
      L8_2 = L6_2
      L7_2(L8_2)
      L7_2 = L8_1
      L7_2 = L7_2[L5_2]
      if L7_2 then
        L7_2 = DeleteEntity
        L8_2 = L8_1
        L8_2 = L8_2[L5_2]
        L7_2(L8_2)
      end
    end
    L1_2 = nil
    L2_1 = L1_2
    L1_2 = nil
    L3_1 = L1_2
    L1_2 = nil
    L4_1 = L1_2
    L1_2 = {}
    L5_1 = L1_2
    L1_2 = {}
    L7_1 = L1_2
    L1_2 = {}
    L8_1 = L1_2
    L1_2 = false
    L6_1 = L1_2
    isInsideElevator = false
  end
  L15_1(L16_1, L17_1)
  function L15_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
    L1_2 = L2_1
    if not L1_2 then
      return
    end
    L1_2 = GlobalState
    L1_2 = L1_2.elevator
    L1_2 = L1_2.currentFloor
    L2_2 = GetEntityCoords
    L3_2 = L2_1
    L2_2 = L2_2(L3_2)
    L3_2 = Config
    L3_2 = L3_2.Elevator
    L3_2 = L3_2.floors
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.coords
    L4_2 = calculateElevatorDuration
    L5_2 = L1_2
    L6_2 = A0_2
    L4_2 = L4_2(L5_2, L6_2)
    L5_2 = math
    L5_2 = L5_2.max
    L6_2 = 3000
    L7_2 = math
    L7_2 = L7_2.min
    L8_2 = L4_2
    L9_2 = 15000
    L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = L7_2(L8_2, L9_2)
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L4_2 = L5_2
    L5_2 = TranslateObjectCoordsCubicBezier
    L6_2 = L2_1
    L7_2 = L3_2
    L8_2 = L4_2
    L9_2 = Config
    L9_2 = L9_2.Elevator
    L9_2 = L9_2.bezierCurve
    L10_2 = L1_2
    L11_2 = "_to_"
    L12_2 = A0_2
    L10_2 = L10_2 .. L11_2 .. L12_2
    L11_2 = A0_2
    L12_2 = GetNetworkTimeAccurate
    L12_2 = L12_2()
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  end
  L16_1 = AddStateBagChangeHandler
  L17_1 = "elevator"
  L18_1 = nil
  function L19_1(A0_2, A1_2, A2_2, A3_2, A4_2)
    local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
    if A2_2 then
      L5_2 = L2_1
      if L5_2 then
        goto lbl_7
      end
    end
    do return end
    ::lbl_7::
    L5_2 = A2_2.targetFloor
    if L5_2 then
      L5_2 = A2_2.isMoving
      if L5_2 then
        L5_2 = L10_1
        L6_2 = false
        L7_2 = L3_1
        L8_2 = L4_1
        L9_2 = L2_1
        L10_2 = A2_2.currentFloor
        L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
        L6_2 = A2_2.currentFloor
        L5_2 = L7_1
        L5_2 = L5_2[L6_2]
        if L5_2 then
          L5_2 = L10_1
          L6_2 = false
          L8_2 = A2_2.currentFloor
          L7_2 = L7_1
          L7_2 = L7_2[L8_2]
          L9_2 = A2_2.currentFloor
          L8_2 = L8_1
          L8_2 = L8_2[L9_2]
          L9_2 = nil
          L10_2 = A2_2.currentFloor
          L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
        end
        L5_2 = A2_2.currentFloor
        L6_2 = A2_2.targetFloor
        if L5_2 ~= L6_2 then
          L5_2 = calculateElevatorDuration
          L6_2 = A2_2.currentFloor
          L7_2 = A2_2.targetFloor
          L5_2 = L5_2(L6_2, L7_2)
          L6_2 = GetNetworkTimeAccurate
          L6_2 = L6_2()
          L7_2 = CreateThread
          function L8_2()
            local L0_3, L1_3, L2_3, L3_3
            L0_3 = L13_1
            L1_3 = A2_2.targetFloor
            L2_3 = L5_2
            L3_3 = L6_2
            L0_3(L1_3, L2_3, L3_3)
            L0_3 = L15_1
            L1_3 = A2_2.targetFloor
            L0_3(L1_3)
          end
          L7_2(L8_2)
        end
    end
    else
      L5_2 = A2_2.isMoving
      if not L5_2 then
        L5_2 = A2_2.doorsOpen
        if L5_2 then
          L5_2 = playElevatorArrivalSound
          L6_2 = A2_2.currentFloor
          L5_2(L6_2)
          L5_2 = L10_1
          L6_2 = true
          L7_2 = L3_1
          L8_2 = L4_1
          L9_2 = L2_1
          L10_2 = A2_2.currentFloor
          L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
          L6_2 = A2_2.currentFloor
          L5_2 = L7_1
          L5_2 = L5_2[L6_2]
          if L5_2 then
            L5_2 = L10_1
            L6_2 = true
            L8_2 = A2_2.currentFloor
            L7_2 = L7_1
            L7_2 = L7_2[L8_2]
            L9_2 = A2_2.currentFloor
            L8_2 = L8_1
            L8_2 = L8_2[L9_2]
            L9_2 = nil
            L10_2 = A2_2.currentFloor
            L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
          end
        end
      end
    end
  end
  L16_1(L17_1, L18_1, L19_1)
  L16_1 = lib
  L16_1 = L16_1.callback
  L16_1 = L16_1.register
  L17_1 = "elevator:playerDoorAnimation"
  function L18_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2
    L1_2 = cache
    L1_2 = L1_2.ped
    if A0_2 then
      L2_2 = "right_close"
      if L2_2 then
        goto lbl_9
      end
    end
    L2_2 = "right_open"
    ::lbl_9::
    L3_2 = Config
    L3_2 = L3_2.Elevator
    L3_2 = L3_2.position
    L3_2 = L3_2.rotation
    L3_2 = L3_2.z
    L4_2 = math
    L4_2 = L4_2.rad
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    L5_2 = Config
    L5_2 = L5_2.Elevator
    L5_2 = L5_2.door
    L5_2 = L5_2.playerAnimation
    L5_2 = L5_2.rawOffset
    L6_2 = {}
    L7_2 = L5_2.x
    L8_2 = math
    L8_2 = L8_2.cos
    L9_2 = L4_2
    L8_2 = L8_2(L9_2)
    L7_2 = L7_2 * L8_2
    L8_2 = L5_2.y
    L9_2 = math
    L9_2 = L9_2.sin
    L10_2 = L4_2
    L9_2 = L9_2(L10_2)
    L8_2 = L8_2 * L9_2
    L7_2 = L7_2 + L8_2
    L6_2.x = L7_2
    L7_2 = L5_2.y
    L8_2 = math
    L8_2 = L8_2.cos
    L9_2 = L4_2
    L8_2 = L8_2(L9_2)
    L7_2 = L7_2 * L8_2
    L8_2 = L5_2.x
    L9_2 = math
    L9_2 = L9_2.sin
    L10_2 = L4_2
    L9_2 = L9_2(L10_2)
    L8_2 = L8_2 * L9_2
    L7_2 = L7_2 - L8_2
    L6_2.y = L7_2
    L7_2 = L5_2.z
    L6_2.z = L7_2
    L7_2 = L5_2.w
    L6_2.w = L7_2
    L7_2 = GetEntityCoords
    L8_2 = L2_1
    L7_2 = L7_2(L8_2)
    L8_2 = GetEntityRotation
    L9_2 = L2_1
    L10_2 = 2
    L8_2 = L8_2(L9_2, L10_2)
    L9_2 = math
    L9_2 = L9_2.rad
    L10_2 = L8_2.z
    L9_2 = L9_2(L10_2)
    L10_2 = L7_2.x
    L11_2 = L6_2.x
    L12_2 = math
    L12_2 = L12_2.cos
    L13_2 = L9_2
    L12_2 = L12_2(L13_2)
    L11_2 = L11_2 * L12_2
    L12_2 = L6_2.y
    L13_2 = math
    L13_2 = L13_2.sin
    L14_2 = L9_2
    L13_2 = L13_2(L14_2)
    L12_2 = L12_2 * L13_2
    L11_2 = L11_2 - L12_2
    L10_2 = L10_2 + L11_2
    L11_2 = L7_2.y
    L12_2 = L6_2.y
    L13_2 = math
    L13_2 = L13_2.cos
    L14_2 = L9_2
    L13_2 = L13_2(L14_2)
    L12_2 = L12_2 * L13_2
    L13_2 = L6_2.x
    L14_2 = math
    L14_2 = L14_2.sin
    L15_2 = L9_2
    L14_2 = L14_2(L15_2)
    L13_2 = L13_2 * L14_2
    L12_2 = L12_2 + L13_2
    L11_2 = L11_2 + L12_2
    L12_2 = L7_2.z
    L13_2 = L6_2.z
    L12_2 = L12_2 + L13_2
    L13_2 = TaskPedSlideToCoord
    L14_2 = L1_2
    L15_2 = L10_2
    L16_2 = L11_2
    L17_2 = L12_2
    L18_2 = L6_2.w
    L19_2 = 500
    L13_2(L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
    L13_2 = GetGameTimer
    L13_2 = L13_2()
    while true do
      L14_2 = GetEntityCoords
      L15_2 = L1_2
      L14_2 = L14_2(L15_2)
      L15_2 = vector3
      L16_2 = L10_2
      L17_2 = L11_2
      L18_2 = L12_2
      L15_2 = L15_2(L16_2, L17_2, L18_2)
      L15_2 = L15_2 - L14_2
      L15_2 = #L15_2
      L16_2 = 0.1
      if L15_2 < L16_2 then
        break
      end
      L16_2 = GetGameTimer
      L16_2 = L16_2()
      L16_2 = L16_2 - L13_2
      L17_2 = 5000
      if L16_2 > L17_2 then
        break
      end
      L16_2 = Wait
      L17_2 = 0
      L16_2(L17_2)
    end
    L14_2 = SetEntityHeading
    L15_2 = L1_2
    L16_2 = L6_2.w
    L14_2(L15_2, L16_2)
    L14_2 = Wait
    L15_2 = 100
    L14_2(L15_2)
    L14_2 = TriggerServerEvent
    L15_2 = "prompt_elevator:send:animation"
    L16_2 = Config
    L16_2 = L16_2.Elevator
    L16_2 = L16_2.door
    L16_2 = L16_2.playerAnimation
    L16_2 = L16_2.dict
    L17_2 = L2_2
    L18_2 = L6_2.w
    L14_2(L15_2, L16_2, L17_2, L18_2)
    L14_2 = Wait
    L15_2 = 300
    L14_2(L15_2)
    L14_2 = true
    return L14_2
  end
  L16_1(L17_1, L18_1)
  L16_1 = RegisterNetEvent
  L17_1 = "prompt_elevator:sync:animation"
  L16_1(L17_1)
  L16_1 = AddEventHandler
  L17_1 = "prompt_elevator:sync:animation"
  function L18_1(A0_2, A1_2, A2_2, A3_2)
    local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
    L4_2 = GetRoomKeyFromEntity
    L5_2 = cache
    L5_2 = L5_2.ped
    L4_2 = L4_2(L5_2)
    if -1984934778 ~= L4_2 then
      return
    end
    L5_2 = GetPlayerPed
    L6_2 = GetPlayerFromServerId
    L7_2 = A0_2
    L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L6_2(L7_2)
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
    L6_2 = lib
    L6_2 = L6_2.requestAnimDict
    L7_2 = A1_2
    L6_2(L7_2)
    L6_2 = TaskPlayAnim
    L7_2 = L5_2
    L8_2 = A1_2
    L9_2 = A2_2
    L10_2 = 8.0
    L11_2 = -8.0
    L12_2 = -1
    L13_2 = 0
    L14_2 = 0
    L15_2 = false
    L16_2 = false
    L17_2 = A3_2
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
  L16_1(L17_1, L18_1)
  function L16_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
    L1_2 = A0_2 or nil
    if not A0_2 then
      L1_2 = GetEntityCoords
      L2_2 = L2_1
      L1_2 = L1_2(L2_2)
    end
    L2_2 = PlaySoundFromCoord
    L3_2 = -1
    L4_2 = "Pin_Centred"
    L5_2 = L1_2.x
    L6_2 = L1_2.y
    L7_2 = L1_2.z
    L8_2 = "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS"
    L9_2 = false
    L10_2 = 0
    L11_2 = false
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  end
  playSelectFloorSound = L16_1
  function L16_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
    L1_2 = Config
    L1_2 = L1_2.Elevator
    L1_2 = L1_2.sounds_roomid
    L1_2 = L1_2[A0_2]
    if not L1_2 then
      return
    end
    L1_2 = GetRoomKeyFromEntity
    L2_2 = cache
    L2_2 = L2_2.ped
    L1_2 = L1_2(L2_2)
    L2_2 = Config
    L2_2 = L2_2.Elevator
    L2_2 = L2_2.sounds_roomid
    L2_2 = L2_2[A0_2]
    if L1_2 ~= L2_2 and -1984934778 ~= L1_2 then
      return
    end
    while true do
      L2_2 = RequestScriptAudioBank
      L3_2 = "audiodirectory/custom_sounds"
      L4_2 = false
      L2_2 = L2_2(L3_2, L4_2)
      if L2_2 then
        break
      end
      L2_2 = Wait
      L3_2 = 0
      L2_2(L3_2)
    end
    L2_2 = GetSoundId
    L2_2 = L2_2()
    L3_2 = GetEntityCoords
    L4_2 = L2_1
    L3_2 = L3_2(L4_2)
    L4_2 = PlaySoundFromCoord
    L5_2 = -1
    L6_2 = "elevator_bell"
    L7_2 = L3_2.x
    L8_2 = L3_2.y
    L9_2 = L3_2.z
    L10_2 = "special_soundset"
    L11_2 = false
    L12_2 = 2
    L13_2 = false
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    L4_2 = ReleaseSoundId
    L5_2 = L2_2
    L4_2(L5_2)
  end
  playElevatorArrivalSound = L16_1
  function L16_1(A0_2, A1_2, A2_2)
    local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
    L3_2 = Config
    L3_2 = L3_2.Elevator
    L3_2 = L3_2.sounds_roomid
    L3_2 = L3_2[A2_2]
    if not L3_2 then
      return
    end
    L3_2 = GetRoomKeyFromEntity
    L4_2 = cache
    L4_2 = L4_2.ped
    L3_2 = L3_2(L4_2)
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.sounds_roomid
    L4_2 = L4_2[A2_2]
    if L3_2 ~= L4_2 and -1984934778 ~= L3_2 then
      return
    end
    if A0_2 then
      L4_2 = PlaySoundFromCoord
      L5_2 = -1
      L6_2 = "OPENING"
      L7_2 = A1_2.x
      L8_2 = A1_2.y
      L9_2 = A1_2.z
      L10_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
      L11_2 = true
      L12_2 = 0
      L13_2 = false
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    else
      L4_2 = PlaySoundFromCoord
      L5_2 = -1
      L6_2 = "CLOSING"
      L7_2 = A1_2.x
      L8_2 = A1_2.y
      L9_2 = A1_2.z
      L10_2 = "MP_PROPERTIES_ELEVATOR_DOORS"
      L11_2 = true
      L12_2 = 0
      L13_2 = false
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    end
  end
  playDoorElevatorSound = L16_1
  function L16_1(A0_2)
    local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
    L1_2 = cache
    L1_2 = L1_2.ped
    L2_2 = Config
    L2_2 = L2_2.Elevator
    L2_2 = L2_2.playerAskElevatorPositions
    L2_2 = L2_2[A0_2]
    if not L2_2 then
      return
    end
    L3_2 = TaskPedSlideToCoord
    L4_2 = L1_2
    L5_2 = L2_2.coords
    L5_2 = L5_2.x
    L6_2 = L2_2.coords
    L6_2 = L6_2.y
    L7_2 = L2_2.coords
    L7_2 = L7_2.z
    L8_2 = L2_2.heading
    L9_2 = 500
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
    L3_2 = GetGameTimer
    L3_2 = L3_2()
    while true do
      L4_2 = GetEntityCoords
      L5_2 = L1_2
      L4_2 = L4_2(L5_2)
      L5_2 = L2_2.coords
      L5_2 = L5_2 - L4_2
      L5_2 = #L5_2
      L6_2 = 0.1
      if L5_2 < L6_2 then
        break
      end
      L6_2 = GetGameTimer
      L6_2 = L6_2()
      L6_2 = L6_2 - L3_2
      L7_2 = 5000
      if L6_2 > L7_2 then
        break
      end
      L6_2 = Wait
      L7_2 = 0
      L6_2(L7_2)
    end
    L4_2 = SetEntityHeading
    L5_2 = L1_2
    L6_2 = L2_2.heading
    L4_2(L5_2, L6_2)
    L4_2 = Config
    L4_2 = L4_2.Elevator
    L4_2 = L4_2.buttonAnimation
    L5_2 = lib
    L5_2 = L5_2.requestAnimDict
    L6_2 = L4_2.dict
    L5_2(L6_2)
    L5_2 = TaskPlayAnim
    L6_2 = L1_2
    L7_2 = L4_2.dict
    L8_2 = L4_2.name
    L9_2 = 8.0
    L10_2 = -8.0
    L11_2 = -1
    L12_2 = 0
    L13_2 = 0
    L14_2 = false
    L15_2 = false
    L16_2 = false
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
  end
  playPlayerButtonAnimation = L16_1
else
  L2_1 = print
  L3_1 = "[PROMPT ELEVATOR DISABLED]"
  L2_1(L3_1)
  L2_1 = ActivateInteriorEntitySet
  L3_1 = L1_1
  L4_1 = "static_elevator"
  L2_1(L3_1, L4_1)
  L2_1 = RefreshInterior
  L3_1 = L1_1
  L2_1(L3_1)
end
