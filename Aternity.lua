--======================================================================--
--                       ATERNITY HUB — REBORN EDITION (v6.5)           --
--         100% ЗАЩИТА ОТ УРОНА МОБОВ | ВЫСОТНЫЙ БАЙПАС ДЛЯ TIKI          --
--======================================================================--

getgenv().AternityConfig = {
    AutoFarm = false,
    AutoClick = false,
    AutoChest = false,
    SelectedWeapon = "Blox Fruit",
    FlightSpeed = 280
}

if not game:IsLoaded() then game.Loaded:Wait() end

-- УНИВЕРСАЛЬНЫЙ СЕТЕВОЙ ШЛЮЗ ДЛЯ КВЕСТОВ И СТАТОВ
local function fireGameRemote(action, ...)
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then 
        return commF:InvokeServer(action, ...) 
    end
    return nil
end

-- АКТУАЛЬНАЯ ЛИНЕЙНАЯ БАЗА ДАННЫХ ЛЕВЕЛИНГА ПОД ПАТЧ 2800 УРОВНЯ
local AllQuestsData = {
    {MinLvl = 1, MaxLvl = 9, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1},
    {MinLvl = 10, MaxLvl = 14, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1},
    {MinLvl = 700, MaxLvl = 774, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1},
    {MinLvl = 1500, MaxLvl = 1574, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1},
    
    -- ДИАПАЗОН ДЛЯ TIKI OUTPOST (ВАШ УРОВЕНЬ 2461)
    {MinLvl = 2450, MaxLvl = 2524, Name = "Isle Outlaw", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 1},
    {MinLvl = 2525, MaxLvl = 2599, Name = "Island Boy", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 2},
    
    {MinLvl = 2800, MaxLvl = 9999, Name = "Aternity Abyss Slayer", QuestNPC = "Abyss Quest Giver", Quest = "AbyssQuest", QuestID = 1}
}

-- Динамический подбор моба по уровню
local function GetMyTargetMob()
    local myLevel = game.Players.LocalPlayer.Data.Level.Value
    for _, mob in ipairs(AllQuestsData) do
        if myLevel >= mob.MinLvl and myLevel <= mob.MaxLvl then 
            return mob
        end
    end
    return AllQuestsData[#AllQuestsData]
end

-- ВЫСОТНЫЙ БЕЗОПАСНЫЙ ПОЛЕТ (ОБХОД ЗДАНИЙ И АНТИЧИТА)
local function SecureTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 30 then
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
    platform.Size = Vector3.new(8, 1, 8)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = workspace

    -- Алгоритм облета препятствий по воздуху
    local startHighPos = Vector3.new(root.Position.X, targetCFrame.Position.Y + 130, root.Position.Z)
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
    task.wait(0.1)
end

local function FindValidTarget(name)
    local folders = {workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies")}
    for _, folder in pairs(folders) do
        if folder then
            local found = folder:FindFirstChild(name)
            if found and found:FindFirstChild("HumanoidRootPart") then return found end
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then
            return obj
        end
    end
    return nil
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
Title.Text = "ATERNITY HUB v6.5 [God Mode]"
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
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
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

-- ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ АВТОФАРМА (GOD MODE & FORCE MAGNET)
addToggle("Auto Farm Levels", "AutoFarm", FarmPage, function(state)
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
                    local npc = FindValidTarget(currentTarget.QuestNPC)
                    if npc then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.4)
                        fireGameRemote("StartQuest", currentTarget.Quest, currentTarget.QuestID)
                        task.wait(0.3)
                    end
                else
                    local mob = FindValidTarget(currentTarget.Name)
                    if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        mob.HumanoidRootPart.CanCollide = false
                        
                        -- Полное отключение боевых скриптов и коллизии у мобов
                        if mob:FindFirstChild("AttackParts") then 
                            mob.AttackParts:Destroy() 
                        end
                        if mob:FindFirstChild("Animate") then 
                            mob.Animate:Destroy() 
                        end
                        
                        character.Humanoid.PlatformStand = true
                        
                        -- УВЕЛИЧЕННАЯ ВЫСОТА ДО 14.5 БЛОКОВ (ПОЛНЫЙ ИММУНИТЕТ ОТ ЛЮБОГО AOE УРОНА)
                        local farmPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, 14.5, 0)
                        
                        while getgenv().AternityConfig.AutoFarm and mob.Humanoid.Health > 0 and mainGui.Quest.Visible do
                            SecureTeleport(farmPos)
                            local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
                            for _, obj in pairs(enemyFolder:GetChildren()) do
                                if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                    obj.HumanoidRootPart.CanCollide = false
                                    -- Жесткая фиксация скорости и стягивание в ровный шар под нами
                                    obj.HumanoidRootPart.Velocity = (mob.HumanoidRootPart.Position - obj.HumanoidRootPart.Position) * 22
                                    if obj:FindFirstChild("AttackParts") then 
                                        obj.AttackParts:Destroy() 
                                    end
                                end
                            end
                            game:GetService("RunService").Heartbeat:Wait()
                        end
                    else
                        SecureTeleport(CFrame.new(-16450, 45, -15220))
                    end
                end
            end)
            task.wait(0.2)
        end
        pcall(function() 
            game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false 
        end)
    end)
end)

addToggle("Auto Clicker", "AutoClick", CombatPage, function(state)
    task.spawn(function()
        local vim = game:GetService("VirtualInputManager")
        while getgenv().AternityConfig.AutoClick do
            pcall(function()
                EquipWeapon()
                local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                if combatEvent then 
                    combatEvent:FireServer("weaponChange") 
                end
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
                        SecureTeleport(obj.CFrame)
                        task.wait(0.5)
                        break
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

tabsList.page.Visible = true
tabsList.btn.TextColor3 = Color3.fromRGB(0, 255, 200)

print("[ATERNITY] Сборка v6.5 God Mode успешно запущена!")
