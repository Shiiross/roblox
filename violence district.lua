-- Duplicate (Çift çalışma) ve Donma Engelleyici Koruma
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
    
    local executorName = identifyexecutor and identifyexecutor() or "Unknown"
    local isMobileExecutor = executorName:lower():find("delta") or 
                             executorName:lower():find("arceus") or
                             executorName:lower():find("fluxus") or
                             executorName:lower():find("krnl")
    
    local isMobile = hasTouchScreen and (noKeyboard or isSmallScreen or hasGyroscope or isMobileExecutor)
    
    if hasTouchScreen and isMobileExecutor then
        isMobile = true
    end
    
    return isMobile
end

local isMobile = detectMobilePlatform()
local executorName = identifyexecutor and identifyexecutor() or "Unknown"


local function safeHttpGet(url)
    local success, result
    
    if game.HttpGet then
        success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then return result end
    end
    
    if syn and syn.request then
        success, result = pcall(function()
            return syn.request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if http and http.request then
        success, result = pcall(function()
            return http.request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if http_request then
        success, result = pcall(function()
            return http_request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if request then
        success, result = pcall(function()
            return request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    error("Failed to load URL: " .. url)
end


local Rayfield
local loadSuccess, loadError = pcall(function()
    Rayfield = loadstring(safeHttpGet('https://sirius.menu/rayfield'))()
end)

if not loadSuccess then
    warn("Failed to load Rayfield from sirius.menu, trying backup...")
    
    pcall(function()
        Rayfield = loadstring(safeHttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
    
    if not Rayfield then
        error("CRITICAL: Could not load Rayfield UI Library.")
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
        ClosestHook = false,
        ShowOnlyClosestHook = false,
        ShowDistance = true,
        MaxDistance = 500
    },
    AutoFeatures = {
        AutoGenerator = false,
        GeneratorMode = "great",
        AutoLeaveGenerator = false,
        LeaveDistance = 15,
        LeaveKeybind = Enum.KeyCode.Q,
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
        TouchControlsEnabled = isMobile,
        ButtonSize = 80,
        ButtonTransparency = 0.3,
        AutoOptimize = true,
        AggressiveOptimization = false
    }
}


local Highlights = {}
local BillboardGuis = {}
local LastUpdate = 0
local UpdateConnection = nil
local LeaveGeneratorConnection = nil
local AutoAttackConnection = nil
local ClosestHookHighlight = nil
local MobileUI = nil
local FPSCounterEnabled = false
local FPSCounterUI = nil


local function notify(title, content, duration)
    local success = pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Image = 4483362458
        })
    end)
    
    if not success then
        warn(string.format("[%s] %s", title, content))
    end
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end

local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function isKiller()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
end

local function isSurvivor()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
end


local function applyMobileOptimizations()
    if not isMobile then return end
    
    local lighting = game:GetService("Lighting")
    local workspace = Workspace
    
    safeCall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        lighting.GlobalShadows = false
        lighting.FogEnd = 100
        lighting.Brightness = 2
        
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        
        workspace.StreamingEnabled = true
        workspace.StreamingMinRadius = 32
        workspace.StreamingTargetRadius = 64
        
        if workspace:FindFirstChild("Terrain") then
            workspace.Terrain.Decoration = false
        end
        
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end)
end

local function applyAggressiveMobileOptimizations()
    if not isMobile then return end
    
    applyMobileOptimizations()
    
    safeCall(function()
        local workspace = Workspace
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EnableFRM = false
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("SurfaceAppearance") then
                obj.Parent = nil
            end
        end
        
        safeCall(function()
            for _, sound in ipairs(workspace:GetDescendants()) do
                if sound:IsA("Sound") and sound.Name ~= "Music" then
                    sound.Volume = 0
                end
            end
        end)
        
        Config.Performance.UpdateRate = 1.0 
        Config.Performance.MaxESPObjects = 25 
    end)
end

