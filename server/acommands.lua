local QBCore = exports['qb-core']:GetCoreObject()

-- fix weapon
if Config.Enable.acommands.fixw then
    lib.addCommand('fixw', {
        help = Lang:t("acommands.iinfo"),
        restricted = 'group.admin',
    }, function(source, args, raw)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end

        TriggerClientEvent('kps-addons:client:GetWeapon', source)
    end)

    RegisterNetEvent('kps-addons:server:FixSelectedW', function(wslot)
        local src = source
        lib.notify(src, {
            description = Lang:t("acommands.done"),
            type = 'success',
        })
        exports.ox_inventory:SetDurability(src, wslot, 100)
    end)
end

-- set player stat
if Config.Enable.acommands.setstat then
    lib.addCommand('setstat', {
        help = Lang:t("acommands.iinfo2"),
        restricted = 'group.admin',
        params = {
            {
                name = 'target',
                type = 'playerId',
                help = Lang:t("acommands.pid"),
            },
            {
                name = 'stat',
                type = 'string',
                help = Lang:t("acommands.wstat"),
            },
            {
                name = 'amount',
                type = 'number',
                help = Lang:t("acommands.wamount"),
            }
        }
    }, function(source, args, raw)
        local targetId = args.target
        local stat = args.stat:lower()
        local amount = args.amount

        if not targetId or not stat or not amount then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("acommands.errorstat"), 'error')
            return
        end

        local Player = QBCore.Functions.GetPlayer(targetId)
        if not Player then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("acommands.perror"), 'error')
            return
        end

        if stat == "hunger" then
            Player.Functions.SetMetaData('hunger', amount)
            TriggerClientEvent('hud:client:UpdateNeeds', targetId, amount, Player.PlayerData.metadata["thirst"])
        elseif stat == "thirst" then
            Player.Functions.SetMetaData('thirst', amount)
            TriggerClientEvent('hud:client:UpdateNeeds', targetId, amount, Player.PlayerData.metadata["hunger"])
        elseif stat == "armor" then
            SetPedArmour(GetPlayerPed(targetId), amount)
        elseif stat == "hp" then
            TriggerClientEvent("kps-addons:client:setHP", targetId, amount)
        elseif stat == "stress" then
            Player.Functions.SetMetaData('stress', amount)
            TriggerClientEvent('hud:client:UpdateStress', targetId, amount)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("acommands.serror"), 'error')
            return
        end

        TriggerClientEvent('QBCore:Notify', source, Lang:t("acommands.done2"), 'success')
    end)
end
