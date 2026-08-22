-- ═══════════════════════════════════════════════════════════════
--  epsilon-economy / server/main.lua
--  Moteur économique : comptes, transactions, marchés dynamiques
-- ═══════════════════════════════════════════════════════════════

local markets          = {}   -- [name] = row
local accounts         = {}   -- [charId] = row (cache)
local activeChars      = {}   -- [src] = charId
local getOrCreateAccount     -- forward declaration

-- ── Utilitaires ──────────────────────────────────────────────────────────────

local function isAdmin(src)
    return IsPlayerAceAllowed(tostring(src), 'epsilon.admin')
        or IsPlayerAceAllowed(tostring(src), 'epsilon.superadmin')
end

-- Formule de prix : base × (demand/supply)^sensitivity, clampée
local function calcPrice(m)
    local s    = math.max(0.01, m.supply)
    local d    = math.max(0.01, m.demand)
    local mult = (d / s) ^ m.sensitivity
    mult = math.max(m.min_multiplier, math.min(m.max_multiplier, mult))
    return math.floor(m.base_price * mult * 100) / 100
end

local function fmtPrice(v)
    return math.floor(v * 100) / 100
end

-- ── Chargement des marchés ────────────────────────────────────────────────────

local function loadMarkets()
    local rows = MySQL.query.await('SELECT * FROM economy_markets')
    markets = {}
    for _, r in ipairs(rows or {}) do
        r.base_price      = tonumber(r.base_price)      or 0
        r.current_price   = tonumber(r.current_price)   or 0
        r.supply          = tonumber(r.supply)          or 100
        r.demand          = tonumber(r.demand)          or 100
        r.sensitivity     = tonumber(r.sensitivity)     or 0.4
        r.min_multiplier  = tonumber(r.min_multiplier)  or 0.4
        r.max_multiplier  = tonumber(r.max_multiplier)  or 3.0
        markets[r.name] = r
    end
    Epsilon.Debug.Info('[economy] %d marchés chargés', #(rows or {}))
end

local function saveMarket(m)
    MySQL.update(
        'UPDATE economy_markets SET current_price=?, supply=?, demand=?, last_update=NOW() WHERE id=?',
        { m.current_price, m.supply, m.demand, m.id }
    )
end

local function getMarketsPayload()
    local result = {}
    for _, m in pairs(markets) do
        result[#result + 1] = {
            id            = m.id,
            name          = m.name,
            label         = m.label,
            icon          = m.icon,
            base_price    = m.base_price,
            current_price = m.current_price,
            supply        = m.supply,
            demand        = m.demand,
        }
    end
    return result
end

-- ── Tick des marchés (decay + recalcul) ──────────────────────────────────────

local EQUILIBRIUM = 100.0
local DECAY       = 0.03   -- 3 % de retour vers l'équilibre par tick (15 min)

local function tickMarkets()
    local changed = false
    for _, m in pairs(markets) do
        local oldPrice = m.current_price
        m.supply = m.supply + (EQUILIBRIUM - m.supply) * DECAY
        m.demand = m.demand + (EQUILIBRIUM - m.demand) * DECAY
        m.current_price = calcPrice(m)
        if math.abs(m.current_price - oldPrice) > 0.005 then
            saveMarket(m)
            changed = true
        end
    end
    if changed then
        TriggerClientEvent('epsilon:economy:marketUpdate', -1, getMarketsPayload())
    end
end

local function snapshotPrices()
    for _, m in pairs(markets) do
        MySQL.insert(
            'INSERT INTO economy_price_history (market_id, price, supply, demand) VALUES (?,?,?,?)',
            { m.id, m.current_price, m.supply, m.demand }
        )
    end
end

CreateThread(function()
    Wait(5000)  -- Laisser la DB démarrer
    loadMarkets()
    snapshotPrices()
    while true do
        Wait(15 * 60 * 1000)  -- 15 minutes
        tickMarkets()
        snapshotPrices()
    end
end)

-- ── Épargne ───────────────────────────────────────────────────────────────────

-- Calcule un score de marché entre -1.0 (crise) et +1.0 (boom)
local function getMarketScore()
    local total, count = 0, 0
    for _, m in pairs(markets) do
        local ratio = m.demand / math.max(0.01, m.supply)
        -- ratio 1.0 = neutre, >1 = boom, <1 = crise ; on normalise en [-1, 1]
        total = total + math.max(-1, math.min(1, (ratio - 1) / 1.5))
        count = count + 1
    end
    return count > 0 and (total / count) or 0
end

local function getMarketVolatility()
    local vals = {}
    for _, m in pairs(markets) do
        vals[#vals + 1] = m.demand / math.max(0.01, m.supply)
    end
    if #vals == 0 then return 0 end
    local mean = 0
    for _, v in ipairs(vals) do mean = mean + v end
    mean = mean / #vals
    local variance = 0
    for _, v in ipairs(vals) do variance = variance + (v - mean)^2 end
    return math.sqrt(variance / #vals)
end

-- Taux par cycle (0.01% base) selon profil et état des marchés
local function calcSavingsRate(profile)
    local base    = 0.0001  -- 0.01 % par cycle
    local score   = getMarketScore()      -- [-1, +1]
    local volat   = getMarketVolatility() -- [0, ~1+]

    if profile == 'secure' then
        return base  -- taux fixe, aucune exposition

    elseif profile == 'mixed' then
        -- exposition modérée : score amplifie le taux de x0 à x3, peut être négatif
        return base + base * score * 2

    elseif profile == 'aggressive' then
        -- exposition forte : score + volatilité ; peut perdre jusqu'à -0.25%/cycle
        return base + base * score * 5 + base * volat * 2
    end
    return base
end

local function tickSavings()
    local placements = MySQL.query.await('SELECT * FROM savings_placements')
    if not placements or #placements == 0 then return end

    local rates = {
        secure     = calcSavingsRate('secure'),
        mixed      = calcSavingsRate('mixed'),
        aggressive = calcSavingsRate('aggressive'),
    }

    -- Enregistrer les taux du cycle
    for profile, rate in pairs(rates) do
        MySQL.insert('INSERT INTO savings_ticks (profile, rate) VALUES (?,?)', { profile, fmtPrice(rate) })
    end

    for _, p in ipairs(placements) do
        local rate   = rates[p.profile] or rates.secure
        local amount = tonumber(p.amount) or 0
        local gain   = fmtPrice(amount * rate)
        local newAmt = fmtPrice(amount + gain)

        if newAmt < 0 then newAmt = 0 end

        MySQL.update(
            'UPDATE savings_placements SET amount=?, last_tick_at=NOW() WHERE id=?',
            { newAmt, p.id }
        )

        -- Mettre à jour le cache si le joueur est connecté
        if accounts[p.character_id] then
            accounts[p.character_id].savings = newAmt
            MySQL.update(
                'UPDATE bank_accounts SET savings=? WHERE character_id=?',
                { newAmt, p.character_id }
            )
        else
            MySQL.update(
                'UPDATE bank_accounts SET savings=? WHERE character_id=?',
                { newAmt, p.character_id }
            )
        end

        -- Enregistrer la transaction si gain non nul
        if math.abs(gain) >= 0.01 then
            local acc = getOrCreateAccount(p.character_id)
            if acc then
                local txType = gain >= 0 and 'credit' or 'debit'
                local label  = gain >= 0 and 'Intérêts épargne' or 'Perte épargne'
                MySQL.insert(
                    'INSERT INTO bank_transactions (from_account, to_account, amount, type, label) VALUES (?,?,?,?,?)',
                    { nil, acc.id, fmtPrice(math.abs(gain)), txType, label }
                )
            end
        end
    end

    Epsilon.Debug.Info('[economy] tick épargne — %d placements traités (secure=%.4f%% mixed=%.4f%% aggressive=%.4f%%)',
        #placements, rates.secure*100, rates.mixed*100, rates.aggressive*100)
end

CreateThread(function()
    Wait(10000)
    while true do
        Wait(30 * 60 * 1000)  -- 30 minutes
        tickSavings()
    end
end)

exports('GetSavingsRates', function()
    return {
        secure     = calcSavingsRate('secure'),
        mixed      = calcSavingsRate('mixed'),
        aggressive = calcSavingsRate('aggressive'),
        score      = getMarketScore(),
    }
end)

exports('GetSavingsHistory', function()
    local rows = MySQL.query.await([[
        SELECT profile, rate, ticked_at
        FROM savings_ticks
        ORDER BY ticked_at DESC
        LIMIT 48
    ]])
    return rows or {}
end)

-- ── Gestion des personnages actifs ────────────────────────────────────────────

RegisterNetEvent('epsilon:economy:setActiveChar', function(charId)
    activeChars[tonumber(source)] = charId
    getOrCreateAccount(charId)  -- Créer le compte bancaire dès le spawn si inexistant
end)

exports('GetCharIdBySrc', function(src)
    return activeChars[tonumber(src)]
end)

AddEventHandler('playerDropped', function()
    local src = tonumber(source)
    if activeChars[src] then
        accounts[activeChars[src]] = nil  -- Vider le cache mémoire
    end
    activeChars[src] = nil
end)

-- ── IBAN ─────────────────────────────────────────────────────────────────────

local function generateIban()
    local groups = {}
    for _ = 1, 5 do
        local g = ''
        for _ = 1, 4 do g = g .. math.random(0, 9) end
        groups[#groups + 1] = g
    end
    return 'EP-' .. table.concat(groups, '-')  -- EP-XXXX-XXXX-XXXX-XXXX-XXXX (27 chars)
end

local function ensureIban(acc)
    if acc.iban and acc.iban ~= '' then return end
    local iban
    repeat
        iban = generateIban()
        local exists = MySQL.query.await('SELECT id FROM bank_accounts WHERE iban=?', { iban })
        if not (exists and exists[1]) then break end
    until false
    MySQL.update.await('UPDATE bank_accounts SET iban=? WHERE id=?', { iban, acc.id })
    acc.iban = iban
end

-- ── Comptes ──────────────────────────────────────────────────────────────────

getOrCreateAccount = function(charId)
    if accounts[charId] then return accounts[charId] end
    local rows = MySQL.query.await(
        'SELECT * FROM bank_accounts WHERE character_id=?', { charId }
    )
    if rows and rows[1] then
        local a = rows[1]
        a.balance      = tonumber(a.balance)      or 0
        a.savings      = tonumber(a.savings)      or 0
        a.credit_score = tonumber(a.credit_score) or 500
        accounts[charId] = a
        ensureIban(a)
        return a
    end
    local iban = generateIban()
    local id = MySQL.insert.await(
        'INSERT INTO bank_accounts (character_id, iban) VALUES (?,?)', { charId, iban }
    )
    local acc = { id = id, character_id = charId, iban = iban, balance = 0.0, savings = 0.0, credit_score = 500 }
    accounts[charId] = acc
    return acc
end

local function flushAccount(acc)
    MySQL.update(
        'UPDATE bank_accounts SET balance=?, savings=?, updated_at=NOW() WHERE id=?',
        { fmtPrice(acc.balance), fmtPrice(acc.savings), acc.id }
    )
end

local function recordTransaction(fromAccId, toAccId, amount, txType, label, meta)
    MySQL.insert(
        'INSERT INTO bank_transactions (from_account, to_account, amount, type, label, metadata) VALUES (?,?,?,?,?,?)',
        { fromAccId, toAccId, fmtPrice(amount), txType or 'transfer', label or '', meta and json.encode(meta) or nil }
    )
end

-- ── Exports publics ───────────────────────────────────────────────────────────

exports('GetAccount', function(charId)
    return getOrCreateAccount(charId)
end)

exports('GetBalance', function(charId)
    local acc = getOrCreateAccount(charId)
    return acc and fmtPrice(acc.balance) or 0.0
end)

exports('GetSavings', function(charId)
    local acc = getOrCreateAccount(charId)
    return acc and fmtPrice(acc.savings) or 0.0
end)

exports('AddMoney', function(charId, amount, label, txType)
    if amount <= 0 then return false, 'Montant invalide' end
    local acc = getOrCreateAccount(charId)
    if not acc then return false, 'Compte introuvable' end
    acc.balance = acc.balance + amount
    flushAccount(acc)
    recordTransaction(nil, acc.id, amount, txType or 'credit', label or 'Crédit')
    return true
end)

exports('RemoveMoney', function(charId, amount, label, txType)
    if amount <= 0 then return false, 'Montant invalide' end
    local acc = getOrCreateAccount(charId)
    if not acc then return false, 'Compte introuvable' end
    if acc.balance < amount then return false, 'Solde insuffisant' end
    acc.balance = acc.balance - amount
    flushAccount(acc)
    recordTransaction(acc.id, nil, amount, txType or 'debit', label or 'Débit')
    return true
end)

exports('Transfer', function(fromCharId, toCharId, amount, label)
    if amount <= 0 then return false, 'Montant invalide' end
    local from = getOrCreateAccount(fromCharId)
    local to   = getOrCreateAccount(toCharId)
    if not from or not to then return false, 'Compte introuvable' end
    if from.balance < amount then return false, 'Solde insuffisant' end
    from.balance = from.balance - amount
    to.balance   = to.balance   + amount
    flushAccount(from)
    flushAccount(to)
    recordTransaction(from.id, to.id, amount, 'transfer', label or 'Virement')
    return true
end)

exports('GetPlacement', function(charId)
    local rows = MySQL.query.await('SELECT * FROM savings_placements WHERE character_id=?', { charId })
    if not rows or not rows[1] then return nil end
    local p = rows[1]
    p.amount = tonumber(p.amount) or 0
    return p
end)

exports('DepositSavings', function(charId, amount, profile)
    local validProfiles = { secure = true, mixed = true, aggressive = true }
    if not validProfiles[profile] then return false, 'Profil invalide' end
    amount = math.floor(tonumber(amount) or 0)
    if amount < 500 then return false, 'Minimum 500$' end

    local existing = MySQL.query.await('SELECT id FROM savings_placements WHERE character_id=?', { charId })
    if existing and existing[1] then return false, 'Vous avez déjà un placement actif' end

    local ok, err = exports['epsilon-economy']:RemoveMoney(charId, amount, 'Placement épargne', 'debit')
    if not ok then return false, err end

    local acc = getOrCreateAccount(charId)
    acc.savings = fmtPrice((acc.savings or 0) + amount)
    MySQL.update('UPDATE bank_accounts SET savings=? WHERE character_id=?', { acc.savings, charId })

    MySQL.insert(
        'INSERT INTO savings_placements (character_id, profile, amount) VALUES (?,?,?)',
        { charId, profile, fmtPrice(amount) }
    )
    return true
end)

exports('WithdrawSavings', function(charId)
    local rows = MySQL.query.await('SELECT * FROM savings_placements WHERE character_id=?', { charId })
    if not rows or not rows[1] then return false, 'Aucun placement actif' end
    local p = rows[1]

    local amount    = tonumber(p.amount) or 0
    local deposited = p.deposited_at
    local hoursOld  = (os.time() - (type(deposited) == 'number' and deposited or os.time())) / 3600
    local penalty   = 0

    if hoursOld < 24 then
        penalty = fmtPrice(amount * 0.05)
        amount  = fmtPrice(amount - penalty)
    end

    if amount < 0 then amount = 0 end

    local acc = getOrCreateAccount(charId)
    acc.savings = 0
    MySQL.update('UPDATE bank_accounts SET savings=0 WHERE character_id=?', { charId })
    MySQL.update('DELETE FROM savings_placements WHERE character_id=?', { charId })

    if amount > 0 then
        exports['epsilon-economy']:AddMoney(charId, amount, 'Retrait épargne', 'credit')
    end

    return true, amount, penalty
end)

exports('GetCharIdByIban', function(iban)
    if not iban or iban == '' then return nil end
    local normalized = (iban:upper():gsub('%s', ''))
    print('[IBAN lookup] recherche: "' .. normalized .. '"')
    local rows = MySQL.query.await('SELECT character_id FROM bank_accounts WHERE iban=?', { normalized })
    local result = rows and rows[1] and rows[1].character_id or nil
    print('[IBAN lookup] résultat: ' .. tostring(result))
    return result
end)

exports('GetMarketPrice', function(marketName)
    local m = markets[marketName]
    return m and m.current_price or nil
end)

exports('GetAllMarkets', function()
    return getMarketsPayload()
end)

-- Enregistrer une vente (augmente l'offre → prix baisse)
exports('RecordSale', function(marketName, quantity)
    quantity = math.max(0.01, quantity or 1)
    local m = markets[marketName]
    if not m then return end
    m.supply = math.min(500, m.supply + quantity)
    m.current_price = calcPrice(m)
    saveMarket(m)
    TriggerClientEvent('epsilon:economy:marketUpdate', -1, getMarketsPayload())
end)

-- Enregistrer un achat (augmente la demande → prix monte)
exports('RecordPurchase', function(marketName, quantity)
    quantity = math.max(0.01, quantity or 1)
    local m = markets[marketName]
    if not m then return end
    m.demand = math.min(500, m.demand + quantity)
    m.current_price = calcPrice(m)
    saveMarket(m)
    TriggerClientEvent('epsilon:economy:marketUpdate', -1, getMarketsPayload())
end)

-- ── Panel admin : récupération des données ────────────────────────────────────

RegisterNetEvent('epsilon:economy:admin:getData', function(data)
    local src = source
    if not isAdmin(src) then return end

    -- Stats globales
    local totals = MySQL.query.await(
        'SELECT COALESCE(SUM(balance),0) AS bal, COALESCE(SUM(savings),0) AS sav, COUNT(*) AS cnt FROM bank_accounts'
    )
    local vol24 = MySQL.query.await(
        'SELECT COALESCE(SUM(amount),0) AS vol, COUNT(*) AS cnt FROM bank_transactions WHERE created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)'
    )

    -- Marchés + historique (derniers 48 snapshots = 12h)
    local marketsOut = {}
    for _, m in pairs(markets) do
        local hist = MySQL.query.await(
            'SELECT price FROM economy_price_history WHERE market_id=? ORDER BY recorded_at DESC LIMIT 48',
            { m.id }
        )
        local prices = {}
        for i = #(hist or {}), 1, -1 do prices[#prices + 1] = hist[i].price end
        marketsOut[#marketsOut + 1] = {
            id = m.id, name = m.name, label = m.label, icon = m.icon,
            base_price = m.base_price, current_price = m.current_price,
            supply = m.supply, demand = m.demand,
            history = prices,
        }
    end

    -- Transactions récentes (montant positif = crédit, négatif = débit)
    local txs = MySQL.query.await([[
        SELECT id,
               CASE WHEN from_account IS NULL THEN ABS(amount) ELSE -ABS(amount) END AS amount,
               type, label, created_at
        FROM bank_transactions
        ORDER BY created_at DESC
        LIMIT 40
    ]])

    TriggerClientEvent('epsilon:economy:admin:dataResult', src, {
        stats = {
            total_circulation = (totals and totals[1] and (totals[1].bal + totals[1].sav)) or 0,
            account_count     = (totals and totals[1] and totals[1].cnt) or 0,
            volume_24h        = (vol24 and vol24[1] and vol24[1].vol) or 0,
            tx_count_24h      = (vol24 and vol24[1] and vol24[1].cnt) or 0,
        },
        markets      = marketsOut,
        transactions = txs or {},
    })
end)

-- ── Panel admin : événement marché ───────────────────────────────────────────

RegisterNetEvent('epsilon:economy:admin:adjustMarket', function(data)
    local src = source
    if not isAdmin(src) then return end

    local m = markets[data.market]
    if not m then return end

    local ev = data.event
    if ev == 'shortage' then          -- Pénurie
        m.supply = math.max(5,  m.supply * 0.20)
    elseif ev == 'surplus' then       -- Surplus
        m.supply = math.min(500, m.supply * 5.0)
    elseif ev == 'crisis' then        -- Crise (pénurie + demande élevée)
        m.supply = math.max(3,  m.supply * 0.15)
        m.demand = math.min(500, m.demand * 4.0)
    elseif ev == 'reset' then         -- Réinitialisation
        m.supply = 100.0
        m.demand = 100.0
    elseif ev == 'set' then           -- Valeur manuelle
        if data.supply then m.supply = math.max(1, math.min(500, tonumber(data.supply) or 100)) end
        if data.demand then m.demand = math.max(1, math.min(500, tonumber(data.demand) or 100)) end
    else
        return
    end

    m.current_price = calcPrice(m)
    saveMarket(m)
    snapshotPrices()

    TriggerClientEvent('epsilon:economy:marketUpdate', -1, getMarketsPayload())

    -- Log admin
    TriggerEvent('epsilon:admin:log', src, nil,
        'economy_' .. ev,
        ev .. ' on market:' .. (data.market or '?'),
        { market = data.market, event = ev }
    )
end)
