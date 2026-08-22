fx_version 'bodacious'
game 'gta5'
this_is_a_map 'yes'
author 'Prompt Studio'
version "1.0.0"

data_file 'AUDIO_GAMEDATA' 'audio/prompt_sandy_cars_game.dat' -- dat151

files {
  'audio/prompt_sandy_cars_game.dat151.rel'
}

escrow_ignore {
    'stream/unlocked/**',
  	'client.lua'
}

-- scripts --
lua54 'yes'

client_script 'client.lua'

server_scripts{
	'sv_Tokens.lua',
	'sv_MapChainHandler.lua',
	'sv_MapVersionCheck.lua'
}
dependency '/assetpacks'