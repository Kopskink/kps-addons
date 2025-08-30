if Config.Enable.forcepk then
    RegisterNetEvent('kps-addons:server:onGunDeath', function(killerId, weaponHash)
        local src = source

        if not weaponHash or weaponHash == 0 then
            print(Lang:t("forcepk.no_weapon"))
            return
        end

        if IsWeaponAGun(weaponHash) then
            local chance = math.random(1, 100)

            if Config.ForcePK.debug then
                print(Lang:t("forcepk.gun_death_roll", { id = src, roll = chance }))
            end

            if chance <= Config.ForcePK.chance then
                if Config.ForcePK.debug then
                    print(Lang:t("forcepk.gun_death_send", { id = src }))
                end
                TriggerClientEvent('kps-addons:client:sendToHospital', src)
            else
                if Config.ForcePK.debug then
                    print(Lang:t("forcepk.gun_death_skip", { id = src }))
                end
            end
        else
            if Config.ForcePK.debug then
                print(Lang:t("forcepk.non_gun_death", { id = src }))
            end
        end
    end)

    function IsWeaponAGun(weaponHash)
        return Config.ForcePK.weapons[weaponHash] or false
    end    
end