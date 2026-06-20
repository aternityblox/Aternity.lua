--======================================================================--
--                       ATERNITY HUB V9 — ШАГ 1: КАРКАС ИНТЕРФЕЙСА     --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- Глобальная конфигурация софта
getgenv().AternityConfig = {
    AutoFarm = false, AutoClick = false, AutoChest = false, FastAttack = false,
    AutoStats = false, SelectedStat = "Melee", SelectedWeapon = "Blox Fruit",
    FlightSpeed = 280
}

-- ИНИЦИАЛИЗАЦИЯ СЕРВЕРНЫХ СЛУЖБ
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- КОРНЕВОЙ КОНТЕЙНЕР ДЛЯ ЭКРАНА ИГРОКА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHubPremium"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

-- ГЛАВНОЕ ОКНО МЕНЮ (Основная черная панель)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Неоновая обводка (Светящаяся рамка)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 204)
Stroke.ApplyStrokeMode = Enum.StrokeMode.Border

-- ВЕРХНЯЯ ПАНЕЛЬ (Хедер для заголовка софта)
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
Title.Text = "ATERNITY HUB v9.0 [Premium Rebuild]"
Title.TextColor3 = Color3.fromRGB(0, 255, 204)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- КНОПКА СВЕРТЫВАНИЯ / ЗАКРЫТИЯ МЕНЮ (Иконка "X")
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

-- ЛЕВАЯ БОКОВАЯ ПАНЕЛЬ НАВИГАЦИИ (Sidebar для вкладок)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(7, 9, 15)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)

-- ПРАВЫЙ ОСНОВНОЙ КОНТЕЙНЕР ДЛЯ СТРАНИЦ ФУНКЦИЙ
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.ZIndex = 2

print("[ATERNITY STEP 1] Базовый каркас со слоями ZIndex отрисован.")
--======================================================================--
--                       Шаг 2 из 5: ДВИЖОК ВКЛАДОК И СТРАНИЦ           --
--======================================================================--

local tabsList = {}

-- Глобальная функция создания адаптивных страниц (вставляется после Container)
local function AddTab(name)
    -- Контейнер страницы с возможностью прокрутки (активируется ZIndex = 3)
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 500)
    TabPage.ScrollBarThickness = 2
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)
    TabPage.ZIndex = 3
    
    -- Автоматическое вертикальное выравнивание элементов внутри страницы
    local PageLayout = Instance.new("UIListLayout", TabPage)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Кнопка вкладки на боковой панели Sidebar
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
    
    -- Логика переключения страниц и плавной смены цвета текста
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
    
    -- Автоматическая активация самой первой вкладки при инжекте
    if #tabsList == 1 then
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    end
    
    return TabPage
end

-- РЕГИСТРАЦИЯ ПРЕМИУМ СТРАНИЦ
local FarmPage = AddTab("Main Farm")
local CombatPage = AddTab("Combat Core")
local TeleportPage = AddTab("Teleports")
local SettingsPage = AddTab("Settings")

print("[ATERNITY STEP 2] Движок страниц и кнопок переключения успешно развернут.")
--======================================================================--
--                       Шаг 3 из 5: ДВИЖОК ТУМБЛЕРОВ И ПЕРЕКЛЮЧАТЕЛЕЙ  --
--======================================================================--

-- Универсальная функция создания премиум-переключателей (Toggles)
local function AddToggle(parentPage, text, configProp, callback)
    -- Основной контейнер кнопки
    local ToggleFrame = Instance.new("Frame", parentPage)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 4
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    -- Текстовое описание функции
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
    
    -- Кнопка заднего фона переключателя (Свитч)
    local Switch = Instance.new("TextButton", ToggleFrame)
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -52, 0, 11)
    Switch.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
    Switch.Text = ""
    Switch.ZIndex = 5
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 10)
    
    -- Подвижный внутренний кружок слайдера
    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0, 3)
    Circle.BackgroundColor3 = Color3.fromRGB(160, 170, 185)
    Circle.ZIndex = 6
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 7)
    
    -- Интерактивная логика клика с плавной анимацией изменения состояний
    Switch.Activated:Connect(function()
        getgenv().AternityConfig[configProp] = not getgenv().AternityConfig[configProp]
        local state = getgenv().AternityConfig[configProp]
        
        -- Плавная смена цвета фона (Зеленый / Серый)
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(28, 33, 46)
        }):Play()
        
        -- Сдвиг кружка вправо / влево
        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 185)
        }):Play()
        
        -- Передача состояния флага в исполнительный модуль
        if callback then callback(state) end
    end)
end

print("[ATERNITY STEP 3] Движок интерактивных переключателей успешно интегрирован.")
--======================================================================--
--                       Шаг 4 из 5: БАЗА ДАННЫХ И НАПОЛНЕНИЕ UI ЭЛЕМЕНТАМИ  --
--======================================================================--

