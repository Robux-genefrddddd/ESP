-- === MODULE AIMBOT FIXED ===
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

-- Protection pour Drawing API
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = Aimbot.FOV
    FOVCircle.Color = Color3.fromRGB(255, 100, 0)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.Visible = false
end)

local function IsPlayerValid(Player)
    if not Player or Player == LocalPlayer then return false end
    if not Player.Character then return false end
    
    local Humanoid = Player.Character:FindFirstChild("Humanoid")
    local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not Humanoid or Humanoid.Health <= 0 or not RootPart then return false end
    if Aimbot.TeamCheck and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then return false end
    
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

        -- Wall Check avec protection
        if Aimbot.WallCheck then
            local success, result = pcall(function()
                local RayParams = RaycastParams.new()
                RayParams.FilterType = Enum.RaycastFilterType.Blacklist
                RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                
                local Ray = workspace:Raycast(Camera.CFrame.Position, Head.Position - Camera.CFrame.Position, RayParams)
                if Ray and Ray.Instance and not Ray.Instance:IsDescendantOf(Player.Character) then
                    return false
                end
                return true
            end)
            
            if not success or not result then continue end
        end

        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
        if Distance < ClosestDistance then
            ClosestDistance = Distance
            Closest = Head
        end
    end
    return Closest
end

-- Silent Aim avec hook protégé
local OldNamecall
pcall(function()
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
end)

-- Backup: Si le jeu utilise mouse.Hit
local OldIndex
pcall(function()
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
end)

function Aimbot:SetEnabled(v)
    self.Enabled = v
    if FOVCircle then
        FOVCircle.Visible = v and self.ShowFOV
    end
end

function Aimbot:SetTeamCheck(v)
    self.TeamCheck = v
end

function Aimbot:SetVisibleCheck(v)
    self.WallCheck = v
end

function Aimbot:SetFOV(v)
    self.FOV = v
    if FOVCircle then
        FOVCircle.Radius = v
    end
end

function Aimbot:SetFOVVisible(v)
    self.ShowFOV = v
    if FOVCircle then
        FOVCircle.Visible = self.Enabled and v
    end
end

-- Update FOV Circle avec protection
if FOVCircle then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if Aimbot.ShowFOV and FOVCircle then
                FOVCircle.Position = UserInputService:GetMouseLocation()
                FOVCircle.Visible = Aimbot.Enabled and Aimbot.ShowFOV
            end
        end)
    end)
end

return Aimbo
