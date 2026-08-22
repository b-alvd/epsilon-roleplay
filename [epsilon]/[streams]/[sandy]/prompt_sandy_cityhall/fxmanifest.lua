fx_version 'cerulean'
game 'gta5'
author 'Prompt Studio & Infames Dev' 
version '1.1.2' 
this_is_a_map 'yes'
description 'Sandy Shores City Hall'


files {
	'd1n_shc_timecycle.xml',
	'd1n_sch_audio_game.dat151.rel',
	'stream/interior/3015184349.ymt',
	'data/audioexample_sounds.dat54.rel',
	'audiodirectory/custom_sounds.awc',
	'stream/interior/unlocked/ytyp/d1n_sch_props.ytyp',
    'stream/interior/unlocked/ytyp/d1n_sch_ytyp.ytyp'
}


data_file 'AUDIO_GAMEDATA' 'd1n_sch_audio_game.dat'
data_file 'TIMECYCLEMOD_FILE' 'd1n_shc_timecycle.xml'
data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/audioexample_sounds.dat'
data_file 'DLC_ITYP_REQUEST' 'stream/interior/unlocked/ytyp/d1n_sch_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/interior/unlocked/ytyp/d1n_sch_ytyp.ytyp'


escrow_ignore {
    'stream/exterior/unlocked/**',
    'stream/interior/unlocked/**',
    'public_config.lua',
    'client/open.lua',
    'ipls_command.lua',
    'ipls_server.lua',
}

-- scripts --
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'public_config.lua',
    'internal_config.lua'
}

client_scripts {
    'client/utils.lua',
    'client/open.lua',
    'client/client.lua',
    'ipls_command.lua'
}

server_scripts {
	'sv_loader.lua',
	'server/*.lua',
	'ipls_server.lua'
}
dependency '/assetpacks'