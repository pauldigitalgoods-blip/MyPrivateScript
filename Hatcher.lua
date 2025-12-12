-- ULTIMATE CRYSTAL HATCHER 2025 | RAYFIELD UI
-- Fully Auto Play → House → Starter Egg (6s wait) → Mass Hatch (5 retries) → Rollback BEFORE Cheese → Rejoin
-- Dec 12, 2025 Compatible | Built with Rayfield UI

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Main Script Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
local ClientData = Fsys.load("ClientData")
local EquipRemote = ReplicatedStorage.API["ToolAPI/Equip"]
local BuyItem = ReplicatedStorage.API["ShopAPI/BuyItem"]
local GiveItem = ReplicatedStorage.API["TradeAPI/GiveItem"]
local API = ReplicatedStorage.API

local request = syn and syn.request or fluxus and fluxus.request or request or http_request or http.request

-- Config (saved via Rayfield)
local Config = {
    AutoPlayHouse = true,
    AntiAFK = true,
    AutoRejoin = true,
    RejoinDelay = 7,
    Webhook = "",
    LogCommon = false,
    LogUncommon = false,
    LogRare = true,
    LogUltraRare = true,
    LogLegendary = true,
    DesiredPets = {"pet_recycler_2025_giant_panda", "penguins_2025_dango_penguins"},
    AutoRollback = true,
    AutoCheese = true,
}

-- Load saved config
pcall(function()
    if isfile("UltimateHatcher/Config.json") then
        local saved = HttpService:JSONDecode(readfile("UltimateHatcher/Config.json"))
        for k, v in pairs(saved) do Config[k] = v end
    end
end)

local function SaveConfig()
    pcall(function() writefile("UltimateHatcher/Config.json", HttpService:JSONEncode(Config)) end)
end

-- Notification
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 6})
    end)
end

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Ultimate Crystal Hatcher 2025",
    LoadingTitle = "Loading Hatcher...",
    LoadingSubtitle = "by Grok - Dec 2025",
    ConfigurationSaving = { Enabled = true, FolderName = "UltimateHatcher", FileName = "Config" },
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AutoTab = Window:CreateTab("Toggles", 4483362458)
local LogTab = Window:CreateTab("Webhook & Pets", 4483362458)

local StatusLabel = MainTab:CreateLabel("Status: Idle...")

-- Auto Tab Toggles
AutoTab:CreateToggle({
    Name = "Auto Play & House Entry",
    CurrentValue = Config.AutoPlayHouse,
    Flag = "AutoPlayHouse",
    Callback = function(Value)
        Config.AutoPlayHouse = Value
        SaveConfig()
        if Value then AutoPlayHouse() end
    end,
})

AutoTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Config.AntiAFK,
    Flag = "AntiAFK",
    Callback = function(Value)
        Config.AntiAFK = Value
        SaveConfig()
        if Value then StartAntiAFK() end
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Rejoin After Kick",
    CurrentValue = Config.AutoRejoin,
    Flag = "AutoRejoin",
    Callback = function(Value)
        Config.AutoRejoin = Value
        SaveConfig()
    end,
})

AutoTab:CreateSlider({
    Name = "Rejoin Delay (sec)",
    Range = {3, 30},
    Increment = 1,
    CurrentValue = Config.RejoinDelay,
    Flag = "RejoinDelay",
    Callback = function(Value)
        Config.RejoinDelay = Value
        SaveConfig()
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Rollback on Bad Hatch",
    CurrentValue = Config.AutoRollback,
    Flag = "AutoRollback",
    Callback = function(Value)
        Config.AutoRollback = Value
        SaveConfig()
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Cheese After Rollback",
    CurrentValue = Config.AutoCheese,
    Flag = "AutoCheese",
    Callback = function(Value)
        Config.AutoCheese = Value
        SaveConfig()
    end,
})

