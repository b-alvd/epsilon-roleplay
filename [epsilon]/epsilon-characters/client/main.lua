-- epsilon-characters/client/main.lua

local inCharSelect  = false
local hasSpawned    = false
local autoSaveThread = nil
local previewPed    = nil
local previewCam    = nil
local previewBusy   = false
local previewSeq    = 0
local currentSlot   = nil
local currentGender = -1
local currentSpot   = nil
local camPreset     = 'full'
local slotCache     = {} -- cache { skin, outfit, gender } par slot

-- ─────────────────────────────────────────────
-- Espace souterrain isolé (aucune géométrie extérieure)
-- Même technique que le backup confirmé fonctionnel
-- ─────────────────────────────────────────────
local SPOTS = {
    { x = 1088.0, y = -3187.5, z = -39.99, heading = 180.0 },
    { x = 1088.0, y = -3187.5, z = -39.99, heading = 180.0 },
    { x = 1088.0, y = -3187.5, z = -39.99, heading = 180.0 },
}

-- tgtSide < 0 → look-target décalé à l'ouest → ped à droite du centre
local PRESETS = {
    full  = { dist = 2.5, side = 0.0, tgtSide = -0.25, up = 0.3,  tgtZ = 0.1,  fov = 65.0 },
    face  = { dist = 1.0, side = 0.0, tgtSide = -0.10, up = 0.7,  tgtZ = 0.7,  fov = 35.0 },
    torso = { dist = 1.5, side = 0.0, tgtSide = -0.15, up = 0.4,  tgtZ = 0.3,  fov = 45.0 },
    legs  = { dist = 1.5, side = 0.0, tgtSide = -0.15, up = -0.3, tgtZ = -0.4, fov = 50.0 },
    feet  = { dist = 1.0, side = 0.0, tgtSide = -0.10, up = -0.7, tgtZ = -0.8, fov = 40.0 },
}

local SPAWN_ZONES = {
    ls     = { x = -269.13, y = -955.98, z = 31.22, heading = 205.0 },
    paleto = { x = -276.83, y = 6224.84, z = 31.50, heading = 40.0  },
    sandy  = { x = 1853.22, y = 3687.47, z = 34.28, heading = 210.0 },
}

-- ─────────────────────────────────────────────
local function applyOutfit(ped, outfit)
    if not outfit then return end
    if outfit.components then
        for k, v in pairs(outfit.components) do
            local id = tonumber(k)
            if id then SetPedComponentVariation(ped, id, v.drawable or 0, v.texture or 0, 0) end
        end
    end
    if outfit.props then
        for k, v in pairs(outfit.props) do
            local id = tonumber(k)
            if id then
                if (v.drawable or -1) == -1 then ClearPedProp(ped, id)
                else SetPedPropIndex(ped, id, v.drawable, v.texture or 0, true) end
            end
        end
    end
end

local function applyAppearance(ped, skin, gender)
    SetPedDefaultComponentVariation(ped)
    if not skin then return end
    if skin.headBlend then
        local h = skin.headBlend
        SetPedHeadBlendData(ped,
            h.shapeFirst or 0, h.shapeSecond or 0, 0,
            h.skinFirst  or 0, h.skinSecond  or 0, 0,
            h.shapeMix or 0.5, h.skinMix or 0.5, 0.0, false)
    end
    if skin.hair then
        SetPedComponentVariation(ped, 2, skin.hair.style or 0, 0, 0)
        SetPedHairColor(ped, skin.hair.color or 0, skin.hair.highlight or 0)
    end
    if skin.eyeColor ~= nil then SetPedEyeColor(ped, skin.eyeColor) end
    if skin.faceFeatures then
        for k, v in pairs(skin.faceFeatures) do
            local i = tonumber(k); if i then SetPedFaceFeature(ped, i, v) end
        end
    end
    if skin.overlays then
        for k, v in pairs(skin.overlays) do
            local i = tonumber(k)
            if i then
                SetPedHeadOverlay(ped, i, v.index ~= nil and v.index or 255, v.opacity ~= nil and v.opacity or 0.0)
                if v.colorType and v.colorType > 0 then
                    SetPedHeadOverlayColor(ped, i, v.colorType, v.colorId or 0, v.secondColorId or 0)
                end
            end
        end
    end
end

