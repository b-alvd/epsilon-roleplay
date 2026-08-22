-- ═══════════════════════════════════════════════════════════════════
-- epsilon-inventory / server/main.lua
-- ═══════════════════════════════════════════════════════════════════

local activeChars = {}  -- [src] = charId
local itemsCache  = {}  -- [name] = parsed item

local MAX_SLOTS = { items = 40, keys = 20, weapons = 12, clothing = 12 }
local WEAPON_HASH_MAP = {}  -- [itemName] = weaponName (populated from items)

-- ── Cache items ──────────────────────────────────────────────────────────────
local function loadItemsCache()
    local rows = MySQL.query.await('SELECT * FROM items')
    itemsCache  = {}
    WEAPON_HASH_MAP = {}
    for _, r in ipairs(rows or {}) do
        local parsed = (r.data and json.decode(r.data)) or {}
        r.data_parsed = parsed
        itemsCache[r.name] = r
        if parsed.type == 'weapon' and parsed.weapon then
            WEAPON_HASH_MAP[r.name] = parsed.weapon
        end
    end
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    loadItemsCache()
    local count = 0; for _ in pairs(itemsCache) do count = count + 1 end
    print(('[epsilon-inventory] %d items chargés'):format(count))
end)

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function getCategory(itemName)
    local item = itemsCache[itemName]
    if not item then return 'items' end
    local t = item.data_parsed and item.data_parsed.type
    if t == 'weapon'   then return 'weapons'  end
    if t == 'ammo'     then return 'weapons'  end
    if t == 'key'      then return 'keys'     end
    if t == 'clothing' then return 'clothing' end
    return 'items'
end