-- 1. СИНХРОНИЗИРОВАННАЯ ЛИНЕЙНАЯ БАЗА ДАННЫХ ЛЕВЕЛИНГА (ДЛЯ TIKI OUTPOST И 2461 LVL)
local AllQuestsData = {
    {MinLvl = 1, MaxLvl = 9, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1, Spot = CFrame.new(1050, 20, 1400)},
    {MinLvl = 10, MaxLvl = 14, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1, Spot = CFrame.new(-1400, 30, 200)},
    {MinLvl = 700, MaxLvl = 774, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1, Spot = CFrame.new(-20, 20, -10)},
    {MinLvl = 1500, MaxLvl = 1574, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1, Spot = CFrame.new(-15000, 40, -14000)},
    
    -- ИСПРАВЛЕННЫЙ СЛОЙ ПРОКАЧКИ ДЛЯ ВАШЕГО ТЕКУЩЕГО УРОВНЯ НА TIKI OUTPOST
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

-- НАПОЛНЕНИЕ ВКЛАДОК ИНТЕРФЕЙСА РАБОЧИМИ ТУМБЛЕРАМИ ФУНКЦИЙ
-- Вкладка Main Farm
AddToggle(FarmPage, "Enable Linear Auto Farm Level", "AutoFarm", function(state)
    if state then runMainAutomationLoop() end
end)

-- Вкладка Combat Core
AddToggle(CombatPage, "Enable Redz Fast Attack (Kill Aura)", "FastAttack", nil)
AddToggle(CombatPage, "Enable Auto Clicker Simulation", "AutoClick", nil)

-- Вкладка Teleports
AddToggle(TeleportPage, "Auto Farm Chests Around Map", "AutoChest", function(state)
    if state then runChestAutomationLoop() end
end)
AddToggle(TeleportPage, "Render Items & Chests 3D ESP", "VisualESP", nil)

-- Вкладка Settings
AddToggle(SettingsPage, "Auto Allocate Level Points", "AutoStats", nil)

print("[ATERNITY STEP 4] База данных 2800 уровня и тумблеры страниц успешно развернуты.")
--======================================================================--
--                       Шаг 5 из 5: ИСПОЛНИТЕЛЬНЫЕ ДВИЖКИ И ПОТОКИ      --
--======================================================================--

-- 1. СЕТЕВОЙ ОПТИМИЗАТОР УДАРА (KILL AURA)
local function executeFastAttack()
    pcall(function()
        local currentTarget = GetMyTargetMob()
        local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, obj in pairs(enemyFolder:GetChildren()) do
            if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                if combatEvent then
                    combatEvent:FireServer("weaponChange")
                    combatEvent:FireServer("hit", obj.HumanoidRootPart, 1)
                    combatEvent:FireServer("hit", obj.HumanoidRootPart, 2)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        if getgenv().AternityConfig.FastAttack and getgenv().AternityConfig.AutoFarm then
            executeFastAttack()
            game:GetService("RunService").Heartbeat:Wait()
        else
            task.wait(0.2)
        end
    end
end)

-- 2. ВЫСОТНЫЙ БЕЗОПАСНЫЙ ПОЛЕТ (ОБХОД СТЕН И ОШИБКИ 267)
local function SecureTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 25 then
        root.CFrame = targetCFrame
        return
    end

    if root:FindFirstChild("AternityVelocity") then root.AternityVelocity:Destroy() end
    if root:FindFirstChild("AternityGyro") then root.AternityGyro:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AternityVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.Name = "AternityGyro"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    bg.Parent = root

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = workspace

    local startHighPos = Vector3.new(root.Position.X, targetCFrame.Position.Y + 120, root.Position.Z)
    root.CFrame = CFrame.new(startHighPos)
    task.wait(0.05)

    while getgenv().AternityConfig.AutoFarm or getgenv().AternityConfig.AutoChest do
        local flatTarget = Vector3.new(targetCFrame.Position.X, root.Position.Y, targetCFrame.Position.Z)
        local currentDist = (root.Position - flatTarget).Magnitude
        
        if currentDist < 12 then break end

        local dir = (flatTarget - root.Position).Unit
        bv.Velocity = dir * getgenv().AternityConfig.FlightSpeed
        bg.CFrame = CFrame.lookAt(root.Position, flatTarget)
        platform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        game:GetService("RunService").Heartbeat:Wait()
    end

    bv:Destroy()
    bg:Destroy()
    platform:Destroy()
    root.Velocity = Vector3.new(0, 0, 0)
    root.CFrame = targetCFrame
end

-- 3. АВТОПРИРАВНИВАНИЕ ОРУЖИЯ С НАПОМИНАНИЕМ ПРОВЕРКИ СТАТОВ
local function EquipWeapon()
    pcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == getgenv().AternityConfig.SelectedWeapon or string.find(tool.Name, "Fruit")) then return end
        end
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == getgenv().AternityConfig.SelectedWeapon or string.find(tool.Name, "Fruit")) then
                character.Humanoid:EquipTool(tool)
                break
            end
        end
    end)
