-- ESP Module for Roblox - FIXED VERSION
-- Standalone ESP system with BillboardGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP Configuration
local ESP = {
    Enabled = false,
    TeamCheck = false,
    ShowBoxes = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    RainbowMode = false,
    Objects = {}
}

-- Internal Functions
local function GetRainbow()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

local function RemoveESP(player)
    if ESP.Objects[player] then
        for _, obj in pairs(ESP.Objects[player]) do
            pcall(function() obj:Destroy() end)
        end
        ESP.Objects[player] = nil
    end
end

local function ClearAllESP()
    for player, _ in pairs(ESP.Objects) do
        RemoveESP(player)
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    RemoveESP(player)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = root
    billboard.Parent = root
    
    ESP.Objects[player] = {}
    table.insert(ESP.Objects[player], billboard)
    
    if ESP.ShowBoxes then
        local box = Instance.new("Frame")
        box.Name = "Box"
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 2
        box.BorderColor3 = Color3.fromRGB(255, 0, 0)
        box.Parent = billboard
        table.insert(ESP.Objects[player], box)
    end
    
    if ESP.ShowNames then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, -0.15, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = billboard
        table.insert(ESP.Objects[player], nameLabel)
    end
    
    if ESP.ShowDistance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "Distance"
        distLabel.Size = UDim2.new(1, 0, 0, 20)
        distLabel.Position = UDim2.new(0, 0, 1.05, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextStrokeTransparency = 0.5
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.SourceSans
        distLabel.Parent = billboard
        table.insert(ESP.Objects[player], distLabel)
    end
    
    if ESP.ShowHealth then
        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Size = UDim2.new(0, 3, 1, 0)
        healthBar.Position = UDim2.new(-0.05, 0, 0, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 1
        healthBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
        healthBar.Parent = billboard
        table.insert(ESP.Objects[player], healthBar)
    end
end

local function UpdateESP()
    if not ESP.Enabled then
        ClearAllESP()
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                if root and humanoid then
                    local billboard = root:FindFirstChild("ESP")
                    if billboard then
                        local distLabel = billboard:FindFirstChild("Distance")
                        if distLabel and ESP.ShowDistance then
                            local dist = (Camera.CFrame.Position - root.Position).Magnitude
                            distLabel.Text = string.format("%.0f studs", dist)
                        end
                        
                        local healthBar = billboard:FindFirstChild("HealthBar")
                        if healthBar and humanoid and ESP.ShowHealth then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            healthBar.Size = UDim2.new(0, 3, healthPercent, 0)
                            
                            if healthPercent > 0.75 then
                                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            elseif healthPercent > 0.5 then
                                healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                            elseif healthPercent > 0.25 then
                                healthBar.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                            else
                RemoveESP(player)
            end
        end
    end
end

-- Update Loop
RunService.Heartbeat:Connect(function()
    if ESP.Enabled then
        UpdateESP()
    end
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if ESP.Enabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ESP.Enabled then
                CreateESP(player)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Public API
function ESP:Toggle(state)
    self.Enabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    else
        ClearAllESP()
    end
end

function ESP:SetTeamCheck(state)
    self.TeamCheck = state
    if self.Enabled then
        ClearAllESP()
        task.wait(0.1)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

function ESP:SetBoxes(state)
    self.ShowBoxes = state
    if self.Enabled then
        ClearAllESP()
        task.wait(0.1)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

function ESP:SetNames(state)
    self.ShowNames = state
    if self.Enabled then
        ClearAllESP()
        task.wait(0.1)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

function ESP:SetDistance(state)
    self.ShowDistance = state
    if self.Enabled then
        ClearAllESP()
        task.wait(0.1)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

function ESP:SetHealth(state)
    self.ShowHealth = state
    if self.Enabled then
        ClearAllESP()
        task.wait(0.1)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

function ESP:SetRainbow(state)
    self.RainbowMode = state
end

return ESP                healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            end
                        end
                        
                        if ESP.RainbowMode then
                            local box = billboard:FindFirstChild("Box")
                            if box then
                                box.BorderColor3 = GetRainbow()
                            end
                            local nameLabel = billboard:FindFirstChild("Name")
                            if nameLabel then
                                nameLabel.TextColor3 = GetRainbow()
                            end
                        end
                    else
                        if not ESP.Objects[player] then
                            CreateESP(player)
                        end
                    end
                end
            else
