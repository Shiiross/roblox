if not game:IsLoaded() then
    game.Loaded:Wait()
end

pcall(function() setfflag("AdornShadingAPI", "true") end)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Sadece ESP Yapılandırması
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
    EspTeamMode = "Enemies",
    UseTeamCheck = false,
    EspChams = false,
    ChamHiddenColor = Color3.fromRGB(255, 0, 0)
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ewenja/HihiHub.gui-new/refs/heads/main/leake_gui_fix_KeyCode.Z_v4.lua"))()
local Window = Library:Window({
    Name = "Icanstoplarping Hub",
    SubName = "ESP Only",
    Logo = "120959262762131"
})

Window:Category("Visuals")
local VisualsPage = Window:Page({Name = "Visuals & ESP", Icon = "100050851789190", Columns = 2})

local EspSection = VisualsPage:Section({Name = "ESP Settings", Description = "Wallhack Settings", Icon = "100050851789190", Side = 1})
local EspToggle = EspSection:Toggle({Name = "Enable ESP", Flag = "BS_Esp", Default = _G.Config.Esp, Callback = function(v) _G.Config.Esp = v end})
EspSection:Toggle({Name = "Boxes", Flag = "BS_EspBoxes", Default = _G.Config.EspBoxes, Callback = function(v) _G.Config.EspBoxes = v end}):Settings(250):Label("Box Color"):Colorpicker({Name = "Color", Flag = "BoxColor", Default = _G.Config.BoxColor, Callback = function(v) _G.Config.BoxColor = v end})
EspSection:Toggle({Name = "Names", Flag = "BS_EspNames", Default = _G.Config.EspNames, Callback = function(v) _G.Config.EspNames = v end}):Settings(250):Label("Name Color"):Colorpicker({Name = "Color", Flag = "NameColor", Default = _G.Config.NameColor, Callback = function(v) _G.Config.NameColor = v end})
EspSection:Toggle({Name = "Health Bar", Flag = "BS_EspHealthBar", Default = _G.Config.EspHealthBar, Callback = function(v) _G.Config.EspHealthBar = v end}):Settings(250):Label("Health Bar Color"):Colorpicker({Name = "Color", Flag = "HealthBarColor", Default = _G.Config.HealthBarColor, Callback = function(v) _G.Config.HealthBarColor = v end})
EspSection:Toggle({Name = "Distance", Flag = "BS_EspDistance", Default = _G.Config.EspDistance, Callback = function(v) _G.Config.EspDistance = v end}):Settings(250):Label("Distance Color"):Colorpicker({Name = "Color", Flag = "DistColor", Default = _G.Config.DistColor, Callback = function(v) _G.Config.DistColor = v end})
EspSection:Toggle({Name = "Head Dot", Flag = "BS_EspHeadDot", Default = _G.Config.EspHeadDot, Callback = function(v) _G.Config.EspHeadDot = v end}):Settings(250):Label("Head Dot Color"):Colorpicker({Name = "Color", Flag = "HeadDotColor", Default = _G.Config.HeadDotColor, Callback = function(v) _G.Config.HeadDotColor = v end})
EspSection:Toggle({Name = "Weapon", Flag = "BS_EspWeapon", Default = _G.Config.EspWeapon, Callback = function(v) _G.Config.EspWeapon = v end}):Settings(250):Label("Weapon Color"):Colorpicker({Name = "Color", Flag = "WeaponColor", Default = _G.Config.WeaponColor, Callback = function(v) _G.Config.WeaponColor = v end})
EspSection:Toggle({Name = "Tracers", Flag = "BS_EspTracers", Default = _G.Config.EspTracers, Callback = function(v) _G.Config.EspTracers = v end}):Settings(250):Label("Tracer Color"):Colorpicker({Name = "Color", Flag = "TracerColor", Default = _G.Config.TracerColor, Callback = function(v) _G.Config.TracerColor = v end})
EspSection:Toggle({Name = "Chams", Flag = "BS_EspChams", Default = _G.Config.EspChams, Callback = function(v) _G.Config.EspChams = v end}):Settings(250):Label("Hidden Color"):Colorpicker({Name = "Color", Flag = "ChamHiddenColor", Default = _G.Config.ChamHiddenColor, Callback = function(v) _G.Config.ChamHiddenColor = v end})

local TeamSection = VisualsPage:Section({Name = "Team Settings", Description = "Colors & Filter", Icon = "100050851789190", Side = 2})
TeamSection:Dropdown({Name = "Team Mode", Flag = "EspTeamMode", Default = {_G.Config.EspTeamMode}, Items = {"Enemies", "Teammates", "All"}, Multi = false, Callback = function(v) _G.Config.EspTeamMode = v end})
TeamSection:Toggle({Name = "Team Check", Flag = "BS_UseTeamCheck", Default = _G.Config.UseTeamCheck, Callback = function(v) _G.Config.UseTeamCheck = v end})
TeamSection:Label("Colors"):Colorpicker({Name = "Enemy Color", Flag = "EnemyColor", Default = _G.Config.EnemyColor, Callback = function(v) _G.Config.EnemyColor = v end})
TeamSection:Label("Teammate Color"):Colorpicker({Name = "Teammate Color", Flag = "TeammateColor", Default = _G.Config.TeammateColor, Callback = function(v) _G.Config.TeammateColor = v end})

