fx_version 'cerulean'
game 'gta5'
author 'Prompt Mods Studio | Igro45'
version "1.0.3"
this_is_a_map 'yes'

files {
  'data/i45pth_gtxd.meta'
}

data_file 'GTXD_PARENTING_DATA' 'data/i45pth_gtxd.meta'


data_file 'AUDIO_GAMEDATA' 'audio/i45ptshospdoor.dat'

files {
    'audio/i45ptshospdoor.dat151.rel',
}

escrow_ignore {
    'stream/unlocked/**',
    'config.lua',
    'client/elevator.lua',
    'client/mri.lua',
    'client/beds.lua',
    'client/debug.lua',
    'server/mri.lua',
    'server/seats.lua',
}


lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/elevator.lua',
    'client/mri.lua',
    'client/beds.lua',
    'client/debug.lua',
}

server_scripts{
	'sv_loader.lua',
	'server/mri.lua',
	'server/seats.lua',
}
dependency '/assetpacks'