fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-characters'
description 'Epsilon Roleplay — Système de personnages (multichar + spawn)'
version     '1.0.0'
author      'Epsilon Dev'

shared_scripts {
    '@epsilon-core/shared/debug.lua',
    '@epsilon-core/shared/utils.lua',
    '@epsilon-core/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'ui/index.html'

dependencies {
    'epsilon-core',
    'epsilon-database',
    'epsilon-logs',
}
