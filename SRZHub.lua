-- Delta Universal Script GUI (SRZ HUB)
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

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.Size = UDim2.new(0, 100, 1, -30)
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 120, 130)
Sidebar.BorderSizePixel = 0

local UIList = Instance.new("UIListLayout", Sidebar)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Frame
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

local function createSlider(labelText, min, max, callback)
	local label = Instance.new("TextLabel", ContentFrame)
	label.Text = labelText
	label.Size = UDim2.new(0.9, 0, 0, 20)
	label.Position = UDim2.new(0.05, 0, 0, #ContentFrame:GetChildren() * 45)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local slider = Instance.new("TextBox", ContentFrame)
	slider.Size = UDim2.new(0.9, 0, 0, 30)
	slider.Position = UDim2.new(0.05, 0, 0, #ContentFrame:GetChildren() * 45 + 20)
	slider.BackgroundColor3 = Color3.fromRGB(0, 120, 130)
	slider.Text = tostring(min)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.Font = Enum.Font.SourceSans
	slider.TextSize = 18
	slider.BorderSizePixel = 0

	slider.FocusLost:Connect(function()
		local val = tonumber(slider.Text)
		if val then
			val = math.clamp(val, min, max)
			slider.Text = tostring(val)
			callback(val)
		end
	end)
end

-- Fly and Speed Logic
local flyActive = false
local flySpeed = 50
local speedValue = 50

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

		local mobileBtn = Instance.new("TextButton", ScreenGui)
		mobileBtn.Size = UDim2.new(0, 100, 0, 40)
		mobileBtn.Position = UDim2.new(1, -110, 1, -50)
		mobileBtn.Text = "Fly"
		mobileBtn.TextColor3 = Color3.new(1, 1, 1)
		mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 200)
		mobileBtn.Font = Enum.Font.SourceSansBold
		mobileBtn.TextSize = 20
		mobileBtn.BorderSizePixel = 0
		mobileBtn.Draggable = true
		mobileBtn.MouseButton1Click:Connect(toggleFly)
	end)

	createSlider("WalkSpeed (20–200)", 20, 200, function(value)
		speedValue = value
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.WalkSpeed = value end
	end)
end)

-- ESP
createTab("ESP", function()
	clearContent()

	createButton("Enable ESP", function()
		local folder = Instance.new("Folder", game.CoreGui)
		folder.Name = "ESPBoxes"

		local function addESP(player)
			if player == LocalPlayer then return end
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			local esp = Instance.new("BillboardGui")
			esp.Adornee = hrp
			esp.Size = UDim2.new(4, 0, 5, 0)
			esp.AlwaysOnTop = true
			esp.LightInfluence = 0

			local box = Instance.new("Frame", esp)
			box.Size = UDim2.new(1, 0, 1, 0)
			box.BackgroundTransparency = 0.3
			box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			box.BorderSizePixel = 0

			esp.Parent = folder
		end

		for _, p in ipairs(Players:GetPlayers()) do
			addESP(p)
		end

		Players.PlayerAdded:Connect(function(player)
			player.CharacterAdded:Connect(function()
				wait(1)
				addESP(player)
			end)
		end)
	end)
end)

-- Misc (Updated with Infinite Jump + God Mode)
createTab("Misc", function()
	clearContent()

	createButton("Rejoin Server", function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)

	createButton("Enable Infinite Jump", function()
		local enabled = true
		StarterGui:SetCore("SendNotification", {
			Title = "SRZ HUB",
			Text = "Infinite Jump Enabled!",
			Duration = 3
		})

		UserInputService.JumpRequest:Connect(function()
			if enabled then
				local char = LocalPlayer.Character
				local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)
	end)

	createButton("Enable God Mode", function()
		local function applyGodMode()
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local humanoid = char:WaitForChild("Humanoid")

			humanoid.Health = math.huge
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health < math.huge then
					humanoid.Health = math.huge
				end
			end)

			StarterGui:SetCore("SendNotification", {
				Title = "SRZ HUB",
				Text = "God Mode Enabled!",
				Duration = 3
			})
		end

		applyGodMode()
		LocalPlayer.CharacterAdded:Connect(function()
			wait(1)
			applyGodMode()
		end)
	end)
end)

-- Socials
createTab("Socials", function()
	clearContent()

	local function copyToClipboard(text)
		setclipboard(text)
		StarterGui:SetCore("SendNotification", {
			Title = "SRZ HUB";
			Text = "Copied to clipboard!";
			Duration = 3;
		})
	end

	createButton("Copy Discord", function()
		copyToClipboard("https://discord.gg/AUDBcJZWTn")
	end)

	createButton("Copy TikTok", function()
		copyToClipboard("https://www.tiktok.com/@srzfv?_t=ZN-8xWFmviaWRC&_r=1")
	end)
end)

-- Hump Feature
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
		local p = Players:FindFirstChild(nameBox.Text)
		if p and p.Character then
			humping = true
			local amplitude = 1.5
			local speed = 8
			humpConn = RunService.RenderStepped:Connect(function()
				if not humping then return end
				local c = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if c and t then
					local offset = math.sin(tick() * speed) * 0.5
					c.CFrame = t.CFrame * CFrame.new(0, 0, amplitude + offset)
				end
			end)
		end
	end)

	createButton("Stop Humping", function()
		humping = false
		if humpConn then humpConn:Disconnect() end
	end)
end)

-- Load default tab
Sidebar:GetChildren()[2].MouseButton1Click:Wait()
