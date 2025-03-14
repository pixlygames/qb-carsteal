fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Pixly Games'
description 'Car Stealing Script for QBCore'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'qb-core',
    'qb-target',
} 