local function setupSkyCam()
    -- PlayerPed reste souterrain (underground streamé), focus streaming sur LS
    local pp = PlayerPedId()
    local s  = SPOTS[1]
    FreezeEntityPosition(pp, true)
    SetEntityVisible(pp, false, false)
    SetEntityCoordsNoOffset(pp, s.x, s.y, s.z, false, false, false)
    SetFocusPosAndVel(-1300.0, -400.0, 220.0, 0.0, 0.0, 0.0)

    if previewCam and DoesCamExist(previewCam) then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(previewCam, false)
    end
    previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(previewCam, -1300.0, -400.0, 220.0)
    PointCamAtCoord(previewCam, -670.0, -900.0, 30.0)
    SetCamFov(previewCam, 55.0)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 0, true, false)
end

-- ─────────────────────────────────────────────
-- Caméra — utilise la position RÉELLE du ped après création
-- ─────────────────────────────────────────────
local function setupCam(pedCoords, heading)
    local p     = PRESETS[camPreset] or PRESETS.full
    local h     = math.rad(heading)
    local fwdX  = math.sin(h)
    local fwdY  = math.cos(h)
    local perpX = -fwdY
    local perpY =  fwdX

    -- Créer la caméra une seule fois; ensuite on déplace sans destroy/recreate
    if not (previewCam and DoesCamExist(previewCam)) then
        if previewCam then DestroyCam(previewCam, false) end
        previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(previewCam, true)
        RenderScriptCams(true, false, 0, true, false)
    end

    SetCamCoord(previewCam,
        pedCoords.x + fwdX * p.dist,
        pedCoords.y + fwdY * p.dist,
        pedCoords.z + p.up)
    PointCamAtCoord(previewCam,
        pedCoords.x + perpX * p.tgtSide,
        pedCoords.y + perpY * p.tgtSide,
        pedCoords.z + p.tgtZ)
    SetCamFov(previewCam, p.fov)
end

-- ─────────────────────────────────────────────
local function teardownPreview()
    if previewPed and DoesEntityExist(previewPed) then
        DeletePed(previewPed); previewPed = nil
    end
    if previewCam and DoesCamExist(previewCam) then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(previewCam, false); previewCam = nil
    end
    local s = Epsilon.Config.Characters.DefaultSpawn
    local pp = PlayerPedId()
    SetEntityVisible(pp, true, false)
    FreezeEntityPosition(pp, false)
    SetEntityCoordsNoOffset(pp, s.x, s.y, s.z, false, false, false)
    currentSlot   = nil; currentGender = -1
    currentSpot   = nil; camPreset     = 'full'
    previewBusy   = false
    ClearOverrideWeather(); ClearWeatherTypePersist()
end

-- ─────────────────────────────────────────────
local function spawnPreviewPed(slot, skin, outfit, gender, skipFade)
    if previewBusy then return end
    previewBusy  = true
    currentSlot  = slot

    local spot      = SPOTS[slot] or SPOTS[1]
    local modelName = (gender == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01'
    local modelHash = GetHashKey(modelName)

    -- Mettre en cache + récupérer si données manquantes
    if skin or outfit then
        slotCache[slot] = { skin = skin, outfit = outfit, gender = gender }
    elseif slotCache[slot] then
        skin   = skin   or slotCache[slot].skin
        outfit = outfit or slotCache[slot].outfit
        gender = slotCache[slot].gender
    end

    ClearFocus()
    if not skipFade then DoScreenFadeOut(300); Wait(350) end

    -- Modèle
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(0) end
    end

    -- Supprimer l'ancien ped
    if previewPed and DoesEntityExist(previewPed) then
        DeletePed(previewPed); previewPed = nil
    end

    -- PlayerPed invisible au spot (pour streaming + intérieur)
    local pp = PlayerPedId()
    FreezeEntityPosition(pp, true)
    SetEntityVisible(pp, false, false)
    SetEntityCoordsNoOffset(pp, spot.x, spot.y, spot.z, false, false, false)

    -- Attendre que l'intérieur souterrain soit streamé (évite le "ped ne charge pas")
    local tStream = GetGameTimer() + 4000
    while not HasCollisionLoadedAroundEntity(pp) and GetGameTimer() < tStream do Wait(100) end

    -- Créer le ped
    previewPed = CreatePed(2, modelHash, spot.x, spot.y, spot.z, spot.heading, false, false)
    SetModelAsNoLongerNeeded(modelHash)

    local t = GetGameTimer() + 5000
    while not DoesEntityExist(previewPed) and GetGameTimer() < t do Wait(50) end

    if DoesEntityExist(previewPed) then
        FreezeEntityPosition(previewPed, true)
        SetEntityVisible(previewPed, true, false)
        SetEntityInvincible(previewPed, true)
        SetBlockingOfNonTemporaryEvents(previewPed, true)
        SetEntityHeading(previewPed, spot.heading)
        Wait(100)
        applyAppearance(previewPed, skin, gender)
        applyOutfit(previewPed, outfit)

        local coords = GetEntityCoords(previewPed)
        currentSpot  = { x = coords.x, y = coords.y, z = coords.z, heading = spot.heading }
        setupCam(coords, spot.heading)
    else
        -- Le ped n'a pas pu être créé: fallback sky cam pour éviter l'écran noir
        setupSkyCam()
    end

    DoScreenFadeIn(500)
    currentGender = gender
    previewBusy   = false
end

local function switchSlot(slot, skin, outfit, gender)
    if currentSlot == slot and currentGender == gender and not previewBusy then
        if previewPed and DoesEntityExist(previewPed) then
            applyAppearance(previewPed, skin, gender)
            applyOutfit(previewPed, outfit)
        end
        return
    end
    previewSeq = previewSeq + 1
    local seq  = previewSeq
    CreateThread(function()
        while previewBusy do
            Wait(50)
            if previewSeq ~= seq then return end
        end
        if currentSlot == slot and currentGender == gender then return end
        if previewSeq == seq then
            spawnPreviewPed(slot, skin, outfit, gender, false)
        end
    end)
end

-- ─────────────────────────────────────────────
-- Init
-- ─────────────────────────────────────────────
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(200) end
    ShutdownLoadingScreen()
    DoScreenFadeOut(0)
    local pp = PlayerPedId()
    SetEntityVisible(pp, false, false)
    FreezeEntityPosition(pp, true)
    -- Précharger les modèles
    for _, name in ipairs({ 'mp_m_freemode_01', 'mp_f_freemode_01' }) do
        local h = GetHashKey(name)
        if not HasModelLoaded(h) then
            RequestModel(h)
            while not HasModelLoaded(h) do Wait(0) end
        end
    end
    -- Aller au spot 1 et charger son intérieur
    local s = SPOTS[1]
    SetEntityCoordsNoOffset(pp, s.x, s.y, s.z, false, false, false)
    Wait(500)
    TriggerServerEvent('epsilon:characters:requestList')
end)

