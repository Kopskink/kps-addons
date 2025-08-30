local QBCore = exports['qb-core']:GetCoreObject()

-- NICOTINE POUCHES

if Config.Enable.consumables.nicotine_pouches then
    local tups = 0
    local isTupsLoopRunning = false

    local function PlayTupsEmoteAndHeal()
        local ped = PlayerPedId()
        RequestAnimDict("anim@mp_player_intcelebrationfemale@nose_pick")
        while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@nose_pick") do
            Wait(100)
        end
        TaskPlayAnim(ped, "anim@mp_player_intcelebrationfemale@nose_pick", "nose_pick", 8.0, -8.0, 2500, 49, 0, false, false, false)
        Wait(2500)
        ClearPedTasks(ped)
        Wait(2500)
        TriggerServerEvent('hud:server:RelieveStress', math.random(1, 5))
    end

    local function StartTupsLoop()
        if isTupsLoopRunning then return end

        isTupsLoopRunning = true

        CreateThread(function()
            local consumed = 0
            while tups > 0 and consumed < 2 do
                Wait(100000) -- 10 minutes
                tups -= 1
                consumed += 1
                PlayTupsEmoteAndHeal()
            end
            isTupsLoopRunning = false
        end)
    end

    RegisterNetEvent('kps-addons:client:useTups', function()

        if tups >= 2 then
            lib.notify({
                description = Lang:t("consumables.maxfresh"),
                type = 'inform',
            })
            return
        end

        local success = lib.progressBar({
            duration = 2500,
            label = Lang:t("consumables.usingnicpouch"),
            useWhileDead = false,
            allowCuffed = false,
            canCancel = true,
            disable = {
                car = false,
                combat = true,
                sprint = true,
            },
            anim = {
                dict = 'mp_suicide',
                clip = 'pill'
            },
        })

        if success then
            TriggerServerEvent('kps-addons:server:useTups')
            tups += 1

            if not isTupsLoopRunning then
                StartTupsLoop()
            end
        end
    end)
end

-- ADRENALINE SYRINGE

if Config.Enable.consumables.adrenaline_syringe then
    local downedPlayers = {}

    RegisterNetEvent("kps-addons:client:updateDownedPlayers", function(serverIds)
        downedPlayers = serverIds or {}
    end)

    function IsPlayerDowned(serverId)
        return downedPlayers[serverId] == true
    end

    exports.ox_target:addGlobalPlayer({
        label = Lang:t("consumables.useadresys"),
        icon = 'fa-solid fa-syringe',
        distance = 2.5,
        items = {'adresys'},
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
                TriggerEvent('kps-addons:client:useAdreSys', serverId)
            end
        end
    })

    RegisterNetEvent('kps-addons:client:useAdreSys', function(serverId)
        local hasItem = QBCore.Functions.HasItem('adresys')
        if hasItem then
                TriggerServerEvent('kps-addons:server:CheckPlayerForRevival', serverId)
            else
                lib.notify({
                    description = Lang:t("consumables.noequipment"),
                    type = 'error',
                })
            end
    end)

    RegisterNetEvent('kps-addons:client:ShowProgressCircle', function(targetPlayerId)
        local playerPed = PlayerPedId()
        RequestAnimDict('amb@medic@standing@tendtodead@idle_a')
        while not HasAnimDictLoaded('amb@medic@standing@tendtodead@idle_a') do
            Wait(500)
        end
        TaskPlayAnim(playerPed, 'amb@medic@standing@tendtodead@idle_a', 'idle_a', 8.0, -8.0, -1, 49, 0, false, false, false)
        local progress = lib.progressCircle({
            label = Lang:t("consumables.usingadresys"),
            duration = 12000,
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
            TriggerServerEvent('kps-addons:server:adresyslast', targetPlayerId)
        else
            ClearPedTasks(playerPed)
            lib.notify({
                description = Lang:t("consumables.cancelled"),
                type = 'error',
            })
        end
    end)
end