-- Log Tab
LogTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    CurrentValue = Config.Webhook,
    Flag = "Webhook",
    Callback = function(Text)
        Config.Webhook = Text
        SaveConfig()
    end,
})

LogTab:CreateToggle({
    Name = "Log Commons",
    CurrentValue = Config.LogCommon,
    Flag = "LogCommon",
    Callback = function(Value)
        Config.LogCommon = Value
        SaveConfig()
    end,
})

LogTab:CreateToggle({
    Name = "Log Uncommons",
    CurrentValue = Config.LogUncommon,
    Flag = "LogUncommon",
    Callback = function(Value)
        Config.LogUncommon = Value
        SaveConfig()
    end,
})

LogTab:CreateToggle({
    Name = "Log Rares",
    CurrentValue = Config.LogRare,
    Flag = "LogRare",
    Callback = function(Value)
        Config.LogRare = Value
        SaveConfig()
    end,
})

LogTab:CreateToggle({
    Name = "Log Ultra Rares",
    CurrentValue = Config.LogUltraRare,
    Flag = "LogUltraRare",
    Callback = function(Value)
        Config.LogUltraRare = Value
        SaveConfig()
    end,
})

LogTab:CreateToggle({
    Name = "Log Legendaries",
    CurrentValue = Config.LogLegendary,
    Flag = "LogLegendary",
    Callback = function(Value)
        Config.LogLegendary = Value
        SaveConfig()
    end,
})

LogTab:CreateInput({
    Name = "Desired Pets (comma separated, keep these)",
    PlaceholderText = "pet_recycler_2025_giant_panda, penguins_2025_dango_penguins",
    RemoveTextAfterFocusLost = false,
    CurrentValue = table.concat(Config.DesiredPets, ", "),
    Flag = "DesiredPets",
    Callback = function(Text)
        Config.DesiredPets = {}
        for pet in Text:gmatch("[^,]+") do
            table.insert(Config.DesiredPets, pet:lower():gsub("%s+", ""))
        end
        SaveConfig()
    end,
})

-- Anti-AFK
local antiAFKConn
function StartAntiAFK()
    if antiAFKConn then antiAFKConn:Disconnect() end
    antiAFKConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:Move(Vector3.new(0,0,0), true)
        end
    end)
end

-- Auto Play & House
function AutoPlayHouse()
    local playClicked = false
    local clickingEnabled = true
    local playButton = nil
    local function updateStep(msg)
        print("[Auto] " .. msg)
        StatusLabel:Set(msg)
    end
    updateStep("Waiting for load...")
    repeat task.wait(0.5) until player:GetAttribute("file_load_status") == "done"
    Notify("Loaded", "Starting Auto Play...", 5)
    task.wait(5)
    updateStep("Looking for Play button...")
    task.spawn(function()
        while clickingEnabled do
            task.wait(1.2)
            local success, btn = pcall(function()
                return player.PlayerGui:FindFirstChild("NewsApp", true):FindFirstChild("EnclosingFrame", true)
                        :FindFirstChild("MainFrame", true):FindFirstChild("Buttons", true):FindFirstChild("PlayButton")
            end)
            if success and btn and btn:IsA("GuiButton") and btn.Visible then
                playButton = btn
                updateStep("Play button found...")
                break
            end
        end
    end)
    task.spawn(function()
        while clickingEnabled do
            task.wait(4 + math.random(0, 2))
            if not clickingEnabled or not playButton then continue end
            pcall(function()
                firesignal(playButton.MouseButton1Down)
                firesignal(playButton.Activated)
                task.wait(1.0)
                firesignal(playButton.MouseButton1Up)
                firesignal(playButton.MouseButton1Click)
            end)
        end
    end)
    task.spawn(function()
        updateStep("Waiting for entry...")
        while not playClicked do
            task.wait(0.3)
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp.Position.Y < 200 then
                    local interiors = Workspace:FindFirstChild("Interiors")
                    if interiors and interiors:FindFirstChild("Neighborhood!Christmas") then
                        playClicked = true
                        clickingEnabled = false
                        playButton = nil
                        updateStep("Entered game - direct house teleport...")
                        task.wait(3)
                        local char_id = "StreamingId_" .. player.Name .. "_" .. HttpService:GenerateGUID(false):gsub("-", ""):lower()
                        API["HousingAPI/SubscribeToHouse"]:FireServer(player)
                        task.wait(0.5)
                        API["LocationAPI/SetLocation"]:FireServer("housing", player)
                        task.wait(0.5)
                        API["AdoptAPI/SendPassiveDoorEnter"]:FireServer("housing", "MainDoor", {
                            house_owner = player,
                            start_transparency = 1,
                            studs_ahead_of_door = 4,
                            char_id = char_id
                        })
                        local start = tick()
                        while tick() - start < 15 do
                            local c = player.Character
                            if c and c:FindFirstChild("HumanoidRootPart") then
                                local pos = c.HumanoidRootPart.Position
                                local int = Workspace:FindFirstChild("Interiors")
                                if int and (pos.Y > 50 or int:FindFirstChild("Micro2023")) then
                                    updateStep("In house - ready for hatching")
                                    Notify("In House", "Equip Starter Egg to hatch", 6)
                                    StartHatching()
                                    return
                                end
                            end
                            task.wait(0.5)
                        end
                        updateStep("House loading...")
                    end
                end
            end
        end
    end)
