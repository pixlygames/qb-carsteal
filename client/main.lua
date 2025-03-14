local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentMission = nil
local missionVehicle = nil
local missionBlip = nil
local deliveryBlip = nil
local npcDriver = nil
local npcAttackers = {}
local cooldownTime = 0
local isOnCooldown = false
local carStealVehicles = {}
local carStealBlips = {}
local carStealZones = {}
local isNearVehicle = false
local currentNearVehicle = nil

-- Function to create a blip
local function CreateMissionBlip(coords, sprite, color, text, scale)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Function to create a waypoint
local function SetWaypoint(coords)
    SetNewWaypoint(coords.x, coords.y)
end

-- Function to spawn NPC attackers
local function SpawnNPCAttackers(attackerGroup, targetVehicle)
    local attackers = {}
    local attackerVehicles = {}
    
    for i, spawnPoint in ipairs(attackerGroup.spawnPoints) do
        -- Select a random vehicle from the attacker group's vehicle list
        local vehicleModel = attackerGroup.vehicles[math.random(#attackerGroup.vehicles)]
        
        -- Request the vehicle model
        local modelHash = GetHashKey(vehicleModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(0)
        end
        
        -- Spawn the vehicle
        local vehicle = CreateVehicle(modelHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
        table.insert(attackerVehicles, vehicle)
        
        -- Create attackers
        local pedModels = {
            'g_m_y_lost_01',
            'g_m_y_lost_02',
            'g_m_y_lost_03',
            'g_m_y_mexgoon_01',
            'g_m_y_mexgoon_02',
            'g_m_y_mexgoon_03'
        }
        
        for seat = -1, 2 do
            local pedModel = GetHashKey(pedModels[math.random(#pedModels)])
            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do
                Wait(0)
            end
            
            local ped = CreatePedInsideVehicle(vehicle, 26, pedModel, seat, true, false)
            
            -- Set ped properties
            SetPedRelationshipGroupHash(ped, GetHashKey('HATES_PLAYER'))
            SetPedCombatAttributes(ped, 46, true)
            SetPedCombatAttributes(ped, 5, true)
            SetPedCombatAttributes(ped, 0, true)
            SetPedCombatRange(ped, 2)
            SetPedCombatMovement(ped, 3)
            
            -- Give weapon
            local weapon = attackerGroup.weapons[math.random(#attackerGroup.weapons)]
            GiveWeaponToPed(ped, GetHashKey(weapon), 250, false, true)
            SetCurrentPedWeapon(ped, GetHashKey(weapon), true)
            
            table.insert(attackers, ped)
            
            -- Release the model
            SetModelAsNoLongerNeeded(pedModel)
        end
        
        -- Set vehicle properties
        SetVehicleEngineOn(vehicle, true, true, false)
        
        -- Release the model
        SetModelAsNoLongerNeeded(modelHash)
    end
    
    -- Make attackers attack the player
    local playerPed = PlayerPedId()
    for _, attacker in ipairs(attackers) do
        TaskCombatPed(attacker, playerPed, 0, 16)
    end
    
    -- Make driver follow the player's vehicle
    for i, vehicle in ipairs(attackerVehicles) do
        local driver = GetPedInVehicleSeat(vehicle, -1)
        if DoesEntityExist(driver) then
            TaskVehicleChase(driver, playerPed)
            SetTaskVehicleChaseBehaviorFlag(driver, 1, true)
            SetDriverAggressiveness(driver, 1.0)
            SetDriverAbility(driver, 1.0)
        end
    end
    
    return attackers, attackerVehicles
end

-- Initialize player data when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('qb-carsteal:server:GetCooldown')
    
    -- Spawn the default car when player loads
    SpawnCarStealVehicles()
end)

-- Update player data when job changes
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Get cooldown from server
RegisterNetEvent('qb-carsteal:client:SetCooldown', function(serverCooldown)
    cooldownTime = serverCooldown
    isOnCooldown = cooldownTime > 0
    
    if isOnCooldown then
        local remainingMinutes = math.ceil(cooldownTime / 60)
        QBCore.Functions.Notify(Lang:t('info.cooldown_time', {value = remainingMinutes}), 'primary', 5000)
    end
end)

-- Function to spawn all car steal vehicles
function SpawnCarStealVehicles()
    -- Clean up existing vehicles
    for i, vehicle in pairs(carStealVehicles) do
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
    
    -- Clean up existing blips
    for i, blip in pairs(carStealBlips) do
        RemoveBlip(blip)
    end
    
    -- Clean up existing zones
    for i, zone in pairs(carStealZones) do
        zone:destroy()
    end
    
    carStealVehicles = {}
    carStealBlips = {}
    carStealZones = {}
    
    -- Spawn each car steal mission vehicle
    for i, missionConfig in pairs(Config.CarStealMissions) do
        if missionConfig.enabled then
            -- Request the vehicle model
            local modelHash = GetHashKey(missionConfig.carModel)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(0)
            end
            
            -- Spawn the vehicle
            local vehicle = CreateVehicle(modelHash, missionConfig.carLocation.x, missionConfig.carLocation.y, missionConfig.carLocation.z, missionConfig.carLocation.w, true, false)
            
            -- Set vehicle properties
            SetVehicleDoorsLocked(vehicle, 2) -- Lock the vehicle
            SetVehicleEngineOn(vehicle, false, false, true)
            SetVehicleDirtLevel(vehicle, math.random(0, 15)) -- Random dirt level
            
            -- Create a blip for the vehicle
            local blip = AddBlipForCoord(missionConfig.carLocation.x, missionConfig.carLocation.y, missionConfig.carLocation.z)
            SetBlipSprite(blip, missionConfig.blip.sprite)
            SetBlipColour(blip, missionConfig.blip.color)
            SetBlipScale(blip, missionConfig.blip.scale)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(missionConfig.blip.text)
            EndTextCommandSetBlipName(blip)
            
            -- Store the vehicle and blip
            carStealVehicles[i] = vehicle
            carStealBlips[i] = blip
            
            -- Create polyzone for the vehicle
            local coords = vector3(missionConfig.carLocation.x, missionConfig.carLocation.y, missionConfig.carLocation.z)
            local carZone = CircleZone:Create(coords, 3.0, {
                name = "car_steal_zone_" .. i,
                debugPoly = Config.Debug
            })
            
            carZone:onPlayerInOut(function(isPointInside)
                if isPointInside and not currentMission and not isOnCooldown then
                    isNearVehicle = true
                    currentNearVehicle = vehicle
                else
                    if currentNearVehicle == vehicle then
                        isNearVehicle = false
                        currentNearVehicle = nil
                    end
                end
            end)
            
            table.insert(carStealZones, carZone)
            
            -- Release the model
            SetModelAsNoLongerNeeded(modelHash)
        end
    end
end

-- Function to start a car steal mission
function StartCarStealMission(vehicle)
    if currentMission or isOnCooldown then
        QBCore.Functions.Notify(isOnCooldown and Lang:t('error.cooldown') or Lang:t('error.already_mission'), 'error')
        return
    end
    
    if not vehicle or not DoesEntityExist(vehicle) then
        QBCore.Functions.Notify(Lang:t('error.no_vehicle'), 'error')
        return
    end
    
    -- Find which car steal mission this is
    local missionIndex = nil
    local missionConfig = nil
    
    for i, v in pairs(carStealVehicles) do
        if v == vehicle then
            missionIndex = i
            missionConfig = Config.CarStealMissions[i]
            break
        end
    end
    
    if not missionIndex or not missionConfig then
        QBCore.Functions.Notify(Lang:t('error.no_vehicle'), 'error')
        return
    end
    
    -- Remove the blip
    if carStealBlips[missionIndex] then
        RemoveBlip(carStealBlips[missionIndex])
        carStealBlips[missionIndex] = nil
    end
    
    -- Remove any existing delivery blip
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    -- Set up the mission
    currentMission = {
        type = "car_steal",
        vehicle = vehicle,
        vehicleModel = missionConfig.carModel,
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle),
        deliveryLocation = {
            coords = missionConfig.deliveryLocation
        },
        missionIndex = missionIndex,
        attackerGroup = missionConfig.attackerGroup
    }
    
    missionVehicle = vehicle
    
    -- Create a blip for the delivery location
    deliveryBlip = CreateMissionBlip(
        vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z),
        Config.BlipSprite,
        Config.BlipColor,
        Config.BlipText,
        Config.BlipScale
    )
    
    -- Set waypoint to delivery location
    SetWaypoint(vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z))
    
    -- Send notification
    QBCore.Functions.Notify(Lang:t('info.mission_started'), 'primary', 30000)
    
    -- Send email notification if enabled
    if Config.UseEmailNotification then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = "Unknown",
            subject = "Car Theft Job",
            message = Config.EmailContent,
            button = {}
        })
    end
    
    -- Send text notification if enabled
    if Config.UseTextNotification then
        QBCore.Functions.Notify("Press M to use phone and read email for information.", "primary", 30000)
    end
    
    -- Spawn NPC attackers after delay
    if Config.NPCAttackDelay > 0 then
        CreateThread(function()
            Wait(Config.NPCAttackDelay * 1000)
            
            if currentMission and currentMission.vehicle then
                -- Get the attacker group
                local attackerGroup = Config.NPCAttackerGroups[currentMission.attackerGroup]
                
                if attackerGroup then
                    -- Spawn the attackers
                    local attackers, vehicles = SpawnNPCAttackers(attackerGroup, currentMission.vehicle)
                    npcAttackers = attackers
                    
                    QBCore.Functions.Notify(Lang:t('info.npc_attackers'), 'error')
                end
            end
        end)
    end
end

-- Function to start cooldown timer
local function StartCooldown()
    isOnCooldown = true
    cooldownTime = Config.Cooldown * 60 -- Convert minutes to seconds
    TriggerServerEvent('qb-carsteal:server:SetCooldown', cooldownTime)
    
    CreateThread(function()
        while cooldownTime > 0 do
            Wait(1000)
            cooldownTime = cooldownTime - 1
            if cooldownTime <= 0 then
                isOnCooldown = false
                TriggerServerEvent('qb-carsteal:server:SetCooldown', 0)
                -- Respawn the default car when cooldown ends
                SpawnCarStealVehicles()
            end
        end
    end)
end

-- Function to check vehicle class
local function GetVehicleClass(vehicleModel)
    local model = GetHashKey(vehicleModel)
    
    for class, vehicles in pairs(Config.VehicleClasses) do
        for _, vehicle in ipairs(vehicles) do
            if GetHashKey(vehicle) == model then
                return class
            end
        end
    end
    
    return "D" -- Default to lowest class if not found
end

-- Function to calculate reward based on vehicle class
local function CalculateReward(vehicleModel)
    local vehicleClass = GetVehicleClass(vehicleModel)
    local baseReward = math.random(Config.MinReward, Config.MaxReward)
    local multiplier = Config.RewardMultiplier[vehicleClass] or 1.0
    
    return math.floor(baseReward * multiplier)
end

-- Function to clean up mission
local function CleanupMission()
    -- Remove blips
    if missionBlip then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end
    
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    -- Delete NPC driver if exists
    if npcDriver and DoesEntityExist(npcDriver) then
        DeleteEntity(npcDriver)
        npcDriver = nil
    end
    
    -- Delete NPC attackers if exist
    for _, attacker in ipairs(npcAttackers) do
        if DoesEntityExist(attacker) then
            DeleteEntity(attacker)
        end
    end
    npcAttackers = {}
    
    -- Reset mission variables
    currentMission = nil
    missionVehicle = nil
end

-- Function to set up delivery location
local function SetupDeliveryLocation()
    -- If the mission already has a delivery location, don't set it up again
    if currentMission and currentMission.deliveryLocation then
        -- If there's no delivery blip, create one
        if not deliveryBlip then
            local missionConfig = Config.CarStealMissions[currentMission.missionIndex]
            
            if not missionConfig then
                -- Fallback to first mission if not found
                missionConfig = Config.CarStealMissions[1]
            end
            
            -- Create a blip for the delivery location
            deliveryBlip = CreateMissionBlip(
                vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z),
                Config.BlipSprite,
                Config.BlipColor,
                Config.BlipText,
                Config.BlipScale
            )
            
            -- Set waypoint to delivery location
            SetWaypoint(vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z))
        end
        
        return
    end
    
    -- Get the mission config
    local missionConfig = Config.CarStealMissions[currentMission.missionIndex]
    
    if not missionConfig then
        -- Fallback to first mission if not found
        missionConfig = Config.CarStealMissions[1]
    end
    
    -- Remove any existing delivery blip
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    -- Create a blip for the delivery location
    deliveryBlip = CreateMissionBlip(
        vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z),
        Config.BlipSprite,
        Config.BlipColor,
        Config.BlipText,
        Config.BlipScale
    )
    
    -- Set waypoint to delivery location
    SetWaypoint(vector3(missionConfig.deliveryLocation.x, missionConfig.deliveryLocation.y, missionConfig.deliveryLocation.z))
    
    -- Update mission with delivery location
    currentMission.deliveryLocation = {
        coords = missionConfig.deliveryLocation
    }
    
    -- Spawn NPC attackers after delay
    if Config.NPCAttackDelay > 0 then
        CreateThread(function()
            Wait(Config.NPCAttackDelay * 1000)
            
            if currentMission and currentMission.vehicle then
                -- Get the attacker group
                local attackerGroup = Config.NPCAttackerGroups[currentMission.attackerGroup]
                
                if attackerGroup then
                    -- Spawn the attackers
                    local attackers, vehicles = SpawnNPCAttackers(attackerGroup, currentMission.vehicle)
                    npcAttackers = attackers
                    
                    QBCore.Functions.Notify(Lang:t('info.npc_attackers'), 'error')
                end
            end
        end)
    end
