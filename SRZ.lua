--// No Clip & Fly GUI Script

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoClipFlyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 100)
MainFrame.Position = UDim2.new(0, 20, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Jet Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "srzs stealer"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local enableFlyBtn = Instance.new("TextButton")
enableFlyBtn.Size = UDim2.new(1, -20, 0, 25)
enableFlyBtn.Position = UDim2.new(0, 10, 0, 30)
enableFlyBtn.Text = "Enable Fly"
enableFlyBtn.TextColor3 = Color3.new(1, 1, 1)
enableFlyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
enableFlyBtn.Font = Enum.Font.SourceSansBold
enableFlyBtn.TextSize = 16
enableFlyBtn.Parent = MainFrame

local disableFlyBtn = Instance.new("TextButton")
disableFlyBtn.Size = UDim2.new(1, -20, 0, 25)
disableFlyBtn.Position = UDim2.new(0, 10, 0, 60)
disableFlyBtn.Text = "Disable Fly"
disableFlyBtn.TextColor3 = Color3.new(1, 1, 1)
disableFlyBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
disableFlyBtn.Font = Enum.Font.SourceSansBold
disableFlyBtn.TextSize = 16
disableFlyBtn.Parent = MainFrame

local enableNoclipBtn = Instance.new("TextButton")
enableNoclipBtn.Size = UDim2.new(1, -20, 0, 25)
enableNoclipBtn.Position = UDim2.new(0, 10, 0, 90)
enableNoclipBtn.Text = "Enable No Clip"
enableNoclipBtn.TextColor3 = Color3.new(1, 1, 1)
enableNoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
enableNoclipBtn.Font = Enum.Font.SourceSansBold
enableNoclipBtn.TextSize = 16
enableNoclipBtn.Parent = MainFrame

local disableNoclipBtn = Instance.new("TextButton")
disableNoclipBtn.Size = UDim2.new(1, -20, 0, 25)
disableNoclipBtn.Position = UDim2.new(0, 10, 0, 120)
disableNoclipBtn.Text = "Disable No Clip"
disableNoclipBtn.TextColor3 = Color3.new(1, 1, 1)
disableNoclipBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
disableNoclipBtn.Font = Enum.Font.SourceSansBold
disableNoclipBtn.TextSize = 16
disableNoclipBtn.Parent = MainFrame

-- Adjust MainFrame height to fit buttons
MainFrame.Size = UDim2.new(0, 180, 0, 150)

-- No Clip Logic
local noclipConnection
local noclipActive = false

local function enableNoclip()
	if noclipActive then return end
	noclipActive = true

	noclipConnection = RunService.RenderStepped:Connect(function()
		local character = LocalPlayer.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function disableNoclip()
	if not noclipActive then return end
	noclipActive = false

	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	local character = LocalPlayer.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end

-- Fly Logic
local flyActive = false
local flySpeed = 70

local velocity
local gyro
local flyConn

local function enableFly()
	if flyActive then return end
	flyActive = true

	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	humanoid.PlatformStand = true

	velocity = Instance.new("BodyVelocity")
	velocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	velocity.Velocity = Vector3.new(0, 0, 0)
	velocity.Parent = hrp

	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
	gyro.P = 3000
	gyro.Parent = hrp

	flyConn = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		local lookVec = cam.CFrame.LookVector

		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude == 0 then
			velocity.Velocity = Vector3.new(0, 0, 0)
		else
			local horizontalVelocity = Vector3.new(moveDir.X, 0, moveDir.Z) * flySpeed
			local verticalVelocity = lookVec.Y * moveDir.Magnitude * flySpeed
			velocity.Velocity = Vector3.new(horizontalVelocity.X, verticalVelocity, horizontalVelocity.Z)
		end

		gyro.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVec)
	end)
end

local function disableFly()
	if not flyActive then return end
	flyActive = false

	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end

	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end

	if velocity then
		velocity:Destroy()
		velocity = nil
	end

	if gyro then
		gyro:Destroy()
		gyro = nil
	end
end

-- Button Connections
enableFlyBtn.MouseButton1Click:Connect(enableFly)
disableFlyBtn.MouseButton1Click:Connect(disableFly)
enableNoclipBtn.MouseButton1Click:Connect(enableNoclip)
disableNoclipBtn.MouseButton1Click:Connect(disableNoclip)
