local QBCore = exports['qb-core']:GetCoreObject()

    local cuffedPlayers = {}

if Config.Enable.handcuffs then

    RegisterNetEvent("kps-addons:server:SetCuffData", function(state)
        local src = source
        if state then
            cuffedPlayers[src] = true
        else
            cuffedPlayers[src] = nil
        end
    end)

    CreateThread(function()
        while true do
            Wait(1000)
            TriggerClientEvent("kps-addons:client:updateCuffedPlayers", -1, cuffedPlayers)
        end
    end)

    RegisterNetEvent("kps-addons:server:UncuffPlayerWithReturn", function(targetId)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayer(targetId)

        if not Player or not Target then return end
        if Player.PlayerData.job.name ~= "police" then return end

        TriggerClientEvent("kps-addons:client:GetCuffed", targetId, src)

        Player.Functions.AddItem("newhandcuffs", 1)
    end)

    QBCore.Functions.CreateUseableItem("newhandcuffs", function(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player.Functions.GetItemByName("newhandcuffs") then return end
        TriggerClientEvent("kps-addons:client:CuffTargetPlayer", src)
    end)

    lib.callback.register('kps-addons:server:IsPlayerAlreadyCuffed', function(source, targetId)
        return lib.callback.await('kps-addons:client:IsPlayerAlreadyCuffed', targetId)
    end)

    RegisterNetEvent('kps-addons:server:ACCTargetPlayer', function(playerId)
        local src = source
        local playerPed = GetPlayerPed(src)
        local targetPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local targetCoords = GetEntityCoords(targetPed)

        if #(playerCoords - targetCoords) > 2.5 then
            return DropPlayer(src, "Attempted exploit abuse")
        end

        local Player = QBCore.Functions.GetPlayer(src)
        local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)

        if not Player or not CuffedPlayer then return end

        local isPolice = Player.PlayerData.job.name == "police"
        local hasHandcuffs = Player.Functions.GetItemByName("newhandcuffs")

        if not hasHandcuffs then return end

        if hasHandcuffs.amount > 0 then
            Player.Functions.RemoveItem("newhandcuffs", 1)
        end

        TriggerClientEvent("kps-addons:client:GetCuffed", CuffedPlayer.PlayerData.source, Player.PlayerData.source)
    end)

    RegisterNetEvent("kps-addons:server:GiveBackHandcuffs", function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddItem("newhandcuffs", 1)
        end
    end)

    QBCore.Functions.CreateUseableItem("wirecutters", function(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player.Functions.GetItemByName("wirecutters") then return end
        TriggerClientEvent("kps-addons:client:UseWireCuttersOnPlayer", src)
    end)

    RegisterNetEvent('kps-addons:server:RemoveTargetCuffs', function(playerId)
        local src = source
        local playerPed = GetPlayerPed(src)
        local targetPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local targetCoords = GetEntityCoords(targetPed)
        if #(playerCoords - targetCoords) > 3.5 then return DropPlayer(src, "Attempted exploit abuse") end

        local Player = QBCore.Functions.GetPlayer(src)
        local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)
        if not Player or not CuffedPlayer or (not Player.Functions.GetItemByName("wirecutters")) then return end

        TriggerClientEvent("kps-addons:client:GetWireCutterUncuffed", CuffedPlayer.PlayerData.source, Player.PlayerData.source)
    end)

    RegisterNetEvent("kps-addons:server:ReduceWirecutterDurability", function()
        local src = source
        local items = exports.ox_inventory:GetInventoryItems(src)
        
        for _, item in pairs(items) do
            if item.name == "wirecutters" then
                local currentDurability = item.metadata and item.metadata.durability or 100
                local newDurability = math.max(currentDurability - 20, 0)
                exports.ox_inventory:SetDurability(src, item.slot, newDurability)

                if newDurability <= 0 then
                    exports.ox_inventory:RemoveItem(src, "wirecutters", 1, nil, item.slot)
                    lib.notify(src, {
                        description = Lang:t("handcuffs.wirecut_fail"),
                        type = 'error',
                    })
                end

                break
            end
        end
    end)

    lib.callback.register('kps-addons:server:IsPlayerCuffed', function(source, targetId)
        return lib.callback.await('kps-addons:client:IsPlayerCuffed', targetId)
    end)

end