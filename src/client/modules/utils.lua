--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

--- @module utils
--- @file src/client/modules/utils.lua
--- @description Handles client utility functions

local m = {}

function m.is_in_water(entity, allow_swimming)
    if not IsEntityInWater(entity) then return false end
    if not allow_swimming and IsPedSwimming(entity) then return false end
    return true
end

return m