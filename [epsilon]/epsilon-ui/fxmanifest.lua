fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'epsilon-ui'
description 'Epsilon Roleplay — Interface React centralisée'
version     '1.0.0'
author      'Epsilon Dev'

client_scripts {
    'client/main.lua',
}

ui_page 'dist/index.html'

files {
    'dist/index.html',
    'dist/assets/**',
}

dependencies {
    'epsilon-core',
}
