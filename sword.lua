-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- LocalPlayer
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Sword Settings
local reachDistance = 5  -- Default sword reach
local sword = nil  -- Will hold the sword when equipped

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0.2, 0, 0.1, 0)
frame.Position = UDim2.new(0.4, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2

local textLabel = Instance.new("TextLabel")
textLabel.Parent = frame
textLabel.Size = UDim2.new(1, 0, 0.5, 0)
textLabel.Text = "Sword Reach"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.BackgroundTransparency = 1

local slider = Instance.new("TextButton")
slider.Parent = frame
slider.Size = UDim2.new(1, 0, 0.5, 0)
slider.Position = UDim2.new(0, 0, 0.5, 0)
slider.Text = "Increase Reach"
slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
slider.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Visual Indicator (Square under player)
local indicator = Instance.new("Part")
indicator.Parent = character
indicator.Size = Vector3.new(reachDistance * 2, 0.2, reachDistance * 2)
indicator.Position = humanoidRootPart.Position - Vector3.new(0, 3, 0)
indicator.Anchored = true
indicator.CanCollide = false
indicator.Material = Enum.Material.Neon

-- Function to update reach
local function updateReach()
    if sword then
        local hitbox = sword:FindFirstChild("Handle")
        if hitbox then
            hitbox.Size = Vector3.new(1, 1, reachDistance * 2)  -- Adjust hitbox
        end
    end
    indicator.Size = Vector3.new(reachDistance * 2, 0.2, reachDistance * 2)
end

-- Slider button increases reach
slider.MouseButton1Click:Connect(function()
    reachDistance = reachDistance + 2
    if reachDistance > 20 then
        reachDistance = 5  -- Reset if too big
    end
    updateReach()
end)

-- Change indicator color continuously
RunService.RenderStepped:Connect(function()
    indicator.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    indicator.Position = humanoidRootPart.Position - Vector3.new(0, 3, 0)
end)

-- Sword Detection
player.Character.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
        sword = tool
        updateReach()
    end
end)

-- Auto Teleport to Nearest Player
local function getNearestPlayer()
    local nearest = nil
    local minDistance = math.huge

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local distance = (humanoidRootPart.Position - otherRoot.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearest = otherRoot
                end
            end
        end
    end
    return nearest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        local target = getNearestPlayer()
        if target then
            humanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)  -- Teleport above target
            repeat
                task.wait(0.1)
                humanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            until not target.Parent or not target.Parent:FindFirstChild("Humanoid") or target.Parent:FindFirstChild("Humanoid").Health <= 0
        end
    end
end)

-- Character Respawn Handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Reset Indicator
    indicator.Parent = newCharacter
    indicator.Size = Vector3.new(reachDistance * 2, 0.2, reachDistance * 2)
    indicator.Position = humanoidRootPart.Position - Vector3.new(0, 3, 0)
    indicator.Anchored = true
    indicator.CanCollide = false

    -- Reset Sword
    sword = nil
end)

print("Sword Fight Enhancer Loaded!")
