-- Duplicate Execution Guard (Çift çalışmayı engeller)
if _G.ScriptRunning then
    if _G.UnloadCurrentScript then
        _G.UnloadCurrentScript()
    end
end
_G.ScriptRunning = true

local function detectMobilePlatform()
    local UserInputService = game:GetService("UserInputService")
    local hasTouchScreen = UserInputService.TouchEnabled
    local camera = workspace.CurrentCamera
    local viewportSize = camera and camera.ViewportSize or Vector2.new(0, 0)
    local isSmallScreen = viewportSize.X <= 1024 or viewportSize.Y <= 768
    local hasGyroscope = UserInputService.GyroscopeEnabled or UserInputService.AccelerometerEnabled
    local noKeyboard = not UserInputService.KeyboardEnabled
    
    local isMobile = hasTouchScreen and (noKeyboard or isSmallScreen or hasGyroscope)
    return isMobile
end

local isMobile = detectMobilePlatform()

local function safeHttpGet(url)
    local success, result
    if game.HttpGet then
        success, result = pcall(function() return game:HttpGet(url) end)
        if success then return result end
    end
    if syn and syn.request then
        success, result = pcall(function() return syn.request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end
    if http and http.request then
        success, result = pcall(function() return http.request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end
    if http_request then
        success, result = pcall(function() return http_request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end
    if request then
        success, result = pcall(function() return request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end
    error("Failed to load URL: " .. url)
end

local Rayfield
local loadSuccess = pcall(function()
    Rayfield = loadstring(safeHttpGet('https://sirius.menu/rayfield'))()
end)

if not loadSuccess then
    pcall(function()
        Rayfield = loadstring(safeHttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
    if not Rayfield then
        error("CRITICAL: Could not load UI Library.")
    end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    ESP = {
        Killer = false,
        Survivor = false,
        Generator = false,
        Gate = false,
        Hook = false,
        Pallet = false,
        Window = false,
        Pumpkin = false,
        ShowOnlyClosestHook = false,
        ShowDistance = true,
        MaxDistance = 500
    },
    AutoFeatures = {
        AutoGenerator = false,
        GeneratorMode = "great",
        AutoAttack = false,
        AttackRange = 10
    },
    Performance = {
        UpdateRate = 0.5,
        UseDistanceCulling = true,
        MaxESPObjects = isMobile and 50 or 100,
        DisableParticles = false,
        LowerGraphics = false,
        DisableShadows = false,
        ReduceRenderDistance = false
    },
    Mobile = {
        AutoOptimize = true,
        AggressiveOptimization = false
    }
}

local Highlights = {}
local BillboardGuis = {}
local LastUpdate = 0
local UpdateConnection = nil
local AutoAttackConnection = nil
local AutoGenLoopRunning = true
local FPSCounterEnabled = false
local FPSCounterUI = nil

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Image = 4483362458
        })
    end)
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then return nil end
    return result
end

local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function isKiller()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
end

local function applyMobileOptimizations()
    if not isMobile then return end
    local lighting = game:GetService("Lighting")
    safeCall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        lighting.GlobalShadows = false
        lighting.FogEnd = 100
        lighting.Brightness = 2
        
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        Workspace.StreamingEnabled = true
        Workspace.StreamingMinRadius = 32
        Workspace.StreamingTargetRadius = 64
        if Workspace:FindFirstChild("Terrain") then Workspace.Terrain.Decoration = false end
    end)
end

local function applyAggressiveMobileOptimizations()
    if not isMobile then return end
    applyMobileOptimizations()
    safeCall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EnableFRM = false
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("SurfaceAppearance") then
                obj.Parent = nil
            end
        end
        Config.Performance.UpdateRate = 1.0 
        Config.Performance.MaxESPObjects = 25 
    end)
end

local function applyPerformanceSettings()
    local lighting = game:GetService("Lighting")
    if Config.Performance.DisableParticles then
        safeCall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = false end
            end
        end)
    end
    if Config.Performance.LowerGraphics then
        safeCall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    end
    if Config.Performance.DisableShadows then
        safeCall(function() lighting.GlobalShadows = false lighting.FogEnd = 100 end)
    end
    if Config.Performance.ReduceRenderDistance then
        safeCall(function()
            Workspace.StreamingEnabled = true
            Workspace.StreamingMinRadius = 32
            Workspace.StreamingTargetRadius = 64
        end)
    end
