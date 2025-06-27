-- SRZ HUB - Updated Script
-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DeltaHubEnhanced"
ScreenGui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton", ScreenGui)
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "Toggle Menu"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 206, 209)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.BorderSizePixel = 0
toggleButton.Draggable = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 340)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 155)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

toggleButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

local title = Instance.new("TextLabel", MainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SRZ HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.BorderSizePixel = 0

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.Size = UDim2.new(0, 100, 1, -30)
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 120, 130)
Sidebar.BorderSizePixel = 0

local UIList = Instance.new("UIListLayout", Sidebar)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 100, 0, 30)
ContentFrame.Size = UDim2.new(1, -100, 1, -30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(0, 110, 120)
ContentFrame.BorderSizePixel = 0

local function clearContent()
	for _, v in pairs(ContentFrame:GetChildren()) do
		if v:IsA("GuiObject") then v:Destroy() end
	end
end

local function createTab(name, onClick)
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(0, 180, 190)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.BorderSizePixel = 0
	btn.MouseButton1Click:Connect(onClick)
end

local function createButton(text, callback)
	local btn = Instance.new("TextButton", ContentFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, #ContentFrame:GetChildren() * 45)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(0, 140, 150)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.BorderSizePixel = 0
	btn.MouseButton1Click:Connect(callback)
end

-- Main Tab
local flyActive = false
local flySpeed = 50

createTab("Main", function()
	clearContent()

	createButton("Fly Mode (F or Tap)", function()
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		local function startFly()
			local bv = Instance.new("BodyVelocity", hrp)
			bv.Velocity = Vector3.zero
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Name = "FlyVelocity"

			local flyConn
			flyConn = RunService.RenderStepped:Connect(function()
				if not flyActive then flyConn:Disconnect() return end
				local camCF = workspace.CurrentCamera.CFrame
				bv.Velocity = camCF.LookVector * flySpeed
			end)
		end

		local function toggleFly()
			flyActive = not flyActive
			if flyActive then
				startFly()
			else
				local char = LocalPlayer.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp and hrp:FindFirstChild("FlyVelocity") then
						hrp.FlyVelocity:Destroy()
					end
				end
			end
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
				toggleFly()
			end
		end)
	end)

	createButton("Walk Speed: 100", function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.WalkSpeed = 100 end
	end)
end)

-- ESP Tab
createTab("ESP", function()
	clearContent()

	local espFolder
	local espConnections = {}
	local espEnabled = false

	local function addESP(player)
		if player == LocalPlayer then return end
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart", 3)
		if not hrp then return end

		local esp = Instance.new("BillboardGui")
		esp.Adornee = hrp
		esp.Size = UDim2.new(4, 0, 5, 0)
		esp.AlwaysOnTop = true
		esp.LightInfluence = 0

		local box = Instance.new("Frame", esp)
		box.Size = UDim2.new(1, 0, 1, 0)
		box.BackgroundTransparency = 0.3
		box.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
		box.BorderSizePixel = 0

		esp.Parent = espFolder
	end

	local function enableESP()
		if espEnabled then return end
		espEnabled = true

		espFolder = Instance.new("Folder", game.CoreGui)
		espFolder.Name = "ESPBoxes"

		for _, p in ipairs(Players:GetPlayers()) do
			addESP(p)
			local conn = p.CharacterAdded:Connect(function()
				task.wait(1)
				addESP(p)
			end)
			table.insert(espConnections, conn)
		end
	end

	local function disableESP()
		if not espEnabled then return end
		espEnabled = false

		for _, conn in ipairs(espConnections) do
			conn:Disconnect()
		end
		espConnections = {}

		if espFolder then
			espFolder:Destroy()
			espFolder = nil
		end
	end

	createButton("Enable ESP", enableESP)
	createButton("Disable ESP", disableESP)
end)

-- Misc Tab
createTab("Misc", function()
	clearContent()

	createButton("Rejoin Server", function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)

	createButton("Enable Infinite Jump", function()
		UserInputService.JumpRequest:Connect(function()
			local char = LocalPlayer.Character
			local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end)

	createButton("Enable God Mode", function()
		local function applyGodMode()
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local humanoid = char:WaitForChild("Humanoid")
			humanoid.MaxHealth = 1e9
			humanoid.Health = 1e9

			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health < 1e9 then
					humanoid.Health = 1e9
				end
			end)
		end

		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			applyGodMode()
		end)

		applyGodMode()
	end)
end)

-- Socials
createTab("Socials", function()
	clearContent()
	local function copyToClipboard(text)
		setclipboard(text)
		StarterGui:SetCore("SendNotification", {
			Title = "SRZ HUB",
			Text = "Copied to clipboard!",
			Duration = 3
		})
	end

	createButton("Copy Discord", function()
		copyToClipboard("https://discord.gg/AUDBcJZWTn")
	end)

	createButton("Copy TikTok", function()
		copyToClipboard("https://www.tiktok.com/@srzfv?_t=ZN-8xWFmviaWRC&_r=1")
	end)
end)

-- Hump Tab
createTab("Hump", function()
	clearContent()

	local nameBox = Instance.new("TextBox", ContentFrame)
	nameBox.Size = UDim2.new(0.9, 0, 0, 40)
	nameBox.Position = UDim2.new(0.05, 0, 0, 0)
	nameBox.PlaceholderText = "Enter Player Name"
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.BackgroundColor3 = Color3.fromRGB(0, 150, 160)
	nameBox.Font = Enum.Font.SourceSans
	nameBox.TextSize = 18
	nameBox.BorderSizePixel = 0

	local humping = false
	local humpConn

	createButton("Start Humping", function()
		local targetPlayer = Players:FindFirstChild(nameBox.Text)
		if not targetPlayer or not targetPlayer.Character then
			StarterGui:SetCore("SendNotification", {
				Title = "SRZ HUB",
				Text = "Player not found!",
				Duration = 3
			})
			return
		end

		humping = true

		humpConn = RunService.Heartbeat:Connect(function()
			if not humping then return end
			local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myHRP and targetHRP then
				myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2 + math.sin(tick() * 10) * 0.5)
			end
		end)
	end)

	createButton("Stop Humping", function()
		humping = false
		if humpConn then
			humpConn:Disconnect()
			humpConn = nil
		end
	end)
end)
