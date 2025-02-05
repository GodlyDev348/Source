local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local masterUserId = 7321421842 -- Replace with the master account's UserID
local Prefix = "." -- Command prefix
local orbiting = false
local hovering = false
local flinging = false
local smitePlayer = nil
local originalPosition = nil -- To store the original position of the alt player
local smiteConnection = nil
local orbitConnection = nil
local hoverConnection = nil

local chatCooldown = 2 -- Cooldown in seconds for spam messages
local spamming = false
local spamConnection

-- Function to find a player by partial or full name
local function findPlayerByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(player.Name), 1, #name) == string.lower(name) or
           string.sub(string.lower(player.DisplayName), 1, #name) == string.lower(name) then
            return player
        end
    end
    return nil
end

-- Function to teleport the alt player to the target
local function teleportAltToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local altHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and altHRP then
            altHRP.CFrame = targetHRP.CFrame
        end
    end
end

local function getMasterPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.UserId == masterUserId then
            return player
        end
    end
    return nil
end

-- Function to teleport the alt to the master
local function teleportAltToMaster()
    local masterPlayer = getMasterPlayer()
    if masterPlayer and masterPlayer.Character then
        local masterHRP = masterPlayer.Character:FindFirstChild("HumanoidRootPart")
        local altHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if masterHRP and altHRP then
            altHRP.CFrame = masterHRP.CFrame
        end
    end
end

-- Function to handle alt's respawn
local function handleAltRespawn()
    localPlayer.CharacterAdded:Connect(function(newCharacter)
        newCharacter:WaitForChild("HumanoidRootPart") -- Wait for the alt's HumanoidRootPart to load
        teleportAltToMaster() -- Teleport the alt to the master once it respawns
    end)
end

-- Connect to the alt's current character death
local function monitorAltDeath()
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                teleportAltToMaster() -- Teleport to the master upon death
            end)
        end
    end
end

-- Initialize monitoring of the alt's death and respawn
if localPlayer.Character then
    monitorAltDeath() -- Monitor death for the current character
end

handleAltRespawn()

local function resetAlt()
    if localPlayer.Character then
        localPlayer.Character:BreakJoints() -- Break all joints in the character model
    else
        warn("Character not found! Alt cannot be reset.")
    end
end

-- Function to start the smite (fling)
local function smite(targetPlayer)
    flinging = true
    smitePlayer = targetPlayer
    if smitePlayer and smitePlayer.Character then
        local targetHRP = smitePlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            if smiteConnection then
                smiteConnection:Disconnect()
            end

            -- Store original position for reset
            originalPosition = localPlayer.Character and localPlayer.Character.HumanoidRootPart.CFrame

            smiteConnection = RunService.Heartbeat:Connect(function()
                if flinging and smitePlayer and smitePlayer.Character then
                    teleportAltToPlayer(smitePlayer)  -- Continuously teleport the alt to the target
                    local targetHRP = smitePlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        targetHRP.Velocity = Vector3.new(0, 10000, 0) -- Apply upward fling velocity
                    end
                end
            end)
        end
    end
end

-- Function to stop the smite and reset the alt
local function stopSmite()
    flinging = false
    if smiteConnection then
        smiteConnection:Disconnect()
        smiteConnection = nil
    end

    -- Teleport alt back to original position if available
    if originalPosition and localPlayer.Character then
        localPlayer.Character.HumanoidRootPart.CFrame = originalPosition
    end
end

