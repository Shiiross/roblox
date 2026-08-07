--[[
    Made by t1futvct
]]

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
    ESP = { Enabled = true },
    Automation = { AutoSkillCheck = true },
    Visuals = { Fullbright = true },
    Colors = {
        Killer = Color3.fromRGB(255, 60, 60),
        Survivor = Color3.fromRGB(64, 224, 255),
        Generator = Color3.fromRGB(180, 0, 220),
        Gate = Color3.fromRGB(255, 255, 255),
        Pallet = Color3.fromRGB(0, 255, 150),
        Window = Color3.fromRGB(0, 255, 150),
        Hook = Color3.fromRGB(255, 170, 0)
    }
}

local MaskNames = {
    ["richard"] = "Rooster", ["tony"] = "Tiger", ["brandon"] = "Panther",
    ["cobra"] = "Cobra", ["richter"] = "Rat", ["rabbit"] = "Rabbit", ["alex"] = "Chainsaw"
}

local ActiveGenerators = {}
local TouchID = 8822
local RenderConnection = nil
local VisibilityConnection = nil
local IndicatorGui = nil

local function SetupGui()
    if PlayerGui:FindFirstChild("ChasedInds") then 
        PlayerGui:FindFirstChild("ChasedInds"):Destroy() 
    end
    IndicatorGui = Instance.new("ScreenGui")
    IndicatorGui.Name = "ChasedInds"
    IndicatorGui.IgnoreGuiInset = true
    IndicatorGui.DisplayOrder = 999
    IndicatorGui.Parent = PlayerGui
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child and child:IsA("ValueBase") then return child.Value end
    return nil
end

local function ClearPlayerESP(player)
    if IndicatorGui then
        local cLabel = IndicatorGui:FindFirstChild(player.Name .. "_Chased")
        if cLabel then cLabel:Destroy() end
        local kLabel = IndicatorGui:FindFirstChild(player.Name .. "_Killer")
        if kLabel then kLabel:Destroy() end
    end
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bh = hrp:FindFirstChild("BitchHook") if bh then bh:Destroy() end
            local mh = hrp:FindFirstChild("MaskHook") if mh then mh:Destroy() end
        end
        local h = player.Character:FindFirstChild("H") if h then h:Destroy() end
    end
end

local function ApplyHighlight(object, color)
    if not Settings.ESP.Enabled then
        local existing = object:FindFirstChild("H")
        if existing then existing:Destroy() end
        return
    end
    local h = object:FindFirstChild("H") or Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0.1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboardTag(text, color, size, textSize)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size = size or UDim2.new(0, 140, 0, 35)
    
    local label = Instance.new("TextLabel")
    label.Name = "BitchHook"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 11
    label.TextWrapped = true
    label.RichText = true 
    label.Parent = billboard
    return billboard
end

local function ProcessMapObject(obj)
    if not Settings.ESP.Enabled or not obj or not obj.Parent then return end
    
    local lowerName = string.lower(obj.Name)

    if lowerName == "generator" or lowerName == "gen" then
        ApplyHighlight(obj, Settings.Colors.Generator)
        if not table.find(ActiveGenerators, obj) then
            table.insert(ActiveGenerators, obj)
        end
    elseif lowerName == "pallet" or lowerName == "palletwrong" then
        ApplyHighlight(obj, Settings.Colors.Pallet)
    elseif lowerName == "window" then
        ApplyHighlight(obj, Settings.Colors.Window)
    elseif lowerName == "hook" then
        local target = obj:FindFirstChild("Model") or obj
        ApplyHighlight(target, Settings.Colors.Hook)
    elseif lowerName == "gate" or lowerName == "exitgate" then
        ApplyHighlight(obj, Settings.Colors.Gate)
    end
end

local function RefreshMapESP()
    ActiveGenerators = {}
    
    if not Settings.ESP.Enabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local h = obj:FindFirstChild("H")
            if h then h:Destroy() end
            local bh = obj:FindFirstChild("GenBitchHook")
            if bh then bh:Destroy() end
        end
        return
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        ProcessMapObject(obj)
    end
end

-- ESP Aç/Kapat Mantığı
local function ToggleESPState(state)
    if state ~= nil then
        Settings.ESP.Enabled = state
    else
        Settings.ESP.Enabled = not Settings.ESP.Enabled
    end

    RefreshMapESP()

    if not Settings.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            ClearPlayerESP(p)
        end
        local nkLabel = IndicatorGui and IndicatorGui:FindFirstChild("NextKillerDisplay")
        if nkLabel then nkLabel:Destroy() end
        Library:Notify("ESP: KAPALI", 2)
    else
        Library:Notify("ESP: AÇIK", 2)
    end

    -- UI Togglena bilgi gönder (Varsa)
    if Options and Options.MasterESP then
        Options.MasterESP:SetValue(Settings.ESP.Enabled)
    end
