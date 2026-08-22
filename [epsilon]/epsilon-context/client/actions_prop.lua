-- S'asseoir sur chaises, bancs, tabourets, canapés
-- Config dans config_sit.lua

local SEAT_PROPS = {
    -- Chaises bureau / intérieur
    `prop_chair_01`,   `prop_chair_02`,   `prop_chair_03`,   `prop_chair_04`,
    `prop_chair_05`,   `prop_chair_06`,   `prop_chair_07`,   `prop_chair_08`,
    `prop_chair_09`,   `prop_chair_10`,
    `prop_off_chair_01`, `prop_off_chair_02`, `prop_off_chair_03`, `prop_off_chair_04`,
    `prop_off_chair_05`,
    -- Bancs extérieur
    `prop_bench_01`,   `prop_bench_02`,   `prop_bench_03`,
    `prop_bench_04`,   `prop_bench_05`,   `prop_bench_06`,
    `prop_bench_09`,
    -- Tabourets
    `prop_bar_stool_01`,
    -- Canapés / fauteuils
    `prop_couch_01`,   `prop_couch_02`,   `prop_couch_03`,
    `prop_couch_lg_1`, `prop_couch_sm_1`,
    -- Chaises plastique terrasse
    `prop_plastic_chair_01`, `prop_plastic_chair_02`,
    -- Transats / chaises longues
    `prop_sun_lounger_01`,   `prop_sun_lounger_lux`,
    -- Chaises de jardin
    `prop_deckchair_01`,     `prop_deckchair_02`,
    -- Chaise pliante
    `prop_foldchair_01`,
    -- Chaises de restaurant / bar
    `prop_food_ctx_table_01`,
}

local SEAT_SET = {}
for _, h in ipairs(SEAT_PROPS) do SEAT_SET[h] = true end

-- SIT_POSES, SIT_MULTISEAT, SIT_LAYDOWN sont définis dans config_sit.lua
-- Toutes les clés props utilisent des strings (nom du prop)

local LAYDOWN_SET = {}
for propName in pairs(SIT_LAYDOWN.props) do
    LAYDOWN_SET[joaat(propName)] = true
end

local DEFAULT_SEAT_HEIGHT = 0.50

local function getSeatZ(prop)
    local propName = GetEntityArchetypeName(prop)
    local cfg = SIT_MULTISEAT[propName]
    local h = (cfg and cfg.seatHeight) or DEFAULT_SEAT_HEIGHT
    return GetEntityCoords(prop).z + h
end

local function getSeatOffsets(propName)
    local cfg = SIT_MULTISEAT[propName]
    local yOff = (cfg and cfg.yOff) or -0.05
    if not cfg then return { vector3(0.0, yOff, 0.0) } end
    local offsets = {}
    local half = (cfg.count - 1) * cfg.spacing / 2
    for i = 1, cfg.count do
        offsets[i] = vector3(-half + (i - 1) * cfg.spacing, yOff, 0.0)
    end
    return offsets
end

local function getPoseOffset(pose, propName)
    if pose.props and propName then
        local o = pose.props[propName]
        if o then return o.x or 0.0, o.y or 0.0, o.z or 0.0 end
    end
    return pose.x or 0.0, pose.y or 0.0, pose.z or 0.0
end

local _sittingOn  = nil
local _layingOn   = nil
local _sitProp    = nil
local _sitOffset  = nil
local _sitPoseIdx = 1

