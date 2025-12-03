local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = true,
    FOV = 140,
    ShowFOV = true,
    HitPart = "Head",         
    TriggerBot = false,
    TriggerDelay = 0.01
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimbotSettings.FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Visible = false

local NamecallHook
local TriggerBotLoop
local FOVConnection

local function GetClosestPlayer()
    local closest = nil
    local shortest = AimbotSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then continue end
        if AimbotSettings.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local part = plr.Character:FindFirstChild(AimbotSettings.HitPart) or plr.Character:FindFirstChild("Head")
        if not part then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        if AimbotSettings.WallCheck then
            local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
            if hit and hit:IsDescendantOf(plr.Character) == false then continue end
        end

        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
        if distance < shortest then
            shortest = distance
            closest = part
        end
    end
    return closest
end

local function SetAimbotState(state)
    AimbotSettings.Enabled = state

    FOVCircle.Visible = state and AimbotSettings.ShowFOV

    if NamecallHook then NamecallHook:Disconnect() NamecallHook = nil end
    if TriggerBotLoop then TriggerBotLoop:Disconnect() TriggerBotLoop = nil end

    if not state then
        FOVCircle.Visible = false
        return
    end

    NamecallHook = hookmetamethod(game, "__namecall", function(self, ...)
        if AimbotSettings.Enabled and (getnamecallmethod() == "FindPartOnRayWithIgnoreList" or getnamecallmethod() == "Raycast") then
            local target = GetClosestPlayer()
            if target then
                local args = {...}
                args[1] = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 10000)
                return self.FindPartOnRayWithIgnoreList(self, unpack(args))
            end
        end
        return NamecallHook(self, ...)
    end)

    if AimbotSettings.TriggerBot then
        TriggerBotLoop = task.spawn(function()
            while AimbotSettings.Enabled and AimbotSettings.TriggerBot do
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and GetClosestPlayer() then
                    mouse1press()
                    task.wait(AimbotSettings.TriggerDelay)
                    mouse1release()
                end
                task.wait()
            end
        end)
    end

    Notify("Aimbot", state and "Aimbot activé" or "Aimbot désactivé")
end

FOVConnection = RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled and AimbotSettings.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = AimbotSettings.FOV
    end
end)

local AimbotTab = Window:Tab({Title = "Aimbot", Icon = "crosshair"})
local MainSec = AimbotTab:Section({Title = "Main"})

MainSec:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        SetAimbotState(state)
    end
})

MainSec:Toggle({
    Title = "Team Check",
    Default = true,
    Callback = function(state) AimbotSettings.TeamCheck = state end
})

MainSec:Toggle({
    Title = "Wall Check",
    Default = true,
    Callback = function(state) AimbotSettings.WallCheck = state end
})

MainSec:Toggle({
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(state)
        AimbotSettings.ShowFOV = state
        FOVCircle.Visible = AimbotSettings.Enabled and state
    end
})

MainSec:Toggle({
    Title = "TriggerBot",
    Default = false,
    Callback = function(state)
        AimbotSettings.TriggerBot = state
        if AimbotSettings.Enabled and state then
            SetAimbotState(true)
        end
    end
})

MainSec:Slider({
    Title = "FOV Size",
    Min = 10,
    Max = 600,
    Default = 140,
    Callback = function(value)
        AimbotSettings.FOV = value
        FOVCircle.Radius = value
    end
})

MainSec:Dropdown({
    Title = "HitPart",
    Items = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(value)
        AimbotSettings.HitPart = value
    end
})

Notify("Aimbot", "Module Aimbot chargé et prêt")
