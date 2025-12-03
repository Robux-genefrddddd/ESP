local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Fly = {}
Fly.speed = 50
Fly.enabled = false
Fly._bodyVelocity = nil
Fly._bodyGyro = nil
Fly._connection = nil

local localPlayer = Players.LocalPlayer

local function getCharacter()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    return character, humanoid, root
end

local function stopInternal()
    Fly.enabled = false

    if Fly._connection then
        Fly._connection:Disconnect()
        Fly._connection = nil
    end

    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    if Fly._bodyVelocity then
        Fly._bodyVelocity:Destroy()
        Fly._bodyVelocity = nil
    end

    if Fly._bodyGyro then
        Fly._bodyGyro:Destroy()
        Fly._bodyGyro = nil
    end
end

local function startInternal()
    if Fly.enabled then
        return
    end
    Fly.enabled = true

    local character, humanoid, root = getCharacter()

    humanoid.PlatformStand = true

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = root
    Fly._bodyVelocity = bodyVelocity

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.CFrame = root.CFrame
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.Parent = root
    Fly._bodyGyro = bodyGyro

    Fly._connection = RunService.RenderStepped:Connect(function()
        if not Fly.enabled then
            return
        end

        local currentCharacter = localPlayer.Character
        if not currentCharacter or not currentCharacter.Parent then
            stopInternal()
            return
        end

        local hrp = currentCharacter:FindFirstChild("HumanoidRootPart")
        local hum = currentCharacter:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then
            stopInternal()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector

        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Z) then
            moveDirection += look
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection -= look
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDirection -= right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection += right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection -= Vector3.new(0, 1, 0)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Fly.speed
        end

        Fly._bodyVelocity.Velocity = moveDirection
        Fly._bodyGyro.CFrame = camera.CFrame
    end)
end

function Fly:SetEnabled(enabled)
    if enabled then
        startInternal()
    else
        stopInternal()
    end
end

function Fly:SetSpeed(speed)
    if typeof(speed) == "number" and speed > 0 then
        self.speed = speed
    end
end

return Fly
