local QBCore = exports['qb-core']:GetCoreObject()
local DebugLocation = nil
local netID = nil
local spawned = false
local respawnTime = (Config.RespawnTime * 60 * 1000)

----------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------

local function CreateCarePackage()
    local loc = Config.Locations[math.random(1, #Config.Locations)]
    local entity = CreateObjectNoOffset("xm_prop_crates_sam_01a", loc, true, true, false)

    netID = NetworkGetNetworkIdFromEntity(entity)

    Citizen.Wait(10)
    FreezeEntityPosition(entity, true)

    spawned = true

    if Config.Debug then
        DebugLocation = loc
        print("Create Network ID" .. netID)
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Announcement", "The Care Package Has Respawned!"}
    })
end

local function DeleteCarePackage()
    local entity = NetworkGetEntityFromNetworkId(netID)
    DeleteEntity(entity)
end

----------------------------------------------------------------------
-- Main
----------------------------------------------------------------------

RegisterServerEvent("ES-CayoAirdrop:server:Reward", function(ID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if ID == netID then
        if spawned ~= true then return end
        
        for i = 1, Config.ItemsAmount do
            local item = Config.Items[math.random(1, #Config.Items)]
            Player.Functions.AddItem(item, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", 1)
        end

        local entity = NetworkGetEntityFromNetworkId(ID)
        DeleteEntity(entity)
        spawned = false
        respawnTime = (Config.RespawnTime * 60 * 1000)
        netID = nil
    else
        print("Possible Wizzard!, Attempted To Trigger The Event!")
    end
end)

QBCore.Functions.CreateCallback('ES-CayoAirdrop:callback:GetNetID', function(source, cb)
    cb(netID)
end)

----------------------------------------------------------------------
-- Startup / Stop
----------------------------------------------------------------------

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    CreateCarePackage()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    DeleteCarePackage()
end)

----------------------------------------------------------------------
-- Debug
----------------------------------------------------------------------

QBCore.Functions.CreateCallback('ES-CayoAirdrop:callback:GetDebugLocation', function(source, cb)
    if Config.Debug then
        cb(DebugLocation)
    else
        cb(false)
    end
end)

----------------------------------------------------------------------
-- Clock
----------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if spawned ~= true then
            if respawnTime <= 0 then
                CreateCarePackage()
            else
                respawnTime = respawnTime - 1000
            end
        else
            respawnTime = (Config.RespawnTime * 60 * 1000)
        end
        Wait(sleep)
    end
end)
