local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local devUserIds = {
    [329617095] = true,
    [467730466] = true,
    [7321421842] = true,
}

local function isDeveloper(userId)
    return devUserIds[userId] == true
end

local function createDevTitle(character)
    local head = character:FindFirstChild("Head")
    if head and not head:FindFirstChild("DevTitle") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DevTitle"
        billboard.Size = UDim2.new(4, 0, 1, 0)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Wrath [ DEV @ Deity.lol]"
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextScaled = true
        textLabel.TextColor3 = Color3.new(1, 0, 0)
    end
end

local function createDevAura(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            if not part:FindFirstChild("DevAuraAttachment") then
                local attachment = Instance.new("Attachment")
                attachment.Name = "DevAuraAttachment"
                attachment.Parent = part

                local emitter = Instance.new("ParticleEmitter")
                emitter.Name = "DevAura"
                emitter.Texture = "rbxassetid://248625108"
                emitter.Rate = 40
                emitter.Lifetime = NumberRange.new(1, 1.5)
                emitter.Speed = NumberRange.new(-2, -1)
                emitter.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 2),
                    NumberSequenceKeypoint.new(1, 0)
                })
                emitter.LightEmission = 1
                emitter.Parent = attachment

                spawn(function()
                    local hue = 0
                    while emitter and emitter.Parent do
                        hue = (hue + 0.005) % 1
                        emitter.Color = ColorSequence.new(Color3.fromHSV(hue, 1, 1))
                        wait(0.05)
                    end
                end)
            end
        end
    end
end

local function applyDevEffects(character)
    if character then
        createDevTitle(character)
        createDevAura(character)
    end
end

local function updateDevEffects()
    for _, plr in ipairs(Players:GetPlayers()) do
        if isDeveloper(plr.UserId) then
            if plr.Character then
                applyDevEffects(plr.Character)
            end
            plr.CharacterAdded:Connect(function(newChar)
                wait(1)
                applyDevEffects(newChar)
            end)
        end
    end
end

updateDevEffects()

Players.PlayerAdded:Connect(function(plr)
    if isDeveloper(plr.UserId) then
        plr.CharacterAdded:Connect(function(newChar)
            wait(1)
            applyDevEffects(newChar)
        end)
    end
end)
