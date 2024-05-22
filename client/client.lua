local QBCore = exports['qb-core']:GetCoreObject()
local netID = nil
local debugBlip = nil

Citizen.CreateThread(function()
    exports['qb-target']:AddTargetModel("xm_prop_crates_sam_01a", {
        options = {
            {
                type = "client",
                event = "",
                label = "Open Package",
                action = function(entity)
                    local Ped = PlayerPedId()
                    local dict = "mini@repair"
                    local animation = "fixing_a_ped"
                    
                    local netID = NetworkGetNetworkIdFromEntity(entity)

                    local time = Config.SearchTime

                    if Config.Debug then
                        time = 10000
                    end

                    RequestNamedPtfxAsset('core')
                    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end

                    UseParticleFxAssetNextCall("core")
                    SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
                    StartParticleFxLoopedOnEntity('weap_heist_flare_trail', entity, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0)

                    TriggerEvent('chat:addMessage', {
                        color = { 255, 0, 0},
                        multiline = true,
                        args = {"Announcement", "Someone Is Looting The Care Package!!!"}
                    })

                    QBCore.Functions.Progressbar('cayo_looting', 'Unpacking Care Package', time, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                        }, {
                            animDict = dict,
                            anim = animation,
                            flags = 0,
                            task = nil,
                        }, {}, {}, function()
                            ClearPedTasks(Ped)
                            TriggerServerEvent("ES-CayoAirdrop:server:Reward", netID)
                        end, function()
                            ClearPedTasks(Ped)
                    end)
                end,
                canInteract = function(entity, distance, data)
                    local id = NetworkGetNetworkIdFromEntity(entity)

                    if id == netID then
                        return true
                    else
                        return false
                    end
                end,            
            }
        },
        distance = 2.5,
    })
end)

if Config.Debug then
    RegisterCommand(Config.DebugCommand, function()
        QBCore.Functions.TriggerCallback('ES-CayoAirdrop:callback:GetDebugLocation', function(result)
            if result then
                if debugBlip ~= nil then
                    RemoveBlip(debugBlip)
                end
                local blip = AddBlipForCoord(result)
                SetBlipColour(blip, 1)
                SetBlipDisplay(blip, 2)
                SetBlipScale(blip, 0.7)
                SetBlipSprite(blip, 550)
                SetBlipAsShortRange(blip, false)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Airdrop")
                EndTextCommandSetBlipName(blip)

                debugBlip = blip
            end
        end)
    end, false)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    QBCore.Functions.TriggerCallback('ES-CayoAirdrop:callback:GetNetID', function(result)
        netID = result
    end, false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    RemoveBlip(debugBlip)
end)
