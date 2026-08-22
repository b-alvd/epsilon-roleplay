local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1
L0_1 = 10
L1_1 = 0.01
L2_1 = 11
L3_1 = L2_1 - 1.0
L4_1 = 1.0
L3_1 = L4_1 / L3_1
function L4_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = 3.0 * A1_2
  L3_2 = 1.0
  L2_2 = L3_2 - L2_2
  L3_2 = 3.0 * A0_2
  L2_2 = L2_2 + L3_2
  return L2_2
end
A = L4_1
function L4_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = 3.0 * A1_2
  L3_2 = 6.0 * A0_2
  L2_2 = L2_2 - L3_2
  return L2_2
end
B = L4_1
function L4_1(A0_2)
  local L1_2
  L1_2 = 3.0 * A0_2
  return L1_2
end
C = L4_1
L4_1 = math
function L5_1(A0_2, A1_2, A2_2)
  local L3_2
  L3_2 = A1_2 - A0_2
  L3_2 = L3_2 * A2_2
  L3_2 = A0_2 + L3_2
  return L3_2
end
L4_1.lerp = L5_1
L4_1 = math
function L5_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2
  L3_2 = A2_2 - A0_2
  L4_2 = A1_2 - A0_2
  L3_2 = L3_2 / L4_2
  return L3_2
end
L4_1.invlerp = L5_1
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = A
  L4_2 = A1_2
  L5_2 = A2_2
  L3_2 = L3_2(L4_2, L5_2)
  L3_2 = L3_2 * A0_2
  L4_2 = B
  L5_2 = A1_2
  L6_2 = A2_2
  L4_2 = L4_2(L5_2, L6_2)
  L3_2 = L3_2 + L4_2
  L3_2 = L3_2 * A0_2
  L4_2 = C
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  L3_2 = L3_2 + L4_2
  L3_2 = L3_2 * A0_2
  return L3_2
end
calcBezier = L4_1
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = A
  L4_2 = A1_2
  L5_2 = A2_2
  L3_2 = L3_2(L4_2, L5_2)
  L3_2 = 3.0 * L3_2
  L3_2 = L3_2 * A0_2
  L3_2 = L3_2 * A0_2
  L4_2 = B
  L5_2 = A1_2
  L6_2 = A2_2
  L4_2 = L4_2(L5_2, L6_2)
  L4_2 = 2.0 * L4_2
  L4_2 = L4_2 * A0_2
  L3_2 = L3_2 + L4_2
  L4_2 = C
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  L3_2 = L3_2 + L4_2
  return L3_2
end
getSlope = L4_1
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L4_2 = 1
  L5_2 = L0_1
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = getSlope
    L9_2 = A1_2
    L10_2 = A2_2
    L11_2 = A3_2
    L8_2 = L8_2(L9_2, L10_2, L11_2)
    if 0.0 == L8_2 then
      return A1_2
    end
    L9_2 = calcBezier
    L10_2 = A1_2
    L11_2 = A2_2
    L12_2 = A3_2
    L9_2 = L9_2(L10_2, L11_2, L12_2)
    L9_2 = L9_2 - A0_2
    L10_2 = L9_2 / L8_2
    A1_2 = A1_2 - L10_2
  end
  return A1_2
