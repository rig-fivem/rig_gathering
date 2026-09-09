--[[
----------------------------------------
RIG Gathering (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_gathering
License: https://github.com/rig-fivem/rig_gathering/blob/main/LICENSE
----------------------------------------
]]

--- @script client_gathering
--- @file src/client/main.lua
--- @description Handles client-side prop searching using rig_interactions DUI sprites and animations module with distance tracking and cleanup.

--- @section Imports

local models_config = require("configs.models")
local animations = require("src.client.modules.animations")

--- @section Native Localization

local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetClosestObjectOfType = GetClosestObjectOfType
local GetHashKey = GetHashKey
local DoesEntityExist = DoesEntityExist
local IsPedInAnyVehicle = IsPedInAnyVehicle
local TriggerServerEvent = TriggerServerEvent
local RegisterNetEvent = RegisterNetEvent
local CreateThread = CreateThread
local Wait = Wait

--- @section State Tables

local active_nodes = {}
local is_searching = false

--- @section Helpers

local function coords_to_id(coords)
    local x, y, z = math.floor(coords.x + 0.5), math.floor(coords.y + 0.5), math.floor(coords.z + 0.5)
    return string.format("searchable_%d_%d_%d", x, y, z)
end

--- @section Functions

local function update_gathering_nodes()
    local player_ped = PlayerPedId()
    local player_coords = GetEntityCoords(player_ped)

    local current_frame_nodes = {}

    for category_name, category_data in pairs(models_config) do
        for _, model_name in ipairs(category_data.models) do
            local model_hash = GetHashKey(model_name)
            local closest_object = GetClosestObjectOfType(
                player_coords.x, player_coords.y, player_coords.z,
                15.0, model_hash, false, false, false
            )

            if DoesEntityExist(closest_object) then
                local obj_coords = GetEntityCoords(closest_object)
                local node_id = coords_to_id(obj_coords)
                local unique_dui_id = ("%s_%s"):format(category_name, node_id)

                current_frame_nodes[unique_dui_id] = true

                if not active_nodes[unique_dui_id] then
                    active_nodes[unique_dui_id] = true

                    exports.rig_interactions:add_dui_sprite({
                        id = unique_dui_id,
                        coords = { x = obj_coords.x, y = obj_coords.y, z = obj_coords.z + 1.0 },
                        header = category_data.label,
                        icon = category_data.icon or "fa-solid fa-magnifying-glass",
                        model = model_name,
                        outline = true,
                        keys = {
                            {
                                key = "e",
                                label = category_data.label,
                                on_action = function()
                                    if is_searching then return end
                                    if IsPedInAnyVehicle(player_ped, false) then return end

                                    TriggerServerEvent("rig_gathering:server:start_searchable", category_name, node_id, {
                                        x = obj_coords.x,
                                        y = obj_coords.y,
                                        z = obj_coords.z
                                    })
                                end
                            }
                        },
                        can_access = function()
                            return not is_searching
                        end
                    })
                end
            end
        end
    end

    for unique_dui_id, _ in pairs(active_nodes) do
        if not current_frame_nodes[unique_dui_id] then
            exports.rig_interactions:remove_dui_sprite(unique_dui_id)
            active_nodes[unique_dui_id] = nil
        end
    end
end

--- @section Events

RegisterNetEvent("rig_gathering:client:play_searchable_anim", function(category_name, node_id, target_coords)
    local ped = PlayerPedId()
    local category_data = models_config[category_name]
    if not category_data then return end

    is_searching = true

    animations.play(ped, {
        dict = category_data.animation.dict,
        anim = category_data.animation.anim,
        duration = math.floor(category_data.duration * 1000),
        flags = category_data.animation.flags,
        freeze = true
    }, function()
        TriggerServerEvent("rig_gathering:server:collect_searchable", category_name, node_id, target_coords)
        is_searching = false
    end)
end)

--- @section Threads

CreateThread(function()
    while true do
        update_gathering_nodes()
        Wait(1000)
    end
end)