end

-- Function to complete the mission
local function CompleteMission()
    if not currentMission or not currentMission.vehicle then
        return
    end
    
    -- Calculate reward
    local reward = CalculateReward(currentMission.vehicleModel)
    
    -- Send event to server to give reward
    TriggerServerEvent('qb-carsteal:server:GiveReward', reward)
    
    -- Lock the vehicle but don't delete it
    if DoesEntityExist(currentMission.vehicle) then
        SetVehicleDoorsLocked(currentMission.vehicle, 2) -- Lock the vehicle
    end
    
    -- Clean up mission
    CleanupMission()
    
    -- Start cooldown
    StartCooldown()
    
    QBCore.Functions.Notify(Lang:t('info.mission_completed'), 'success')
    
    -- Respawn cars after cooldown
    Wait(Config.Cooldown * 60 * 1000)
    SpawnCarStealVehicles()
end

-- Function to cancel the mission
local function CancelMission()
    if not currentMission then
        return
    end
    
    -- Clean up mission
    CleanupMission()
    
    -- Respawn the default car if it was the default mission
    SpawnCarStealVehicles()
    
    QBCore.Functions.Notify(Lang:t('error.cancelled'), 'error')
end

-- Event handler for when player enters vehicle
RegisterNetEvent('qb-carsteal:client:EnteredVehicle', function(vehicle)
    if not currentMission or not currentMission.vehicle or vehicle ~= currentMission.vehicle then
        return
    end
    
    -- Remove the mission blip
    if missionBlip then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end
    
    -- Set up delivery location
    SetupDeliveryLocation()
end)

