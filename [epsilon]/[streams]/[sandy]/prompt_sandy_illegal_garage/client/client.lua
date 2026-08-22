local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1
L0_1 = GetResourceState
L1_1 = "ox_lib"
L0_1 = L0_1(L1_1)
L0_1 = "started" == L0_1
L1_1 = L0_1 or L1_1
if L0_1 then
  L1_1 = lib
  L1_1 = nil ~= L1_1
end
function L2_1(...)
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.Debug
  if L0_2 then
    L0_2 = print
    L1_2 = ...
    L0_2(L1_2)
  end
end
L3_1 = vector3
L4_1 = 1996.6924
L5_1 = 3787.7312
L6_1 = 32.2094
L3_1 = L3_1(L4_1, L5_1, L6_1)
L4_1 = nil
function L5_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L4_1
  if L0_2 then
    L0_2 = L4_1
    if 0 ~= L0_2 then
      L0_2 = L4_1
      return L0_2
    end
  end
  L0_2 = 0
  while L0_2 < 50 do
    L1_2 = GetInteriorAtCoords
    L2_2 = L3_1.x
    L3_2 = L3_1.y
    L4_2 = L3_1.z
    L1_2 = L1_2(L2_2, L3_2, L4_2)
    L4_1 = L1_2
    L1_2 = L4_1
    if L1_2 then
      L1_2 = L4_1
      if 0 ~= L1_2 then
        L1_2 = L2_1
        L2_2 = "[ILLEGAL GARAGE] Interior found: "
        L3_2 = tostring
        L4_2 = L4_1
        L3_2 = L3_2(L4_2)
        L2_2 = L2_2 .. L3_2
        L1_2(L2_2)
        L1_2 = L4_1
        return L1_2
      end
    end
    L0_2 = L0_2 + 1
    L1_2 = Wait
    L2_2 = 100
    L1_2(L2_2)
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE WARNING] Could not find interior after 5 seconds"
  L1_2(L2_2)
  L1_2 = 0
  return L1_2
end
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L5_1
  L0_2 = L0_2()
  if 0 == L0_2 then
    return
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Enabling default entity set (InteriorId: "
  L3_2 = tostring
  L4_2 = L0_2
  L3_2 = L3_2(L4_2)
  L4_2 = ")"
  L2_2 = L2_2 .. L3_2 .. L4_2
  L1_2(L2_2)
  L1_2 = ActivateInteriorEntitySet
  L2_2 = L0_2
  L3_2 = "default"
  L1_2(L2_2, L3_2)
  L1_2 = RefreshInterior
  L2_2 = L0_2
  L1_2(L2_2)
end
enableDefault = L6_1
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L5_1
  L0_2 = L0_2()
  if 0 == L0_2 then
    return
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Disabling default entity set (InteriorId: "
  L3_2 = tostring
  L4_2 = L0_2
  L3_2 = L3_2(L4_2)
  L4_2 = ")"
  L2_2 = L2_2 .. L3_2 .. L4_2
  L1_2(L2_2)
  L1_2 = DeactivateInteriorEntitySet
  L2_2 = L0_2
  L3_2 = "default"
  L1_2(L2_2, L3_2)
  L1_2 = RefreshInterior
  L2_2 = L0_2
  L1_2(L2_2)
end
disableDefault = L6_1
L6_1 = L1_1 or L6_1
if L1_1 then
  L6_1 = Config
  L6_1 = L6_1.EnableAnimations
end
if not L6_1 then
  L7_1 = CreateThread
  function L8_1()
    local L0_2, L1_2
    L0_2 = enableDefault
    L0_2()
  end
  L7_1(L8_1)
  if not L0_1 then
    L7_1 = "ox_lib resource not started"
    if L7_1 then
      goto lbl_48
    end
  end
  if not L1_1 then
    L7_1 = "ox_lib failed to initialize (lib global missing)"
    if L7_1 then
      goto lbl_48
    end
  end
  L7_1 = "Config.EnableAnimations is false"
  ::lbl_48::
  L8_1 = L2_1
  L9_1 = "[ILLEGAL GARAGE ANIMS DISABLED] "
  L10_1 = L7_1
  L9_1 = L9_1 .. L10_1
  L8_1(L9_1)
  return
end
L7_1 = CreateThread
function L8_1()
  local L0_2, L1_2
  L0_2 = disableDefault
  L0_2()
end
L7_1(L8_1)
L7_1 = L2_1
L8_1 = "[ILLEGAL GARAGE ANIMS ENABLED] Using animated props instead of default entity set"
L7_1(L8_1)
L7_1 = useTarget
if L7_1 then
  L7_1 = L2_1
  L8_1 = "[ILLEGAL GARAGE] Target system detected: "
  L9_1 = TargetSystem
  L10_1 = " - using target interactions"
  L8_1 = L8_1 .. L9_1 .. L10_1
  L7_1(L8_1)
else
  L7_1 = L2_1
  L8_1 = "[ILLEGAL GARAGE] No target system available or disabled - using zone interactions"
  L7_1(L8_1)
end
L7_1 = {}
L8_1 = {}
L9_1 = {}
L10_1 = nil
L11_1 = false
L12_1 = {}
L13_1 = {}
L14_1 = {}
L15_1 = {}
function L16_1(A0_2)
  local L1_2, L2_2
  L1_2 = type
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L1_2 = "string" == L1_2 and "prompt_sandy_is_garage_rollup" == A0_2
  return L1_2
end
function L17_1()
  local L0_2, L1_2, L2_2
  L0_2 = GlobalState
  L0_2 = L0_2.ilegal_carwash
  if not L0_2 then
    L0_2 = TriggerServerEvent
    L1_2 = "ilegal_anims:initializeState"
    L2_2 = {}
    L0_2(L1_2, L2_2)
  end
end
function L18_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  if A0_2 and A1_2 then
    L5_2 = IsModelValid
    L6_2 = A0_2
    L5_2 = L5_2(L6_2)
    if L5_2 then
      goto lbl_19
    end
  end
  L5_2 = L2_1
  L6_2 = "[ILLEGAL GARAGE] Model not valid: "
  L7_2 = tostring
  L8_2 = A0_2
  L7_2 = L7_2(L8_2)
  L6_2 = L6_2 .. L7_2
  L5_2(L6_2)
  L5_2 = nil
  do return L5_2 end
  ::lbl_19::
  L5_2 = lib
  L5_2 = L5_2.requestModel
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  if L5_2 then
    L6_2 = type
    L7_2 = L5_2
    L6_2 = L6_2(L7_2)
    if "table" == L6_2 then
      L6_2 = L5_2.await
      if L6_2 then
        L6_2 = L5_2.await
        L6_2()
      end
    end
  end
  L6_2 = CreateObjectNoOffset
  L7_2 = joaat
  L8_2 = A0_2
  L7_2 = L7_2(L8_2)
  L8_2 = A1_2.x
  L9_2 = A1_2.y
  L10_2 = A1_2.z
  L11_2 = false
  L12_2 = false
  L13_2 = A3_2 or L13_2
  if not A3_2 then
    L13_2 = false
  end
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  if not L6_2 or 0 == L6_2 then
    L7_2 = L2_1
    L8_2 = "[ILLEGAL GARAGE] Failed to create entity for model: "
    L9_2 = tostring
    L10_2 = A0_2
    L9_2 = L9_2(L10_2)
    L8_2 = L8_2 .. L9_2
    L7_2(L8_2)
    L7_2 = nil
    return L7_2
  end
  L7_2 = SetEntityRotation
  L8_2 = L6_2
  L9_2 = A2_2.x
  L10_2 = A2_2.y
  L11_2 = A2_2.z
  L12_2 = 2
  L13_2 = true
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  L7_2 = FreezeEntityPosition
  L8_2 = L6_2
  L9_2 = true
  L7_2(L8_2, L9_2)
  if A3_2 then
    L7_2 = SetEntityCollision
    L8_2 = L6_2
    L9_2 = true
    L10_2 = true
    L7_2(L8_2, L9_2, L10_2)
    if A4_2 then
      L7_2 = FreezeEntityPosition
      L8_2 = L6_2
      L9_2 = true
      L7_2(L8_2, L9_2)
    end
    L7_2 = SetEntityVisible
    L8_2 = L6_2
    L9_2 = false
    L7_2(L8_2, L9_2)
  end
  L7_2 = SetModelAsNoLongerNeeded
  L8_2 = A0_2
  L7_2(L8_2)
  return L6_2
end
function L19_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = A0_2.name
  L1_2 = L7_1
  L1_2 = L1_2[L2_2]
  if L1_2 then
    L1_2 = DoesEntityExist
    L3_2 = A0_2.name
    L2_2 = L7_1
    L2_2 = L2_2[L3_2]
    L1_2 = L1_2(L2_2)
    if L1_2 then
      L2_2 = A0_2.name
      L1_2 = L7_1
      L1_2 = L1_2[L2_2]
      return L1_2
    end
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Creating prop: "
  L3_2 = A0_2.name
  L4_2 = " with model: "
  L5_2 = tostring
  L6_2 = A0_2.model
  L5_2 = L5_2(L6_2)
  L2_2 = L2_2 .. L3_2 .. L4_2 .. L5_2
  L1_2(L2_2)
  L1_2 = L18_1
  L2_2 = A0_2.model
  L3_2 = A0_2.coords
  L4_2 = A0_2.rotation
  L5_2 = false
  L6_2 = false
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2)
  if not L1_2 then
    L2_2 = L2_1
    L3_2 = "[ILLEGAL GARAGE ERROR] Failed to create entity for prop: "
    L4_2 = A0_2.name
    L3_2 = L3_2 .. L4_2
    L2_2(L3_2)
    L2_2 = nil
    return L2_2
  end
  L2_2 = L2_1
  L3_2 = "[ILLEGAL GARAGE] Successfully created prop entity: "
  L4_2 = A0_2.name
  L5_2 = " (entity: "
  L6_2 = tostring
  L7_2 = L1_2
  L6_2 = L6_2(L7_2)
  L7_2 = ")"
  L3_2 = L3_2 .. L4_2 .. L5_2 .. L6_2 .. L7_2
  L2_2(L3_2)
  L3_2 = A0_2.name
  L2_2 = L7_1
  L2_2[L3_2] = L1_2
  L2_2 = A0_2.collision
  if L2_2 then
    L2_2 = createCollision
    L3_2 = A0_2
    L2_2(L3_2)
  end
  L2_2 = A0_2.linkedProps
  if L2_2 then
    L2_2 = ipairs
    L3_2 = A0_2.linkedProps
    L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
    for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
      L8_2 = createLinkedProp
      L9_2 = L7_2
      L10_2 = A0_2.name
      L8_2(L9_2, L10_2)
    end
  end
  L2_2 = GlobalState
  L2_2 = L2_2.ilegal_carwash
  if L2_2 then
    L2_2 = GlobalState
    L2_2 = L2_2.ilegal_carwash
    L3_2 = A0_2.name
    L2_2 = L2_2[L3_2]
    if nil ~= L2_2 then
      L2_2 = SetTimeout
      L3_2 = 100
      function L4_2()
        local L0_3, L1_3, L2_3, L3_3, L4_3
        L0_3 = animateProp
        L1_3 = A0_2.name
        L2_3 = GlobalState
        L2_3 = L2_3.ilegal_carwash
        L3_3 = A0_2.name
        L2_3 = L2_3[L3_3]
        L3_3 = true
        L4_3 = true
        L0_3(L1_3, L2_3, L3_3, L4_3)
      end
      L2_2(L3_2, L4_2)
  end
  else
    L2_2 = A0_2.animations
    if L2_2 then
      L2_2 = A0_2.animations
      L2_2 = L2_2.static
      if L2_2 then
        L2_2 = SetTimeout
        L3_2 = 100
        function L4_2()
          local L0_3, L1_3, L2_3
          L0_3 = playStaticAnimation
          L1_3 = L1_2
          L2_3 = A0_2
          L0_3(L1_3, L2_3)
        end
        L2_2(L3_2, L4_2)
      end
    end
  end
  return L1_2
end
createProp = L19_1
function L19_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetPlayerServerId
  L2_2 = PlayerId
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2 = L2_2()
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2)
  L2_2 = nil
  L3_2 = nil
  L4_2 = type
  L5_2 = A0_2.label
  L4_2 = L4_2(L5_2)
  if "table" == L4_2 then
    L4_2 = A0_2.label
    L2_2 = L4_2.open
    L4_2 = A0_2.label
    L3_2 = L4_2.close
  else
    L4_2 = A0_2.label
    L2_2 = L4_2 or L2_2
    if not L4_2 then
      L4_2 = Config
      L4_2 = L4_2.Messages
      L2_2 = L4_2.open
    end
    L4_2 = A0_2.label
    L3_2 = L4_2 or L3_2
    if not L4_2 then
      L4_2 = Config
      L4_2 = L4_2.Messages
      L3_2 = L4_2.close
    end
  end
  L4_2 = {}
  L5_2 = GetCustomLabel
  L6_2 = A0_2.name
  L7_2 = L1_2
  L8_2 = L2_2
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  L4_2.open = L5_2
  L5_2 = GetCustomLabel
  L6_2 = A0_2.name
  L7_2 = L1_2
  L8_2 = L3_2
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  L4_2.close = L5_2
  return L4_2
