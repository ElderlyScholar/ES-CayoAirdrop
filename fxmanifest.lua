fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'Noneya Business'
description 'An Airdrop system for cayo'
version '1.0.0'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    'config.lua',
}