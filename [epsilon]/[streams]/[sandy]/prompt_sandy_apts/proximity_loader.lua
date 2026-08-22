local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1
L0_1 = {}
L1_1 = {}
L2_1 = {}
L3_1 = Config
L3_1 = L3_1.InteriorMode
function L4_1(...)
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.Debug
  if L0_2 then
    L0_2 = print
    L1_2 = ...
    L0_2(L1_2)
  end
end
function L5_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2
  L6_2 = math
  L6_2 = L6_2.sqrt
  L7_2 = A3_2 - A0_2
  L7_2 = L7_2 ^ 2
  L8_2 = A4_2 - A1_2
  L8_2 = L8_2 ^ 2
  L7_2 = L7_2 + L8_2
  L8_2 = A5_2 - A2_2
  L8_2 = L8_2 ^ 2
  L7_2 = L7_2 + L8_2
  return L6_2(L7_2)
end
function L6_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = Config
  L2_2 = L2_2.ExclusionZoneEnabled
  if not L2_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = Config
  L2_2 = L2_2.ExclusionWallPoint1
  L3_2 = Config
  L3_2 = L3_2.ExclusionWallPoint2
  L4_2 = L3_2.x
  L5_2 = L2_2.x
  L4_2 = L4_2 - L5_2
  L5_2 = L2_2.y
  L5_2 = A1_2 - L5_2
  L4_2 = L4_2 * L5_2
  L5_2 = L3_2.y
  L6_2 = L2_2.y
  L5_2 = L5_2 - L6_2
  L6_2 = L2_2.x
  L6_2 = A0_2 - L6_2
  L5_2 = L5_2 * L6_2
  L4_2 = L4_2 - L5_2
  L4_2 = L4_2 < 0
  return L4_2
end
function L7_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2
  L6_2 = A0_2 - A2_2
  L7_2 = A5_2 - A3_2
  L6_2 = L6_2 * L7_2
  L7_2 = A1_2 - A3_2
  L8_2 = A4_2 - A2_2
  L7_2 = L7_2 * L8_2
  L6_2 = L6_2 - L7_2
  L7_2 = math
  L7_2 = L7_2.abs
  L8_2 = L6_2
  L7_2 = L7_2(L8_2)
  L8_2 = 1.0E-4
  if L7_2 > L8_2 then
    L7_2 = false
    return L7_2
  end
  L7_2 = A0_2 - A2_2
  L8_2 = A4_2 - A2_2
  L7_2 = L7_2 * L8_2
  L8_2 = A1_2 - A3_2
  L9_2 = A5_2 - A3_2
  L8_2 = L8_2 * L9_2
  L7_2 = L7_2 + L8_2
  if L7_2 < 0 then
    L8_2 = false
    return L8_2
  end
  L8_2 = A4_2 - A2_2
  L8_2 = L8_2 ^ 2
  L9_2 = A5_2 - A3_2
  L9_2 = L9_2 ^ 2
  L8_2 = L8_2 + L9_2
  L9_2 = L7_2 <= L8_2
  return L9_2
end
function L8_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L3_2 = false
  L4_2 = #A2_2
  L5_2 = 1
  L6_2 = #A2_2
  L7_2 = 1
  for L8_2 = L5_2, L6_2, L7_2 do
    L9_2 = A2_2[L8_2]
    L10_2 = A2_2[L4_2]
    L11_2 = L7_1
    L12_2 = A0_2
    L13_2 = A1_2
    L14_2 = L9_2.x
    L15_2 = L9_2.y
    L16_2 = L10_2.x
    L17_2 = L10_2.y
    L11_2 = L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
    if L11_2 then
      L11_2 = true
      return L11_2
    end
    L11_2 = L9_2.y
    L11_2 = A1_2 < L11_2
    L12_2 = L10_2.y
    L12_2 = A1_2 < L12_2
    L11_2 = L11_2 ~= L12_2
    if L11_2 then
      L3_2 = not L3_2
    end
    L4_2 = L8_2
  end
  return L3_2
