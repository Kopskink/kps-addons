local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.peds then

    local assignedPed = nil

    local blockedPeds = {
        "u_m_y_juggernaut_01", -- add more if needed
    }

    local function LoadPlayerModel(skin)
        RequestModel(skin)
        while not HasModelLoaded(skin) do
            Wait(0)
        end
    end

    local function isPedAllowedRandom(skin)
        local retval = false
        for _, v in pairs(blockedPeds) do
            if v ~= skin then
                retval = true
            end
        end
        return retval
    end

    RegisterNetEvent('kps-addons:client:openPedMenu', function(playerPedName)
        assignedPed = playerPedName

        if not playerPedName then
            lib.notify({
                description = Lang:t("peds.nopedset"),
                type = 'error'
            })
            return
        end

        local ped = PlayerPedId()
        local currentModel = GetEntityModel(ped)
        local targetModel = GetHashKey(playerPedName)

        local desc
        if currentModel == targetModel then
            desc = Lang:t("peds.changepedback")
        else
            desc = Lang:t("peds.setgivenped")
        end

        lib.registerContext({
            id = 'kps-pedmenu',
            title = Lang:t("peds.yourpeds"),
            options = {
                {
                    title = Lang:t("peds.savedpedsettings"),
                    onSelect = function()
                        TriggerEvent('kps-addons:client:openSavedPedMenu')
                    end
                },
                {
                    title = playerPedName,
                    description = desc,
                    icon = 'fa-solid fa-gear',
                    onSelect = function()
                        local ped = PlayerPedId()
                        local currentModel = GetEntityModel(ped)
                        local targetModel = GetHashKey(playerPedName)

                        if currentModel == targetModel then
                            ExecuteCommand('reloadskin')
                            lib.notify({
                                description = Lang:t("peds.pedremoved"),
                                type = 'success'
                            })
                        else
                            TriggerEvent('kps-addons:client:setPed', playerPedName)
                            lib.notify({
                                description = Lang:t("peds.pedenabled"),
                                type = 'success'
                            })
                        end
                    end
                },
            },
        })

        lib.showContext('kps-pedmenu')
    end)

    RegisterNetEvent('kps-addons:client:openSavedPedMenu', function()
        TriggerServerEvent('kps-addons:server:getSavedPeds')
    end)

    RegisterNetEvent('kps-addons:client:showSavedPedMenu', function(savedPeds)
        local options = {
            {
                title = Lang:t("peds.savecurrent"),
                icon = 'floppy-disk',
                onSelect = function()
                    local playerPed = PlayerPedId()
                    local currentModel = GetEntityModel(playerPed)
            
                    if not assignedPed then
                        lib.notify({
                            title = Lang:t("peds.pederror"),
                            description = Lang:t("peds.nopedset"),
                            type = "error"
                        })
                        return
                    end
            
                    local targetModel = GetHashKey(assignedPed)
            
                    if currentModel ~= targetModel then
                        lib.notify({
                            title = Lang:t("peds.pederror"),
                            description = Lang:t("peds.saveforsetonly"),
                            type = "error"
                        })
                        return
                    end
            
                    local pedComponents = exports['illenium-appearance']:getPedComponents(playerPed)
                    local pedProps = exports['illenium-appearance']:getPedProps(playerPed)
                    
                    local input = lib.inputDialog(Lang:t("peds.saveped"), {
                        { label = Lang:t("peds.outfit_name"), type = "input", required = true }
                    })
            
                    if not input or not input[1] then return end
            
                    local saveData = {
                        name = input[1],
                        model = currentModel,
                        components = pedComponents,
                        props = pedProps
                    }
            
                    TriggerServerEvent('kps-addons:server:savePedOutfit', saveData)
                    lib.notify({ title = Lang:t("peds.saved"), description = Lang:t("peds.outfit_saved"), type = "success" })
                end
            },
            {
                title = Lang:t("peds.outfit_del"),
                icon = 'fa-trash-can',
                onSelect = function()
                    local deleteOptions = {}
            
                    for _, outfit in pairs(savedPeds) do
                        table.insert(deleteOptions, {
                            title = outfit.name,
                            description = Lang:t("peds.outfit_del_desc"),
                            icon = 'trash',
                            onSelect = function()
                                TriggerServerEvent('kps-addons:server:deletePedOutfit', outfit.name)
                                lib.notify({
                                    title = Lang:t("peds.outfit_del_noti"),
                                    description = Lang:t('peds.outfit_removed', { outfit = outfit.name }),
                                    type = "warning",
                                })
                            end
                        })
                    end
            
                    lib.registerContext({
                        id = 'kps-deletepedmenu',
                        title = Lang:t("peds.outfit_del_selec"),
                        menu = 'kps-savedpedmenu',
                        options = deleteOptions
                    })
            
                    lib.showContext('kps-deletepedmenu')
                end
            },
        }

        for _, outfit in pairs(savedPeds) do
            table.insert(options, {
                title = Lang:t('peds.outfit_save_list', { outfit = outfit.name }),
                description = Lang:t("peds.outfit_save_desc"),
                onSelect = function()
                    exports['illenium-appearance']:setPlayerAppearance({
                        model = outfit.model,
                        components = outfit.components,
                        props = outfit.props
                    })
                    lib.notify({ title = Lang:t("peds.outfit_loaded"), description = Lang:t('peds.outfit_loaded_desc', { outfit = outfit.name }), type = "info" })
                end
            })
        end

        lib.registerContext({
            id = 'kps-savedpedmenu',
            title = Lang:t("peds.outfit_yoursaves"),
            menu = 'kps-pedmenu',
            options = options
        })

        lib.showContext('kps-savedpedmenu')
    end)

    RegisterNetEvent('kps-addons:client:setPed', function(pedName)
        local ped = PlayerPedId()
        local model = GetHashKey(pedName)
        SetEntityInvincible(ped, true)

        if IsModelInCdimage(model) and IsModelValid(model) then
            LoadPlayerModel(model)
            SetPlayerModel(PlayerId(), model)

            if isPedAllowedRandom(pedName) then
                SetPedRandomComponentVariation(ped, true)
            end

            SetModelAsNoLongerNeeded(model)
        end
        SetEntityInvincible(ped, false)
    end)

end