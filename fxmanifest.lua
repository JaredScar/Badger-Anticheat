fx_version 'bodacious'
games { 'gta5' }

author 'Badger'
description "Badger's Official Anticheat"

shared_script 'config.lua'

client_scripts {
    'Enumerators.lua',
    'client.lua', 
    'acloader.lua'
}

server_scripts {
    'server.lua',
}