fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Epsilon'
description 'Context menu alt+clic — epsilon-context'
version '1.0.0'

server_scripts {
    'server/main.lua',
}

client_scripts {
    -- Utils
    'client/utils/screenToWorld.lua',
    'client/utils/TextAlignment.lua',
    'client/utils/TextFont.lua',
    'client/utils/Log.lua',
    'client/utils/Color.lua',

    -- Valeurs par défaut (dépend de Color.lua)
    'client/defaults.lua',

    -- Graphics2D
    'client/graphics/Object2D.lua',
    'client/graphics/Rect.lua',
    'client/graphics/Text.lua',
    'client/graphics/Sprite.lua',
    'client/graphics/SpriteUV.lua',
    'client/graphics/Container.lua',
    'client/graphics/Border.lua',

    -- Items
    'client/items/BaseItem.lua',
    'client/items/SeparatorItem.lua',
    'client/items/ScrollItem.lua',
    'client/items/PageItem.lua',
    'client/items/TextItem.lua',
    'client/items/Item.lua',
    'client/items/SpriteItem.lua',
    'client/items/SubmenuItem.lua',
    'client/items/CheckboxItem.lua',

    -- Menu
    'client/menu/Menu.lua',
    'client/menu/ScrollMenu.lua',
    'client/menu/PageMenu.lua',
    'client/menu/MenuPool.lua',
    'client/menu/core.lua',

    -- Notifications réseau
    'client/notify.lua',

    -- Actions
    'client/actions_player.lua',
    'client/actions_vehicle.lua',
    'client/actions_world.lua',
    'client/config_sit.lua',
    'client/actions_prop.lua',
}

files {
    'stream/customSprites.ytd',
}

data_file 'DLC_ITYP_REQUEST' 'stream/customSprites.ytd'