-- HUD
CreateThread(function()
    while true do
        Wait(0)
        if inCharSelect then
            DisableAllControlActions(0)
            DisplayRadar(false)
            HideHudComponentThisFrame(1)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(7)
            -- Maintenir le ped preview sur place (sans bloquer la rotation)
            if previewPed and DoesEntityExist(previewPed) then
                FreezeEntityPosition(previewPed, true)
            end
        end
    end
end)

-- ─────────────────────────────────────────────
-- Événements réseau
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:openUI', function(data)
    inCharSelect = true
    DisplayRadar(false)
    NetworkOverrideClockTime(12, 0, 0)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')

    CreateThread(function()
        local c      = data.characters and data.characters[1] or nil
        local slot   = c and c.slot   or 1
        local gender = c and c.gender or 0
        local skin   = c and c.skin   and json.decode(c.skin)   or nil
        local outfit = c and c.outfit and json.decode(c.outfit) or nil

        if c then
            spawnPreviewPed(slot, skin, outfit, gender, true)
            Wait(200)
        else
            -- Aucun perso: cam cinématique dans le ciel de Los Santos
            setupSkyCam()
            DoScreenFadeIn(500); Wait(600)
        end
        TriggerEvent('epsilon:ui:open', 'characters', data)
    end)
end)

RegisterNetEvent('epsilon:characters:refreshList', function(data)
    TriggerEvent('epsilon:ui:update', 'characters', data)
end)

RegisterNetEvent('epsilon:characters:createError', function(msg)
    Epsilon.Debug.Error('[Characters] Erreur création: %s', msg)
end)

-- ─────────────────────────────────────────────
-- Callbacks NUI
-- ─────────────────────────────────────────────
AddEventHandler('epsilon:characters:nui:setCamPreset', function(data)
    camPreset = PRESETS[data.preset] and data.preset or 'full'
    if currentSpot and previewPed and DoesEntityExist(previewPed) then
        local coords = GetEntityCoords(previewPed)
        -- Toujours utiliser le heading du spot (pas le heading après rotation user)
        -- pour que changer d'onglet ne déplace pas la caméra
        setupCam(coords, currentSpot.heading)
    end
end)

AddEventHandler('epsilon:characters:nui:rotatePreview', function(data)
    if not previewPed or not DoesEntityExist(previewPed) then return end
    local delta = tonumber(data.delta) or 0
    local newH  = (GetEntityHeading(previewPed) - delta * 0.3) % 360
    SetEntityHeading(previewPed, newH)
end)

