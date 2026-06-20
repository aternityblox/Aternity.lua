--======================================================================--
--                       ATERNITY HUB — REBORN EDITION (v4.4)           --
--         ФИНАЛЬНЫЙ СТАБИЛЬНЫЙ МОНОЛИТ ДЛЯ TIKI OUTPOST | 2026         --
--======================================================================--

getgenv().AternityConfig = {
    AutoFarm = false,
    AutoClick = false,
    AutoChest = false,
    SelectedWeapon = "Blox Fruit",
    FlightSpeed = 250
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

-- АКТУАЛИЗИРОВАННАЯ БАЗА ДАННЫХ TIKI OUTPOST И ДРУГИХ МОРЕЙ
local SeaMobData = {
    [1] = {
        {MinLvl = 1, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1},
        {MinLvl = 10, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1},
        {MinLvl = 15, Name = "Gorilla", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 2},
        {MinLvl = 30, Name = "Pirate", QuestNPC = "Pirate Adventurer", Quest = "PirateIslandQuest", QuestID = 1}
    },
    [2] = {
        {MinLvl = 700, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1},
        {MinLvl = 775, Name = "Mercenary", QuestNPC = "Quest Giver", Quest = "Area2Quest", QuestID = 1},
        {MinLvl = 875, Name = "Swan Pirate", QuestNPC = "Quest Giver", Quest = "Area2Quest", QuestID = 2}
    },
    [3] = {
        {MinLvl = 1500, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1},
        {MinLvl = 1575, Name = "Pistol Billionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 2},
        {MinLvl = 1650, Name = "Dragon Crew Warrior", QuestNPC = "Floating Turtle Quest Giver", Quest = "FloatingTurtleQuest", QuestID = 1},
        {MinLvl = 1725, Name = "Dragon Crew Archer", QuestNPC = "Floating Turtle Quest Giver", Quest = "FloatingTurtleQuest", QuestID = 2},
        {MinLvl = 1825, Name = "Superhuman", QuestNPC = "Castle Quest Giver", Quest = "CastleQuest", QuestID = 1},
        {MinLvl = 2200, Name = "Cookie Commando", QuestNPC = "Ice Cream Chef", Quest = "IceCreamIslandQuest", QuestID = 1},
        {MinLvl = 2300, Name = "Cake Guard", QuestNPC = "Cake Chef", Quest = "CakeIslandQuest", QuestID = 1},
        {MinLvl = 2400, Name = "Baking Warrior", QuestNPC = "Sweet Chef", Quest = "SweetIslandQuest", QuestID = 1},
        
        -- СТРОГИЙ ФИКС ДЛЯ ВАШЕГО ТЕКУЩЕГО УРОВНЯ НА ТИКИ АВАНПОСТЕ (2461 LVL)
        {MinLvl = 2450, Name = "Isle Outlaw", QuestNPC = "Tiki Quest Giver", Quest = "TikiOutpostQuest", QuestID = 1},
        {MinLvl = 2525, Name = "Island Boy", QuestNPC = "Tiki Quest Giver", Quest = "TikiOutpostQuest", QuestID = 2},
        
        {MinLvl = 2700, Name = "Prehistoric Warrior", QuestNPC = "Ancient Quest Giver", Quest = "PrehistoricQuest", QuestID = 1},
        {MinLvl = 2750, Name = "Ancient Guardian", QuestNPC = "Ancient Quest Giver", Quest = "GuardianQuest", QuestID = 1},
        {MinLvl = 2800, Name = "Aternity Abyss Slayer", QuestNPC = "Abyss Quest Giver", Quest = "AbyssQuest", QuestID = 1}
    }
}

-- Автоматическое определение текущего моря игрока
local placeId = game.PlaceId
local currentSea = 1
if placeId == 2753915549 then currentSea = 1
elseif placeId == 4442272121 then currentSea = 2
elseif placeId == 7405815088 then currentSea = 3 end

-- Функция точной проверки уровня и выбора подходящего моба
local function GetMyTargetMob()
    local myLevel = game.Players.LocalPlayer.Data.Level.Value
    local currentSeaData = SeaMobData[currentSea] or SeaMobData
    local target = currentSeaData[1]
    
    for _, mob in ipairs(currentSeaData) do
        if myLevel >= mob.MinLvl and mob.MinLvl >= target.MinLvl then 
            target = mob 
        end
    end
    return target
end

-- НАДЕЖНЫЙ ФИЗИЧЕСКИЙ ПОЛЕТ (BODYVELOCITY-БАЙПАС)
local function SecureTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 35 then
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

    while getgenv().AternityConfig.AutoFarm or getgenv().AternityConfig.AutoChest do
        if not root or not root.Parent then break end
        local currentDist = (root.Position - targetCFrame.Position).Magnitude
        if currentDist < 15 then break end

        local dir = (targetCFrame.Position - root.Position).Unit
        bv.Velocity = dir * getgenv().AternityConfig.FlightSpeed
        bg.CFrame = CFrame.lookAt(root.Position, targetCFrame.Position)
        platform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        task.wait()
    end

    bv:Destroy()
    bg:Destroy()
    platform:Destroy()
    root.Velocity = Vector3.new(0, 0, 0)
    root.CFrame = targetCFrame
end

-- ГЛУБОКИЙ ПОИСК ЦЕЛЕЙ НА КАРТЕ (NPC И МОБЫ)
local function FindValidTarget(name)
    local locations = {workspace, workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs")}
    for _, folder in pairs(locations) do
        if folder then
            local found = folder:FindFirstChild(name)
            if found and found:FindFirstChild("HumanoidRootPart") then return found end
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and (obj:IsA("Model") or obj:IsA("Part")) and obj:FindFirstChild("HumanoidRootPart") then
            return obj
        end
    end
    return nil
end

-- ИНИЦИАЛИЗАЦИЯ UI
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
Title.Text = "ATERNITY HUB v4.4 [Tiki Outpost]"
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
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = "  " .. name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(47, 53, 66)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 11
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.Activated:Connect(function()
        getgenv().AternityConfig[prop] = not getgenv().AternityConfig[prop]
        local state = getgenv().AternityConfig[prop]
        Btn.Text = state and "  " .. name .. ": ON" or "  " .. name .. ": OFF"
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(47, 53, 66)
        if callback then callback(state) end
    end)
end

local function EquipWeapon()
    pcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == getgenv().AternityConfig.SelectedWeapon or string.find(tool.Name, "Fruit")) then 
                return 
            end
        end
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == getgenv().AternityConfig.SelectedWeapon or string.find(tool.Name, "Fruit")) then
                character.Humanoid:EquipTool(tool)
                break
            end
        end
    end)
