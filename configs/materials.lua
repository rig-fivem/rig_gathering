--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

--- @module configs.materials
--- @description Stores all static data for harvestable materials

--- Material hashes: https://gist.github.com/DurtyFree/b37463ea9bfd3089fab696f554509977

return {

    -- Treebark
    [0x8DD4EBB9] = {
        label = "Tree",
        allowed_weapons = {
            "weapon_hatchet",
        },
        rewards = {
            chance = 50,
            item_amount = { min = 1, max = 1 },
            items = {
                wood = { label = "Wood", weight = 70, min = 2, max = 5 }
            }
        }
    },

    -- Rock
    [0xCDEB5023] = {
        label = "Rock",
        allowed_weapons = {
            "weapon_hatchet",
        },
        rewards = {
            chance = 50,
            item_amount = { min = 1, max = 1 },
            items = {
                stone = { label = "Stone", weight = 70, min = 2, max = 5 }
            }
        }
    },

    -- Stone? (not listed on DurtyFree's list)
    [0x079E4953] = {
        label = "Stone",
        allowed_weapons = {
            "weapon_hatchet",
        },
        rewards = {
            chance = 50,
            item_amount = { min = 1, max = 1 },
            items = {
                stone = { label = "Stone", weight = 70, min = 2, max = 5 }
            }
        }
    },

}