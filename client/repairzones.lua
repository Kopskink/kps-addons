local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.repairzones then

    for name, data in pairs(Config.RepairZonesLocSettings) do
        lib.zones.box({
            coords = data.zone.coords,
            size = data.zone.size,
            rotation = data.zone.rotation,
            debug = data.zone.debug or false,
            onEnter = function(self)
                if cache.vehicle then
                    lib.showTextUI(Lang:t("repairzones.textui_label"), {
                        position = Config.RepairZonesOverallSettings.textui.position,
                        icon = Config.RepairZonesOverallSettings.textui.icon,
                    })
                end
            end,
            onExit = function(self)
                lib.hideTextUI()
            end,
            inside = function(self)
                if cache.vehicle and IsControlJustPressed(0, Config.RepairZonesOverallSettings.repair_button) then
                    local Player = QBCore.Functions.GetPlayerData()
                    local job = Player.job.name
                    
                    local allowed = false
                    for _, group in ipairs(data.groups) do
                        if job == group then
                            allowed = true
                            break
                        end
                    end
                    
                    if allowed then
                        local progress = lib.progressBar({
                            duration = Config.RepairZonesOverallSettings.repair_time,
                            label = Lang:t("repairzones.repair_label"),
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                car = true,
                            },
                        })

                        if progress then
                            SetVehicleEngineHealth(cache.vehicle, 1000.0)
                            lib.notify({
                                description = Lang:t("repairzones.repair_done"),
                                type = 'success',
                            })
                            for i = 0, 4 do
                                SetVehicleTyreFixed(cache.vehicle, i)
                            end
                            SetVehicleFixed(cache.vehicle)
                        else
                            lib.notify({
                                description = Lang:t("repairzones.repair_cancelled"),
                                type = 'error',
                            })
                        end
                    else
                        lib.notify({
                            description = Lang:t("repairzones.repair_wronggroup"),
                            type = 'error',
                        })
                    end
                end
            end
        })
    end

end