--======================================================================--
--                       ATERNITY HUB V10 — ШАГ 1: ГРАФИЧЕСКОЕ ЯДРО     --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. ГЛОБАЛЬНАЯ КЛИЕНТСКАЯ КОНФИГУРАЦИЯ СОФТА
getgenv().AternityConfig = {
    AutoFarm = false, 
    AutoClick = false, 
    AutoChest = false, 
    FastAttack = false,
    AutoStats = false, 
    SelectedStat = "Melee", 
    SelectedWeapon = "Blox Fruit",
    FlightSpeed = 280,
    VisualESP = false
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 2. ЭКРАННЫЙ КОНТЕЙНЕР ДЛЯ СБОРКИ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHubPremium"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

-- 3. ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА (Премиум-формат Redz Hub)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Изумрудная неоновая обводка границ
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 204)
Stroke.ApplyStrokeMode = Enum.StrokeMode.Border

-- 4. ВЕРХНЯЯ ПАНЕЛЬ С УПРАВЛЕНИЕМ (Header)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY HUB v10.0 [Premium Overlord]"
Title.TextColor3 = Color3.fromRGB(0, 255, 204)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- Функциональная кнопка скрытия интерфейса "X"
local ToggleKeyBtn = Instance.new("TextButton", Header)
ToggleKeyBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleKeyBtn.Position = UDim2.new(1, -45, 0, 5)
ToggleKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
ToggleKeyBtn.Text = "X"
ToggleKeyBtn.TextColor3 = Color3.fromRGB(0, 255, 204)
ToggleKeyBtn.Font = Enum.Font.GothamBold
ToggleKeyBtn.TextSize = 12
ToggleKeyBtn.ZIndex = 3
Instance.new("UICorner", ToggleKeyBtn).CornerRadius = UDim.new(0, 6)

local uiClosed = false
ToggleKeyBtn.Activated:Connect(function()
    uiClosed = not uiClosed
    MainFrame.Visible = not uiClosed
end)

print("[ATERNITY STEP 1] Базовое графическое ядро со слоями ZIndex успешно создано.")
--======================================================================--
--                       ATERNITY HUB V10 — ШАГ 2: ПАНЕЛИ НАВИГАЦИИ     --
--======================================================================--

-- 1. ЛЕВАЯ БОКОВАЯ ПАНЕЛЬ НАВИГАЦИИ (Sidebar для вкладок)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(7, 9, 15)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

-- Автоматический вертикальный список для выстраивания кнопок
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)

-- 2. ПРАВЫЙ ОСНОВНОЙ КОНТЕЙНЕР ДЛЯ РАЗМЕЩЕНИЯ СТРАНИЦ ФУНКЦИЙ
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.ZIndex = 2

print("[ATERNITY STEP 2] Боковая навигация и фрейм-контейнер успешно интегрированы.")
--======================================================================--
--                       ATERNITY HUB V10 — ШАГ 3: ДВИЖОК ВКЛАДОК       --
--======================================================================--

local tabsList = {}

-- Универсальный генератор вкладок (Размещает кнопки в Sidebar, а страницы в Container)
local function AddTab(name)
    -- Контейнер страницы со встроенным скроллингом под ZIndex = 3
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 500)
    TabPage.ScrollBarThickness = 2
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)
    TabPage.ZIndex = 3
    
    -- Автоматическое вертикальное распределение элементов внутри страницы
    local PageLayout = Instance.new("UIListLayout", TabPage)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Кнопка переключения вкладки (Размещается на боковой панели Sidebar)
    local TabButton = Instance.new("TextButton", Sidebar)
    TabButton.Size = UDim2.new(0, 125, 0, 32)
    TabButton.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(160, 170, 190)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.ZIndex = 3
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    -- Логика переключения страниц при клике
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
            tab.btn.TextColor3 = Color3.fromRGB(160, 170, 190)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    end)
    
    table.insert(tabsList, {page = TabPage, btn = TabButton})
    
    -- Принудительное открытие самой первой страницы по умолчанию
    if #tabsList == 1 then
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    end
    
    return TabPage
end

-- РЕГИСТРАЦИЯ РОДИТЕЛЬСКИХ СТРАНИЦ
local FarmPage = AddTab("Main Farm")
local CombatPage = AddTab("Combat Core")
local TeleportPage = AddTab("Teleports")
local SettingsPage = AddTab("Settings")