end

-- ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ СИНХРОНИЗИРОВАННОГО АВТОФАРМА (TIKI ВЕРИФИКАЦИЯ)
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
                    -- 1. Летим к Tiki Quest Giver на аванпост
                    local npc = FindValidTarget(currentTarget.QuestNPC)
                    if npc then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.5) -- Оптимальная задержка перед диалогом
                        fireGameRemote("StartQuest", currentTarget.Quest, currentTarget.QuestID)
                    end
                else
                    -- 2. Квест взят, летим зачищать Isle Outlaw / Island Boy
                    local mob = FindValidTarget(currentTarget.Name)
                    if mob and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        mob.HumanoidRootPart.CanCollide = false
                        if mob:FindFirstChild("AttackParts") then 
                            mob.AttackParts:Destroy() 
                        end
                        
                        character.Humanoid.PlatformStand = true
                        local farmPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8.5, 0)
                        
                        while getgenv().AternityConfig.AutoFarm and mob.Humanoid.Health > 0 and mainGui.Quest.Visible do
                            SecureTeleport(farmPos)
                            -- Стабилизированное стягивание пачки
                            local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
                            for _, obj in pairs(enemyFolder:GetChildren()) do
                                if obj.Name == currentTarget.Name and obj:FindFirstChild("HumanoidRootPart") then
                                    obj.HumanoidRootPart.CanCollide = false
                                    obj.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame
                                end
                            end
                            task.wait()
                        end
                    else
                        -- Если мобов на споте нет, летим караулить точку спавна
                        local spawners = workspace:FindFirstChild("EnemySpawns") or workspace:FindFirstChild("Spawners")
                        if spawners and spawners:FindFirstChild(currentTarget.Name) then
                            SecureTeleport(spawners[currentTarget.Name].CFrame * CFrame.new(0, 15, 0))
                        end
                    end
                end
            end)
            task.wait(0.4)
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

print("[ATERNITY] Сборка v4.4 для аванпоста Tiki успешно запущена!")
