fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'BURRO'
description 'BRR - Essential Needs System'
version  "1.0.0"

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/*.lua',
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
	'shared/config.lua',
	'client/cl_utils.lua',
	'server/sv_utils.lua' 
}