end
getOxTargetLabels = L19_1
function L19_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L1_2 = A0_2.interactionZone
  if not L1_2 then
    return
  end
  L2_2 = A0_2.name
  L1_2 = L14_1
  L1_2 = L1_2[L2_2]
  if L1_2 then
    return
  end
  L1_2 = GetPlayerServerId
  L2_2 = PlayerId
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = L2_2()
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L2_2 = "ilegal_"
  L3_2 = A0_2.name
  L2_2 = L2_2 .. L3_2
  L3_2 = A0_2.originalName
  if not L3_2 then
    L3_2 = A0_2.name
  end
  L4_2 = Config
  L4_2 = L4_2.AutoOpen
  if L4_2 then
    L4_2 = L16_1
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
  end
  L5_2 = nil
  if L4_2 then
    L6_2 = {}
    L7_2 = {}
    L8_2 = L2_2
    L9_2 = "_unlock"
    L8_2 = L8_2 .. L9_2
    L7_2.name = L8_2
    L7_2.icon = "fas fa-lock-open"
    L8_2 = Config
    L8_2 = L8_2.Messages
    L8_2 = L8_2.unlock
    L7_2.label = L8_2
    function L8_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3
      L0_3 = GlobalState
      L0_3 = L0_3.ilegal_carwash_locks
      if not L0_3 then
        L0_3 = {}
      end
      L1_3 = L3_2
      L1_3 = L0_3[L1_3]
      if not L1_3 then
        L1_3 = false
        return L1_3
      end
      L1_3 = GlobalState
      L1_3 = L1_3.ilegal_carwash_busy
      if L1_3 then
        L1_3 = GlobalState
        L1_3 = L1_3.ilegal_carwash_busy
        L2_3 = L3_2
        L1_3 = L1_3[L2_3]
      end
      if L1_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = CanPlayerInteract
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      if not L2_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = HasJobAccess
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      if not L2_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = true
      return L2_3
    end
    L7_2.canInteract = L8_2
    function L8_2()
      local L0_3, L1_3, L2_3
      L0_3 = TriggerServerEvent
      L1_3 = "ilegal_anims:toggleLock"
      L2_3 = L3_2
      L0_3(L1_3, L2_3)
    end
    L7_2.onSelect = L8_2
    L8_2 = {}
    L9_2 = L2_2
    L10_2 = "_lock"
    L9_2 = L9_2 .. L10_2
    L8_2.name = L9_2
    L8_2.icon = "fas fa-lock"
    L9_2 = Config
    L9_2 = L9_2.Messages
    L9_2 = L9_2.lock
    L8_2.label = L9_2
    function L9_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3
      L0_3 = GlobalState
      L0_3 = L0_3.ilegal_carwash_locks
      if not L0_3 then
        L0_3 = {}
      end
      L1_3 = L3_2
      L1_3 = L0_3[L1_3]
      if L1_3 then
        L1_3 = false
        return L1_3
      end
      L1_3 = GlobalState
      L1_3 = L1_3.ilegal_carwash_busy
      if L1_3 then
        L1_3 = GlobalState
        L1_3 = L1_3.ilegal_carwash_busy
        L2_3 = L3_2
        L1_3 = L1_3[L2_3]
      end
      if L1_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = CanPlayerInteract
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      if not L2_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = HasJobAccess
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      if not L2_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = true
      return L2_3
    end
    L8_2.canInteract = L9_2
    function L9_2()
      local L0_3, L1_3, L2_3
      L0_3 = TriggerServerEvent
      L1_3 = "ilegal_anims:toggleLock"
      L2_3 = L3_2
      L0_3(L1_3, L2_3)
    end
    L8_2.onSelect = L9_2
    L6_2[1] = L7_2
    L6_2[2] = L8_2
    L5_2 = L6_2
  else
    L6_2 = getOxTargetLabels
    L7_2 = A0_2
    L6_2 = L6_2(L7_2)
    L7_2 = {}
    L8_2 = {}
    L9_2 = L2_2
    L10_2 = "_open"
    L9_2 = L9_2 .. L10_2
    L8_2.name = L9_2
    L8_2.icon = "fas fa-door-open"
    L9_2 = L6_2.open
    L8_2.label = L9_2
    function L9_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
      L0_3 = GlobalState
      L0_3 = L0_3.ilegal_carwash
      if L0_3 then
        L0_3 = GlobalState
        L0_3 = L0_3.ilegal_carwash
        L1_3 = L3_2
        L0_3 = L0_3[L1_3]
      end
      L1_3 = GlobalState
      L1_3 = L1_3.ilegal_carwash_busy
      if L1_3 then
        L1_3 = GlobalState
        L1_3 = L1_3.ilegal_carwash_busy
        L2_3 = L3_2
        L1_3 = L1_3[L2_3]
      end
      if L1_3 then
        L2_3 = false
        return L2_3
      end
      if L0_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = CanPlayerInteract
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      L3_3 = HasJobAccess
      L4_3 = L3_2
      L5_3 = L1_2
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = L2_3 or L4_3
      if L2_3 then
        L4_3 = L3_3
      end
      return L4_3
    end
    L8_2.canInteract = L9_2
    function L9_2()
      local L0_3, L1_3, L2_3, L3_3
      L0_3 = OnPropInteraction
      L1_3 = L3_2
      L2_3 = L1_2
      L3_3 = false
      L0_3(L1_3, L2_3, L3_3)
      L0_3 = A0_2.onExecute
      if L0_3 then
        L0_3 = A0_2.onExecute
        L1_3 = A0_2
        L0_3(L1_3)
      end
      L0_3 = TriggerServerEvent
      L1_3 = "ilegal_anims:setPropBusy"
      L2_3 = L3_2
      L3_3 = true
      L0_3(L1_3, L2_3, L3_3)
      L0_3 = animateProp
      L1_3 = L3_2
      L2_3 = true
      L0_3(L1_3, L2_3)
    end
    L8_2.onSelect = L9_2
    L9_2 = {}
    L10_2 = L2_2
    L11_2 = "_close"
    L10_2 = L10_2 .. L11_2
    L9_2.name = L10_2
    L9_2.icon = "fas fa-door-closed"
    L10_2 = L6_2.close
    L9_2.label = L10_2
    function L10_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
      L0_3 = GlobalState
      L0_3 = L0_3.ilegal_carwash
      if L0_3 then
        L0_3 = GlobalState
        L0_3 = L0_3.ilegal_carwash
        L1_3 = L3_2
        L0_3 = L0_3[L1_3]
      end
      L1_3 = GlobalState
      L1_3 = L1_3.ilegal_carwash_busy
      if L1_3 then
        L1_3 = GlobalState
        L1_3 = L1_3.ilegal_carwash_busy
        L2_3 = L3_2
        L1_3 = L1_3[L2_3]
      end
      if L1_3 then
        L2_3 = false
        return L2_3
      end
      if not L0_3 then
        L2_3 = false
        return L2_3
      end
      L2_3 = CanPlayerInteract
      L3_3 = L3_2
      L4_3 = L1_2
      L2_3 = L2_3(L3_3, L4_3)
      L3_3 = HasJobAccess
      L4_3 = L3_2
      L5_3 = L1_2
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = L2_3 or L4_3
      if L2_3 then
        L4_3 = L3_3
      end
      return L4_3
    end
    L9_2.canInteract = L10_2
    function L10_2()
      local L0_3, L1_3, L2_3, L3_3
      L0_3 = OnPropInteraction
      L1_3 = L3_2
      L2_3 = L1_2
      L3_3 = true
      L0_3(L1_3, L2_3, L3_3)
      L0_3 = A0_2.onExecute
      if L0_3 then
        L0_3 = A0_2.onExecute
        L1_3 = A0_2
        L0_3(L1_3)
      end
      L0_3 = TriggerServerEvent
      L1_3 = "ilegal_anims:setPropBusy"
      L2_3 = L3_2
      L3_3 = true
      L0_3(L1_3, L2_3, L3_3)
      L0_3 = animateProp
      L1_3 = L3_2
      L2_3 = false
      L0_3(L1_3, L2_3)
    end
    L9_2.onSelect = L10_2
    L7_2[1] = L8_2
    L7_2[2] = L9_2
    L5_2 = L7_2
  end
  L6_2 = TargetAddBoxZone
  L7_2 = {}
  L7_2.name = L2_2
  L8_2 = A0_2.interactionZone
  L8_2 = L8_2.coords
  L7_2.coords = L8_2
  L8_2 = A0_2.interactionZone
  L8_2 = L8_2.size
  L7_2.size = L8_2
  L8_2 = A0_2.interactionZone
  L8_2 = L8_2.rotation
  if not L8_2 then
    L8_2 = 0
  end
  L7_2.rotation = L8_2
  L8_2 = Config
  L8_2 = L8_2.Debug
  L7_2.debug = L8_2
  L7_2.options = L5_2
  L6_2(L7_2)
  L7_2 = A0_2.name
  L6_2 = L14_1
  L6_2[L7_2] = L2_2
  L6_2 = L2_1
  L7_2 = "[ILLEGAL GARAGE] Registered target zone for prop: "
  L8_2 = A0_2.name
  if L4_2 then
    L9_2 = " (lock/unlock mode)"
    if L9_2 then
      goto lbl_133
    end
  end
  L9_2 = " (open/close mode)"
  ::lbl_133::
  L10_2 = A0_2.originalName
  if L10_2 then
    L10_2 = " (controls: "
    L11_2 = A0_2.originalName
    L12_2 = ")"
    L10_2 = L10_2 .. L11_2 .. L12_2
    if L10_2 then
      goto lbl_143
    end
  end
  L10_2 = ""
  ::lbl_143::
  L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2
  L6_2(L7_2)
end
registerOxTarget = L19_1
function L19_1(A0_2)
  local L1_2, L2_2, L3_2
  L2_2 = A0_2.name
  L1_2 = L14_1
  L1_2 = L1_2[L2_2]
  if not L1_2 then
    return
  end
  L1_2 = TargetRemoveZone
  L3_2 = A0_2.name
  L2_2 = L14_1
  L2_2 = L2_2[L3_2]
  L1_2(L2_2)
  L2_2 = A0_2.name
  L1_2 = L14_1
  L1_2[L2_2] = nil