local function applyPerformanceSettings()
    local lighting = game:GetService("Lighting")
    local workspace = Workspace
    
    if Config.Performance.DisableParticles then
        safeCall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj.Enabled = false
                end
            end
        end)
    end
    
    if Config.Performance.LowerGraphics then
        safeCall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end
    
    if Config.Performance.DisableShadows then
        safeCall(function()
            lighting.GlobalShadows = false
            lighting.FogEnd = 100
        end)
    end
    
    if Config.Performance.ReduceRenderDistance then
        safeCall(function()
            workspace.StreamingEnabled = true
            workspace.StreamingMinRadius = 32
            workspace.StreamingTargetRadius = 64
        end)
    end
end

local function resetPerformanceSettings()
    local lighting = game:GetService("Lighting")
    local workspace = Workspace
    
    safeCall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = true
            end
        end
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        lighting.GlobalShadows = true
        lighting.FogEnd = 100000
        
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = true
            end
        end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
    end)
end


local function createMobileControls()
    if not isMobile then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileControls"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local leaveButton = Instance.new("TextButton")
    leaveButton.Name = "LeaveGenerator"
    leaveButton.Size = UDim2.new(0, Config.Mobile.ButtonSize, 0, Config.Mobile.ButtonSize)
    leaveButton.Position = UDim2.new(1, -100, 0.5, -40)
    leaveButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    leaveButton.BackgroundTransparency = Config.Mobile.ButtonTransparency
    leaveButton.Text = "LEAVE"
    leaveButton.TextColor3 = Color3.new(1, 1, 1)
    leaveButton.TextScaled = true
    leaveButton.Font = Enum.Font.GothamBold
    leaveButton.Parent = screenGui
    
    local leaveCorner = Instance.new("UICorner")
    leaveCorner.CornerRadius = UDim.new(0, 10)
    leaveCorner.Parent = leaveButton
    
    leaveButton.MouseButton1Click:Connect(function()
        leaveGenerator()
    end)
    
    local success = pcall(function()
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
    
    if success then
        MobileUI = screenGui
    end
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
    fpsLabel.TextStrokeTransparency = 0
    fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 18
    fpsLabel.Parent = frame
    
    local dragging = false
    local dragInput, mousePos, framePos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    local lastTime = tick()
    local frameCount = 0
    local fps = 0
    
    RunService.Heartbeat:Connect(function()
        if not FPSCounterEnabled then return end
        
        frameCount = frameCount + 1
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        
        if deltaTime >= 1.5 then
            fps = math.floor(frameCount / deltaTime)
            frameCount = 0
            lastTime = currentTime
            
            if fps >= 60 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) 
            elseif fps >= 30 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0) 
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0) 
            end
            
            fpsLabel.Text = string.format("FPS: %d", fps)
        end
    end)
    
    local success = pcall(function()
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
    
    if success then
        FPSCounterUI = screenGui
        FPSCounterEnabled = true
    end
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

local function isNearGenerator()
    local hrp = getCharacterRootPart()
    if not hrp then return false, nil end
    
    local map = Workspace:FindFirstChild("Map")
    if not map then return false, nil end
    
    local nearestGen = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local genPart = obj:FindFirstChildWhichIsA("BasePart")
            if genPart then
                local distance = (genPart.Position - hrp.Position).Magnitude
                if distance < nearestDist then
                    nearestDist = distance
                    nearestGen = obj
                end
            end
        end
    end
    
    if nearestGen and nearestDist <= Config.AutoFeatures.LeaveDistance then
        return true, nearestGen, nearestDist
    end
    
    return false, nil, nil
end

function leaveGenerator()
    local hrp = getCharacterRootPart()
    if not hrp then return false end
    
    local isNear, nearestGen, distance = isNearGenerator()
    if not isNear then
        return false
    end
    
    return false
end

local function startAutoLeaveGenerator()
    if LeaveGeneratorConnection then return end
    
    if not isMobile then
        LeaveGeneratorConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Config.AutoFeatures.LeaveKeybind then
                leaveGenerator()
            end
        end)
    end
end

local function stopAutoLeaveGenerator()
    if LeaveGeneratorConnection then
        LeaveGeneratorConnection:Disconnect()
        LeaveGeneratorConnection = nil
    end
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
        if remotes then
            local attacks = remotes:FindFirstChild("Attacks")
            if attacks then
                local basicAttack = attacks:FindFirstChild("BasicAttack")
                if basicAttack then
                    basicAttack:FireServer(false)
                end
            end
        end
    end)
