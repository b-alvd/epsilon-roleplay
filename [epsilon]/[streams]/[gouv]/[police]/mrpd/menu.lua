local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1
L0_1 = {}
L1_1 = {}
L2_1 = false
L3_1 = {}
L4_1 = {}
L5_1 = nil
L6_1 = false
L7_1 = nil
L8_1 = Config
L8_1 = L8_1.ActivateRadius
function L9_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = {}
  L3_2 = pairs
  L4_2 = A0_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2 in L3_2, L4_2, L5_2, L6_2 do
    L8_2 = table
    L8_2 = L8_2.insert
    L9_2 = L2_2
    L10_2 = L7_2
    L8_2(L9_2, L10_2)
  end
  L3_2 = table
  L3_2 = L3_2.sort
  L4_2 = L2_2
  L5_2 = A1_2
  L3_2(L4_2, L5_2)
  L3_2 = 0
  function L4_2()
    local L0_3, L1_3, L2_3
    L0_3 = L3_2
    L0_3 = L0_3 + 1
    L3_2 = L0_3
    L1_3 = L3_2
    L0_3 = L2_2
    L0_3 = L0_3[L1_3]
    if nil == L0_3 then
      L0_3 = nil
      return L0_3
    else
      L1_3 = L3_2
      L0_3 = L2_2
      L0_3 = L0_3[L1_3]
      L2_3 = L3_2
      L1_3 = L2_2
      L2_3 = L1_3[L2_3]
      L1_3 = A0_2
      L1_3 = L1_3[L2_3]
      return L0_3, L1_3
    end
  end
  return L4_2
end
pairsByKeys = L9_1
function L9_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  if nil == A1_2 then
    A1_2 = true
  end
  L2_2 = IsHelpMessageOnScreen
  L2_2 = L2_2()
  if not L2_2 then
    L2_2 = AddTextEntry
    L3_2 = "Notification"
    L4_2 = A0_2
    L2_2(L3_2, L4_2)
    L2_2 = BeginTextCommandDisplayHelp
    L3_2 = "Notification"
    L2_2(L3_2)
    L2_2 = EndTextCommandDisplayHelp
    L3_2 = 0
    L4_2 = false
    L5_2 = false
    L6_2 = -1
    L2_2(L3_2, L4_2, L5_2, L6_2)
  end
end
function L10_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L0_2 = {}
  L1_2 = 1
  L2_2 = Config
  L2_2 = L2_2.Elevators
  L2_2 = #L2_2
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = Config
    L5_2 = L5_2.Elevators
    L5_2 = L5_2[L4_2]
    L6_2 = 1
    L7_2 = L5_2.floors
    L7_2 = #L7_2
    L8_2 = 1
    for L9_2 = L6_2, L7_2, L8_2 do
      L10_2 = L5_2.floors
      L10_2 = L10_2[L9_2]
      L11_2 = table
      L11_2 = L11_2.insert
      L12_2 = L0_2
      L13_2 = {}
      L14_2 = L10_2.coords
      L13_2.coords = L14_2
      L13_2.elevator = L4_2
      L13_2.floor = L9_2
      L11_2(L12_2, L13_2)
    end
  end
  return L0_2
end
function L11_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = mainMenu
  L2_2 = L1_2
  L1_2 = L1_2.Visible
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
end
ShowMenu = L11_1
function L11_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = nil
  L1_2 = Config
  L1_2 = L1_2.MenuPosition
  if L1_2 then
    L1_2 = Config
    L1_2 = L1_2.MenuPositions
    L2_2 = Config
    L2_2 = L2_2.MenuPosition
    L0_2 = L1_2[L2_2]
  end
  L1_2 = NativeUI
  L1_2 = L1_2.CreatePool
  L1_2 = L1_2()
  _menuPool = L1_2
  L1_2 = NativeUI
  L1_2 = L1_2.CreateMenu
  L2_2 = Config
  L2_2 = L2_2.Translation
  L3_2 = Config
  L3_2 = L3_2.Language
  L2_2 = L2_2[L3_2]
  L2_2 = L2_2.menu_header
  L3_2 = Config
  L3_2 = L3_2.Translation
  L4_2 = Config
  L4_2 = L4_2.Language
  L3_2 = L3_2[L4_2]
  L3_2 = L3_2.menu_title
  L4_2 = L0_2.x
  L5_2 = L0_2.y
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2)
  mainMenu = L1_2
  L1_2 = _menuPool
  L2_2 = L1_2
  L1_2 = L1_2.Add
  L3_2 = mainMenu
  L1_2(L2_2, L3_2)
  L1_2 = Citizen
  L1_2 = L1_2.CreateThread
  function L2_2()
    local L0_3, L1_3
    while true do
      L0_3 = Citizen
      L0_3 = L0_3.Wait
      L1_3 = 0
      L0_3(L1_3)
      L0_3 = _menuPool
      L1_3 = L0_3
      L0_3 = L0_3.ProcessMenus
      L0_3(L1_3)
    end
  end
  L1_2(L2_2)