end

local function updateNextKillerDisplay()
    if not IndicatorGui or not IndicatorGui.Parent then return end
    local label = IndicatorGui:FindFirstChild("NextKillerDisplay")
    
    if not Settings.ESP.Enabled then
        if label then label:Destroy() end
        return
    end

    local teamName = (LocalPlayer.Team and LocalPlayer.Team.Name:lower()) or ""
    if teamName:find("spectator") or teamName:find("lobby") or teamName == "" then
        if not label then
            label = Instance.new("TextLabel", IndicatorGui)
            label.Name = "NextKillerDisplay"
            label.Size = UDim2.new(0, 220, 0, 30)
            label.Position = UDim2.new(0.5, 0, 0, 45)
            label.AnchorPoint = Vector2.new(0.5, 0)
            label.BackgroundTransparency = 0.5
            label.BackgroundColor3 = Color3.new(0, 0, 0)
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.RichText = true
            label.Text = "Next Killer: Calculating..."
        end
        
        local players = Players:GetPlayers()
        table.sort(players, function(a, b)
            local aA = GetGameValue(a, "AllowKiller") or false
            local bA = GetGameValue(b, "AllowKiller") or false
            if aA ~= bA then return aA == true end
            return (GetGameValue(a, "KillerChance") or 0) > (GetGameValue(b, "KillerChance") or 0)
        end)
        
        local nk = players[1]
        if nk then
            local killerName = (nk == LocalPlayer and "YOU") or tostring(GetGameValue(nk, "SelectedKiller") or nk.Name)
            label.Text = "Next Killer: <font color=\"rgb(255,0,0)\">" .. killerName .. "</font>"
        end
    elseif label then 
        label:Destroy() 
    end
end

local function ProcessPlayerESP(player)
    if not Settings.ESP.Enabled or player == LocalPlayer then
        ClearPlayerESP(player)
        return
    end

    local char = player.Character
    if not char then 
        ClearPlayerESP(player)
        return 
    end

    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end

    local teamName = (player.Team and player.Team.Name:lower()) or ""
    local isKiller = teamName:find("killer") ~= nil

    local color = isKiller and Settings.Colors.Killer or Settings.Colors.Survivor
    local selectedKillerAttr = GetGameValue(player, "SelectedKiller") or GetGameValue(char, "SelectedKiller")

    local dist = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        dist = math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
    end

    local displayName = player.Name
    if isKiller and selectedKillerAttr and tostring(selectedKillerAttr) ~= "" then
        displayName = tostring(selectedKillerAttr)
    end

    local nameText = string.format("%s\n[%dm]", displayName, dist)

    local billboard = rootPart:FindFirstChild("BitchHook")
    if not billboard then
        billboard = CreateBillboardTag(nameText, color)
        billboard.Adornee = rootPart
        billboard.Parent = rootPart
    else
        local lbl = billboard:FindFirstChild("BitchHook")
        if lbl then
            lbl.Text = nameText
            lbl.TextColor3 = color
        end
    end

    ApplyHighlight(char, color)

    local rawMask = GetGameValue(player, "Mask") or GetGameValue(char, "Mask")
    if isKiller and rawMask then
        local maskKey = tostring(rawMask):lower()
        if MaskNames[maskKey] then
            local maskBillboard = rootPart:FindFirstChild("MaskHook")
            if not maskBillboard then
                maskBillboard = CreateBillboardTag(MaskNames[maskKey], Color3.fromRGB(255, 255, 0), UDim2.new(0, 100, 0, 20), 12)
                maskBillboard.Name = "MaskHook"
                maskBillboard.StudsOffset = Vector3.new(0, 3, 0)
                maskBillboard.Adornee = rootPart
                maskBillboard.Parent = rootPart
            end
        end
    else
        local maskBillboard = rootPart:FindFirstChild("MaskHook")
        if maskBillboard then maskBillboard:Destroy() end
    end
end

local function updateGeneratorProgress(generator)
    if not generator or not generator.Parent then return true end
    local billboard = generator:FindFirstChild("GenBitchHook")
    if not Settings.ESP.Enabled then
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H") if h then h:Destroy() end
        return false
    end

    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H") if h then h:Destroy() end
        return true
    end

    local percentStr = string.format("Gen: %.1f%%", percent)
    if not billboard then
        billboard = CreateBillboardTag(percentStr, Settings.Colors.Generator)
        billboard.Name = "GenBitchHook"
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = generator:FindFirstChild("defaultMaterial", true) or generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChild("BitchHook")
        if lbl then lbl.Text = percentStr end
    end
    return false