end
removeOxTarget = L19_1
function L19_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = A0_2.collision
  if L1_2 then
    L1_2 = A0_2.collision
    L2_2 = L1_2.name
    L1_2 = L8_1
    L1_2 = L1_2[L2_2]
    if not L1_2 then
      goto lbl_11
    end
  end
  do return end
  ::lbl_11::
  L1_2 = A0_2.collision
  L1_2 = L1_2.coords
  L2_2 = A0_2.collision
  L2_2 = L2_2.rotation
  L3_2 = GlobalState
  L3_2 = L3_2.ilegal_carwash
  if L3_2 then
    L3_2 = GlobalState
    L3_2 = L3_2.ilegal_carwash
    L4_2 = A0_2.name
    L3_2 = L3_2[L4_2]
  end
  L4_2 = A0_2.collision
  L4_2 = L4_2.moveType
  if "coords" == L4_2 and nil ~= L3_2 then
    if L3_2 then
      L4_2 = A0_2.collision
      L4_2 = L4_2.endCoords
      L1_2 = L4_2 or L1_2
    end
    if not L4_2 then
      L4_2 = A0_2.collision
      L1_2 = L4_2.startCoords
    end
  else
    L4_2 = A0_2.collision
    L4_2 = L4_2.moveType
    if "rotation" == L4_2 and nil ~= L3_2 then
      if L3_2 then
        L4_2 = A0_2.collision
        L4_2 = L4_2.endRotation
        if L4_2 then
          goto lbl_52
          L2_2 = L4_2 or L2_2
        end
      end
      L4_2 = A0_2.collision
      L2_2 = L4_2.startRotation
    end
  end
  ::lbl_52::
  L4_2 = L18_1
  L5_2 = A0_2.collision
  L5_2 = L5_2.model
  L6_2 = L1_2
  L7_2 = L2_2
  L8_2 = true
  L9_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  if L4_2 then
    L5_2 = A0_2.collision
    L6_2 = L5_2.name
    L5_2 = L8_1
    L5_2[L6_2] = L4_2
  end
  return L4_2
end
createCollision = L19_1
function L19_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = A0_2.name
  L2_2 = L9_1
  L2_2 = L2_2[L3_2]
  if L2_2 then
    L3_2 = A0_2.name
    L2_2 = L9_1
    L2_2 = L2_2[L3_2]
    return L2_2
  end
  L2_2 = L18_1
  L3_2 = A0_2.model
  L4_2 = A0_2.coords
  L5_2 = A0_2.rotation
  L6_2 = false
  L7_2 = false
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  if L2_2 then
    L4_2 = A0_2.name
    L3_2 = L9_1
    L5_2 = {}
    L5_2.entity = L2_2
    L5_2.parent = A1_2
    L3_2[L4_2] = L5_2
  end
  return L2_2
end
createLinkedProp = L19_1
function L19_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2)
  local L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  if A0_2 then
    L8_2 = DoesEntityExist
    L9_2 = A0_2
    L8_2 = L8_2(L9_2)
    if L8_2 then
      goto lbl_9
    end
  end
  do return end
  ::lbl_9::
  L8_2 = lib
  L8_2 = L8_2.requestAnimDict
  L9_2 = A1_2
  L8_2 = L8_2(L9_2)
  if L8_2 then
    L9_2 = type
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    if "table" == L9_2 then
      L9_2 = L8_2.await
      if L9_2 then
        L9_2 = L8_2.await
        L9_2()
      end
    end
  end
  L9_2 = PlayEntityAnim
  L10_2 = A0_2
  L11_2 = A2_2
  L12_2 = A1_2
  L13_2 = 8.0
  L14_2 = A4_2 or L14_2
  if not A4_2 then
    L14_2 = false
  end
  L15_2 = A5_2 or L15_2
  if not A5_2 then
    L15_2 = true
  end
  L16_2 = false
  L17_2 = A6_2 or L17_2
  if not A6_2 then
    L17_2 = 0.0
  end
  L18_2 = A7_2 or L18_2
  if not A7_2 then
    L18_2 = 0
  end
  L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
  L9_2 = RemoveAnimDict
  L10_2 = A1_2
  L9_2(L10_2)
end
function L20_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
  if A0_2 then
    L2_2 = DoesEntityExist
    L3_2 = A0_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      L2_2 = A1_2.animations
      if L2_2 then
        L2_2 = A1_2.animations
        L2_2 = L2_2.static
        if L2_2 then
          goto lbl_16
        end
      end
    end
  end
  do return end
  ::lbl_16::
  L2_2 = A1_2.animations
  L2_2 = L2_2.dict
  L3_2 = A1_2.animations
  L3_2 = L3_2.static
  L4_2 = L19_1
  L5_2 = A0_2
  L6_2 = L2_2
  L7_2 = L3_2
  L8_2 = 0
  L9_2 = false
  L10_2 = true
  L11_2 = 0.0
  L12_2 = 0
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L4_2 = A1_2.linkedProps
  if L4_2 then
    L4_2 = A1_2.animations
    L4_2 = L4_2.linkedAnims
    if L4_2 then
      L4_2 = ipairs
      L5_2 = A1_2.linkedProps
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L11_2 = L9_2.name
        L10_2 = L9_1
        L10_2 = L10_2[L11_2]
        if L10_2 then
          L11_2 = L10_2.entity
          if L11_2 then
            L11_2 = A1_2.animations
            L11_2 = L11_2.linkedAnims
            L11_2 = L11_2[L8_2]
            L11_2 = L11_2.static
            if L11_2 then
              L12_2 = L19_1
              L13_2 = L10_2.entity
              L14_2 = L2_2
              L15_2 = L11_2
              L16_2 = 0
              L17_2 = false
              L18_2 = true
              L19_2 = 0.0
              L20_2 = 0
              L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
            end
          end
        end
      end
    end
  end
end
playStaticAnimation = L20_1
function L20_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  if not A5_2 then
    A5_2 = 1
  end
  L6_2 = #A0_2
  if A5_2 > L6_2 then
    return
  end
  L6_2 = A0_2[A5_2]
  L8_2 = L6_2.name
  L7_2 = L9_1
  L7_2 = L7_2[L8_2]
  if L7_2 then
    L8_2 = L7_2.entity
    if L8_2 then
      if A3_2 then
        L8_2 = A1_2[A5_2]
        L8_2 = L8_2.open
        if L8_2 then
          goto lbl_25
        end
      end
      L8_2 = A1_2[A5_2]
      L8_2 = L8_2.close
      ::lbl_25::
      L9_2 = L19_1
      L10_2 = L7_2.entity
      L11_2 = A2_2
      L12_2 = L8_2
      L13_2 = A4_2
      L14_2 = false
      L15_2 = true
      L16_2 = 0.0
      L17_2 = 0
      L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
    end
  end
  L8_2 = L20_1
  L9_2 = A0_2
  L10_2 = A1_2
  L11_2 = A2_2
  L12_2 = A3_2
  L13_2 = A4_2
  L14_2 = A5_2 + 1
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
end
function L21_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L4_2 = nil
  L5_2 = pairs
  L6_2 = Config
  L6_2 = L6_2.Props
  L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
  for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
    L11_2 = L10_2.name
    if L11_2 == A0_2 then
      L4_2 = L10_2
      break
    end
  end
  if L4_2 then
    L5_2 = L7_1
    L5_2 = L5_2[A0_2]
    if L5_2 then
      goto lbl_22
    end
  end
  do return end
  ::lbl_22::
  L5_2 = L7_1
  L5_2 = L5_2[A0_2]
  L6_2 = L4_2.animations
  L6_2 = L6_2.dict
  if A1_2 then
    L7_2 = L4_2.animations
    L7_2 = L7_2.open
    if L7_2 then
      goto lbl_34
    end
  end
  L7_2 = L4_2.animations
  L7_2 = L7_2.close
  ::lbl_34::
  L8_2 = lib
  L8_2 = L8_2.requestAnimDict
  L9_2 = L6_2
  L8_2 = L8_2(L9_2)
  if L8_2 then
    L9_2 = type
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    if "table" == L9_2 then
      L9_2 = L8_2.await
      if L9_2 then
        L9_2 = L8_2.await
        L9_2()
      end
    end
  end
  L9_2 = GetAnimDuration
  L10_2 = L6_2
  L11_2 = L7_2
  L9_2 = L9_2(L10_2, L11_2)
  L9_2 = L9_2 * 1000
  L10_2 = L9_2 or L10_2
  if not (L9_2 > 0) or not L9_2 then
    L10_2 = L4_2.animations
    L10_2 = L10_2.duration
  end
  L11_2 = L4_2.playerAnimation
  if L11_2 and not A3_2 then
    if A1_2 then
      L11_2 = L4_2.playerAnimation
      L11_2 = L11_2.name
      if L11_2 then
        goto lbl_79
      end
    end
    L11_2 = L4_2.playerAnimation
    L11_2 = L11_2.closeName
    if not L11_2 then
      L11_2 = L4_2.playerAnimation
      L11_2 = L11_2.name
    end
    ::lbl_79::
    L12_2 = DoesEntityExist
    L13_2 = L5_2
    L12_2 = L12_2(L13_2)
    if not L12_2 then
      L12_2 = L2_1
      L13_2 = "[ILLEGAL GARAGE] Error: The prop does not exist to animate"
      L12_2(L13_2)
      L12_2 = false
      return L12_2
    end
    L12_2 = TriggerServerEvent
    L13_2 = "ilegal_anims:requestPlayerAnimation"
    L14_2 = {}
    L15_2 = L4_2.playerAnimation
    L15_2 = L15_2.dict
    L14_2.dict = L15_2
    L14_2.anim = L11_2
    L15_2 = type
    L16_2 = L4_2.playerAnimation
    L16_2 = L16_2.position
    L15_2 = L15_2(L16_2)
    if "table" == L15_2 then
      L15_2 = L4_2.playerAnimation
      L15_2 = L15_2.position
      L15_2 = L15_2[L11_2]
      if L15_2 then
        goto lbl_110
      end
    end
    L15_2 = L4_2.playerAnimation
    L15_2 = L15_2.position
    ::lbl_110::
    L14_2.position = L15_2
    L15_2 = type
    L16_2 = L4_2.playerAnimation
    L16_2 = L16_2.heading
    L15_2 = L15_2(L16_2)
    if "table" == L15_2 then
      L15_2 = L4_2.playerAnimation
      L15_2 = L15_2.heading
      L15_2 = L15_2[L11_2]
      if L15_2 then
        goto lbl_124
      end
    end
    L15_2 = L4_2.playerAnimation
    L15_2 = L15_2.heading
    ::lbl_124::
    L14_2.heading = L15_2
    L14_2.propName = A0_2
    L14_2.state = A1_2
    L12_2(L13_2, L14_2)
  else
    L11_2 = animatePropObject
    L12_2 = L4_2
    L13_2 = L5_2
    L14_2 = A1_2
    L15_2 = L6_2
    L16_2 = L7_2
    L17_2 = L10_2
    L18_2 = A2_2
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
  end
  L11_2 = true
  return L11_2