end
newtonRaphsonIterate = L4_1
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  if not (A0_2 >= 0 and A0_2 <= 1 and A2_2 >= 0) or not (A2_2 <= 1) then
    L4_2 = error
    L5_2 = "bezier x values must be in [0, 1] range"
    L4_2(L5_2)
  end
  if A0_2 == A1_2 and A2_2 == A3_2 then
    function L4_2(A0_3)
      local L1_3
      return A0_3
    end
    return L4_2
  end
  L4_2 = {}
  L5_2 = 0
  L6_2 = L2_1
  L6_2 = L6_2 - 1
  L7_2 = 1
  for L8_2 = L5_2, L6_2, L7_2 do
    L9_2 = L8_2 + 1
    L10_2 = calcBezier
    L11_2 = L3_1
    L11_2 = L8_2 * L11_2
    L12_2 = A0_2
    L13_2 = A2_2
    L10_2 = L10_2(L11_2, L12_2, L13_2)
    L4_2[L9_2] = L10_2
  end
  function L5_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3
    L1_3 = 0.0
    L2_3 = 1
    L3_3 = L4_2
    L3_3 = #L3_3
    while L2_3 < L3_3 do
      L4_3 = L4_2
      L4_3 = L4_3[L2_3]
      if not (A0_3 >= L4_3) then
        break
      end
      L4_3 = L3_1
      L1_3 = L1_3 + L4_3
      L2_3 = L2_3 + 1
    end
    L2_3 = L2_3 - 1
    L4_3 = L4_2
    L4_3 = L4_3[L2_3]
    L4_3 = A0_3 - L4_3
    L6_3 = L2_3 + 1
    L5_3 = L4_2
    L5_3 = L5_3[L6_3]
    L6_3 = L4_2
    L6_3 = L6_3[L2_3]
    L5_3 = L5_3 - L6_3
    L4_3 = L4_3 / L5_3
    L5_3 = L3_1
    L5_3 = L4_3 * L5_3
    L5_3 = L1_3 + L5_3
    L6_3 = calcBezier
    L7_3 = L5_3
    L8_3 = A0_2
    L9_3 = A2_2
    L6_3 = L6_3(L7_3, L8_3, L9_3)
    L7_3 = getSlope
    L8_3 = L5_3
    L9_3 = A0_2
    L10_3 = A2_2
    L7_3 = L7_3(L8_3, L9_3, L10_3)
    L8_3 = L1_1
    if L7_3 >= L8_3 then
      L8_3 = newtonRaphsonIterate
      L9_3 = A0_3
      L10_3 = L5_3
      L11_3 = A0_2
      L12_3 = A2_2
      L8_3 = L8_3(L9_3, L10_3, L11_3, L12_3)
      L5_3 = L8_3
    end
    return L5_3
  end
  function L6_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    if 0 == A0_3 or 1 == A0_3 then
      return A0_3
    end
    L1_3 = calcBezier
    L2_3 = L5_2
    L3_3 = A0_3
    L2_3 = L2_3(L3_3)
    L3_3 = A1_2
    L4_3 = A3_2
    return L1_3(L2_3, L3_3, L4_3)
  end
  return L6_2
