-- epsilon-characters/server/main.lua

local playerCache = {} -- [src] = { db_id, characters }
local joinTimes   = {} -- [src] = os.time() à la connexion

-- ─────────────────────────────────────────────
-- Utilitaires
-- ─────────────────────────────────────────────
local function getIdentifiers(src)
    local license, steam, discord, ip
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id:sub(1,8)  == 'license:' then license = id:sub(9) end
        if id:sub(1,6)  == 'steam:' then steam   = id:sub(7) end
        if id:sub(1,8)  == 'discord:' then discord = id:sub(9) end
        if id:sub(1,3)  == 'ip:' then ip      = id:sub(4) end
    end
    return license, steam, discord, ip
end

local function getOrCreatePlayer(src, cb)
    local license, steam, discord, ip = getIdentifiers(src)
    if not license then
        Epsilon.Debug.Error('[Characters] Joueur %s sans license', src)
        return cb(nil)
    end

    local rows = MySQL.query.await('SELECT id FROM players WHERE license = ?', { license })
    if rows and rows[1] then
        MySQL.query.await('UPDATE players SET steam=?,discord=?,ip=?,name=?,last_join=NOW() WHERE id=?', {
            steam, discord, ip, GetPlayerName(src), rows[1].id
        })
        joinTimes[src] = os.time()
        return cb(rows[1].id)
    end

    local newId = MySQL.insert.await(
        'INSERT INTO players (license,steam,discord,ip,name) VALUES (?,?,?,?,?)',
        { license, steam, discord, ip, GetPlayerName(src) }
    )
    joinTimes[src] = os.time()
    cb(newId)
end

local function fetchCharacters(playerId)
    return MySQL.query.await(
        'SELECT id,slot,firstname,lastname,dob,gender,skin,outfit,cash,pos_x,pos_y,pos_z,pos_heading FROM characters WHERE player_id=? ORDER BY slot ASC',
        { playerId }
    ) or {}
end

local function sendCharacterList(src, playerId, chars)
    playerCache[src] = { db_id = playerId, characters = chars }
    TriggerClientEvent('epsilon:characters:openUI', src, {
        playerUid  = playerId,
        maxSlots   = Epsilon.Config.Characters.MaxPerPlayer or 3,
        characters = chars,
    })
end

-- ─────────────────────────────────────────────
-- Connexion joueur
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:requestList', function()
    local src = source
    getOrCreatePlayer(src, function(playerId)
        if not playerId then
            DropPlayer(src, 'Erreur d\'authentification.')
            return
        end
        local chars = fetchCharacters(playerId)
        sendCharacterList(src, playerId, chars)
    end)
end)

-- ─────────────────────────────────────────────
-- Création de personnage
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:create', function(data)
    local src = source
    local cache = playerCache[src]
    if not cache then return end

    -- Validation
    if not data.firstname or not data.lastname or not data.dob or data.gender == nil then
        TriggerClientEvent('epsilon:characters:createError', src, 'Données manquantes')
        return
    end

    local chars = fetchCharacters(cache.db_id)
    if #chars >= (Epsilon.Config.Characters.MaxPerPlayer or 3) then
        TriggerClientEvent('epsilon:characters:createError', src, 'Nombre max de personnages atteint')
        return
    end

    -- Trouver un slot libre
    local usedSlots = {}
    for _, c in ipairs(chars) do usedSlots[c.slot] = true end
    local freeSlot = 1
    for i = 1, Epsilon.Config.Characters.MaxPerPlayer or 3 do
        if not usedSlots[i] then freeSlot = i; break end
    end

    local SPAWN_ZONES = {
        ls     = { x = -269.13, y = -955.98, z = 31.22, heading = 205.0 },
        paleto = { x = -276.83, y = 6224.84, z = 31.50, heading = 40.0  },
        sandy  = { x = 1853.22, y = 3687.47, z = 34.28, heading = 210.0 },
    }
    local spawn = SPAWN_ZONES[data.spawnZone] or Epsilon.Config.Characters.DefaultSpawn

    local newId = MySQL.insert.await(
        'INSERT INTO characters (player_id,slot,firstname,lastname,dob,gender,skin,outfit,pos_x,pos_y,pos_z,pos_heading) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
        {
            cache.db_id, freeSlot,
            data.firstname, data.lastname, data.dob, data.gender or 0,
            data.skin   and json.encode(data.skin)   or nil,
            data.outfit and json.encode(data.outfit) or nil,
            spawn.x, spawn.y, spawn.z, spawn.heading,
        }
    )

    if not newId then
        TriggerClientEvent('epsilon:characters:createError', src, 'Erreur base de données')
        return
    end

    -- Auto-spawn directement après création
    MySQL.query.await('UPDATE characters SET last_played=NOW() WHERE id=?', { newId })
    TriggerClientEvent('epsilon:characters:doSpawn', src, {
        id        = newId,
        slot      = freeSlot,
        firstname = data.firstname,
        lastname  = data.lastname,
        gender    = data.gender or 0,
        skin      = data.skin   and json.encode(data.skin)   or nil,
        outfit    = data.outfit and json.encode(data.outfit) or nil,
        job       = 'chomeur',
        job_grade = 0,
        bank      = 0,
        cash      = 500,
        x         = spawn.x,
        y         = spawn.y,
        z         = spawn.z,
        heading   = spawn.heading,
    })

    local updatedChars = fetchCharacters(cache.db_id)
    playerCache[src].characters = updatedChars