end
animateProp = L21_1
function L21_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
  local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L7_2 = L19_1
  L8_2 = A1_2
  L9_2 = A3_2
  L10_2 = A4_2
  L11_2 = A5_2
  L12_2 = false
  L13_2 = true
  L14_2 = 0.0
  L15_2 = 0
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  if not A6_2 then
    L7_2 = TriggerEvent
    L8_2 = "prompt_sandy_illegal_garage:liftStateChanged"
    L9_2 = A0_2.name
    L10_2 = A2_2
    L7_2(L8_2, L9_2, L10_2)
  end
  L7_2 = A0_2.linkedProps
  if L7_2 then
    L7_2 = A0_2.animations
    L7_2 = L7_2.linkedAnims
    if L7_2 then
      L7_2 = L20_1
      L8_2 = A0_2.linkedProps
      L9_2 = A0_2.animations
      L9_2 = L9_2.linkedAnims
      L10_2 = A3_2
      L11_2 = A2_2
      L12_2 = A5_2
      L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
    end
  end
  L7_2 = A0_2.collision
  if L7_2 then
    L7_2 = A0_2.collision
    L8_2 = L7_2.name
    L7_2 = L8_1
    L7_2 = L7_2[L8_2]
    if L7_2 then
      L8_2 = A0_2.collision
      L8_2 = L8_2.moveType
      if "coords" == L8_2 then
        if A2_2 then
          L8_2 = A0_2.collision
          L8_2 = L8_2.startCoords
          if L8_2 then
            goto lbl_54
          end
        end
        L8_2 = A0_2.collision
        L8_2 = L8_2.endCoords
        ::lbl_54::
        if A2_2 then
          L9_2 = A0_2.collision
          L9_2 = L9_2.endCoords
          if L9_2 then
            goto lbl_62
          end
        end
        L9_2 = A0_2.collision
        L9_2 = L9_2.startCoords
        ::lbl_62::
        L10_2 = A5_2
        L11_2 = 0
        L12_2 = "easeInOut"
        L13_2 = A0_2.collision
        L13_2 = L13_2.liftSettings
        if L13_2 then
          if A2_2 then
            L13_2 = A0_2.collision
            L13_2 = L13_2.liftSettings
            L13_2 = L13_2.upDelay
            L11_2 = L13_2 or L11_2
            if not L13_2 then
              L11_2 = 200
            end
            L13_2 = A0_2.collision
            L13_2 = L13_2.liftSettings
            L13_2 = L13_2.upSpeedFactor
            if not L13_2 then
              L13_2 = 0.8
            end
            L10_2 = A5_2 * L13_2
            L13_2 = A0_2.collision
            L13_2 = L13_2.liftSettings
            L13_2 = L13_2.upCurve
            L12_2 = L13_2 or L12_2
            if not L13_2 then
              L12_2 = "easeInOutQuad"
            end
          else
            L13_2 = A0_2.collision
            L13_2 = L13_2.liftSettings
            L13_2 = L13_2.downSpeedFactor
            if not L13_2 then
              L13_2 = 1.2
            end
            L10_2 = A5_2 * L13_2
            L13_2 = A0_2.collision
            L13_2 = L13_2.liftSettings
            L13_2 = L13_2.downCurve
            L12_2 = L13_2 or L12_2
            if not L13_2 then
              L12_2 = "easeOutCubic"
            end
          end
        else
          L13_2 = A0_2.name
          if "prompt_sandy_is_lift" == L13_2 then
            if A2_2 then
              L11_2 = 200
              L10_2 = A5_2 * 0.8
              L12_2 = "easeInOutQuad"
            else
              L10_2 = A5_2 * 1.2
              L12_2 = "easeOutCubic"
            end
          end
        end
        if A2_2 then
          L13_2 = A0_2.collision
          L13_2 = L13_2.openDelay
          if L13_2 then
            goto lbl_132
          end
        end
        if not A2_2 then
          L13_2 = A0_2.collision
          L13_2 = L13_2.closeDelay
          ::lbl_132::
          if L13_2 then
            if A2_2 then
              L13_2 = A0_2.collision
              L13_2 = L13_2.openDelay
              if L13_2 then
                goto lbl_140
              end
            end
            L13_2 = A0_2.collision
            L13_2 = L13_2.closeDelay
            ::lbl_140::
            L14_2 = SetTimeout
            L15_2 = L13_2
            function L16_2()
              local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
              L0_3 = AnimateObjectCoords
              L1_3 = L7_2
              L2_3 = L8_2
              L3_3 = L9_2
              L4_3 = L10_2
              L5_3 = L12_2
              L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
            end
            L14_2(L15_2, L16_2)
        end
        elseif L11_2 > 0 then
          L13_2 = SetTimeout
          L14_2 = L11_2
          function L15_2()
            local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
            L0_3 = AnimateObjectCoords
            L1_3 = L7_2
            L2_3 = L8_2
            L3_3 = L9_2
            L4_3 = L10_2
            L5_3 = L12_2
            L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
          end
          L13_2(L14_2, L15_2)
        else
          L13_2 = AnimateObjectCoords
          L14_2 = L7_2
          L15_2 = L8_2
          L16_2 = L9_2
          L17_2 = L10_2
          L18_2 = L12_2
          L13_2(L14_2, L15_2, L16_2, L17_2, L18_2)
        end
      else
        L8_2 = A0_2.collision
        L8_2 = L8_2.moveType
        if "rotation" == L8_2 then
          if A2_2 then
            L8_2 = A0_2.collision
            L8_2 = L8_2.startRotation
            if L8_2 then
              goto lbl_173
            end
          end
          L8_2 = A0_2.collision
          L8_2 = L8_2.endRotation
          ::lbl_173::
          if A2_2 then
            L9_2 = A0_2.collision
            L9_2 = L9_2.endRotation
            if L9_2 then
              goto lbl_181
            end
          end
          L9_2 = A0_2.collision
          L9_2 = L9_2.startRotation
          ::lbl_181::
          L10_2 = AnimateObjectRotation
          L11_2 = L7_2
          L12_2 = L8_2
          L13_2 = L9_2
          L14_2 = A5_2
          L15_2 = "easeInOut"
          L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
        end
      end
    end
  end
  if not A6_2 then
    L7_2 = TriggerServerEvent
    L8_2 = "ilegal_anims:updatePropState"
    L9_2 = A0_2.name
    L10_2 = A2_2
    L7_2(L8_2, L9_2, L10_2)
  end
  L7_2 = SetTimeout
  L8_2 = A5_2
  function L9_2()
    local L0_3, L1_3, L2_3, L3_3
    L0_3 = TriggerServerEvent
    L1_3 = "ilegal_anims:setPropBusy"
    L2_3 = A0_2.name
    L3_3 = false
    L0_3(L1_3, L2_3, L3_3)
    L0_3 = A6_2
    if not L0_3 then
      L0_3 = TriggerEvent
      L1_3 = "prompt_sandy_illegal_garage:liftAnimationComplete"
      L2_3 = A0_2.name
      L3_3 = A2_2
      L0_3(L1_3, L2_3, L3_3)
    end
  end
  L7_2(L8_2, L9_2)
end
animatePropObject = L21_1
L21_1 = exports
L22_1 = "getLiftState"
function L23_1(A0_2)
  local L1_2, L2_2
  L1_2 = GlobalState
  L1_2 = L1_2.ilegal_carwash
  if not L1_2 then
    L1_2 = {}
  end
  L2_2 = L1_2[A0_2]
  return L2_2
end
L21_1(L22_1, L23_1)
L21_1 = exports
L22_1 = "isLiftBusy"
function L23_1(A0_2)
  local L1_2, L2_2
  L1_2 = GlobalState
  L1_2 = L1_2.ilegal_carwash_busy
  if not L1_2 then
    L1_2 = {}
  end
  L2_2 = L1_2[A0_2]
  if not L2_2 then
    L2_2 = false
  end
  return L2_2
end
L21_1(L22_1, L23_1)
L21_1 = exports
L22_1 = "setLiftState"
function L23_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = animateProp
  L3_2 = A0_2
  L4_2 = A1_2
  L2_2(L3_2, L4_2)
  L2_2 = TriggerServerEvent
  L3_2 = "ilegal_anims:setPropBusy"
  L4_2 = A0_2
  L5_2 = true
  L2_2(L3_2, L4_2, L5_2)
end
L21_1(L22_1, L23_1)
L21_1 = Config
L21_1 = L21_1.Debug
if L21_1 then
  L21_1 = AddEventHandler
  L22_1 = "prompt_sandy_illegal_garage:liftStateChanged"
  function L23_1(A0_2, A1_2)
    local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
    L2_2 = print
    L3_2 = "[ILLEGAL GARAGE EXPORT DEBUG] [CLIENT] liftStateChanged -> propName: %s | state: %s (%s)"
    L4_2 = L3_2
    L3_2 = L3_2.format
    L5_2 = A0_2
    L6_2 = tostring
    L7_2 = A1_2
    L6_2 = L6_2(L7_2)
    if A1_2 then
      L7_2 = "UP"
      if L7_2 then
        goto lbl_14
      end
    end
    L7_2 = "DOWN"
    ::lbl_14::
    L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
    L2_2 = exports
    L3_2 = GetCurrentResourceName
    L3_2 = L3_2()
    L2_2 = L2_2[L3_2]
    L3_2 = L2_2
    L2_2 = L2_2.getLiftState
    L4_2 = A0_2
    L2_2 = L2_2(L3_2, L4_2)
    L3_2 = print
    L4_2 = "[ILLEGAL GARAGE EXPORT DEBUG] [CLIENT] getLiftState(%s) = %s"
    L5_2 = L4_2
    L4_2 = L4_2.format
    L6_2 = A0_2
    L7_2 = tostring
    L8_2 = L2_2
    L7_2, L8_2, L9_2 = L7_2(L8_2)
    L4_2, L5_2, L6_2, L7_2, L8_2, L9_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
    L3_2 = exports
    L4_2 = GetCurrentResourceName
    L4_2 = L4_2()
    L3_2 = L3_2[L4_2]
    L4_2 = L3_2
    L3_2 = L3_2.isLiftBusy
    L5_2 = A0_2
    L3_2 = L3_2(L4_2, L5_2)
    L4_2 = print
    L5_2 = "[ILLEGAL GARAGE EXPORT DEBUG] [CLIENT] isLiftBusy(%s) = %s"
    L6_2 = L5_2
    L5_2 = L5_2.format
    L7_2 = A0_2
    L8_2 = tostring
    L9_2 = L3_2
    L8_2, L9_2 = L8_2(L9_2)
    L5_2, L6_2, L7_2, L8_2, L9_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  end
  L21_1(L22_1, L23_1)
  L21_1 = AddEventHandler
  L22_1 = "prompt_sandy_illegal_garage:liftAnimationComplete"
  function L23_1(A0_2, A1_2)
    local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
    L2_2 = print
    L3_2 = "[ILLEGAL GARAGE EXPORT DEBUG] [CLIENT] liftAnimationComplete -> propName: %s | state: %s (%s)"
    L4_2 = L3_2
    L3_2 = L3_2.format
    L5_2 = A0_2
    L6_2 = tostring
    L7_2 = A1_2
    L6_2 = L6_2(L7_2)
    if A1_2 then
      L7_2 = "UP"
      if L7_2 then
        goto lbl_14
      end
    end
    L7_2 = "DOWN"
    ::lbl_14::
    L3_2, L4_2, L5_2, L6_2, L7_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  end
  L21_1(L22_1, L23_1)
end
function L21_1(A0_2)
  local L1_2, L2_2
  L1_2 = L10_1
  if L1_2 ~= A0_2 then
    if A0_2 then
      L1_2 = lib
      L1_2 = L1_2.showTextUI
      L2_2 = A0_2
      L1_2(L2_2)
    else
      L1_2 = lib
      L1_2 = L1_2.hideTextUI
      L1_2()
    end
    L10_1 = A0_2
  end
