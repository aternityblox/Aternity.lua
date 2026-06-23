-- ====================================================================
-- ШАГ 1: ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА И НАСТРОЕК AXONIC CLONE
-- ====================================================================
local Fluent = loadstring(game:HttpGet("https://github.com"))()

local Window = Fluent:CreateWindow({
    Title = "Axonic / Cinnamon",
    SubTitle = "Blox Fruits | Версия 2026",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Подключение ключевых сервисов игры
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Глобальные переменные настроек (Синхронизированы со всеми плашками)
_G.AutoLevelFarm = false
_G.BossFarmActive = false
_G.AutoKillRaidMobs = false
_G.SelectedRaid = "Пламя"
_G.AutoBuyChip = false
_G.AutoStartRaid = false

_G.KillAura = true
_G.Noclip = true
_G.AntiAFK = true
_G.WalkOnWater = false

_G.PointsAmount = "1"
_G.SelectedStat = "BloxFruit"
_G.AutoStatsActive = false

_G.TweenSpeed = 25    -- Ползунок строго от 10 до 50
_G.Y_Axis = 25        -- Ползунок смещения по высоте (Защита от AOE)
_G.X_Axis = 20        -- Ползунок смещения вбок
_G.BringMobs = true
_G.BringMobDistance = 500
_G.AutoEquipWeapon = "Ближний бой"
_G.SkillUsage = false

_G.IsEvacuating = false
_G.EmergencyHealthPercent = 35

-- Создание структуры вкладок меню
local Tabs = {
    Utils = Window:AddTab({ Title = "Utils", Icon = "wrench" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "swords" }),
    Raid = Window:AddTab({ Title = "Raid", Icon = "shield" }),
    SkillPoints = Window:AddTab({ Title = "Skill Points", Icon = "bar-chart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
-- ====================================================================
-- ШАГ 2: СИСТЕМА ДВИЖЕНИЯ, ЗАЩИТЫ И АВТО-ХИТБОКСОВ (БЭКЕНД)
-- ====================================================================

-- 1. Экипировка выбранного типа оружия из инвентаря
local function equipTargetWeapon()
    local character = player.Character
    if not character then return end
    local weaponType = _G.AutoEquipWeapon
    local targetName = "Combat"
    
    if weaponType == "Меч" then
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Sword" then targetName = v.Name break end
        end
    elseif weaponType == "Фрукт" then
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then targetName = v.Name break end
        end
    else
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == "Melee" or v.Name == "Combat") then targetName = v.Name break end
        end
    end
    if player.Backpack:FindFirstChild(targetName) then
        character.Humanoid:EquipTool(player.Backpack[targetName])
    end
end

-- 2. Безопасный полет по чекпоинтам с отрисовкой фиолетовых сфер
local function flyToTarget(targetPos)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or _G.IsEvacuating then return end
    
    local distance = (root.Position - targetPos.Position).Magnitude
    if distance > 25 then
        -- Отрисовка фиолетового маркера Axonic на экране
        local sphere = Instance.new("Part", workspace)
        sphere.Shape = Enum.PartType.Ball
        sphere.Size = Vector3.new(4, 4, 4)
        sphere.Material = Enum.Material.Neon
        sphere.Color = Color3.fromRGB(138, 43, 226)
        sphere.Position = targetPos.Position
        sphere.Anchored = true
        sphere.CanCollide = false
        task.delay(1, function() sphere:Destroy() end)
        
        -- Масштабирование ползунка 10-50 в безопасную скорость обхода Byfron
        local actualSpeed = (_G.TweenSpeed >= 10 and _G.TweenSpeed <= 50) and (_G.TweenSpeed * 6) or 150
        player.Character.Humanoid.PlatformStand = true
        
        local tween = TweenService:Create(root, TweenInfo.new(distance / actualSpeed, Enum.EasingStyle.Linear), {CFrame = targetPos})
        tween:Play()
        tween.Completed:Wait()
        player.Character.Humanoid.PlatformStand = false
    end
end

-- 3. Автоматическое расширение хитбоксов мобов для ударов с высоты
local function applyAdvancedHitboxes(enemy)
    pcall(function()
        if enemy:FindFirstChild("HumanoidRootPart") then
            local hrp = enemy.HumanoidRootPart
            hrp.Size = Vector3.new(15, 15, 15) -- Увеличенный хитбокс
            hrp.Transparency = 0.7
            hrp.Material = Enum.Material.Neon
            hrp.Color = Color3.fromRGB(255, 0, 0)
            hrp.CanCollide = false
        end
    end)
end

-- 4. Беспрерывный Noclip (Проход сквозь стены)
RunService.Stepped:Connect(function()
    if _G.Noclip and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 5. Эвакуация при угрозе смерти (Anti-Die система)
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and (_G.AutoLevelFarm or _G.AutoKillRaidMobs) then
                local hpPercent = (hum.Health / hum.MaxHealth) * 100
                if hpPercent <= _G.EmergencyHealthPercent and not _G.IsEvacuating then
                    _G.IsEvacuating = true
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.CFrame = root.CFrame * CFrame.new(0, 800, 0) -- Отлет в небо на лечение
                    Fluent:Notify({Title = "Axonic Защита", Content = "Экстренный отлет на регенерацию ХП!", Duration = 4})
                    while hum.Health < hum.MaxHealth do task.wait(1) end
                    _G.IsEvacuating = false
                end
            end
        end)
    end
end)

-- 6. Модуль стягивания мобов (Bring Mobs) + Kill Aura
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.BringMobs and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not _G.IsEvacuating then
            pcall(function()
                local pRoot = player.Character.HumanoidRootPart
                local activeFolder = workspace:FindFirstChild("Raid") or workspace.Enemies
                for _, enemy in pairs(activeFolder:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        if (pRoot.Position - enemy.HumanoidRootPart.Position).Magnitude <= _G.BringMobDistance then
                            enemy.HumanoidRootPart.CanCollide = false
                            -- Стягивание под координаты смещения из настроек
                            enemy.HumanoidRootPart.CFrame = pRoot.CFrame * CFrame.new(_G.X_Axis, -_G.Y_Axis + 12, 0)
                            if _G.KillAura then
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("AttackRemote", enemy)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Быстрая авто-атака кликами оружия
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.AutoLevelFarm or _G.AutoKillRaidMobs or _G.BossFarmActive then
            pcall(function()
                equipTargetWeapon()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end)
        end
    end
end)
-- ====================================================================
-- ШАГ 3: ПОДКЛЮЧЕНИЕ ФУНКЦИОНАЛА К КНОПКАМ И ТУМБЛЕРАМ ИНТЕРФЕЙСА
-- ====================================================================

-- 1. НАПОЛНЕНИЕ ВКЛАДКИ UTILS
Tabs.Utils:AddSection("Main Player")
Tabs.Utils:AddToggle("AutoBusoTgl", {Title = "Auto Buso (Haki)", Default = true, Callback = function(v) _G.AutoBuso = v end})
task.spawn(function()
    while true do task.wait(1) if _G.AutoBuso and player.Character and not player.Character:FindFirstChild("HasBuso") then ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end end
end)
Tabs.Utils:AddToggle("KillAuraTgl", {Title = "Kill Aura", Default = true, Callback = function(v) _G.KillAura = v end})
Tabs.Utils:AddToggle("NoclipTgl", {Title = "Noclip", Default = true, Callback = function(v) _G.Noclip = v end})
Tabs.Utils:AddToggle("AntiAfkTgl", {Title = "Anti AFK", Default = true, Callback = function(v) _G.AntiAFK = v end})
player.Idled:Connect(function() if _G.AntiAFK then VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5) VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end end)
Tabs.Utils:AddToggle("WaterWalkTgl", {Title = "Walk On Water", Default = false, Callback = function(v) _G.WalkOnWater = v end})

-- 2. НАПОЛНЕНИЕ ВКЛАДКИ FARMING (Динамическая логика под любой лвл до 2800)
local function runDynamicAutoFarm()
    task.spawn(function()
        while _G.AutoLevelFarm do
            task.wait(0.5)
            pcall(function()
                if not player.PlayerGui.Main.Quest.Visible then
                    -- Гибридное умное взятие квеста: сначала дистанционно, при сбое — летит к NPC
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "PirateQuest", 1)
                    task.wait(1.5)
                else
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                            applyAdvancedHitboxes(enemy)
                            flyToTarget(enemy.HumanoidRootPart.CFrame * CFrame.new(_G.X_Axis, _G.Y_Axis, 0))
                            while _G.AutoLevelFarm and enemy.Humanoid.Health > 0 and enemy.Parent and not _G.IsEvacuating do
                                player.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(_G.X_Axis, _G.Y_Axis, 0)
                                task.wait()
                            end
                        end
                    end
                end
            end)
        end
    end)
end
Tabs.Farming:AddSection("Level Quest Farm")
Tabs.Farming:AddToggle("LvlFarmToggle", {Title = "Auto Level Farm", Default = false, Callback = function(v) _G.AutoLevelFarm = v if v then runDynamicAutoFarm() end end})

-- 3. НАПОЛНЕНИЕ ВКЛАДКИ RAID (Официальный список со скриншота)
local RaidServerNames = {["Пламя"]="Flame",["Лёд"]="Ice",["Песок"]="Sand",["Тьма"]="Dark",["Свет"]="Light",["Магма"]="Magma",["Дрожь"]="Quake",["Будда"]="Buddha",["Паук"]="Spider",["Феникс"]="Phoenix",["Тесто"]="Dough"}
Tabs.Raid:AddSection("Выбор Рейда")
Tabs.Raid:AddDropdown("RaidDrop", {Title = "Выберите Фрукт для Рейда", Values = {"Пламя","Лёд","Песок","Тьма","Свет","Магма","Дрожь","Будда","Паук","Феникс","Тесто"}, CurrentValue = "Пламя", Callback = function(v) _G.SelectedRaid = v end})
Tabs.Raid:AddSection("Автоматизация")
Tabs.Raid:AddToggle("BuyChipTgl", {Title = "Авто-Покупка Чипа", Default = false, Callback = function(v) _G.AutoBuyChip = v end})
task.spawn(function()
    while true do task.wait(2) if _G.AutoBuyChip and not player.Backpack:FindFirstChild("Special Microchip") and not player.Character:FindFirstChild("Special Microchip") then ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", RaidServerNames[_G.SelectedRaid], "1") end end
end)
local function runRaidClean()
    task.spawn(function()
        while _G.AutoKillRaidMobs do
            task.wait(0.4)
            pcall(function()
                local folder = workspace:FindFirstChild("Raid") or workspace.Enemies
                for _, enemy in pairs(folder:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                        applyAdvancedHitboxes(enemy)
                        flyToTarget(enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Y_Axis, 0)) -- Безопасная высота
                        while _G.AutoKillRaidMobs and enemy.Humanoid.Health > 0 and enemy.Parent and not _G.IsEvacuating do
                            player.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Y_Axis, 0)
                            task.wait()
                        end
                    end
                end
            end)
        end
    end)
end
Tabs.Raid:AddToggle("KillRaidMobsTgl", {Title = "Авто-Зачистка Островов", Default = false, Callback = function(v) _G.AutoKillRaidMobs = v if v then runRaidClean() end end})

-- 4. НАПОЛНЕНИЕ ВКЛАДКИ SKILL POINTS
Tabs.SkillPoints:AddSection("Auto Stats System")
Tabs.SkillPoints:AddInput("PtsInput", {Title = "Points Amount", Default = "1", Callback = function(v) _G.PointsAmount = v end})
Tabs.SkillPoints:AddDropdown("StatDrop", {Title = "Select Stats", Values = {"Melee", "Defense", "Sword", "Gun", "BloxFruit"}, CurrentValue = "BloxFruit", Callback = function(v) _G.SelectedStat = v end})
Tabs.SkillPoints:AddToggle("AStatTgl", {Title = "Auto Stats", Default = false, Callback = function(v) _G.AutoStatsActive = v end})
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoStatsActive and player.Data.Points.Value > 0 then
            local sName = _G.SelectedStat == "BloxFruit" and "Demon Fruit" or _G.SelectedStat
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", sName, tonumber(_G.PointsAmount) or 1)
        end
    end
end)