end
bezier = L4_1
L4_1 = {}
L5_1 = {}
L6_1 = 0.25
L7_1 = 0.1
L8_1 = 0.25
L9_1 = 1
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L4_1.ease = L5_1
L5_1 = {}
L6_1 = 0.42
L7_1 = 0
L8_1 = 1
L9_1 = 1
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L4_1.easeIn = L5_1
L5_1 = {}
L6_1 = 0
L7_1 = 0
L8_1 = 0.58
L9_1 = 1
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L4_1.easeOut = L5_1
L5_1 = {}
L6_1 = 0.42
L7_1 = 0
L8_1 = 0.58
L9_1 = 1
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L4_1.easeInOut = L5_1
function L5_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  if A0_2 then
    L6_2 = DoesEntityExist
    L7_2 = A0_2
    L6_2 = L6_2(L7_2)
    if L6_2 then
      goto lbl_9
    end
  end
  do return end
  ::lbl_9::
  L6_2 = GetGameTimer
  L6_2 = L6_2()
  L7_2 = bezier
  L8_2 = 0.42
  L9_2 = 0
  L10_2 = 0.58
  L11_2 = 1
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2)
  L8_2 = type
  L9_2 = A4_2
  L8_2 = L8_2(L9_2)
  if "string" == L8_2 then
    if "easeIn" == A4_2 then
      L8_2 = bezier
      L9_2 = 0.42
      L10_2 = 0
      L11_2 = 1
      L12_2 = 1
      L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2)
      L7_2 = L8_2
    elseif "easeOut" == A4_2 then
      L8_2 = bezier
      L9_2 = 0
      L10_2 = 0
      L11_2 = 0.58
      L12_2 = 1
      L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2)
      L7_2 = L8_2
    elseif "linear" == A4_2 then
      function L8_2(A0_3)
        local L1_3
        return A0_3
      end
      L7_2 = L8_2
    elseif "easeInQuad" == A4_2 then
      function L8_2(A0_3)
        local L1_3
        L1_3 = A0_3 * A0_3
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeOutQuad" == A4_2 then
      function L8_2(A0_3)
        local L1_3
        L1_3 = 2
        L1_3 = L1_3 - A0_3
        L1_3 = A0_3 * L1_3
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeInOutQuad" == A4_2 then
      function L8_2(A0_3)
        local L1_3, L2_3
        L1_3 = 0.5
        if A0_3 < L1_3 then
          L1_3 = 2 * A0_3
          L1_3 = L1_3 * A0_3
          if L1_3 then
            goto lbl_19
          end
        end
        L1_3 = 2 * A0_3
        L2_3 = 4
        L1_3 = L2_3 - L1_3
        L1_3 = L1_3 * A0_3
        L1_3 = -1 + L1_3
        ::lbl_19::
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeInCubic" == A4_2 then
      function L8_2(A0_3)
        local L1_3
        L1_3 = A0_3 * A0_3
        L1_3 = L1_3 * A0_3
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeOutCubic" == A4_2 then
      function L8_2(A0_3)
        local L1_3
        A0_3 = A0_3 - 1
        L1_3 = A0_3 * A0_3
        L1_3 = L1_3 * A0_3
        L1_3 = L1_3 + 1
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeInOutCubic" == A4_2 then
      function L8_2(A0_3)
        local L1_3, L2_3
        L1_3 = 0.5
        if A0_3 < L1_3 then
          L1_3 = 4 * A0_3
          L1_3 = L1_3 * A0_3
          L1_3 = L1_3 * A0_3
          if L1_3 then
            goto lbl_28
          end
        end
        L1_3 = A0_3 - 1
        L2_3 = 2 * A0_3
        L2_3 = L2_3 - 2
        L1_3 = L1_3 * L2_3
        L2_3 = 2 * A0_3
        L2_3 = L2_3 - 2
        L1_3 = L1_3 * L2_3
        L1_3 = L1_3 + 1
        ::lbl_28::
        return L1_3
      end
      L7_2 = L8_2
    elseif "easeInElastic" == A4_2 then
      function L8_2(A0_3)
        local L1_3, L2_3, L3_3, L4_3
        L1_3 = math
        L1_3 = L1_3.pi
        L1_3 = 2 * L1_3
        L1_3 = L1_3 / 3
        if 0 == A0_3 then
          L2_3 = 0
          if L2_3 then
            goto lbl_37
          end
        end
        if 1 == A0_3 then
          L2_3 = 1
          if L2_3 then
            goto lbl_37
          end
        end
        L2_3 = math
        L2_3 = L2_3.pow
        L3_3 = 2
        L4_3 = 10 * A0_3
        L4_3 = L4_3 - 10
        L2_3 = L2_3(L3_3, L4_3)
        L2_3 = -L2_3
        L3_3 = math
        L3_3 = L3_3.sin
        L4_3 = A0_3 * 10
        L4_3 = L4_3 - 10.75
        L4_3 = L4_3 * L1_3
        L3_3 = L3_3(L4_3)
        L2_3 = L2_3 * L3_3
        ::lbl_37::
        return L2_3
      end
      L7_2 = L8_2
    elseif "easeOutElastic" == A4_2 then
      function L8_2(A0_3)
        local L1_3, L2_3, L3_3, L4_3
        L1_3 = math
        L1_3 = L1_3.pi
        L1_3 = 2 * L1_3
        L1_3 = L1_3 / 3
        if 0 == A0_3 then
          L2_3 = 0
          if L2_3 then
            goto lbl_36
          end
        end
        if 1 == A0_3 then
          L2_3 = 1
          if L2_3 then
            goto lbl_36
          end
        end
        L2_3 = math
        L2_3 = L2_3.pow
        L3_3 = 2
        L4_3 = -10 * A0_3
        L2_3 = L2_3(L3_3, L4_3)
        L3_3 = math
        L3_3 = L3_3.sin
        L4_3 = A0_3 * 10
        L4_3 = L4_3 - 0.75
        L4_3 = L4_3 * L1_3
        L3_3 = L3_3(L4_3)
        L2_3 = L2_3 * L3_3
        L2_3 = L2_3 + 1
        ::lbl_36::
        return L2_3
      end
      L7_2 = L8_2
    end
  else
    L8_2 = type
    L9_2 = A4_2
    L8_2 = L8_2(L9_2)
    if "function" == L8_2 then
      L7_2 = A4_2
    end
  end
  function L8_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    L1_3 = math
    L1_3 = L1_3.lerp
    L2_3 = A1_2.x
    L3_3 = A2_2.x
    L4_3 = A0_3
    return L1_3(L2_3, L3_3, L4_3)
  end
  function L9_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    L1_3 = math
    L1_3 = L1_3.lerp
    L2_3 = A1_2.y
    L3_3 = A2_2.y
    L4_3 = A0_3
    return L1_3(L2_3, L3_3, L4_3)
  end
  function L10_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    L1_3 = math
    L1_3 = L1_3.lerp
    L2_3 = A1_2.z
    L3_3 = A2_2.z
    L4_3 = A0_3
    return L1_3(L2_3, L3_3, L4_3)
  end
  L11_2 = CreateThread
  function L12_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3
    while true do
      L0_3 = GetGameTimer
      L0_3 = L0_3()
      L1_3 = math
      L1_3 = L1_3.min
      L2_3 = L6_2
      L2_3 = L0_3 - L2_3
      L3_3 = A3_2
      L2_3 = L2_3 / L3_3
      L3_3 = 1.0
      L1_3 = L1_3(L2_3, L3_3)
      if L1_3 >= 1.0 then
        L2_3 = SetEntityCoords
        L3_3 = A0_2
        L4_3 = A2_2.x
        L5_3 = A2_2.y
        L6_3 = A2_2.z
        L7_3 = false
        L8_3 = false
        L9_3 = false
        L10_3 = false
        L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
        L2_3 = A5_2
        if L2_3 then
          L2_3 = A5_2
          L2_3()
        end
        break
      end
      L2_3 = L7_2
      L3_3 = L1_3
      L2_3 = L2_3(L3_3)
      L3_3 = vector3
      L4_3 = L8_2
      L5_3 = L2_3
      L4_3 = L4_3(L5_3)
      L5_3 = L9_2
      L6_3 = L2_3
      L5_3 = L5_3(L6_3)
      L6_3 = L10_2
      L7_3 = L2_3
      L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3 = L6_3(L7_3)
      L3_3 = L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3)
      L4_3 = SetEntityCoords
      L5_3 = A0_2
      L6_3 = L3_3.x
      L7_3 = L3_3.y
      L8_3 = L3_3.z
      L9_3 = false
      L10_3 = false
      L11_3 = false
      L12_3 = false
      L4_3(L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3)
      L4_3 = Wait
      L5_3 = 0
      L4_3(L5_3)
    end
  end
  L11_2(L12_2)