end
updateTextUI = L21_1
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L0_2 = {}
  L1_2 = pairs
  L2_2 = Config
  L2_2 = L2_2.Props
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = GlobalState
    L7_2 = L7_2.ilegal_carwash
    if L7_2 then
      L7_2 = GlobalState
      L7_2 = L7_2.ilegal_carwash
      L8_2 = L6_2.name
      L7_2 = L7_2[L8_2]
    end
    if L7_2 then
      L8_2 = Config
      L8_2 = L8_2.Messages
      L8_2 = L8_2.close
      if L8_2 then
        goto lbl_26
      end
    end
    L8_2 = Config
    L8_2 = L8_2.Messages
    L8_2 = L8_2.open
    ::lbl_26::
    L9_2 = table
    L9_2 = L9_2.insert
    L10_2 = L0_2
    L11_2 = {}
    L12_2 = L6_2.name
    L11_2.title = L12_2
    L12_2 = L8_2
    L13_2 = " "
    L14_2 = L6_2.name
    L12_2 = L12_2 .. L13_2 .. L14_2
    L11_2.description = L12_2
    L11_2.icon = "building"
    function L12_2()
      local L0_3, L1_3, L2_3
      L0_3 = animateProp
      L1_3 = L6_2.name
      L2_3 = L7_2
      L2_3 = not L2_3
      L0_3(L1_3, L2_3)
    end
    L11_2.onSelect = L12_2
    L9_2(L10_2, L11_2)
  end
  return L0_2
end
getTestMenu = L21_1
function L21_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2
  L1_2 = A0_2.interactionZone
  if not L1_2 then
    return
  end
  L1_2 = {}
  L2_2 = Config
  L2_2 = L2_2.AutoOpen
  if L2_2 then
    L2_2 = L16_1
    L3_2 = A0_2.name
    L2_2 = L2_2(L3_2)
  end
  L3_2 = lib
  L3_2 = L3_2.zones
  L3_2 = L3_2.box
  L4_2 = {}
  L5_2 = A0_2.interactionZone
  L5_2 = L5_2.coords
  L4_2.coords = L5_2
  L5_2 = A0_2.interactionZone
  L5_2 = L5_2.size
  L4_2.size = L5_2
  L5_2 = A0_2.interactionZone
  L5_2 = L5_2.rotation
  L4_2.rotation = L5_2
  L4_2.debug = false
  function L5_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
    L0_3 = true
    L11_1 = L0_3
    L1_3 = A0_2.name
    L0_3 = L12_1
    L0_3[L1_3] = true
    L0_3 = GetPlayerServerId
    L1_3 = PlayerId
    L1_3, L2_3, L3_3, L4_3, L5_3 = L1_3()
    L0_3 = L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
    L1_3 = CanPlayerInteract
    L2_3 = A0_2.name
    L3_3 = L0_3
    L1_3 = L1_3(L2_3, L3_3)
    L2_3 = HasJobAccess
    L3_3 = A0_2.name
    L4_3 = L0_3
    L2_3 = L2_3(L3_3, L4_3)
    L4_3 = A0_2.name
    L3_3 = L1_2
    L5_3 = {}
    L5_3.canInteract = L1_3
    L5_3.hasAccess = L2_3
    L5_3.playerId = L0_3
    L3_3[L4_3] = L5_3
  end
  L4_2.onEnter = L5_2
  function L5_2()
    local L0_3, L1_3
    L1_3 = A0_2.name
    L0_3 = L12_1
    L0_3[L1_3] = nil
    L1_3 = A0_2.name
    L0_3 = L1_2
    L0_3[L1_3] = nil
    L0_3 = next
    L1_3 = L12_1
    L0_3 = L0_3(L1_3)
    if not L0_3 then
      L0_3 = false
      L11_1 = L0_3
      L0_3 = updateTextUI
      L1_3 = nil
      L0_3(L1_3)
    end
  end
  L4_2.onExit = L5_2
  function L5_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L1_3 = A0_2.name
    L0_3 = L1_2
    L0_3 = L0_3[L1_3]
    L1_3 = GlobalState
    L1_3 = L1_3.ilegal_carwash_busy
    if L1_3 then
      L1_3 = GlobalState
      L1_3 = L1_3.ilegal_carwash_busy
      L2_3 = A0_2.name
      L1_3 = L1_3[L2_3]
    end
    if L1_3 then
      L2_3 = updateTextUI
      L3_3 = nil
      L2_3(L3_3)
      return
    end
    L2_3 = L2_2
    if L2_3 then
      L2_3 = GlobalState
      L2_3 = L2_3.ilegal_carwash_locks
      if not L2_3 then
        L2_3 = {}
      end
      L3_3 = A0_2.name
      L3_3 = L2_3[L3_3]
      if not L3_3 then
        L3_3 = false
      end
      if L3_3 then
        L4_3 = Config
        L4_3 = L4_3.Messages
        L4_3 = L4_3.unlock
        if L4_3 then
          goto lbl_42
        end
      end
      L4_3 = Config
      L4_3 = L4_3.Messages
      L4_3 = L4_3.lock
      ::lbl_42::
      if L0_3 then
        L5_3 = L0_3.playerId
        if L5_3 then
          goto lbl_51
        end
      end
      L5_3 = GetPlayerServerId
      L6_3 = PlayerId
      L6_3, L7_3, L8_3, L9_3 = L6_3()
      L5_3 = L5_3(L6_3, L7_3, L8_3, L9_3)
      ::lbl_51::
      L6_3 = GetCustomLabel
      L7_3 = A0_2.name
      L8_3 = L5_3
      L9_3 = L4_3
      L6_3 = L6_3(L7_3, L8_3, L9_3)
      L4_3 = L6_3
      L6_3 = updateTextUI
      L7_3 = "[E] "
      L8_3 = L4_3
      L7_3 = L7_3 .. L8_3
      L6_3(L7_3)
      L6_3 = IsControlJustPressed
      L7_3 = 0
      L8_3 = 38
      L6_3 = L6_3(L7_3, L8_3)
      if L6_3 then
        L6_3 = TriggerServerEvent
        L7_3 = "ilegal_anims:toggleLock"
        L8_3 = A0_2.name
        L6_3(L7_3, L8_3)
      end
    else
      if L0_3 then
        L2_3 = L0_3.canInteract
        if L2_3 then
          L2_3 = L0_3.hasAccess
          if L2_3 then
            goto lbl_85
          end
        end
      end
      L2_3 = updateTextUI
      L3_3 = nil
      L2_3(L3_3)
      do return end
      ::lbl_85::
      L2_3 = GlobalState
      L2_3 = L2_3.ilegal_carwash
      if L2_3 then
        L2_3 = GlobalState
        L2_3 = L2_3.ilegal_carwash
        L3_3 = A0_2.name
        L2_3 = L2_3[L3_3]
      end
      L3_3 = nil
      L4_3 = type
      L5_3 = A0_2.label
      L4_3 = L4_3(L5_3)
      if "table" == L4_3 then
        if L2_3 then
          L4_3 = A0_2.label
          L4_3 = L4_3.close
          L3_3 = L4_3 or L3_3
        end
        if not L4_3 then
          L4_3 = A0_2.label
          L3_3 = L4_3.open
        end
      else
        L4_3 = A0_2.label
        L3_3 = L4_3 or L3_3
        if not L4_3 then
          if L2_3 then
            L4_3 = Config
            L4_3 = L4_3.Messages
            L4_3 = L4_3.close
            L5_3 = " "
            L6_3 = A0_2.name
            L4_3 = L4_3 .. L5_3 .. L6_3
            if L4_3 then
              goto lbl_128
              L3_3 = L4_3 or L3_3
            end
          end
          L4_3 = Config
          L4_3 = L4_3.Messages
          L4_3 = L4_3.open
          L5_3 = " "
          L6_3 = A0_2.name
          L4_3 = L4_3 .. L5_3 .. L6_3
          L3_3 = L4_3
        end
      end
      ::lbl_128::
      L4_3 = GetCustomLabel
      L5_3 = A0_2.name
      L6_3 = L0_3.playerId
      L7_3 = L3_3
      L4_3 = L4_3(L5_3, L6_3, L7_3)
      L3_3 = L4_3
      L4_3 = updateTextUI
      L5_3 = "["
      L6_3 = Config
      L6_3 = L6_3.InteractionKey
      L6_3 = L6_3.display
      L7_3 = "] "
      L8_3 = L3_3
      L5_3 = L5_3 .. L6_3 .. L7_3 .. L8_3
      L4_3(L5_3)
      L4_3 = IsControlJustPressed
      L5_3 = 0
      L6_3 = Config
      L6_3 = L6_3.InteractionKey
      L6_3 = L6_3.control
      L4_3 = L4_3(L5_3, L6_3)
      if L4_3 then
        L4_3 = OnPropInteraction
        L5_3 = A0_2.name
        L6_3 = L0_3.playerId
        L7_3 = L2_3
        L4_3(L5_3, L6_3, L7_3)
        L4_3 = A0_2.onExecute
        if L4_3 then
          L4_3 = A0_2.onExecute
          L5_3 = A0_2
          L4_3(L5_3)
        end
        L4_3 = TriggerServerEvent
        L5_3 = "ilegal_anims:setPropBusy"
        L6_3 = A0_2.name
        L7_3 = true
        L4_3(L5_3, L6_3, L7_3)
        L4_3 = animateProp
        L5_3 = A0_2.name
        L6_3 = not L2_3
        L4_3(L5_3, L6_3)
      end
    end
  end
  L4_2.inside = L5_2
  return L3_2(L4_2)
end
createInteractionZone = L21_1
function L21_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = A0_2.interactionZone
  if not L1_2 then
    return
  end
  L1_2 = A0_2.name
  L2_2 = L15_1
  L2_2[L1_2] = 0
  L2_2 = lib
  L2_2 = L2_2.zones
  L2_2 = L2_2.box
  L3_2 = {}
  L4_2 = A0_2.interactionZone
  L4_2 = L4_2.coords
  L3_2.coords = L4_2
  L4_2 = A0_2.interactionZone
  L4_2 = L4_2.size
  L3_2.size = L4_2
  L4_2 = A0_2.interactionZone
  L4_2 = L4_2.rotation
  L3_2.rotation = L4_2
  L4_2 = Config
  L4_2 = L4_2.Debug
  L3_2.debug = L4_2
  function L4_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3
    L1_3 = L1_2
    L0_3 = L15_1
    L3_3 = L1_2
    L2_3 = L15_1
    L2_3 = L2_3[L3_3]
    if not L2_3 then
      L2_3 = 0
    end
    L2_3 = L2_3 + 1
    L0_3[L1_3] = L2_3
    L0_3 = TriggerServerEvent
    L1_3 = "ilegal_anims:zoneEnter"
    L2_3 = L1_2
    L0_3(L1_3, L2_3)
    L0_3 = GlobalState
    L0_3 = L0_3.ilegal_carwash_locks
    if not L0_3 then
      L0_3 = {}
    end
    L1_3 = L1_2
    L1_3 = L0_3[L1_3]
    if L1_3 then
      return
    end
    L1_3 = GlobalState
    L1_3 = L1_3.ilegal_carwash
    if not L1_3 then
      L1_3 = {}
    end
    L2_3 = L1_2
    L2_3 = L1_3[L2_3]
    if L2_3 then
      return
    end
    L2_3 = GlobalState
    L2_3 = L2_3.ilegal_carwash_busy
    if not L2_3 then
      L2_3 = {}
    end
    L3_3 = L1_2
    L3_3 = L2_3[L3_3]
    if L3_3 then
      return
    end
    L3_3 = GetPlayerServerId
    L4_3 = PlayerId
    L4_3, L5_3, L6_3 = L4_3()
    L3_3 = L3_3(L4_3, L5_3, L6_3)
    L4_3 = CanPlayerInteract
    L5_3 = L1_2
    L6_3 = L3_3
    L4_3 = L4_3(L5_3, L6_3)
    if not L4_3 then
      return
    end
    L4_3 = HasJobAccess
    L5_3 = L1_2
    L6_3 = L3_3
    L4_3 = L4_3(L5_3, L6_3)
    if not L4_3 then
      return
    end
    L4_3 = TriggerServerEvent
    L5_3 = "ilegal_anims:requestAutoOpen"
    L6_3 = L1_2
    L4_3(L5_3, L6_3)
  end
  L3_2.onEnter = L4_2
  function L4_2()
    local L0_3, L1_3, L2_3, L3_3
    L0_3 = TriggerServerEvent
    L1_3 = "ilegal_anims:zoneExit"
    L2_3 = L1_2
    L0_3(L1_3, L2_3)
    L1_3 = L1_2
    L0_3 = L15_1
    L0_3 = L0_3[L1_3]
    if not L0_3 then
      L0_3 = 0
    end
    L1_3 = SetTimeout
    L2_3 = Config
    L2_3 = L2_3.AutoOpenCloseDelay
    function L3_3()
      local L0_4, L1_4, L2_4
      L1_4 = L1_2
      L0_4 = L15_1
      L0_4 = L0_4[L1_4]
      if not L0_4 then
        L0_4 = 0
      end
      L1_4 = L0_3
      if L0_4 ~= L1_4 then
        return
      end
      L0_4 = TriggerServerEvent
      L1_4 = "ilegal_anims:requestAutoClose"
      L2_4 = L1_2
      L0_4(L1_4, L2_4)
    end
    L1_3(L2_3, L3_3)
  end
  L3_2.onExit = L4_2
  return L2_2(L3_2)
