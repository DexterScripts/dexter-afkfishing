fx_version 'cerulean'
game 'gta5'

author 'DonHulieo'
description 'An AFK Fishing Script for Qbox, ox_inventory, ox_target, and mz-skills'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {'server/main.lua'}

client_scripts {'client/utils.lua', 'client/main.lua'}

dependencies {'qbx_core', 'ox_inventory', 'ox_target', 'ox_lib', 'mz-skills'}

optional_dependencies {'z-phone'}

lua54 'yes'
