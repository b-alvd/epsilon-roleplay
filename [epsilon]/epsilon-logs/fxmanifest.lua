fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-logs'
description 'Epsilon Roleplay — Universal server event logger → MySQL'
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
