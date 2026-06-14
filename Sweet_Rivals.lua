--[[
    SWEET // RIVALS // KEY SYSTEM
    Components: Aimbot (Silent/Camera/Mouse), ESP (Box/Tracer/Name/Health/Distance), Custom UI, Key System
    Compatibility: Solara, Xeno, Wave, Delta, Arceus X, Synapse Z, Medium (All executors)
    UI Toggle: Right Shift
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- KEY SYSTEM
-- ============================================

-- CONFIGURAÇÃO DE KEYS (MUDE AQUI)
local ValidKeys = {
    ["SWEET-FREE-2024"] = "free",
    ["SWEET-VIP-001"] = "vip",
    ["SWEET-VIP-002"] = "vip",
    ["SWEET-ADMIN"] = "admin"
}

-- Key armazenada (persiste entre execuções)
local savedKey = nil
local userAccessLevel = nil

-- Função para salvar key no ambiente
local function saveKey(key)
    savedKey = key
    userAccessLevel = ValidKeys[key] or "invalid"
    
    -- Tentar salvar no ambiente do executor (persiste entre execuções)
    if getgenv then
        getgenv().SweetRivals_Key = key
        getgenv().SweetRivals_AccessLevel = userAccessLevel
    end
end

-- Função para verificar key
local function checkKey(inputKey)
    if ValidKeys[inputKey] then
        saveKey(inputKey)
        return true
    end
    return false
end

-- Verificar key salva anteriormente
if getgenv and getgenv().SweetRivals_Key and ValidKeys[getgenv().SweetRivals_Key] then
    savedKey = getgenv().SweetRivals_Key
    userAccessLevel = ValidKeys[savedKey]
    print("SWEET // Key loaded from memory: " .. savedKey)
end

-- ============================================
-- KEY UI (SE NENHUMA KEY VÁLIDA)
-- ============================================

local keyValidated = (savedKey ~= nil and userAccessLevel ~= "invalid")
local keyUI = nil

local function showKeyUI()
    if keyValidated then return end
    
    -- Criar UI de key
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Sweet_KeyUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Blur
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Image = "rbxassetid://5028857088"
    bg.ScaleType = Enum.ScaleType.Slice
    bg.SliceCenter = Rect.new(8, 8, 8, 8)
    bg.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = "SWEET // RIVALS"
    Title.TextColor3 = Color3.fromRGB(255, 120, 160)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Subtitle
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, 0, 0, 30)
    SubTitle.Position = UDim2.new(0, 0, 0, 45)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Digite sua key para continuar"
    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    SubTitle.TextSize = 12
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.Parent = MainFrame
    
    -- Input box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0, 90)
    KeyInput.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
    KeyInput.BackgroundTransparency = 0.3
    KeyInput.BorderSizePixel = 0
    KeyInput.PlaceholderText = "SWEET-XXXX-XXXX"
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.Text = ""
    KeyInput.Parent = MainFrame
    
    -- Error label
    local ErrorLabel = Instance.new("TextLabel")
    ErrorLabel.Size = UDim2.new(1, 0, 0, 25)
    ErrorLabel.Position = UDim2.new(0, 0, 0, 135)
    ErrorLabel.BackgroundTransparency = 1
    ErrorLabel.Text = ""
    ErrorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    ErrorLabel.TextSize = 11
    ErrorLabel.Font = Enum.Font.Gotham
    ErrorLabel.Visible = false
    ErrorLabel.Parent = MainFrame
    
    -- Submit button
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(0.5, 0, 0, 40)
    SubmitBtn.Position = UDim2.new(0.25, 0, 0, 165)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 160)
    SubmitBtn.BackgroundTransparency = 0.2
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Text = "VALIDAR KEY"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Parent = MainFrame
    
    -- Status text
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0, 215)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame
    
    -- Função para validar key localmente
    local function validateKey()
        local inputKey = string.upper(KeyInput.Text)
        
        if inputKey == "" then
            ErrorLabel.Text = "Digite uma key!"
            ErrorLabel.Visible = true
            return
        end
        
        if checkKey(inputKey) then
            StatusLabel.Text = "Key validada! Carregando SWEET RIVALS..."
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            
            -- Fechar UI de key
            task.wait(0.5)
            ScreenGui:Destroy()
            keyValidated = true
            
            -- Iniciar o exploit (chama a função main depois)
            return true
        else
            ErrorLabel.Text = "Key inválida! Tente novamente."
            ErrorLabel.Visible = true
            StatusLabel.Text = ""
            KeyInput.Text = ""
            return false
        end
    end
    
    SubmitBtn.MouseButton1Click:Connect(validateKey)
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            validateKey()
        end
    end)
    
    -- Drag
    local dragging = false
    local dragStart
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
        end
    end)
    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset + delta.X, 0, MainFrame.Position.Y.Offset + delta.Y)
            dragStart = input.Position
        end
    end)
    
    -- Bloquear outras interações até key ser validada
    local blockGui = Instance.new("Frame")
    blockGui.Size = UDim2.new(1, 0, 1, 0)
    blockGui.BackgroundTransparency = 1
    blockGui.Parent = ScreenGui
    
    return false
