-- Premium ESP Module v2.0
-- High Quality Modular ESP System
-- Compatible with all Roblox games

local ESP = {}
ESP.__index = ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Storage
ESP.Players = {}
ESP.Objects = {}

-- Settings
ESP.Settings = {
    -- Box ESP
    Box = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        Filled = false,
        FilledTransparency = 0.3,
        Rainbow = false
    },
    
    -- Tracer ESP
    Tracer = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        Origin = "Bottom", -- Bottom, Middle, Top, Mouse
        Rainbow = false
    },
    
    -- Name ESP
    Name = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 16,
        Font = 2, -- Drawing.Fonts.UI
        Outline = true,
        DisplayDistance = true,
        DisplayHealth = true,
        DisplayTeam = false
    },
    
    -- Health Bar ESP
    HealthBar = {
        Enabled = false,
        Width = 3,
        Outline = true,
        HealthBased = true, -- Color changes with health
        Position = "Left" -- Left, Right, Top, Bottom
    },
    
    -- Skeleton ESP
    Skeleton = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1.5,
        Rainbow = false
    },
    
    -- Chams/Highlight
    Chams = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        Rainbow = false
    },
    
    -- Head Dot
    HeadDot = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Radius = 5,
        Filled = true,
        Rainbow = false
    },
    
    -- Distance ESP
    Distance = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        Font = 2,
        Outline = true
    },
    
    -- Weapon ESP
    Weapon = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        Font = 2,
        Outline = true
    },
    
    -- LookLine (Line to where player is looking)
    LookLine = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        Length = 10,
        Rainbow = false
    },
    
    -- General Settings
    TeamCheck = false,
    ShowTeam = true,
    ShowEnemies = true,
    MaxDistance = 1000,
    VisibilityCheck = false,
    UseDisplayName = false,
    
    -- Rainbow Settings
    RainbowSpeed = 1,
    RainbowSaturation = 1,
    RainbowBrightness = 1
}

-- Rainbow Color Generator
local RainbowHue = 0
function ESP:GetRainbowColor()
    RainbowHue = (RainbowHue + (self.Settings.RainbowSpeed / 100)) % 1
    return Color3.fromHSV(RainbowHue, self.Settings.RainbowSaturation, self.Settings.RainbowBrightness)
end

-- Health Color Generator
function ESP:GetHealthColor(health, maxHealth)
    local percentage = health / maxHealth
    if percentage > 0.75 then
        return Color3.fromRGB(0, 255, 0) -- Green
    elseif percentage > 0.5 then
        return Color3.fromRGB(255, 255, 0) -- Yellow
    elseif percentage > 0.25 then
        return Color3.fromRGB(255, 165, 0) -- Orange
    else
        return Color3.fromRGB(255, 0, 0) -- Red
    end
end

-- Check if player should be shown
function ESP:ShouldShow(player)
    if not player or player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- Team Check
    if self.Settings.TeamCheck then
        if player.Team == LocalPlayer.Team then
            if not self.Settings.ShowTeam then return false end
        else
            if not self.Settings.ShowEnemies then return false end
        end
    end
    
    -- Distance Check
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > self.Settings.MaxDistance then return false end
    
    -- Visibility Check
    if self.Settings.VisibilityCheck then
        local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * distance)
        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        if hit and not player.Character:IsAncestorOf(hit) then
            return false
        end
    end
    
    return true
end

-- Get Character Parts (R6/R15 Compatible)
function ESP:GetCharacterParts(character)
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    local parts = {
        Head = character:FindFirstChild("Head"),
        RootPart = character:FindFirstChild("HumanoidRootPart"),
        RigType = humanoid.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
    }
    
    if parts.RigType == "R15" then
        parts.UpperTorso = character:FindFirstChild("UpperTorso")
        parts.LowerTorso = character:FindFirstChild("LowerTorso")
        parts.LeftUpperArm = character:FindFirstChild("LeftUpperArm")
        parts.LeftLowerArm = character:FindFirstChild("LeftLowerArm")
        parts.LeftHand = character:FindFirstChild("LeftHand")
        parts.RightUpperArm = character:FindFirstChild("RightUpperArm")
        parts.RightLowerArm = character:FindFirstChild("RightLowerArm")
        parts.RightHand = character:FindFirstChild("RightHand")
        parts.LeftUpperLeg = character:FindFirstChild("LeftUpperLeg")
        parts.LeftLowerLeg = character:FindFirstChild("LeftLowerLeg")
        parts.LeftFoot = character:FindFirstChild("LeftFoot")
        parts.RightUpperLeg = character:FindFirstChild("RightUpperLeg")
        parts.RightLowerLeg = character:FindFirstChild("RightLowerLeg")
        parts.RightFoot = character:FindFirstChild("RightFoot")
    else
        parts.Torso = character:FindFirstChild("Torso")
        parts.LeftArm = character:FindFirstChild("Left Arm")
        parts.RightArm = character:FindFirstChild("Right Arm")
        parts.LeftLeg = character:FindFirstChild("Left Leg")
        parts.RightLeg = character:FindFirstChild("Right Leg")
    end
    
    return parts
