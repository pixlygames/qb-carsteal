# CarSteal

A comprehensive car stealing script for QBCore Framework that allows players to steal high-end vehicles and deliver them for rewards.

## Features

- Multiple car steal missions with different vehicles and locations
- Custom delivery locations for each mission
- NPC attackers that chase the player after stealing a car
- Reward system based on vehicle class
- Email and text notifications through qb-phone
- Cooldown system between missions
- PolyZone integration for interactive markers
- Configurable blips and waypoints
- Vehicle remains locked after delivery (not deleted)

## Dependencies

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [PolyZone](https://github.com/mkafrin/PolyZone)
- [qb-phone](https://github.com/qbcore-framework/qb-phone) (optional, for email notifications)

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure qb-carsteal` to your server.cfg
4. Configure the script to your liking in `config.lua`
5. Restart your server

## Configuration

The script is highly configurable through the `config.lua` file. Here's a breakdown of the main configuration sections:

### Debug Settings

```lua
Config.Debug = false -- Enable debug mode for development purposes
```

When set to `true`, this will show the PolyZones around vehicles for easier debugging.

### General Settings

```lua
Config.UseTarget = true -- Use qb-target for interactions (set to false to use DrawText)
Config.Cooldown = 30 -- Cooldown time in minutes before player can start another car stealing mission
Config.NPCExitDamageThreshold = 10 -- Percentage of vehicle damage that will cause NPC to exit the vehicle
Config.NPCAttackDelay = 10 -- Time in seconds before NPCs spawn and attack after stealing the car
```

- `UseTarget`: Set to `true` to use qb-target for interactions, or `false` to use the E key press system
- `Cooldown`: Time in minutes before a player can start another mission
- `NPCAttackDelay`: Delay in seconds before NPC attackers spawn after stealing a car

### Notification Settings

```lua
Config.UseEmailNotification = true -- Enable/disable email notifications
Config.UseTextNotification = true -- Enable/disable text notifications
Config.EmailContent = "Press TAB to see what you have in your pockets, lockpick is there - use it!"
```

- `UseEmailNotification`: Enable/disable email notifications through qb-phone
- `UseTextNotification`: Enable/disable text notifications
- `EmailContent`: The content of the email sent to the player

### Blip Settings

```lua
Config.BlipSprite = 326 -- Blip sprite for the delivery location
Config.BlipColor = 1 -- Blip color for the delivery location
Config.BlipScale = 0.8 -- Blip scale for the delivery location
Config.BlipText = "Car Delivery Location" -- Text for the delivery location blip
```

These settings control the appearance of the delivery location blip on the map.

### Reward Settings

```lua
Config.MinReward = 1000 -- Minimum reward for delivering a car
Config.MaxReward = 5000 -- Maximum reward for delivering a car
Config.RewardMultiplier = {
    ["A"] = 1.5, -- Multiplier for A class vehicles
    ["B"] = 1.2, -- Multiplier for B class vehicles
    ["C"] = 1.0, -- Multiplier for C class vehicles
    ["D"] = 0.8, -- Multiplier for D class vehicles
}
```

- `MinReward` and `MaxReward`: Define the range for the base reward
- `RewardMultiplier`: Multipliers based on the vehicle class

### Car Steal Missions

```lua
Config.CarStealMissions = {
    -- Mission 1: Default Car Steal
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
    -- Add more missions here...
}
```

This is where you define each car steal mission:
- `enabled`: Whether this mission is active
- `carModel`: The model of the car to spawn
- `carLocation`: Where the car spawns (x, y, z, heading)
- `deliveryLocation`: Where the player needs to deliver the car
- `blip`: Settings for the blip that appears on the map for the car
- `attackerGroup`: Which NPC attacker group to use (references the index in Config.NPCAttackerGroups)

### NPC Attacker Groups

```lua
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
    -- Add more attacker groups here...
}
```

This defines the NPC attackers that will chase the player:
- `spawnPoints`: Where the attackers spawn
- `weapons`: What weapons they can use
- `vehicles`: What vehicles they can drive

### Vehicle Classes

```lua
Config.VehicleClasses = {
    ["A"] = { -- High-end vehicles
        "adder", "autarch", "banshee2", /* ... */
    },
    ["B"] = { -- Mid-high vehicles
        "alpha", "banshee", "bestiagts", /* ... */
    },
    -- More classes...
}
```

This categorizes vehicles into classes, which affects the reward multiplier.

## How to Add New Missions

To add a new car steal mission, add a new entry to the `Config.CarStealMissions` table:

```lua
[4] = {
    enabled = true,
    carModel = "zentorno",
    carLocation = vector4(123.45, 678.90, 25.0, 180.0),
    deliveryLocation = vector4(987.65, 432.10, 30.0, 90.0),
    blip = {
        sprite = 225,
        color = 1,
        scale = 0.8,
        text = "Steal Zentorno"
    },
    attackerGroup = 2 -- Use attacker group 2
},
```

## How to Add New Attacker Groups

To add a new attacker group, add a new entry to the `Config.NPCAttackerGroups` table:

```lua
[4] = {
    spawnPoints = {
        vector4(100.0, 200.0, 30.0, 0.0),
        vector4(110.0, 200.0, 30.0, 0.0),
        vector4(120.0, 200.0, 30.0, 0.0),
    },
    weapons = {
        "WEAPON_PISTOL50",
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_SAWNOFFSHOTGUN",
    },
    vehicles = {
        "baller",
        "granger",
        "dubsta",
    },
},
```

## Player Experience

1. Players will see blips on the map for available car steal missions
2. When approaching a car, a marker will appear and they can press E to start the mission
3. After starting the mission, they'll receive a notification and an email with instructions
4. They need to lockpick the car and drive it to the delivery location
5. NPC attackers will chase them after a short delay
6. At the delivery location, they need to stop the car and exit the vehicle
7. Once they walk away from the vehicle (at least 2 meters), the mission completes automatically
8. The car remains locked at the delivery location (not deleted)
9. A cooldown period begins before they can start another mission


## License

This resource is licensed under the MIT License. See the LICENSE file for details.

## Credits

- Created by Pixly Games