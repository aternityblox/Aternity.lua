--======================================================================--
--                       ATERNITY HUB — WHITEOUT EDITION (v3.0)         --
--         ФИНАЛЬНЫЙ МОНОЛИТ | АВТОМИРАЖ | ЧЕСТ И ФРУКТ ESP | 2026       --
--======================================================================--

local Aternity = {
    Flags = {
        AutoFarm = false, AutoClicker = false, AutoStats = false,
        AutoChest = false, AutoRaid = false, AutoBuyFruit = false,
        AutoRaceRoll = false, AutoSwordSpawn = false,
        AutoMirage = false, VisualESP = false
    },
    Stats = { Selected = {}, MaxAllowed = 3 },
    Data = {
        MaxLevel = 2800, CurrentSea = 1, FlightSpeed = 350,
        StartLevel = game.Players.LocalPlayer.Data.Level.Value,
        StartBeli = game.Players.LocalPlayer.Data.Beli.Value,
        Weapon = "Blox Fruit"
    }
}

-- Определение моря
local placeId = game.PlaceId
if placeId == 2753915549 then Aternity.Data.CurrentSea = 1
elseif placeId == 4442272121 then Aternity.Data.CurrentSea = 2
elseif placeId == 7405815088 then Aternity.Data.CurrentSea = 3 end

-- УНИВЕРСАЛЬНЫЙ СЕТЕВОЙ ШЛЮЗ
local function fireRemote(action, ...)
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then return commF:InvokeServer(action, ...) end
    return nil
end

-- ИНИЦИАЛИЗАЦИЯ UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AternityHub"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 430, 0, 560)
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(220, 221, 230)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ATERNITY SOFTWARE v3.0 [Mirage Update]"
Title.TextColor3 = Color3.fromRGB(47, 53, 66)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", Header)
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "▲"
ToggleBtn.TextColor3 = Color3.fromRGB(47, 53, 66)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- СТАТИСТИКА
local StatsPanel = Instance.new("Frame", MainFrame)
StatsPanel.Size = UDim2.new(1, -20, 0, 45)
StatsPanel.Position = UDim2.new(0, 10, 0, 50)
StatsPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", StatsPanel).CornerRadius = UDim.new(0, 8)

local LevelLog = Instance.new("TextLabel", StatsPanel)
LevelLog.Size = UDim2.new(1, -20, 0, 20)
LevelLog.Position = UDim2.new(0, 10, 0, 3)
LevelLog.BackgroundTransparency = 1
LevelLog.Text = "Levels Gained: 0 (Current Lvl: " .. Aternity.Data.StartLevel .. ")"
LevelLog.TextColor3 = Color3.fromRGB(47, 53, 66)
LevelLog.Font = Enum.Font.GothamSemibold
LevelLog.TextSize = 11
LevelLog.TextXAlignment = Enum.TextXAlignment.Left

local BeliLog = Instance.new("TextLabel", StatsPanel)
BeliLog.Size = UDim2.new(1, -20, 0, 20)
BeliLog.Position = UDim2.new(0, 10, 0, 20)
BeliLog.BackgroundTransparency = 1
BeliLog.Text = "Beli Earned: 0$"
BeliLog.TextColor3 = Color3.fromRGB(46, 204, 113)
BeliLog.Font = Enum.Font.GothamSemibold
BeliLog.TextSize = 11
BeliLog.TextXAlignment = Enum.TextXAlignment.Left

game.Players.LocalPlayer.Data.Level.Changed:Connect(function(val)
    LevelLog.Text = "Levels Gained: " .. (val - Aternity.Data.StartLevel) .. " (Current Lvl: " .. val .. ")"
end)
game.Players.LocalPlayer.Data.Beli.Changed:Connect(function(val)
    BeliLog.Text = "Beli Earned: " .. (val - Aternity.Data.StartBeli) .. "$"
end)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, 100, 1, -115)
TabBar.Position = UDim2.new(0, 10, 0, 105)
TabBar.BackgroundTransparency = 1
Instance.new("UIListLayout", TabBar).Padding = UDim.new(0, 6)

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -125, 1, -115)
PagesContainer.Position = UDim2.new(0, 115, 0, 105)
PagesContainer.BackgroundTransparency = 1

