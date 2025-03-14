local QBCore = exports['qb-core']:GetCoreObject()

-- Player cooldowns (stored by citizenid)
local playerCooldowns = {}

-- Event handler for giving reward to player
RegisterNetEvent('qb-carsteal:server:GiveReward', function(reward)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Add money to player
    Player.Functions.AddMoney('cash', reward, 'car-steal-mission-reward')
    
    -- Send notification to player
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.reward_received', {value = reward}), 'success')
    
    -- Set cooldown for player
    local citizenid = Player.PlayerData.citizenid
    playerCooldowns[citizenid] = Config.Cooldown * 60 -- Convert minutes to seconds
    
    -- Start cooldown timer
    StartCooldownTimer(citizenid)
end)

-- Event handler for getting player cooldown
RegisterNetEvent('qb-carsteal:server:GetCooldown', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local cooldown = playerCooldowns[citizenid] or 0
    
    TriggerClientEvent('qb-carsteal:client:SetCooldown', src, cooldown)
end)

-- Event handler for setting player cooldown
RegisterNetEvent('qb-carsteal:server:SetCooldown', function(cooldown)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    playerCooldowns[citizenid] = cooldown
end)

-- Function to start cooldown timer for player
function StartCooldownTimer(citizenid)
    CreateThread(function()
        while playerCooldowns[citizenid] and playerCooldowns[citizenid] > 0 do
            Wait(1000)
            playerCooldowns[citizenid] = playerCooldowns[citizenid] - 1
            
            if playerCooldowns[citizenid] <= 0 then
                playerCooldowns[citizenid] = nil
            end
        end
    end)
end

-- Command to reset cooldown (for admins)
QBCore.Commands.Add('resetcarstealcooldown', 'Reset car stealing cooldown (Admin Only)', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Player.PlayerData.job.name == 'police' and Player.PlayerData.job.grade.level >= 4 or QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god') then
        local citizenid = Player.PlayerData.citizenid
        playerCooldowns[citizenid] = nil
        TriggerClientEvent('qb-carsteal:client:SetCooldown', src, 0)
        TriggerClientEvent('QBCore:Notify', src, 'Car stealing cooldown reset', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command', 'error')
    end
end)

-- Save cooldowns when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Could save cooldowns to database here if needed
end)

-- Load cooldowns when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Could load cooldowns from database here if needed
end) 