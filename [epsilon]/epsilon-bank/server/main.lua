-- epsilon-bank / server/main.lua

local function getCharId(src)
    return exports['epsilon-inventory']:GetCharId(src)
end

local function getAccount(charId)
    return exports['epsilon-economy']:GetAccount(charId)
end

local function notify(src, msg, ntype)
    TriggerClientEvent('epsilon:ui:notify', src, { text = msg, type = ntype or 'info' })
end

local function notifyBank(src, msg, ntype)
    TriggerClientEvent('epsilon:bank:notify', src, { text = msg, type = ntype or 'info' })
end

-- Retourne le tier config par id
local function getTier(id)
    for _, t in ipairs(Config.CardTiers) do
        if t.id == id then return t end
    end
end

-- Retourne le total retiré aujourd'hui
local function getDailyWithdrawn(accId)
    local rows = MySQL.query.await([[
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM bank_transactions
        WHERE from_account = ? AND type = 'withdrawal'
          AND DATE(created_at) = CURDATE()
    ]], { accId })
    return (rows and rows[1] and tonumber(rows[1].total)) or 0
end


-- Générateur de chiffres aléatoires
local function randDigits(n)
    local s = ''
    for _ = 1, n do s = s .. math.random(0, 9) end
    return s
end


-- ── Accès carte (depuis bank_cards, indépendant de l'inventaire) ─────────────

local function getActiveCard(charId)
    local rows = MySQL.query.await(
        "SELECT id, character_id, number, cvv, pin, tier, DATE_FORMAT(expires, '%Y-%m-%d') AS expires FROM bank_cards WHERE character_id=? LIMIT 1",
        { charId }
    )
    return rows and rows[1] or nil
end

-- ── Données épargne ──────────────────────────────────────────────────────────

local function getSavingsPayload(charId)
    local placement = exports['epsilon-economy']:GetPlacement(charId)
    local rates     = exports['epsilon-economy']:GetSavingsRates()
    local history   = exports['epsilon-economy']:GetSavingsHistory()

    local hist = { secure = {}, mixed = {}, aggressive = {} }
    for _, row in ipairs(history or {}) do
        local p = row.profile
        if hist[p] and #hist[p] < 24 then
            table.insert(hist[p], 1, tonumber(row.rate) or 0)
        end
    end

    return {
        placement = placement,
        rates     = rates,
        history   = hist,
    }
end

-- ── sendBankData (helper partagé) ────────────────────────────────────────────

local function sendBankData(src, mode)
    local charId = getCharId(src)
    if not charId then return end

    local acc = getAccount(charId)
    if not acc then return end

    local txs = MySQL.query.await([[
        SELECT id, amount, type, label, created_at
        FROM bank_transactions
        WHERE from_account = ? OR to_account = ?
        ORDER BY created_at DESC
        LIMIT 30
    ]], { acc.id, acc.id })

    local weekly = MySQL.query.await([[
        SELECT
            DATE(created_at)                                                     AS day,
            DAYNAME(created_at)                                                  AS day_name,
            COALESCE(SUM(CASE WHEN to_account = ? THEN amount ELSE 0 END), 0)   AS deposits,
            COALESCE(SUM(CASE WHEN from_account = ? THEN amount ELSE 0 END), 0) AS withdrawals
        FROM bank_transactions
        WHERE (from_account = ? OR to_account = ?)
          AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
        GROUP BY DATE(created_at), DAYNAME(created_at)
        ORDER BY DATE(created_at) ASC
    ]], { acc.id, acc.id, acc.id, acc.id })

    local cash = MySQL.query.await(
        'SELECT COALESCE(SUM(quantity), 0) AS total FROM player_items pi JOIN items i ON i.name = pi.name WHERE pi.character_id = ? AND JSON_UNQUOTE(JSON_EXTRACT(i.data, "$.type")) = "money"',
        { charId }
    )
    local cashAmount = (cash and cash[1] and tonumber(cash[1].total)) or 0

    local player = exports['epsilon-characters']:GetPlayer(src)
    local char   = player and player.characters and player.characters[1]

    -- Infos carte depuis bank_cards
    local card     = getActiveCard(charId)
    local cardData = nil
    if card then
        local tier = getTier(card.tier or '')
        cardData = {
            tier        = card.tier,
            label       = tier and tier.label or 'Carte',
            color       = tier and tier.color or '#94a3b8',
            expires     = card.expires,
            hasPin      = card.pin ~= nil and card.pin ~= '',
            pin         = card.pin,
            number      = card.number,
            cvv         = card.cvv,
            maxWithdraw = tier and tier.maxWithdraw or 0,
            dailyLimit  = tier and tier.dailyLimit  or 0,
            dailyUsed   = getDailyWithdrawn(acc.id),
        }
    end

    TriggerClientEvent('epsilon:bank:dataResult', src, {
        mode    = mode or 'bank',
        account = {
            id      = acc.id,
            iban    = acc.iban or '',
            balance = tonumber(acc.balance) or 0,
            savings = tonumber(acc.savings) or 0,
        },
        cash         = cashAmount,
        transactions = txs or {},
        weekly       = weekly or {},
        character    = {
            firstname = char and char.firstname or 'John',
            lastname  = char and char.lastname  or 'Doe',
        },
        card         = cardData,
        cardTiers    = mode == 'bank' and Config.CardTiers or nil,
        savings      = mode == 'bank' and getSavingsPayload(charId) or nil,
    })
end

-- ── bank:getData ─────────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:getData', function(data)
    sendBankData(source, data and data.mode or 'bank')
end)

