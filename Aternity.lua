--======================================================================--
--                       ATERNITY HUB — STEP 1-3: OBSIDIAN CORE ENGINE  --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ ФЛАГОВ СОФТА
getgenv().AternityConfig = {
    AutoFarm = false, FastAttack = false, AutoClick = false, AutoChest = false,
    AutoStats = false, SelectedStat = "Melee", SelectedWeapon = "Blox Fruit",
    FlightSpeed = 280, VisualESP = false
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 2. ЭКРАННЫЙ КОНТЕЙНЕР ДЛЯ СБОРКИ UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityObsidianX"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

-- 3. ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА (Строгий матовый стиль Dark Obsidian)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 540, 0, 370)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Тонкая серая рамка
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Thickness = 1
FrameStroke.Color = Color3.fromRGB(45, 48, 58)
FrameStroke.ApplyStrokeMode = Enum.StrokeMode.Border

-- 4. ВЕРХНЯЯ ПАНЕЛЬ С УПРАВЛЕНИЕМ (Header)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)

local HeaderLine = Instance.new("Frame", Header)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 3

-- Текст заголовка
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY OVERLORD v12.5"
Title.TextColor3 = Color3.fromRGB(240, 242, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- Кнопка закрытия
local ToggleKeyBtn = Instance.new("TextButton", Header)
ToggleKeyBtn.Size = UDim2.new(0, 24, 0, 24)
ToggleKeyBtn.Position = UDim2.new(1, -36, 0, 8)
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

-- Плавный драггинг
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

-- 5. БОКОВАЯ ПАНЕЛЬ НАВИГАЦИИ (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 135, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 3

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)

-- 6. ОСНОВНОЙ КОНТЕЙНЕР ДЛЯ РАЗМЕЩЕНИЯ СТРАНИЦ ФУНКЦИЙ
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -145, 1, -50)
Container.Position = UDim2.new(0, 140, 0, 45)
Container.BackgroundTransparency = 1
Container.ZIndex = 2

local tabsList = {}

-- Фабрика кастомных матовых страниц
local function AddTab(name)
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 500)
    TabPage.ScrollBarThickness = 2
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(55, 60, 75)
    TabPage.ZIndex = 3
    
    local PageLayout = Instance.new("UIListLayout", TabPage)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local TabButton = Instance.new("TextButton", Sidebar)
    TabButton.Size = UDim2.new(0, 120, 0, 32)
    TabButton.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(150, 155, 165)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.ZIndex = 3
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)
    
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
            tab.btn.TextColor3 = Color3.fromRGB(150, 155, 165)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(38, 42, 53)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(tabsList, {page = TabPage, btn = TabButton})
    if #tabsList == 1 then
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(38, 42, 53)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    return TabPage
end

-- СИСТЕМНАЯ РЕГИСТРАЦИЯ ВКЛАДОК МЕНЮ
local FarmPage = AddTab("Main Farm")
local CombatPage = AddTab("Combat Core")
local TeleportPage = AddTab("Teleports")
local SettingsPage = AddTab("Settings")

print("[ATERNITY STEP 3] Панель, вкладки и Хедер полностью прогружены без лагов.")