-- ── Numéro de série ──────────────────────────────────────────────────────────
local SERIAL_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local function generateSerial()
    local s = ''
    for _ = 1, 10 do
        local i = math.random(1, #SERIAL_CHARS)
        s = s .. SERIAL_CHARS:sub(i, i)
    end
    return s:sub(1,4) .. '-' .. s:sub(5)  -- format XXXX-XXXXXX
end

local function isFirearm(itemName)
    local idata = itemsCache[itemName] and itemsCache[itemName].data_parsed or {}
    if idata.type ~= 'weapon' then return false end
    local cat = idata.category
    return cat ~= 'melee' and cat ~= 'throwable'
end

-- Fusionne un patch dans le data JSON d'un player_item (préserve les autres champs)
local function mergeItemData(itemId, charId, patch)
    local rows = MySQL.query.await(
        'SELECT data FROM player_items WHERE id=? AND character_id=?',
        { itemId, charId }
    )
    if not rows or not rows[1] then return false end
    local current = (rows[1].data and json.decode(rows[1].data)) or {}
    for k, v in pairs(patch) do current[k] = v end
    MySQL.update.await('UPDATE player_items SET data=? WHERE id=?',
        { json.encode(current), itemId })
    return true
end

local function findFreeSlot(charId, category)
    local max  = MAX_SLOTS[category] or 40
    local rows = MySQL.query.await(
        'SELECT slot FROM player_items WHERE character_id=? AND category=?',
        { charId, category }
    )
    local used = {}
    for _, r in ipairs(rows or {}) do used[r.slot] = true end
    for i = 1, max do
        if not used[i] then return i end
    end
    return nil
end

local function buildInventory(charId)
    local rows = MySQL.query.await([[
        SELECT pi.id, pi.name, pi.quantity, pi.slot, pi.category, pi.data,
               i.label, i.weight, i.image, i.data AS item_data
        FROM player_items pi
        LEFT JOIN items i ON i.name = pi.name
        WHERE pi.character_id = ?
    ]], { charId })

    local hb = MySQL.query.await(
        'SELECT slot, item_name FROM player_hotbar WHERE character_id=?', { charId }
    )

    local inv = {
        items = {}, keys = {}, weapons = {}, clothing = {},
        hotbar = {}, cash = 0, weight = 0, maxWeight = 30,
    }

    -- Index des items que le joueur possède réellement (name → quantity totale)
    local ownedQty = {}
    for _, r in ipairs(rows or {}) do
        ownedQty[r.name] = (ownedQty[r.name] or 0) + (tonumber(r.quantity) or 0)
    end

    -- Hotbar: tableau de 5 entrées (false = vide pour JSON)
    -- On retire automatiquement les armes jetées ou épuisées
    local hotbarMap = {}
    for _, h in ipairs(hb or {}) do hotbarMap[h.slot] = h.item_name end
    for i = 1, 5 do
        local name = hotbarMap[i]
        if name and itemsCache[name] then
            local qty = ownedQty[name] or 0
            if qty > 0 then
                inv.hotbar[i] = {
                    slot  = i,
                    name  = name,
                    label = itemsCache[name].label,
                    image = itemsCache[name].image,
                }
            else
                -- Nettoyer la BDD silencieusement
                MySQL.update(
                    'DELETE FROM player_hotbar WHERE character_id=? AND slot=?',
                    { charId, i }
                )
            end
        end
    end

    -- Items + calcul cash & poids total
    for _, r in ipairs(rows or {}) do
        local idata    = (r.item_data and json.decode(r.item_data)) or {}
        local cat      = (idata.type == 'ammo') and 'weapons' or r.category
        -- money garde les décimales, tout le reste est entier
        r.quantity = (idata.type == 'money') and tonumber(r.quantity) or math.floor(tonumber(r.quantity) or 0)
        if inv[cat] then
            local instdata = (r.data and json.decode(r.data)) or {}
            local unitWeight = r.weight or 0
            inv.weight = inv.weight + (unitWeight * r.quantity)

            -- L'argent liquide = somme des items de type 'money'
            if idata.type == 'money' then
                inv.cash = inv.cash + r.quantity
            end

            table.insert(inv[cat], {
                id       = r.id,
                name     = r.name,
                label    = r.label or r.name,
                quantity = r.quantity,
                slot     = r.slot,
                category = cat,
                weight   = unitWeight,
                idata    = idata,
                data     = instdata,
                image    = r.image,
            })
        end
    end

    inv.weight = math.floor(inv.weight * 100) / 100  -- arrondi 2 décimales

    -- Injecter faim/soif depuis epsilon-status
    local ok, status = pcall(function()
        return exports['epsilon-status']:GetStatus(charId)
    end)
    if ok and status then
        inv.hunger = math.floor(status.hunger + 0.5)
        inv.thirst = math.floor(status.thirst + 0.5)
        local okp, paused = pcall(function() return exports['epsilon-status']:IsPaused(charId) end)
        inv.statusPaused = okp and paused or false
    end

    return inv
end

local playerNames = {}  -- [src] = "Prénom Nom"

local function pushInventory(src)
    local charId = activeChars[src]
    if not charId then return end
    local inv = buildInventory(charId)
    inv.playerName = playerNames[src] or 'Joueur'
    TriggerClientEvent('epsilon:inventory:load', src, inv)
end

-- ── Activer personnage ───────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:setActiveChar', function(charId, firstName, lastName)
    local src = source
    activeChars[src] = charId
    if firstName then
        playerNames[src] = firstName .. ' ' .. (lastName or '')
    end
    pushInventory(src)
end)

AddEventHandler('playerDropped', function()
    activeChars[source] = nil
    playerNames[source] = nil
end)

-- ── Récupérer le perso actif si la resource démarre en cours de session ───────
local function fetchAndPush(src, charId)
    -- Récupère le nom s'il n'est pas en mémoire (après ensure/restart)
    if not playerNames[src] then
        local rows = MySQL.query.await(
            'SELECT firstname, lastname FROM characters WHERE id=?', { charId })
        if rows and rows[1] then
            playerNames[src] = rows[1].firstname .. ' ' .. (rows[1].lastname or '')
        end
    end
    activeChars[src] = charId
    TriggerClientEvent('epsilon:inventory:setCharId', src, charId)
    pushInventory(src)
end