end

-- Create Drawing Object
function ESP:CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties or {}) do
        pcall(function()
            drawing[prop] = value
        end)
    end
    return drawing
end

-- Create ESP for Player
function ESP:CreateESP(player)
    if self.Players[player] then
        self:RemoveESP(player)
    end
    
    local espData = {
        Player = player,
        Drawings = {},
        Highlight = nil
    }
    
    -- Box ESP
    if self.Settings.Box.Enabled then
        espData.Drawings.Box = {
            Square = self:CreateDrawing("Square", {
                Thickness = self.Settings.Box.Thickness,
                Filled = self.Settings.Box.Filled,
                Transparency = self.Settings.Box.Filled and self.Settings.Box.FilledTransparency or 1,
                Visible = false
            })
        }
    end
    
    -- Tracer ESP
    if self.Settings.Tracer.Enabled then
        espData.Drawings.Tracer = self:CreateDrawing("Line", {
            Thickness = self.Settings.Tracer.Thickness,
            Visible = false
        })
    end
    
    -- Name ESP
    if self.Settings.Name.Enabled then
        espData.Drawings.Name = self:CreateDrawing("Text", {
            Size = self.Settings.Name.Size,
            Font = self.Settings.Name.Font,
            Outline = self.Settings.Name.Outline,
            Center = true,
            Visible = false
        })
    end
    
    -- Health Bar ESP
    if self.Settings.HealthBar.Enabled then
        espData.Drawings.HealthBar = {
            Background = self:CreateDrawing("Square", {
                Thickness = 1,
                Filled = true,
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = 0.5,
                Visible = false
            }),
            Bar = self:CreateDrawing("Square", {
                Thickness = 1,
                Filled = true,
                Transparency = 1,
                Visible = false
            }),
            Outline = self:CreateDrawing("Square", {
                Thickness = 1,
                Filled = false,
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = 1,
                Visible = false
            })
        }
    end
    
    -- Skeleton ESP
    if self.Settings.Skeleton.Enabled then
        espData.Drawings.Skeleton = {}
        for i = 1, 14 do
            espData.Drawings.Skeleton[i] = self:CreateDrawing("Line", {
                Thickness = self.Settings.Skeleton.Thickness,
                Visible = false
            })
        end
    end
    
    -- Chams/Highlight
    if self.Settings.Chams.Enabled and player.Character then
        espData.Highlight = Instance.new("Highlight")
        espData.Highlight.Adornee = player.Character
        espData.Highlight.FillTransparency = self.Settings.Chams.FillTransparency
        espData.Highlight.OutlineTransparency = self.Settings.Chams.OutlineTransparency
        espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        espData.Highlight.Parent = player.Character
    end
    
    -- Head Dot ESP
    if self.Settings.HeadDot.Enabled then
        espData.Drawings.HeadDot = self:CreateDrawing("Circle", {
            Radius = self.Settings.HeadDot.Radius,
            Filled = self.Settings.HeadDot.Filled,
            NumSides = 30,
            Visible = false
        })
    end
    
    -- Distance ESP
    if self.Settings.Distance.Enabled then
        espData.Drawings.Distance = self:CreateDrawing("Text", {
            Size = self.Settings.Distance.Size,
            Font = self.Settings.Distance.Font,
            Outline = self.Settings.Distance.Outline,
            Center = true,
            Visible = false
        })
    end
    
    -- Weapon ESP
    if self.Settings.Weapon.Enabled then
        espData.Drawings.Weapon = self:CreateDrawing("Text", {
            Size = self.Settings.Weapon.Size,
            Font = self.Settings.Weapon.Font,
            Outline = self.Settings.Weapon.Outline,
            Center = true,
            Visible = false
        })
    end
    
    -- Look Line ESP
    if self.Settings.LookLine.Enabled then
        espData.Drawings.LookLine = self:CreateDrawing("Line", {
            Thickness = self.Settings.LookLine.Thickness,
            Visible = false
        })
    end
    
    self.Players[player] = espData