end

-- ============================================
-- SISTEMA DE KEY ONLINE (OPCIONAL - VIA PASTEBIN)
-- ============================================

local function fetchOnlineKeys()
    -- URL para lista de keys válidas (crie um pastebin com as keys)
    local keyListURL = "https://pastebin.com/raw/SUA_KEY_LIST_AQUI"
    
    local success, response = pcall(function()
        return game:HttpGet(keyListURL)
    end)
    
    if success and response then
        for key in string.gmatch(response, "[%S]+") do
            if not ValidKeys[key] then
                ValidKeys[key] = "online"
            end
        end
        print("SWEET // Loaded " .. #ValidKeys .. " online keys")
    else
        print("SWEET // Online key list not available, using local keys only")
    end
end

-- Opcional: descomente para usar keys online
-- fetchOnlineKeys()

-- ============================================
-- EXPLOIT PRINCIPAL (só executa se key válida)
-- ============================================

-- Variables
local mouse = LocalPlayer:GetMouse()
local target = nil
local fovCircle = nil
local espObjects = {}
local uiVisible = true

-- Configuration
local Settings = {
    Aimbot = {
        Enabled = true,
        Silent = true,
        VisibleCheck = true,
        TeamCheck = true,
        AliveCheck = true,
        HitPart = "Head",
        FOV = 120,
        FOVVisible = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        Smoothness = 0.3
    },
    ESP = {
        Enabled = true,
        Box = true,
        Tracer = true,
        Name = true,
        Health = true,
        Distance = true,
        TeamColor = true,
        EnemyColor = Color3.fromRGB(255, 50, 50),
        TeamColorVal = Color3.fromRGB(50, 150, 255)
    }
}

-- Utility Functions
local function getPlayers()
    local plrs = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if Settings.Aimbot.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if Settings.Aimbot.AliveCheck and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end
            table.insert(plrs, v)
        end
    end
    return plrs
end

local function isVisible(part)
    if not Settings.Aimbot.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * (part.Position - origin).Magnitude)
    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == part or not hit
end

