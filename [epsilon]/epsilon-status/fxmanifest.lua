fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-status'
description 'Epsilon Roleplay — Faim & Soif'
version     '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'epsilon-core',
    'epsilon-database',
    'epsilon-inventory',
}