end

-- Remove ESP for Player
function ESP:RemoveESP(player)
    local espData = self.Players[player]
    if not espData then return end
    
    -- Remove Drawings
    for category, drawing in pairs(espData.Drawings) do
        if type(drawing) == "table" then
            for _, d in pairs(drawing) do
                pcall(function() d:Remove() end)
            end
        else
            pcall(function() drawing:Remove() end)
        end
    end
    
    -- Remove Highlight
    if espData.Highlight then
        pcall(function() espData.Highlight:Destroy() end)
    end
    
    self.Players[player] = nil
end

-- Update ESP for Player
function ESP:UpdateESP(player)
    if not self:ShouldShow(player) then
        if self.Players[player] then
            self:HideESP(player)
        end
        return
    end
    
    if not self.Players[player] then
        self:CreateESP(player)
    end
    
    local espData = self.Players[player]
    local character = player.Character
    local parts = self:GetCharacterParts(character)
    
    if not parts or not parts.RootPart then
        self:HideESP(player)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPos = parts.RootPart.Position
    local headPos = parts.Head and parts.Head.Position or rootPos
    
    -- Get Rainbow Color if enabled
    local rainbowColor = self:GetRainbowColor()
    
    -- Calculate 2D Positions
    local rootScreen, rootVisible = Camera:WorldToViewportPoint(rootPos)
    local headScreen, headVisible = Camera:WorldToViewportPoint(headPos)
    
    if not rootVisible then
        self:HideESP(player)
        return
    end
    
    -- Calculate Box Corners
    local corners = {}
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                minX = math.min(minX, screenPos.X)
                maxX = math.max(maxX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end
    
    local boxWidth = maxX - minX
    local boxHeight = maxY - minY
    
    -- Update Box ESP
    if espData.Drawings.Box then
        local box = espData.Drawings.Box.Square
        box.Size = Vector2.new(boxWidth, boxHeight)
        box.Position = Vector2.new(minX, minY)
        box.Color = self.Settings.Box.Rainbow and rainbowColor or self.Settings.Box.Color
        box.Visible = true
    end
    
    -- Update Tracer ESP
    if espData.Drawings.Tracer then
        local tracer = espData.Drawings.Tracer
        local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        
        if self.Settings.Tracer.Origin == "Top" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
        elseif self.Settings.Tracer.Origin == "Middle" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        
        tracer.From = origin
        tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
        tracer.Color = self.Settings.Tracer.Rainbow and rainbowColor or self.Settings.Tracer.Color
        tracer.Visible = true
    end
    
    -- Update Name ESP
    if espData.Drawings.Name then
        local nameText = self.Settings.UseDisplayName and player.DisplayName or player.Name
        local distance = math.floor((rootPos - Camera.CFrame.Position).Magnitude)
        
        if self.Settings.Name.DisplayDistance then
            nameText = nameText .. " [" .. distance .. "m]"
        end
        
        if self.Settings.Name.DisplayHealth and humanoid then
            nameText = nameText .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "]"
        end
        
        if self.Settings.Name.DisplayTeam and player.Team then
            nameText = nameText .. " [" .. player.Team.Name .. "]"
        end
        
        local name = espData.Drawings.Name
        name.Text = nameText
        name.Position = Vector2.new(headScreen.X, minY - 20)
        name.Color = self.Settings.Name.Color
        name.Visible = true
    end
    
    -- Update Health Bar ESP
    if espData.Drawings.HealthBar and humanoid then
        local healthBar = espData.Drawings.HealthBar
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        
        local barHeight = boxHeight
        local barWidth = self.Settings.HealthBar.Width
        local barX = minX - barWidth - 3
        local barY = minY
        
        if self.Settings.HealthBar.Position == "Right" then
            barX = maxX + 3
        end
        
        -- Background
        healthBar.Background.Size = Vector2.new(barWidth, barHeight)
        healthBar.Background.Position = Vector2.new(barX, barY)
        healthBar.Background.Visible = true
        
        -- Health Bar
        local barFillHeight = barHeight * healthPercent
        healthBar.Bar.Size = Vector2.new(barWidth, barFillHeight)
        healthBar.Bar.Position = Vector2.new(barX, barY + (barHeight - barFillHeight))
        healthBar.Bar.Color = self.Settings.HealthBar.HealthBased and self:GetHealthColor(humanoid.Health, humanoid.MaxHealth) or Color3.fromRGB(0, 255, 0)
        healthBar.Bar.Visible = true
        
        -- Outline
        if self.Settings.HealthBar.Outline then
            healthBar.Outline.Size = Vector2.new(barWidth, barHeight)
            healthBar.Outline.Position = Vector2.new(barX, barY)
            healthBar.Outline.Visible = true
        end
    end
    
    -- Update Skeleton ESP
    if espData.Drawings.Skeleton then
        local skeleton = espData.Drawings.Skeleton
        local skeletonColor = self.Settings.Skeleton.Rainbow and rainbowColor or self.Settings.Skeleton.Color
        
        local function drawLine(index, partA, partB)
            if not partA or not partB or index > #skeleton then return end
            local posA, visA = Camera:WorldToViewportPoint(partA.Position)
            local posB, visB = Camera:WorldToViewportPoint(partB.Position)
            
            if visA and visB then
                skeleton[index].From = Vector2.new(posA.X, posA.Y)
                skeleton[index].To = Vector2.new(posB.X, posB.Y)
                skeleton[index].Color = skeletonColor
                skeleton[index].Visible = true
            else
                skeleton[index].Visible = false
            end
        end
        
        if parts.RigType == "R15" then
            drawLine(1, parts.Head, parts.UpperTorso)
            drawLine(2, parts.UpperTorso, parts.LowerTorso)
            drawLine(3, parts.UpperTorso, parts.LeftUpperArm)
            drawLine(4, parts.LeftUpperArm, parts.LeftLowerArm)
            drawLine(5, parts.LeftLowerArm, parts.LeftHand)
            drawLine(6, parts.UpperTorso, parts.RightUpperArm)
            drawLine(7, parts.RightUpperArm, parts.RightLowerArm)
            drawLine(8, parts.RightLowerArm, parts.RightHand)
            drawLine(9, parts.LowerTorso, parts.LeftUpperLeg)
            drawLine(10, parts.LeftUpperLeg, parts.LeftLowerLeg)
            drawLine(11, parts.LeftLowerLeg, parts.LeftFoot)
            drawLine(12, parts.LowerTorso, parts.RightUpperLeg)
            drawLine(13, parts.RightUpperLeg, parts.RightLowerLeg)
            drawLine(14, parts.RightLowerLeg, parts.RightFoot)
        else
            drawLine(1, parts.Head, parts.Torso)
            drawLine(2, parts.Torso, parts.LeftArm)
            drawLine(3, parts.Torso, parts.RightArm)
            drawLine(4, parts.Torso, parts.LeftLeg)
            drawLine(5, parts.Torso, parts.RightLeg)
            for i = 6, 14 do
                if skeleton[i] then skeleton[i].Visible = false end
            end
        end
    end
    
    -- Update Chams/Highlight
    if espData.Highlight then
        espData.Highlight.FillColor = self.Settings.Chams.Rainbow and rainbowColor or self.Settings.Chams.FillColor
        espData.Highlight.OutlineColor = self.Settings.Chams.OutlineColor
    end
    
    -- Update Head Dot ESP
    if espData.Drawings.HeadDot and parts.Head then
        local headDot = espData.Drawings.HeadDot
        headDot.Position = Vector2.new(headScreen.X, headScreen.Y)
        headDot.Color = self.Settings.HeadDot.Rainbow and rainbowColor or self.Settings.HeadDot.Color
        headDot.Visible = headVisible
    end
    
    -- Update Distance ESP
    if espData.Drawings.Distance then
        local distance = math.floor((rootPos - Camera.CFrame.Position).Magnitude)
        local dist = espData.Drawings.Distance
        dist.Text = distance .. "m"
        dist.Position = Vector2.new(rootScreen.X, maxY + 5)
        dist.Color = self.Settings.Distance.Color
        dist.Visible = true
    end
    
    -- Update Weapon ESP
    if espData.Drawings.Weapon then
        local tool = character:FindFirstChildOfClass("Tool")
        local weapon = espData.Drawings.Weapon
        weapon.Text = tool and tool.Name or "Unarmed"
        weapon.Position = Vector2.new(rootScreen.X, maxY + 20)
        weapon.Color = self.Settings.Weapon.Color
        weapon.Visible = true
    end
    
    -- Update Look Line ESP
    if espData.Drawings.LookLine and parts.Head then
        local lookLine = espData.Drawings.LookLine
        local lookVector = parts.Head.CFrame.LookVector * self.Settings.LookLine.Length
        local endPos = parts.Head.Position + lookVector
        local endScreen, endVisible = Camera:WorldToViewportPoint(endPos)
        
        if headVisible and endVisible then
            lookLine.From = Vector2.new(headScreen.X, headScreen.Y)
            lookLine.To = Vector2.new(endScreen.X, endScreen.Y)
            lookLine.Color = self.Settings.LookLine.Rainbow and rainbowColor or self.Settings.LookLine.Color
            lookLine.Visible = true
        else
            lookLine.Visible = false
        end
    end
end

-- Hide ESP for Player
function ESP:HideESP(player)
    local espData = self.Players[player]
    if not espData then return end
    
    for category, drawing in pairs(espData.Drawings) do
        if type(drawing) == "table" then
            for _, d in pairs(drawing) do
                pcall(function() d.Visible = false end)
            end
        else
            pcall(function() drawing.Visible = false end)
        end
    end
    
    if espData.Highlight then
        espData.Highlight.Enabled = false
    end
end

-- Main Update Loop
function ESP:Start()
    if self.Connection then return end
    
    self.Connection = RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                self:UpdateESP(player)
            end)
        end
    end)
    
    -- Player Added
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            self:CreateESP(player)
        end)
    end)
    
    -- Player Removing
    Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
    
    -- Initialize existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            self:CreateESP(player)
        end
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            self:CreateESP(player)
        end)
    end