-- Aimbot Core (Silent Aim)
local function getClosestTarget()
    local closest = nil
    local shortestDist = Settings.Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(getPlayers()) do
        if plr.Character then
            local hitPart = plr.Character:FindFirstChild(Settings.Aimbot.HitPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if hitPart and isVisible(hitPart) then
                local screenPos, onScreen = Camera:WorldToScreenPoint(hitPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = hitPart
                    end
                end
            end
        end
    end
    return closest
end

-- FOV Circle
local function setupFOV()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = Settings.Aimbot.FOVVisible
    fovCircle.Radius = Settings.Aimbot.FOV
    fovCircle.Color = Settings.Aimbot.FOVColor
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.NumSides = 60
    fovCircle.Transparency = 0.8
    
    RunService.RenderStepped:Connect(function()
        if Settings.Aimbot.FOVVisible then
            fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
            fovCircle.Radius = Settings.Aimbot.FOV
            fovCircle.Color = Settings.Aimbot.FOVColor
            fovCircle.Visible = Settings.Aimbot.Enabled
        else
            fovCircle.Visible = false
        end
    end)
end

-- Silent Aim Execution
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled then
        local aimTarget = getClosestTarget()
        if aimTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local screenPos = Camera:WorldToScreenPoint(aimTarget.Position)
            if Settings.Aimbot.Silent then
                local delta = Vector2.new(screenPos.X - mouse.X, screenPos.Y - mouse.Y)
                if delta.Magnitude > 0.5 then
                    local smoothed = delta * Settings.Aimbot.Smoothness
                    mousemoverel(smoothed.X, smoothed.Y)
                end
            else
                mousemoverel(screenPos.X - mouse.X, screenPos.Y - mouse.Y)
            end
        end
    end
end)

-- ESP System
local function createESP(player)
    local espData = {}
    
    local function updateESP()
        if not Settings.ESP.Enabled then
            if espData.Box then espData.Box.Visible = false end
            if espData.Tracer then espData.Tracer.Visible = false end
            if espData.Name then espData.Name.Visible = false end
            if espData.HealthBar then espData.HealthBar.Visible = false end
            if espData.Distance then espData.Distance.Visible = false end
            return
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if espData.Box then espData.Box.Visible = false end
            if espData.Tracer then espData.Tracer.Visible = false end
            if espData.Name then espData.Name.Visible = false end
            if espData.HealthBar then espData.HealthBar.Visible = false end
            if espData.Distance then espData.Distance.Visible = false end
            return
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local torsoPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
        local headPos = Camera:WorldToScreenPoint(player.Character:FindFirstChild("Head") and player.Character.Head.Position or rootPart.Position)
        
        if onScreen and torsoPos.Z > 0 then
            local height = math.abs(headPos.Y - torsoPos.Y) * 2
            local width = height * 0.5
            local boxPos = Vector2.new(torsoPos.X - width / 2, torsoPos.Y - height)
            local boxSize = Vector2.new(width, height)
            
            local color = Settings.ESP.TeamColor and (player.Team == LocalPlayer.Team and Settings.ESP.TeamColorVal or Settings.ESP.EnemyColor) or Settings.ESP.EnemyColor
            
            -- Box ESP
            if Settings.ESP.Box then
                if not espData.Box then
                    espData.Box = Drawing.new("Square")
                    espData.Box.Thickness = 1
                    espData.Box.Filled = false
                    espData.Box.Transparency = 0.7
                end
                espData.Box.Visible = true
                espData.Box.Position = boxPos
                espData.Box.Size = boxSize
                espData.Box.Color = color
            elseif espData.Box then
                espData.Box.Visible = false
            end
            
            -- Tracer
            if Settings.ESP.Tracer then
                if not espData.Tracer then
                    espData.Tracer = Drawing.new("Line")
                    espData.Tracer.Thickness = 1
                    espData.Tracer.Transparency = 0.6
                end
                espData.Tracer.Visible = true
                espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                espData.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                espData.Tracer.Color = color
            elseif espData.Tracer then
                espData.Tracer.Visible = false
            end
            
            -- Name
            if Settings.ESP.Name then
                if not espData.Name then
                    espData.Name = Drawing.new("Text")
                    espData.Name.Font = 1
                    espData.Name.Size = 12
                    espData.Name.Outline = true
                    espData.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                end
                espData.Name.Visible = true
                espData.Name.Position = Vector2.new(torsoPos.X - 30, boxPos.Y - 15)
                espData.Name.Text = player.Name
                espData.Name.Color = color
            elseif espData.Name then
                espData.Name.Visible = false
            end
            
            -- Health
            if Settings.ESP.Health and humanoid then
                if not espData.HealthBar then
                    espData.HealthBar = Drawing.new("Line")
                    espData.HealthBar.Thickness = 2
                end
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthBarHeight = height * healthPercent
                espData.HealthBar.Visible = true
                espData.HealthBar.From = Vector2.new(boxPos.X - 5, boxPos.Y + height)
                espData.HealthBar.To = Vector2.new(boxPos.X - 5, boxPos.Y + height - healthBarHeight)
                espData.HealthBar.Color = Color3.fromRGB(50, 255, 50)
            elseif espData.HealthBar then
                espData.HealthBar.Visible = false
            end
            
            -- Distance
            if Settings.ESP.Distance then
                if not espData.Distance then
                    espData.Distance = Drawing.new("Text")
                    espData.Distance.Font = 0
                    espData.Distance.Size = 10
                    espData.Distance.Outline = true
                end
                local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 0))
                espData.Distance.Visible = true
                espData.Distance.Position = Vector2.new(torsoPos.X - 15, torsoPos.Y + 10)
                espData.Distance.Text = dist .. "m"
                espData.Distance.Color = Color3.fromRGB(255, 255, 255)
            elseif espData.Distance then
                espData.Distance.Visible = false
            end
        else
            if espData.Box then espData.Box.Visible = false end
            if espData.Tracer then espData.Tracer.Visible = false end
            if espData.Name then espData.Name.Visible = false end
            if espData.HealthBar then espData.HealthBar.Visible = false end
            if espData.Distance then espData.Distance.Visible = false end
        end
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(updateESP)
    
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            if espData.Box then espData.Box:Remove() end
            if espData.Tracer then espData.Tracer:Remove() end
            if espData.Name then espData.Name:Remove() end
            if espData.HealthBar then espData.HealthBar:Remove() end
            if espData.Distance then espData.Distance:Remove() end
        end
    end)
