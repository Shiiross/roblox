--[[
	ScriptStrike ESP + Arayüz
	Konum: StarterPlayer > StarterPlayerScripts (LocalScript)
	Arayüzü açıp kapatma: RightShift veya sağ üstteki "ESP" düğmesi
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Ayarlar
---------------------------------------------------------------------
local Config = {
	Enabled = false,
	Chams = true,
	Names = true,
	Health = true,
	Distance = true,
	TeamMode = "Enemies", -- "Enemies" | "Teammates" | "All"
	MaxDistance = 1000,
	EnemyColor = Color3.fromRGB(255, 70, 70),
	TeamColor = Color3.fromRGB(70, 160, 255),
}

local TEAM_MODES = { "Enemies", "Teammates", "All" }

---------------------------------------------------------------------
-- ESP mantığı
---------------------------------------------------------------------
local espObjects = {} -- [player] = {Highlight, Billboard, Label}

local espFolder = Instance.new("Folder")
espFolder.Name = "ScriptStrikeESP"
espFolder.Parent = PlayerGui

local function isEnemy(player)
	if not player.Team or not LocalPlayer.Team then
		return true
	end
	return player.Team ~= LocalPlayer.Team
end

local function shouldShow(player)
	if Config.TeamMode == "All" then
		return true
	elseif Config.TeamMode == "Enemies" then
		return isEnemy(player)
	else
		return not isEnemy(player)
	end
end

local function destroyEsp(player)
	local o = espObjects[player]
	if o then
		if o.Highlight then o.Highlight:Destroy() end
		if o.Billboard then o.Billboard:Destroy() end
		espObjects[player] = nil
	end
end

local function createEsp(player, character, root)
	destroyEsp(player)

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = espFolder

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPInfo"
	billboard.Adornee = root
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(160, 40)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.Parent = espFolder

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextStrokeTransparency = 0.4
	label.TextColor3 = Color3.new(1, 1, 1)
	label.RichText = true
	label.Parent = billboard

	espObjects[player] = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label,
		Character = character,
	}
end

local function updatePlayer(player, myRoot)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	local visible = Config.Enabled
		and humanoid ~= nil
		and root ~= nil
		and humanoid.Health > 0
		and shouldShow(player)

	local dist = 0
	if visible and myRoot then
		dist = (root.Position - myRoot.Position).Magnitude
		if dist > Config.MaxDistance then
			visible = false
		end
	end

	if not visible then
		destroyEsp(player)
		return
	end

	local o = espObjects[player]
	if not o or o.Character ~= character or not o.Highlight.Parent then
		createEsp(player, character, root)
		o = espObjects[player]
	end

	local color = isEnemy(player) and Config.EnemyColor or Config.TeamColor

	o.Highlight.Enabled = Config.Chams
	o.Highlight.FillColor = color
	o.Highlight.OutlineColor = color

	local parts = {}
	if Config.Names then
		table.insert(parts, player.DisplayName)
	end
	if Config.Health then
		local hp = math.floor(humanoid.Health)
		table.insert(parts, string.format("%d HP", hp))
	end
	if Config.Distance and myRoot then
		table.insert(parts, string.format("[%dm]", math.floor(dist)))
	end

	o.Billboard.Enabled = #parts > 0
	o.Label.Text = table.concat(parts, "  ")
	o.Label.TextColor3 = color
end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.1 then -- saniyede ~10 güncelleme yeterli
		return
	end
	accumulator = 0

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			updatePlayer(player, myRoot)
		end
	end
end)

Players.PlayerRemoving:Connect(destroyEsp)

---------------------------------------------------------------------
-- Arayüz
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptStrikeESPGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local BG = Color3.fromRGB(24, 24, 30)
local PANEL = Color3.fromRGB(36, 36, 46)
local ACCENT = Color3.fromRGB(90, 140, 255)
local OFF = Color3.fromRGB(70, 70, 82)

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(260, 330)
main.Position = UDim2.new(0, 30, 0.5, -165)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Visible = true
main.Parent = gui
corner(main, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = PANEL
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "ScriptStrike  •  ESP"
title.Parent = main
corner(title, 10)

-- Sürükleme
do
	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -20, 1, -48)
list.Position = UDim2.fromOffset(10, 44)
list.BackgroundTransparency = 1
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local order = 0
local function nextOrder()
	order += 1
	return order
end

local function addToggle(text, key)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.LayoutOrder = nextOrder()
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = list
	corner(btn, 8)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.Parent = btn

	local function refresh()
		local on = Config[key]
		btn.Text = text .. ":  " .. (on and "AÇIK" or "KAPALI")
		btn.BackgroundColor3 = on and ACCENT or OFF
	end
	refresh()

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		refresh()
	end)
end

addToggle("ESP", "Enabled")
addToggle("Chams (Siluet)", "Chams")
addToggle("İsimler", "Names")
addToggle("Can", "Health")
addToggle("Mesafe", "Distance")

-- Takım modu düğmesi
do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.LayoutOrder = nextOrder()
	btn.BackgroundColor3 = PANEL
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = list
	corner(btn, 8)

	local function refresh()
		local tr = { Enemies = "Düşmanlar", Teammates = "Takım arkadaşları", All = "Herkes" }
		btn.Text = "Hedef:  " .. tr[Config.TeamMode]
	end
	refresh()

	btn.MouseButton1Click:Connect(function()
		local idx = table.find(TEAM_MODES, Config.TeamMode) or 1
		Config.TeamMode = TEAM_MODES[idx % #TEAM_MODES + 1]
		refresh()
	end)
end

-- Mesafe kaydırıcısı (metin kutusu)
do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 34)
	row.LayoutOrder = nextOrder()
	row.BackgroundColor3 = PANEL
	row.BorderSizePixel = 0
	row.Parent = list
	corner(row, 8)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = "Maks. mesafe"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.35, -8, 0, 24)
	box.Position = UDim2.new(0.65, 0, 0.5, -12)
	box.BackgroundColor3 = OFF
	box.BorderSizePixel = 0
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Text = tostring(Config.MaxDistance)
	box.ClearTextOnFocus = false
	box.Parent = row
	corner(box, 6)

	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then
			Config.MaxDistance = math.clamp(n, 10, 5000)
		end
		box.Text = tostring(Config.MaxDistance)
	end)
end

-- Arayüzü açıp kapatma
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.fromOffset(60, 30)
openBtn.Position = UDim2.new(1, -70, 0, 10)
openBtn.BackgroundColor3 = ACCENT
openBtn.BorderSizePixel = 0
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Text = "ESP"
openBtn.Parent = gui
corner(openBtn, 8)

local function toggleGui()
	main.Visible = not main.Visible
end

openBtn.MouseButton1Click:Connect(toggleGui)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		toggleGui()
	end
end)
