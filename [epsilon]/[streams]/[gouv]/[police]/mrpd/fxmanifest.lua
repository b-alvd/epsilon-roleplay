fx_version 'bodacious'
game 'gta5'
description 'Mission Row dept.'

this_is_a_map 'yes'
lua54 'yes'

data_file 'TIMECYCLEMOD_FILE' 'kiiya_timecycle.xml'

files {
  'mrpd_game.dat151.rel',
  'kiiya_timecycle.xml',
}

data_file 'AUDIO_GAMEDATA' 'mrpd_game.dat'

client_scripts {
  'config.lua',
  'NativeUI.lua',
  'menu.lua',
  'functions.lua',
  'meta_client.lua',
}

escrow_ignore {
  'stream/ydr/kiiya_hei_dt1_19_lspd02.ydr',
  'stream/ydr/dt1_19_cp_01.ydr',
  'stream/ydr/dt1_19_cp_01_shadow.ydr',
  'stream/ydr/dt1_19_decal01.ydr',
  'stream/ydr/dt1_19_ground.ydr',
  'stream/ydr/dt1_19_hedge.ydr',
  'stream/ydr/dt1_19_hedge_d.ydr',
  'stream/ydr/dt1_19_lspd05.ydr',
  'stream/ydr/dt1_19_pipes.ydr',
  'stream/ydr/kiiya_d1_19_lspd_decal02.ydr',
  'stream/ydr/kiiya_d1_19_lspd_dirt.ydr',
  'stream/ydr/kiiya_hei_dt1_19_lspd02.ydr', 
  'stream/ydr/kiiya_mrpd_prop_lobby_text.ydr',
  'config.lua',
  }

dependency '/assetpacks'