end
function L9_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = Config
  L2_2 = L2_2.ExclusionBoxEnabled
  if not L2_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = Config
  L2_2 = L2_2.ExclusionBoxPoints
  if L2_2 then
    L2_2 = Config
    L2_2 = L2_2.ExclusionBoxPoints
    L2_2 = #L2_2
    if not (L2_2 < 3) then
      goto lbl_18
    end
  end
  L2_2 = false
  do return L2_2 end
  ::lbl_18::
  L2_2 = L8_1
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = Config
  L5_2 = L5_2.ExclusionBoxPoints
  return L2_2(L3_2, L4_2, L5_2)
end
function L10_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L3_2 = Config
  L3_2 = L3_2.ApartmentCenter
  L4_2 = L5_1
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = A2_2
  L8_2 = L3_2.x
  L9_2 = L3_2.y
  L10_2 = L3_2.z
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L5_2 = ipairs
  L6_2 = Config
  L6_2 = L6_2.CheckScaling
  L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
  for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
    L11_2 = L10_2.distance
    if L4_2 >= L11_2 then
      L11_2 = L10_2.interval
      return L11_2
    end
  end
  L5_2 = Config
  L5_2 = L5_2.CheckInterval
  return L5_2
end
function L11_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = GetInteriorAtCoords
  L4_2 = A0_2
  L5_2 = A1_2
  L6_2 = A2_2
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  if 0 == L3_2 then
    L4_2 = nil
    return L4_2
  end
  return L3_2
end
function L12_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L4_2 = Citizen
  L4_2 = L4_2.Wait
  L5_2 = 100
  L4_2(L5_2)
  L4_2 = L11_1
  L5_2 = A1_2
  L6_2 = A2_2
  L7_2 = A3_2
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  if not L4_2 then
    L5_2 = L4_1
    L6_2 = "^3[ENTITYSET]^7 Warning: Could not find interior for '"
    L7_2 = A0_2
    L8_2 = "'"
    L6_2 = L6_2 .. L7_2 .. L8_2
    L5_2(L6_2)
    L5_2 = false
    return L5_2
  end
  L5_2 = IsInteriorEntitySetActive
  L6_2 = L4_2
  L7_2 = Config
  L7_2 = L7_2.EntitySetFurniture
  L5_2 = L5_2(L6_2, L7_2)
  if not L5_2 then
    L5_2 = IsInteriorEntitySetActive
    L6_2 = L4_2
    L7_2 = Config
    L7_2 = L7_2.EntitySetFurniture
    L5_2 = L5_2(L6_2, L7_2)
    L6_2 = ActivateInteriorEntitySet
    L7_2 = L4_2
    L8_2 = Config
    L8_2 = L8_2.EntitySetFurniture
    L6_2(L7_2, L8_2)
    L6_2 = Citizen
    L6_2 = L6_2.Wait
    L7_2 = 50
    L6_2(L7_2)
    L6_2 = IsInteriorEntitySetActive
    L7_2 = L4_2
    L8_2 = Config
    L8_2 = L8_2.EntitySetFurniture
    L6_2 = L6_2(L7_2, L8_2)
    if not L6_2 then
      L7_2 = L3_1
      if "furnished" == L7_2 then
        L7_2 = L4_1
        L8_2 = "^1[ENTITYSET]^7 Skipping '"
        L9_2 = A0_2
        L10_2 = "' - interior "
        L11_2 = L4_2
        L12_2 = " doesn't have '"
        L13_2 = Config
        L13_2 = L13_2.EntitySetFurniture
        L14_2 = "' entity set"
        L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
        L7_2(L8_2)
        L7_2 = false
        return L7_2
      end
    end
  end
  L5_2 = DeactivateInteriorEntitySet
  L6_2 = L4_2
  L7_2 = Config
  L7_2 = L7_2.EntitySetFurniture
  L5_2(L6_2, L7_2)
  L5_2 = Citizen
  L5_2 = L5_2.Wait
  L6_2 = 0
  L5_2(L6_2)
  L5_2 = {}
  L6_2 = L3_1
  if "furnished" == L6_2 then
    L6_2 = ActivateInteriorEntitySet
    L7_2 = L4_2
    L8_2 = Config
    L8_2 = L8_2.EntitySetFurniture
    L6_2(L7_2, L8_2)
    L6_2 = table
    L6_2 = L6_2.insert
    L7_2 = L5_2
    L8_2 = Config
    L8_2 = L8_2.EntitySetFurniture
    L6_2(L7_2, L8_2)
    L6_2 = L4_1
    L7_2 = "^2[ENTITYSET]^7 Activated '"
    L8_2 = Config
    L8_2 = L8_2.EntitySetFurniture
    L9_2 = "' for: "
    L10_2 = A0_2
    L11_2 = " (interior: "
    L12_2 = L4_2
    L13_2 = ")"
    L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2
    L6_2(L7_2)
  else
    L6_2 = table
    L6_2 = L6_2.insert
    L7_2 = L5_2
    L8_2 = "shell_only"
    L6_2(L7_2, L8_2)
    L6_2 = L4_1
    L7_2 = "^3[ENTITYSET]^7 Shell only mode for: "
    L8_2 = A0_2
    L7_2 = L7_2 .. L8_2
    L6_2(L7_2)
  end
  L6_2 = RefreshInterior
  L7_2 = L4_2
  L6_2(L7_2)
  L6_2 = L1_1
  L7_2 = {}
  L7_2.interiorId = L4_2
  L7_2.sets = L5_2
  L6_2[A0_2] = L7_2
  L6_2 = true
  return L6_2
