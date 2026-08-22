-- epsilon-pausemenu — client

local isOpen     = false
local nativeMode = false -- true quand le menu GTA natif est ouvert

-- ── Ouvrir / fermer ───────────────────────────────────────────
local function openMenu()
    if isOpen or nativeMode then return end
    TriggerServerEvent('epsilon:pausemenu:getData')
end

RegisterNetEvent('epsilon:pausemenu:dataResult', function(data)
    if isOpen then return end
    isOpen = true
    TriggerEvent('epsilon:ui:open', 'pausemenu', data)
end)

local function closeMenu()
    if not isOpen then return end
    isOpen = false
    TriggerEvent('epsilon:ui:close')
end

-- ── Interception ESC : seulement quand le menu natif GTA est inactif ──
CreateThread(function()
    while true do
        Wait(0)
        if not nativeMode then
            DisableControlAction(0, 199, true) -- FrontendPauseAlternate (ESC)
            DisableControlAction(0, 200, true) -- FrontendPause (Start manette)

            if IsDisabledControlJustPressed(0, 199) or IsDisabledControlJustPressed(0, 200) then
                if isOpen then closeMenu() else openMenu() end
            end
        end
    end
end)

-- ── Ouvrir le menu GTA natif sur un onglet précis ────────────
-- tabIndex : -1 = Carte (défaut), 6 = Paramètres
local function openNativeMenu(tabIndex)
    closeMenu()
    nativeMode = true
    CreateThread(function()
        Wait(150)
        SetPauseMenuActive(true)
        ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), 0, tabIndex)
        -- Attendre que le joueur ferme le menu natif
        Wait(500)
        while IsPauseMenuActive() do Wait(0) end
        nativeMode = false
    end)
end

-- ── NUI callbacks (relayés depuis epsilon-ui) ─────────────────
AddEventHandler('epsilon:pausemenu:nui:close', function()
    closeMenu()
end)

AddEventHandler('epsilon:pausemenu:nui:tile', function(data)
    local id = data and data.id or ''
    TriggerServerEvent('epsilon:pausemenu:tileClicked', id)

    if id == 'carte' then
        openNativeMenu(-1)      -- onglet Carte
    elseif id == 'reglages' then
        openNativeMenu(6)       -- onglet Paramètres
    end
end)

AddEventHandler('epsilon:pausemenu:nui:openUrl', function(data)
    local url = data and data.url or ''
    if url ~= '' then OpenUrl(url) end
end)

AddEventHandler('epsilon:pausemenu:nui:copyToClipboard', function(data)
    local text = data and data.text or ''
    if text ~= '' then AddTextEntry('FMMC_KEY_TIP1', text) end
end)

AddEventHandler('epsilon:pausemenu:nui:sendReport', function(data)
    TriggerServerEvent('epsilon:pausemenu:sendReport',
        data.type     or 'report',
        data.category or 'autre',
        data.target   or '',
        data.message  or ''
    )
end)
