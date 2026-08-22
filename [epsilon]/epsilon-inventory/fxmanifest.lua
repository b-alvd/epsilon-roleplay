fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-inventory'
description 'Epsilon Roleplay — Système d\'inventaire'
version     '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

files {
    'images/*.png',
}

dependencies {
    'epsilon-core',
    'epsilon-database',
}
