fx_version 'bodacious'
game 'gta5'
this_is_a_map 'yes'
lua54 'yes'

-- map by---:
author 'Prompt Studio'
description 'Sandy Shores Illegal Garage & Gas Station & Car Wash'
scripts_author 'Infames Dev'
version '1.1.1'

-- data_file 'AUDIO_GAMEDATA' 'audio/prompt_sandy_is_garage_game.dat' -- dat151
-- data_file 'DLC_ITYP_REQUEST' 'stream/unlocked/illegal_garage/prompt_sandy_illegal_garage.ytyp'

-- files {
--   'audio/prompt_sandy_is_garage_game.dat151.rel'
-- }

escrow_ignore {
    'stream/unlocked/**',
    'config.lua',
    'open_config.lua',
    'open_functions.lua',
    'client/target_wrapper.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'open_config.lua'
}

client_scripts {
	'open_functions.lua',
    'client/target_wrapper.lua',
    'client/utils.lua',
    'client/client.lua'
}

server_scripts {
    'server/*.lua',
    'sv_loader.lua'
 }

dependency '/assetpacks'
dependency '/assetpacks'