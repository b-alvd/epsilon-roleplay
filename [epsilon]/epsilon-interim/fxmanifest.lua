fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-interim'
description 'Epsilon Roleplay — Missions intérim'
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
    'client/state.lua',
    'client/utils.lua',
    'client/vehicle.lua',
    'client/eboueur.lua',
    'client/livreur.lua',
    'client/lifecycle.lua',
    'client/blips.lua',
    'client/main.lua',
}

dependencies {
    'epsilon-core',
    'epsilon-jobs',
}
