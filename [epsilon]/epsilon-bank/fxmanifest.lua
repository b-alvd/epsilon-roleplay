fx_version 'cerulean'
game      'gta5'
lua54     'yes'

name        'epsilon-bank'
description 'Epsilon Roleplay — Banque (agences + ATM)'
version     '1.0.0'

shared_scripts {
    '@epsilon-core/shared/debug.lua',
    '@epsilon-core/config.lua',
    'config.lua',
}

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
    'epsilon-economy',
    'epsilon-inventory',
    'epsilon-characters',
}
