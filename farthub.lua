-- Wait for the player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables
local Speed = 90
local SpeedEnabled = false
local selectedPlayers = {}
local lowGravityEnabled = false
local currentHighlights = {}
local playerPanelVisible = false
local inventoryUIEnabled = false
local inventoryGUIs = {}
local antiRagdollEnabled = false

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
playerFrame.Visible = false
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

local function createFullButton(text, position, color)
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

-- Top row
local button1 = createButton("💥 tp up", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(0, 140, 255))
local lowGravButton = createButton("🌙 Low Grav", UDim2.new(0.52, 0, 0.18, 0), Color3.fromRGB(138, 43, 226))

-- Second row: TP Forward and Highest Value ESP side by side
local button3 = createFullButton("⚡ TP Forward", UDim2.new(0.05, 0, 0.31, 0), Color3.fromRGB(85, 255, 85))
local highestValueButton = createFullButton("💰 ESP", UDim2.new(0.52, 0, 0.31, 0), Color3.fromRGB51, 255, 00))

-- Third row: Use tools and Anti Ragdoll
local button2 = createButton("🔧 Use Tools", UDim2.new(0.05, 0, 0.44, 0), Color3.fromRGB(255, 85, 85))
local antiRagdollButton = createButton("🔴 Anti Ragdoll", UDim2.new(0.52, 0, 0.44, 0), Color3.fromRGB(255, 140, 0))

-- Inventory UI Toggle Button
local inventoryButton = Instance.new("TextButton")
inventoryButton.Size = UDim2.new(0.9, 0, 0.11, 0)
inventoryButton.Position = UDim2.new(0.05, 0, 0.57, 0)
inventoryButton.Text = "🔴 Inventory UI OFF"
inventoryButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
inventoryButton.TextColor3 = Color3.new(1, 1, 1)
inventoryButton.Font = Enum.Font.GothamBold
inventoryButton.TextSize = 14
inventoryButton.Parent = frame
Instance.new("UICorner", inventoryButton).CornerRadius = UDim.new(0, 6)

-- Speed Toggle Button
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0.11, 0)
speedButton.Position = UDim2.new(0.05, 0, 0.70, 0)
speedButton.Text = "🔴 Speed OFF"
speedButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.Font = Enum.Font.GothamBold
speedButton.TextSize = 14
speedButton.Parent = frame
Instance.new("UICorner", speedButton).CornerRadius = UDim.new(0, 6)

-- Dropdown button with toggle functionality
local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(0.9, 0, 0.11, 0)
dropdownButton.Position = UDim2.new(0.05, 0, 0.83, 0)
dropdownButton.Text = "👤 Select Players"
dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.Font = Enum.Font.GothamBold
dropdownButton.TextSize = 14
dropdownButton.Parent = frame
Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 6)

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
Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 4)

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

-- Function to create inventory GUI for a player
local function createInventoryGUI(targetPlayer)
	if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
		return nil
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "InventoryDisplay"
	billboardGui.Adornee = targetPlayer.Character.Head
	billboardGui.Size = UDim2.new(0, 120, 0, 60)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = math.huge
	billboardGui.Parent = targetPlayer.Character.Head

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = billboardGui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = targetPlayer.DisplayName
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 10
	nameLabel.TextScaled = true
	nameLabel.Parent = frame

	local inventoryContainer = Instance.new("Frame")
	inventoryContainer.Size = UDim2.new(1, -4, 0.65, -2)
	inventoryContainer.Position = UDim2.new(0, 2, 0.35, 0)
	inventoryContainer.BackgroundTransparency = 1
	inventoryContainer.Parent = frame

	local inventoryLayout = Instance.new("UIListLayout", inventoryContainer)
	inventoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	inventoryLayout.FillDirection = Enum.FillDirection.Horizontal
	inventoryLayout.Padding = UDim.new(0, 1)

	return billboardGui, inventoryContainer
