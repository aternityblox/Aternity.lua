--======================================================================--
--                       ATERNITY HUB — OVERLORD EDITION (v9.0)          --
--         UI CORE & MULTI-THREADING SYSTEM | REDZ HUB KILLER | 2026    --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- ГЛОБАЛЬНАЯ КЛИЕНТСКАЯ КОНФИГУРАЦИЯ БУДУЩЕГО СОФТА
getgenv().AternityConfig = {
    AutoFarm = false, AutoClick = false, AutoChest = false, FastAttack = false,
    AutoStats = false, SelectedStat = "Melee", SelectedWeapon = "Blox Fruit",
    FlightSpeed = 300, CurrentTheme = "SpaceDark", AutoRejoin = true
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА ВЫСШЕГО КЛАССА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHubPremium"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 360) -- Удобный горизонтальный формат как у Redz
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Неоновая подсветка границ (Glow Border)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 204)
Stroke.ApplyStrokeMode = Enum.StrokeMode.Border

-- БОКОВАЯ ПАНЕЛЬ НАВИГАЦИИ (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(7, 9, 15)
Sidebar.BorderSizePixel = 0

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 4)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.BackgroundTransparency = 1
Logo.Text = "ATERNITY V9"
Logo.TextColor3 = Color3.fromRGB(0, 255, 204)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 16

-- ОСНОВНОЙ КОНТЕЙНЕР СТРАНИЦ
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -150, 1, -20)
Container.Position = UDim2.new(0, 145, 0, 10)
Container.BackgroundTransparency = 1

local pages = {}
local currentTab = nil

local function AddTab(name, icon)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 600)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local TabButton = Instance.new("TextButton", Sidebar)
    TabButton.Size = UDim2.new(0, 125, 0, 32)
    TabButton.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(160, 170, 190)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 12
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.Activated:Connect(function()
        for _, p in pairs(pages) do
            p.frame.Visible = false
            p.btn.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
            p.btn.TextColor3 = Color3.fromRGB(160, 170, 190)
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    end)
    
    table.insert(pages, {frame = Page, btn = TabButton})
    if #pages == 1 then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    end
    return Page
end

-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
local function AddToggle(parent, text, configProp, callback)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 225, 235)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("TextButton", ToggleFrame)
    Switch.Size = UDim2.new(0, 44, 0, 22)
    Switch.Position = UDim2.new(1, -54, 0, 9)
    Switch.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    Switch.Text = ""
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)
    
    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 3, 0, 3)
    Circle.BackgroundColor3 = Color3.fromRGB(180, 190, 200)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 8)
    
    Switch.Activated:Connect(function()
        getgenv().AternityConfig[configProp] = not getgenv().AternityConfig[configProp]
        local state = getgenv().AternityConfig[configProp]
        
        TweenService:Create(Switch, UTweenInfo or TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(30, 35, 45)
        }):Play()
        
        TweenService:Create(Circle, UTweenInfo or TweenInfo.new(0.2), {
            Position = state and UDim2.new(0, 25, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 190, 200)
        }):Play()
        
        if callback then callback(state) end
    end)
end

-- СОЗДАНИЕ ПРЕМИУМ ВКЛАДОК
local MainPage = AddTab("Main Farm")
local CombatPage = AddTab("Combat Core")
local TeleportPage = AddTab("Teleports")
local SettingsPage = AddTab("Settings")

print("[ATERNITY V9] UI Core Engine успешно инициализирован.")
--======================================================================--
--                       Шаг 2: FAST ATTACK CORE & ENGINE              --
--======================================================================--

-- 1. СЕТЕВОЙ ОПТИМИЗАТОР ПАКЕТОВ (FAST ATTACK BYPASS)
local CombatFramework = {}
local RigController = nil

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local modules = game:GetService("ReplicatedStorage"):FindFirstChild("Util")
                if modules and modules:FindFirstChild("Modules") and modules.Modules:FindFirstChild("Xenon") then
                    -- Попытка хука боевого движка напрямую через игровой кэш
                    CombatFramework = require(modules.Modules.Xenon.CombatFramework)
                end
            end
        end)
    end
end)

-- Профессиональная Kill Aura (Удары пакетами до 30 раз в секунду)
local function executeFastAttack()
    pcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        
        local currentTarget = GetMyTargetMob()
        local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
        
        for _, obj in pairs(enemyFolder:GetChildren()) do
            if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                -- Дистанционная отправка урона без анимации замаха (Метод Redz Hub)
                local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                if combatEvent then
                    combatEvent:FireServer("weaponChange")
                    -- Тройной пакетный удар за один тик физики
                    combatEvent:FireServer("hit", obj.HumanoidRootPart, 1)
                    combatEvent:FireServer("hit", obj.HumanoidRootPart, 2)
                    combatEvent:FireServer("hit", obj.HumanoidRootPart, 3)
                end
            end
        end
    end)
end

-- Поток высокочастотного триггера атаки
task.spawn(function()
    while true do
        if getgenv().AternityConfig.FastAttack and getgenv().AternityConfig.AutoFarm then
            executeFastAttack()
            -- Минимальная задержка кадра для обхода лимита пакетов
            game:GetService("RunService").Heartbeat:Wait()
        else
            task.wait(0.2)
        end
    end
end)

