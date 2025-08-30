local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.endsuffering then

    local downedPlayers = {}

        RegisterNetEvent("kps-addons:client:EndSufferingUpdateDownedPlayers", function(serverIds)
            downedPlayers = serverIds or {}
        end)

        function IsPlayerDowned(serverId)
            return downedPlayers[serverId] == true
        end

        exports.ox_target:addGlobalPlayer({
            label = Lang:t("endsuffering.target"),
            icon = 'fa-solid fa-skull',
            distance = 2.5,
            canInteract = function(entity, distance, data)
                local playerIndex = NetworkGetPlayerIndexFromPed(entity)
                if playerIndex ~= -1 then
                    local serverId = GetPlayerServerId(playerIndex)
                    return IsPlayerDowned(serverId)
                end
                return false
            end,
            onSelect = function(data)
                local playerIndex = NetworkGetPlayerIndexFromPed(data.entity)
                if playerIndex ~= -1 then
                    local serverId = GetPlayerServerId(playerIndex)
                    TriggerEvent('kps-addons:client:EndSufferingInitial', serverId)
                end
            end
        })

        RegisterNetEvent('kps-addons:client:EndSufferingInitial', function(serverId)
            TriggerServerEvent('kps-addons:server:EndSufferingCheckPlayerForRevival', serverId)
        end)

        RegisterNetEvent('kps-addons:client:EndSufferingShowProgressCircle', function(targetPlayerId)
            local playerPed = PlayerPedId()
            RequestAnimDict('amb@medic@standing@tendtodead@idle_a')
            while not HasAnimDictLoaded('amb@medic@standing@tendtodead@idle_a') do
                Wait(500)
            end
            TaskPlayAnim(playerPed, 'amb@medic@standing@tendtodead@idle_a', 'idle_a', 8.0, -8.0, -1, 49, 0, false, false, false)
            local progress = lib.progressCircle({
                label = Lang:t("endsuffering.doingaction"),
                duration = 5000,
                position = 'bottom',
                useWhileDead = false,
                allowCuffed = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    sprint = true,
                }
            })

            if progress then
                ClearPedTasks(playerPed)
                TriggerServerEvent('kps-addons:server:EndSufferingLast', targetPlayerId)
            else
                ClearPedTasks(playerPed)
                lib.notify({
                    description = Lang:t("consumables.cancelled"),
                    type = 'error',
                })
            end
        end)
    end