RegisterNetEvent('epsilon:inventory:requestInventory', function()
    local src = source
    if activeChars[src] then
        fetchAndPush(src, activeChars[src])
        return
    end
    -- Chercher via epsilon-characters
    local ok, player = pcall(function()
        return exports['epsilon-characters']:GetPlayer(src)
    end)
    if not ok or not player or not player.db_id then return end
    local rows = MySQL.query.await(
        'SELECT id FROM characters WHERE player_id=? ORDER BY last_played DESC LIMIT 1',
        { player.db_id }
    )
    if not rows or not rows[1] then return end
    fetchAndPush(src, rows[1].id)
end)

-- ── API publique (exports) ───────────────────────────────────────────────────
local MAX_WEIGHT = 30

local function addItem(charId, name, quantity, instData)
    if not itemsCache[name] then return false, 'Item inconnu: ' .. tostring(name) end
    quantity = quantity or 1
    local category = getCategory(name)
    local idata    = itemsCache[name].data_parsed or {}
    local isWeapon = idata.type == 'weapon'

    -- Vérification du poids
    local itemWeight = (itemsCache[name].weight or 0) * quantity
    local rows_w = MySQL.query.await([[
        SELECT COALESCE(SUM(i.weight * pi.quantity), 0) AS total
        FROM player_items pi LEFT JOIN items i ON i.name = pi.name
        WHERE pi.character_id = ?
    ]], { charId })
    local currentWeight = tonumber(rows_w and rows_w[1] and rows_w[1].total) or 0
    if currentWeight + itemWeight > MAX_WEIGHT then
        return false, 'Inventaire trop lourd'
    end

    -- Stackable : armes non stackées (instance unique pour les données ammo/composants)
    if not isWeapon then
        local existing = MySQL.query.await(
            'SELECT id, quantity FROM player_items WHERE character_id=? AND name=? AND category=? LIMIT 1',
            { charId, name, category }
        )
        if existing and existing[1] then
            MySQL.update.await('UPDATE player_items SET quantity=quantity+? WHERE id=?',
                { quantity, existing[1].id })
            return true
        end
    end

    local slot = findFreeSlot(charId, category)
    if not slot then return false, 'Inventaire plein' end

    -- Numéro de série : auto-généré pour toute arme à feu
    local finalData = {}
    for k, v in pairs(instData or {}) do finalData[k] = v end

    if isFirearm(name) then
        if finalData.noSerial then
            -- Arme intentionnellement sans N/S (illégale)
            finalData.serial        = nil
            finalData.serialErased  = false
            finalData.noSerial      = nil
        elseif not finalData.serial then
            -- Cas normal : génération automatique
            finalData.serial        = generateSerial()
            finalData.serialErased  = false
        end
        -- Si serial déjà fourni (transfert, restauration), on le conserve tel quel
    end

    MySQL.insert.await(
        'INSERT INTO player_items (character_id, name, quantity, slot, category, data) VALUES (?,?,?,?,?,?)',
        { charId, name, quantity, slot, category, json.encode(finalData) }
    )
    return true
end

local function removeItem(charId, name, quantity)
    quantity = quantity or 1
    local rows = MySQL.query.await(
        'SELECT id, quantity FROM player_items WHERE character_id=? AND name=? ORDER BY quantity ASC',
        { charId, name }
    )
    if not rows or #rows == 0 then return false end
    local rem = quantity
    for _, r in ipairs(rows) do
        if rem <= 0 then break end
        r.quantity = tonumber(r.quantity)
        if r.quantity <= rem then
            MySQL.update.await('DELETE FROM player_items WHERE id=?', { r.id })
            rem = rem - r.quantity
        else
            MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=?', { rem, r.id })
            rem = 0
        end
    end
    return rem == 0
end

local function hasItem(charId, name, quantity)
    quantity = quantity or 1
    local rows = MySQL.query.await(
        'SELECT COALESCE(SUM(quantity),0) AS total FROM player_items WHERE character_id=? AND name=?',
        { charId, name }
    )
    return rows and rows[1] and (tonumber(rows[1].total) or 0) >= quantity
end

local function addCash(charId, amount)
    amount = math.floor((tonumber(amount) or 0) * 100) / 100
    if amount <= 0 then return false end
    MySQL.update.await('UPDATE characters SET cash = cash + ? WHERE id=?', { amount, charId })
    return true
end