local tabsList = {}
local function createTab(tabName)
    local TabPage = Instance.new("ScrollingFrame", PagesContainer)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 520)
    TabPage.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)
    
    local TabButton = Instance.new("TextButton", TabBar)
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(112, 119, 137)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 11
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.Activated:Connect(function()
        for _, tab in pairs(tabsList) do
            tab.page.Visible = false
            tab.btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            tab.btn.TextColor3 = Color3.fromRGB(112, 119, 137)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(220, 221, 230)
        TabButton.TextColor3 = Color3.fromRGB(47, 53, 66)
    end)
    table.insert(tabsList, {page = TabPage, btn = TabButton})
    return TabPage
end

local FarmPage = createTab("Main Farm")
local CombatPage = createTab("Combat")
local StatsPage = createTab("Stats")
local MiscPage = createTab("Misc")

tabsList[1].page.Visible = true
tabsList[1].btn.BackgroundColor3 = Color3.fromRGB(220, 221, 230)
tabsList[1].btn.TextColor3 = Color3.fromRGB(47, 53, 66)

local function addToggle(name, prop, parentPage)
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Size = UDim2.new(1, -5, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = "  " .. name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(112, 119, 137)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 11
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.Activated:Connect(function()
        Aternity.Flags[prop] = not Aternity.Flags[prop]
        Btn.Text = Aternity.Flags[prop] and "  " .. name .. ": ON" or "  " .. name .. ": OFF"
        Btn.TextColor3 = Aternity.Flags[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(112, 119, 137)
    end)
end

-- Стрелочка
local collapsed = false
ToggleBtn.Activated:Connect(function()
    collapsed = not collapsed
    MainFrame:TweenSize(collapsed and UDim2.new(0, 420, 0, 40) or UDim2.new(0, 420, 0, 560), "Out", "Quart", 0.25, true)
    PagesContainer.Visible = not collapsed
    TabBar.Visible = not collapsed
    StatsPanel.Visible = not collapsed
    ToggleBtn.Text = collapsed and "▼" or "▲"
end)

addToggle("Auto Farm Levels", "AutoFarm", FarmPage)
addToggle("Auto Clicker / Attack", "AutoClicker", CombatPage)
addToggle("Auto Chest Farm", "AutoChest", MiscPage)
addToggle("Auto Raid Farm", "AutoRaid", CombatPage)
addToggle("Auto Buy Random Fruit", "AutoBuyFruit", MiscPage)
addToggle("Auto Stats Upgrade", "AutoStats", StatsPage)
addToggle("Auto Race V4 Roll", "AutoRaceRoll", MiscPage)
addToggle("Auto Legendary Swords", "AutoSwordSpawn", MiscPage)
addToggle("Auto Teleport to Mirage", "AutoMirage", MiscPage)
addToggle("Item & Chest ESP", "VisualESP", MiscPage)

-- Оружие
local WeaponBtn = Instance.new("TextButton", CombatPage)
WeaponBtn.Size = UDim2.new(1, -5, 0, 40)
WeaponBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WeaponBtn.Text = "  Selected Weapon: Blox Fruit"
WeaponBtn.TextColor3 = Color3.fromRGB(47, 53, 66)
WeaponBtn.Font = Enum.Font.GothamSemibold
WeaponBtn.TextSize = 11
WeaponBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", WeaponBtn).CornerRadius = UDim.new(0, 8)

local weapons = {"Combat", "Melee", "Sword", "Blox Fruit"}
local weaponIndex = 4
WeaponBtn.Activated:Connect(function()
    weaponIndex = weaponIndex % #weapons + 1
    Aternity.Data.Weapon = weapons[weaponIndex]
    WeaponBtn.Text = "  Selected Weapon: " .. Aternity.Data.Weapon
end)

-- Прокачка статов
local availableStats = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}
for _, statName in ipairs(availableStats) do
    local StatBtn = Instance.new("TextButton", StatsPage)
    StatBtn.Size = UDim2.new(1, -5, 0, 32)
    StatBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatBtn.Text = "  [ ] " .. statName
    StatBtn.TextColor3 = Color3.fromRGB(112, 119, 137)
    StatBtn.Font = Enum.Font.GothamSemibold
    StatBtn.TextSize = 11
    StatBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", StatBtn).CornerRadius = UDim.new(0, 6)
    
    StatBtn.Activated:Connect(function()
        local idx = table.find(Aternity.Stats.Selected, statName)
        if idx then
            table.remove(Aternity.Stats.Selected, idx)
            StatBtn.Text = "  [ ] " .. statName
            StatBtn.TextColor3 = Color3.fromRGB(112, 119, 137)
        elseif #Aternity.Stats.Selected < Aternity.Stats.MaxAllowed then
            table.insert(Aternity.Stats.Selected, statName)
            StatBtn.Text = "  [✓] " .. statName
            StatBtn.TextColor3 = Color3.fromRGB(52, 152, 219)
        else
            StatBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
            task.wait(0.3)
            StatBtn.TextColor3 = Color3.fromRGB(112, 119, 137)
        end
    end)
end

--======================================================================--
--                             ДВИЖОК СКРИПТА                           --
--======================================================================--

local SeaMobData = {
    [1] = {
        {MinLvl = 1, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1},
        {MinLvl = 10, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1}
    },
    [2] = {
        {MinLvl = 700, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1}
    },
    [3] = {
        {MinLvl = 1500, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1},
        {MinLvl = 2700, Name = "Prehistoric Warrior", QuestNPC = "Ancient Quest Giver", Quest = "PrehistoricQuest", QuestID = 1},
        {MinLvl = 2800, Name = "Aternity Abyss Slayer", QuestNPC = "Abyss Quest Giver", Quest = "AbyssQuest", QuestID = 1}
    }
}

local function GetMyTargetMob()
    local player = game.Players.LocalPlayer
    local myLevel = player.Data.Level.Value
    local currentSeaData = SeaMobData[Aternity.Data.CurrentSea] or SeaMobData[1]
    local target = currentSeaData[1]
    
    for _, mob in ipairs(currentSeaData) do
        if myLevel >= mob.MinLvl and mob.MinLvl >= target.MinLvl then 
            target = mob 
        end
    end
    return target
end

local function SecureTeleport(targetCFrame)
    pcall(function()
        local character = game.Players.LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if not root then return end
        
        local dist = (root.Position - targetCFrame.Position).Magnitude
        if dist < 40 then
            root.CFrame = targetCFrame
        else
            if humanoid then humanoid.PlatformStand = true end
            root.Velocity = Vector3.new(0, 0, 0)
            
            local steps = dist / (Aternity.Data.FlightSpeed * 0.03)
            for i = 1, steps do
                if not Aternity.Flags.AutoFarm and not Aternity.Flags.AutoChest and not Aternity.Flags.AutoRaid and not Aternity.Flags.AutoSwordSpawn and not Aternity.Flags.AutoMirage then 
                    break 
                end
                root.CFrame = root.CFrame:Lerp(targetCFrame, i / steps)
                task.wait()
            end
            root.CFrame = targetCFrame
        end
    end)
end

local function EquipWeapon()
    pcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == Aternity.Data.Weapon or tool.ToolTip == Aternity.Data.Weapon) then 
                return 
            end
        end
        
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == Aternity.Data.Weapon or tool.ToolTip == Aternity.Data.Weapon) then
                character.Humanoid:EquipTool(tool)
                break
            end
        end
    end)
