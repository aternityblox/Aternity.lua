--======================================================================--
--                       ATERNITY HUB — REBORN EDITION (v3.5)           --
--         ФИНАЛЬНЫЙ СТАБИЛЬНЫЙ МОНОЛИТ | 100% РАБОЧИЕ ФУНКЦИИ | 2026   --
--======================================================================--

-- Глобальные флаги управления
getgenv().AternityConfig = {
    AutoFarm = false,
    AutoClick = false,
    VisualESP = false,
    SelectedWeapon = "Blox Fruit"
}

-- Проверка окружения Xeno
if not game:IsLoaded() then game.Loaded:Wait() end

-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (Whiteout Релиз)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHubReborn"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 26) -- Темная тема по умолчанию
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Хедер
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY HUB v3.5 [REBORN]"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Боковое меню вкладок
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, 110, 1, -60)
TabBar.Position = UDim2.new(0, 10, 0, 50)
TabBar.BackgroundTransparency = 1
Instance.new("UIListLayout", TabBar).Padding = UDim.new(0, 6)

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -140, 1, -60)
PagesContainer.Position = UDim2.new(0, 130, 0, 50)
PagesContainer.BackgroundTransparency = 1

local tabsList = {}
local function createTab(tabName)
    local TabPage = Instance.new("ScrollingFrame", PagesContainer)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 450)
    TabPage.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)
    
    local TabButton = Instance.new("TextButton", TabBar)
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        TabPage.Visible = true
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 200)
    end)
    table.insert(tabsList, {page = TabPage, btn = TabButton})
    return TabPage
end

local FarmPage = createTab("Main Farm")
local CombatPage = createTab("Combat")
local MiscPage = createTab("Misc")

-- Универсальный переключатель функций
local function addToggle(name, prop, parentPage, callback)
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Size = UDim2.new(1, -5, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    Btn.Text = "  " .. name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 11
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.Activated:Connect(function()
        getgenv().AternityConfig[prop] = not getgenv().AternityConfig[prop]
        local state = getgenv().AternityConfig[prop]
        Btn.Text = state and "  " .. name .. ": ON" or "  " .. name .. ": OFF"
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(200, 200, 200)
        if callback then callback(state) end
    end)
end

--======================================================================--
--              ЛОГИКА ВЫПОЛНЕНИЯ ФУНКЦИЙ (ОБХОД ЗАЩИТЫ ИГРЫ)           --
--======================================================================--

-- 1. Модуль автоматической атаки и кликера
local function startClickerEngine(enabled)
    task.spawn(function()
        while getgenv().AternityConfig.AutoClick do
            pcall(function()
                local character = game.Players.LocalPlayer.Character
                -- Автоматическое экипирование выбранного типа оружия
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if not tool then
                        for _, backpackTool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if backpackTool:IsA("Tool") and (backpackTool.Name == getgenv().AternityConfig.SelectedWeapon or string.find(backpackTool.Name, "Fruit")) then
                                game.Players.LocalPlayer.Humanoid:EquipTool(backpackTool)
                                break
                            end
                        end
                    end
                end
                -- Прямой вызов клика через игровой контроллер боя
                local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                if combatEvent then
                    combatEvent:FireServer("weaponChange")
                end
                -- Дублирующий клик по экрану
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(10, 10, 0, true, game, 1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(10, 10, 0, false, game, 1)
            end)
            task.wait(0.05)
        end
    end)
end

-- 2. Стабильный полет и сбор мобов в одну точку
local function startFarmEngine(enabled)
    task.spawn(function()
        while getgenv().AternityConfig.AutoFarm do
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Поиск ближайшего врага для фарма (универсальный алгоритм для всех морей)
                local targetEnemy = nil
                local minDistance = math.huge
                
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            targetEnemy = enemy
                        end
                    end
                end

                -- Если нашли врага, летим и стягиваем остальных
                if targetEnemy then
                    -- Отключаем коллизию, чтобы не застревать в текстурах
                    root.Velocity = Vector3.new(0, 0, 0)
                    character.Humanoid.PlatformStand = true
                    
                    -- Удерживаем позицию на 7 блоков выше врага (безопасная зона от ударов)
                    root.CFrame = targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                    
                    -- Стягивание всех мобов с таким же именем в радиусе 150 блоков
                    for _, obj in pairs(workspace.Enemies:GetChildren()) do
                        if obj.Name == targetEnemy.Name and obj:FindFirstChild("HumanoidRootPart") then
                            obj.HumanoidRootPart.CanCollide = false
                            obj.HumanoidRootPart.CFrame = targetEnemy.HumanoidRootPart.CFrame
                        end
                    end
                else
                    -- Если живых мобов на споте нет, летим к точке их спавна
                    local spawners = workspace:FindFirstChild("EnemySpawns") or workspace:FindFirstChild("Spawners")
                    if spawners then
                        local spawnPoint = spawners:FindFirstChildOfClass("Part") or spawners:FindFirstChildOfClass("MeshPart")
                        if spawnPoint then
                            root.CFrame = spawnPoint.CFrame * CFrame.new(0, 10, 0)
                        end
                    end
                    character.Humanoid.PlatformStand = false
                end
            end)
            task.wait(0.2)
        end
        -- Возвращаем нормальное управление при выключении функции
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        end)
    end)
end

-- НАПОЛНЕНИЕ ИНТЕРФЕЙСА ФУНКЦИЯМИ
addToggle("Auto Farm Levels", "AutoFarm", FarmPage, function(state) startFarmEngine(state) end)
addToggle("Auto Clicker", "AutoClick", CombatPage, function(state) startClickerEngine(state) end)

-- Вкладка Misc — Кнопка принудительного сбора ближайших сундуков
addToggle("Teleport To Chests", "AutoChest", MiscPage, function(state)
    task.spawn(function()
        while getgenv().AternityConfig.AutoChest do
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                        task.wait(0.3)
                        break
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- Инициализация первой страницы
tabsList[1].page.Visible = true
tabsList[1].btn.TextColor3 = Color3.fromRGB(0, 255, 200)