end
function L13_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L1_2 = L11_1
  L2_2 = A0_2.x
  L3_2 = A0_2.y
  L4_2 = A0_2.z
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  if not L1_2 then
    L2_2 = L4_1
    L3_2 = "^3[ENTITYSET]^7 Warning: Could not find static interior '"
    L4_2 = A0_2.name
    L5_2 = "'"
    L3_2 = L3_2 .. L4_2 .. L5_2
    L2_2(L3_2)
    L2_2 = false
    return L2_2
  end
  L2_2 = ActivateInteriorEntitySet
  L3_2 = L1_2
  L4_2 = Config
  L4_2 = L4_2.EntitySetFurniture
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = 50
  L2_2(L3_2)
  L2_2 = IsInteriorEntitySetActive
  L3_2 = L1_2
  L4_2 = Config
  L4_2 = L4_2.EntitySetFurniture
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = L3_1
    if "furnished" == L3_2 then
      L3_2 = L4_1
      L4_2 = "^1[ENTITYSET]^7 Skipping static '"
      L5_2 = A0_2.name
      L6_2 = "' - interior "
      L7_2 = L1_2
      L8_2 = " doesn't have '"
      L9_2 = Config
      L9_2 = L9_2.EntitySetFurniture
      L10_2 = "' entity set"
      L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
      L3_2(L4_2)
      L3_2 = false
      return L3_2
    end
  end
  L3_2 = DeactivateInteriorEntitySet
  L4_2 = L1_2
  L5_2 = Config
  L5_2 = L5_2.EntitySetFurniture
  L3_2(L4_2, L5_2)
  L3_2 = Citizen
  L3_2 = L3_2.Wait
  L4_2 = 0
  L3_2(L4_2)
  L3_2 = {}
  L4_2 = L3_1
  if "furnished" == L4_2 then
    L4_2 = ActivateInteriorEntitySet
    L5_2 = L1_2
    L6_2 = Config
    L6_2 = L6_2.EntitySetFurniture
    L4_2(L5_2, L6_2)
    L4_2 = table
    L4_2 = L4_2.insert
    L5_2 = L3_2
    L6_2 = Config
    L6_2 = L6_2.EntitySetFurniture
    L4_2(L5_2, L6_2)
    L4_2 = L4_1
    L5_2 = "^2[ENTITYSET]^7 Activated '"
    L6_2 = Config
    L6_2 = L6_2.EntitySetFurniture
    L7_2 = "' for static: "
    L8_2 = A0_2.name
    L9_2 = " (interior: "
    L10_2 = L1_2
    L11_2 = ")"
    L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
    L4_2(L5_2)
  else
    L4_2 = table
    L4_2 = L4_2.insert
    L5_2 = L3_2
    L6_2 = "shell_only"
    L4_2(L5_2, L6_2)
    L4_2 = L4_1
    L5_2 = "^3[ENTITYSET]^7 Shell only mode for static: "
    L6_2 = A0_2.name
    L5_2 = L5_2 .. L6_2
    L4_2(L5_2)
  end
  L4_2 = RefreshInterior
  L5_2 = L1_2
  L4_2(L5_2)
  L5_2 = A0_2.name
  L4_2 = L2_1
  L6_2 = {}
  L6_2.interiorId = L1_2
  L6_2.sets = L3_2
  L4_2[L5_2] = L6_2
  L4_2 = true
  return L4_2