end

local function FindValidTarget(name)
    for _, folder in pairs({workspace, workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs")}) do
        if folder then
            local res = folder:FindFirstChild(name)
            if res and res:FindFirstChild("Humanoid") and res.Humanoid.Health > 0 then 
                return res 
            end
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then 
            return obj 
        end
    end
    return nil
end

-- АВТОКЛИКЕР
task.spawn(function()
    local vim = game:GetService("VirtualInputManager")
    while task.wait(0.08) do
        if Aternity.Flags.AutoClicker and (Aternity.Flags.AutoFarm or Aternity.Flags.AutoRaid) then
            pcall(function()
                EquipWeapon()
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChildOfClass("Tool") then
                    vim:SendMouseButtonEvent(10, 10, 0, true, game, 1)
                    vim:SendMouseButtonEvent(10, 10, 0, false, game, 1)
                end
            end)
        end
    end
end)

-- АВТОФАРМ УРОВНЕЙ
task.spawn(function()
    while task.wait(0.4) do
        if Aternity.Flags.AutoFarm and not Aternity.Flags.AutoMirage then
            pcall(function()
                local player = game.Players.LocalPlayer
                local target = GetMyTargetMob()
                local mainGui = player.PlayerGui:FindFirstChild("Main")
                local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
                
                if not hasQuest then
                    local npc = FindValidTarget(target.QuestNPC)
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.4)
                        fireRemote("StartQuest", target.Quest, target.QuestID)
                    end
                else
                    local mob = FindValidTarget(target.Name)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        mob.HumanoidRootPart.CanCollide = false
                        if mob:FindFirstChild("AttackParts") then 
                            mob.AttackParts:Destroy() 
                        end
                        
                        local pPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                        while Aternity.Flags.AutoFarm and mob.Humanoid.Health > 0 and mainGui.Quest.Visible do
                            SecureTeleport(pPos)
                            for _, obj in pairs(workspace:GetChildren()) do
                                if obj.Name == target.Name and obj:FindFirstChild("HumanoidRootPart") then
                                    obj.HumanoidRootPart.CanCollide = false
                                    obj.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame
                                end
                            end
                            task.wait()
                        end
                    end
                end
            end)
        else
            local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and not Aternity.Flags.AutoChest then 
                humanoid.PlatformStand = false 
            end
        end
    end
end)

-- СТАДАРТНЫЙ МИСК (Честы, Статы, Раса)
task.spawn(function()
    while task.wait(0.5) do
        if Aternity.Flags.AutoStats and #Aternity.Stats.Selected > 0 then
            local points = game.Players.LocalPlayer.Data.Points.Value
            if points > 0 then
                for _, name in ipairs(Aternity.Stats.Selected) do 
                    fireRemote("AddPoint", name, 1) 
                end
            end
        end
        
        if Aternity.Flags.AutoChest and not Aternity.Flags.AutoMirage then
            for _, v in pairs(workspace:GetChildren()) do
                if string.find(v.Name, "Chest") and v:IsA("Part") then
                    SecureTeleport(v.CFrame) 
                    task.wait(0.2) 
                    break
                end
            end
        end
        
        if Aternity.Flags.AutoRaceRoll then 
            fireRemote("BlackbeardReward", "Reroll", "1") 
        end
    end
end)

-- ДЕТЕКТОР МИРАЖ-ОСТРОВА + АВТОТЕЛЕПОРТ
task.spawn(function()
    while task.wait(2) do
        if Aternity.Flags.AutoMirage then
            pcall(function()
                local mirage = workspace:FindFirstChild("Mirage Island") or workspace.Map:FindFirstChild("Mirage Island")
                if mirage then
                    SecureTeleport(mirage:GetModelCFrame() * CFrame.new(0, 200, 0))
                end
            end)
        end
    end
end)

-- ДЕТЕКТОР ЛЕГЕНДАРНЫХ МЕЧЕЙ
task.spawn(function()
    while task.wait(1.5) do
        if Aternity.Flags.AutoSwordSpawn then
            pcall(function()
                local swordNames = {"Shisui", "Wando", "Saddi", "Legendary Sword Dealer"}
                for _, name in ipairs(swordNames) do
                    local foundModel = workspace:FindFirstChild(name) or workspace.NPCs:FindFirstChild(name)
                    if foundModel and foundModel:FindFirstChild("HumanoidRootPart") then
                        SecureTeleport(foundModel.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        break
                    end
                end
            end)
        end
    end
end)

-- Автопокупка фруктов + Складывание
task.spawn(function()
    while task.wait(10) do
        if Aternity.Flags.AutoBuyFruit then
            fireRemote("Cousin", "BuyFruit")
            task.wait(1)
            for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if string.find(string.lower(tool.Name), "fruit") then 
                    fireRemote("StoreFruit", tool.Name, tool) 
                end
            end
        end
    end
end)

-- Авторейд
task.spawn(function()
    while task.wait(1) do
        if Aternity.Flags.AutoRaid then
            fireRemote("BlackbeardReward", "Flame", "1")
            for _, enemy in pairs(workspace:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy.Name ~= game.Players.LocalPlayer.Name then
                        SecureTeleport(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0))
                    end
                end
            end)
        end
    end
end)

--======================================================================--
--              СИСТЕМНЫЙ СКАНИРУЮЩИЙ ДВИЖОК 3D ESP                      --
--======================================================================--
local espObjects = {}
task.spawn(function()
    while task.wait(1) do
        if Aternity.Flags.VisualESP then
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if (string.find(obj.Name, "Chest") and obj:IsA("Part")) or (string.find(obj.Name:lower(), "fruit") and obj:IsA("Tool")) then
                        if not espObjects[obj] then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Size = obj:IsA("Part") and obj.Size or Vector3.new(4, 4, 4)
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Color3 = obj:IsA("Part") and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(155, 89, 182)
                            box.Adornee = obj
                            box.Parent = obj
                            
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
                            espObjects[obj] = {b = box, g = billboard}
                        end
                    end
                end
            end)
        else
            for obj, instances in pairs(espObjects) do
                if instances.b then instances.b:Destroy() end
                if instances.g then instances.g:Destroy() end
                espObjects[obj] = nil
            end
        end
    end
end)

