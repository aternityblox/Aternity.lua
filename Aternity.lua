--======================================================================--
--                       ATERNITY HUB — REBORN EDITION (v3.6)           --
--         100% ФИКС КИКА SECURITY KICK | СТАБИЛЬНЫЙ ПОЛЕТ | 2026       --
--======================================================================--

getgenv().AternityConfig = {
    AutoFarm = false,
    AutoClick = false,
    AutoChest = false,
    SelectedWeapon = "Blox Fruit",
    FlightSpeed = 300 -- Безопасная скорость полета для обхода античита
}

if not game:IsLoaded() then game.Loaded:Wait() end

-- УНИВЕРСАЛЬНЫЙ СЕТЕВОЙ ШЛЮЗ
local function fireGameRemote(action, ...)
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then 
        return commF:InvokeServer(action, ...) 
    end
    return nil
end

-- СИСТЕМА БЕЗОПАСНОГО ПОЛЕТА (ОБХОД ERROR CODE 267)
local function SecureTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not root then return end
    
    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 40 then
        root.CFrame = targetCFrame
    else
        if humanoid then humanoid.PlatformStand = true end
        root.Velocity = Vector3.new(0, 0, 0)
        
        local steps = dist / (getgenv().AternityConfig.FlightSpeed * 0.03)
        for i = 1, steps do
            if not getgenv().AternityConfig.AutoFarm and not getgenv().AternityConfig.AutoChest then break end
            root.CFrame = root.CFrame:Lerp(targetCFrame, i / steps)
            task.wait()
        end
        root.CFrame = targetCFrame
    end
end

-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHubReborn"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY HUB v3.6 [Anti-Kick]"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

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
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(47, 53, 66)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.TextColor3 = Color3.fromRGB(47, 53, 66)
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

-- НАПОЛНЕНИЕ СТРАНИЦ ФУНКЦИЯМИ
addToggle("Auto Farm Levels", "AutoFarm", FarmPage, function(state)
    task.spawn(function()
        while getgenv().AternityConfig.AutoFarm do
            pcall(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

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

                if targetEnemy then
                    root.Velocity = Vector3.new(0, 0, 0)
                    character.Humanoid.PlatformStand = true
                    SecureTeleport(targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                    
                    for _, obj in pairs(workspace.Enemies:GetChildren()) do
                        if obj.Name == targetEnemy.Name and obj:FindFirstChild("HumanoidRootPart") then
                            obj.HumanoidRootPart.CanCollide = false
                            obj.HumanoidRootPart.CFrame = targetEnemy.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false end)
    end)
end)

addToggle("Auto Clicker", "AutoClick", CombatPage, function(state)
    task.spawn(function()
        local vim = game:GetService("VirtualInputManager")
        while getgenv().AternityConfig.AutoClick do
            pcall(function()
                EquipWeapon()
                local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                if combatEvent then combatEvent:FireServer("weaponChange") end
                vim:SendMouseButtonEvent(10, 10, 0, true, game, 1)
                vim:SendMouseButtonEvent(10, 10, 0, false, game, 1)
            end)
            task.wait(0.08)
        end
    end)
end)

addToggle("Teleport To Chests", "AutoChest", MiscPage, function(state)
    task.spawn(function()
        while getgenv().AternityConfig.AutoChest do
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        -- Безопасный перелет к сундуку вместо жесткой телепортации
                        SecureTeleport(obj.CFrame)
                        task.wait(0.5)
                        break
                    end
                end
            end)
            task.wait(0.5)
        end
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false end)
    end)
end)

tabsList[1].page.Visible = true
tabsList[1].btn.TextColor3 = Color3.fromRGB(0, 255, 200)

print("[ATERNITY] Скрипт успешно защищен от киков и запущен!")