-- ── bank:deposit ─────────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:deposit', function(amount)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    amount = math.floor((tonumber(amount) or 0) * 100) / 100
    if amount <= 0 or amount > Config.MaxDeposit then
        notifyBank(src, 'Montant invalide.', 'error'); return
    end

    local hasEnough = exports['epsilon-inventory']:HasItem(charId, Config.CashItemName, amount)
    if not hasEnough then

        notifyBank(src, 'Vous n\'avez pas assez d\'argent liquide.', 'error'); return
    end

    local ok = exports['epsilon-inventory']:RemoveItem(charId, Config.CashItemName, amount)
    if not ok then
        notifyBank(src, 'Erreur lors du retrait du liquide.', 'error'); return
    end

    exports['epsilon-economy']:AddMoney(charId, amount, 'Dépôt en agence', 'deposit')
    exports['epsilon-inventory']:PushInventory(src)
    notifyBank(src, ('Dépôt de %s$ effectué.'):format(amount), 'success')
    sendBankData(src, 'bank')
end)

-- ── bank:withdraw ─────────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:withdraw', function(amount, mode)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local notif = (mode == 'atm') and notify or notifyBank

    amount = math.floor((tonumber(amount) or 0) * 100) / 100
    if amount <= 0 then
        notif(src, 'Montant invalide.', 'error'); return
    end

    local card = getActiveCard(charId)
    if not card then
        notif(src, 'Vous devez posséder une carte bancaire pour effectuer un retrait.', 'error'); return
    end

    local today = os.date('%Y-%m-%d')
    local expires = card.expires
    if expires < today then
        notif(src, 'Votre carte est expirée. Rendez-vous en agence.', 'error'); return
    end

    local tier  = getTier(card.tier or '')
    local maxW  = tier and tier.maxWithdraw or 0
    local dayLim = tier and tier.dailyLimit or 0

    if amount > maxW then
        notif(src, ('Plafond de retrait dépassé (%s$ max).'):format(maxW), 'error'); return
    end

    local acc = getAccount(charId)
    if not acc then return end

    local dailyUsed = getDailyWithdrawn(acc.id)
    if dailyUsed + amount > dayLim then
        local remain = math.max(0, dayLim - dailyUsed)
        notif(src, ('Plafond journalier dépassé. Il vous reste %s$ disponibles aujourd\'hui.'):format(remain), 'error'); return
    end

    local label = (mode == 'atm') and 'Retrait DAB' or 'Retrait agence'
    local ok, err = exports['epsilon-economy']:RemoveMoney(charId, amount, label, 'withdrawal')
    if not ok then
        notif(src, err or 'Solde insuffisant.', 'error'); return
    end

    exports['epsilon-inventory']:AddItem(charId, Config.CashItemName, amount)
    exports['epsilon-inventory']:PushInventory(src)
    notif(src, ('Retrait de %s$ effectué.'):format(amount), 'success')
    sendBankData(src, mode or 'bank')
end)

