local QBCore = exports['qb-core']:GetCoreObject()

    local isHandcuffed = false

    local cuffedPlayers = {}

    local function loadAnimDict(dict)
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end

    local function HandCuffAnimation()
        local ped = PlayerPedId()
        
        loadAnimDict("mp_arrest_paired")
        Wait(100)
        
        if not isHandcuffed then
            -- Cuffing animation
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
            TaskPlayAnim(ped, "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
            Wait(3500)
            TaskPlayAnim(ped, "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
        else
            -- Uncuffing animation
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "Uncuff", 0.2)
            TaskPlayAnim(ped, "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
            Wait(3500)
            TaskPlayAnim(ped, "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
        end
    end

if Config.Enable.handcuffs then

    RegisterNetEvent("kps-addons:client:updateCuffedPlayers", function(serverIds)
        cuffedPlayers = serverIds or {}
    end)

    function IsPlayerCuffed(serverId)
        return cuffedPlayers[serverId] == true
    end

    exports.ox_target:addGlobalPlayer({
        label = Lang:t("handcuffs.remove_label"),
        icon = 'fa-solid fa-unlock',
        distance = 2.5,
        groups = {'police'},
        canInteract = function(entity, distance, data)
            local playerIndex = NetworkGetPlayerIndexFromPed(entity)
            if playerIndex ~= -1 then
                local serverId = GetPlayerServerId(playerIndex)
                return IsPlayerCuffed(serverId)
            end
            return false
        end,
        onSelect = function(data)
            local playerIndex = NetworkGetPlayerIndexFromPed(data.entity)
            if playerIndex ~= -1 then
                local targetId = GetPlayerServerId(playerIndex)
                TriggerServerEvent("kps-addons:server:UncuffPlayerWithReturn", targetId)
            end
        end
    })

    local function GetCuffedAnimation(playerId)
        local ped = PlayerPedId()
        local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
        local heading = GetEntityHeading(cuffer)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
        loadAnimDict("mp_arrest_paired")
        SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))

        Wait(100)
        SetEntityHeading(ped, heading)
        TaskPlayAnim(ped, "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0 ,true, true, true)
        Wait(2500)
    end

    lib.callback.register('kps-addons:client:IsPlayerAlreadyCuffed', function()
        return isHandcuffed
    end)

    RegisterNetEvent('kps-addons:client:CuffTargetPlayer', function()
        if not IsPedRagdoll(PlayerPedId()) then
            local player, distance = QBCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 1.5 then
                local playerId = GetPlayerServerId(player)
                if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(PlayerPedId()) then
                    lib.callback('kps-addons:server:IsPlayerAlreadyCuffed', false, function(isCuffed)
                        if isCuffed then
                            lib.notify({Lang:t("handcuffs.already_cuffed"), type = "error"})
                            return
                        end
                        TriggerServerEvent("kps-addons:server:ACCTargetPlayer", playerId, true)
                        HandCuffAnimation()
                    end, playerId)
                else
                    lib.notify({description = Lang:t("handcuffs.in_vehicle"), type = "error"})
                end
            else
                lib.notify({description = Lang:t("handcuffs.no_nearby_player"), type = "error"})
            end
        else
            Wait(2000)
        end
    end)

    RegisterNetEvent('kps-addons:client:GetCuffed', function(sourcePlayerId)
        local ped = PlayerPedId()
        local playerId = sourcePlayerId
        local settings = Config.HandcuffSettings.escape_settings
    
        if not isHandcuffed then
            local skillCheckSteps = {}
            for _, step in ipairs(settings.skillcheck) do
                table.insert(skillCheckSteps, step)
            end
    
            local success = lib.skillCheck(skillCheckSteps)
    
            if success then
                local chance = math.random(1, 100)
                if chance <= settings.chance then
                    LocalPlayer.state.invBusy = true
                    isHandcuffed = true
                    TriggerServerEvent("kps-addons:server:SetCuffData", true)
                    ClearPedTasksImmediately(ped)
                    if GetSelectedPedWeapon(ped) ~= GetHashKey('WEAPON_UNARMED') then
                        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                    end
                    cuffType = 49
                    GetCuffedAnimation(playerId)
                    lib.notify({description = Lang:t("handcuffs.cuffed_can_move"), type = 'inform'})
                else
                    TriggerServerEvent("kps-addons:server:GiveBackHandcuffs")
                    TriggerServerEvent("kps-addons:server:SetCuffData", false)
                    LocalPlayer.state.invBusy = false
                    isHandcuffed = false
                    isEscorted = false
                    GetCuffedAnimation(playerId)
                    TriggerEvent('hospital:client:isEscorted', isEscorted)
                    DetachEntity(ped, true, false)
                    ClearPedTasksImmediately(ped)
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "Uncuff", 0.2)
                    TriggerServerEvent('hud:server:GainStress', math.random(2, 3))
                    lib.notify({description = Lang:t("handcuffs.escaped_handcuffs"), type = "success"})
                end
            else
                LocalPlayer.state.invBusy = true
                isHandcuffed = true
                TriggerServerEvent("kps-addons:server:SetCuffData", true)
                ClearPedTasksImmediately(ped)
                if GetSelectedPedWeapon(ped) ~= GetHashKey('WEAPON_UNARMED') then
                    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                end
                cuffType = 49
                GetCuffedAnimation(playerId)
                lib.notify({description = Lang:t("handcuffs.cuffed_can_move"), type = 'inform'})
            end
        else
            isHandcuffed = false
            isEscorted = false
            TriggerEvent('hospital:client:isEscorted', isEscorted)
            DetachEntity(ped, true, false)
            TriggerServerEvent("kps-addons:server:SetCuffData", false)
            ClearPedTasksImmediately(ped)
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "Uncuff", 0.2)
            lib.notify({description = Lang:t("handcuffs.uncuffed"), type = 'inform'})
        end
    end)

    CreateThread(function()
        while true do
            Wait(1)
            if isHandcuffed then
                LocalPlayer.state.invBusy = true
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, 45, true)

                DisableControlAction(0, 45, true) -- Reload
                DisableControlAction(0, 22, true) -- Jump
                DisableControlAction(0, 44, true) -- Cover
                DisableControlAction(0, 37, true) -- Select Weapon
                DisableControlAction(0, 23, true) -- Also 'enter'?

                DisableControlAction(0, 288, true) -- Disable phone
                DisableControlAction(0, 289, true) -- Inventory
                DisableControlAction(0, 170, true) -- Animations
                DisableControlAction(0, 167, true) -- Job

                DisableControlAction(0, 26, true) -- Disable looking behind
                DisableControlAction(0, 73, true) -- Disable clearing animation
                DisableControlAction(2, 199, true) -- Disable pause screen

                DisableControlAction(0, 59, true) -- Disable steering in vehicle
                DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
                DisableControlAction(0, 72, true) -- Disable reversing in vehicle

                DisableControlAction(2, 36, true) -- Disable going stealth

                DisableControlAction(0, 264, true) -- Disable melee
                DisableControlAction(0, 257, true) -- Disable melee
                DisableControlAction(0, 140, true) -- Disable melee
                DisableControlAction(0, 141, true) -- Disable melee
                DisableControlAction(0, 142, true) -- Disable melee
                DisableControlAction(0, 143, true) -- Disable melee
                DisableControlAction(1, 19, true) -- Disable ALT
                DisableControlAction(0, 75, true)  -- Disable exit vehicle
                DisableControlAction(27, 75, true) -- Disable exit vehicle
                EnableControlAction(0, 249, true) -- Added for talking while cuffed
                EnableControlAction(0, 46, true)  -- Added for talking while cuffed



                if (not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not IsEntityPlayingAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3)) and not QBCore.Functions.GetPlayerData().metadata["isdead"] then
                    loadAnimDict("mp_arresting")
                    TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, cuffType, 0, 0, 0, 0)
                end
            end
            if not isHandcuffed then
                LocalPlayer.state.invBusy = false
                Wait(2000)
            end
        end
    end)

    lib.callback.register('kps-addons:client:IsPlayerCuffed', function()
        return isHandcuffed
    end)

    RegisterNetEvent('kps-addons:client:UseWireCuttersOnPlayer', function()
        if not IsPedRagdoll(PlayerPedId()) then
            local player, distance = QBCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 2.5 then
                local playerId = GetPlayerServerId(player)
                if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(PlayerPedId()) then
    
                    lib.callback('kps-addons:server:IsPlayerCuffed', false, function(isCuffed)
                        if not isCuffed then
                            lib.notify({description = Lang:t("handcuffs.already_uncuffed"), type = "error"})
                            return
                        end
    
                        TriggerServerEvent("kps-addons:server:ReduceWirecutterDurability", playerId)
    
                        local skillCheckSteps = {}
                        for _, step in ipairs(Config.HandcuffSettings.wirecutter_settings.skillcheck) do
                            table.insert(skillCheckSteps, step)
                        end
    
                        local cancelled = false
                        local skillCheckActive = true
    
                        CreateThread(function()
                            while skillCheckActive do
                                local currentPlayer = PlayerPedId()
                                local targetPed = GetPlayerPed(player)
                                local dist = #(GetEntityCoords(currentPlayer) - GetEntityCoords(targetPed))
    
                                if dist > 2.5 then
                                    cancelled = true
                                    break
                                end
                                Wait(100)
                            end
                        end)
    
                        local success = lib.skillCheck(skillCheckSteps)
                        skillCheckActive = false
    
                        if cancelled then
                            lib.notify({description = Lang:t("handcuffs.p_toofar"), type = "error"})
                            return
                        end
    
                        if success then
                            TriggerServerEvent("kps-addons:server:RemoveTargetCuffs", playerId, true)
                            HandCuffAnimation()
                        else
                            lib.notify({description = Lang:t("handcuffs.wirecut_fail"), type = "error"})
                        end
                    end, playerId)
    
                else
                    lib.notify({description = Lang:t("handcuffs.in_vehicle"), type = "error"})
                end
            else
                lib.notify({description = Lang:t("handcuffs.no_nearby_player"), type = "error"})
            end
        else
            Wait(2000)
        end
    end)

    RegisterNetEvent('kps-addons:client:GetWireCutterUncuffed', function(sourcePlayerId)
        local ped = PlayerPedId()
        isHandcuffed = false
        isEscorted = false
        LocalPlayer.state.invBusy = false
        ClearPedTasksImmediately(ped)
        TriggerEvent('hospital:client:isEscorted', isEscorted)
        DetachEntity(ped, true, false)
        TriggerServerEvent("kps-addons:server:SetCuffData", false)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "Uncuff", 0.2)
        lib.notify({description = Lang:t("handcuffs.wirecut_success"), type = 'success'})
    end)
    
end