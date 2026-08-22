-- Moteur principal du context menu (adapté de fb_context/ExportMenu.lua)

local funcTable    = {}
local exportMenuPool
local exportMenu
local itemList     = {}
local submenuList  = {}
local COOLDOWN     = 250
local onCooldown   = false

local function GetMenu(id)
    if not id or id == 0 then return exportMenu end
    return submenuList[id]
end

local function AddItemToList(item)
    table.insert(itemList, item)
    return #itemList
end

local function AddSubmenuToList(sub)
    table.insert(submenuList, sub)
    return #submenuList
end

function InitContextMenu()
    exportMenuPool = MenuPool()

    exportMenuPool.OnInteract = function(screenPos, hitSomething, worldPos, hitEntity, normalDir)
        if onCooldown then return end
        onCooldown = true
        Citizen.CreateThread(function()
            local t = GetGameTimer()
            while GetGameTimer() < t + COOLDOWN do Citizen.Wait(0) end
            onCooldown = false
        end)

        -- Reset
        exportMenuPool:Reset()
        itemList    = {}
        submenuList = {}
        exportMenu  = exportMenuPool:AddMenu()

        -- Appel des callbacks enregistrés
        local toDelete = {}
        for i, func in ipairs(funcTable) do
            local ok, err = pcall(func, screenPos, hitSomething, worldPos, hitEntity, normalDir)
            if not ok then
                table.insert(toDelete, i)
                if err then LogError("epsilon-context callback error: " .. tostring(err)) end
            end
        end
        for i = #toDelete, 1, -1 do table.remove(funcTable, toDelete[i]) end

        -- Afficher uniquement si au moins un item a été ajouté
        if #itemList > 0 then
            exportMenu:Position(screenPos)
            exportMenu:Visible(true)
        end
    end
end

-- ── API publique ───────────────────────────────────────────────────────────────

function ECM_Register(func)
    table.insert(funcTable, func)
    if not exportMenuPool then InitContextMenu() end
    return #funcTable
end

function ECM_AddItem(menuId, title)
    return AddItemToList(GetMenu(menuId):AddItem(title))
end

function ECM_AddSubmenu(menuId, title)
    local sub, item = GetMenu(menuId):AddSubmenu(title)
    return AddSubmenuToList(sub), AddItemToList(item)
end

function ECM_AddSeparator(menuId)
    return AddItemToList(GetMenu(menuId):AddSeparator())
end

function ECM_OnActivate(itemId, func)
    itemList[itemId].OnActivate = func
end
