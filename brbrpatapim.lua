-- Wait for the player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables
local Speed = 10
local SpeedEnabled = false
local selectedPlayers = {} -- Changed to table for multiple players
local lowGravityEnabled = false
local currentHighlights = {} -- Changed to table for multiple highlights
local playerPanelVisible = false -- Track panel visibility

-- Remove old FartHubUI if it exists
local old = game:GetService("CoreGui"):FindFirstChild("FartHubUI")
if old then old:Destroy() end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FartHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 335)
frame.Position = UDim2.new(0.5, -125, 0.3, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- Player selection frame (side by side)
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(0, 200, 0, 335)
playerFrame.Position = UDim2.new(1, 10, 0, 0)
playerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerFrame.BorderSizePixel = 0
playerFrame.Active = true
playerFrame.Visible = false -- Start hidden
playerFrame.Parent = frame

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

local playerFrameCorner = Instance.new("UICorner", playerFrame)
playerFrameCorner.CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.15, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💨 Fart Hub | Instant Steal"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 16
title.Parent = frame

-- Helper: Create rounded buttons
local function createButton(text, position, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.43, 0, 0.11, 0)
	button.Position = position
	button.Text = text
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.Parent = frame

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)

	return button
end

-- Helper: Create full-width buttons
local function createFullButton(text, position, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.9, 0, 0.11, 0)
	button.Position = position
	button.Text = text
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Parent = frame

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)

	return button
end

-- Buttons (side by side for first row)
local button1 = createButton("💥 tp up gang", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(0, 140, 255))
local lowGravButton = createButton("🌙 Low Grav", UDim2.new(0.52, 0, 0.18, 0), Color3.fromRGB(138, 43, 226))

-- Full width buttons
local button2 = createFullButton("🔧 Use Tools", UDim2.new(0.05, 0, 0.31, 0), Color3.fromRGB(255, 85, 85))
local button3 = createFullButton("⚡ TP Forward", UDim2.new(0.05, 0, 0.44, 0), Color3.fromRGB(85, 255, 85))

-- Speed Box
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0.11, 0)
speedBox.Position = UDim2.new(0.05, 0, 0.57, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.Text = "14"
speedBox.PlaceholderText = "Speed Value"
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Parent = frame

local speedBoxCorner = Instance.new("UICorner", speedBox)
speedBoxCorner.CornerRadius = UDim.new(0, 6)

-- Speed Toggle Button
local speedButton = createFullButton("🔴 Speed OFF", UDim2.new(0.05, 0, 0.70, 0), Color3.fromRGB(128, 0, 128))

-- Dropdown button with toggle functionality
local dropdownButton = createFullButton("👤 Select Players", UDim2.new(0.05, 0, 0.83, 0), Color3.fromRGB(255, 170, 0))

-- Player Frame Title with clear selection button
local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(0.7, 0, 0, 30)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "👥 Players (0 selected)"
playerTitle.TextColor3 = Color3.new(1, 1, 1)
playerTitle.Font = Enum.Font.GothamSemibold
playerTitle.TextSize = 14
playerTitle.Parent = playerFrame

-- Clear selection button
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.25, 0, 0, 25)
clearButton.Position = UDim2.new(0.75, 0, 0, 2.5)
clearButton.Text = "Clear"
clearButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
clearButton.TextColor3 = Color3.new(1, 1, 1)
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 10
clearButton.Parent = playerFrame

local clearCorner = Instance.new("UICorner", clearButton)
clearCorner.CornerRadius = UDim.new(0, 4)

-- Player grid container
local playerContainer = Instance.new("ScrollingFrame")
playerContainer.Size = UDim2.new(1, -10, 1, -40)
playerContainer.Position = UDim2.new(0, 5, 0, 35)
playerContainer.BackgroundTransparency = 1
playerContainer.BorderSizePixel = 0
playerContainer.ScrollBarThickness = 4
playerContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
playerContainer.Parent = playerFrame

local playerGrid = Instance.new("UIGridLayout", playerContainer)
playerGrid.CellSize = UDim2.new(0.45, 0, 0, 35)
playerGrid.CellPadding = UDim2.new(0.05, 0, 0, 5)
playerGrid.SortOrder = Enum.SortOrder.LayoutOrder

-- Function to highlight player's plot
local function highlightPlayerPlot(playerName)
	-- Remove existing highlight for this player
	if currentHighlights[playerName] then
		currentHighlights[playerName]:Destroy()
		currentHighlights[playerName] = nil
	end

	-- Look for a TextLabel that includes the player's name (e.g. "username's base")
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("TextLabel") and descendant.Text:lower():find(playerName:lower()) then
			local base = descendant:FindFirstAncestorOfClass("Model") or descendant.Parent
			if base and base:IsDescendantOf(workspace) then
				-- Add highlight to the base
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 255, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.Adornee = base
				highlight.Parent = base
				currentHighlights[playerName] = highlight
				break
			end
		end
	end
end

-- Function to remove highlight for a player
local function removeHighlight(playerName)
	if currentHighlights[playerName] then
		currentHighlights[playerName]:Destroy()
		currentHighlights[playerName] = nil
	end
end

-- Function to update player title with selection count
local function updatePlayerTitle()
	local count = 0
	for _ in pairs(selectedPlayers) do
		count = count + 1
	end
	playerTitle.Text = "👥 Players (" .. count .. " selected)"
end