end

-- 4. ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ ЦИКЛИЧНОГО АВТОФАРМА (SPOT-ANCHORED SYSTEM)
function runMainAutomationLoop()
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
                    -- Направляемся к NPC за квестом
                    local npc = FindValidTarget(currentTarget.QuestNPC)
                    if npc then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.4)
                        fireGameRemote("StartQuest", currentTarget.Quest, currentTarget.QuestID)
                        task.wait(0.3)
                    end
                else
                    -- Квест активен. Летим в геометрический центр спота мобов
                    local farmPosition = currentTarget.Spot * CFrame.new(0, 7.5, 0)
                    SecureTeleport(farmPosition)
                    
                    character.Humanoid.PlatformStand = true
                    
                    while getgenv().AternityConfig.AutoFarm and mainGui.Quest.Visible do
                        local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
                        local hasMobsOnSpot = false
                        
                        for _, obj in pairs(enemyFolder:GetChildren()) do
                            if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                hasMobsOnSpot = true
                                obj.HumanoidRootPart.CanCollide = false
                                
                                -- Клиентская фиксация без импульса коллизии
                                obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                obj.HumanoidRootPart.CFrame = currentTarget.Spot
                                
                                -- Раздутие хитбокса до 35 блоков (Метод Redz Hub)
                                if obj.HumanoidRootPart:IsA("Part") or obj.HumanoidRootPart:IsA("MeshPart") then
                                    obj.HumanoidRootPart.Size = Vector3.new(35, 35, 35)
                                    obj.HumanoidRootPart.Transparency = 0.85
                                end
                                if obj:FindFirstChild("AttackParts") then obj.AttackParts:Destroy() end
                            end
                        end
                        
                        -- Цикл ожидания респавна у квестовика
                        if not hasMobsOnSpot then
                            local npc = FindValidTarget(currentTarget.QuestNPC)
                            if npc then SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)) end
                            task.wait(1)
                        end
                        game:GetService("RunService").Heartbeat:Wait()
                    end
                end
            end)
            task.wait(0.3)
        end
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false end)
    end)
end

-- Вспомогательный глубокий поиск целей
function FindValidTarget(name)
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

-- 5. АВТОПРОКАЧКА СТАТОВ И КЛИКЕР ТРИГГЕРЫ
task.spawn(function()
    while task.wait(1) do
        if getgenv().AternityConfig.AutoStats then
            pcall(function()
                local points = game.Players.LocalPlayer.Data.Points.Value
                if points > 0 then fireGameRemote("AddPoint", getgenv().AternityConfig.SelectedStat, points) end
            end)
        end
    end
end)

task.spawn(function()
    local vim = game:GetService("VirtualInputManager")
    while task.wait(0.08) do
        if getgenv().AternityConfig.AutoClick and (getgenv().AternityConfig.AutoFarm) then
            pcall(function()
                EquipWeapon()
                vim:SendMouseButtonEvent(10, 10, 0, true, game, 1)
                vim:SendMouseButtonEvent(10, 10, 0, false, game, 1)
            end)
        end
    end
end)

-- 6. ДОПОЛНИТЕЛЬНЫЕ ИСПОЛНИТЕЛЬНЫЕ ПОТОКИ (CHESTS & ESP)
function runChestAutomationLoop()
    task.spawn(function()
        while getgenv().AternityConfig.AutoChest do
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        SecureTeleport(obj.CFrame)
                        task.wait(0.4)
                        break
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local espCache = {}
task.spawn(function()
        while true do
            if getgenv().AternityConfig.VisualESP then
                pcall(function()
                    for _, obj in pairs(workspace:GetChildren()) do
                        if (string.find(obj.Name, "Chest") and obj:IsA("Part")) or (string.find(obj.Name:lower(), "fruit") and obj:IsA("Tool")) then
                            if not espCache[obj] then
                                local box = Instance.new("BoxHandleAdornment", obj)
                                box.Size = obj:IsA("Part") and obj.Size or Vector3.new(4, 4, 4)
                                box.AlwaysOnTop = true
                                box.Color3 = obj:IsA("Part") and Color3.fromRGB(0, 255, 204) or Color3.fromRGB(255, 0, 150)
                                box.Adornee = obj
                                
                                local billboard = Instance.new("BillboardGui", obj)
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
                                
                                espCache[obj] = {b = box, g = billboard}
                            end
                        end
                    end
                end)
                task.wait(1)
            else
                for obj, inst in pairs(espCache) do
                    if inst.b then inst.b:Destroy() end
                    if inst.g then inst.g:Destroy() end
                end
                table.clear(espCache)
                task.wait(0.5)
            end
        end
    end)
end)

print("[ATERNITY STEP 5] Все исполнительные движки Redz-уровня успешно развернуты.")