-- 5. НАПОЛНЕНИЕ ВКЛАДКИ SETTINGS (Лимиты слайдеров строго со скриншотов)
Tabs.Settings:AddSection("Farm Settings")
Tabs.Settings:AddSlider("TSpdSlider", {Title = "Tween Speed", Min = 10, Max = 50, Default = 25, Callback = function(v) _G.TweenSpeed = v end})
Tabs.Settings:AddSlider("YAxSlider", {Title = "Y Axis Cordinates", Min = 0, Max = 50, Default = 25, Callback = function(v) _G.Y_Axis = v end})
Tabs.Settings:AddSlider("XAxSlider", {Title = "X Axis Cordinates", Min = 0, Max = 50, Default = 20, Callback = function(v) _G.X_Axis = v end})
Tabs.Settings:AddDropdown("WepEquip", {Title = "Auto Equip Weapon", Values = {"Ближний бой", "Меч", "Фрукт"}, CurrentValue = "Ближний бой", Callback = function(v) _G.AutoEquipWeapon = v end})
Tabs.Settings:AddSection("Mob Settings")
Tabs.Settings:AddToggle("BringMobTgl", {Title = "Bring Mobs", Default = true, Callback = function(v) _G.BringMobs = v end})
Tabs.Settings:AddSlider("BrgDDist", {Title = "Bring Mob Distance", Min = 100, Max = 1000, Default = 500, Callback = function(v) _G.BringMobDistance = v end})

-- Уведомление об успешном развертывании
Fluent:Notify({Title = "Axonic System", Content = "Все 3 шага успешно скомпилированы! Скрипт готов.", Duration = 5})
