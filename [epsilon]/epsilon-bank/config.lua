Config = Config or {}

Config.CashItemName = 'money'
Config.CardItemName = 'bank_card'
Config.PinLength    = 4

Config.MaxDeposit  = 500000
Config.MaxTransfer = 100000

-- Tiers de carte bancaire
Config.CardTiers = {
    {
        id           = 'classique',
        label        = 'Carte Classique',
        color        = '#94a3b8',
        price        = 500,
        monthly      = 100,
        maxWithdraw  = 500,
        dailyLimit   = 1500,
        description  = 'Accès basique aux distributeurs.',
    },
    {
        id           = 'gold',
        label        = 'Carte Gold',
        color        = '#f59e0b',
        price        = 2000,
        monthly      = 400,
        maxWithdraw  = 3000,
        dailyLimit   = 8000,
        description  = 'Plafonds élevés pour usage courant.',
    },
    {
        id           = 'platinum',
        label        = 'Carte Platinum',
        color        = '#a78bfa',
        price        = 5000,
        monthly      = 1200,
        maxWithdraw  = 10000,
        dailyLimit   = 30000,
        description  = 'Accès illimité, plafonds premium.',
    },
}

-- Emplacements des agences bancaires (blips + zones de proximité)
Config.Agencies = {
    { label = 'Banque - Downtown',   x = 149.84,   y = -1042.71, z = 29.37,  radius = 3.0 },
    { label = 'Banque - Rockford',   x = -350.91,  y = -49.76,   z = 49.04,  radius = 3.0 },
    { label = 'Banque - Sandy',      x = 1175.35,  y = 2706.63,  z = 38.09,  radius = 3.0 },
    { label = 'Banque - Paleto',     x = -101.86,  y = 6469.32,  z = 31.63,  radius = 3.0 },
}