end

local function startAutoAttack()
    if AutoAttackConnection then return end
    
    if not isKiller() then
        return
    end
    
    AutoAttackConnection = RunService.Heartbeat:Connect(function()
        if Config.AutoFeatures.AutoAttack then
            performAutoAttack()
        end
    end)
end

local function stopAutoAttack()
    if AutoAttackConnection then
        AutoAttackConnection:Disconnect()
        AutoAttackConnection = nil
    end
end


local function createHighlight(obj, color)
    if not validateInstance(obj) then return end
    if obj:FindFirstChild("H") then return end
    
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
        safeCall(function()
            if validateInstance(Highlights[obj]) then
                Highlights[obj]:Destroy()
            end
        end)
        Highlights[obj] = nil
    end
    
    local existingH = obj:FindFirstChild("H")
    if existingH then
        existingH:Destroy()
    end
end

local function createLabel(obj, text, color)
    if not validateInstance(obj) then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj or nil)
    if not rootPart then return end
    
    local playerRoot = LocalPlayer.Character.HumanoidRootPart
    local distance = (playerRoot.Position - rootPart.Position).Magnitude
    
    if Config.Performance.UseDistanceCulling and distance > Config.ESP.MaxDistance then
        if BillboardGuis[obj] then
            safeCall(function()
                if validateInstance(BillboardGuis[obj]) then
                    BillboardGuis[obj]:Destroy()
                end
            end)
            BillboardGuis[obj] = nil
        end
        return
    end
    
    if BillboardGuis[obj] and validateInstance(BillboardGuis[obj]) then
        local textLabel = BillboardGuis[obj]:FindFirstChild("TextLabel")
        if textLabel and Config.ESP.ShowDistance then
            textLabel.Text = string.format("%s\n%.0fm", text, distance)
        elseif textLabel then
            textLabel.Text = text
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
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextScaled = true
        textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        textLabel.Parent = billboard
        
        BillboardGuis[obj] = billboard
    end)
end

local function removeLabel(obj)
    if BillboardGuis[obj] then
        safeCall(function()
            if validateInstance(BillboardGuis[obj]) then
                BillboardGuis[obj]:Destroy()
            end
        end)
        BillboardGuis[obj] = nil
    end
end

local function clearAllESP()
    for obj, h in pairs(Highlights) do
        removeHighlight(obj)
    end
    for obj, gui in pairs(BillboardGuis) do
        removeLabel(obj)
    end
    Highlights = {}
    BillboardGuis = {}
end


local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
            local teamName = player.Team.Name
            
            if teamName == "Killer" and Config.ESP.Killer then
                createHighlight(player.Character, Color3.fromRGB(255, 0, 0))
                createLabel(player.Character, player.Name .. "\n[KILLER]", Color3.fromRGB(255, 0, 0))
            elseif teamName == "Survivors" and Config.ESP.Survivor then
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

local function updateGateESP()
    if not Config.ESP.Gate then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gate" then
                createHighlight(obj, Color3.fromRGB(255, 255, 255))
                createLabel(obj, "Gate", Color3.fromRGB(255, 255, 255))
            end
        end
    end)
end

local function updateHookESP()
    if not Config.ESP.Hook then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        if Config.ESP.ShowOnlyClosestHook then
            local hrp = getCharacterRootPart()
            if not hrp then return end
            
            local closestHook = nil
            local closestDist = math.huge
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    local hookPart = obj:FindFirstChildWhichIsA("BasePart")
                    if hookPart then
                        local dist = (hookPart.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestHook = obj
                        end
                    end
                end
            end
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    removeHighlight(obj)
                    removeLabel(obj)
                end
            end
            
            if closestHook then
                if closestHook:FindFirstChild("Model") then
                    for _, part in ipairs(closestHook.Model:GetDescendants()) do
                        if part:IsA("MeshPart") then
                            createHighlight(part, Color3.fromRGB(255, 255, 0))
                        end
                    end
                end
                createLabel(closestHook, "CLOSEST HOOK", Color3.fromRGB(255, 255, 0))
            end
        else
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    if obj:FindFirstChild("Model") then
                        for _, part in ipairs(obj.Model:GetDescendants()) do
                            if part:IsA("MeshPart") then
                                createHighlight(part, Color3.fromRGB(255, 0, 0))
                            end
                        end
                    end
                    createLabel(obj, "Hook", Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end)
end

local function updatePalletESP()
    if not Config.ESP.Pallet then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Palletwrong" then
                createHighlight(obj, Color3.fromRGB(255, 255, 0))
                createLabel(obj, "Pallet", Color3.fromRGB(255, 255, 0))
            end
        end
    end)