end
function L14_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = L1_1
  L1_2 = L1_2[A0_2]
  if L1_2 then
    L1_2 = L4_1
    L2_2 = "^1[ENTITYSET]^7 Cleared tracking for: "
    L3_2 = A0_2
    L2_2 = L2_2 .. L3_2
    L1_2(L2_2)
    L1_2 = L1_1
    L1_2[A0_2] = nil
  end
end
function L15_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  if not L1_2 then
    L1_2 = RequestIpl
    L2_2 = A0_2
    L1_2(L2_2)
    L1_2 = L0_1
    L1_2[A0_2] = true
    L1_2 = L4_1
    L2_2 = "^2[PROXIMITY]^7 Loaded: "
    L3_2 = A0_2
    L2_2 = L2_2 .. L3_2
    L1_2(L2_2)
  end
end
function L16_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  if L1_2 then
    L1_2 = L14_1
    L2_2 = A0_2
    L1_2(L2_2)
    L1_2 = RemoveIpl
    L2_2 = A0_2
    L1_2(L2_2)
    L1_2 = L0_1
    L1_2[A0_2] = nil
    L1_2 = L4_1
    L2_2 = "^1[PROXIMITY]^7 Unloaded: "
    L3_2 = A0_2
    L2_2 = L2_2 .. L3_2
    L1_2(L2_2)
  end
end
function L17_1(A0_2)
  local L1_2, L2_2
  L2_2 = A0_2.name
  L1_2 = L0_1
  L1_2 = L1_2[L2_2]
  if not L1_2 then
    L1_2 = L15_1
    L2_2 = A0_2.name
    L1_2(L2_2)
    L1_2 = CreateThread
    function L2_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3
      L0_3 = L12_1
      L1_3 = A0_2.name
      L2_3 = A0_2.x
      L3_3 = A0_2.y
      L4_3 = A0_2.z
      L0_3(L1_3, L2_3, L3_3, L4_3)
    end
    L1_2(L2_2)
  end
end
function L18_1(A0_2)
  local L1_2, L2_2
  L2_2 = A0_2.name
  L1_2 = L0_1
  L1_2 = L1_2[L2_2]
  if L1_2 then
    L1_2 = L16_1
    L2_2 = A0_2.name
    L1_2(L2_2)
  end
end
function L19_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = A0_2.proximityDistance
  if not L2_2 then
    L2_2 = Config
    L2_2 = L2_2.ProximityDistance
  end
  L3_2 = A0_2.zThreshold
  if not L3_2 then
    L3_2 = Config
    L3_2 = L3_2.ProximityZThreshold
  end
  L4_2 = L5_1
  L5_2 = A1_2.x
  L6_2 = A1_2.y
  L7_2 = A1_2.z
  L8_2 = A0_2.x
  L9_2 = A0_2.y
  L10_2 = A0_2.z
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L5_2 = math
  L5_2 = L5_2.abs
  L6_2 = A1_2.z
  L7_2 = A0_2.z
  L6_2 = L6_2 - L7_2
  L5_2 = L5_2(L6_2)
  L6_2 = L2_2 >= L4_2 and L3_2 >= L5_2
  return L6_2
end
function L20_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = Config
  L2_2 = L2_2.AdditionalProximityIPLs
  if not L2_2 then
    return
  end
  L2_2 = ipairs
  L3_2 = Config
  L3_2 = L3_2.AdditionalProximityIPLs
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.name
    if not L8_2 then
      L8_2 = L4_1
      L9_2 = "^1[PROXIMITY]^7 Skipping additional IPL entry with missing name"
      L8_2(L9_2)
    elseif A1_2 then
      L8_2 = L16_1
      L9_2 = L7_2.name
      L8_2(L9_2)
    else
      L8_2 = L7_2.x
      if L8_2 then
        L8_2 = L7_2.y
        if L8_2 then
          L8_2 = L7_2.z
        end
      end
      if not L8_2 then
        L9_2 = L4_1
        L10_2 = "^1[PROXIMITY]^7 Skipping additional IPL '"
        L11_2 = L7_2.name
        L12_2 = "' (missing coordinates)"
        L10_2 = L10_2 .. L11_2 .. L12_2
        L9_2(L10_2)
        L9_2 = L16_1
        L10_2 = L7_2.name
        L9_2(L10_2)
      else
        L9_2 = L19_1
        L10_2 = L7_2
        L11_2 = A0_2
        L9_2 = L9_2(L10_2, L11_2)
        if L9_2 then
          L9_2 = L15_1
          L10_2 = L7_2.name
          L9_2(L10_2)
        else
          L9_2 = L16_1
          L10_2 = L7_2.name
          L9_2(L10_2)
        end
      end
    end
  end
