local Translations = {
    error = {
        ["already_mission"] = "You are already on a car stealing mission",
        ["no_vehicle"] = "No vehicle to steal",
        ["not_in_vehicle"] = "You are not in a vehicle",
        ["not_in_target_vehicle"] = "This is not the target vehicle",
        ["too_far"] = "You are too far from the vehicle",
        ["vehicle_locked"] = "Vehicle is locked",
        ["cooldown"] = "You need to wait before stealing another car",
        ["cancelled"] = "Mission cancelled",
    },
    success = {
        ["vehicle_delivered"] = "Vehicle delivered successfully",
        ["reward_received"] = "You received $%{value}",
    },
    info = {
        ["steal_vehicle"] = "Steal Vehicle",
        ["deliver_vehicle"] = "Deliver Vehicle",
        ["npc_coming_out"] = "The driver is coming out of the vehicle",
        ["npc_attackers"] = "Attackers are coming after you!",
        ["cooldown_time"] = "You need to wait %{value} minutes before stealing another car",
        ["delivery_blip"] = "Car Delivery Location",
        ["mission_started"] = "Car stealing mission started",
        ["mission_completed"] = "Car stealing mission completed",
    },
    progress = {
        ["stealing_vehicle"] = "Stealing vehicle...",
        ["hotwiring"] = "Hotwiring vehicle...",
        ["delivering_vehicle"] = "Delivering vehicle...",
    }
}

-- Fix for the error: use the proper QBCore import method
local QBCore = exports['qb-core']:GetCoreObject()
Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true,
    fallbackLang = Lang,
}) 