end

local function updateWindowESP()
    if not Config.ESP.Window then return end
    
    safeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Window" then
                createHighlight(obj, Color3.fromRGB(173, 216, 230))
                createLabel(obj, "Window", Color3.fromRGB(173, 216, 230))
            end
        end
    end)
end

local function updatePumpkinESP()
    if not Config.ESP.Pumpkin then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        local pumpkins = map:FindFirstChild("Pumpkins")
        if not pumpkins then return end
        
        for _, obj in ipairs(pumpkins:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("Pumpkin") then
                createHighlight(obj, Color3.fromRGB(255, 140, 0))
                createLabel(obj, "Pumpkin", Color3.fromRGB(255, 140, 0))
            end
        end
    end)
end

local function updateAllESP()
    local currentTime = tick()
    if currentTime - LastUpdate < Config.Performance.UpdateRate then return end
    LastUpdate = currentTime
    
    local espCount = 0
    local maxObjects = Config.Performance.MaxESPObjects
    
    for obj, h in pairs(Highlights) do
        if not validateInstance(obj) or not validateInstance(h) then
            Highlights[obj] = nil
        else
            espCount = espCount + 1
        end
    end
    
    for obj, gui in pairs(BillboardGuis) do
        if not validateInstance(obj) or not validateInstance(gui) then
            BillboardGuis[obj] = nil
        end
    end
    
    if espCount >= maxObjects then
        return
    end
    
    updatePlayerESP()
    updateGeneratorESP()
    updateGateESP()
    updateHookESP()
    updatePalletESP()
    updateWindowESP()
    updatePumpkinESP()
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


local Window = Rayfield:CreateWindow({
    Name = "Violence District Interface",
    LoadingTitle = "Loading System...",
    LoadingSubtitle = isMobile and "Mobile Mode" or "PC Mode",
    ConfigurationSaving = {
        Enabled = false, 
        FolderName = nil,
        FileName = "ViolenceDistrictConfig"
    },
    Discord = {
        Enabled = false, 
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})


local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Killer ESP (Red)",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value)
        Config.ESP.Killer = Value
        if Value then
            startESP()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Team and player.Team.Name == "Killer" then
                    removeHighlight(player.Character)
                    removeLabel(player.Character)
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Survivor ESP (Green)",
    CurrentValue = false,
    Flag = "SurvivorESP",
    Callback = function(Value)
        Config.ESP.Survivor = Value
        if Value then
            startESP()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Team and player.Team.Name == "Survivors" then
                    removeHighlight(player.Character)
                    removeLabel(player.Character)
                end
            end
        end
    end
})

ESPTab:CreateSection("Object ESP")

ESPTab:CreateToggle({
    Name = "Generator ESP (Orange)",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        Config.ESP.Generator = Value
        if Value then
            startESP()
        else
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        removeHighlight(obj)
                        removeLabel(obj)
                    end
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Gate ESP (White)",
    CurrentValue = false,
    Flag = "GateESP",
    Callback = function(Value)
        Config.ESP.Gate = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Hook ESP (Red)",
    CurrentValue = false,
    Flag = "HookESP",
    Callback = function(Value)
        Config.ESP.Hook = Value
        if Value then
            startESP()
        else
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Hook" then
                        removeHighlight(obj)
                        removeLabel(obj)
                    end
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Only Closest Hook",
    CurrentValue = false,
    Flag = "ShowOnlyClosestHook",
    Callback = function(Value)
        Config.ESP.ShowOnlyClosestHook = Value
        
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    removeHighlight(obj)
                    removeLabel(obj)
                end
            end
        end
        
        if Config.ESP.Hook then
            updateHookESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Pallet ESP (Yellow)",
    CurrentValue = false,
    Flag = "PalletESP",
    Callback = function(Value)
        Config.ESP.Pallet = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Window ESP (Light Blue)",
    CurrentValue = false,
    Flag = "WindowESP",
    Callback = function(Value)
        Config.ESP.Window = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Pumpkin ESP (Orange)",
    CurrentValue = false,
    Flag = "PumpkinESP",
    Callback = function(Value)
        Config.ESP.Pumpkin = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateSection("Settings")

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(Value)
        Config.ESP.ShowDistance = Value
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 1000},
    Increment = 50,
    CurrentValue = 500,
    Flag = "MaxDistance",
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end
})