local function removeCash(charId, amount)
    amount = math.floor((tonumber(amount) or 0) * 100) / 100
    if amount <= 0 then return false end
    local rows = MySQL.query.await('SELECT cash FROM characters WHERE id=?', { charId })
    local current = (rows and rows[1] and tonumber(rows[1].cash)) or 0
    if current < amount then return false end
    MySQL.update.await('UPDATE characters SET cash = cash - ? WHERE id=?', { amount, charId })
    return true
end

local function getCash(charId)
    local rows = MySQL.query.await('SELECT cash FROM characters WHERE id=?', { charId })
    return (rows and rows[1] and tonumber(rows[1].cash)) or 0
end

exports('AddItem',       addItem)
exports('RemoveItem',    removeItem)
exports('HasItem',       hasItem)
exports('AddCash',       addCash)
exports('RemoveCash',    removeCash)
exports('GetCash',       getCash)
exports('GetCharId',     function(src) return activeChars[src] end)
exports('PushInventory', function(src) pushInventory(src) end)

-- ── NUI: déplacer item ───────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:moveItem', function(itemId, toSlot, toCategory)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    local item = MySQL.query.await(
        'SELECT * FROM player_items WHERE id=? AND character_id=?', { itemId, charId })
    if not item or not item[1] then return end
    local fromSlot = item[1].slot
    local fromCat  = item[1].category

    if toCategory == fromCat and toSlot == fromSlot then return end

    -- Vérifier si le slot de destination est occupé
    local dest = MySQL.query.await(
        'SELECT id FROM player_items WHERE character_id=? AND category=? AND slot=?',
        { charId, toCategory, toSlot }
    )
    if dest and dest[1] then
        -- Swap en 3 étapes pour éviter la violation de contrainte unique
        -- 1) Source → slot temporaire
        MySQL.update.await('UPDATE player_items SET slot=9999 WHERE id=?', { itemId })
        -- 2) Dest → ancienne position de la source
        MySQL.update.await('UPDATE player_items SET slot=?, category=? WHERE id=?',
            { fromSlot, fromCat, dest[1].id })
        -- 3) Source (temp) → destination
        MySQL.update.await('UPDATE player_items SET slot=?, category=? WHERE id=?',
            { toSlot, toCategory, itemId })
    else
        MySQL.update.await('UPDATE player_items SET slot=?, category=? WHERE id=?',
            { toSlot, toCategory, itemId })
    end

    pushInventory(src)
end)

-- ── NUI: utiliser item ───────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:useItem', function(itemId)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    local rows = MySQL.query.await(
        'SELECT pi.*, i.label FROM player_items pi LEFT JOIN items i ON i.name=pi.name WHERE pi.id=? AND pi.character_id=?',
        { itemId, charId }
    )
    if not rows or not rows[1] then return end
    local pi    = rows[1]
    local idata = itemsCache[pi.name] and itemsCache[pi.name].data_parsed or {}

    pi.quantity = tonumber(pi.quantity)
    if idata.type == 'consumable' then
        if pi.quantity <= 1 then
            MySQL.update.await('DELETE FROM player_items WHERE id=?', { pi.id })
        else
            MySQL.update.await('UPDATE player_items SET quantity=quantity-1 WHERE id=?', { pi.id })
        end
        -- Effets faim/soif
        local hungerDelta = idata.hunger or 0
        local thirstDelta = idata.thirst or 0
        if hungerDelta ~= 0 or thirstDelta ~= 0 then
            pcall(function()
                exports['epsilon-status']:ModifyStatus(charId, hungerDelta, thirstDelta)
            end)
        end
        TriggerClientEvent('epsilon:inventory:itemUsed', src, {
            name  = pi.name,
            label = pi.label or pi.name,
            idata = idata,
        })
    elseif idata.type == 'weapon' then
        TriggerClientEvent('epsilon:inventory:toggleWeapon', src, pi.name, json.decode(pi.data) or {}, idata)
    else
        TriggerEvent('epsilon:inventory:use:' .. pi.name, src, charId, pi)
    end

    pushInventory(src)
end)

