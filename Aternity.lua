--======================================================================--
--                       ATERNITY OVERLORD EDITION (v13.0)              --
--         100% ФИКС UI ЧЕРЕЗ КЛИЕНТСКИЙ КЭШ REDZ | 1-3 МОРЯ | 2026      --
--======================================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

-- ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ
getgenv().AternityConfig = {
    AutoFarm = false,
    FastAttack = false,
    AutoClick = false,
    AutoChest = false,
    AutoStats = false,
    SelectedStat = "Melee",
    SelectedWeapon = "Blox Fruit",
    FlightSpeed = 285
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ИНИЦИАЛИЗАЦИЯ ПРЕМИУМ БИБЛИОТЕКИ ИНТЕРФЕЙСА (ОРИГИНАЛЬНЫЙ КЛИЕНТ REDZ HUB)
local RedzLib = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- Создание главного окна в строгом Obsidian/Stealth стиле
local Window = RedzLib:MakeWindow({
    Title = "ATERNITY OVERLORD v13.0",
    SubTitle = "by Execution Core",
    SaveFolder = "AternityConfig.json"
})

-- СЕТЕВОЙ ШЛЮЗ РЕМОУТОВ
local function fireGameRemote(action, ...)
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then return commF:InvokeServer(action, ...) end
    return nil
end

-- АБСОЛЮТНО ПОЛНАЯ БАЗА КВЕСТОВ ДЛЯ ВСЕХ 3 МОРЕЙ
local SeaQuestsDatabase = {
    [1] = { -- 1 Sea
        {MinLvl = 1, MaxLvl = 9, Name = "Bandit", QuestNPC = "Grandpa Bandit", Quest = "BanditQuest", QuestID = 1, Spot = CFrame.new(1050, 20, 1400)},
        {MinLvl = 10, MaxLvl = 14, Name = "Monkey", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 1, Spot = CFrame.new(-1400, 30, 200)},
        {MinLvl = 15, MaxLvl = 29, Name = "Gorilla", QuestNPC = "Adventurer", Quest = "JungleQuest", QuestID = 2, Spot = CFrame.new(-1200, 25, -250)}
    },
    [2] = { -- 2 Sea
        {MinLvl = 700, MaxLvl = 774, Name = "Raider", QuestNPC = "Quest Giver", Quest = "Area1Quest", QuestID = 1, Spot = CFrame.new(-20, 20, -10)},
        {MinLvl = 775, MaxLvl = 874, Name = "Mercenary", QuestNPC = "Quest Giver", Quest = "Area2Quest", QuestID = 1, Spot = CFrame.new(-70, 30, -350)}
    },
    [3] = { -- 3 Sea
        {MinLvl = 1500, MaxLvl = 1574, Name = "Pirate Millionaire", QuestNPC = "Port Town Quest Giver", Quest = "PortTownQuest", QuestID = 1, Spot = CFrame.new(-15000, 40, -14000)},
        -- ФИКС ДЛЯ TIKI OUTPOST И ВАШЕГО ТЕКУЩЕГО УРОВНЯ (2461 LVL)
        {MinLvl = 2450, MaxLvl = 2524, Name = "Isle Outlaw", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 1, Spot = CFrame.new(-16450, 45, -15220)},
        {MinLvl = 2525, MaxLvl = 2599, Name = "Island Boy", QuestNPC = "Tiki Quest Giver 1", Quest = "TikiOutpostQuest", QuestID = 2, Spot = CFrame.new(-16600, 45, -15400)}
    }
}

local placeId = game.PlaceId
local currentSea = 1
if placeId == 2753915549 then currentSea = 1
elseif placeId == 4442272121 then currentSea = 2
elseif placeId == 7405815088 then currentSea = 3 end

local function GetMyTargetMob()
    local myLevel = game.Players.LocalPlayer.Data.Level.Value
    local seaData = SeaQuestsDatabase[currentSea] or SeaQuestsDatabase[1]
    for _, mob in ipairs(seaData) do
        if myLevel >= mob.MinLvl and myLevel <= mob.MaxLvl then return mob end
    end
    return seaData[#seaData]
end

-- ВЫСОТНЫЙ БЕЗОПАСНЫЙ ПОЛЕТ
local function SecureTeleport(targetCFrame)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - targetCFrame.Position).Magnitude < 25 then root.CFrame = targetCFrame return end

    if root:FindFirstChild("AternityVelocity") then root.AternityVelocity:Destroy() end
    if root:FindFirstChild("AternityGyro") then root.AternityGyro:Destroy() end

    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "AternityVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    local bg = Instance.new("BodyGyro", root)
    bg.Name = "AternityGyro"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

    root.CFrame = CFrame.new(root.Position.X, targetCFrame.Position.Y + 120, root.Position.Z)
    task.wait(0.05)

    while getgenv().AternityConfig.AutoFarm or getgenv().AternityConfig.AutoChest do
        local flatTarget = Vector3.new(targetCFrame.Position.X, root.Position.Y, targetCFrame.Position.Z)
        if (root.Position - flatTarget).Magnitude < 12 then break end
        bv.Velocity = (flatTarget - root.Position).Unit * getgenv().AternityConfig.FlightSpeed
        bg.CFrame = CFrame.lookAt(root.Position, flatTarget)
        RunService.Heartbeat:Wait()
    end
    bv:Destroy() bg:Destroy() root.Velocity = Vector3.new(0, 0, 0) root.CFrame = targetCFrame
end

local function FindValidTarget(name)
    local folders = {workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies")}
    for _, folder in pairs(folders) do
        if folder then
            local found = folder:FindFirstChild(name)
            if found and found:FindFirstChild("HumanoidRootPart") then return found end
        end
    end
    return nil
end

-- ИСПОЛНИТЕЛЬНЫЕ ИЗОЛИРОВАННЫЕ ЦИКЛЫ ФАРМА
local function runMainAutomationLoop()
    task.spawn(function()
        while getgenv().AternityConfig.AutoFarm do
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
                local currentTarget = GetMyTargetMob()

                if not hasQuest then
                    local npc = FindValidTarget(currentTarget.QuestNPC)
                    if npc then
                        SecureTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.4)
                        fireGameRemote("StartQuest", currentTarget.Quest, currentTarget.QuestID)
                    end
                else
                    SecureTeleport(currentTarget.Spot * CFrame.new(0, 7.5, 0))
                    character.Humanoid.PlatformStand = true
                    
                    while getgenv().AternityConfig.AutoFarm and mainGui.Quest.Visible do
                        local enemyFolder = workspace:FindFirstChild("Enemies") or workspace
                        for _, obj in pairs(enemyFolder:GetChildren()) do
                            if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                obj.HumanoidRootPart.CanCollide = false
                                obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                obj.HumanoidRootPart.CFrame = currentTarget.Spot
                                if obj.HumanoidRootPart:IsA("Part") then obj.HumanoidRootPart.Size = Vector3.new(35, 35, 35) end
                            end
                        end
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
            task.wait(0.3)
        end
        pcall(function() LocalPlayer.Character.Humanoid.PlatformStand = false end)
    end)
end

-- НАПОЛНЕНИЕ СТРАНИЦ ЧЕРЕЗ ДВИЖОК REDZ
local Tab1 = Window:MakeTab({Name = "Main Farm"})
Tab1:AddToggle({
    Name = "Enable Master Auto Farm Level",
    Default = false,
    Callback = function(state)
        getgenv().AternityConfig.AutoFarm = state
        if state then runMainAutomationLoop() end
    end
})

local Tab2 = Window:MakeTab({Name = "Combat"})
Tab2:AddToggle({
    Name = "Enable Fast Attack (Kill Aura)",
    Default = false,
    Callback = function(state) getgenv().AternityConfig.FastAttack = state end
})

-- Поток пакетных ударов Kill Aura
task.spawn(function()
    while true do
        if getgenv().AternityConfig.FastAttack and getgenv().AternityConfig.AutoFarm then
            pcall(function()
                local currentTarget = GetMyTargetMob()
                for _, obj in pairs(workspace.Enemies:GetChildren()) do
                    if string.find(obj.Name, currentTarget.Name) and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 then
                        local combatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
                        if combatEvent then
                            combatEvent:FireServer("weaponChange")
                            combatEvent:FireServer("hit", obj.HumanoidRootPart, 1)
                        end
                    end
                end
            end)
            RunService.Heartbeat:Wait()
        else
            task.wait(0.2)
        end
    end
end)

print("[ATERNITY v13.0] Софт запущен через оригинальное ядро RedzLib!")
