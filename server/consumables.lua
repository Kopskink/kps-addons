local QBCore = exports['qb-core']:GetCoreObject()

-- NICOTINE POUCHES

if Config.Enable.consumables.nicotine_pouches then
    QBCore.Functions.CreateUseableItem('tups', function(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            TriggerClientEvent("kps-addons:client:useTups", source)
        end
    end)

    QBCore.Functions.CreateUseableItem('tupsukarp', function(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            xPlayer.Functions.RemoveItem('tupsukarp', 1)
            xPlayer.Functions.AddItem('tups', 27)
        end
    end)

    RegisterNetEvent('kps-addons:server:useTups', function()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.RemoveItem('tups', 1)
        end
    end)
end

-- ADRENALINE SYRINGE
if Config.Enable.consumables.adrenaline_syringe then
    CreateThread(function()
        while true do
            Wait(1000)
            local players = QBCore.Functions.GetPlayers()
            local downedPlayers = {}

            for _, playerId in pairs(players) do
                local Player = QBCore.Functions.GetPlayer(playerId)
                if Player then
                    local inlaststand = Player.PlayerData.metadata["inlaststand"]
                    local dead = Player.PlayerData.metadata["isdead"]

                    if inlaststand or dead then
                        downedPlayers[playerId] = true
                    end
                end
            end

            TriggerClientEvent("kps-addons:client:updateDownedPlayers", -1, downedPlayers)
        end
    end)

    RegisterNetEvent('kps-addons:server:CheckPlayerForRevival', function(targetPlayerId)
        exports.ox_inventory:RemoveItem(source, 'adresys', 1)
        TriggerClientEvent("kps-addons:client:ShowProgressCircle", source, targetPlayerId)
    end)

    RegisterNetEvent('kps-addons:server:adresyslast', function(targetPlayerId)
        TriggerClientEvent('hospital:client:Revive', targetPlayerId)
    end)
end