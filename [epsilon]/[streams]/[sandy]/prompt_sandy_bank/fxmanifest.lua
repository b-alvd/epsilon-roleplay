lua54 'yes'
fx_version 'cerulean'
game 'gta5'


author 'Prompt Studio | d1n'
description 'Sandy Shores Bank'
version '1.0.0'

this_is_a_map 'yes'

files {
    'd1n_sandy_bank_audio_game.dat151.rel'
}

data_file 'AUDIO_GAMEDATA' 'd1n_sandy_bank_audio_game.dat'

server_scripts{
	'sv_loader.lua'
}

escrow_ignore {
    'stream/unlocked/**'
}


--#client_scripts {
--#	'client.lua'
--#}
dependency '/assetpacks'