-- ── NUI: jeter item ──────────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:dropItem', function(itemId, quantity, x, y, z)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    local rows = MySQL.query.await(
        'SELECT * FROM player_items WHERE id=? AND character_id=?', { itemId, charId })
    if not rows or not rows[1] then return end
    local pi = rows[1]
    pi.quantity = tonumber(pi.quantity)
    quantity = math.min(quantity or 1, pi.quantity)

    if pi.quantity <= quantity then
        MySQL.update.await('DELETE FROM player_items WHERE id=?', { pi.id })
    else
        MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=?', { quantity, pi.id })
    end

    local groundId = MySQL.insert.await(
        'INSERT INTO ground_items (name, quantity, data, x, y, z) VALUES (?,?,?,?,?,?)',
        { pi.name, quantity, pi.data, x, y, z }
    )

    -- Notifier les clients proches (sera filtré côté client)
    TriggerClientEvent('epsilon:inventory:itemDropped', -1, {
        id = groundId, name = pi.name, quantity = quantity,
        x = x, y = y, z = z,
    })

    pushInventory(src)
end)

-- ── NUI: ramasser item sol ───────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:pickupItem', function(groundId)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    local rows = MySQL.query.await('SELECT * FROM ground_items WHERE id=?', { groundId })
    if not rows or not rows[1] then return end
    local gi = rows[1]
    gi.quantity = tonumber(gi.quantity)

    local ok, err = addItem(charId, gi.name, gi.quantity, json.decode(gi.data) or {})
    if not ok then
        TriggerClientEvent('epsilon:ui:notify', src, { type = 'error', title = 'Inventaire', msg = err or 'Inventaire plein' })
        return
    end

    MySQL.update.await('DELETE FROM ground_items WHERE id=?', { groundId })
    TriggerClientEvent('epsilon:inventory:groundRemoved', -1, groundId)
    pushInventory(src)
end)

-- ── NUI: donner item à un joueur ─────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:giveItem', function(itemId, quantity, targetSrc)
    local src          = source
    local charId       = activeChars[src]
    local targetCharId = activeChars[targetSrc]
    if not charId or not targetCharId then
        TriggerClientEvent('epsilon:ui:notify', src, { type='error', msg='Joueur introuvable' })
        return
    end

    local rows = MySQL.query.await(
        'SELECT * FROM player_items WHERE id=? AND character_id=?', { itemId, charId })
    if not rows or not rows[1] then return end
    local pi = rows[1]
    pi.quantity = tonumber(pi.quantity)
    quantity = math.min(quantity or 1, pi.quantity)

    if pi.quantity <= quantity then
        MySQL.update.await('DELETE FROM player_items WHERE id=?', { pi.id })
    else
        MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=?', { quantity, pi.id })
    end

    local ok, err = addItem(targetCharId, pi.name, quantity, json.decode(pi.data) or {})
    if not ok then
        -- Remboursement
        addItem(charId, pi.name, quantity, json.decode(pi.data) or {})
        TriggerClientEvent('epsilon:ui:notify', src, { type='error', msg=err or 'Inventaire plein' })
        return
    end

    TriggerClientEvent('epsilon:inventory:load', targetSrc, buildInventory(targetCharId))
    pushInventory(src)
end)

-- ── NUI: définir slot hotbar ─────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:setHotbar', function(hotbarSlot, itemName)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    if itemName and itemName ~= '' then
        MySQL.query.await([[
            INSERT INTO player_hotbar (character_id, slot, item_name) VALUES (?,?,?)
            ON DUPLICATE KEY UPDATE item_name=VALUES(item_name)
        ]], { charId, hotbarSlot, itemName })
    else
        MySQL.update.await(
            'DELETE FROM player_hotbar WHERE character_id=? AND slot=?', { charId, hotbarSlot })
    end

    pushInventory(src)
end)

-- ── NUI: items proches au sol ────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:getGroundItems', function(x, y, z)
    local src  = source
    local rows = MySQL.query.await([[
        SELECT gi.id, gi.name, gi.quantity, gi.data, gi.x, gi.y, gi.z,
               i.label, i.weight, i.image, i.data AS item_data
        FROM ground_items gi
        LEFT JOIN items i ON i.name = gi.name
        WHERE SQRT(POW(gi.x-?,2)+POW(gi.y-?,2)+POW(gi.z-?,2)) < 3
    ]], { x, y, z })
    TriggerClientEvent('epsilon:inventory:groundItems', src, rows or {})