-- Function to start orbiting a target player
local function startOrbit(targetPlayer, axis, distance, speed)
    orbiting = true
    local orbitAxis = string.lower(axis)
    local orbitDistance = tonumber(distance) or 10
    local orbitSpeed = tonumber(speed) or 1

    if not (orbitAxis == "x" or orbitAxis == "y" or orbitAxis == "z") then
        warn("Invalid axis specified. Use 'x', 'y', or 'z'.")
        return
    end

    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local altHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

        if targetHRP and altHRP then
            if orbitConnection then
                orbitConnection:Disconnect()
            end

            orbitConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if orbiting and targetHRP and altHRP then
                    local time = tick() * orbitSpeed
                    local offset

                    if orbitAxis == "x" then
                        offset = Vector3.new(math.cos(time) * orbitDistance, 0, math.sin(time) * orbitDistance)
                    elseif orbitAxis == "y" then
                        offset = Vector3.new(math.cos(time) * orbitDistance, math.sin(time) * orbitDistance, 0)
                    elseif orbitAxis == "z" then
                        offset = Vector3.new(0, math.sin(time) * orbitDistance, math.cos(time) * orbitDistance)
                    end

                    altHRP.CFrame = CFrame.new(targetHRP.Position + offset)
                end
            end)
        end
    end
end

-- Function to stop orbiting
local function stopOrbit()
    orbiting = false
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

local function bang(targetName)
    local targetPlayer = findPlayerByName(targetName)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local altHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and altHRP then
            -- Create and play the bang animation
            local bangAnim = Instance.new("Animation")
            if not r15(localPlayer) then
                bangAnim.AnimationId = "rbxassetid://148840371" -- Non-R15 animation
            else
                bangAnim.AnimationId = "rbxassetid://5918726674" -- R15 animation
            end
            local bang = localPlayer.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(bangAnim)
            bang:Play(0.1, 1, 1)

            -- Adjust the speed if specified (optional)
            bang:AdjustSpeed(3) -- Default speed

            -- Move alt player to target and apply velocity
            local bangOffet = CFrame.new(0, 0, 1.1)
            local bangLoop
            bangLoop = RunService.Stepped:Connect(function()
                pcall(function()
                    local otherRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    altHRP.CFrame = otherRoot.CFrame * bangOffet
                end)
            end)

            -- Disconnect when the bang animation ends
            local bangDied
            bangDied = localPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
                bangLoop:Disconnect()
                bang:Stop()
                bangAnim:Destroy()
                bangDied:Disconnect()
            end)
        end
    end
end

-- Function to stop the bang effect
local function unbang()
    if bangLoop then
        bangLoop:Disconnect()
        bangLoop = nil
    end
    if bangDied then
        bangDied:Disconnect()
        bangDied = nil
    end
end

-- Function to start hovering near a target player
local function startHover(targetPlayer, position)
    local validPositions = { "center", "topleft", "topright" }
    if not table.find(validPositions, string.lower(position)) then
        return
    end

    hovering = true
    local hoverPosition = string.lower(position)

    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local altHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

        if targetHRP and altHRP then
            if hoverConnection then
                hoverConnection:Disconnect()
            end

            hoverConnection = RunService.Heartbeat:Connect(function()
                if hovering and targetHRP and altHRP then
                    local offset = Vector3.new(0, 5, -5)

                    if hoverPosition == "topleft" then
                        offset = Vector3.new(-3, 5, -5)
                    elseif hoverPosition == "topright" then
                        offset = Vector3.new(3, 5, -5)
                    end

                    altHRP.CFrame = targetHRP.CFrame * CFrame.new(offset)
                end
            end)
        end
    end
end

-- Function to stop hovering
local function stopHover()
    hovering = false
    if hoverConnection then
        hoverConnection:Disconnect()
        hoverConnection = nil
    end
end

-- Function to make the alt say something once
local function sayMessage(message)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
end

-- Function to start spamming a message
local function startSpam(message)
    spamming = true

    if spamConnection then
        spamConnection:Disconnect()
    end

    spamConnection = RunService.Heartbeat:Connect(function()
        if spamming then
            sayMessage(message)
            task.wait(chatCooldown)
        end
    end)
end

-- Function to stop spamming
local function stopSpam()
    spamming = false
    if spamConnection then
        spamConnection:Disconnect()
        spamConnection = nil
    end