-- Thread to check if player is in the mission vehicle
CreateThread(function()
    while true do
        Wait(1000)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle ~= 0 and currentMission and currentMission.vehicle and vehicle == currentMission.vehicle then
            if not currentMission.playerEntered then
                currentMission.playerEntered = true
                TriggerEvent('qb-carsteal:client:EnteredVehicle', vehicle)
            end
        end
    end
end)

-- Thread to handle E key press for stealing vehicles
CreateThread(function()
    while true do
        Wait(0)
        
        if isNearVehicle and currentNearVehicle and not currentMission and not isOnCooldown then
            -- Draw marker
            local coords = GetEntityCoords(currentNearVehicle)
            DrawMarker(2, coords.x, coords.y, coords.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, nil, nil, false)
            
            -- Draw text
            QBCore.Functions.DrawText3D(coords.x, coords.y, coords.z + 1.0, "Press [E] to steal vehicle")
            
            -- Check for E key press
            if IsControlJustReleased(0, 38) then -- E key
                StartCarStealMission(currentNearVehicle)
            end
        end
    end
end)

-- Thread to handle delivery zone
CreateThread(function()
    while true do
        Wait(0)
        
        if currentMission and currentMission.deliveryLocation then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local deliveryCoords = vector3(
                currentMission.deliveryLocation.coords.x,
                currentMission.deliveryLocation.coords.y,
                currentMission.deliveryLocation.coords.z
            )
            
            local distance = #(playerCoords - deliveryCoords)
            
            if distance < 50.0 then
                DrawMarker(1, deliveryCoords.x, deliveryCoords.y, deliveryCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 165, 0, 100, false, true, 2, false, nil, nil, false)
                
                if distance < 5.0 then
                    -- Check if player is in the mission vehicle
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    
                    if vehicle == currentMission.vehicle then
                        -- Player is in the mission vehicle at the delivery point
                        QBCore.Functions.DrawText3D(deliveryCoords.x, deliveryCoords.y, deliveryCoords.z, "Stop the car here and leave")
                        
                        -- Check if vehicle is stopped
                        local speed = GetEntitySpeed(vehicle)
                        if speed < 0.1 then
                            -- Vehicle is stopped, set a flag to check when player leaves
                            if not currentMission.vehicleStopped then
                                currentMission.vehicleStopped = true
                                currentMission.stoppedCoords = GetEntityCoords(vehicle)
                            end
                        end
                    elseif currentMission.vehicleStopped then
                        -- Player has exited the vehicle, check if the vehicle is still at the delivery point
                        local vehicleCoords = GetEntityCoords(currentMission.vehicle)
                        local vehicleDistance = #(vehicleCoords - currentMission.stoppedCoords)
                        
                        -- Check if vehicle hasn't moved and player is away from it
                        if vehicleDistance < 3.0 and distance > 2.0 then
                            -- Complete the mission
                            CompleteMission()
                        end
                    end
                end
            end
        end
    end
end)

