-- ESP Module for Roblox - WORKING VERSION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.objects = {}
ESP.skeleton = false
ESP.highlight = false
ESP.tracers = false
ESP.rainbow = false
ESP.teamCheck = false
ESP.customColor = Color3.fromRGB(255, 0, 0)
ESP._connection = nil

local function isAnyEnabled()
    return ESP.skeleton or ESP.highlight or ESP.tracers
end

local function cleanPlayer(player)
    local data = ESP.objects[player]
    if not data then return end

    if data.Highlight then
        pcall(function() data.Highlight:Destroy() end)
    end

    if data.Skeleton then
        for _, line in ipairs(data.Skeleton) do
            pcall(function() line:Remove() end)
        end
    end

    if data.Tracer then
        pcall(function() data.Tracer:Remove() end)
    end

    ESP.objects[player] = nil
end

local function fullClean()
    for plr in pairs(ESP.objects) do
        cleanPlayer(plr)
    end
end

local function getCharacterParts(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then
        return nil
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rig = humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"

    local t = {
        Head = char.Head,
        Root = char.HumanoidRootPart,
        RigType = rig
    }

    if rig == "R15" then
        t.UpperTorso = char:FindFirstChild("UpperTorso")
        t.LowerTorso = char:FindFirstChild("LowerTorso")
        t.LeftUpperArm = char:FindFirstChild("LeftUpperArm")
        t.LeftLowerArm = char:FindFirstChild("LeftLowerArm")
        t.LeftHand = char:FindFirstChild("LeftHand")
        t.RightUpperArm = char:FindFirstChild("RightUpperArm")
        t.RightLowerArm = char:FindFirstChild("RightLowerArm")
        t.RightHand = char:FindFirstChild("RightHand")
        t.LeftUpperLeg = char:FindFirstChild("LeftUpperLeg")
        t.LeftLowerLeg = char:FindFirstChild("LeftLowerLeg")
        t.LeftFoot = char:FindFirstChild("LeftFoot")
        t.RightUpperLeg = char:FindFirstChild("RightUpperLeg")
        t.RightLowerLeg = char:FindFirstChild("RightLowerLeg")
        t.RightFoot = char:FindFirstChild("RightFoot")
    else
        t.Torso = char:FindFirstChild("Torso")
        t.LeftArm = char:FindFirstChild("Left Arm")
        t.RightArm = char:FindFirstChild("Right Arm")
        t.LeftLeg = char:FindFirstChild("Left Leg")
        t.RightLeg = char:FindFirstChild("Right Leg")
    end

    return t
end

local function getCurrentColor()
    if ESP.rainbow then
        return Color3.fromHSV(tick() % 5 / 5, 1, 1)
    else
        return ESP.customColor
    end
end

local function updateESP()
    if not isAnyEnabled() then
        if next(ESP.objects) ~= nil then
            fullClean()
        end
        return
    end

    local camera = workspace.CurrentCamera
    local currentColor = getCurrentColor()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        if ESP.teamCheck and player.Team == LocalPlayer.Team then
            cleanPlayer(player)
            continue
        end

        local character = player.Character
        local parts = character and getCharacterParts(character)
        if not parts then
            cleanPlayer(player)
            continue
        end

        if not ESP.objects[player] then
            ESP.objects[player] = {}
        end

        if ESP.highlight then
            if not ESP.objects[player].Highlight then
                local hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = character
                hl.Parent = character
                ESP.objects[player].Highlight = hl
            end
            local hl = ESP.objects[player].Highlight
            hl.FillColor = currentColor
            hl.OutlineColor = currentColor
        else
            if ESP.objects[player].Highlight then
                pcall(function() ESP.objects[player].Highlight:Destroy() end)
                ESP.objects[player].Highlight = nil
            end
        end

        if ESP.skeleton then
            if not ESP.objects[player].Skeleton then
                local lines = {}
                for i = 1, 14 do
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Visible = false
                    table.insert(lines, line)
                end
                ESP.objects[player].Skeleton = lines
            end

            local lines = ESP.objects[player].Skeleton

            local function draw(index, a, b)
                local line = lines[index]
                if not line then return end
                if not a or not b then
                    line.Visible = false
                    return
                end
                local p1, v1 = camera:WorldToViewportPoint(a.Position)
                local p2, v2 = camera:WorldToViewportPoint(b.Position)
                local visible = v1 and v2 and p1.Z > 0 and p2.Z > 0
                line.Visible = visible
                if visible then
                    line.From = Vector2.new(p1.X, p1.Y)
                    line.To = Vector2.new(p2.X, p2.Y)
                    line.Color = currentColor
                end
            end

            if parts.RigType == "R15" then
                draw(1, parts.Head, parts.UpperTorso)
                draw(2, parts.UpperTorso, parts.LowerTorso)
                draw(3, parts.UpperTorso, parts.LeftUpperArm)
                draw(4, parts.LeftUpperArm, parts.LeftLowerArm)
                draw(5, parts.LeftLowerArm, parts.LeftHand)
                draw(6, parts.UpperTorso, parts.RightUpperArm)
                draw(7, parts.RightUpperArm, parts.RightLowerArm)
                draw(8, parts.RightLowerArm, parts.RightHand)
                draw(9, parts.LowerTorso, parts.LeftUpperLeg)
                draw(10, parts.LeftUpperLeg, parts.LeftLowerLeg)
                draw(11, parts.LeftLowerLeg, parts.LeftFoot)
                draw(12, parts.LowerTorso, parts.RightUpperLeg)
                draw(13, parts.RightUpperLeg, parts.RightLowerLeg)
                draw(14, parts.RightLowerLeg, parts.RightFoot)
            else
                draw(1, parts.Head, parts.Torso)
                draw(2, parts.Torso, parts.LeftArm)
                draw(3, parts.Torso, parts.RightArm)
                draw(4, parts.Torso, parts.LeftLeg)
                draw(5, parts.Torso, parts.RightLeg)
                for i = 6, 14 do
                    local line = ESP.objects[player].Skeleton[i]
                    if line then line.Visible = false end
                end
            end
        else
            if ESP.objects[player].Skeleton then
                for _, line in ipairs(ESP.objects[player].Skeleton) do
                    pcall(function() line:Remove() end)
                end
                ESP.objects[player].Skeleton = nil
            end
        end

        if ESP.tracers then
            if not ESP.objects[player].Tracer then
                local trace = Drawing.new("Line")
                trace.Thickness = 2
                ESP.objects[player].Tracer = trace
            end

            local trace = ESP.objects[player].Tracer
            local p, v = camera:WorldToViewportPoint(parts.Root.Position)
            trace.Visible = v
            if v then
                trace.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                trace.To = Vector2.new(p.X, p.Y)
                trace.Color = currentColor
            end
        else
            if ESP.objects[player].Tracer then
                pcall(function() ESP.objects[player].Tracer:Remove() end)
                ESP.objects[player].Tracer = nil
            end
        end
    end
end

local function ensureConnection()
    if ESP._connection then return end
    ESP._connection = RunService.Heartbeat:Connect(function()
        pcall(updateESP)
    end)
    Players.PlayerRemoving:Connect(cleanPlayer)
end

function ESP:SetSkeleton(enabled)
    self.skeleton = enabled and true or false
    ensureConnection()
end

function ESP:SetHighlight(enabled)
    self.highlight = enabled and true or false
    ensureConnection()
end

function ESP:SetTracers(enabled)
    self.tracers = enabled and true or false
    ensureConnection()
end

function ESP:SetRainbow(enabled)
    self.rainbow = enabled and true or false
end

function ESP:SetTeamCheck(enabled)
    self.teamCheck = enabled and true or false
end

function ESP:SetColor(color)
    if typeof(color) == "Color3" then
        self.customColor = color
    end
end

function ESP:DisableAll()
    self.skeleton = false
    self.highlight = false
    self.tracers = false
    self.rainbow = false
    fullClean()
end

return ESP
