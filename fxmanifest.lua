fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'kopskink'
description 'A package of scripts'

lua54 'yes'

client_scripts {
    'client/*.lua',
}

shared_script {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    -- 'locales/et.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}