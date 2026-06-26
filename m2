
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local loadstringFn = loadstring or load
if not loadstringFn then
    warn("[Sqays] loadstring desteklenmiyor. Executor ayarlarini kontrol et.")
    return
end

if not game.HttpGet then
    warn("[Sqays] HttpGet desteklenmiyor. Executor HTTP isteklerine izin vermiyor olabilir.")
    return
end

local rayfieldOk, rayfieldSource = pcall(function()
    return game:HttpGet("https://sirius.menu/rayfield")
end)

if not rayfieldOk or type(rayfieldSource) ~= "string" or rayfieldSource == "" then
    warn("[Sqays] Rayfield indirilemedi. Internet/HTTP ayarlarini kontrol et.")
    return
end

local RayfieldLoader = loadstringFn(rayfieldSource)
if type(RayfieldLoader) ~= "function" then
    warn("[Sqays] Rayfield kodu yuklenemedi. Link gecersiz veya executor loadstring desteklemiyor.")
    return
end

local Rayfield = RayfieldLoader()
if not Rayfield or type(Rayfield.CreateWindow) ~= "function" then
    warn("[Sqays] Rayfield baslatilamadi. UI kutuphanesi beklenen sekilde donmedi.")
    return
end

-- === CONFIG ===
local oresFolder = Workspace:WaitForChild("__GAME_CONTENT"):WaitForChild("Ores")
_G.MiningSpeed = 0.5
_G.HarvestSpeed = 0.2
_G.TierSpeed = 0.2
_G.RuneSpeed = 0.2
_G.TreeSpeed = 0.2
_G.WaterPumpSpeed = 0.2
_G.IceConvertSpeed = 0.2
_G.AshConvertSpeed = 1
_G.BlazeQuestSpeed = 5
_G.AutoHarvest = false
_G.AutoRollTier = false
_G.AutoHitTree = false
_G.AutoWaterPump = false
_G.AutoBlazeQuest = false
_G.AutoConvertWoodToAsh = false
_G.AntiAFK = false

local M2Settings = {}
local OreNames = {"Stone", "Coal", "Copper", "Silver", "Iron", "Gold", "Platinum", "Titanium", "Uranium", "Cobalt", "Palladium", "Ruby", "Aetherite", "Celestium", "Voidsteel", "Infinity"}
local RuneNames = {"Basic", "Super", "Advanced", "Cosmic Prism", "Hacker", "Snowy", "Deepcore"}
local RuneSettings = {}
for _, name in ipairs(RuneNames) do RuneSettings[name] = false end

local antiIdleConnection = nil
local antiIdleSaves = 0

local function getMainRemote()
    return ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
end

local function setAntiIdle(enabled)
    _G.AntiAFK = enabled

    if antiIdleConnection then
        antiIdleConnection:Disconnect()
        antiIdleConnection = nil
    end

    if not enabled then
        return
    end

    antiIdleSaves = 0
    antiIdleConnection = player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        antiIdleSaves += 1
        warn("[Sqays] Anti Idle save: " .. tostring(antiIdleSaves))
    end)
end

-- === ANTI AFK DONGUSU ===
setAntiIdle(false)

-- === DONGULER ===

-- 1. HARVEST
task.spawn(function()
    while true do
        if _G.AutoHarvest == true then
            local slots = CollectionService:GetTagged("WheatSlot")
            for _, slot in ipairs(slots) do
                if _G.AutoHarvest == false then break end
                local cd = slot:FindFirstChildOfClass("ClickDetector")
                if cd and slot:FindFirstChild("5") then
                    fireclickdetector(cd)
                end
            end
        end
        task.wait(_G.HarvestSpeed)
    end
end)

-- 2. STABIL TIER ROLL DONGUSU
task.spawn(function()
    while true do
        if _G.AutoRollTier then
            pcall(function()
                local MainRemote = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
                if MainRemote then
                    MainRemote:FireServer("RollTier")
                end
            end)
        end
        task.wait(_G.TierSpeed)
    end
end)

-- 3. STABIL RUNE ROLL DONGUSU
task.spawn(function()
    while true do
        pcall(function()
            local MainRemote = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
            if MainRemote then
                for _, name in ipairs(RuneNames) do
                    if RuneSettings[name] then
                        MainRemote:FireServer("RollRune", name)
                    end
                end
            end
        end)
        task.wait(_G.RuneSpeed)
    end
end)

-- 4. STABIL TREE HIT DONGUSU
task.spawn(function()
    while true do
        if _G.AutoHitTree then
            pcall(function()
                local MainRemote = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
                if MainRemote and player.FEATURES.TREE.IsSpawned.Value then
                    MainRemote:FireServer("HitTree")
                end
            end)
        end
        task.wait(_G.TreeSpeed)
    end
end)

-- 5. WATER PUMP DONGUSU
task.spawn(function()
    while true do
        if _G.AutoWaterPump then
            pcall(function()
                local MainRemote = getMainRemote()
                if MainRemote then
                    MainRemote:FireServer("GainWater")
                end
            end)
        end
        task.wait(_G.WaterPumpSpeed)
    end
end)