end
createAutoOpenZone = L21_1
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L0_2 = useTarget
  if L0_2 then
    L0_2 = L2_1
    L1_2 = "[ILLEGAL GARAGE] Creating target zones for all props"
    L0_2(L1_2)
    L0_2 = pairs
    L1_2 = Config
    L1_2 = L1_2.Props
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = L5_2.interactionZone
      if L6_2 then
        L6_2 = registerOxTarget
        L7_2 = L5_2
        L6_2(L7_2)
      end
      L6_2 = L5_2.extraZones
      if L6_2 then
        L6_2 = ipairs
        L7_2 = L5_2.extraZones
        L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
        for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
          L12_2 = table
          L12_2 = L12_2.clone
          L13_2 = L5_2
          L12_2 = L12_2(L13_2)
          L12_2.interactionZone = L11_2
          L13_2 = L5_2.name
          L12_2.originalName = L13_2
          L13_2 = L5_2.name
          L14_2 = "_extra_"
          L15_2 = L10_2
          L13_2 = L13_2 .. L14_2 .. L15_2
          L12_2.name = L13_2
          L13_2 = registerOxTarget
          L14_2 = L12_2
          L13_2(L14_2)
        end
      end
    end
  else
    L0_2 = L2_1
    L1_2 = "[ILLEGAL GARAGE] Creating lib.zones for all props"
    L0_2(L1_2)
    L0_2 = pairs
    L1_2 = Config
    L1_2 = L1_2.Props
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = createInteractionZone
      L7_2 = L5_2
      L6_2(L7_2)
      L6_2 = L5_2.extraZones
      if L6_2 then
        L6_2 = ipairs
        L7_2 = L5_2.extraZones
        L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
        for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
          L12_2 = table
          L12_2 = L12_2.clone
          L13_2 = L5_2
          L12_2 = L12_2(L13_2)
          L12_2.interactionZone = L11_2
          L13_2 = createInteractionZone
          L14_2 = L12_2
          L13_2(L14_2)
        end
      end
    end
  end
  L0_2 = Config
  L0_2 = L0_2.AutoOpen
  if L0_2 then
    L0_2 = L2_1
    L1_2 = "[ILLEGAL GARAGE] Creating auto-open zones for garage rollup doors"
    L0_2(L1_2)
    L0_2 = pairs
    L1_2 = Config
    L1_2 = L1_2.Props
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = L16_1
      L7_2 = L5_2.name
      L6_2 = L6_2(L7_2)
      if L6_2 then
        L6_2 = L5_2.interactionZone
        if L6_2 then
          L6_2 = createAutoOpenZone
          L7_2 = L5_2
          L6_2(L7_2)
        end
      end
    end
  end
end
createInteractionZones = L21_1
function L21_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = lib
  L1_2 = L1_2.points
  L1_2 = L1_2.new
  L2_2 = {}
  L3_2 = A0_2.coords
  L2_2.coords = L3_2
  L3_2 = Config
  L3_2 = L3_2.SpawnDistance
  L2_2.distance = L3_2
  function L3_2()
    local L0_3, L1_3, L2_3
    L0_3 = L2_1
    L1_3 = "[ILLEGAL GARAGE] onEnter triggered for prop: "
    L2_3 = A0_2.name
    L1_3 = L1_3 .. L2_3
    L0_3(L1_3)
    L0_3 = createProp
    L1_3 = A0_2
    L0_3(L1_3)
  end
  L2_2.onEnter = L3_2
  function L3_2()
    local L0_3, L1_3
  end
  L2_2.onExit = L3_2
  L1_2 = L1_2(L2_2)
  if L1_2 then
    L3_2 = A0_2.name
    L2_2 = L13_1
    L2_2[L3_2] = L1_2
    L2_2 = L2_1
    L3_2 = "[ILLEGAL GARAGE] Spawn point created and stored for: "
    L4_2 = A0_2.name
    L3_2 = L3_2 .. L4_2
    L2_2(L3_2)
  else
    L2_2 = L2_1
    L3_2 = "[ILLEGAL GARAGE WARNING] Failed to create spawn point for: "
    L4_2 = A0_2.name
    L3_2 = L3_2 .. L4_2
    L2_2(L3_2)
  end
end
createSpawnPoint = L21_1
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = pairs
  L1_2 = Config
  L1_2 = L1_2.Props
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = createSpawnPoint
    L7_2 = L5_2
    L6_2(L7_2)
  end
end
createSpawnPoints = L21_1
L21_1 = RegisterNetEvent
L22_1 = "ilegal_anims:syncAnimation"
L21_1(L22_1)
L21_1 = AddEventHandler
L22_1 = "ilegal_anims:syncAnimation"
function L23_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L4_2 = GetPlayerPed
  L5_2 = GetPlayerFromServerId
  L6_2 = A0_2
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L5_2(L6_2)
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L5_2 = cache
  L5_2 = L5_2.ped
  if L4_2 ~= L5_2 then
    L5_2 = lib
    L5_2 = L5_2.requestAnimDict
    L6_2 = A1_2
    L5_2 = L5_2(L6_2)
    if L5_2 then
      L6_2 = type
      L7_2 = L5_2
      L6_2 = L6_2(L7_2)
      if "table" == L6_2 then
        L6_2 = L5_2.await
        if L6_2 then
          L6_2 = L5_2.await
          L6_2()
        end
      end
    end
    L6_2 = TaskPlayAnim
    L7_2 = L4_2
    L8_2 = A1_2
    L9_2 = A2_2
    L10_2 = 8.0
    L11_2 = -8.0
    L12_2 = A3_2
    L13_2 = 0
    L14_2 = 0
    L15_2 = false
    L16_2 = false
    L17_2 = false
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
    L6_2 = RemoveAnimDict
    L7_2 = A1_2
    L6_2(L7_2)
  end
end
L21_1(L22_1, L23_1)
L21_1 = RegisterNetEvent
L22_1 = "ilegal_anims:animatePropAfterPlayerAnim"
L21_1(L22_1)
L21_1 = AddEventHandler
L22_1 = "ilegal_anims:animatePropAfterPlayerAnim"
function L23_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L1_2 = A0_2.propName
  L2_2 = A0_2.state
  L3_2 = nil
  L4_2 = pairs
  L5_2 = Config
  L5_2 = L5_2.Props
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L9_2.name
    if L10_2 == L1_2 then
      L3_2 = L9_2
      break
    end
  end
  if not L3_2 then
    L4_2 = L2_1
    L5_2 = "[ILLEGAL GARAGE] Error: The prop configuration was not found: "
    L6_2 = L1_2
    L5_2 = L5_2 .. L6_2
    L4_2(L5_2)
    return
  end
  L4_2 = L7_1
  L4_2 = L4_2[L1_2]
  if not L4_2 then
    L4_2 = L2_1
    L5_2 = "[ILLEGAL GARAGE] Error: The prop is not spawned: "
    L6_2 = L1_2
    L5_2 = L5_2 .. L6_2
    L4_2(L5_2)
    return
  end
  L4_2 = L7_1
  L4_2 = L4_2[L1_2]
  L5_2 = DoesEntityExist
  L6_2 = L4_2
  L5_2 = L5_2(L6_2)
  if not L5_2 then
    L5_2 = L2_1
    L6_2 = "[ILLEGAL GARAGE] Error: The prop entity does not exist: "
    L7_2 = L1_2
    L6_2 = L6_2 .. L7_2
    L5_2(L6_2)
    return
  end
  L5_2 = L3_2.animations
  L5_2 = L5_2.dict
  if L2_2 then
    L6_2 = L3_2.animations
    L6_2 = L6_2.open
    if L6_2 then
      goto lbl_58
    end
  end
  L6_2 = L3_2.animations
  L6_2 = L6_2.close
  ::lbl_58::
  L7_2 = lib
  L7_2 = L7_2.requestAnimDict
  L8_2 = L5_2
  L7_2 = L7_2(L8_2)
  if L7_2 then
    L8_2 = type
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    if "table" == L8_2 then
      L8_2 = L7_2.await
      if L8_2 then
        L8_2 = L7_2.await
        L8_2()
      end
    end
  end
  L8_2 = GetAnimDuration
  L9_2 = L5_2
  L10_2 = L6_2
  L8_2 = L8_2(L9_2, L10_2)
  L8_2 = L8_2 * 1000
  L9_2 = L8_2 or L9_2
  if not (L8_2 > 0) or not L8_2 then
    L9_2 = L3_2.animations
    L9_2 = L9_2.duration
  end
  L10_2 = animatePropObject
  L11_2 = L3_2
  L12_2 = L4_2
  L13_2 = L2_2
  L14_2 = L5_2
  L15_2 = L6_2
  L16_2 = L9_2
  L17_2 = false
  L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
