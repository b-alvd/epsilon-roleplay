fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-pausemenu'
description 'Epsilon Roleplay — Menu pause & signalements'
version     '1.0.0'
author      'Epsilon Dev'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'epsilon-core',
    'epsilon-ui',
    'epsilon-database',
    'oxmysql',
}