end

local function resetPerformanceSettings()
    local lighting = game:GetService("Lighting")
    safeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = true end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        lighting.GlobalShadows = true
        lighting.FogEnd = 100000
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = true end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 0 end
        end
    end)
end

local function createFPSCounter()
    if FPSCounterUI then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSCounter"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "FPSFrame"
    frame.Size = UDim2.new(0, 120, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 18
    fpsLabel.Parent = frame

    local lastTime = tick()
    local frameCount = 0
    
    local fpsConnection
    fpsConnection = RunService.Heartbeat:Connect(function()
        if not FPSCounterEnabled or not screenGui.Parent then 
            if fpsConnection then fpsConnection:Disconnect() end
            return 
        end
        frameCount = frameCount + 1
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        
        if deltaTime >= 1.0 then
            local fps = math.floor(frameCount / deltaTime)
            frameCount = 0
            lastTime = currentTime
            fpsLabel.Text = string.format("FPS: %d", fps)
        end
    end)
    
    pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    FPSCounterUI = screenGui
    FPSCounterEnabled = true
end

local function removeFPSCounter()
    if FPSCounterUI then
        FPSCounterUI:Destroy()
        FPSCounterUI = nil
        FPSCounterEnabled = false
    end
end

local function getCharacterRootPart()
    if not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function findClosestSurvivor()
    if not isKiller() then return nil, nil end
    local hrp = getCharacterRootPart()
    if not hrp then return nil, nil end
    
    local closestPlayer = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dist = (targetHRP.Position - hrp.Position).Magnitude
                if dist < closestDist and dist <= Config.AutoFeatures.AttackRange then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer, closestDist
end

local function performAutoAttack()
    if not isKiller() then return end
    local target, distance = findClosestSurvivor()
    if not target then return end
    
    safeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("Attacks") and remotes.Attacks:FindFirstChild("BasicAttack") then
            remotes.Attacks.BasicAttack:FireServer(false)
        end
    end)
end

local function startAutoAttack()
    if AutoAttackConnection then return end
    AutoAttackConnection = RunService.Heartbeat:Connect(function()
        if Config.AutoFeatures.AutoAttack then performAutoAttack() end
    end)
end

local function stopAutoAttack()
    if AutoAttackConnection then
        AutoAttackConnection:Disconnect()
        AutoAttackConnection = nil
    end
end

local function createHighlight(obj, color)
    if not validateInstance(obj) or obj:FindFirstChild("H") then return end
    safeCall(function()
        local h = Instance.new("Highlight")
        h.Name = "H"
        h.Adornee = obj
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = obj
        Highlights[obj] = h
    end)
end

local function removeHighlight(obj)
    if Highlights[obj] then
        safeCall(function() if validateInstance(Highlights[obj]) then Highlights[obj]:Destroy() end end)
        Highlights[obj] = nil
    end
    if obj and obj:FindFirstChild("H") then obj.H:Destroy() end
end

local function createLabel(obj, text, color)
    if not validateInstance(obj) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj or nil)
    if not rootPart then return end
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    if Config.Performance.UseDistanceCulling and distance > Config.ESP.MaxDistance then
        if BillboardGuis[obj] then
            safeCall(function() if validateInstance(BillboardGuis[obj]) then BillboardGuis[obj]:Destroy() end end)
            BillboardGuis[obj] = nil
        end
        return
    end
    
    if BillboardGuis[obj] and validateInstance(BillboardGuis[obj]) then
        local textLabel = BillboardGuis[obj]:FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        end
        return
    end
    
    safeCall(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = rootPart
        billboard.Parent = obj
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = color
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextScaled = true
        textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        textLabel.Parent = billboard
        BillboardGuis[obj] = billboard
    end)
end

local function removeLabel(obj)
    if BillboardGuis[obj] then
        safeCall(function() if validateInstance(BillboardGuis[obj]) then BillboardGuis[obj]:Destroy() end end)
        BillboardGuis[obj] = nil
    end
end