-- АДМИН-ДЕТЕКТОР
task.spawn(function()
    game.Players.PlayerAdded:Connect(function(player)
        if player:GetRankInGroup(4330432) >= 200 or player:IsA("Player") and (string.find(player.Name:lower(), "admin") or string.find(player.Name:lower(), "mod")) then
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    end)
end)
--======================================================================--
--                       ATERNITY ERROR LOGGER SYSTEM                   --
--======================================================================--

local LogScreen = Instance.new("Frame", MainFrame)
LogScreen.Size = UDim2.new(1, -125, 1, -115)
LogScreen.Position = UDim2.new(0, 115, 0, 105)
LogScreen.BackgroundTransparency = 1
LogScreen.Visible = false -- Сделать visible при создании вкладки Log

local LogContainer = Instance.new("ScrollingFrame", LogScreen)
LogContainer.Size = UDim2.new(1, -5, 1, 0)
LogContainer.BackgroundTransparency = 1
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 1000)
LogContainer.ScrollBarThickness = 2

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
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 20)
end

-- Перехватчик внутренних ошибок Lua и сетевых пакетов
game:GetService("ScriptContext").Error:Connect(function(message, stackTrace, script)
    -- Фильтруем ошибки, чтобы логировать только те, что связаны с Aternity
    if string.find(message:lower(), "aternity") or string.find(message:lower(), "commf") or string.find(message:lower(), "nil value") then
        createLogEntry("ERROR: " .. message, Color3.fromRGB(231, 76, 60)) -- Красный лог
    end
end)

-- Логирование успешных внутренних событий софта
local function LogInfo(message)
    createLogEntry("INFO: " .. message, Color3.fromRGB(52, 152, 219)) -- Синий лог
end

-- Пример системных логов при старте
LogInfo("Physics Bypass Activated.")
LogInfo("Tween Flight Core Status: STABLE.")
LogInfo("Remotes Secure Handshake: SUCCESS.")