end

-- Ensure the loop-explosion table exists
if not getgenv().LoopExplosions then
    getgenv().LoopExplosions = {}
end

-- Chat function to send messages
local function Chat(msg)
    Players:Chat(msg)
end

-- Function to start loop-exploding a target
local function LexCommand(targetPartial)
    if not targetPartial or #targetPartial == 0 then return end
    
    -- Check if the target is already being loop-exploded
    if getgenv().LoopExplosions[targetPartial] then
        return -- If already loop-exploding, do nothing
    end
    
    -- Mark the target as active (start exploding)
    getgenv().LoopExplosions[targetPartial] = true

    -- Switch to system chat for administrative commands
    Chat("/c system")
    task.wait(0.1)

    -- Loop explosion until stopped
    while getgenv().LoopExplosions[targetPartial] do
        Chat("explode " .. targetPartial)  -- Send explode command
        task.wait(0.5)  -- Adjust delay to avoid spam detection
    end
end

-- Function to stop the loop-exploding (unlex) a target
local function UnlexCommand(targetPartial)
    if targetPartial and getgenv().LoopExplosions[targetPartial] then
        -- Mark the target as no longer being loop-exploded
        getgenv().LoopExplosions[targetPartial] = nil
        Chat("Stopped exploding " .. targetPartial)  -- Inform in chat
    end
end

-- Function to process chat messages from the master
local function onPlayerChatted(player, message)
    if player.UserId == masterUserId and message:sub(1, #Prefix) == Prefix then
        local cmd = string.split(message, " ")
        local targetPlayer = findPlayerByName(cmd[2])

        if not targetPlayer and cmd[1] ~= Prefix .. "say" and cmd[1] ~= Prefix .. "spam" and cmd[1] ~= Prefix .. "stopspam" then
            return
        end

        if cmd[1] == Prefix .. "summon" then
            teleportAltToPlayer(targetPlayer)
        elseif cmd[1] == Prefix .. "orbit" and #cmd >= 5 then
            startOrbit(targetPlayer, cmd[3], cmd[4], cmd[5])
        elseif cmd[1] == Prefix .. "stoporbit" then
            stopOrbit()
        elseif cmd[1] == Prefix .. "hover" and #cmd >= 3 then
            startHover(targetPlayer, cmd[3])
        elseif cmd[1] == Prefix .. "stophover" then
            stopHover()
        elseif cmd[1] == Prefix .. "say" and #cmd >= 2 then
            sayMessage(table.concat(cmd, " ", 2))
        elseif cmd[1] == Prefix .. "spam" and #cmd >= 2 then
            startSpam(table.concat(cmd, " ", 2))
        elseif cmd[1] == Prefix .. "stopspam" then
            stopSpam()
        elseif cmd[1] == Prefix .. "smite" and #cmd >= 2 then
            smite(targetPlayer)
        elseif cmd[1] == Prefix .. "stopsmite" then
            stopSmite()
        elseif cmd[1] == Prefix .. "reset" then
            resetAlt()
        elseif cmd[1] == Prefix .. "lex" and #cmd >= 2 then
            LexCommand(cmd[2])  -- Start the loop-explosion on the target
        elseif cmd[1] == Prefix .. "unlex" and #cmd >= 2 then
            UnlexCommand(cmd[2])  -- Stop the loop-explosion for the target
        elseif cmd[1] == Prefix .. "bang" and #cmd >= 2 then
            bang(cmd[2]) -- Start the bang animation on the target
        elseif cmd[1] == Prefix .. "unbang" then
            unbang() -- Stop the bang animation
        end
    end
end

-- Connect chat listener for the master
for _, player in ipairs(Players:GetPlayers()) do
    if player.UserId == masterUserId then
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end
end

-- Connect listener for when the master joins
Players.PlayerAdded:Connect(function(player)
    if player.UserId == masterUserId then
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end
end)

print("loaded")
