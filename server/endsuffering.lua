local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.endsuffering then

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

            TriggerClientEvent("kps-addons:client:EndSufferingUpdateDownedPlayers", -1, downedPlayers)
        end
    end)

    RegisterNetEvent('kps-addons:server:EndSufferingCheckPlayerForRevival', function(targetPlayerId)
        TriggerClientEvent("kps-addons:client:EndSufferingShowProgressCircle", source, targetPlayerId)
    end)

    RegisterNetEvent('kps-addons:server:EndSufferingLast', function(targetPlayerId)
        TriggerClientEvent('hospital:client:RespawnAtHospital', targetPlayerId)
    end)

end