end)

-- ── Admin: liste des items ────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:getItems', function()
    local src  = source
    local rows = MySQL.query.await('SELECT * FROM items ORDER BY name ASC')
    TriggerClientEvent('epsilon:inventory:admin:itemsList', src, rows or {})
end)

-- ── Admin: créer/modifier item ────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:saveItem', function(item)
    local src = source
    if not item or not item.name or not item.label then return end

    MySQL.query.await([[
        INSERT INTO items (name, label, weight, data, image) VALUES (?,?,?,?,?)
        ON DUPLICATE KEY UPDATE label=VALUES(label), weight=VALUES(weight),
                                data=VALUES(data), image=VALUES(image)
    ]], {
        item.name:lower():gsub('%s+','_'),
        item.label,
        tonumber(item.weight) or 1,
        type(item.data) == 'table' and json.encode(item.data) or (item.data or '{}'),
        item.image or nil,
    })

    loadItemsCache()
    local rows = MySQL.query.await('SELECT * FROM items ORDER BY name ASC')
    TriggerClientEvent('epsilon:inventory:admin:itemsList', src, rows or {})
    TriggerEvent('epsilon:admin:log', src, nil, 'item_save', item.name, nil)
end)

-- ── Admin: supprimer item ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:deleteItem', function(name)
    local src = source
    MySQL.update.await('DELETE FROM items WHERE name=?', { name })
    loadItemsCache()
    local rows = MySQL.query.await('SELECT * FROM items ORDER BY name ASC')
    TriggerClientEvent('epsilon:inventory:admin:itemsList', src, rows or {})
    TriggerEvent('epsilon:admin:log', src, nil, 'item_delete', name, nil)
end)

-- ── Admin: dupliquer item ─────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:duplicateItem', function(name)
    local src  = source
    local rows = MySQL.query.await('SELECT * FROM items WHERE name=?', { name })
    if not rows or not rows[1] then return end
    local orig    = rows[1]
    local newName = orig.name .. '_copy'
    MySQL.insert.await(
        'INSERT IGNORE INTO items (name, label, weight, data, image) VALUES (?,?,?,?,?)',
        { newName, orig.label .. ' (copie)', orig.weight, orig.data, orig.image }
    )
    loadItemsCache()
    local all = MySQL.query.await('SELECT * FROM items ORDER BY name ASC')
    TriggerClientEvent('epsilon:inventory:admin:itemsList', src, all or {})
    TriggerEvent('epsilon:admin:log', src, nil, 'item_duplicate', name .. ' → ' .. newName, nil)
end)

-- ── Rechargement arme ────────────────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:reloadWeapon', function(weaponItemId, currentAmmo)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end

    local rows = MySQL.query.await([[
        SELECT pi.id, pi.data, i.data AS item_data
        FROM player_items pi LEFT JOIN items i ON i.name=pi.name
        WHERE pi.id=? AND pi.character_id=?
    ]], { weaponItemId, charId })
    if not rows or not rows[1] then return end

    local idata    = (rows[1].item_data and json.decode(rows[1].item_data)) or {}
    local maxAmmo  = idata.maxAmmo  or 0
    local ammoType = idata.ammoType
    if not ammoType or maxAmmo <= 0 then return end

    local needed = maxAmmo - (currentAmmo or 0)
    if needed <= 0 then return end

    local ammoRows = MySQL.query.await(
        'SELECT id, quantity FROM player_items WHERE character_id=? AND name=? ORDER BY quantity DESC LIMIT 1',
        { charId, ammoType:lower() }
    )
    if not ammoRows or not ammoRows[1] then
        TriggerClientEvent('epsilon:inventory:reloadResult', src, 0)
        return
    end
    ammoRows[1].quantity = tonumber(ammoRows[1].quantity)
    if ammoRows[1].quantity <= 0 then
        TriggerClientEvent('epsilon:inventory:reloadResult', src, 0)
        return
    end

    local granted = math.min(needed, ammoRows[1].quantity)
    if ammoRows[1].quantity <= granted then
        MySQL.update.await('DELETE FROM player_items WHERE id=?', { ammoRows[1].id })
    else
        MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=?', { granted, ammoRows[1].id })
    end

    local newLoaded = (currentAmmo or 0) + granted
    mergeItemData(weaponItemId, charId, { loadedAmmo = newLoaded })

    TriggerClientEvent('epsilon:inventory:reloadResult', src, granted)
    pushInventory(src)
