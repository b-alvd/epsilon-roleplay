Epsilon.Admin = {
    -- Touche pour ouvrir/fermer le panel (F6 par défaut)
    Key = 'F6',

    -- Licences autorisées (fallback si pas d'ace permissions)
    -- Format: 'license:xxxxxxxx'
    SuperAdmins = {},

    -- Rangs admin (utilisés dans l'UI et les logs)
    Ranks = {
        superadmin = { label = 'Super Admin', color = '#ef4444' },
        admin      = { label = 'Admin',       color = '#f97316' },
        moderator  = { label = 'Modérateur',  color = '#3b82f6' },
    },

    -- Météos disponibles
    Weathers = {
        'EXTRASUNNY', 'CLEAR', 'CLOUDS', 'OVERCAST',
        'RAIN', 'THUNDER', 'FOGGY', 'SNOW', 'XMAS',
    },
}