end
MenuSetup = L11_1
function L11_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = Config
  L2_2 = L2_2.Elevators
  L2_2 = L2_2[A0_2]
  L3_2 = mainMenu
  L4_2 = L3_2
  L3_2 = L3_2.Clear
  L3_2(L4_2)
  L3_2 = 1
  L4_2 = L2_2.floors
  L4_2 = #L4_2
  L5_2 = 1
  for L6_2 = L3_2, L4_2, L5_2 do
    L7_2 = mainMenu
    L8_2 = L7_2
    L7_2 = L7_2.AddItem
    L9_2 = NativeUI
    L9_2 = L9_2.CreateItem
    L10_2 = L2_2.floors
    L10_2 = L10_2[L6_2]
    L10_2 = L10_2.label
    L11_2 = ""
    L9_2, L10_2, L11_2 = L9_2(L10_2, L11_2)
    L7_2(L8_2, L9_2, L10_2, L11_2)
    L7_2 = mainMenu
    function L8_2(A0_3, A1_3, A2_3)
      local L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
      L3_3 = A0_2
      L4_3 = A1_2
      L5_3 = Config
      L5_3 = L5_3.Elevators
      L5_3 = L5_3[L3_3]
      L5_3 = L5_3.floors
      L5_3 = L5_3[A2_3]
      L5_3 = L5_3.coords
      L6_3 = A1_2
      if A2_3 ~= L6_3 then
        L6_3 = Teleport
        L7_3 = vector3
        L8_3 = L5_3.x
        L9_3 = L5_3.y
        L10_3 = L5_3.z
        L7_3 = L7_3(L8_3, L9_3, L10_3)
        L8_3 = L5_3.w
        L6_3(L7_3, L8_3)
        L6_3 = ShowMenu
        L7_3 = false
        L6_3(L7_3)
      else
        L6_3 = L9_1
        L7_3 = Config
        L7_3 = L7_3.Translation
        L8_3 = Config
        L8_3 = L8_3.Language
        L7_3 = L7_3[L8_3]
        L7_3 = L7_3.same_floor
        L8_3 = true
        L6_3(L7_3, L8_3)
      end
    end
    L7_2.OnItemSelect = L8_2
  end
  L3_2 = _menuPool
  L4_2 = L3_2
  L3_2 = L3_2.RefreshIndex
  L3_2(L4_2)
  L3_2 = ShowMenu
  L4_2 = true
  L3_2(L4_2)
end
CallMenu = L11_1
function L11_1(A0_2)
  local L1_2
  L1_2 = true
  L2_1 = L1_2
  L1_2 = "menu"
  L5_1 = L1_2
  L1_2 = L3_1
  L1_2 = L1_2[A0_2]
  L4_1 = L1_2
end
function L12_1(A0_2)
  local L1_2
  L1_2 = false
  L2_1 = L1_2
  L1_2 = nil
  L5_1 = L1_2
  L1_2 = {}
  L4_1 = L1_2
end
L13_1 = L10_1
L13_1 = L13_1()
L3_1 = L13_1
L13_1 = MenuSetup
L13_1()
L13_1 = AddEventHandler
L14_1 = "liftMenuClosed"
function L15_1()
  local L0_2, L1_2
  L0_2 = "menu"
  L5_1 = L0_2
end
L13_1(L14_1, L15_1)
L13_1 = Citizen
L13_1 = L13_1.CreateThread
function L14_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  while true do
    L0_2 = Citizen
    L0_2 = L0_2.Wait
    L1_2 = 1000
    L0_2(L1_2)
    L0_2 = PlayerPedId
    L0_2 = L0_2()
    L1_2 = GetEntityCoords
    L2_2 = L0_2
    L1_2 = L1_2(L2_2)
    L2_2 = false
    L3_2 = nil
    L4_2 = 1
    L5_2 = L3_1
    L5_2 = #L5_2
    L6_2 = 1
    for L7_2 = L4_2, L5_2, L6_2 do
      L8_2 = L3_1
      L8_2 = L8_2[L7_2]
      L8_2 = L8_2.coords
      L9_2 = GetDistanceBetweenCoords
      L10_2 = L8_2.x
      L11_2 = L8_2.y
      L12_2 = L8_2.z
      L13_2 = L1_2.x
      L14_2 = L1_2.y
      L15_2 = L1_2.z
      L16_2 = true
      L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
      L10_2 = L8_1
      if L9_2 < L10_2 then
        L2_2 = true
        L3_2 = L7_2
      end
    end
    if L2_2 then
      L4_2 = L6_1
      if not L4_2 then
        goto lbl_45
      end
    end
    if L2_2 then
      L4_2 = L7_1
      ::lbl_45::
      if L4_2 ~= L3_2 then
        L4_2 = true
        L6_1 = L4_2
        L7_1 = L3_2
        L4_2 = L11_1
        L5_2 = L3_2
        L4_2(L5_2)
      end
    end
    if not L2_2 then
      L4_2 = L6_1
      if L4_2 then
        L4_2 = false
        L6_1 = L4_2
        L4_2 = L12_1
        L5_2 = L7_1
        L4_2(L5_2)
      end
    end
  end
end
L13_1(L14_1)
L13_1 = Citizen
L13_1 = L13_1.CreateThread
function L14_1()
  local L0_2, L1_2, L2_2
  while true do
    L0_2 = Citizen
    L0_2 = L0_2.Wait
    L1_2 = 0
    L0_2(L1_2)
    L0_2 = L5_1
    if nil ~= L0_2 then
      L0_2 = L9_1
      L1_2 = Config
      L1_2 = L1_2.Translation
      L2_2 = Config
      L2_2 = L2_2.Language
      L1_2 = L1_2[L2_2]
      L1_2 = L1_2.notification
      L0_2(L1_2)
      L0_2 = IsControlJustReleased
      L1_2 = 0
      L2_2 = 51
      L0_2 = L0_2(L1_2, L2_2)
      if L0_2 then
        L0_2 = L5_1
        if "menu" == L0_2 then
          L0_2 = CallMenu
          L1_2 = L4_1.elevator
          L2_2 = L4_1.floor
          L0_2(L1_2, L2_2)
        end
        L0_2 = nil
        L5_1 = L0_2
      end
    else
      L0_2 = Citizen
      L0_2 = L0_2.Wait
      L1_2 = 500
      L0_2(L1_2)
    end
  end
end
L13_1(L14_1)
