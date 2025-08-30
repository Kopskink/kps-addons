Config = Config or {}

Config.Enable = {
    acommands = {
        fixw = true,
        setstat = true,
    },
    consumables = {
        nicotine_pouches = true,
        adrenaline_syringe = true,
    },
    forcepk = true,
    repairzones = true,
    peds = true,
    comms = {
        [310] = true,
        [311] = true,
        [312] = true,
    },
    endsuffering = true,
    handcuffs = true,
}

Config.HandcuffSettings = {
    escape_settings = {
        chance = 50,
        skillcheck = {
            {areaSize = 50, speedMultiplier = 0.9},
            'medium',
            {areaSize = 30, speedMultiplier = 1.7},
            {areaSize = 30, speedMultiplier = 1.5},
        },
    },
    wirecutter_settings = {
        skillcheck = {
            'medium',
            'medium',
            {areaSize = 30, speedMultiplier = 1.5},
            {areaSize = 30, speedMultiplier = 1.5},
            {areaSize = 10, speedMultiplier = 0.15},
        },
    },
}

Config.ForcePK = {
    debug = false,
    chance = 20, -- number ** chance to get sent instantly to the hospital after getting killed by the guns listed down below
    weapons = {
        [`WEAPON_PISTOL`] = true,
        [`WEAPON_COMBATPISTOL`] = true,
        [`WEAPON_HEAVYPISTOL`] = true,
        [`WEAPON_ASSAULTRIFLE`] = true,
        [`WEAPON_CARBINERIFLE`] = true,
        [`WEAPON_MACHINEPISTOL`] = true,
        [`WEAPON_VINTAGEPISTOL`] = true,
        [`WEAPON_SMG`] = true,
        [`WEAPON_MINISMG`] = true,
        [`WEAPON_PUMPSHOTGUN`] = true,
        [`WEAPON_APPISTOL`] = true,
        [`WEAPON_MICROSMG`] = true
    }
}

Config.ChatMessageColor = {
    [310] = {124, 173, 95}, -- (EMS & LSPD) green
    [311] = {191, 125, 67}, -- (LSPD) orange
    [312] = {227, 107, 107}, -- (EMS) pink
    ['error'] = {255, 0, 0}, -- red
}

Config.RepairZonesOverallSettings = {
    repair_button = 38, -- button number reference: https://docs.fivem.net/docs/game-references/controls/
    repair_time = 60000, -- milliseconds ** length of the repairing time
    textui = { -- reference: https://overextended.dev/ox_lib/Modules/Interface/Client/textui
        position = 'left-center',
        icon = 'fa-solid fa-wrench',
    }
}

Config.RepairZonesLocSettings = {
    ['MRPD'] = {
        groups = {'police', 'sheriff'},
        zone = { -- lib.zones.box info
            coords = vector3(450.95, -975.85, 26.0),
            size = vec3(10.0, 4.5, 5.0),
            rotation = 0,
            debug = false,
        },
    },
    ['PILLBOX'] = {
        groups = {'ambulance'},
        zone = {
            coords = vector3(294.18, -607.72, 43.33),
            size = vec3(10.0, 4.5, 5.0),
            rotation = 160.0,
            debug = false,
        },
    },
}