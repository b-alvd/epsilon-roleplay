fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-spawn'
description 'Epsilon Roleplay — Gestionnaire de spawn personnalisé'
version     '1.0.0'
author      'Epsilon Dev'

shared_scripts {
    '@epsilon-core/shared/debug.lua',
    '@epsilon-core/config.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'epsilon-core',
    'epsilon-characters',
}
