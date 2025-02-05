-- LocalPlayer setup
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")

-- Prefix variable
local prefix = "fd#"

-- Save position variable
local savedPosition = nil

-- Function to save the current position before void teleport
local function savePositionBeforeVoid()
    -- Save the position of the character's HumanoidRootPart before teleporting to the void
    savedPosition = character:FindFirstChild("HumanoidRootPart").CFrame
    print("Position saved before void teleport!")
end

-- Function to teleport to the void and back
local function teleportToVoidAndBack()
    -- Save the position first before teleporting
    savePositionBeforeVoid()

    -- Get the position of the "Void" (an unreachable position to simulate falling and death)
    local voidPosition = CFrame.new(0, -5000, 0)  -- Coordinates deep below the map to simulate falling

    -- Teleport to the void
    character:SetPrimaryPartCFrame(voidPosition)

    -- Kill the player by setting health to 0
    humanoid.Health = 0

    -- Wait a brief moment for the "death" process to happen
    wait(1)

    -- Respawn the character at the saved position
    respawnAtSavedPosition()
end

-- Function to respawn at saved position after death
local function respawnAtSavedPosition()
    if savedPosition then
        -- Wait for the new character to fully load
        local newCharacter = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")

        -- Teleport to the saved position
        newCharacter:SetPrimaryPartCFrame(savedPosition)
        print("Respawned at saved position!")

        -- Clear the saved position after teleporting to avoid reusing it
        savedPosition = nil
    else
        print("No saved position!")
    end
end

-- Command handler for commands
game.Players.LocalPlayer.Chatted:Connect(function(message)
    -- Check if message starts with prefix
    if not message:sub(1, #prefix) == prefix then return end
    
    -- Remove prefix from the message
    local cmd = message:sub(#prefix + 1):split(" ")

    if cmd[1] == "rejoin" then
        -- Rejoin the game
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        print("Rejoining game...")
    elseif cmd[1] == "ws" or cmd[1] == "walkspeed" then
        if #cmd >= 2 then
            local speed = tonumber(cmd[2])
            humanoid.WalkSpeed = speed or 16
            print("Walkspeed set to " .. humanoid.WalkSpeed)
        else
            print("Please specify a speed value.")
        end
    elseif cmd[1] == "jp" or cmd[1] == "jumpower" then
        if #cmd >= 2 then
            local jumpPower = tonumber(cmd[2])
            humanoid.JumpPower = jumpPower or 50
            print("JumpPower set to " .. humanoid.JumpPower)
        else
            print("Please specify a jump power value.")
        end
    elseif cmd[1] == "find" then
        if #cmd >= 2 then
            local targetPlayerName = cmd[2]
            -- Find player by name or partial username
            local targetPlayer = nil
            for _, target in ipairs(game.Players:GetPlayers()) do
                if target.DisplayName:lower():find(targetPlayerName:lower()) or target.Name:lower():find(targetPlayerName:lower()) then
                    targetPlayer = target
                    break
                end
            end
            if targetPlayer then
                -- Teleport to the found player
                local targetCharacter = targetPlayer.Character
                if targetCharacter then
                    character:SetPrimaryPartCFrame(targetCharacter.HumanoidRootPart.CFrame)
                    print("Teleported to " .. targetPlayer.Name)
                end
            else
                print("Player not found!")
            end
        else
            print("Please specify a player to teleport to.")
        end
    elseif cmd[1] == "c" then
        if #cmd >= 2 then
            -- Execute the Lua code passed after the "fd#c" command
            local code = table.concat(cmd, " ", 2)
            local success, result = pcall(function() return loadstring(code)() end)
            if success then
                print("Code executed successfully!")
            else
                print("Error executing code: " .. result)
            end
        else
            print("Please specify the Lua code to execute.")
        end
    end
end)

-- Listen for the "G" key press to teleport to void and back
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignore if the input was processed by something else

    if input.KeyCode == Enum.KeyCode.G then
        teleportToVoidAndBack()
    end
end)

-- Reset event when the character respawns
player.CharacterAdded:Connect(function()
    -- Only teleport if there's a saved position
    if savedPosition then
        respawnAtSavedPosition()
    end
end)

print("Admin commands loaded.")