end
L21_1(L22_1, L23_1)
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = AddStateBagChangeHandler
  L1_2 = "ilegal_carwash"
  L2_2 = nil
  function L3_2(A0_3, A1_3, A2_3, A3_3, A4_3)
    local L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
    if not A2_3 then
      return
    end
    L5_3 = GlobalState
    L5_3 = L5_3.ilegal_carwash
    if not L5_3 then
      L5_3 = {}
    end
    L6_3 = pairs
    L7_3 = Config
    L7_3 = L7_3.Props
    L6_3, L7_3, L8_3, L9_3 = L6_3(L7_3)
    for L10_3, L11_3 in L6_3, L7_3, L8_3, L9_3 do
      L12_3 = L11_3.name
      L13_3 = A2_3[L12_3]
      if nil ~= L13_3 then
        L13_3 = A2_3[L12_3]
        L14_3 = L5_3[L12_3]
        if L13_3 ~= L14_3 then
          L13_3 = L7_1
          L13_3 = L13_3[L12_3]
          if L13_3 then
            L13_3 = animateProp
            L14_3 = L12_3
            L15_3 = A2_3[L12_3]
            L16_3 = true
            L17_3 = true
            L13_3(L14_3, L15_3, L16_3, L17_3)
          end
        end
      end
    end
  end
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = Config
  L0_2 = L0_2.AutoOpen
  if L0_2 then
    L0_2 = {}
    L1_2 = GlobalState
    L1_2 = L1_2.ilegal_carwash_locks
    L2_2 = type
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    if "table" == L2_2 then
      L2_2 = pairs
      L3_2 = L1_2
      L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
      for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
        L0_2[L6_2] = L7_2
      end
    end
    L2_2 = AddStateBagChangeHandler
    L3_2 = "ilegal_carwash_locks"
    L4_2 = nil
    function L5_2(A0_3, A1_3, A2_3, A3_3, A4_3)
      local L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3
      if not A2_3 then
        return
      end
      L5_3 = pairs
      L6_3 = Config
      L6_3 = L6_3.Props
      L5_3, L6_3, L7_3, L8_3 = L5_3(L6_3)
      for L9_3, L10_3 in L5_3, L6_3, L7_3, L8_3 do
        L11_3 = L10_3.name
        L12_3 = L16_1
        L13_3 = L11_3
        L12_3 = L12_3(L13_3)
        if L12_3 then
          L12_3 = A2_3[L11_3]
          if nil ~= L12_3 then
            L12_3 = A2_3[L11_3]
            L13_3 = L0_2
            L13_3 = L13_3[L11_3]
            if L12_3 ~= L13_3 then
              L12_3 = L10_3.coords
              L13_3 = A2_3[L11_3]
              if L13_3 then
                L13_3 = PlaySoundFromCoord
                L14_3 = -1
                L15_3 = "CLOSING"
                L16_3 = L12_3.x
                L17_3 = L12_3.y
                L18_3 = L12_3.z
                L19_3 = "MP_PROPERTIES_ELEVATOR_DOORS"
                L20_3 = true
                L21_3 = 0
                L22_3 = false
                L13_3(L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3)
              else
                L13_3 = PlaySoundFromCoord
                L14_3 = -1
                L15_3 = "OPENING"
                L16_3 = L12_3.x
                L17_3 = L12_3.y
                L18_3 = L12_3.z
                L19_3 = "MP_PROPERTIES_ELEVATOR_DOORS"
                L20_3 = true
                L21_3 = 0
                L22_3 = false
                L13_3(L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3)
              end
            end
          end
        end
      end
      L5_3 = pairs
      L6_3 = A2_3
      L5_3, L6_3, L7_3, L8_3 = L5_3(L6_3)
      for L9_3, L10_3 in L5_3, L6_3, L7_3, L8_3 do
        L11_3 = L0_2
        L11_3[L9_3] = L10_3
      end
    end
    L2_2(L3_2, L4_2, L5_2)
  end
end
registerPropStateHandlers = L21_1
L21_1 = lib
L21_1 = L21_1.callback
L21_1 = L21_1.register
L22_1 = "ilegal_anims:playPlayerAnimation"
function L23_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  if A0_2 then
    L1_2 = A0_2.dict
    if L1_2 then
      L1_2 = A0_2.anim
      if L1_2 then
        L1_2 = A0_2.propName
        if L1_2 then
          goto lbl_17
        end
      end
    end
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Error: Incomplete data for the player animation"
  L1_2(L2_2)
  L1_2 = false
  do return L1_2 end
  ::lbl_17::
  L1_2 = A0_2.position
  if L1_2 then
    L1_2 = A0_2.heading
    if L1_2 then
      goto lbl_28
    end
  end
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Error: Position or heading not provided for the animation"
  L1_2(L2_2)
  L1_2 = false
  do return L1_2 end
  ::lbl_28::
  L1_2 = PlayerPedId
  L1_2 = L1_2()
  L2_2 = ClearPedTasks
  L3_2 = L1_2
  L2_2(L3_2)
  L2_2 = TaskGoStraightToCoord
  L3_2 = L1_2
  L4_2 = A0_2.position
  L4_2 = L4_2.x
  L5_2 = A0_2.position
  L5_2 = L5_2.y
  L6_2 = A0_2.position
  L6_2 = L6_2.z
  L7_2 = 1.0
  L8_2 = -1
  L9_2 = A0_2.heading
  L10_2 = 0.1
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L2_2 = 0.5
  L3_2 = 5000
  L4_2 = GetGameTimer
  L4_2 = L4_2()
  while true do
    L5_2 = GetEntityCoords
    L6_2 = L1_2
    L5_2 = L5_2(L6_2)
    L6_2 = A0_2.position
    L6_2 = L5_2 - L6_2
    L6_2 = #L6_2
    if L2_2 > L6_2 then
      break
    end
    L7_2 = GetGameTimer
    L7_2 = L7_2()
    L7_2 = L7_2 - L4_2
    if L3_2 < L7_2 then
      L7_2 = SetEntityCoords
      L8_2 = L1_2
      L9_2 = A0_2.position
      L9_2 = L9_2.x
      L10_2 = A0_2.position
      L10_2 = L10_2.y
      L11_2 = A0_2.position
      L11_2 = L11_2.z
      L12_2 = false
      L13_2 = false
      L14_2 = false
      L15_2 = false
      L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
      break
    end
    L7_2 = Wait
    L8_2 = 100
    L7_2(L8_2)
  end
  L5_2 = SetEntityCoordsNoOffset
  L6_2 = L1_2
  L7_2 = A0_2.position
  L7_2 = L7_2.x
  L8_2 = A0_2.position
  L8_2 = L8_2.y
  L9_2 = A0_2.position
  L9_2 = L9_2.z
  L10_2 = false
  L11_2 = false
  L12_2 = false
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L5_2 = SetEntityHeading
  L6_2 = L1_2
  L7_2 = A0_2.heading
  L5_2(L6_2, L7_2)
  L5_2 = lib
  L5_2 = L5_2.requestAnimDict
  L6_2 = A0_2.dict
  L5_2 = L5_2(L6_2)
  if L5_2 then
    L6_2 = type
    L7_2 = L5_2
    L6_2 = L6_2(L7_2)
    if "table" == L6_2 then
      L6_2 = L5_2.await
      if L6_2 then
        L6_2 = L5_2.await
        L6_2()
      end
    end
  end
  L6_2 = TaskPlayAnim
  L7_2 = L1_2
  L8_2 = A0_2.dict
  L9_2 = A0_2.anim
  L10_2 = 8.0
  L11_2 = 8.0
  L12_2 = -1
  L13_2 = 0
  L14_2 = 0
  L15_2 = false
  L16_2 = false
  L17_2 = false
  L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L6_2 = RemoveAnimDict
  L7_2 = A0_2.dict
  L6_2(L7_2)
  L6_2 = TriggerServerEvent
  L7_2 = "ilegal_anims:syncAnimation"
  L8_2 = A0_2.dict
  L9_2 = A0_2.anim
  L10_2 = -1
  L6_2(L7_2, L8_2, L9_2, L10_2)
  L6_2 = Wait
  L7_2 = 600
  L6_2(L7_2)
  L6_2 = true
  return L6_2
end
L21_1(L22_1, L23_1)
L21_1 = AddEventHandler
L22_1 = "onResourceStop"
function L23_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if L1_2 ~= A0_2 then
    return
  end
  L1_2 = useTarget
  if L1_2 then
    L1_2 = pairs
    L2_2 = L14_1
    L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
    for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
      L7_2 = TargetRemoveZone
      L8_2 = L6_2
      L7_2(L8_2)
    end
    L1_2 = {}
    L14_1 = L1_2
  end
  L1_2 = pairs
  L2_2 = L7_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = DeleteEntity
    L8_2 = L6_2
    L7_2(L8_2)
  end
  L1_2 = pairs
  L2_2 = L8_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = DeleteEntity
    L8_2 = L6_2
    L7_2(L8_2)
  end
  L1_2 = pairs
  L2_2 = L9_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = DeleteEntity
    L8_2 = L6_2.entity
    L7_2(L8_2)
  end
  L1_2 = updateTextUI
  L2_2 = nil
  L1_2(L2_2)
  L1_2 = enableDefault
  L1_2()
  L1_2 = L2_1
  L2_2 = "[ILLEGAL GARAGE] Resource stopped - restored default entity set"
  L1_2(L2_2)
end
L21_1(L22_1, L23_1)
L21_1 = RegisterCommand
L22_1 = "testsound"
function L23_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L2_2 = #A1_2
  if L2_2 < 2 then
    L2_2 = print
    L3_2 = "[SOUND] Usage: /testsound <audioName> <audioRef> [spatial]"
    L2_2(L3_2)
    L2_2 = print
    L3_2 = "[SOUND] Example: /testsound BOLT_LOCK GTAO_APT_DOOR_SOUNDS"
    L2_2(L3_2)
    L2_2 = print
    L3_2 = "[SOUND] Add \"3d\" as 3rd arg for spatial at player coords"
    L2_2(L3_2)
    return
  end
  L2_2 = A1_2[1]
  L3_2 = A1_2[2]
  L4_2 = A1_2[3]
  L4_2 = "3d" == L4_2
  if L4_2 then
    L5_2 = GetEntityCoords
    L6_2 = PlayerPedId
    L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2 = L6_2()
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
    L6_2 = PlaySoundFromCoord
    L7_2 = -1
    L8_2 = L2_2
    L9_2 = L5_2.x
    L10_2 = L5_2.y
    L11_2 = L5_2.z
    L12_2 = L3_2
    L13_2 = true
    L14_2 = 0
    L15_2 = false
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
    L6_2 = print
    L7_2 = "[SOUND] PlaySoundFromCoord: "
    L8_2 = L2_2
    L9_2 = " / "
    L10_2 = L3_2
    L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2
    L6_2(L7_2)
  else
    L5_2 = PlaySoundFrontend
    L6_2 = -1
    L7_2 = L2_2
    L8_2 = L3_2
    L9_2 = true
    L5_2(L6_2, L7_2, L8_2, L9_2)
    L5_2 = print
    L6_2 = "[SOUND] PlaySoundFrontend: "
    L7_2 = L2_2
    L8_2 = " / "
    L9_2 = L3_2
    L6_2 = L6_2 .. L7_2 .. L8_2 .. L9_2
    L5_2(L6_2)
  end