end

local function updateInventoryDisplay(targetPlayer)
	if not inventoryGUIs[targetPlayer.Name] then return end

	local billboardGui = inventoryGUIs[targetPlayer.Name].gui
	local inventoryContainer = inventoryGUIs[targetPlayer.Name].inventoryContainer
	
	for _, child in pairs(inventoryContainer:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local items = {}
	local equippedItem = nil

	if targetPlayer.Character then
		for _, tool in pairs(targetPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") then
				equippedItem = tool.Name
				table.insert(items, tool.Name)
			end
		end
	end

	if targetPlayer.Backpack then
		for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(items, tool.Name)
			end
		end
	end

	local itemCount = math.max(#items, 1)
	local itemWidth = 35
	local padding = 1
	local minWidth = 120
	local maxWidth = 300
	
	local calculatedWidth = math.max(minWidth, math.min(maxWidth, (itemWidth + padding) * itemCount + 10))
	billboardGui.Size = UDim2.new(0, calculatedWidth, 0, 60)

	for i, itemName in pairs(items) do
		local itemLabel = Instance.new("TextLabel")
		itemLabel.Size = UDim2.new(0, itemWidth, 1, 0)
		itemLabel.Text = itemName
		itemLabel.TextColor3 = (itemName == equippedItem) and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
		itemLabel.BackgroundColor3 = (itemName == equippedItem) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(40, 40, 40)
		itemLabel.BackgroundTransparency = (itemName == equippedItem) and 0.7 or 0.8
		itemLabel.Font = Enum.Font.Gotham
		itemLabel.TextSize = 6
		itemLabel.TextScaled = true
		itemLabel.Parent = inventoryContainer

		local itemCorner = Instance.new("UICorner", itemLabel)
		itemCorner.CornerRadius = UDim.new(0, 2)

		if itemName == equippedItem then
			local stroke = Instance.new("UIStroke", itemLabel)
			stroke.Color = Color3.new(0, 1, 0)
			stroke.Thickness = 1
		end
	end

	if #items == 0 then
		local noItemsLabel = Instance.new("TextLabel")
		noItemsLabel.Size = UDim2.new(1, 0, 1, 0)
		noItemsLabel.Text = "No items"
		noItemsLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
		noItemsLabel.BackgroundTransparency = 1
		noItemsLabel.Font = Enum.Font.Gotham
		noItemsLabel.TextSize = 8
		noItemsLabel.TextScaled = true
		noItemsLabel.Parent = inventoryContainer
		billboardGui.Size = UDim2.new(0, minWidth, 0, 60)
	end
end

local function toggleInventoryUI()
	inventoryUIEnabled = not inventoryUIEnabled
	inventoryButton.Text = inventoryUIEnabled and "🟢 Inventory UI ON" or "🔴 Inventory UI OFF"
	inventoryButton.BackgroundColor3 = inventoryUIEnabled and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 140, 0)

	if inventoryUIEnabled then
		for _, targetPlayer in pairs(Players:GetPlayers()) do
			if targetPlayer ~= player then
				local gui, container = createInventoryGUI(targetPlayer)
				if gui then
					inventoryGUIs[targetPlayer.Name] = {
						gui = gui,
						inventoryContainer = container
					}
					updateInventoryDisplay(targetPlayer)
				end
			end
		end
	else
		for playerName, guiData in pairs(inventoryGUIs) do
			if guiData.gui then
				guiData.gui:Destroy()
			end
		end
		inventoryGUIs = {}
	end
end

local function highlightPlayerPlot(playerName)
	if currentHighlights[playerName] then
		currentHighlights[playerName]:Destroy()
		currentHighlights[playerName] = nil
	end

	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("TextLabel") and descendant.Text:lower():find(playerName:lower()) then
			local base = descendant:FindFirstAncestorOfClass("Model") or descendant.Parent
			if base and base:IsDescendantOf(workspace) then
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

local function removeHighlight(playerName)
	if currentHighlights[playerName] then
		currentHighlights[playerName]:Destroy()
		currentHighlights[playerName] = nil
	end
end

local function updatePlayerTitle()
	local count = 0
	for _ in pairs(selectedPlayers) do
		count = count + 1
	end
	playerTitle.Text = "👥 Players (" .. count .. " selected)"
end

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

function runAntiRagdoll()
    if not (character and character:FindFirstChild("Humanoid")) then return end
    local r = character:FindFirstChild("HumanoidRootPart")
    if r then
        for _, x in ipairs(character:GetDescendants()) do
            if x:IsA("BallSocketConstraint") or x:IsA("HingeConstraint") then
                character.Humanoid.PlatformStand = true
                r.Anchored = true
                task.delay(1, function()
                    if character:FindFirstChild("Humanoid") then character.Humanoid.PlatformStand = false end
                    if character and r then r.Anchored = false end
                end)
                break
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
					selectedPlayers[plr.Name] = nil
					btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					removeHighlight(plr.DisplayName)
				else
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

Players.PlayerAdded:Connect(function(newPlayer)
	updatePlayerList()
	if inventoryUIEnabled and newPlayer ~= player then
		task.wait(1)
		local gui, container = createInventoryGUI(newPlayer)
		if gui then
			inventoryGUIs[newPlayer.Name] = {
				gui = gui,
				inventoryContainer = container
			}
			updateInventoryDisplay(newPlayer)
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if selectedPlayers[plr.Name] then
		selectedPlayers[plr.Name] = nil
		removeHighlight(plr.DisplayName)
		updatePlayerTitle()
	end
	if inventoryGUIs[plr.Name] then
		if inventoryGUIs[plr.Name].gui then
			inventoryGUIs[plr.Name].gui:Destroy()
		end
		inventoryGUIs[plr.Name] = nil
	end
	task.defer(updatePlayerList)
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		if inventoryUIEnabled then
			for playerName, guiData in pairs(inventoryGUIs) do
				local targetPlayer = Players:FindFirstChild(playerName)
				if targetPlayer then
					updateInventoryDisplay(targetPlayer)
				end
			end
		end
	end
end)

inventoryButton.MouseButton1Click:Connect(toggleInventoryUI)

dropdownButton.MouseButton1Click:Connect(function()
	playerPanelVisible = not playerPanelVisible
	playerFrame.Visible = playerPanelVisible
	dropdownButton.Text = playerPanelVisible and "❌ Hide Players" or "👤 Select Players"
end)

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
	local webSlinger = waitForTool("Web Slinger")
	webSlinger.Parent = character

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

local speedLoopThread = nil

local function SpeedControl()
	if speedLoopThread then
		speedLoopThread:Disconnect()
		speedLoopThread = nil
	end

	local Humanoid = character:FindFirstChild("Humanoid")
	local BP = player:FindFirstChild("Backpack")

	if not Humanoid or not BP or not BP:FindFirstChild("Invisibility Cloak") then return end

	Humanoid:EquipTool(BP:WaitForChild("Invisibility Cloak"))
	task.wait(0.1)
	if character:FindFirstChild("Invisibility Cloak") then
		character["Invisibility Cloak"]:Activate()
	end
	task.wait(0.1)
	Humanoid:UnequipTools()
	Humanoid.WalkSpeed = Speed

	speedLoopThread = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if SpeedEnabled and Humanoid.WalkSpeed ~= Speed then
			Humanoid.WalkSpeed = Speed
		end
	end)
end

speedButton.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	speedButton.Text = SpeedEnabled and "🟢 Speed ON" or "🔴 Speed OFF"
	if SpeedEnabled then
		SpeedControl()
	else
		if speedLoopThread then
			speedLoopThread:Disconnect()
			speedLoopThread = nil
		end
		local Humanoid = character and character:FindFirstChild("Humanoid")
		if Humanoid then
			print("Speed OFF")
		end
	end
end)