end
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = GetEntityCoords
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = L6_1
  L3_2 = L1_2.x
  L4_2 = L1_2.y
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L2_2 = L9_1
    L3_2 = L1_2.x
    L4_2 = L1_2.y
    L2_2 = L2_2(L3_2, L4_2)
    if not L2_2 then
      goto lbl_34
    end
  end
  L2_2 = ipairs
  L3_2 = Config
  L3_2 = L3_2.IplLocations
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L18_1
    L9_2 = L7_2
    L8_2(L9_2)
  end
  L2_2 = L20_1
  L3_2 = L1_2
  L4_2 = true
  L2_2(L3_2, L4_2)
  do return end
  ::lbl_34::
  L2_2 = ipairs
  L3_2 = Config
  L3_2 = L3_2.IplLocations
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L5_1
    L9_2 = L1_2.x
    L10_2 = L1_2.y
    L11_2 = L1_2.z
    L12_2 = L7_2.x
    L13_2 = L7_2.y
    L14_2 = L7_2.z
    L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
    L9_2 = math
    L9_2 = L9_2.abs
    L10_2 = L1_2.z
    L11_2 = L7_2.z
    L10_2 = L10_2 - L11_2
    L9_2 = L9_2(L10_2)
    L10_2 = Config
    L10_2 = L10_2.ProximityDistance
    if L8_2 <= L10_2 then
      L10_2 = Config
      L10_2 = L10_2.ProximityZThreshold
      if L9_2 <= L10_2 then
        L10_2 = L17_1
        L11_2 = L7_2
        L10_2(L11_2)
    end
    else
      L10_2 = L18_1
      L11_2 = L7_2
      L10_2(L11_2)
    end
  end
  L2_2 = L20_1
  L3_2 = L1_2
  L4_2 = false
  L2_2(L3_2, L4_2)
end
L22_1 = CreateThread
function L23_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = Config
  L0_2 = L0_2.ProximityEnabled
  if not L0_2 then
    L0_2 = L4_1
    L1_2 = "^3[PROXIMITY]^7 Proximity loading is DISABLED"
    L0_2(L1_2)
    return
  end
  while true do
    L0_2 = GetEntityCoords
    L1_2 = PlayerPedId
    L1_2, L2_2, L3_2, L4_2 = L1_2()
    L0_2 = L0_2(L1_2, L2_2, L3_2, L4_2)
    L1_2 = L10_1
    L2_2 = L0_2.x
    L3_2 = L0_2.y
    L4_2 = L0_2.z
    L1_2 = L1_2(L2_2, L3_2, L4_2)
    L2_2 = L21_1
    L2_2()
    L2_2 = Wait
    L3_2 = L1_2
    L2_2(L3_2)
  end
end
L22_1(L23_1)
L22_1 = CreateThread
function L23_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L0_2 = Wait
  L1_2 = 3000
  L0_2(L1_2)
  L0_2 = L4_1
  L1_2 = "^5[ENTITYSET]^7 Initializing static interiors..."
  L0_2(L1_2)
  L0_2 = ipairs
  L1_2 = Config
  L1_2 = L1_2.StaticInteriors
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = 0
    L7_2 = false
    while L6_2 < 5 and not L7_2 do
      L8_2 = L13_1
      L9_2 = L5_2
      L8_2 = L8_2(L9_2)
      L7_2 = L8_2
      if not L7_2 then
        L6_2 = L6_2 + 1
        L8_2 = Wait
        L9_2 = 1000
        L8_2(L9_2)
      end
    end
    if not L7_2 then
      L8_2 = L4_1
      L9_2 = "^1[ENTITYSET]^7 Failed to initialize: "
      L10_2 = L5_2.name
      L9_2 = L9_2 .. L10_2
      L8_2(L9_2)
    end
  end
  L0_2 = L4_1
  L1_2 = "^5[ENTITYSET]^7 Static interior initialization complete!"
  L0_2(L1_2)