local function showSitButtons()
    local pose = SIT_POSES[_sitPoseIdx]
    exports['epsilon-ui']:ShowInstructionalButtons({
        { key = '←→', action = 'Changer de pose' },
        { key = 'X',  action = 'Se lever'         },
        { key = _sitPoseIdx .. '/' .. #SIT_POSES, action = pose.label },
    })
end

local function standUp()
    local prop = _sittingOn or _layingOn
    if not prop then return end
    local ped = PlayerPedId()
    _sittingOn = nil
    _layingOn  = nil
    FreezeEntityPosition(prop, false)
    exports['epsilon-ui']:HideInstructionalButtons()
    local front = GetOffsetFromEntityInWorldCoords(prop, 0.0, -1.0, 0.0)
    local isLaying = _layingOn ~= nil
    if isLaying then
        ClearPedTasksImmediately(ped)
        Citizen.CreateThread(function()
            Wait(200)
            SetEntityCoords(ped, front.x, front.y, front.z, false, false, false, false)
            Wait(50)
            ClearPedTasksImmediately(ped)
        end)
    else
        ClearPedTasks(ped)
        Citizen.CreateThread(function()
            Wait(1500)
            SetEntityCoords(ped, front.x, front.y, front.z, false, false, false, false)
        end)
    end
end

-- Applique les offsets de pose dans le repère local du prop
local function applyPoseOffset(ox, oy, oz, seat, ph)
    local rad = math.rad(ph + 180.0)
    return
        seat.x + ox * math.sin(rad) + oy * math.cos(rad),
        seat.y - ox * math.cos(rad) + oy * math.sin(rad),
        seat.z + oz
end

local function startScenarioAt(ped, seat, ph, z, teleport, sittingAnim, ox, oy, oz)
    local sx, sy, sz = seat.x, seat.y, z + oz
    if ox ~= 0.0 or oy ~= 0.0 then
        sx, sy = applyPoseOffset(ox, oy, 0.0, seat, ph)
    end
    TaskStartScenarioAtPosition(ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', sx, sy, sz, ph + 180.0, 0, sittingAnim, teleport)
end

local function applyAnimPose(ped, pose, seat, ph, propName)
    RequestAnimDict(pose.dict)
    while not HasAnimDictLoaded(pose.dict) do Wait(10) end
    local ox, oy, oz = getPoseOffset(pose, propName)
    if ox ~= 0.0 or oy ~= 0.0 or oz ~= 0.0 then
        local nx, ny, nz = applyPoseOffset(ox, oy, oz, seat, ph)
        SetEntityCoords(ped, nx, ny, nz, false, false, false, false)
        Wait(10)
    end
    TaskPlayAnim(ped, pose.dict, pose.name, 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function applySitPose(prop, off)
    local ped      = PlayerPedId()
    local ph       = GetEntityHeading(prop)
    local seat     = GetOffsetFromEntityInWorldCoords(prop, off.x, off.y, off.z)
    local z        = getSeatZ(prop)
    local pose     = SIT_POSES[_sitPoseIdx]
    local propName = GetEntityArchetypeName(prop)
    local ox, oy, oz = getPoseOffset(pose, propName)
    ClearPedTasksImmediately(ped)
    startScenarioAt(ped, seat, ph, z, true, false, ox, oy, oz)
    if pose.type ~= 'scenario' then
        Wait(200)
        applyAnimPose(ped, pose, seat, ph, propName)
    end
end

local function sitOn(prop, offset)
    local ped      = PlayerPedId()
    local ph       = GetEntityHeading(prop)
    local off      = offset or vector3(0.0, -0.05, 0.0)
    local z        = getSeatZ(prop)
    local propName = GetEntityArchetypeName(prop)

    FreezeEntityPosition(prop, true)
    PlaceObjectOnGroundProperly(prop)

    local seat = GetOffsetFromEntityInWorldCoords(prop, off.x, off.y, off.z)
    local pose = SIT_POSES[_sitPoseIdx]
    local ox, oy, oz = getPoseOffset(pose, propName)

    startScenarioAt(ped, seat, ph, z, false, true, ox, oy, oz)
    Wait(1500)

    if pose.type ~= 'scenario' then
        applyAnimPose(ped, pose, seat, ph, propName)
    end

    _sittingOn = prop
    _sitProp   = prop
    _sitOffset = off
    showSitButtons()
end

local function layOn(prop)
    local ped      = PlayerPedId()
    local ph       = GetEntityHeading(prop)
    local propName = GetEntityArchetypeName(prop)
    local cfg   = SIT_LAYDOWN.props[propName] or {}
    local yOff  = cfg.yOff or -0.60
    local zOff  = cfg.z    or 0.0

    FreezeEntityPosition(prop, true)
    PlaceObjectOnGroundProperly(prop)

    local anim = SIT_LAYDOWN.anim
    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do Wait(10) end

    local seatPos = GetOffsetFromEntityInWorldCoords(prop, 0.0, yOff, zOff)
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, seatPos.x, seatPos.y, seatPos.z, false, false, false, false)
    SetEntityHeading(ped, ph + 180.0)
    Wait(150)

    TaskPlayAnim(ped, anim.dict, anim.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    _layingOn = prop
    exports['epsilon-ui']:ShowInstructionalButtons({
        { key = 'X', action = 'Se lever' },
    })
end

ECM_Register(function(screenPos, hitSomething, worldPos, hitEntity, normalDir)
    if not hitSomething then return end
    if not DoesEntityExist(hitEntity) then return end
    if not IsEntityAnObject(hitEntity) then return end
    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(hitEntity)) > 2.5 then return end

    -- Affiche toujours le nom du prop pour faciliter la config
    ECM_AddItem(0, "[ " .. (GetEntityArchetypeName(hitEntity) or "inconnu") .. " ]")

    local model    = GetEntityModel(hitEntity)
    local isSeat   = SEAT_SET[model]
    local isLaydown = LAYDOWN_SET[model]
    if not isSeat and not isLaydown then return end

    if _sittingOn == hitEntity or _layingOn == hitEntity then
        local iStand = ECM_AddItem(0, "Se lever")
        ECM_OnActivate(iStand, standUp)
        return
    end

    if isLaydown then
        local iLay = ECM_AddItem(0, "S'allonger")
        ECM_OnActivate(iLay, function()
            if _sittingOn or _layingOn then standUp() end
            Citizen.CreateThread(function() layOn(hitEntity) end)
        end)
    end

    if isSeat then
        local propName = GetEntityArchetypeName(hitEntity)
        local offsets = getSeatOffsets(propName)
        if #offsets == 1 then
            local iSit = ECM_AddItem(0, "S'asseoir")
            ECM_OnActivate(iSit, function()
                if _sittingOn or _layingOn then standUp() end
                Citizen.CreateThread(function() sitOn(hitEntity, offsets[1]) end)
            end)
        else
            local labels = { "À gauche", "Au milieu", "À droite" }
            local sub = ECM_AddSubmenu(0, "S'asseoir")
            for i, offset in ipairs(offsets) do
                local iSit = ECM_AddItem(sub, labels[i] or ("Place " .. i))
                local o = offset
                ECM_OnActivate(iSit, function()
                    if _sittingOn or _layingOn then standUp() end
                    Citizen.CreateThread(function() sitOn(hitEntity, o) end)
                end)
            end
        end
    end
end)

RegisterKeyMapping('prop_standup', 'Se lever (assis / allongé)', 'keyboard', 'x')
RegisterCommand('prop_standup', function()
    if _sittingOn or _layingOn then standUp() end
end, false)

-- Flèches gauche/droite pour changer de pose
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not _sittingOn then
            Wait(500)
        else
            DisableControlAction(0, 174, true) -- LEFT
            DisableControlAction(0, 175, true) -- RIGHT

            if IsDisabledControlJustPressed(0, 174) then
                _sitPoseIdx = (_sitPoseIdx - 2) % #SIT_POSES + 1
                applySitPose(_sittingOn, _sitOffset or vector3(0.0, -0.05, 0.0))
                showSitButtons()
            elseif IsDisabledControlJustPressed(0, 175) then
                _sitPoseIdx = _sitPoseIdx % #SIT_POSES + 1
                applySitPose(_sittingOn, _sitOffset or vector3(0.0, -0.05, 0.0))
                showSitButtons()
            end
        end
    end
end)

-- Se lever si le prop est supprimé
Citizen.CreateThread(function()
    while true do
        Wait(500)
        local prop = _sittingOn or _layingOn
        if prop and not DoesEntityExist(prop) then standUp() end
    end
end)
