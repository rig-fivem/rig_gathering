--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

fx_version "cerulean"
games { "gta5" }
name "rig_gathering"
version "0.1.0"
description "Gathering/looting system for RIG (FiveM)."
license "Apache 2.0"
author "Case"
lua54 "yes"

files {
    "locales/*.json"
}

shared_scripts {
    "configs/*.lua",
    "init.lua"
}
client_scripts {
    "src/client/modules/*.lua",
    "src/client/main.lua"
}
server_scripts {
    "src/server/*.lua"
}

dependency "rig"