end

-- Stop ESP
function ESP:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    for player in pairs(self.Players) do
        self:RemoveESP(player)
    end
end

-- Toggle Functions
function ESP:ToggleBox(enabled)
    self.Settings.Box.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Box then
                data.Drawings.Box.Square.Visible = false
            end
        end
    end
end

function ESP:ToggleTracer(enabled)
    self.Settings.Tracer.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Tracer then
                data.Drawings.Tracer.Visible = false
            end
        end
    end
end

function ESP:ToggleName(enabled)
    self.Settings.Name.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Name then
                data.Drawings.Name.Visible = false
            end
        end
    end
end

function ESP:ToggleHealthBar(enabled)
    self.Settings.HealthBar.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.HealthBar then
                for _, d in pairs(data.Drawings.HealthBar) do
                    d.Visible = false
                end
            end
        end
    end
end

function ESP:ToggleSkeleton(enabled)
    self.Settings.Skeleton.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Skeleton then
                for _, line in pairs(data.Drawings.Skeleton) do
                    line.Visible = false
                end
            end
        end
    end
end

function ESP:ToggleChams(enabled)
    self.Settings.Chams.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Highlight then
                data.Highlight.Enabled = false
            end
        end
    else
        for player in pairs(self.Players) do
            if player.Character and not self.Players[player].Highlight then
                local hl = Instance.new("Highlight")
                hl.Adornee = player.Character
                hl.FillTransparency = self.Settings.Chams.FillTransparency
                hl.OutlineTransparency = self.Settings.Chams.OutlineTransparency
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player.Character
                self.Players[player].Highlight = hl
            end
        end
    end
end

function ESP:ToggleHeadDot(enabled)
    self.Settings.HeadDot.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.HeadDot then
                data.Drawings.HeadDot.Visible = false
            end
        end
    end
end

function ESP:ToggleDistance(enabled)
    self.Settings.Distance.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Distance then
                data.Drawings.Distance.Visible = false
            end
        end
    end
end

function ESP:ToggleWeapon(enabled)
    self.Settings.Weapon.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.Weapon then
                data.Drawings.Weapon.Visible = false
            end
        end
    end
end

function ESP:ToggleLookLine(enabled)
    self.Settings.LookLine.Enabled = enabled
    if not enabled then
        for _, data in pairs(self.Players) do
            if data.Drawings.LookLine then
                data.Drawings.LookLine.Visible = false
            end
        end
    end
end

-- Disable All ESP
function ESP