ESPTab:CreateSlider({
    Name = "Update Rate (seconds)",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "UpdateRate",
    Callback = function(Value)
        Config.Performance.UpdateRate = Value
    end
})

ESPTab:CreateSlider({
    Name = "Max ESP Objects",
    Range = {25, 500},
    Increment = 25,
    CurrentValue = isMobile and 50 or 100,
    Flag = "MaxESPObjects",
    Callback = function(Value)
        Config.Performance.MaxESPObjects = Value
    end
})


local GameplayTab = Window:CreateTab("Gameplay", 4483362458)
GameplayTab:CreateSection("Auto Features")

GameplayTab:CreateToggle({
    Name = "Auto Complete Generators",
    CurrentValue = false,
    Flag = "AutoGenerator",
    Callback = function(Value)
        Config.AutoFeatures.AutoGenerator = Value
    end
})

GameplayTab:CreateDropdown({
    Name = "Generator Mode",
    Options = {"Great (Fast)", "Normal (Slow)"},
    CurrentOption = "Great (Fast)",
    Flag = "GeneratorMode",
    Callback = function(Option)
        if Option == "Great (Fast)" then
            Config.AutoFeatures.GeneratorMode = "great"
        else
            Config.AutoFeatures.GeneratorMode = "normal"
        end
    end
})

GameplayTab:CreateSection("Quick Escape")

GameplayTab:CreateToggle({
    Name = "Enable Quick Leave Generator",
    CurrentValue = false,
    Flag = "AutoLeaveGenerator",
    Callback = function(Value)
        Config.AutoFeatures.AutoLeaveGenerator = Value
        if Value then
            startAutoLeaveGenerator()
        else
            stopAutoLeaveGenerator()
        end
    end
})

if not isMobile then
    GameplayTab:CreateDropdown({
        Name = "Leave Generator Keybind",
        Options = {"Q", "E", "F", "G", "X", "Z", "V", "B"},
        CurrentOption = "Q",
        Flag = "LeaveKeybind",
        Callback = function(Option)
            local keyMap = {
                ["Q"] = Enum.KeyCode.Q,
                ["E"] = Enum.KeyCode.E,
                ["F"] = Enum.KeyCode.F,
                ["G"] = Enum.KeyCode.G,
                ["X"] = Enum.KeyCode.X,
                ["Z"] = Enum.KeyCode.Z,
                ["V"] = Enum.KeyCode.V,
                ["B"] = Enum.KeyCode.B
            }
            
            Config.AutoFeatures.LeaveKeybind = keyMap[Option]
            
            if Config.AutoFeatures.AutoLeaveGenerator then
                stopAutoLeaveGenerator()
                startAutoLeaveGenerator()
            end
        end
    })
end

GameplayTab:CreateSlider({
    Name = "Detection Range (studs)",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "LeaveDistance",
    Callback = function(Value)
        Config.AutoFeatures.LeaveDistance = Value
    end
})

GameplayTab:CreateButton({
    Name = "Leave Generator Now",
    Callback = function()
        leaveGenerator()
    end
})

GameplayTab:CreateSection("Manual Actions")