-- ── bank:transfer ─────────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:transfer', function(data)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local amount = math.floor((tonumber(data.amount) or 0) * 100) / 100
    local label  = tostring(data.label or 'Virement'):sub(1, 100)

    if amount <= 0 or amount > Config.MaxTransfer then
        notifyBank(src, 'Montant invalide.', 'error'); return
    end

    -- Résolution du destinataire : IBAN ou character_id (rétrocompat)
    local targetId
    if data.targetIban and data.targetIban ~= '' then
        local iban = (tostring(data.targetIban):upper():gsub('%s', ''))
        targetId = exports['epsilon-economy']:GetCharIdByIban(iban)
        if not targetId then
            notifyBank(src, 'IBAN introuvable.', 'error'); return
        end
    else
        targetId = tonumber(data.targetCharId)
    end

    if not targetId then
        notifyBank(src, 'Destinataire invalide.', 'error'); return
    end
    if targetId == charId then
        notifyBank(src, 'Vous ne pouvez pas virer de l\'argent sur le compte émetteur.', 'error'); return
    end

    local ok, err = exports['epsilon-economy']:Transfer(charId, targetId, amount, label)
    if not ok then
        notifyBank(src, err or 'Virement impossible.', 'error'); return
    end

    notifyBank(src, ('Virement de %s$ envoyé.'):format(amount), 'success')
    sendBankData(src, 'bank')
end)

-- ── bank:useCard — vérifie la carte physique, lit les données depuis bank_cards

RegisterNetEvent('epsilon:bank:useCard', function(itemId)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    -- Vérifier que le joueur a bien la carte physique en inventaire
    local rows = MySQL.query.await(
        'SELECT id FROM player_items WHERE id=? AND character_id=? AND name=?',
        { itemId, charId, Config.CardItemName }
    )
    if not rows or not rows[1] then
        notify(src, 'Carte bancaire introuvable dans votre inventaire.', 'error'); return
    end

    -- Récupérer les données depuis bank_cards
    local card = getActiveCard(charId)
    if not card then
        notify(src, 'Aucune carte enregistrée en banque. Rendez-vous en agence.', 'error'); return
    end

    local today   = os.date('%Y-%m-%d')
    local expires = card.expires
    if expires < today then
        notify(src, 'Votre carte est expirée. Rendez-vous en agence.', 'error'); return
    end

    TriggerClientEvent('epsilon:bank:pinPrompt', src, {
        itemId    = rows[1].id,
        needSetup = card.pin == nil or card.pin == '',
    })
end)

-- ── bank:setPin — définit le PIN (depuis agence ou ATM) ─────────────────────

RegisterNetEvent('epsilon:bank:setPin', function(pin, mode)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    pin = tostring(pin or ''):gsub('%D', ''):sub(1, Config.PinLength)
    if #pin ~= Config.PinLength then
        TriggerClientEvent('epsilon:bank:pinResult', src, { ok = false, msg = 'PIN invalide.' }); return
    end

    local card = getActiveCard(charId)
    if not card then
        TriggerClientEvent('epsilon:bank:pinResult', src, { ok = false, msg = 'Carte introuvable.' }); return
    end

    MySQL.update.await('UPDATE bank_cards SET pin=? WHERE character_id=?', { pin, charId })
    sendBankData(src, mode or 'bank')
end)

-- ── bank:verifyPin — vérifie le PIN depuis bank_cards ────────────────────────

RegisterNetEvent('epsilon:bank:verifyPin', function(itemId, pin)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local card = getActiveCard(charId)
    if not card then
        TriggerClientEvent('epsilon:bank:pinResult', src, { ok = false, msg = 'Carte introuvable.' }); return
    end

    if tostring(card.pin) ~= tostring(pin) then
        TriggerClientEvent('epsilon:bank:pinResult', src, { ok = false, msg = 'Code PIN incorrect.' }); return
    end

    local today   = os.date('%Y-%m-%d')
    local expires = card.expires
    if expires < today then
        TriggerClientEvent('epsilon:bank:pinResult', src, {
            ok = false, msg = 'Votre abonnement a expiré. Rendez-vous en agence.',
        }); return
    end

    sendBankData(src, 'atm')
end)

-- ── bank:buyCard — premier achat (crée une entrée dans bank_cards) ────────────