end
L24_1 = true
L21_1(L22_1, L23_1, L24_1)
L21_1 = RegisterCommand
L22_1 = "testautodoors_ig_flow"
function L23_1()
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.AutoOpen
  if not L0_2 then
    L0_2 = print
    L1_2 = "^1[TEST] Config.AutoOpen is false \226\128\148 cannot run flow test^0"
    L0_2(L1_2)
    return
  end
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3
    L0_3 = PlayerPedId
    L0_3 = L0_3()
    L1_3 = 0
    L2_3 = 0
    L3_3 = {}
    function L4_3(A0_4, A1_4)
      local L2_4, L3_4, L4_4, L5_4
      if A1_4 then
        L2_4 = L1_3
        L2_4 = L2_4 + 1
        L1_3 = L2_4
        L2_4 = L3_3
        L2_4 = #L2_4
        L3_4 = L2_4 + 1
        L2_4 = L3_3
        L4_4 = "^2  PASS^0: "
        L5_4 = A0_4
        L4_4 = L4_4 .. L5_4
        L2_4[L3_4] = L4_4
      else
        L2_4 = L2_3
        L2_4 = L2_4 + 1
        L2_3 = L2_4
        L2_4 = L3_3
        L2_4 = #L2_4
        L3_4 = L2_4 + 1
        L2_4 = L3_3
        L4_4 = "^1  FAIL^0: "
        L5_4 = A0_4
        L4_4 = L4_4 .. L5_4
        L2_4[L3_4] = L4_4
      end
    end
    function L5_3(A0_4)
      local L1_4, L2_4, L3_4
      L1_4 = print
      L2_4 = "[TEST] "
      L3_4 = A0_4
      L2_4 = L2_4 .. L3_4
      L1_4(L2_4)
    end
    L6_3 = "prompt_sandy_is_garage_rollup"
    L7_3 = Config
    L7_3 = L7_3.Props
    L7_3 = L7_3.garage_rollup
    L8_3 = L7_3.interactionZone
    L8_3 = L8_3.coords
    L9_3 = vector3
    L10_3 = L8_3.x
    L10_3 = L10_3 + 20.0
    L11_3 = L8_3.y
    L12_3 = L8_3.z
    L9_3 = L9_3(L10_3, L11_3, L12_3)
    L10_3 = L5_3
    L11_3 = "^3========== Full-Flow Auto-Door Test (Illegal Garage) ==========^0"
    L10_3(L11_3)
    L10_3 = L4_3
    L11_3 = "isGarageRollup client helper works"
    L12_3 = L16_1
    L13_3 = "prompt_sandy_is_garage_rollup"
    L12_3 = L12_3(L13_3)
    L12_3 = true == L12_3
    L10_3(L11_3, L12_3)
    L10_3 = L4_3
    L11_3 = "isGarageRollup rejects lifts"
    L12_3 = L16_1
    L13_3 = "prompt_sandy_is_lift"
    L12_3 = L12_3(L13_3)
    L12_3 = false == L12_3
    L10_3(L11_3, L12_3)
    L10_3 = L5_3
    L11_3 = "Step 1: Teleporting outside zone..."
    L10_3(L11_3)
    L10_3 = SetEntityCoordsNoOffset
    L11_3 = L0_3
    L12_3 = L9_3.x
    L13_3 = L9_3.y
    L14_3 = L9_3.z
    L15_3 = false
    L16_3 = false
    L17_3 = false
    L10_3(L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
    L10_3 = Wait
    L11_3 = 500
    L10_3(L11_3)
    L10_3 = GlobalState
    L10_3 = L10_3.ilegal_carwash_locks
    if not L10_3 then
      L10_3 = {}
    end
    L11_3 = L4_3
    L12_3 = "Door starts locked"
    L13_3 = L10_3[L6_3]
    L13_3 = true == L13_3
    L11_3(L12_3, L13_3)
    L11_3 = GlobalState
    L11_3 = L11_3.ilegal_carwash
    if not L11_3 then
      L11_3 = {}
    end
    L12_3 = L4_3
    L13_3 = "Door starts closed"
    L14_3 = L11_3[L6_3]
    L14_3 = not L14_3
    L12_3(L13_3, L14_3)
    L12_3 = L5_3
    L13_3 = "Step 2: Teleporting into zone (door locked)..."
    L12_3(L13_3)
    L12_3 = SetEntityCoordsNoOffset
    L13_3 = L0_3
    L14_3 = L8_3.x
    L15_3 = L8_3.y
    L16_3 = L8_3.z
    L17_3 = false
    L18_3 = false
    L19_3 = false
    L12_3(L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
    L12_3 = Wait
    L13_3 = 1500
    L12_3(L13_3)
    L12_3 = GlobalState
    L12_3 = L12_3.ilegal_carwash
    L11_3 = L12_3 or L11_3
    if not L12_3 then
      L12_3 = {}
      L11_3 = L12_3
    end
    L12_3 = L4_3
    L13_3 = "Locked door does NOT auto-open"
    L14_3 = L11_3[L6_3]
    L14_3 = not L14_3
    L12_3(L13_3, L14_3)
    L12_3 = L5_3
    L13_3 = "Step 3: Teleporting out..."
    L12_3(L13_3)
    L12_3 = SetEntityCoordsNoOffset
    L13_3 = L0_3
    L14_3 = L9_3.x
    L15_3 = L9_3.y
    L16_3 = L9_3.z
    L17_3 = false
    L18_3 = false
    L19_3 = false
    L12_3(L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
    L12_3 = Wait
    L13_3 = 1000
    L12_3(L13_3)
    L12_3 = L5_3
    L13_3 = "Step 4: Unlocking door..."
    L12_3(L13_3)
    L12_3 = TriggerServerEvent
    L13_3 = "ilegal_anims:toggleLock"
    L14_3 = L6_3
    L12_3(L13_3, L14_3)
    L12_3 = Wait
    L13_3 = 1000
    L12_3(L13_3)
    L12_3 = GlobalState
    L12_3 = L12_3.ilegal_carwash_locks
    L10_3 = L12_3 or L10_3
    if not L12_3 then
      L12_3 = {}
      L10_3 = L12_3
    end
    L12_3 = L4_3
    L13_3 = "Door is now unlocked"
    L14_3 = L10_3[L6_3]
    L14_3 = false == L14_3
    L12_3(L13_3, L14_3)
    L12_3 = L5_3
    L13_3 = "Step 5: Teleporting into zone (door unlocked)..."
    L12_3(L13_3)
    L12_3 = SetEntityCoordsNoOffset
    L13_3 = L0_3
    L14_3 = L8_3.x
    L15_3 = L8_3.y
    L16_3 = L8_3.z
    L17_3 = false
    L18_3 = false
    L19_3 = false
    L12_3(L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
    L12_3 = Wait
    L13_3 = 2000
    L12_3(L13_3)
    L12_3 = GlobalState
    L12_3 = L12_3.ilegal_carwash
    L11_3 = L12_3 or L11_3
    if not L12_3 then
      L12_3 = {}
      L11_3 = L12_3
    end
    L12_3 = L4_3
    L13_3 = "Unlocked door auto-opens on zone enter"
    L14_3 = L11_3[L6_3]
    L14_3 = true == L14_3
    L12_3(L13_3, L14_3)
    L12_3 = L5_3
    L13_3 = "Step 6: Waiting for animation to finish..."
    L12_3(L13_3)
    L12_3 = GetGameTimer
    L12_3 = L12_3()
    while true do
      L13_3 = GlobalState
      L13_3 = L13_3.ilegal_carwash_busy
      if not L13_3 then
        L13_3 = {}
      end
      L13_3 = L13_3[L6_3]
      if not L13_3 then
        break
      end
      L13_3 = GetGameTimer
      L13_3 = L13_3()
      L13_3 = L13_3 - L12_3
      L14_3 = 8000
      if not (L13_3 < L14_3) then
        break
      end
      L13_3 = Wait
      L14_3 = 200
      L13_3(L14_3)
    end
    L13_3 = GlobalState
    L13_3 = L13_3.ilegal_carwash_busy
    if not L13_3 then
      L13_3 = {}
    end
    L14_3 = L4_3
    L15_3 = "Busy flag clears after animation"
    L16_3 = L13_3[L6_3]
    L16_3 = not L16_3
    L14_3(L15_3, L16_3)
    L14_3 = L5_3
    L15_3 = "Step 7: Teleporting out of zone..."
    L14_3(L15_3)
    L14_3 = SetEntityCoordsNoOffset
    L15_3 = L0_3
    L16_3 = L9_3.x
    L17_3 = L9_3.y
    L18_3 = L9_3.z
    L19_3 = false
    L20_3 = false
    L21_3 = false
    L14_3(L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3)
    L14_3 = Wait
    L15_3 = Config
    L15_3 = L15_3.AutoOpenCloseDelay
    L15_3 = L15_3 + 2000
    L14_3(L15_3)
    L14_3 = GlobalState
    L14_3 = L14_3.ilegal_carwash
    L11_3 = L14_3 or L11_3
    if not L14_3 then
      L14_3 = {}
      L11_3 = L14_3
    end
    L14_3 = GlobalState
    L14_3 = L14_3.ilegal_carwash_busy
    if not L14_3 then
      L14_3 = {}
    end
    L14_3 = L14_3[L6_3]
    if L14_3 then
      L14_3 = Wait
      L15_3 = 6000
      L14_3(L15_3)
    end
    L14_3 = GlobalState
    L14_3 = L14_3.ilegal_carwash
    L11_3 = L14_3 or L11_3
    if not L14_3 then
      L14_3 = {}
      L11_3 = L14_3
    end
    L14_3 = L4_3
    L15_3 = "Door auto-closes after leaving zone"
    L16_3 = L11_3[L6_3]
    L16_3 = not L16_3
    L14_3(L15_3, L16_3)
    L14_3 = L5_3
    L15_3 = "Step 8: Re-locking door (cleanup)..."
    L14_3(L15_3)
    L14_3 = TriggerServerEvent
    L15_3 = "ilegal_anims:toggleLock"
    L16_3 = L6_3
    L14_3(L15_3, L16_3)
    L14_3 = Wait
    L15_3 = 1000
    L14_3(L15_3)
    L14_3 = GlobalState
    L14_3 = L14_3.ilegal_carwash_locks
    L10_3 = L14_3 or L10_3
    if not L14_3 then
      L14_3 = {}
      L10_3 = L14_3
    end
    L14_3 = L4_3
    L15_3 = "Door re-locked for cleanup"
    L16_3 = L10_3[L6_3]
    L16_3 = true == L16_3
    L14_3(L15_3, L16_3)
    L14_3 = L5_3
    L15_3 = "^3---------- Results ----------^0"
    L14_3(L15_3)
    L14_3 = ipairs
    L15_3 = L3_3
    L14_3, L15_3, L16_3, L17_3 = L14_3(L15_3)
    for L18_3, L19_3 in L14_3, L15_3, L16_3, L17_3 do
      L20_3 = print
      L21_3 = "[TEST] "
      L22_3 = L19_3
      L21_3 = L21_3 .. L22_3
      L20_3(L21_3)
    end
    L14_3 = L5_3
    L15_3 = "^3========== "
    L16_3 = L1_3
    L17_3 = " passed, "
    L18_3 = L2_3
    L19_3 = " failed ==========^0"
    L15_3 = L15_3 .. L16_3 .. L17_3 .. L18_3 .. L19_3
    L14_3(L15_3)
    L14_3 = exports
    L14_3 = L14_3.ox_lib
    L15_3 = L14_3
    L14_3 = L14_3.notify
    L16_3 = {}
    L17_3 = "Auto-door flow test: "
    L18_3 = L1_3
    L19_3 = " passed, "
    L20_3 = L2_3
    L21_3 = " failed"
    L17_3 = L17_3 .. L18_3 .. L19_3 .. L20_3 .. L21_3
    L16_3.description = L17_3
    if 0 == L2_3 then
      L17_3 = "success"
      if L17_3 then
        goto lbl_333
      end
    end
    L17_3 = "error"
    ::lbl_333::
    L16_3.type = L17_3
    L16_3.duration = 8000
    L14_3(L15_3, L16_3)
  end
  L0_2(L1_2)
end
L24_1 = true
L21_1(L22_1, L23_1, L24_1)
L21_1 = CreateThread
function L22_1()
  local L0_2, L1_2
  L0_2 = L17_1
  L0_2()
  L0_2 = createInteractionZones
  L0_2()
  L0_2 = createSpawnPoints
  L0_2()
  L0_2 = registerPropStateHandlers
  L0_2()
  L0_2 = L2_1
  L1_2 = "[ILLEGAL GARAGE ANIMS ENABLED] Sistema de props animados iniciado."
  L0_2(L1_2)
end
L21_1(L22_1)
L21_1 = RegisterCommand
L22_1 = "testanims"
function L23_1()
  local L0_2, L1_2, L2_2
  L0_2 = lib
  L0_2 = L0_2.registerContext
  L1_2 = {}
  L1_2.id = "test_anims_menu"
  L2_2 = Config
  L2_2 = L2_2.Messages
  L2_2 = L2_2.menuTitle
  L1_2.title = L2_2
  L2_2 = getTestMenu
  L2_2 = L2_2()
  L1_2.options = L2_2
  L0_2(L1_2)
  L0_2 = lib
  L0_2 = L0_2.showContext
  L1_2 = "test_anims_menu"
  L0_2(L1_2)
end
L24_1 = false
L21_1(L22_1, L23_1, L24_1)
