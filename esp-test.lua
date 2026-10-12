if not game:IsLoaded() then
    game.Loaded:Wait()
end

pcall(function() setfflag("AdornShadingAPI", "true") end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- ESP Yapılandırma Ayarları
_G.Config = {
    Esp = true, 
    EspBoxes = true, 
    EspNames = true, 
    EspHealthBar = true, 
    EspDistance = true, 
    EspTracers = false,  
    EspHeadDot = true,
    EspWeapon = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    DistColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    WeaponColor = Color3.fromRGB(255, 255, 255),
    EnemyColor = Color3.fromRGB(150, 200, 60),
    TeammateColor = Color3.fromRGB(60, 150, 200),
    EspTeamMode = "Enemies", -- "Enemies", "Teammates", "All"
    UseTeamCheck = false,
    EspChams = false,
    ChamHiddenColor = Color3.fromRGB(255, 0, 0),
}

-- Takım Kontrolü
local function isEnemy(p)
    if not p or not p.Character then return false end
    if not _G.Config.UseTeamCheck then return true end
    if p == LocalPlayer then return false end 
    local LPTeamFolder = LocalPlayer.Character and LocalPlayer.Character.Parent
    local PlayerTeamFolder = p.Character.Parent
    if LocalPlayer.Team and p.Team then
        return LocalPlayer.Team ~= p.Team
    elseif LPTeamFolder and PlayerTeamFolder and LPTeamFolder.Name ~= "Players" then
         return LPTeamFolder ~= PlayerTeamFolder
    end
    return true 
end

local ESP_Table = {}

local function SetAllVisible(data, val)
    if not data then return end
    for k, d in pairs(data) do
        if typeof(d) == "Instance" then
            if d:IsA("BillboardGui") then 
                d.Enabled = val 
            end
        elseif d.Visible ~= nil then 
             pcall(function() d.Visible = val end)
        end
    end
end

local function RemoveEsp(p)
    if ESP_Table[p] then
        for _, d in pairs(ESP_Table[p]) do 
            if typeof(d) == "Instance" then
                d:Destroy()
            elseif d.Remove then
                d:Remove()
            end
        end
        ESP_Table[p] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveEsp)