Window:Category("Config")
local SettingsPage = Window:Page({Name = "Configuration", Icon = "108839695397679", Columns = 1})
local UISettings = SettingsPage:Section({Name = "UI Settings", Description = "Menu Keybinds", Icon = "103180437044643", Side = 1})
UISettings:Keybind({
    Name = "Menu Toggle",
    Flag = "GuiToggleKey",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window:SetOpen(not Window.IsOpen)
    end
})

Window:Init()

-- Takım Kontrolü
local function isEnemy(p)
    if not p or not p.Character then return false end
    if not _G.Config.UseTeamCheck then return true end
    if p == LP then return false end 
    local LPTeamFolder = LP.Character and LP.Character.Parent
    local PlayerTeamFolder = p.Character.Parent
    if LP.Team and p.Team then
        return LP.Team ~= p.Team
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
            if d:IsA("BillboardGui") then d.Enabled = val end
        elseif d.Visible ~= nil then 
             pcall(function() d.Visible = val end)
        end
    end
end

local function RemoveEsp(p)
    if ESP_Table[p] then
        for _, d in pairs(ESP_Table[p]) do 
            if typeof(d) == "Instance" then d:Destroy()
            elseif d.Remove then d:Remove() end
        end
        ESP_Table[p] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveEsp)

-- ESP Mantığı
RunService.RenderStepped:Connect(function()
    pcall(function() 
        Camera = workspace.CurrentCamera
        if not Camera then return end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
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
                if pos.X < 0 or pos.X > sX or pos.Y < 0 or pos.Y > sY then vis = false end
            end
            
            if not vis then
                 SetAllVisible(data, false)
                 continue
            end
            
            local currentFov = Camera.FieldOfView
            local fovScale = 70 / currentFov
            local size = math.max((2000 * fovScale) / math.max(pos.Z, 1), 10)
            
            -- Kutular
            data.BoxOutline.Visible = _G.Config.EspBoxes
            data.BoxOutline.Size = Vector2.new(size, size * 1.5)
            data.BoxOutline.Position = Vector2.new(pos.X - size/2, pos.Y - (size*1.5)/2)
            
            data.Box.Visible = _G.Config.EspBoxes
            data.Box.Size = Vector2.new(size, size * 1.5)
            data.Box.Position = Vector2.new(pos.X - size/2, pos.Y - (size*1.5)/2)
            data.Box.Color = _G.Config.BoxColor
            data.Box.Thickness = 1
            data.Box.Filled = false
            
            -- İsimler
            data.Name.Visible = _G.Config.EspNames
            data.Name.Text = p.Name
            data.Name.Size = 14
            data.Name.Center = true
            data.Name.Outline = true
            data.Name.Font = 2 
            data.Name.Color = _G.Config.NameColor
            data.Name.Position = Vector2.new(pos.X, pos.Y - (size*1.5)/2 - 16)
            
            -- Can Barı
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
            
            -- Mesafe
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
            
            -- Tracers
            if _G.Config.EspTracers then
                data.Tracer.Visible = true
                data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                data.Tracer.To = Vector2.new(pos.X, pos.Y)
                data.Tracer.Color = _G.Config.TracerColor
                data.Tracer.Thickness = 1
            else
                 data.Tracer.Visible = false
            end
            
            -- Head Dot
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
            
            -- Silah Bilgisi
            if _G.Config.EspWeapon then
                local attr = p:GetAttribute("CurrentEquipped")
                local weaponName = "None"
                if attr then
                    local s, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(attr) end)
                    if s and decoded and decoded.Name then weaponName = decoded.Name end
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

-- Chams Döngüsü
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        local configChams = _G.Config.EspChams
        local hiddenColor = _G.Config.ChamHiddenColor or Color3.fromRGB(255, 0, 0)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local shouldCham = configChams and p ~= LP and isEnemy(p)

                for _, v in pairs(p.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        if v.Name ~= "HumanoidRootPart" and v.Transparency >= 1 then v.Transparency = 0 end
                        
                        local box = v:FindFirstChild("BloxStrikeChamAdorn")
                        if shouldCham and v.Name ~= "HumanoidRootPart" then
                             if not box then
                                  box = Instance.new("BoxHandleAdornment", v)
                                  box.Name = "BloxStrikeChamAdorn"
                                  box.Adornee = v
                                  box.AlwaysOnTop = false 
                                  box.ZIndex = -1 
                                  box.Transparency = -1 
                                  box.Shading = Enum.AdornShading.XRayShaded
                             end
                             if box then
                                  box.Visible = true
                                  box.Size = v.Size + Vector3.new(0.1, 0.1, 0.1)
                                  box.Color3 = hiddenColor
                             end
                        else
                             if box then box:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end)