end)

-- ── Sauvegarder balles chargées à la dépose ───────────────────────────────────
RegisterNetEvent('epsilon:inventory:saveWeaponAmmo', function(weaponItemId, loadedAmmo)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end
    mergeItemData(weaponItemId, charId, { loadedAmmo = loadedAmmo })
end)

-- ── Consommation throwable (lancé en jeu) ────────────────────────────────────
RegisterNetEvent('epsilon:inventory:consumeThrowable', function(weaponItemId, count)
    local src    = source
    local charId = activeChars[src]
    if not charId then return end
    count = math.max(1, math.floor(count or 1))

    local rows = MySQL.query.await(
        'SELECT id, quantity FROM player_items WHERE id=? AND character_id=?',
        { weaponItemId, charId }
    )
    if not rows or not rows[1] then return end
    local pi = rows[1]
    pi.quantity = tonumber(pi.quantity)

    if pi.quantity <= count then
        MySQL.update.await('DELETE FROM player_items WHERE id=?', { pi.id })
    else
        MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=?', { count, pi.id })
    end
    pushInventory(src)
end)

-- ── Vérification numéro de série ─────────────────────────────────────────────
-- Déclenché par une personne habilitée (police, douane…) sur une arme d'un joueur ciblé.
-- targetItemId : id dans player_items ; targetCharId : character_id du propriétaire.
RegisterNetEvent('epsilon:inventory:checkSerial', function(targetItemId, targetCharId)
    local src = source
    local rows = MySQL.query.await(
        'SELECT pi.data, pi.name, i.label FROM player_items pi LEFT JOIN items i ON i.name=pi.name WHERE pi.id=? AND pi.character_id=?',
        { targetItemId, targetCharId }
    )
    if not rows or not rows[1] then
        TriggerClientEvent('epsilon:inventory:serialResult', src, nil)
        return
    end
    local data   = (rows[1].data and json.decode(rows[1].data)) or {}
    local result = {
        label        = rows[1].label or rows[1].name,
        serial       = data.serial,
        serialErased = data.serialErased or false,
        -- status : 'ok' | 'no_serial' | 'erased'
        status = data.serial and 'ok'
              or (data.serialErased and 'erased' or 'no_serial'),
    }
    TriggerClientEvent('epsilon:inventory:serialResult', src, result)
end)