end

-- Tuş Tetikleme Mantığı
local function TriggerSkillCheckPress()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

    local targetButton = PlayerGui:FindFirstChild("Controls", true) and PlayerGui.Controls:FindFirstChild("action", true)
    if targetButton and targetButton:IsA("GuiObject") then
        local pos = targetButton.AbsolutePosition
        local size = targetButton.AbsoluteSize
        local inset = GuiService:GetGuiInset()
        local cx, cy = pos.X + (size.X/2) + inset.X, pos.Y + (size.Y/2) + inset.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

-- Çoklu (King's Scorch) & 110-118 Derece Hizalamalı Skill Check Dinleyicisi
local function ListenSkillChecks()
    task.spawn(function()
        local prompt = PlayerGui:WaitForChild("SkillCheckPromptGui", 10)
        if not prompt then return end
        local check = prompt:WaitForChild("Check", 10)
        if not check then return end

        local line = check:WaitForChild("Line", 5)
        local goal = check:WaitForChild("Goal", 5)
        if not line or not goal then return end

        if VisibilityConnection then VisibilityConnection:Disconnect() end

        local isPressing = false

        VisibilityConnection = check:GetPropertyChangedSignal("Visible"):Connect(function()
            if Settings.Automation.AutoSkillCheck and check.Visible then
                if RenderConnection then RenderConnection:Disconnect() end
                
                RenderConnection = RunService.RenderStepped:Connect(function()
                    if not check.Visible then
                        if RenderConnection then 
                            RenderConnection:Disconnect() 
                            RenderConnection = nil 
                        end
                        return
                    end

                    local lr = line.Rotation % 360
                    local gr = goal.Rotation % 360
                    
                    local targetStart = (gr + 110) % 360
                    local targetEnd = (gr + 118) % 360

                    local diff = math.abs(lr - targetStart)
                    if diff > 180 then diff = 360 - diff end

                    if not isPressing and ((targetStart > targetEnd and (lr >= targetStart or lr <= targetEnd)) or (lr >= targetStart and lr <= targetEnd) or diff <= 3) then
                        isPressing = true
                        TriggerSkillCheckPress()
                        
                        task.wait(0.08)
                        isPressing = false
                    end
                end)
            elseif RenderConnection then 
                RenderConnection:Disconnect() 
                RenderConnection = nil 
            end
        end)
    end)
end

-- RightAlt Tuş Dinleyicisi
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        ToggleESPState()
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    ProcessMapObject(obj)
end)

RunService.Heartbeat:Connect(function()
    if Settings.Visuals.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end

    updateNextKillerDisplay()

    if Settings.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            ProcessPlayerESP(p)
        end

        for i = #ActiveGenerators, 1, -1 do
            local g = ActiveGenerators[i]
            if updateGeneratorProgress(g) then 
                table.remove(ActiveGenerators, i) 
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        ProcessPlayerESP(p)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        ProcessPlayerESP(p)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    SetupGui()
    task.wait(1)
    ListenSkillChecks()
end)

-- Obsidian UI Sekme ve Butonları
local Window = Library:CreateWindow({
    Title = "Game Utility Hub",
    Footer = "Mobile & PC Uyumlu",
    NotifySide = "Right"
})

local Tabs = {
    ESP = Window:AddTab("ESP", "eye"),
    Automation = Window:AddTab("Auto", "zap"),
    Visuals = Window:AddTab("Visuals", "sun")
}

-- ESP Sekmesi Butonları
local MainESPGroup = Tabs.ESP:AddLeftGroupbox("ESP Ayarları")
MainESPGroup:AddToggle("MasterESP", {
    Text = "Enable ESP",
    Default = Settings.ESP.Enabled,
    Callback = function(v) 
        ToggleESPState(v)
    end
})

-- Auto Sekmesi Butonları
local AutoGroup = Tabs.Automation:AddLeftGroupbox("Otomasyon Ayarları")
AutoGroup:AddToggle("AutoSkillCheckToggle", {
    Text = "Auto Skill Check",
    Default = Settings.Automation.AutoSkillCheck,
    Callback = function(v) 
        Settings.Automation.AutoSkillCheck = v 
    end
})

-- Visuals Sekmesi Butonları
local VisGroup = Tabs.Visuals:AddLeftGroupbox("Görsel Ayarlar")
VisGroup:AddToggle("FullbrightToggle", {
    Text = "Fullbright",
    Default = Settings.Visuals.Fullbright,
    Callback = function(v) 
        Settings.Visuals.Fullbright = v 
    end
})

SetupGui()
RefreshMapESP()
ListenSkillChecks()

Library:Notify("RightAlt: ESP Toggle Aktif!", 4)
