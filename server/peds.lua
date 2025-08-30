QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.peds then

    lib.addCommand('ped', {
        help = Lang:t("peds.command_help"),
        restricted = false
    }, function(source, args, raw)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end

        local citizenid = Player.PlayerData.citizenid

        MySQL.query('SELECT ped FROM kps_peds WHERE citizenid = ?', { citizenid }, function(result)
            local ped = result[1] and result[1].ped or nil
            TriggerClientEvent('kps-addons:client:openPedMenu', source, ped)
        end)
    end)

    RegisterNetEvent('kps-addons:server:savePedOutfit', function(data)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end

        local citizenid = Player.PlayerData.citizenid

        MySQL.query('SELECT owned_peds FROM kps_peds WHERE citizenid = ?', { citizenid }, function(result)
            local savedOutfits = {}

            if result[1] and result[1].owned_peds then
                savedOutfits = json.decode(result[1].owned_peds) or {}
            end

            table.insert(savedOutfits, data)

            local newJson = json.encode(savedOutfits)

            MySQL.update('UPDATE kps_peds SET owned_peds = ? WHERE citizenid = ?', { newJson, citizenid })
        end)
    end)

    RegisterNetEvent('kps-addons:server:getSavedPeds', function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end

        local citizenid = Player.PlayerData.citizenid

        MySQL.query('SELECT owned_peds FROM kps_peds WHERE citizenid = ?', { citizenid }, function(result)
            if result[1] and result[1].owned_peds then
                local saved = json.decode(result[1].owned_peds) or {}
                TriggerClientEvent('kps-addons:client:showSavedPedMenu', src, saved)
            else
                TriggerClientEvent('kps-addons:client:showSavedPedMenu', src, {})
            end
        end)
    end)

    RegisterNetEvent('kps-addons:server:deletePedOutfit', function(outfitName)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end

        local citizenid = Player.PlayerData.citizenid

        MySQL.query('SELECT owned_peds FROM kps_peds WHERE citizenid = ?', { citizenid }, function(result)
            if result[1] and result[1].owned_peds then
                local outfits = json.decode(result[1].owned_peds) or {}

                for i = #outfits, 1, -1 do
                    if outfits[i].name == outfitName then
                        table.remove(outfits, i)
                    end
                end

                MySQL.update('UPDATE kps_peds SET owned_peds = ? WHERE citizenid = ?', {
                    json.encode(outfits), citizenid
                })
            end
        end)
    end)

end