-- Function to get closest selected player
local function getClosestSelectedPlayer()
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	
	local myPosition = character.HumanoidRootPart.Position
	local closestPlayer = nil
	local closestDistance = math.huge
	
	for playerName, _ in pairs(selectedPlayers) do
		local targetPlayer = Players:FindFirstChild(playerName)
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (targetPlayer.Character.HumanoidRootPart.Position - myPosition).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestPlayer = targetPlayer
			end
		end
	end
	
	return closestPlayer
end

local function toggleLowGravity()
	lowGravityEnabled = not lowGravityEnabled
	lowGravButton.Text = lowGravityEnabled and "🌙 Low Grav ON" or "🌙 Low Grav OFF"
	lowGravButton.BackgroundColor3 = lowGravityEnabled and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(138, 43, 226)

	local c = character
	if c then
		local h = c:FindFirstChild("Humanoid")
		local r = c:FindFirstChild("HumanoidRootPart")
		if lowGravityEnabled then
			if h then h.JumpHeight = 40 end
			if r then
				local bf = Instance.new("BodyForce", r)
				bf.Name = "LowGravityForce"
				bf.Force = Vector3.new(0, workspace.Gravity * r.AssemblyMass * 0.75, 0)
			end
		else
			if h then h.JumpHeight = 7.2 end
			if r then
				local bf = r:FindFirstChild("LowGravityForce")
				if bf then bf:Destroy() end
			end
		end
	end
end

local function updatePlayerList()
	for _, child in pairs(playerContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.Text = plr.Name
			btn.BackgroundColor3 = selectedPlayers[plr.Name] and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 10
			btn.TextScaled = true
			btn.Parent = playerContainer

			local btnCorner = Instance.new("UICorner", btn)
			btnCorner.CornerRadius = UDim.new(0, 4)

			btn.MouseButton1Click:Connect(function()
				if selectedPlayers[plr.Name] then
					-- Deselect player
					selectedPlayers[plr.Name] = nil
					btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					removeHighlight(plr.DisplayName)
				else
					-- Select player
					selectedPlayers[plr.Name] = plr
					btn.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
					highlightPlayerPlot(plr.DisplayName)
				end
				updatePlayerTitle()
			end)
		end
	end

	task.wait()
	playerContainer.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#Players:GetPlayers() / 2) * 40)
end
updatePlayerList()

Players.PlayerAdded:Connect(updatePlayerList)

Players.PlayerRemoving:Connect(function(plr)
	if selectedPlayers[plr.Name] then
		selectedPlayers[plr.Name] = nil
		removeHighlight(plr.DisplayName)
		updatePlayerTitle()
	end

	task.defer(updatePlayerList)
end)

-- Toggle player panel visibility
dropdownButton.MouseButton1Click:Connect(function()
	playerPanelVisible = not playerPanelVisible
	playerFrame.Visible = playerPanelVisible
	dropdownButton.Text = playerPanelVisible and "❌ Hide Players" or "👤 Select Players"
end)

-- Clear all selections
clearButton.MouseButton1Click:Connect(function()
	selectedPlayers = {}
	for _, highlight in pairs(currentHighlights) do
		if highlight then
			highlight:Destroy()
		end
	end
	currentHighlights = {}
	updatePlayerTitle()
	updatePlayerList()
end)

button1.MouseButton1Click:Connect(function()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(hrp.Position.X, 250, hrp.Position.Z)
	end
end)

lowGravButton.MouseButton1Click:Connect(toggleLowGravity)

button2.MouseButton1Click:Connect(function()
	-- Get closest selected player
	local target = getClosestSelectedPlayer()
	if not target then 
		print("No players selected or no valid targets nearby!")
		return 
	end

	local function waitForTool(toolName)
		while not player.Backpack:FindFirstChild(toolName) do
			task.wait()
		end
		return player.Backpack:FindFirstChild(toolName)
	end

	character:WaitForChild("Humanoid"):UnequipTools()

	local coilCombo = waitForTool("Coil Combo")
	local webSlinger = waitForTool("Web Slinger")
	webSlinger.Parent = character
	coilCombo.Parent = character

	local ohCFrame1 = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.CFrame
	local ohInstance2 = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local ohInstance3 = workspace[player.Name]["Web Slinger"].Handle

	if ohCFrame1 and ohInstance2 and ohInstance3 then
		game:GetService("ReplicatedStorage").Packages.Net["RE/UseItem"]:FireServer(ohCFrame1, ohInstance2, ohInstance3)
		print("Hooking onto closest player: " .. target.Name)
	end
end)

button3.MouseButton1Click:Connect(function()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local forward = hrp.CFrame.LookVector.Unit
		hrp.CFrame = CFrame.new(hrp.Position + forward * 10, hrp.Position + forward * 11)
	end
end)

local function SpeedControl()
	while SpeedEnabled do
		RunService.RenderStepped:Wait()
		if character and character:FindFirstChild("HumanoidRootPart") then
			local MoveDirection = character.Humanoid.MoveDirection
			if MoveDirection.Magnitude > 0 then
				character.HumanoidRootPart.CFrame += MoveDirection * Speed / 10
			end
		end
	end
end

speedButton.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	speedButton.Text = SpeedEnabled and "🟢 Speed ON" or "🔴 Speed OFF"
	if SpeedEnabled then
		SpeedControl()
	end
end)

speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local NewSpeed = tonumber(speedBox.Text)
		if NewSpeed and NewSpeed > 0 then
			Speed = NewSpeed
		else
			speedBox.Text = tostring(Speed)
		end
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	if lowGravityEnabled then
		task.wait(1)
		toggleLowGravity()
		toggleLowGravity()
	end
	if SpeedEnabled then
		SpeedControl()
	end
end)

-- Dragging
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