AddEventHandler('epsilon:characters:nui:clearPreview', function()
    -- Nettoyer l'état complètement avant de respawn
    previewBusy  = false
    previewSeq   = previewSeq + 1  -- annule tout switchSlot en attente
    if previewPed and DoesEntityExist(previewPed) then DeletePed(previewPed); previewPed = nil end
    currentSlot = nil; currentSpot = nil; currentGender = -1

    if slotCache[1] then
        CreateThread(function()
            local c = slotCache[1]
            spawnPreviewPed(1, c.skin, c.outfit, c.gender, false)
        end)
    else
        setupSkyCam()
        DoScreenFadeIn(400)
    end
end)

AddEventHandler('epsilon:characters:nui:selectPreview', function(data)
    CreateThread(function()
        local slot   = data.slot or 1
        local skin   = data.skin   and (type(data.skin)   == 'table' and data.skin   or json.decode(data.skin))   or nil
        local outfit = data.outfit and (type(data.outfit) == 'table' and data.outfit or json.decode(data.outfit)) or nil
        local g      = data.gender or 0
        switchSlot(slot, skin, outfit, g)
    end)
end)

AddEventHandler('epsilon:characters:nui:updateOutfit', function(data)
    local ped = (previewPed and DoesEntityExist(previewPed)) and previewPed or PlayerPedId()
    if data.outfit then applyOutfit(ped, data.outfit) end
end)

AddEventHandler('epsilon:characters:nui:updateAppearance', function(data)
    local ped = (previewPed and DoesEntityExist(previewPed)) and previewPed or PlayerPedId()
    if data.appearance then applyAppearance(ped, data.appearance, data.gender or 0) end
end)

AddEventHandler('epsilon:characters:nui:selectCharacter', function(data)
    TriggerServerEvent('epsilon:characters:select', data.id)
end)

AddEventHandler('epsilon:characters:nui:createCharacter', function(data)
    TriggerServerEvent('epsilon:characters:create', data)
end)

-- ─────────────────────────────────────────────
-- Spawn
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:doSpawn', function(spawnData)
    inCharSelect = false; hasSpawned = true
    DisplayRadar(true)
    TriggerEvent('epsilon:ui:close')

    CreateThread(function()
        local x       = spawnData.x       or Epsilon.Config.Characters.DefaultSpawn.x
        local y       = spawnData.y       or Epsilon.Config.Characters.DefaultSpawn.y
        local z       = spawnData.z       or Epsilon.Config.Characters.DefaultSpawn.z
        local heading = spawnData.heading or Epsilon.Config.Characters.DefaultSpawn.heading

        DoScreenFadeOut(300); Wait(400)
        teardownPreview()

        local modelName = (spawnData.gender == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        local modelHash = GetHashKey(modelName)
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(0) end
        end

        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)
        Wait(100)

        local ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
        SetEntityHeading(ped, heading)
        applyAppearance(ped, spawnData.skin   and json.decode(spawnData.skin)   or nil, spawnData.gender)
        applyOutfit(ped,     spawnData.outfit and json.decode(spawnData.outfit) or nil)
        SetEntityVisible(ped, true, false)
        FreezeEntityPosition(ped, false)
        SetFollowPedCamViewMode(1)

        Wait(200)
        SetEntityCoordsNoOffset(PlayerPedId(), x, y, z, false, false, false)
        NewLoadSceneStart(x, y, z, x, y, z, 25.0, 0)
        local t = GetGameTimer() + 10000
        while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() < t do Wait(200) end
        NewLoadSceneStop()

        DoScreenFadeIn(800); Wait(900)
        Epsilon.Debug.Success('[Spawn] %s %s', spawnData.firstname or '?', spawnData.lastname or '?')
        TriggerEvent('epsilon:spawn:complete', spawnData)
        startAutoSave()
    end)
end)

-- ─────────────────────────────────────────────
-- Auto-save
-- ─────────────────────────────────────────────
function startAutoSave()
    if autoSaveThread then return end
    autoSaveThread = CreateThread(function()
        local interval = (Epsilon.Config.Characters.AutoSaveInterval or 120) * 1000
        while not inCharSelect do
            Wait(interval)
            if not inCharSelect then savePosition() end
        end
        autoSaveThread = nil
    end)
end

function savePosition()
    local ped = PlayerPedId()
    if not ped or ped == 0 or IsEntityDead(ped) then return end
    local c = GetEntityCoords(ped)
    TriggerServerEvent('epsilon:characters:savePosition', {
        x = c.x, y = c.y, z = c.z, heading = GetEntityHeading(ped)
    })
end

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if hasSpawned and not inCharSelect then savePosition() end
end)
