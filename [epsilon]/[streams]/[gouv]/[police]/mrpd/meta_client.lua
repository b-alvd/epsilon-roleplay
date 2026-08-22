local L0_1, L1_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = GetInteriorAtCoordsWithType
  L1_2 = 442.429565
  L2_2 = -985.067
  L3_2 = 29.8852863
  L4_2 = "hei_heist_police_dlc"
  L0_2 = L0_2(L1_2, L2_2, L3_2, L4_2)
  L1_2 = DisableInterior
  L2_2 = L0_2
  L3_2 = true
  L1_2(L2_2, L3_2)
  L1_2 = UnpinInterior
  L2_2 = L0_2
  L1_2(L2_2)
end
L0_1(L1_1)
