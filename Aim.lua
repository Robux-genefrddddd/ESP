local Aimbot = {}

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local settings = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = true,
    FOV = 140,
    ShowFOV = true,
    HitPart = "Head",
    TriggerBot = false,
    TriggerDelay = 0.01
}

local circle = Drawing.new("Circle")
circle.Radius = settings.FOV
circle.Color = Color3.fromRGB(255, 100, 0)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.8
circle.Visible = false

local hookConn
local triggerConn

local function getClosest()
    local closest
    local shortest = settings.FOV
    local mouse = UserInputService:GetMouseLocation()

    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        local hum = plr.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local part = plr.Character:FindFirstChild(settings.HitPart) or plr.Character:FindFirstChild("Head")
        if not part then continue end

        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        if settings.WallCheck then
            local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(plr.Character) then continue end
        end

        local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
        if dist < shortest then
            shortest = dist
            closest = part
        end
    end

    return closest
end

local function enableHook()
    if hookConn then return end

    hookConn = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if settings.Enabled and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
            local target = getClosest()
            if target then
                local args = {...}
                args[1] = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 9999)
                return self.FindPartOnRayWithIgnoreList(self, unpack(args))
            end
        end

        return hookConn(self, ...)
    end)
end

local function disableHook()
    hookConn = nil
end

local function startTrigger()
    if triggerConn then return end

    triggerConn = RunService.RenderStepped:Connect(function()
        if not (settings.Enabled and settings.TriggerBot) then return end

        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and getClosest() then
            mouse1press()
            task.wait(settings.TriggerDelay)
            mouse1release()
        end
    end)
end

local function stopTrigger()
    if triggerConn then
        triggerConn:Disconnect()
        triggerConn = nil
    end
end

function Aimbot:SetEnabled(state)
    settings.Enabled = state

    circle.Visible = state and settings.ShowFOV

    if not state then
        disableHook()
        stopTrigger()
        Notify("Aimbot", "Aimbot disabled")
        return
    end

    enableHook()

    if settings.TriggerBot then
        startTrigger()
    end

    Notify("Aimbot", "Aimbot enabled")
end

RunService.RenderStepped:Connect(function()
    if settings.Enabled and settings.ShowFOV then
        circle.Position = UserInputService:GetMouseLocation()
        circle.Radius = settings.FOV
    end
end)

_G.Aimbot = Aimbot