-- ── Effacement numéro de série ────────────────────────────────────────────────
-- Peut être déclenché par :
--   • un admin (panel admin → targetItemId + targetCharId)
--   • un script criminel (outil d'effacement, passed noSerial=true) → propre inventaire
RegisterNetEvent('epsilon:inventory:eraseSerial', function(targetItemId, targetCharId)
    local src    = source
    local charId = targetCharId or activeChars[src]
    if not charId then return end

    local rows = MySQL.query.await(
        'SELECT data FROM player_items WHERE id=? AND character_id=?',
        { targetItemId, charId }
    )
    if not rows or not rows[1] then return end

    local data = (rows[1].data and json.decode(rows[1].data)) or {}

    if not data.serial and not data.serialErased then
        TriggerClientEvent('epsilon:ui:notify', src, { type='warning', msg='Cette arme n\'a jamais eu de numéro de série' })
        return
    end
    if data.serialErased then
        TriggerClientEvent('epsilon:ui:notify', src, { type='warning', msg='Le numéro de série est déjà effacé' })
        return
    end

    data.serial        = nil
    data.serialErased  = true
    MySQL.update.await('UPDATE player_items SET data=? WHERE id=?',
        { json.encode(data), targetItemId })

    TriggerClientEvent('epsilon:ui:notify', src, { type='success', msg='Numéro de série effacé' })
    -- Rafraîchir l'inventaire du propriétaire si connecté
    for playerSrc, cid in pairs(activeChars) do
        if cid == charId then
            pushInventory(playerSrc)
            break
        end
    end
end)

-- Export pour les ressources externes (police check, scripts criminels)
exports('CheckSerial', function(targetItemId, targetCharId)
    local rows = MySQL.query.await(
        'SELECT data FROM player_items WHERE id=? AND character_id=?',
        { targetItemId, targetCharId }
    )
    if not rows or not rows[1] then return nil end
    local data = (rows[1].data and json.decode(rows[1].data)) or {}
    return {
        serial       = data.serial,
        serialErased = data.serialErased or false,
        status       = data.serial and 'ok' or (data.serialErased and 'erased' or 'no_serial'),
    }
end)

-- ── Admin: donner item à un joueur ────────────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:giveItem', function(targetSrc, itemName, quantity)
    local src          = source
    local targetCharId = activeChars[targetSrc]
    if not targetCharId then
        TriggerClientEvent('epsilon:ui:notify', src, { type='error', msg='Joueur sans personnage actif' })
        return
    end
    local qty = math.max(1, math.floor(quantity or 1))
    local ok, err = addItem(targetCharId, itemName, qty, {})
    if ok then
        TriggerClientEvent('epsilon:inventory:load', targetSrc, buildInventory(targetCharId))
        local itemLabel = (itemsCache[itemName] and itemsCache[itemName].label) or itemName
        TriggerClientEvent('epsilon:ui:notify', src, {
            text = GetPlayerName(targetSrc) .. ' — ' .. itemLabel .. ' x' .. qty .. ' donné',
            color = '#22c55e', icon = 'bi-gift', duration = 4,
        })
        TriggerClientEvent('epsilon:ui:notify', targetSrc, {
            text = 'Vous avez reçu ' .. itemLabel .. ' x' .. qty,
            color = '#22c55e', icon = 'bi-gift', duration = 5,
        })
        TriggerEvent('epsilon:admin:log', src, targetSrc, 'give_item', itemName .. ' x' .. qty, { item = itemName, quantity = qty })
    else
        TriggerClientEvent('epsilon:ui:notify', src, { type='error', msg=err or 'Erreur' })
    end
end)

-- ── Admin: voir l'inventaire d'un joueur ─────────────────────────────────────
RegisterNetEvent('epsilon:inventory:admin:getPlayerInventory', function(targetSrc)
    local src = source
    local targetCharId = activeChars[tonumber(targetSrc)]
    if not targetCharId then
        TriggerClientEvent('epsilon:admin:playerInventory', src, nil)
        return
    end
    local inv = buildInventory(targetCharId)
    TriggerClientEvent('epsilon:admin:playerInventory', src, inv)
end)

-- ── Admin: supprimer un item de l'inventaire d'un joueur ──────────────────────
RegisterNetEvent('epsilon:inventory:admin:removePlayerItem', function(targetSrc, itemId, removeQty)
    local src = source
    local targetCharId = activeChars[tonumber(targetSrc)]
    if not targetCharId or not itemId then return end
    local rows = MySQL.query.await('SELECT quantity FROM player_items WHERE id=? AND character_id=?', { itemId, targetCharId })
    if not rows or not rows[1] then return end
    rows[1].quantity = tonumber(rows[1].quantity)
    local qty = math.min(math.max(1, math.floor(removeQty or 1)), rows[1].quantity)
    if rows[1].quantity <= qty then
        MySQL.update.await('DELETE FROM player_items WHERE id=? AND character_id=?', { itemId, targetCharId })
    else
        MySQL.update.await('UPDATE player_items SET quantity=quantity-? WHERE id=? AND character_id=?', { qty, itemId, targetCharId })
    end
    local inv = buildInventory(targetCharId)
    TriggerClientEvent('epsilon:admin:playerInventory', src, inv)
    TriggerClientEvent('epsilon:inventory:load', tonumber(targetSrc), buildInventory(targetCharId))
    TriggerEvent('epsilon:admin:log', src, targetSrc, 'remove_item', 'item#'..tostring(itemId), { itemId = itemId })
end)
