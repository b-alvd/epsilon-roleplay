fx_version 'cerulean'
game 'gta5'
description 'maps'
lua54 'yes'
this_is_a_map 'yes'

escrow_ignore {
    'stream/unlocked/**',
    'stream/_manifest.ymf',
    'stream/ybn/**',
    'stream/ymap/**',
    'stream/ymf/**',
    'stream/ytd/**',
    'stream/ytyp/**',
}

server_scripts {
	'sv_loader.lua'
}
dependency '/assetpacks'