local function clearAllESP()
    for obj, _ in pairs(Highlights) do removeHighlight(obj) end
    for obj, _ in pairs(BillboardGuis) do removeLabel(obj) end
    Highlights = {}
    BillboardGuis = {}
end

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
            if player.Team.Name == "Killer" and Config.ESP.Killer then
                createHighlight(player.Character, Color3.fromRGB(255, 0, 0))
                createLabel(player.Character, player.Name .. "\n[KILLER]", Color3.fromRGB(255, 0, 0))
            elseif player.Team.Name == "Survivors" and Config.ESP.Survivor then
                createHighlight(player.Character, Color3.fromRGB(0, 255, 0))
                createLabel(player.Character, player.Name .. "\n[SURVIVOR]", Color3.fromRGB(0, 255, 0))
            else
                removeHighlight(player.Character)
                removeLabel(player.Character)
            end
        end
    end
end

local function updateGeneratorESP()
    if not Config.ESP.Generator then return end
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                createHighlight(obj, Color3.fromRGB(203, 132, 66))
                createLabel(obj, "Generator", Color3.fromRGB(203, 132, 66))
            end
        end
    end)
end

local function updateAllESP()
    local currentTime = tick()
    if currentTime - LastUpdate < Config.Performance.UpdateRate then return end
    LastUpdate = currentTime
    
    updatePlayerESP()
    updateGeneratorESP()
end

local function startESP()
    if UpdateConnection then return end
    UpdateConnection = RunService.Heartbeat:Connect(updateAllESP)
end

local function stopESP()
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end
    clearAllESP()
end

-- UI Initialization
local Window = Rayfield:CreateWindow({
    Name = "System Controller",
    LoadingTitle = "Loading System...",
    LoadingSubtitle = isMobile and "Mobile Mode" or "PC Mode",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "Killer ESP",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value)
        Config.ESP.Killer = Value
        if Value then startESP() end
    end
})

ESPTab:CreateToggle({
    Name = "Survivor ESP",
    CurrentValue = false,
    Flag = "SurvivorESP",
    Callback = function(Value)
        Config.ESP.Survivor = Value
        if Value then startESP() end
    end
})

ESPTab:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        Config.ESP.Generator = Value
        if Value then startESP() end
    end
})

local GameplayTab = Window:CreateTab("Gameplay", 4483362458)

GameplayTab:CreateToggle({
    Name = "Auto Complete Generators",
    CurrentValue = false,
    Flag = "AutoGenerator",
    Callback = function(Value) Config.AutoFeatures.AutoGenerator = Value end
})

GameplayTab:CreateToggle({
    Name = "Auto Attack Nearby Survivors",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        Config.AutoFeatures.AutoAttack = Value
        if Value then startAutoAttack() else stopAutoAttack() end
    end
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateToggle({
    Name = "Show FPS Counter",
    CurrentValue = false,
    Flag = "FPSCounter",
    Callback = function(Value)
        if Value then createFPSCounter() else removeFPSCounter() end
    end
})

local function unloadScript()
    AutoGenLoopRunning = false
    stopESP()
    stopAutoAttack()
    resetPerformanceSettings()
    removeFPSCounter()
    _G.ScriptRunning = nil
    _G.UnloadCurrentScript = nil
    Rayfield:Destroy()
end

_G.UnloadCurrentScript = unloadScript

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = unloadScript
})

-- Auto Generator Task Loop
task.spawn(function()
    while AutoGenLoopRunning do
        task.wait(0.2)
        if Config.AutoFeatures.AutoGenerator then
            safeCall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if not remotes or not remotes:FindFirstChild("Generator") then return end
                local genRemotes = remotes.Generator
                local repairEvent = genRemotes:FindFirstChild("RepairEvent")
                local skillCheckEvent = genRemotes:FindFirstChild("SkillCheckResultEvent")
                if not repairEvent or not skillCheckEvent then return end
                
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        for _, point in ipairs(obj:GetChildren()) do
                            if point.Name:find("GeneratorPoint") then
                                pcall(function()
                                    repairEvent:FireServer(point, true)
                                    skillCheckEvent:FireServer("success", 1, obj, point)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

if isMobile and Config.Mobile.AutoOptimize then
    applyMobileOptimizations()
end