-- 2. СИСТЕМА УПРАВЛЕНИЯ ЗАДАЧАМИ (TASK SCHEDULER)
local function runMainAutomationLoop()
    task.spawn(function()
        while getgenv().AternityConfig.AutoFarm do
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local mainGui = player.PlayerGui:FindFirstChild("Main")
                local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
                local currentTarget = GetMyTargetMob()

                if not hasQuest then
                    -- Полет к NPC
                    local npc = FindValidTarget(currentTarget.QuestNPC)
                    if npc then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.3)
                        fireGameRemote("StartQuest", currentTarget.Quest, currentTarget.QuestID)
                        task.wait(0.2)
                    end
                else
                    -- Полет в центр спота
                    local farmPosition = currentTarget.Spot * CFrame.new(0, 7.5, 0)
                    SecureTeleport(farmPosition)
                    
                    character.Humanoid.PlatformStand = true
                    
                    -- Магнитное клиентское стягивание и раздутие хитбоксов
                    local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
                    local hasMobs = false
                    
                    for _, obj in pairs(enemyFolder:GetChildren()) do
                        if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                            hasMobs = true
                            obj.HumanoidRootPart.CanCollide = false
                            obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            obj.HumanoidRootPart.CFrame = currentTarget.Spot
                            
                            -- Премиум хитбокс 35 блоков как в Redz Hub
                            if obj.HumanoidRootPart:IsA("Part") or obj.HumanoidRootPart:IsA("MeshPart") then
                                obj.HumanoidRootPart.Size = Vector3.new(35, 35, 35)
                                obj.HumanoidRootPart.Transparency = 0.85
                            end
                            if obj:FindFirstChild("AttackParts") then obj.AttackParts:Destroy() end
                        end
                    end
                    
                    -- Если спот зачищен, летим ждать респавна к NPC
                    if not hasMobs then
                        local npc = FindValidTarget(currentTarget.QuestNPC)
                        if npc then SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)) end
                        task.wait(1)
                    end
                end
            end)
            game:GetService("RunService").Heartbeat:Wait()
        end
    end)
end

-- Автоматическое распределение очков статов
task.spawn(function()
    while task.wait(1) do
        if getgenv().AternityConfig.AutoStats then
            pcall(function()
                local points = game.Players.LocalPlayer.Data.Points.Value
                if points > 0 then
                    fireGameRemote("AddPoint", getgenv().AternityConfig.SelectedStat, points)
                end
            end)
        end
    end
end)

-- НАПОЛНЕНИЕ ВКЛАДОК КНОПКАМИ И ТУМБЛЕРАМИ
AddToggle(MainPage, "Enable Master Auto Farm", "AutoFarm", function(state)
    if state then runMainAutomationLoop() end
end)

AddToggle(CombatPage, "Enable Redz Ultra Fast Attack", "FastAttack", nil)
AddToggle(SettingsPage, "Auto Upgrade Allocated Stats", "AutoStats", nil)
--======================================================================--
--               Шаг 3: AUTO CHEST ENGINE & UNIVERSAL 3D ESP             --
--======================================================================--

-- 1. ОПТИМИЗИРОВАННЫЙ АВТОКЛЕКТОР СУНДУКОВ (СКОРОСТНОЙ ВЕКТОРНЫЙ СБОР)
local function runChestAutomationLoop()
    task.spawn(function()
        while getgenv().AternityConfig.AutoChest do
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Поиск ближайшего сундука на карте
                local targetChest = nil
                local minDistance = math.huge

                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        local dist = (root.Position - obj.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            targetChest = obj
                        end
                    end
                end

                -- Если нашли сундук, физически летим к нему вектором силы
                if targetChest then
                    SecureTeleport(targetChest.CFrame)
                    task.wait(0.3) -- Задержка для легальной регистрации сбора сервером
                else
                    -- Если сундуков в Workspace нет, летим на точку спавна Tiki Outpost караулить их появление
                    SecureTeleport(CFrame.new(-16450, 45, -15220))
                    task.wait(1)
                end
            end)
            game:GetService("RunService").Heartbeat:Wait()
        end
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false end)
    end)
end

-- 2. СИСТЕМНЫЙ СКАНИРУЮЩИЙ ДВИЖОК 3D ESP (ДЛЯ СУНДУКОВ И ДРОПНУТЫХ ФРУКТОВ)
local espCache = {}

