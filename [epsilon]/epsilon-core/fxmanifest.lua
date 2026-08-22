fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-core'
description 'Epsilon Roleplay — Core framework'
version     '1.0.0'
author      'Epsilon Dev'

shared_scripts {
    'shared/debug.lua',
    'shared/utils.lua',
    'config.lua',
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}
