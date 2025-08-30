local QBCore = exports['qb-core']:GetCoreObject()

if Config.Enable.forcepk then
    local wasDead = false

    CreateThread(function()
        while true do
            Wait(500)
            local ped = PlayerPedId()
            if IsEntityDead(ped) and not wasDead then
                wasDead = true

                local killer = GetPedSourceOfDeath(ped)
                local weapon = GetPedCauseOfDeath(ped)

                TriggerServerEvent('kps-addons:server:onGunDeath', killer, weapon)
            elseif not IsEntityDead(ped) and wasDead then
                wasDead = false
            end
        end
    end)

    RegisterNetEvent('kps-addons:client:sendToHospital', function(playerId)
        Wait(7000)
        TriggerEvent('hospital:client:RespawnAtHospital')
    end)
end