print("[ATERNITY STEP 3] Ядро генерации вкладок полностью развернуто.")
--======================================================================--
--                       ATERNITY HUB V10 — ШАГ 4: ТУМБЛЕРЫ И БАЗА      --
--======================================================================--

-- 1. СИНХРОНИЗИРОВАННАЯ ЛИНЕЙНАЯ БАЗА ДАННЫХ ЛЕВЕЛИНГА (ДЛЯ TIKI OUTPOST И 2461 LVL)
local AllQuestsData = {
    {MinLvl = 1, MaxLvl = 9, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1, Spot = CFrame.new(1050, 20, 1400)},
    {MinLvl = 10, MaxLvl = 14, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1, Spot = CFrame.new(-1400, 30, 200)},
    {MinLvl = 700, MaxLvl = 774, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1, Spot = CFrame.new(-20, 20, -10)},
    {MinLvl = 1500, MaxLvl = 1574, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1, Spot = CFrame.new(-15000, 40, -14000)},
    
    -- СТРОГИЙ ФИКС ДЛЯ ВАШЕГО ТЕКУЩЕГО УРОВНЯ НА АВАНПОСТЕ TIKI (2461 LVL)
    {MinLvl = 2450, MaxLvl = 2524, Name = "Isle Outlaw", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 1, Spot = CFrame.new(-16450, 45, -15220)},
    {MinLvl = 2525, MaxLvl = 2599, Name = "Island Boy", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 2, Spot = CFrame.new(-16600, 45, -15400)},
    
    {MinLvl = 2800, MaxLvl = 9999, Name = "Aternity Abyss Slayer", QuestNPC = "Abyss Quest Giver", Quest = "AbyssQuest", QuestID = 1, Spot = CFrame.new(-17000, 50, -16000)}
}

-- Глобальная функция динамического подбора квеста по уровню в реальном времени
local function GetMyTargetMob()
    local myLevel = game.Players.LocalPlayer.Data.Level.Value
    for _, mob in ipairs(AllQuestsData) do
        if myLevel >= mob.MinLvl and myLevel <= mob.MaxLvl then 
            return mob
        end
    end
    return AllQuestsData[#AllQuestsData]
end

-- Вспомогательный глубокий поиск целей по структурам папок игры
local function FindValidTarget(name)
    local folders = {workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies")}
    for _, folder in pairs(folders) do
        if folder then
            local found = folder:FindFirstChild(name)
            if found and found:FindFirstChild("HumanoidRootPart") then return found end
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then return obj end
    end
    return nil
end

-- 2. УНИВЕРСАЛЬНАЯ ФАБРИКА НЕОНОВЫХ ТУМБЛЕРОВ (Toggles Core)
local function AddToggle(parentPage, text, configProp, callback)
    local ToggleFrame = Instance.new("Frame", parentPage)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 4
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 215, 225)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 5
    
    local Switch = Instance.new("TextButton", ToggleFrame)
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -52, 0, 11)
    Switch.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
    Switch.Text = ""
    Switch.ZIndex = 5
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 10)
    
    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0, 3)
    Circle.BackgroundColor3 = Color3.fromRGB(160, 170, 185)
    Circle.ZIndex = 6
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 7)
    
    Switch.Activated:Connect(function()
        getgenv().AternityConfig[configProp] = not getgenv().AternityConfig[configProp]
        local state = getgenv().AternityConfig[configProp]
        
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(28, 33, 46)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 185)
        }):Play()
        
        if callback then callback(state) end
    end)
end

-- 3. РАЗВЕРТЫВАНИЕ ТУМБЛЕРОВ ПО СТРАНИЦАМ
AddToggle(FarmPage, "Enable Linear Auto Farm Level", "AutoFarm", function(state)
    if state then runMainAutomationLoop() end
end)

AddToggle(CombatPage, "Enable Redz Fast Attack (Kill Aura)", "FastAttack", nil)
AddToggle(CombatPage, "Enable Auto Clicker Simulation", "AutoClick", nil)

AddToggle(TeleportPage, "Auto Farm Chests Around Map", "AutoChest", function(state)
    if state then runChestAutomationLoop() end
end)
AddToggle(TeleportPage, "Render Items & Chests 3D ESP", "VisualESP", nil)

AddToggle(SettingsPage, "Auto Allocate Level Points", "AutoStats", nil)

print("[ATERNITY STEP 4] Интерактивные тумблеры и базы данных успешно инициализированы.")