end)

-- ─────────────────────────────────────────────
-- Sélection de personnage (spawn)
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:select', function(charId)
    local src = source
    local cache = playerCache[src]
    if not cache then return end

    local rows = MySQL.query.await(
        'SELECT * FROM characters WHERE id=? AND player_id=?',
        { charId, cache.db_id }
    )
    if not rows or not rows[1] then return end
    local char = rows[1]

    -- Mémorise le personnage actif pour les autres resources
    playerCache[src].activeCharId = charId
    MySQL.query.await('UPDATE characters SET last_played=NOW() WHERE id=?', { charId })

    local spawn = Epsilon.Config.Characters.DefaultSpawn
    TriggerClientEvent('epsilon:characters:doSpawn', src, {
        id        = char.id,
        slot      = char.slot,
        firstname = char.firstname,
        lastname  = char.lastname,
        gender    = char.gender,
        skin      = char.skin,
        outfit    = char.outfit,
        job       = char.job,
        job_grade = char.job_grade,
        bank      = char.bank,
        cash      = char.cash,
        x         = (char.pos_x ~= 0 and char.pos_x) or spawn.x,
        y         = (char.pos_y ~= 0 and char.pos_y) or spawn.y,
        z         = (char.pos_z ~= 0 and char.pos_z) or spawn.z,
        heading   = (char.pos_heading ~= 0 and char.pos_heading) or spawn.heading,
    })
end)

-- ─────────────────────────────────────────────
-- Sauvegarde position
-- ─────────────────────────────────────────────
RegisterNetEvent('epsilon:characters:savePosition', function(pos)
    local src = source
    local cache = playerCache[src]
    if not cache then return end

    -- Trouver le perso actif (last_played le plus récent)
    local rows = MySQL.query.await(
        'SELECT id FROM characters WHERE player_id=? ORDER BY last_played DESC LIMIT 1',
        { cache.db_id }
    )
    if not rows or not rows[1] then return end

    MySQL.query.await(
        'UPDATE characters SET pos_x=?,pos_y=?,pos_z=?,pos_heading=? WHERE id=?',
        { pos.x, pos.y, pos.z, pos.heading, rows[1].id }
    )
end)

-- ─────────────────────────────────────────────
-- Nettoyage déconnexion
-- ─────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    local joined = joinTimes[src]
    if joined then
        local elapsed = os.time() - joined
        local cache   = playerCache[src]
        if cache and cache.db_id then
            MySQL.update(
                'UPDATE players SET total_playtime = total_playtime + ? WHERE id = ?',
                { elapsed, cache.db_id }
            )
        end
        joinTimes[src] = nil
    end
    playerCache[src] = nil
end)

-- ─────────────────────────────────────────────
-- Export: GetPlayer (pour autres resources)
-- ─────────────────────────────────────────────
exports('GetPlayer', function(src)
    return playerCache[src]
end)

exports('GetCharIdBySrc', function(src)
    local cache = playerCache[tonumber(src)]
    return cache and cache.activeCharId or nil
end)

Epsilon.Debug.Success('epsilon-characters server prêt')
