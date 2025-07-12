--// No Clip & Fly GUI Script with Auto Lock Feature (Updated)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoClipFlyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 180)
MainFrame.Position = UDim2.new(0, 20, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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

local function createButton(text, color, yOffset)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 25)
	button.Position = UDim2.new(0, 10, 0, yOffset)
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = color
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 16
	button.Parent = MainFrame
	return button
end

local enableFlyBtn = createButton("Enable Fly", Color3.fromRGB(0, 170, 255), 30)
local disableFlyBtn = createButton("Disable Fly", Color3.fromRGB(170, 0, 0), 60)
local enableNoclipBtn = createButton("Enable No Clip", Color3.fromRGB(0, 170, 0), 90)
local disableNoclipBtn = createButton("Disable No Clip", Color3.fromRGB(170, 0, 0), 120)
local autoLockBtn = createButton("Auto Lock: OFF", Color3.fromRGB(255, 165, 0), 150)

-- Variables
local noclipConnection
local noclipActive = false
local flyActive = false
local flySpeed = 70
local velocity
local gyro
local flyConn
local AutoLock = false

-- Auto Lock Variables
local lockObjects = {}
local autoLockConnection = nil

-- Functions for Auto Lock setup and restore
local function setupObject(obj)
	if not obj:GetAttribute("OriginalPropertiesSaved") then
		obj:SetAttribute("OriginalTransparency", obj.Transparency)
		obj:SetAttribute("OriginalCanCollide", obj.CanCollide)
		obj:SetAttribute("OriginalAnchored", obj.Anchored)
		obj:SetAttribute("OriginalCFrame", obj.CFrame)
		obj:SetAttribute("OriginalPropertiesSaved", true)
	end
	obj.Transparency = 1
	obj.CanCollide = false
	obj.Anchored = false
end

local function restoreObject(obj)
	if obj:GetAttribute("OriginalPropertiesSaved") then
		obj.Transparency = obj:GetAttribute("OriginalTransparency")
		obj.CanCollide = obj:GetAttribute("OriginalCanCollide")
		obj.Anchored = obj:GetAttribute("OriginalAnchored")
		obj.CFrame = obj:GetAttribute("OriginalCFrame")
		obj:SetAttribute("OriginalPropertiesSaved", false)
	end
end

-- No Clip Logic
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
	if flyConn then flyConn:Disconnect() flyConn = nil end
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end
	if velocity then velocity:Destroy() velocity = nil end
	if gyro then gyro:Destroy() gyro = nil end
end

-- Auto Lock Logic (moves LockButton parts to player to trigger lock)
local function toggleAutoLock(state)
	if state then
		autoLockConnection = RunService.Heartbeat:Connect(function()
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj.Name == "LockButton" and obj:IsA("BasePart") then
						if not lockObjects[obj] then
							setupObject(obj)
							lockObjects[obj] = true
						end
						obj.CFrame = character.HumanoidRootPart.CFrame
					end
				end
			end
		end)
	else
		if autoLockConnection then
			autoLockConnection:Disconnect()
			autoLockConnection = nil
		end
		for obj, _ in pairs(lockObjects) do
			if obj and obj.Parent then
				restoreObject(obj)
			end
		end
		lockObjects = {}
	end
end

-- Example Function Trigger: Steal Meme
local function stealMeme()
	print("😂 Meme stolen!") -- Your actual steal logic here
	if AutoLock then
		-- No separate tryAutoLock needed, autoLock runs continuously now
	end
end

-- Button Connections
enableFlyBtn.MouseButton1Click:Connect(enableFly)
disableFlyBtn.MouseButton1Click:Connect(disableFly)
enableNoclipBtn.MouseButton1Click:Connect(enableNoclip)
disableNoclipBtn.MouseButton1Click:Connect(disableNoclip)

-- Auto Lock Toggle Button
autoLockBtn.MouseButton1Click:Connect(function()
	AutoLock = not AutoLock
	autoLockBtn.Text = "Auto Lock: " .. (AutoLock and "ON" or "OFF")
	toggleAutoLock(AutoLock)
end)

-- Example hotkey to trigger stealing a meme (press "M")
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.M then
		stealMeme()
	end
end)
