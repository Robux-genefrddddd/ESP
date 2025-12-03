-- === MODULE AIMBOT ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Aimbot = {}
Aimbot.Enabled = false
Aimbot.TeamCheck = true
Aimbot.WallCheck = true
Aimbot.FOV = 120
Aimbot.ShowFOV = true

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Visible = false

local function IsPlayerValid(Player)
    if not Player or Player == LocalPlayer then return false end
    if not Player.Character then return false end
    
    local Humanoid = Player.Character:FindFirstChild("Humanoid")
    local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not Humanoid or Humanoid.Health <= 0 or not RootPart then return false end
    if Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then return false end
    
    return true
end

local function GetClosestPlayerInFOV()
    if not Aimbot.Enabled then return nil end
    
    local Closest, ClosestDistance = nil, Aimbot.FOV
    local MousePos = UserInputService:GetMouseLocation()

    for _, Player in ipairs(Players:GetPlayers()) do
        if not IsPlayerValid(Player) then continue end

        local Head = Player.Character:FindFirstChild("Head")
        if not Head then continue end

        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
        if not OnScreen then continue end

        if Aimbot.WallCheck then
            local RayParams = RaycastParams.new()
            RayParams.FilterType = Enum.RaycastFilterType.Blacklist
            RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            
            local Ray = workspace:Raycast(Camera.CFrame.Position, Head.Position - Camera.CFrame.Position, RayParams)
            if Ray and not Ray.Instance:IsDescendantOf(Player.Character) then continue end
        end

        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
        if Distance < ClosestDistance then
            ClosestDistance = Distance
            Closest = Head
        end
    end
    return Closest
end

-- Silent Aim avec hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if Aimbot.Enabled and (Method == "FireServer" or Method == "InvokeServer") then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local Target = GetClosestPlayerInFOV()
            if Target then
                for i, v in pairs(Args) do
                    if typeof(v) == "Vector3" then
                        Args[i] = Target.Position
                    elseif typeof(v) == "CFrame" then
                        Args[i] = CFrame.new(Target.Position)
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, unpack(Args))
end)

-- Backup: Si le jeu utilise mouse.Hit
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if Aimbot.Enabled and self:IsA("Mouse") and (key == "Hit" or key == "Target") then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local Target = GetClosestPlayerInFOV()
            if Target then
                if key == "Hit" then
                    return CFrame.new(Target.Position)
                elseif key == "Target" then
                    return Target
                end
            end
        end
    end
    return OldIndex(self, key)
end)

function Aimbot:SetEnabled(v)
    self.Enabled = v
    FOVCircle.Visible = v and self.ShowFOV
end

function Aimbot:SetTeamCheck(v)
    self.TeamCheck = v
end

function Aimbot:SetVisibleCheck(v)
    self.WallCheck = v
end

function Aimbot:SetFOV(v)
    self.FOV = v
    FOVCircle.Radius = v
end

function Aimbot:SetFOVVisible(v)
    self.ShowFOV = v
    FOVCircle.Visible = self.Enabled and v
end

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    if Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = Aimbot.Enabled and Aimbot.ShowFOV
    end
end)

return Aimbot
