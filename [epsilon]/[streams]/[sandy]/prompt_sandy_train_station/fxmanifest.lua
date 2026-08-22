fx_version 'cerulean'
game 'gta5'
author 'Prompt' 
version '1.0.0' 
this_is_a_map 'yes'

data_file 'AUDIO_GAMEDATA' 'audio/prompt_sandy_train_game.dat'


files {
    'audio/prompt_sandy_train_game.dat151.rel'
}


escrow_ignore {
    'stream/unlocked/**'
}

-- scripts --
lua54 'yes'


server_scripts{
	'sv_Tokens.lua',
	'sv_MapChainHandler.lua',
	'sv_MapVersionCheck.lua'
}



dependency '/assetpacks'