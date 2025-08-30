local QBCore = exports['qb-core']:GetCoreObject()

-- fix weapon
if Config.Enable.acommands.fixw then
    RegisterNetEvent('kps-addons:client:GetWeapon', function()
        local cweapon = exports.ox_inventory:getCurrentWeapon()
        if not cweapon then
            lib.notify({
                description = Lang:t("acommands.needguninhand"),
                type = 'error',
            })
        end
        if not cweapon.slot then return end

        local wslot = cweapon.slot
        TriggerServerEvent('kps-addons:server:FixSelectedW', wslot)
    end)
end

-- set player stat

if Config.Enable.acommands.setstat then
    RegisterNetEvent('kps-addons:client:setHP', function(amount)
        local ped = PlayerPedId()
        local hp = math.floor(amount + 100)
        SetEntityHealth(ped, hp)
    end)
end