GameplayTab:CreateButton({
    Name = "Complete All Generators (Instant)",
    Callback = function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then return end
            
            local genRemotes = remotes:FindFirstChild("Generator")
            if not genRemotes then return end
            
            local repairEvent = genRemotes:FindFirstChild("RepairEvent")
            local skillCheckEvent = genRemotes:FindFirstChild("SkillCheckResultEvent")
            
            if not repairEvent or not skillCheckEvent then return end
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Generator" then
                    for _, point in ipairs(obj:GetChildren()) do
                        if point.Name:find("GeneratorPoint") then
                            pcall(function()
                                for i = 1, 10 do
                                    repairEvent:FireServer(point, true)
                                    skillCheckEvent:FireServer("success", 1, obj, point)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
})

GameplayTab:CreateSection("Killer Powers")

GameplayTab:CreateToggle({
    Name = "Auto Attack Nearby Survivors",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        Config.AutoFeatures.AutoAttack = Value
        if Value then
            startAutoAttack()
        else
            stopAutoAttack()
        end
    end
})

GameplayTab:CreateSlider({
    Name = "Auto Attack Range (studs)",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AttackRange",
    Callback = function(Value)
        Config.AutoFeatures.AttackRange = Value
    end
})

GameplayTab:CreateButton({
    Name = "Activate Killer Power",
    Callback = function()
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local killerRemotes = remotes:FindFirstChild("Killers")
                if killerRemotes then
                    local killerFolder = killerRemotes:FindFirstChild("Killer")
                    if killerFolder then
                        local activatePower = killerFolder:FindFirstChild("ActivatePower")
                        if activatePower then
                            activatePower:FireServer()
                        end
                    end
                end
            end
        end)
    end
})

GameplayTab:CreateButton({
    Name = "Basic Attack (Killer)",
    Callback = function()
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local attacks = remotes:FindFirstChild("Attacks")
                if attacks then
                    local basicAttack = attacks:FindFirstChild("BasicAttack")
                    if basicAttack then
                        basicAttack:FireServer(false)
                    end
                end
            end
        end)
    end
})


local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Performance Options")

SettingsTab:CreateToggle({
    Name = "Disable Particles & Effects",
    CurrentValue = false,
    Flag = "DisableParticles",
    Callback = function(Value)
        Config.Performance.DisableParticles = Value
        applyPerformanceSettings()
    end
})

SettingsTab:CreateToggle({
    Name = "Lower Graphics Quality",
    CurrentValue = false,
    Flag = "LowerGraphics",
    Callback = function(Value)
        Config.Performance.LowerGraphics = Value
        applyPerformanceSettings()
    end
})

SettingsTab:CreateToggle({
    Name = "Disable Shadows",
    CurrentValue = false,
    Flag = "DisableShadows",
    Callback = function(Value)
        Config.Performance.DisableShadows = Value
        applyPerformanceSettings()
    end
})

SettingsTab:CreateToggle({
    Name = "Reduce Render Distance",
    CurrentValue = false,
    Flag = "ReduceRenderDistance",
    Callback = function(Value)
        Config.Performance.ReduceRenderDistance = Value
        applyPerformanceSettings()
    end
})

SettingsTab:CreateToggle({
    Name = "Use Distance Culling (ESP)",
    CurrentValue = true,
    Flag = "UseDistanceCulling",
    Callback = function(Value)
        Config.Performance.UseDistanceCulling = Value
    end
})

SettingsTab:CreateButton({
    Name = "Apply All Performance Boosts",
    Callback = function()
        Config.Performance.DisableParticles = true
        Config.Performance.LowerGraphics = true
        Config.Performance.DisableShadows = true
        Config.Performance.ReduceRenderDistance = true
        Config.Performance.UseDistanceCulling = true
        applyPerformanceSettings()
    end
})

SettingsTab:CreateButton({
    Name = "Reset Performance Settings",
    Callback = function()
        Config.Performance.DisableParticles = false
        Config.Performance.LowerGraphics = false
        Config.Performance.DisableShadows = false
        Config.Performance.ReduceRenderDistance = false
        resetPerformanceSettings()
    end
})