RegisterNetEvent('epsilon:bank:buyCard', function(tierId)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local tier = getTier(tierId)
    if not tier then notifyBank(src, 'Offre introuvable.', 'error'); return end

    local existing = getActiveCard(charId)
    if existing then notifyBank(src, 'Vous possédez déjà une carte bancaire.', 'error'); return end

    local ok, err = exports['epsilon-economy']:RemoveMoney(charId, tier.price, 'Ouverture carte ' .. tier.label, 'purchase')
    if not ok then notifyBank(src, err or 'Solde insuffisant.', 'error'); return end

    local expires    = os.date('%Y-%m-%d', os.time() + 30 * 24 * 3600)
    local cardNumber = randDigits(4)..'-'..randDigits(4)..'-'..randDigits(4)..'-'..randDigits(4)
    local cvv        = randDigits(3)

    -- Enregistrer dans bank_cards
    MySQL.update.await(
        'INSERT INTO bank_cards (character_id, number, cvv, tier, expires) VALUES (?, ?, ?, ?, ?)',
        { charId, cardNumber, cvv, tierId, expires }
    )

    -- Donner l'item physique (support de la carte)
    local usedRows = MySQL.query.await(
        'SELECT slot FROM player_items WHERE character_id=? AND category="items"', { charId }
    )
    local occupied = {}
    for _, r in ipairs(usedRows or {}) do occupied[tonumber(r.slot)] = true end
    local freeSlot = 1
    while occupied[freeSlot] do freeSlot = freeSlot + 1 end

    MySQL.update.await(
        'INSERT INTO player_items (character_id, name, quantity, slot, category, data) VALUES (?, ?, 1, ?, "items", ?)',
        { charId, Config.CardItemName, freeSlot, '{}' }
    )
    exports['epsilon-inventory']:PushInventory(src)

    local expires_fr = expires:match('(%d+)-(%d+)-(%d+)') and
        expires:sub(9,10)..'/'..expires:sub(6,7)..'/'..expires:sub(1,4) or expires
    notifyBank(src, ('Carte %s activée — expire le %s.'):format(tier.label, expires_fr), 'success')
    sendBankData(src, 'bank')
end)

-- ── bank:renewCard ────────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:renewCard', function()
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local card = getActiveCard(charId)
    if not card then notifyBank(src, 'Aucune carte bancaire trouvée.', 'error'); return end

    local tier = getTier(card.tier or '')
    if not tier then notifyBank(src, 'Type de carte inconnu.', 'error'); return end

    local ok, err = exports['epsilon-economy']:RemoveMoney(charId, tier.monthly, 'Abonnement ' .. tier.label, 'purchase')
    if not ok then notifyBank(src, err or 'Solde insuffisant pour le renouvellement.', 'error'); return end

    local today = os.date('%Y-%m-%d')
    local base  = card.expires
    if base < today then base = today end
    local y, m, d = base:match('(%d+)-(%d+)-(%d+)')
    local newExpiry = os.date('%Y-%m-%d', os.time({ year=tonumber(y), month=tonumber(m)+1, day=tonumber(d) }))

    MySQL.update.await('UPDATE bank_cards SET expires=? WHERE character_id=?', { newExpiry, charId })

    local exp_fr = newExpiry:sub(9,10)..'/'..newExpiry:sub(6,7)..'/'..newExpiry:sub(1,4)
    notifyBank(src, ('Abonnement renouvelé — expire le %s.'):format(exp_fr), 'success')
    sendBankData(src, 'bank')
end)

-- ── bank:savings:deposit ─────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:savings:deposit', function(data)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local ok, err = exports['epsilon-economy']:DepositSavings(charId, data.amount, data.profile)
    if not ok then
        notifyBank(src, err or 'Dépôt impossible.', 'error'); return
    end

    notifyBank(src, ('Placement de %s$ effectué.'):format(data.amount), 'success')
    sendBankData(src, 'bank')
end)

-- ── bank:savings:withdraw ─────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:savings:withdraw', function()
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local ok, amount, penalty = exports['epsilon-economy']:WithdrawSavings(charId)
    if not ok then
        notifyBank(src, amount or 'Retrait impossible.', 'error'); return
    end

    if penalty and penalty > 0 then
        notifyBank(src, ('Retrait de %s$ effectué (pénalité %s$ retrait anticipé).'):format(amount, penalty), 'info')
    else
        notifyBank(src, ('Retrait de %s$ effectué.'):format(amount), 'success')
    end
    sendBankData(src, 'bank')
end)

-- ── bank:upgradeCard ──────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:bank:upgradeCard', function(tierId)
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    local card = getActiveCard(charId)
    if not card then notifyBank(src, 'Aucune carte bancaire trouvée.', 'error'); return end

    local newTier = getTier(tierId)
    if not newTier then notifyBank(src, 'Offre introuvable.', 'error'); return end
    if card.tier == tierId then notifyBank(src, 'Vous avez déjà cette carte.', 'error'); return end

    local ok, err = exports['epsilon-economy']:RemoveMoney(charId, newTier.price, 'Upgrade ' .. newTier.label, 'purchase')
    if not ok then notifyBank(src, err or 'Solde insuffisant.', 'error'); return end

    MySQL.update.await('UPDATE bank_cards SET tier=? WHERE character_id=?', { tierId, charId })

    notifyBank(src, ('Carte mise à niveau : %s.'):format(newTier.label), 'success')
    sendBankData(src, 'bank')
end)
