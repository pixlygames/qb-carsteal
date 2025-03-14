Config = {}

-- Debug Settings
Config.Debug = false -- Enable debug mode for development purposes

-- General Settings
Config.UseTarget = true -- Use qb-target for interactions (set to false to use DrawText)
Config.Cooldown = 90 -- Cooldown time in minutes before player can start another car stealing mission
Config.NPCExitDamageThreshold = 10 -- Percentage of vehicle damage that will cause NPC to exit the vehicle
Config.NPCAttackDelay = 10 -- Time in seconds before NPCs spawn and attack after stealing the car

-- Notification Settings
Config.UseEmailNotification = true -- Enable/disable email notifications
Config.UseTextNotification = true -- Enable/disable text notifications
Config.EmailContent = "Press TAB to see what you have in your pockets, lockpick is there - use it!"

-- Blip Settings
Config.BlipSprite = 326 -- Blip sprite for the delivery location
Config.BlipColor = 1 -- Blip color for the delivery location
Config.BlipScale = 0.8 -- Blip scale for the delivery location
Config.BlipText = "Car Delivery Location" -- Text for the delivery location blip

-- Reward Settings
Config.MinReward = 1000 -- Minimum reward for delivering a car
Config.MaxReward = 5000 -- Maximum reward for delivering a car
Config.RewardMultiplier = {
    ["A"] = 1.5, -- Multiplier for A class vehicles
    ["B"] = 1.2, -- Multiplier for B class vehicles
    ["C"] = 1.0, -- Multiplier for C class vehicles
    ["D"] = 0.8, -- Multiplier for D class vehicles
}

-- Car Steal Missions
Config.CarStealMissions = {
    -- Mission 1: Turismo R
    [1] = {
        enabled = true,
        carModel = "turismor",
        carLocation = vector4(-1026.19, -2728.12, 12.81, 240.21),
        deliveryLocation = vector4(534.12, -169.26, 54.69, 0.55),
        blip = {
            sprite = 225,
            color = 1,
            scale = 0.8,
            text = "Steal Turismo R"
        },
        attackerGroup = 1 -- Index of the attacker group to use
    },
    
    -- Mission 2: Infernus
    [2] = {
        enabled = true,
        carModel = "infernus",
        carLocation = vector4(-675.92, 903.37, 230.58, 327.88),
        deliveryLocation = vector4(1261.26, -2563.96, 42.72, 111.83),
        blip = {
            sprite = 225,
            color = 1,
            scale = 0.8,
            text = "Steal Infernus"
        },
        attackerGroup = 2
    },
    
    -- Mission 3: Tyrus
    [3] = {
        enabled = true,
        carModel = "tyrus",
        carLocation = vector4(-974.62, -1104.33, 2.15, 288.46),
        deliveryLocation = vector4(1737.43, 3687.96, 34.33, 12.99),
        blip = {
            sprite = 225,
            color = 1,
            scale = 0.8,
            text = "Steal Tyrus"
        },
        attackerGroup = 3
    }
}

-- NPC Attacker Groups
Config.NPCAttackerGroups = {
    [1] = {
        spawnPoints = {
            vector4(228.76, -1037.96, 29.17, 352.14),
            vector4(238.76, -1037.96, 29.17, 352.14),
            vector4(218.76, -1037.96, 29.17, 352.14),
        },
        weapons = {
            "WEAPON_PISTOL",
            "WEAPON_SMG",
            "WEAPON_PUMPSHOTGUN",
        },
        vehicles = {
            "kuruma",
            "sultan",
            "schafter3",
        },
    },
    [2] = {
        spawnPoints = {
            vector4(-529.14, 258.23, 83.07, 49.9),
            vector4(-529.14, 258.23, 83.07, 49.9),
            vector4(-529.14, 258.23, 83.07, 49.9),
        },
        weapons = {
            "WEAPON_PISTOL",
            "WEAPON_SMG",
            "WEAPON_PUMPSHOTGUN",
        },
        vehicles = {
            "kuruma",
            "sultan",
            "schafter3",
        },
    },
    [3] = {
        spawnPoints = {
            vector4(-186.84, -884.83, 29.4, 260.74),
            vector4(-186.84, -884.83, 29.4, 260.74),
            vector4(-186.84, -884.83, 29.4, 260.74),
        },
        weapons = {
            "WEAPON_PISTOL",
            "WEAPON_SMG",
            "WEAPON_PUMPSHOTGUN",
        },
        vehicles = {
            "kuruma",
            "sultan",
            "schafter3",
        },
    },
}

-- Vehicle Classes (used for reward calculation)
Config.VehicleClasses = {
    ["A"] = { -- High-end vehicles
        "adder",
        "autarch",
        "banshee2",
        "bullet",
        "cheetah",
        "entityxf",
        "fmj",
        "infernus",
        "nero",
        "osiris",
        "pfister811",
        "prototipo",
        "reaper",
        "sc1",
        "t20",
        "tempesta",
        "turismor",
        "tyrus",
        "vacca",
        "visione",
        "voltic",
        "zentorno",
    },
    ["B"] = { -- Mid-high vehicles
        "alpha",
        "banshee",
        "bestiagts",
        "carbonizzare",
        "comet2",
        "comet3",
        "coquette",
        "elegy",
        "elegy2",
        "feltzer2",
        "furoregt",
        "jester",
        "kuruma",
        "lynx",
        "massacro",
        "neon",
        "ninef",
        "ninef2",
        "rapidgt",
        "rapidgt2",
        "schafter3",
        "seven70",
        "verlierer2",
    },
    ["C"] = { -- Mid-range vehicles
        "blista2",
        "buffalo",
        "buffalo2",
        "dominator",
        "exemplar",
        "felon",
        "felon2",
        "fugitive",
        "fusilade",
        "futo",
        "jackal",
        "oracle",
        "oracle2",
        "phoenix",
        "premier",
        "schafter2",
        "sentinel",
        "sentinel2",
        "sultan",
        "surano",
        "tampa",
        "zion",
        "zion2",
    },
    ["D"] = { -- Low-end vehicles
        "asea",
        "asterope",
        "blista",
        "dilettante",
        "emperor",
        "emperor2",
        "ingot",
        "intruder",
        "minivan",
        "premier",
        "primo",
        "primo2",
        "regina",
        "rhapsody",
        "stanier",
        "stratum",
        "surge",
        "warrener",
        "washington",
    },
}