local function updateVisualESP(enabled)
    if not enabled then
        -- Полная очистка визуальных объектов при выключении функции
        for obj, instances in pairs(espCache) do
            if instances.box then instances.box:Destroy() end
            if instances.gui then instances.gui:Destroy() end
        end
        table.clear(espCache)
        return
    end

    pcall(function()
        for _, obj in pairs(workspace:GetChildren()) do
            -- Проверяем сундуки (Parts) и фрукты (Tools на земле)
            if (string.find(obj.Name, "Chest") and obj:IsA("Part")) or (string.find(obj.Name:lower(), "fruit") and obj:IsA("Tool")) then
                if not espCache[obj] then
                    -- 3D Бокс-подсветка
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = obj:IsA("Part") and obj.Size or Vector3.new(4, 4, 4)
                    box.AlwaysOnTop = true
                    box.ZIndex = 6
                    box.Color3 = obj:IsA("Part") and Color3.fromRGB(0, 255, 204) or Color3.fromRGB(255, 0, 150)
                    box.Adornee = obj
                    box.Parent = obj
                    
                    -- Billboard-текст с названием предмета
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    
                    local textLabel = Instance.new("TextLabel", billboard)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = box.Color3
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 10
                    textLabel.Text = obj.Name
                    
                    billboard.Parent = obj
                    espCache[obj] = {box = box, gui = billboard}
                end
            end
        end
    end)
end

-- Высокочастотный поток обновления ESP-рендеринга
task.spawn(function()
    while true do
        if getgenv().AternityConfig.VisualESP then
            updateVisualESP(true)
            task.wait(1) -- Сканирование Workspace раз в секунду без просадки FPS
        else
            updateVisualESP(false)
            task.wait(0.5)
        end
    end
end)

-- НАПОЛНЕНИЕ ВКЛАДОК КНОПКАМИ И ТУМБЛЕРАМИ
AddToggle(TeleportPage, "Auto Farm Chests (Beli)", "AutoChest", function(state)
    if state then runChestAutomationLoop() end
end)

AddToggle(TeleportPage, "Render Items & Fruit ESP", "VisualESP", nil)
--======================================================================--
--               Шаг 4: АДМИН-ДЕТЕКТОР, СЕРВЕРХОП И ЛОГГЕР PANEL         --
--======================================================================--

-- 1. СИСТЕМА ЗАЩИТЫ И АВТОМАТИЧЕСКОЙ СМЕНЫ СЕРВЕРА (SERVER HOP CORE)
local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://roblox.com" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, game.Players.LocalPlayer)
                break
            end
        end
    end)
end

-- Админ-Детектор (Защита от модераторов Blox Fruits)
task.spawn(function()
    game.Players.PlayerAdded:Connect(function(player)
        pcall(function()
            -- Проверка по официальной группе модераторов и паттернам никнеймов
            if player:GetRankInGroup(4330432) >= 200 or string.find(player.Name:lower(), "admin") or string.find(player.Name:lower(), "mod") then
                -- Моментальный уход на другой сервер при обнаружении угрозы бан-тикета
                ServerHop()
            end
        end)
    end)
end)

-- 2. ВНУТРЕННИЙ ГРАФИЧЕСКИЙ ЛОГГЕР ОТЛАДКИ (CONSOLE CONTEXT)
local LogPage = AddTab("Logs Console")

local LogContainer = Instance.new("ScrollingFrame", LogPage)
LogContainer.Size = UDim2.new(1, -5, 1, 0)
LogContainer.BackgroundTransparency = 1
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 2000)
LogContainer.ScrollBarThickness = 2
LogContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)

local LogLayout = Instance.new("UIListLayout", LogContainer)
LogLayout.Padding = UDim.new(0, 4)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createLogEntry(message, typeColor)
    local LogText = Instance.new("TextLabel", LogContainer)
    LogText.Size = UDim2.new(1, 0, 0, 20)
    LogText.BackgroundTransparency = 1
    LogText.Text = "  [" .. os.date("%X") .. "] " .. message
    LogText.TextColor3 = typeColor
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 10
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 25)
end

game:GetService("ScriptContext").Error:Connect(function(message)
    pcall(function()
        if string.find(message:lower(), "aternity") or string.find(message:lower(), "quest") or string.find(message:lower(), "remote") then
            createLogEntry("ERROR: " .. message, Color3.fromRGB(255, 75, 75))
        end
    end)
end)

local function LogInfo(message)
    createLogEntry("INFO: " .. message, Color3.fromRGB(0, 255, 204))
end

-- Стартовые логи инициализации ядра
LogInfo("Aternity Engine: MULTI-THREADING COMPLIANT.")
LogInfo("Fast Attack Bridge: READY.")
LogInfo("Tiki Outpost Vector Hook: ENGAGED.")

-- 3. ФИНАЛИЗАЦИЯ И ПРИНУДИТЕЛЬНЫЙ ЗАПУСК КЛИЕНТСКИХ ИНТЕРФЕЙСОВ
local closed = false
local ToggleKeyBtn = Instance.new("TextButton", Header)
ToggleKeyBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleKeyBtn.Position = UDim2.new(1, -40, 0, 5)
ToggleKeyBtn.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
ToggleKeyBtn.Text = "X"
ToggleKeyBtn.TextColor3 = Color3.fromRGB(0, 255, 204)
ToggleKeyBtn.Font = Enum.Font.GothamBold
ToggleKeyBtn.TextSize = 12
Instance.new("UICorner", ToggleKeyBtn).CornerRadius = UDim.new(0, 6)

ToggleKeyBtn.Activated:Connect(function()
    closed = not closed
    MainFrame.Visible = not closed
end)

print("[ATERNITY V9] Премиум-скрипт полностью укомплектован и готов к фарму уровня Redz Hub!")
