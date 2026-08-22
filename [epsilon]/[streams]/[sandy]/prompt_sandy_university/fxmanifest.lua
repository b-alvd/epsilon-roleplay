lua54 'yes'
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'

author 'Prompt Studio'
description 'prompt_sandy_university'
version '1.0.1'

files {
	'meta/gtxd.meta'
}

--data_file 'DLC_ITYP_REQUEST' 'stream/it_shell.ytyp'
data_file 'GTXD_PARENTING_DATA' 'meta/gtxd.meta'


escrow_ignore {
    'stream/unlocked/**'
}

server_scripts{
	'sv_loader.lua'
}
dependency '/assetpacks'