-- Add target interactions if Config.UseTarget is true
if Config.UseTarget then
    -- Add target for car steal vehicles
    local carModels = {}
    for _, mission in pairs(Config.CarStealMissions) do
        if mission.enabled then
            table.insert(carModels, mission.carModel)
        end
    end
    
    exports['qb-target']:AddTargetModel(carModels, {
        options = {
            {
                type = "client",
                event = "qb-carsteal:client:StartMission",
                icon = "fas fa-car",
                label = Lang:t('info.steal_vehicle'),
                canInteract = function(entity)
                    if not IsEntityAVehicle(entity) then return false end
                    if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
                    if currentMission then return false end
                    if isOnCooldown then return false end
                    
                    -- Check if it's one of our car steal vehicles
                    for i, vehicle in pairs(carStealVehicles) do
                        if entity == vehicle then
                            return true
                        end
                    end
                    
                    return false
                end,
            }
        },
        distance = 2.5,
    })
end

-- Event handler for starting a mission
RegisterNetEvent('qb-carsteal:client:StartMission', function()
    if currentNearVehicle then
        StartCarStealMission(currentNearVehicle)
    end
end)

-- Event handler for starting the default mission
RegisterNetEvent('qb-carsteal:client:StartDefaultMission', function()
    -- Find the first mission vehicle (which is the default one)
    local defaultVehicle = carStealVehicles[1]
    if defaultVehicle and DoesEntityExist(defaultVehicle) then
        StartCarStealMission(defaultVehicle)
    end
end)

-- Event handler for cancelling a mission
RegisterNetEvent('qb-carsteal:client:CancelMission', function()
    CancelMission()
end)

-- Command to cancel a mission (for testing)
RegisterCommand('cancelcarsteal', function()
    CancelMission()
end, false)

-- Initialize the script when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Spawn the default car when resource starts
    Wait(1000) -- Wait a bit to ensure everything is loaded
    SpawnCarStealVehicles()
end) 