end

-- Initialize ESP for all players
local function initESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createESP(plr)
        end
    end
    
    Players.PlayerAdded:Connect(function(plr)
        if plr ~= LocalPlayer then
            createESP(plr)
        end
    end)
end

-- UI Library (Sweet Theme)
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Sweet_Rivals_GUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Blur background (if supported)
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Image = "rbxassetid://5028857088"
    bg.ScaleType = Enum.ScaleType.Slice
    bg.SliceCenter = Rect.new(8, 8, 8, 8)
    bg.Parent = MainFrame
    
    -- Title (Sweet Rivals)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "SWEET // RIVALS v1.0"
    Title.TextColor3 = Color3.fromRGB(255, 120, 160)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Drag functionality
    local dragging = false
    local dragStart
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
        end
    end)
    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset + delta.X, 0, MainFrame.Position.Y.Offset + delta.Y)
            dragStart = input.Position
        end
    end)
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        uiVisible = false
    end)
    
    -- Tab buttons
    local Tabs = {"AIMBOT", "ESP", "UI"}
    local selectedTab = "AIMBOT"
    local tabY = 45
    
    for i, tabName in ipairs(Tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 120, 0, 35)
        tabBtn.Position = UDim2.new(0, 10 + (i-1)*125, 0, tabY)
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
        tabBtn.BackgroundTransparency = 0.3
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.TextSize = 14
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = MainFrame
        
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -20, 1, -90)
        contentFrame.Position = UDim2.new(0, 10, 0, 85)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = (tabName == selectedTab)
        contentFrame.Parent = MainFrame
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(MainFrame:GetChildren()) do
                if child:IsA("Frame") and child ~= MainFrame and child ~= bg and child ~= Title and child.Name ~= "ContentFrame" then
                    if child:FindFirstChild("ContentFrame") then
                        child.ContentFrame.Visible = false
                    end
                end
            end
            contentFrame.Visible = true
            selectedTab = tabName
        end)
        
        -- Aimbot Tab Content
        if tabName == "AIMBOT" then
            local yOffset = 10
            
            createToggle(contentFrame, "Enable Aimbot", Settings.Aimbot.Enabled, function(val)
                Settings.Aimbot.Enabled = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Silent Aim", Settings.Aimbot.Silent, function(val)
                Settings.Aimbot.Silent = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Visible Check", Settings.Aimbot.VisibleCheck, function(val)
                Settings.Aimbot.VisibleCheck = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Team Check", Settings.Aimbot.TeamCheck, function(val)
                Settings.Aimbot.TeamCheck = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Alive Check", Settings.Aimbot.AliveCheck, function(val)
                Settings.Aimbot.AliveCheck = val
            end, yOffset)
            yOffset = yOffset + 45
            
            createSlider(contentFrame, "FOV Range", 30, 300, Settings.Aimbot.FOV, function(val)
                Settings.Aimbot.FOV = val
            end, yOffset)
            yOffset = yOffset + 55
            
            createSlider(contentFrame, "Smoothness", 0, 1, Settings.Aimbot.Smoothness, function(val)
                Settings.Aimbot.Smoothness = val
            end, yOffset)
            yOffset = yOffset + 55
            
            createDropdown(contentFrame, "Hit Part", {"Head", "HumanoidRootPart", "UpperTorso"}, Settings.Aimbot.HitPart, function(val)
                Settings.Aimbot.HitPart = val
            end, yOffset)
        end
        
        -- ESP Tab Content
        if tabName == "ESP" then
            local yOffset = 10
            
            createToggle(contentFrame, "Enable ESP", Settings.ESP.Enabled, function(val)
                Settings.ESP.Enabled = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Box ESP", Settings.ESP.Box, function(val)
                Settings.ESP.Box = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Tracers", Settings.ESP.Tracer, function(val)
                Settings.ESP.Tracer = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Player Names", Settings.ESP.Name, function(val)
                Settings.ESP.Name = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Health Bars", Settings.ESP.Health, function(val)
                Settings.ESP.Health = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Distance", Settings.ESP.Distance, function(val)
                Settings.ESP.Distance = val
            end, yOffset)
            yOffset = yOffset + 35
            
            createToggle(contentFrame, "Team Colors", Settings.ESP.TeamColor, function(val)
                Settings.ESP.TeamColor = val
            end, yOffset)
        end
        
        -- UI Tab Content
        if tabName == "UI" then
            local yOffset = 10
            
            local themeLabel = Instance.new("TextLabel")
            themeLabel.Size = UDim2.new(1, 0, 0, 25)
            themeLabel.Position = UDim2.new(0, 0, 0, yOffset)
            themeLabel.BackgroundTransparency = 1
            themeLabel.Text = "UI Theme"
            themeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            themeLabel.TextSize = 14
            themeLabel.Font = Enum.Font.Gotham
            themeLabel.TextXAlignment = Enum.TextXAlignment.Left
            themeLabel.Parent = contentFrame
            yOffset = yOffset + 25
            
            local themeDropdown = Instance.new("TextButton")
            themeDropdown.Size = UDim2.new(1, 0, 0, 30)
            themeDropdown.Position = UDim2.new(0, 0, 0, yOffset)
            themeDropdown.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
            themeDropdown.Text = "Sweet Pink (Default)"
            themeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
            themeDropdown.TextSize = 12
            themeDropdown.Font = Enum.Font.Gotham
            themeDropdown.Parent = contentFrame
            yOffset = yOffset + 40
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, 0, 0, 25)
            toggleLabel.Position = UDim2.new(0, 0, 0, yOffset)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = "FOV Circle"
            toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleLabel.TextSize = 14
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = contentFrame
            
            local fovToggle = Instance.new("TextButton")
            fovToggle.Size = UDim2.new(0, 60, 0, 25)
            fovToggle.Position = UDim2.new(1, -70, 0, yOffset)
            fovToggle.BackgroundColor3 = Settings.Aimbot.FOVVisible and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80)
            fovToggle.Text = Settings.Aimbot.FOVVisible and "ON" or "OFF"
            fovToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovToggle.TextSize = 12
            fovToggle.Font = Enum.Font.Gotham
            fovToggle.Parent = contentFrame
            fovToggle.MouseButton1Click:Connect(function()
                Settings.Aimbot.FOVVisible = not Settings.Aimbot.FOVVisible
                fovToggle.BackgroundColor3 = Settings.Aimbot.FOVVisible and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80)
                fovToggle.Text = Settings.Aimbot.FOVVisible and "ON" or "OFF"
            end)
            
            yOffset = yOffset + 35
            
            local bindLabel = Instance.new("TextLabel")
            bindLabel.Size = UDim2.new(1, 0, 0, 25)
            bindLabel.Position = UDim2.new(0, 0, 0, yOffset)
            bindLabel.BackgroundTransparency = 1
            bindLabel.Text = "UI Toggle Key: Right Shift"
            bindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            bindLabel.TextSize = 14
            bindLabel.Font = Enum.Font.Gotham
            bindLabel.TextXAlignment = Enum.TextXAlignment.Left
            bindLabel.Parent = contentFrame
            
            -- Key Info
            yOffset = yOffset + 40
            local keyInfo = Instance.new("TextLabel")
            keyInfo.Size = UDim2.new(1, 0, 0, 40)
            keyInfo.Position = UDim2.new(0, 0, 0, yOffset)
            keyInfo.BackgroundTransparency = 1
            keyInfo.Text = "Access Level: " .. (userAccessLevel or "none")
            keyInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
            keyInfo.TextSize = 11
            keyInfo.Font = Enum.Font.Gotham
            keyInfo.Parent = contentFrame
        end
    end
    
    return ScreenGui
end

-- Helper functions for UI elements
function createToggle(parent, text, defaultValue, callback, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30
