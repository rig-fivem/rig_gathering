--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

--- @script server_gathering
--- @file src/server/main.lua
--- @description Main server side handling

--- @section Imports

local _models_cfg = require("configs.models")
local _utils = require("src.server.modules.utils")

--- @section State Tables

local search_states = {}

--- @section Helpers

local function coords_to_id(coords)
    local x, y, z = math.floor(coords.x + 0.5), math.floor(coords.y + 0.5), math.floor(coords.z + 0.5)
    return string.format("searchable_%d_%d_%d", x, y, z)
end

local function get_weighted_items(reward_def)
    if not reward_def or not reward_def.items or (reward_def.chance and math.random(100) > reward_def.chance) then 
        return nil 
    end

    local total_weight, choices = 0, {}
    for id, data in pairs(reward_def.items) do
        total_weight = total_weight + (data.weight or 1)
        choices[#choices + 1] = { id = id, data = data }
    end

    if #choices == 0 then return nil end

    local awarded = {}
    local min_amt = reward_def.item_amount and reward_def.item_amount.min or 1
    local max_amt = reward_def.item_amount and reward_def.item_amount.max or 1
    local count = math.random(min_amt, max_amt)

    while #awarded < count and #choices > 0 do
        local rand, cumulative = math.random(1, total_weight), 0
        for i = #choices, 1, -1 do
            local entry = choices[i]
            cumulative = cumulative + (entry.data.weight or 1)
            if rand <= cumulative then
                local min_i = entry.data.min or 1
                local max_i = entry.data.max or 1
                local amount = math.random(min_i, max_i)
                awarded[#awarded + 1] = { id = entry.id, label = entry.data.label or entry.id, amount = amount }
                total_weight = total_weight - (entry.data.weight or 1)
                table.remove(choices, i)
                break
            end
        end
    end

    return awarded
end

--- @section Events

RegisterNetEvent("rig_gathering:server:start_searchable", function(category_name, node_id, target_coords)
    local source_id = source
    local player_ped = GetPlayerPed(source_id)

    if not player_ped or player_ped == 0 then return end

    local category_data = _models_cfg[category_name]
    if not category_data then
        log("error", ("[rig_gathering] Invalid category requested by player %d: %s"):format(source_id, tostring(category_name)))
        return
    end

    if not target_coords or not target_coords.x or not target_coords.y or not target_coords.z or not node_id then
        log("error", ("[rig_gathering] Malformed payload received from player %d"):format(source_id))
        return
    end

    local target_vector = vector3(target_coords.x, target_coords.y, target_coords.z)

    local calculated_id = coords_to_id(target_vector)
    if calculated_id ~= node_id then
        log("warn", ("[rig_gathering] Player %d sent mismatched node ID and coordinates!"):format(source_id))
        return
    end

    local player_coords = GetEntityCoords(player_ped)
    if #(player_coords - target_vector) > 4.5 then
        log("warn", ("[rig_gathering] Player %d is too far from target coordinates. Distance: %.2fm"):format(source_id, #(player_coords - target_vector)))
        return
    end

    local cooldown_key = ("searchable_%s_%s"):format(category_name, node_id)
    if category_data.cooldown and exports.rig:check_cooldown(source_id, cooldown_key, category_data.cooldown.is_global) then
        exports.rig:notify(source_id, {
            type = "error",
            header = category_data.label,
            message = "This container has already been searched.",
            icon = "fa-solid fa-triangle-exclamation",
            duration = 4000
        })
        return
    end

    search_states[node_id] = search_states[node_id] or { player = nil, collected = false }
    local state = search_states[node_id]

    if state.collected or (state.player and state.player ~= source_id) then
        exports.rig:notify(source_id, {
            type = "error",
            header = category_data.label,
            message = "Someone is already searching this container.",
            icon = "fa-solid fa-lock",
            duration = 4000
        })
        return
    end

    state.player = source_id

    TriggerClientEvent("rig_gathering:client:play_searchable_anim", source_id, category_name, node_id, target_coords)
end)

RegisterNetEvent("rig_gathering:server:collect_searchable", function(category_name, node_id, target_coords)
    local source_id = source
    local category_data = _models_cfg[category_name]
    if not category_data then return end

    local state = search_states[node_id]
    if not state or state.collected or state.player ~= source_id then
        log("warn", ("[rig_gathering] Security Warning: Invalid collection state for player %d on node %s"):format(source_id, node_id))
        return
    end

    state.collected = true

    if category_data.cooldown then
        local cooldown_key = ("searchable_%s_%s"):format(category_name, node_id)
        exports.rig:add_cooldown(source_id, cooldown_key, category_data.cooldown.duration, category_data.cooldown.is_global)
    end

    local rewards = get_weighted_items(category_data.rewards)
    if not rewards or #rewards == 0 then
        exports.rig:notify(source_id, {
            type = "error",
            header = category_data.label,
            message = "You found nothing of interest inside.",
            icon = "fa-solid fa-box-open",
            duration = 3500
        })
        return
    end

    for _, reward in ipairs(rewards) do
        local success, err = exports.rig_inventory:add_item(source_id, reward.id, reward.amount)
        if success then
            exports.rig:notify(source_id, {
                type = "success",
                header = category_data.label,
                message = ("Found %d x %s"):format(reward.amount, reward.label),
                icon = "fa-solid fa-check-circle",
                duration = 3500
            })
        else
            exports.rig:notify(source_id, {
                type = "error",
                header = category_data.label,
                message = "Your inventory is too full to carry this!",
                icon = "fa-solid fa-triangle-exclamation",
                duration = 3500
            })
        end
    end
end)