end
L22_1(L23_1)
L22_1 = exports
L23_1 = "GetInteriorMode"
function L24_1()
  local L0_2, L1_2
  L0_2 = L3_1
  return L0_2
end
L22_1(L23_1, L24_1)
L22_1 = exports
L23_1 = "SetInteriorMode"
function L24_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  if "shell_only" ~= A0_2 and "furnished" ~= A0_2 then
    L1_2 = false
    return L1_2
  end
  L3_1 = A0_2
  L1_2 = L4_1
  L2_2 = "^5[PROXIMITY]^7 Interior mode changed to: "
  L3_2 = L3_1
  L2_2 = L2_2 .. L3_2
  L1_2(L2_2)
  L1_2 = pairs
  L2_2 = L0_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = ipairs
    L8_2 = Config
    L8_2 = L8_2.IplLocations
    L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
    for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
      L13_2 = L12_2.name
      if L13_2 == L5_2 then
        L13_2 = CreateThread
        function L14_2()
          local L0_3, L1_3, L2_3, L3_3, L4_3
          L0_3 = L12_1
          L1_3 = L12_2.name
          L2_3 = L12_2.x
          L3_3 = L12_2.y
          L4_3 = L12_2.z
          L0_3(L1_3, L2_3, L3_3, L4_3)
        end
        L13_2(L14_2)
        break
      end
    end
  end
  L1_2 = ipairs
  L2_2 = Config
  L2_2 = L2_2.StaticInteriors
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = CreateThread
    function L8_2()
      local L0_3, L1_3
      L0_3 = L13_1
      L1_3 = L6_2
      L0_3(L1_3)
    end
    L7_2(L8_2)
  end
  L1_2 = true
  return L1_2
end
L22_1(L23_1, L24_1)
L22_1 = exports
L23_1 = "GetLoadedIPLsCount"
function L24_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = 0
  L1_2 = pairs
  L2_2 = L0_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2 in L1_2, L2_2, L3_2, L4_2 do
    L0_2 = L0_2 + 1
  end
  return L0_2
end
L22_1(L23_1, L24_1)
L22_1 = exports
L23_1 = "IsIPLLoaded"
function L24_1(A0_2)
  local L1_2
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  L1_2 = true == L1_2
  return L1_2
end
L22_1(L23_1, L24_1)
L22_1 = CreateThread
function L23_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = Wait
  L1_2 = 3000
  L0_2(L1_2)
  L0_2 = L4_1
  L1_2 = "^5[PROXIMITY LOADER]^7 Started!"
  L0_2(L1_2)
  L0_2 = Config
  L0_2 = L0_2.ProximityEnabled
  if L0_2 then
    L0_2 = L4_1
    L1_2 = "^5[PROXIMITY]^7 Proximity: ^2ENABLED^7 | Distance: "
    L2_2 = Config
    L2_2 = L2_2.ProximityDistance
    L3_2 = " | Interval: "
    L4_2 = Config
    L4_2 = L4_2.CheckInterval
    L4_2 = L4_2 / 1000
    L5_2 = "s"
    L1_2 = L1_2 .. L2_2 .. L3_2 .. L4_2 .. L5_2
    L0_2(L1_2)
  else
    L0_2 = L4_1
    L1_2 = "^5[PROXIMITY]^7 Proximity: ^1DISABLED"
    L0_2(L1_2)
  end
  L0_2 = L4_1
  L1_2 = "^5[PROXIMITY]^7 Interior mode: "
  L2_2 = L3_1
  L1_2 = L1_2 .. L2_2
  L0_2(L1_2)
  L0_2 = L4_1
  L1_2 = "^5[PROXIMITY]^7 Static interiors: "
  L2_2 = Config
  L2_2 = L2_2.StaticInteriors
  L2_2 = #L2_2
  L1_2 = L1_2 .. L2_2
  L0_2(L1_2)
end
L22_1(L23_1)