antiRagdollButton.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    antiRagdollButton.Text = antiRagdollEnabled and "🟢 Anti Ragdoll ON" or "🔴 Anti Ragdoll OFF"
    antiRagdollButton.BackgroundColor3 = antiRagdollEnabled and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 140, 0)
end)

RunService.Heartbeat:Connect(function()
    if antiRagdollEnabled then
        runAntiRagdoll()
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
	if inventoryUIEnabled then
		task.wait(2)
		for _, targetPlayer in pairs(Players:GetPlayers()) do
			if targetPlayer ~= player then
				local gui, container = createInventoryGUI(targetPlayer)
				if gui then
					inventoryGUIs[targetPlayer.Name] = {
						gui = gui,
						inventoryContainer = container
					}
					updateInventoryDisplay(targetPlayer)
				end
			end
		end
	end
end)

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

-- ===== HIGHEST VALUE ESP SCRIPT =====
local suffix = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
local lastESP = {}
local highestValueESPEnabled = false
getgenv().MaxESP = 1

local function toNumber(s)
    local n, suf = string.match(s, "([%d%.]+)%s*([KMBT]?)")
    return (tonumber(n) or 0) * (suffix[suf] or 1)
end

local function clearHighestValueESP()
    for _, entry in pairs(lastESP) do
        local model = workspace:FindFirstChild(entry.name)
        if model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    local h = part:FindFirstChildOfClass("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
        local bb = entry.bb
        if bb then
            bb.AlwaysOnTop = false
            bb.Size = UDim2.new(1, 0, 1, 0)
            bb.MaxDistance = 100
            local price = bb:FindFirstChild("Price")
            local gen   = bb:FindFirstChild("Generation")
            if price then price.Visible = true end
            if gen   then gen.Visible   = true gen.Size = UDim2.new(1,0,0.15,0) end
        end
    end
    lastESP = {}
end

local function updateHighestValueESP()
    clearHighestValueESP()
    local gens = {}
    for _, lbl in ipairs(workspace:FindFirstChild("Plots") and workspace.Plots:GetDescendants() or {}) do
        if lbl:IsA("TextLabel") and lbl.Name == "Generation" then
            local bb = lbl.Parent
            if bb:IsA("BillboardGui") and bb:FindFirstChild("DisplayName") then
                local name = bb.DisplayName.Text
                if workspace:FindFirstChild(name) then
                    table.insert(gens, {name = name, value = toNumber(lbl.Text), bb = bb})
                end
            end
        end
    end
    table.sort(gens, function(a, b) return a.value > b.value end)
    for i = 1, math.min(getgenv().MaxESP, #gens) do
        local entry = gens[i]
        local model = workspace[entry.name]
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and not part:FindFirstChildOfClass("Highlight") then
                local hl = Instance.new("Highlight")
                hl.Adornee = part
                hl.Parent = part
            end
        end
        local bb = entry.bb
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(50, 0, 50, 0)
        bb.MaxDistance = 1000
        local price = bb:FindFirstChild("Price")
        local gen   = bb:FindFirstChild("Generation")
        if price then price.Visible = false end
        if gen   then gen.Visible   = true gen.Size = UDim2.new(0.9, 0, 0.1,0) end
        table.insert(lastESP, entry)
    end
end

highestValueButton.MouseButton1Click:Connect(function()
    highestValueESPEnabled = not highestValueESPEnabled
    highestValueButton.Text = highestValueESPEnabled and "🟢 ESP" or "💰 ESP"
    highestValueButton.BackgroundColor3 = highestValueESPEnabled and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 255, 0)
    if not highestValueESPEnabled then
        clearHighestValueESP()
    end
end)

RunService.Heartbeat:Connect(function()
    if highestValueESPEnabled then
        updateHighestValueESP()
    end
end)