end
AnimateObjectCoords = L5_1
function L5_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  if A0_2 then
    L6_2 = DoesEntityExist
    L7_2 = A0_2
    L6_2 = L6_2(L7_2)
    if L6_2 then
      goto lbl_9
    end
  end
  do return end
  ::lbl_9::
  L6_2 = GetGameTimer
  L6_2 = L6_2()
  L7_2 = GetEntityRotation
  L8_2 = A0_2
  L9_2 = 0
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = vector3
  L9_2 = A2_2.x
  L10_2 = A1_2.x
  L9_2 = L9_2 - L10_2
  L10_2 = A2_2.y
  L11_2 = A1_2.y
  L10_2 = L10_2 - L11_2
  L11_2 = A2_2.z
  L12_2 = A1_2.z
  L11_2 = L11_2 - L12_2
  L8_2 = L8_2(L9_2, L10_2, L11_2)
  L9_2 = bezier
  L10_2 = 0.42
  L11_2 = 0
  L12_2 = 0.58
  L13_2 = 1
  L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2)
  if "easeIn" == A4_2 then
    L10_2 = bezier
    L11_2 = 0.42
    L12_2 = 0
    L13_2 = 1
    L14_2 = 1
    L10_2 = L10_2(L11_2, L12_2, L13_2, L14_2)
    L9_2 = L10_2
  elseif "easeOut" == A4_2 then
    L10_2 = bezier
    L11_2 = 0
    L12_2 = 0
    L13_2 = 0.58
    L14_2 = 1
    L10_2 = L10_2(L11_2, L12_2, L13_2, L14_2)
    L9_2 = L10_2
  end
  L10_2 = CreateThread
  function L11_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    while true do
      L0_3 = GetGameTimer
      L0_3 = L0_3()
      L1_3 = math
      L1_3 = L1_3.min
      L2_3 = L6_2
      L2_3 = L0_3 - L2_3
      L3_3 = A3_2
      L2_3 = L2_3 / L3_3
      L3_3 = 1.0
      L1_3 = L1_3(L2_3, L3_3)
      if L1_3 >= 1.0 then
        L2_3 = SetEntityRotation
        L3_3 = A0_2
        L4_3 = A2_2.x
        L5_3 = A2_2.y
        L6_3 = A2_2.z
        L7_3 = 0
        L8_3 = true
        L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3)
        L2_3 = A5_2
        if L2_3 then
          L2_3 = A5_2
          L2_3()
        end
        break
      end
      L2_3 = L9_2
      L3_3 = L1_3
      L2_3 = L2_3(L3_3)
      L3_3 = vector3
      L4_3 = A1_2.x
      L5_3 = L8_2.x
      L5_3 = L5_3 * L2_3
      L4_3 = L4_3 + L5_3
      L5_3 = A1_2.y
      L6_3 = L8_2.y
      L6_3 = L6_3 * L2_3
      L5_3 = L5_3 + L6_3
      L6_3 = A1_2.z
      L7_3 = L8_2.z
      L7_3 = L7_3 * L2_3
      L6_3 = L6_3 + L7_3
      L3_3 = L3_3(L4_3, L5_3, L6_3)
      L4_3 = SetEntityRotation
      L5_3 = A0_2
      L6_3 = L3_3.x
      L7_3 = L3_3.y
      L8_3 = L3_3.z
      L9_3 = 0
      L10_3 = true
      L4_3(L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
      L4_3 = Wait
      L5_3 = 0
      L4_3(L5_3)
    end
  end
  L10_2(L11_2)
end
AnimateObjectRotation = L5_1
function L5_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = cache
  L4_2 = L4_2.ped
  L5_2 = TaskPedSlideToCoord
  L6_2 = L4_2
  L7_2 = A0_2.x
  L8_2 = A0_2.y
  L9_2 = A0_2.z
  L10_2 = A1_2
  L11_2 = A2_2 or L11_2
  if not A2_2 then
    L11_2 = 1000
  end
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  L5_2 = GetGameTimer
  L5_2 = L5_2()
  L6_2 = CreateThread
  function L7_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3
    while true do
      L0_3 = GetEntityCoords
      L1_3 = L4_2
      L0_3 = L0_3(L1_3)
      L1_3 = vector3
      L2_3 = A0_2.x
      L3_3 = A0_2.y
      L4_3 = A0_2.z
      L1_3 = L1_3(L2_3, L3_3, L4_3)
      L1_3 = L1_3 - L0_3
      L1_3 = #L1_3
      L2_3 = 0.1
      if not (L1_3 < L2_3) then
        L2_3 = GetGameTimer
        L2_3 = L2_3()
        L3_3 = L5_2
        L2_3 = L2_3 - L3_3
        L3_3 = A2_2
        if not L3_3 then
          L3_3 = 1000
        end
        L3_3 = L3_3 + 2000
        if not (L2_3 > L3_3) then
          goto lbl_38
        end
      end
      L2_3 = SetEntityHeading
      L3_3 = L4_2
      L4_3 = A1_2
      L2_3(L3_3, L4_3)
      L2_3 = A3_2
      if L2_3 then
        L2_3 = A3_2
        L2_3()
      end
      do break end
      ::lbl_38::
      L2_3 = Wait
      L3_3 = 0
      L2_3(L3_3)
    end
  end
  L6_2(L7_2)
end
MovePlayerToPosition = L5_1