-- Ana ESP Çizim Döngüsü
RunService.RenderStepped:Connect(function()
    pcall(function() 
        if not Camera then Camera = workspace.CurrentCamera end
        if not Camera then return end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local data = ESP_Table[p]
            local character = p.Character
            if not character or not character.Parent then
                if data then RemoveEsp(p) end
                continue
            end
            local root = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            local isValid = (root and humanoid and head and humanoid.Health > 0)
            
            if not isValid or not _G.Config.Esp then
                if data then SetAllVisible(data, false) end
                if not isValid and data then RemoveEsp(p) end 
                continue
            end
            
            local is_enemy = isEnemy(p)
            local shouldDraw = false
            if _G.Config.EspTeamMode == "All" then shouldDraw = true
            elseif _G.Config.EspTeamMode == "Enemies" and is_enemy then shouldDraw = true
            elseif _G.Config.EspTeamMode == "Teammates" and not is_enemy then shouldDraw = true
            end
            
            if not shouldDraw then
                if data then SetAllVisible(data, false) end
                continue
            end
            
            if not data then
                ESP_Table[p] = {
                    BoxOutline = Drawing.new("Square"),
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text"),
                    HealthBarOutline = Drawing.new("Square"),
                    HealthBar = Drawing.new("Square"),
                    DistanceText = Drawing.new("Text"),
                    Tracer = Drawing.new("Line"),
                    HeadDot = Drawing.new("Circle"),
                    Weapon = Drawing.new("Text") 
                }
                data = ESP_Table[p]
                data.BoxOutline.Visible = false
                data.BoxOutline.Color = Color3.new(0,0,0)
                data.BoxOutline.Thickness = 3
                data.BoxOutline.Filled = false
                data.HealthBarOutline.Visible = false
                data.HealthBarOutline.Color = Color3.new(0,0,0)
                data.HealthBarOutline.Filled = true
            end
            
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if vis then
                local sX = Camera.ViewportSize.X
                local sY = Camera.ViewportSize.Y
                if pos.X < 0 or pos.X > sX or pos.Y < 0 or pos.Y > sY then
                    vis = false
                end
            end
            
            if not vis then
                 SetAllVisible(data, false)
                 continue
            end
            
            local currentFov = Camera.FieldOfView
            local fovScale = 70 / currentFov
            local size = math.max((2000 * fovScale) / math.max(pos.Z, 1), 10)
            
            -- Kutular (Boxes)
            data.BoxOutline.Visible = _G.Config.EspBoxes
            data.BoxOutline.Size = Vector2.new(size, size * 1.5)
            data.BoxOutline.Position = Vector2.new(pos.X - size/2, pos.Y - (size*1.5)/2)
            
            data.Box.Visible = _G.Config.EspBoxes
            data.Box.Size = Vector2.new(size, size * 1.5)
            data.Box.Position = Vector2.new(pos.X - size/2, pos.Y - (size*1.5)/2)
            data.Box.Color = _G.Config.BoxColor
            data.Box.Thickness = 1
            data.Box.Filled = false
            
            -- İsimler (Names)
            data.Name.Visible = _G.Config.EspNames
            data.Name.Text = p.Name
            data.Name.Size = 14
            data.Name.Center = true
            data.Name.Outline = true
            data.Name.Font = 2 
            data.Name.Color = _G.Config.NameColor
            data.Name.Position = Vector2.new(pos.X, pos.Y - (size*1.5)/2 - 16)
            
            -- Can Barı (Health Bar)
            if _G.Config.EspHealthBar then
                local healthPer = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                data.HealthBarOutline.Visible = true
                data.HealthBarOutline.Size = Vector2.new(4, size * 1.5 + 2)
                data.HealthBarOutline.Position = Vector2.new(pos.X - size/2 - 7, pos.Y - (size*1.5)/2 - 1)
                
                data.HealthBar.Visible = true
                data.HealthBar.Size = Vector2.new(2, size * 1.5 * healthPer)
                data.HealthBar.Position = Vector2.new(pos.X - size/2 - 6, pos.Y - (size*1.5)/2 + (size * 1.5 * (1 - healthPer))) 
                data.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPer)
                data.HealthBar.Filled = true
            else
                data.HealthBar.Visible = false
                data.HealthBarOutline.Visible = false
            end
            
            -- Mesafe (Distance)
            if _G.Config.EspDistance then
                data.DistanceText.Visible = true
                data.DistanceText.Text = math.floor((Camera.CFrame.Position - root.Position).Magnitude) .. "m"
                data.DistanceText.Size = 12
                data.DistanceText.Center = true
                data.DistanceText.Outline = true
                data.DistanceText.Font = 2
                data.DistanceText.Color = _G.Config.DistColor
                data.DistanceText.Position = Vector2.new(pos.X, pos.Y + (size*1.5)/2 + 5)
            else
                 data.DistanceText.Visible = false
            end
            
            -- Çizgiler (Tracers)
            if _G.Config.EspTracers then
                data.Tracer.Visible = true
                data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                data.Tracer.To = Vector2.new(pos.X, pos.Y)
                data.Tracer.Color = _G.Config.TracerColor
                data.Tracer.Thickness = 1
            else
                 data.Tracer.Visible = false
            end
            
            -- Kafa Noktası (Head Dot)
            if _G.Config.EspHeadDot and head then
                 local hPos, hVis = Camera:WorldToViewportPoint(head.Position)
                 if hVis then
                    data.HeadDot.Visible = true
                    data.HeadDot.Position = Vector2.new(hPos.X, hPos.Y)
                    data.HeadDot.Radius = 3
                    data.HeadDot.Color = _G.Config.HeadDotColor
                    data.HeadDot.Filled = true
                 else
                    data.HeadDot.Visible = false
                 end
            else
                data.HeadDot.Visible = false
            end
            
            -- Silah Bilgisi (Weapon)
            if _G.Config.EspWeapon then
                local attr = p:GetAttribute("CurrentEquipped")
                local weaponName = "None"
                if attr then
                    local s, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(attr) end)
                    if s and decoded and decoded.Name then
                        weaponName = decoded.Name
                    end
                end
                data.Weapon.Visible = true
                data.Weapon.Text = weaponName
                data.Weapon.Size = 13
                data.Weapon.Center = false 
                data.Weapon.Outline = true
                data.Weapon.Font = 2
                data.Weapon.Position = Vector2.new(pos.X + size/2 + 4, pos.Y - size/2) 
                data.Weapon.Color = _G.Config.WeaponColor
            else
                data.Weapon.Visible = false
            end
        end
    end)
end)

print("BloxStrike ESP Only - Yüklendi!")