end

-- Hatching
function StartHatching()
    StatusLabel:Set("Waiting for Starter Egg...")
    Notify("Ready", "Equip Starter Egg to begin", 8)
    while not Workspace.Pets:FindFirstChild("Starter Egg") do
        task.wait(1)
    end
    Notify("STARTER EGG DETECTED", "Starting mass Crystal Egg hatch...", 6)
    task.wait(6)
    local hatchedPets = {}
    local hatchStartTime = tick()
    local attempts = 0
    while attempts < 5 do
        local inv = ClientData.get("inventory").pets or {}
        local crystalEggs = {}
        for id, data in pairs(inv) do
            if (data.kind or ""):lower():find("pet_recycler_2025_crystal_egg") then
                table.insert(crystalEggs, id)
            end
        end
        if #crystalEggs == 0 then break end
        Notify("HATCHING", #crystalEggs .. " Crystal Eggs left (Attempt " .. (attempts + 1) .. ")", 5)
        for _, eggId in ipairs(crystalEggs) do
            pcall(function()
                EquipRemote:InvokeServer(eggId, {equip_as_last = false, use_sound_delay = true})
            end)
            task.wait(2.3)
        end
        attempts = attempts + 1
        task.wait(2)
    end

    if tick() - hatchStartTime > 180 and #hatchedPets == 0 then
        Notify("TIMEOUT", "No eggs hatched in 3 min – rejoining", 10)
        task.wait(10)
        TeleportService:Teleport(game.PlaceId)
        return
    end

    local hasGood = false
    for _, name in ipairs(hatchedPets) do
        for _, desired in ipairs(Config.DesiredPets) do
            if name:find(desired) then
                hasGood = true
                break
            end
        end
        if hasGood then break end
    end

    if hasGood then
        Notify("GOOD PET HATCHED", "WINNER – SCRIPT WILL REJOIN!", 20)
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, player)
    else
        if Config.AutoRollback then
            Rollback()
        end
    end
end

-- Auto Rejoin
if Config.AutoRejoin then
    player.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            task.wait(Config.RejoinDelay)
            TeleportService:Teleport(game.PlaceId)
        end
    end)
end

-- Auto Start if enabled
if Config.AutoPlayHouse then AutoPlayHouse() end
if Config.AntiAFK then StartAntiAFK() end

Notify("Hatcher Loaded", "Configure in UI and toggle Auto Play!", 10)
StatusLabel:Set("Ready - Toggle Auto Play & House")
