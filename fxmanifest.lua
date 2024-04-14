fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'BuongiornoDEV_DROGHE'

author 'BuongiornoDEV'

discord 'https://discord.gg/HFZ7rse96S'

shared_script "@es_extended/imports.lua"
shared_script '@ox_lib/init.lua'

server_scripts {
    'Config.lua',
    'Server/**.lua',
}

client_scripts {
    'Config.lua',
    'Client/**.lua',
}