if isMobile then
    SettingsTab:CreateSection("Mobile Controls")
    
    SettingsTab:CreateToggle({
        Name = "Enable Touch Controls",
        CurrentValue = true,
        Flag = "TouchControls",
        Callback = function(Value)
            Config.Mobile.TouchControlsEnabled = Value
            if Value and not MobileUI then
                createMobileControls()
            elseif not Value and MobileUI then
                MobileUI:Destroy()
                MobileUI = nil
            end
        end
    })
    
    SettingsTab:CreateSlider({
        Name = "Button Size",
        Range = {60, 120},
        Increment = 10,
        CurrentValue = 80,
        Flag = "ButtonSize",
        Callback = function(Value)
            Config.Mobile.ButtonSize = Value
            if MobileUI then
                MobileUI:Destroy()
                createMobileControls()
            end
        end
    })
    
    SettingsTab:CreateSlider({
        Name = "Button Transparency",
        Range = {0, 0.8},
        Increment = 0.1,
        CurrentValue = 0.3,
        Flag = "ButtonTransparency",
        Callback = function(Value)
            Config.Mobile.ButtonTransparency = Value
            if MobileUI then
                for _, button in ipairs(MobileUI:GetChildren()) do
                    if button:IsA("TextButton") then
                        button.BackgroundTransparency = Value
                    end
                end
            end
        end
    })
    
    SettingsTab:CreateSection("Mobile Performance Boost")
    
    SettingsTab:CreateToggle({
        Name = "Auto Mobile Optimization",
        CurrentValue = true,
        Flag = "AutoOptimize",
        Callback = function(Value)
            Config.Mobile.AutoOptimize = Value
            if Value then
                applyMobileOptimizations()
            else
                resetPerformanceSettings()
            end
        end
    })
    
    SettingsTab:CreateToggle({
        Name = "ULTRA Performance Mode (Aggressive)",
        CurrentValue = false,
        Flag = "AggressiveOptimization",
        Callback = function(Value)
            Config.Mobile.AggressiveOptimization = Value
            if Value then
                applyAggressiveMobileOptimizations()
            else
                resetPerformanceSettings()
                if Config.Mobile.AutoOptimize then
                    applyMobileOptimizations()
                end
            end
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Apply All Mobile Optimizations NOW",
        Callback = function()
            Config.Performance.DisableParticles = true
            Config.Performance.LowerGraphics = true
            Config.Performance.DisableShadows = true
            Config.Performance.ReduceRenderDistance = true
            Config.Performance.UseDistanceCulling = true
            Config.Performance.UpdateRate = 1.0
            Config.Performance.MaxESPObjects = 25
            
            applyAggressiveMobileOptimizations()
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Reset All Optimizations",
        Callback = function()
            Config.Performance.DisableParticles = false
            Config.Performance.LowerGraphics = false
            Config.Performance.DisableShadows = false
            Config.Performance.ReduceRenderDistance = false
            Config.Performance.UpdateRate = 0.5
            Config.Performance.MaxESPObjects = 50
            Config.Mobile.AutoOptimize = false
            Config.Mobile.AggressiveOptimization = false
            
            resetPerformanceSettings()
        end
    })
end

SettingsTab:CreateSection("Display Options")

SettingsTab:CreateToggle({
    Name = "Show FPS Counter",
    CurrentValue = false,
    Flag = "FPSCounter",
    Callback = function(Value)
        if Value then
            createFPSCounter()
        else
            removeFPSCounter()
        end
    end
})

SettingsTab:CreateSection("Script Controls")

SettingsTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        clearAllESP()
    end
})

SettingsTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        clearAllESP()
        updateAllESP()
    end
})

local function unloadScript()
    stopESP()
    clearAllESP()
    stopAutoLeaveGenerator()
    stopAutoAttack()
    resetPerformanceSettings()
    removeFPSCounter()
    if MobileUI then
        MobileUI:Destroy()
    end
    _G.ScriptRunning = nil
    _G.UnloadCurrentScript = nil
    Rayfield:Destroy()
end

_G.UnloadCurrentScript = unloadScript

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        unloadScript()
    end
})


task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoFeatures.AutoGenerator then
            safeCall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if not remotes then return end
                
                local genRemotes = remotes:FindFirstChild("Generator")
                if not genRemotes then return end
                
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
                                    
                                    local result = Config.AutoFeatures.GeneratorMode == "great" and "success" or "neutral"
                                    local value = Config.AutoFeatures.GeneratorMode == "great" and 1 or 0
                                    skillCheckEvent:FireServer(result, value, obj, point)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)


if isMobile then
    task.wait(1)
    createMobileControls()
    
    if Config.Mobile.AutoOptimize then
        task.wait(0.5)
        applyMobileOptimizations()
    end
end