-- 6. BLAZE QUEST DONGUSU
task.spawn(function()
    while true do
        if _G.AutoBlazeQuest then
            pcall(function()
                local MainRemote = getMainRemote()
                if MainRemote then
                    MainRemote:FireServer("SetUpgradeAutomationPaused", "Fire", false)
                    MainRemote:FireServer("Blaze")
                end
            end)
        end
        task.wait(_G.BlazeQuestSpeed)
    end
end)

-- 7. ASH CONVERT
task.spawn(function()
    while true do
        if _G.AutoConvertWoodToAsh then
            pcall(function()
                local MainRemote = getMainRemote()
                if MainRemote then
                    MainRemote:FireServer("ConvertWoodToAsh")
                end
            end)
        end
        task.wait(_G.AshConvertSpeed)
    end
end)

-- 8. MINING
local function isOreReady(ore)
    if not ore or not ore:FindFirstChild("Rock") then
        return false
    end

    local ui = ore:FindFirstChild("OresTopUI")
    local bar = ui and ui:FindFirstChild("Bar")
    local health = bar and bar:FindFirstChild("Health")
    if health and health.Text == "Respawning..." then
        return false
    end

    return true
end

local function getBestSelectedOre()
    for i = #OreNames, 1, -1 do
        local oreName = OreNames[i]
        if M2Settings[oreName] then
            for _, ore in ipairs(oresFolder:GetChildren()) do
                if ore.Name == oreName and isOreReady(ore) then
                    return ore
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(_G.MiningSpeed)
        local ore = getBestSelectedOre()
        if ore and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = ore:GetPivot() + Vector3.new(0, 5, 0)
        end
    end
end)

-- === GUI ===
local Window = Rayfield:CreateWindow({
    Name = "Sqays Noob Incremental",
    LoadingTitle = "Loading...",
    ConfigurationSaving = {Enabled = true, FileName = "SqaysConfig"}
})

-- Mining Tab
local MiningTab = Window:CreateTab("Mining", 0)
for _, name in ipairs(OreNames) do
    M2Settings[name] = false
    MiningTab:CreateToggle({Name = "Mine " .. name, Callback = function(v) M2Settings[name] = v end})
end

-- Automation Tab
local RollTab = Window:CreateTab("Automation", 1)

RollTab:CreateSection("Harvest & Quest")
RollTab:CreateToggle({Name = "Auto Harvest", Callback = function(v) _G.AutoHarvest = v end})
RollTab:CreateToggle({Name = "Auto Upgrade Quest", Callback = function(v) _G.AutoBlazeQuest = v end})

RollTab:CreateSection("Roll & Tree")
RollTab:CreateToggle({Name = "Auto Roll Tier", Callback = function(v) _G.AutoRollTier = v end})
RollTab:CreateToggle({Name = "Auto Hit Tree", Callback = function(v) _G.AutoHitTree = v end})
RollTab:CreateToggle({Name = "Auto Water Pump", Callback = function(v) _G.AutoWaterPump = v end})

RollTab:CreateSection("Runes")
for _, name in ipairs(RuneNames) do
    RollTab:CreateToggle({Name = "Roll " .. name, Callback = function(v) RuneSettings[name] = v end})
end

-- Ice And Ash Convert Tab
local IceTab = Window:CreateTab("Ice And Ash Convert", "snowflake")
for i = 1, 12 do
    IceTab:CreateToggle({
        Name = "Convert Level " .. i,
        Callback = function(Value)
            getgenv()["AutoIce_" .. i] = Value
            task.spawn(function()
                while getgenv()["AutoIce_" .. i] do
                    pcall(function()
                        local MainRemote = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
                        if MainRemote then MainRemote:FireServer("PressButton", i) end
                    end)
                    task.wait(_G.IceConvertSpeed)
                end
            end)
        end,
    })
end

IceTab:CreateSection("Ash Convert")
IceTab:CreateToggle({Name = "Auto Convert Wood To Ash", Callback = function(v) _G.AutoConvertWoodToAsh = v end})

-- Speed Tab
local SpeedTab = Window:CreateTab("Speed", 2)
local SpeedOptions = {"0.01", "0.05", "0.1", "0.2", "0.5", "1", "2", "3", "5", "10"}

SpeedTab:CreateSection("Main Speeds")
SpeedTab:CreateDropdown({Name = "Mining Speed", Options = SpeedOptions, CurrentOption = {"0.5"}, Callback = function(o) _G.MiningSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Tier Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.TierSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Rune Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.RuneSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Water Pump Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.WaterPumpSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Ice Convert Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.IceConvertSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Ash Convert Speed", Options = SpeedOptions, CurrentOption = {"1"}, Callback = function(o) _G.AshConvertSpeed = tonumber(o[1]) end})

SpeedTab:CreateSection("Extra Speeds")
SpeedTab:CreateDropdown({Name = "Harvest Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.HarvestSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Tree Speed", Options = SpeedOptions, CurrentOption = {"0.2"}, Callback = function(o) _G.TreeSpeed = tonumber(o[1]) end})
SpeedTab:CreateDropdown({Name = "Blaze Quest Speed", Options = SpeedOptions, CurrentOption = {"5"}, Callback = function(o) _G.BlazeQuestSpeed = tonumber(o[1]) end})

SpeedTab:CreateSection("Anti-Idle")
SpeedTab:CreateToggle({Name = "Anti Idle", Callback = function(v) setAntiIdle(v) end})

Rayfield:LoadConfiguration()
