--======================================================================--
--                       ATERNITY HUB — STEP 1: STEALTH UI ENGINE       --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- Глобальное хранилище конфигурации софта
getgenv().AternityConfig = {
    AutoFarm = false, FastAttack = false, AutoClick = false, AutoChest = false,
    AutoStats = false, SelectedStat = "Melee", SelectedWeapon = "Blox Fruit",
    FlightSpeed = 280, VisualESP = false, AntiServerLag = true, SafeMode = true
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. ЭКРАННЫЙ КОНТЕЙНЕР
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityStealthX"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

-- 2. ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА (Строгий матовый стиль Dark Obsidian)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 27) -- Глубокий матовый темный
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Строгая, тонкая темно-серая разграничительная рамка (Вместо неона)
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Thickness = 1
FrameStroke.Color = Color3.fromRGB(45, 48, 58)
FrameStroke.ApplyStrokeMode = Enum.StrokeMode.Border

-- 3. ВЕРХНЯЯ ПАНЕЛЬ УПРАВЛЕНИЯ (Header)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(26, 29, 36) -- Чуть светлее основы для объема
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)

local HeaderLine = Instance.new("Frame", Header)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 3

-- Заголовок софта (Мягкий белый цвет текста)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY OVERLORD"
Title.TextColor3 = Color3.fromRGB(240, 242, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- Датчик производительности (FPS и Пинг)
local InfoLabel = Instance.new("TextLabel", Header)
InfoLabel.Size = UDim2.new(0, 150, 1, 0)
InfoLabel.Position = UDim2.new(1, -210, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FPS: -- | PING: --"
InfoLabel.TextColor3 = Color3.fromRGB(110, 115, 125)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Right
InfoLabel.ZIndex = 3

task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        if os.clock() - lastTime >= 1 then
            local ping = tonumber(string.format("%.0f", LocalPlayer:GetNetworkPing() * 1000)) or 0
            InfoLabel.Text = "FPS: " .. frameCount .. " | PING: " .. ping .. "ms"
            frameCount = 0
            lastTime = os.clock()
        end
    end)
end)

-- Строгая кнопка закрытия
local ToggleKeyBtn = Instance.new("TextButton", Header)
ToggleKeyBtn.Size = UDim2.new(0, 24, 0, 24)
ToggleKeyBtn.Position = UDim2.new(1, -38, 0, 9)
ToggleKeyBtn.BackgroundColor3 = Color3.fromRGB(38, 42, 53)
ToggleKeyBtn.Text = "×"
ToggleKeyBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
ToggleKeyBtn.Font = Enum.Font.GothamBold
ToggleKeyBtn.TextSize = 14
ToggleKeyBtn.ZIndex = 3
Instance.new("UICorner", ToggleKeyBtn).CornerRadius = UDim.new(0, 4)

local uiClosed = false
ToggleKeyBtn.Activated:Connect(function()
    uiClosed = not uiClosed
    MainFrame.Visible = not uiClosed
end)

-- Плавное и точное перетаскивание за шапку
local dragToggle, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

print("[ATERNITY STEP 1] Строгое Obsidian-ядро успешно развернуто.")
--======================================================================--
--                       ATERNITY HUB — STEP 2: FIX LOGIC & SIDEBAR     --
--======================================================================--

-- 1. СТАБИЛЬНЫЙ ПЕРЕХВАТ ПИНГА И FPS ЧЕРЕЗ СЛУЖБУ СТАТИСТИКИ ROBLOX
task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    local statsService = game:GetService("Stats")
    
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        if os.clock() - lastTime >= 1 then
            pcall(function()
                -- Метод прямого чтения сетевого пинга из системного коннекта
                local networkStats = statsService:FindFirstChild("Network")
                local ping = networkStats and math.floor(networkStats.ServerPing.Value) or 0
                
                -- Запись стабильных значений в текстовое поле хедера
                if InfoLabel then
                    InfoLabel.Text = "FPS: " .. frameCount .. " | PING: " .. ping .. "ms"
                end
            end)
            frameCount = 0
            lastTime = os.clock()
        end
    end)
end)

-- 2. СТРОГАЯ МАТОВАЯ ЛЕВАТЯ ПАНЕЛЬ НАВИГАЦИИ (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 22) -- Более темный матовый тон для контраста
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

-- Правая разделительная линия для боковой панели
local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 3

-- Автоматический список для вертикального выстраивания строгого меню вкладок
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 12)

-- 3. ПРАВЫЙ ОСНОВНОЙ КОНТЕЙНЕР ДЛЯ СТРАНИЦ С ФУНКЦИЯМИ
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -152, 1, -52)
Container.Position = UDim2.new(0, 146, 0, 47)
Container.BackgroundTransparency = 1
Container.ZIndex = 2

print("[ATERNITY STEP 2] Навигационные панели Dark Obsidian развернуты. Счетчики запущены.")
