--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

--- @module configs.models
--- @file configs/models.lua
--- @description Stores all data for searchable prop models

return {

    bin = {
        models = { "prop_bin_08a", "prop_bin_07c", "prop_bin_05a", "prop_bin_01a", "prop_bin_02a", "prop_bin_03a", "prop_bin_04a", "prop_bin_06a", "prop_bin_07b", "prop_bin_07a", "prop_bin_08open" },
        label = "Search Bin",
        duration = 3.5,
        animation = { dict = "amb@world_human_bum_wash@male@low@idle_a", anim = "idle_a", flags = 1 },
        cooldown = { duration = 60, is_global = true },
        rewards = { 
            chance = 100, 
            item_amount = { min = 1, max = 3 },
            items = {
                water = { label = "Water", weight = 25, min = 1, max = 3 }
            }
        }
    },

    dumpster = {
        models = { "prop_dumpster_01a", "prop_dumpster_02a", "prop_dumpster_02b", "prop_dumpster_03a", "prop_dumpster_04a", "prop_dumpster_04b" },
        label = "Search Dumpster",
        duration = 3.5,
        animation = { dict = "amb@world_human_bum_wash@male@low@idle_a", anim = "idle_a", flags = 1 },
        cooldown = { duration = 60, is_global = true },
        rewards = { 
            chance = 100, 
            item_amount = { min = 1, max = 3 },
            items = {
                water = { label = "Water", weight = 25, min = 1, max = 3 }
            }
        }
    },
}