local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.comms[311] then
    -- /311 Only LSPD chat
    lib.addCommand('311', {
        help = Lang:t("comms.help_311"),
        params = {
            {
                name = 'desc',
                type = 'longString',
                help = Lang:t("comms.desc_help"),
            },
        },
        restricted = false
    }, function(source, args, raw)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
    
        if not xPlayer then
            print("Error: Player not found.")
            return
        end
    
        if xPlayer.PlayerData.job.name ~= "police" then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.not_police")}
            })
            return
        end
    
        local desc = args.desc
        if not desc then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.no_message")}
            })
            return
        end
    
        local fname = xPlayer.PlayerData.charinfo.firstname or "-"
        local lname = xPlayer.PlayerData.charinfo.lastname or "-"
        local auaste = xPlayer.PlayerData.job.grade.name or "-"
        local callsign = xPlayer.PlayerData.metadata["callsign"] or "000"
    
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local targetPlayer = QBCore.Functions.GetPlayer(playerId)
            if targetPlayer and targetPlayer.PlayerData.job.name == "police" then
                TriggerClientEvent("chat:addMessage", playerId, {
                    color = Config.ChatMessageColor[311] or {191, 125, 67},
                    multiline = true,
                    args = {
                        ("(311) [%s] %s %s | %s"):format(callsign, fname, lname, auaste),
                        desc
                    }
                })
            end
        end
    end)
end

if Config.Enable.comms[310] then
    -- /310 EMS and LSPD chat
    lib.addCommand('310', {
        help = Lang:t("comms.help_310"),
        params = {
            {
                name = 'desc',
                type = 'longString',
                help = Lang:t("comms.desc_help"),
            },
        },
        restricted = false
    }, function(source, args, raw)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local job = xPlayer and xPlayer.PlayerData.job.name

        if not xPlayer or (job ~= "police" and job ~= "ambulance") then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.not_ems_police")}
            })
            return
        end

        local desc = args.desc
        if not desc then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.no_message")}
            })
            return
        end

        local fname = xPlayer.PlayerData.charinfo.firstname or "-"
        local lname = xPlayer.PlayerData.charinfo.lastname or "-"
        local auaste = xPlayer.PlayerData.job.grade.name or "-"
        local joblabel = xPlayer.PlayerData.job.label or "-"
        local callsign = xPlayer.PlayerData.metadata["callsign"] or "000"

        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local targetPlayer = QBCore.Functions.GetPlayer(playerId)
            if targetPlayer then
                local tJob = targetPlayer.PlayerData.job.name
                if tJob == "police" or tJob == "ambulance" then
                    TriggerClientEvent("chat:addMessage", playerId, {
                        color = Config.ChatMessageColor[310] or {124, 173, 95},
                        multiline = true,
                        args = {
                            ("(310) [%s - %s] %s %s | %s"):format(joblabel, callsign, fname, lname, auaste),
                            desc
                        }
                    })
                end
            end
        end
    end)
end

if Config.Enable.comms[312] then
    -- /312 Only EMS chat
    lib.addCommand('312', {
        help = Lang:t("comms.help_312"),
        params = {
            {
                name = 'desc',
                type = 'longString',
                help = Lang:t("comms.desc_help"),
            },
        },
        restricted = false
    }, function(source, args, raw)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)

        if not xPlayer or xPlayer.PlayerData.job.name ~= "ambulance" then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.not_ems")}
            })
            return
        end

        local desc = args.desc
        if not desc then
            TriggerClientEvent("chat:addMessage", src, {
                color = Config.ChatMessageColor.error,
                multiline = true,
                args = {Lang:t("comms.system"), Lang:t("comms.no_message")}
            })
            return
        end

        local fname = xPlayer.PlayerData.charinfo.firstname or "-"
        local lname = xPlayer.PlayerData.charinfo.lastname or "-"
        local auaste = xPlayer.PlayerData.job.grade.name or "-"
        local callsign = xPlayer.PlayerData.metadata["callsign"] or "000"

        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local targetPlayer = QBCore.Functions.GetPlayer(playerId)
            if targetPlayer and targetPlayer.PlayerData.job.name == "ambulance" then
                TriggerClientEvent("chat:addMessage", playerId, {
                    color = Config.ChatMessageColor[312] or {181, 85, 85},
                    multiline = true,
                    args = {
                        ("(312) [%s] %s %s | %s"):format(callsign, fname, lname, auaste),
                        desc
                    }
                })
            end
        end
    end)
end