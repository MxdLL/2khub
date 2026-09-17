-- [[ 🔥 2SKI - RIDE A PET (ขี่สัตว์เลี้ยง) MASTER MOBILE & iOS EDITION 🔥 ]] --
-- UI Engine: WindUI Glassy Tiffany + macOS 3-Dots + Responsive Mobile & iOS Layout
-- Game: ขี่สัตว์เลี้ยง (Ride a Pet) - PlaceId: 124216119978534
-- Re-Engineered & Architected by cook45 for clack (Mobile Zero-Lag & Anti-Stutter Engine)

local myToken = tick()
_G.TwoSkiActiveToken = myToken

if _G.TwoSkiCleanup then
    pcall(_G.TwoSkiCleanup)
    task.wait(0.2)
end

_G.TwoSkiActiveToken = myToken
_G.TwoSkiRunning = true
_G.TwoSkiLoaded = false

-- Core Services
local cloneref = (cloneref or clonereference or function(inst) return inst end)
local function safeService(name)
    local ok, svc = pcall(function()
        local s = game:GetService(name)
        if cloneref then
            local ref = cloneref(s)
            if ref and typeof(ref) == "Instance" then return ref end
        end
        return s
    end)
    return ok and svc or nil
end

local Players = safeService("Players") or game:GetService("Players")
local ReplicatedStorage = safeService("ReplicatedStorage") or game:GetService("ReplicatedStorage")
local UserInputService = safeService("UserInputService") or game:GetService("UserInputService")
local RunService = safeService("RunService") or game:GetService("RunService")
local HttpService = safeService("HttpService") or game:GetService("HttpService")
local TweenService = safeService("TweenService") or game:GetService("TweenService")
local TeleportService = safeService("TeleportService") or game:GetService("TeleportService")
local CoreGui = safeService("CoreGui")
local VirtualUser = safeService("VirtualUser")
local VirtualInputManager = safeService("VirtualInputManager")

-- Mobile & iOS Touch Diagnostics
local isTouchDevice = UserInputService.TouchEnabled
local isMobile = isTouchDevice and (not UserInputService.KeyboardEnabled or isTouchDevice)

-- Safe Clipboard Handler (Protects Mobile / iOS Executors like Delta, Appleware, Cryptic)
local function safeCopy(text)
    pcall(function()
        if setclipboard then
            setclipboard(text)
        elseif toclipboard then
            toclipboard(text)
        end
    end)
end

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.05)
    LocalPlayer = Players.LocalPlayer
end

-- Safe Universal GUI Resolver (Guarantees execution on Delta, Appleware, Codex, Fluxus, Solara, Wave)
local getgenv_fn = getgenv or function() return _G end
local env = getgenv_fn()

local canWriteCoreGui = false
pcall(function()
    if CoreGui then
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test:Destroy()
        canWriteCoreGui = true
    end
end)

if not env.gethui or type(env.gethui) ~= "function" then
    if not canWriteCoreGui then
        env.gethui = function()
            return LocalPlayer:WaitForChild("PlayerGui", 10)
        end
    end
end

local function getSafeGuiContainer()
    if env.gethui then
        local ok, h = pcall(env.gethui)
        if ok and h and typeof(h) == "Instance" then return h end
    end
    if canWriteCoreGui and CoreGui then
        local ok, r = pcall(function() return CoreGui:FindFirstChild("RobloxGui") end)
        if ok and r then return r end
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

local function safeDestroyGui(name)
    pcall(function()
        local parents = {}
        if gethui then pcall(function() table.insert(parents, gethui()) end) end
        if CoreGui then
            pcall(function() table.insert(parents, CoreGui:FindFirstChild("RobloxGui")) end)
            table.insert(parents, CoreGui)
        end
        if LocalPlayer then table.insert(parents, LocalPlayer:FindFirstChild("PlayerGui")) end
        for _, p in ipairs(parents) do
            if p then
                for _, c in ipairs(p:GetChildren()) do
                    if c and (c.Name == name or c.Name:find(name, 1, true)) then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
    end)
end

safeDestroyGui("TwoSki_EggESP")
safeDestroyGui("TwoSki_RideAPet_Floating")
safeDestroyGui("TwoSki_Floating_ToggleButton")
safeDestroyGui("TwoSki_Float_V3")
safeDestroyGui("WindUI")

-- Remotes & Modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local GameRemotes = Remotes and Remotes:WaitForChild("Game", 10)
local ReusableRemotes = Remotes and Remotes:WaitForChild("Reusable", 10)

local Remote_EggPickup       = GameRemotes and GameRemotes:FindFirstChild("EggPickup")
local Remote_EggPlaced       = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")
local Remote_Hatch           = GameRemotes and GameRemotes:FindFirstChild("Hatch")
local Remote_FeedPet         = GameRemotes and GameRemotes:FindFirstChild("FeedPet")
local Remote_PetCollect      = GameRemotes and GameRemotes:FindFirstChild("PetCollect")
local Remote_PlacePet        = GameRemotes and GameRemotes:FindFirstChild("PlacePet")
local Remote_PickupPet       = GameRemotes and GameRemotes:FindFirstChild("PickupPet")
local Remote_Mounting        = GameRemotes and GameRemotes:FindFirstChild("Mounting")
local Remote_PetDismount     = GameRemotes and GameRemotes:FindFirstChild("PetDismount")
local Remote_BuyWithCash     = GameRemotes and GameRemotes:FindFirstChild("BuyWithCash")
local Remote_Rebirth         = GameRemotes and GameRemotes:FindFirstChild("Rebirth")
local Remote_ClaimIndex      = GameRemotes and GameRemotes:FindFirstChild("ClaimIndexReward")
local Remote_OfflineEarnings = GameRemotes and GameRemotes:FindFirstChild("OfflineEarnings")
local Remote_PlotNests       = GameRemotes and GameRemotes:FindFirstChild("Plot") and GameRemotes.Plot:FindFirstChild("Nests")
local Remote_PlotUpgrades    = GameRemotes and GameRemotes:FindFirstChild("Plot") and GameRemotes.Plot:FindFirstChild("Upgrades")
local Remote_TeleportToPlot  = GameRemotes and GameRemotes:FindFirstChild("TeleportToPlot")
local Remote_ClaimGroupReward = ReusableRemotes and ReusableRemotes:FindFirstChild("ClaimGroupReward")
local Remote_ClaimEventReward = ReusableRemotes and ReusableRemotes:FindFirstChild("ClaimEventReward")

local GamePetsData = {}
pcall(function() GamePetsData = require(ReplicatedStorage.GameData.Pets) end)
local GameEggsData = {}
pcall(function() GameEggsData = require(ReplicatedStorage.GameData.Eggs) end)
local HatchLuckModule = nil
pcall(function() HatchLuckModule = require(ReplicatedStorage.GameData.HatchLuck) end)
local NestPrices = { [1] = 0, [2] = 1000, [3] = 5000, [4] = 100000, [5] = 1000000 }
pcall(function()
    local nData = require(ReplicatedStorage.GameData.Nests)
    if nData and nData.Prices then NestPrices = nData.Prices end
end)

local RarityScoreMap = { Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Divine=7, Ethereal=8 }

-- Helper Functions
local function getCharHrp()
    local c = LocalPlayer.Character or workspace:FindFirstChild(LocalPlayer.Name)
    local hrp = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"))
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

local cachedPlot = nil
local function getMyPlot()
    if cachedPlot and cachedPlot.Parent then
        local ownerId = cachedPlot:GetAttribute("NestsOwnerLoaded") or cachedPlot:GetAttribute("OwnerUserId")
        local ownerName = cachedPlot:GetAttribute("Owner")
        local dataOwner = cachedPlot:FindFirstChild("Data") and cachedPlot.Data:FindFirstChild("Owner")
        if (ownerId and tostring(ownerId) == tostring(LocalPlayer.UserId)) or (ownerName and ownerName == LocalPlayer.Name) or (dataOwner and dataOwner.Value == LocalPlayer) then
            return cachedPlot
        end
    end
    local ok, General = pcall(function() return require(ReplicatedStorage.GameServices.General) end)
    if ok and General and General.GetPlot then
        local p = General:GetPlot(LocalPlayer)
        if p then cachedPlot = p; return p end
    end
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            local ownerId = p:GetAttribute("NestsOwnerLoaded") or p:GetAttribute("OwnerUserId")
            local ownerName = p:GetAttribute("Owner")
            local dataOwner = p:FindFirstChild("Data") and p.Data:FindFirstChild("Owner")
            if (ownerId and tostring(ownerId) == tostring(LocalPlayer.UserId)) or (ownerName and ownerName == LocalPlayer.Name) or (dataOwner and dataOwner.Value == LocalPlayer) then
                cachedPlot = p
                return p
            end
        end
    end
    return nil
end

local function getPlotCenterPos()
    local myPlot = getMyPlot()
    if not myPlot then return nil end
    local baseplate = myPlot:FindFirstChild("Baseplate")
    if baseplate then
        return baseplate.Position + Vector3.new(0, 4, 0)
    end
    if myPlot:FindFirstChild("Nests") and myPlot.Nests:FindFirstChild("1") then
        return myPlot.Nests["1"]:GetPivot().Position + Vector3.new(0, 4, 0)
    end
    return myPlot:GetPivot().Position + Vector3.new(0, 4, 0)
end

local SaveModule = nil
pcall(function()
    if ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("Save") then
        SaveModule = require(ReplicatedStorage.Shared.Save)
    end
end)

local function parseSuffixedNumber(str)
    if not str or type(str) ~= "string" then return tonumber(str) or 0 end
    local cleaned = str:gsub("%$", ""):gsub(",", ""):gsub("%s+", "")
    local numStr, suffix = cleaned:match("^([%d%.]+)%s*([%a]*)$")
    if not numStr then return tonumber(cleaned) or 0 end
    local num = tonumber(numStr) or 0
    local s = (suffix or ""):upper()
    if s == "K" then return num * 1e3
    elseif s == "M" then return num * 1e6
    elseif s == "B" then return num * 1e9
    elseif s == "T" then return num * 1e12
    elseif s == "QA" or s == "Q" then return num * 1e15
    elseif s == "QI" then return num * 1e18
    elseif s == "SX" then return num * 1e21
    elseif s == "SP" then return num * 1e24
    elseif s == "OC" then return num * 1e27
    elseif s == "NO" then return num * 1e30
    elseif s == "DC" then return num * 1e33
    end
    return num
end

local function getPlayerCash()
    -- 1. LocalPlayer.SavedData (direct live storage)
    local sd = LocalPlayer:FindFirstChild("SavedData")
    if sd then
        local c = sd:FindFirstChild("Cash") or sd:FindFirstChild("Money") or sd:FindFirstChild("Coins")
        if c and c.Value then
            local val = tonumber(c.Value)
            if val then return val end
        end
    end

    -- 2. Shared.Save Module
    if SaveModule and type(SaveModule.Get) == "function" then
        local success, data = pcall(SaveModule.Get)
        if success and type(data) == "table" then
            local val = data.Money or data.Cash or data.Coins
            if val and tonumber(val) then return tonumber(val) end
        end
    end

    -- 3. leaderstats
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Money")
        if cash and cash.Value then
            local val = tonumber(cash.Value)
            if val then return val end
        end
    end

    -- 4. PlayerGui HUD text fallback
    local successHud, hudCash = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local hud = pg and pg:FindFirstChild("HUD")
        local moneyLbl = hud and hud:FindFirstChild("GameHUD") and hud.GameHUD:FindFirstChild("BottomLeft") and hud.GameHUD.BottomLeft:FindFirstChild("Money") and hud.GameHUD.BottomLeft.Money:FindFirstChild("Value")
        if moneyLbl and moneyLbl:IsA("TextLabel") and moneyLbl.Text then
            return parseSuffixedNumber(moneyLbl.Text)
        end
        return nil
    end)
    if successHud and hudCash and hudCash > 0 then
        return hudCash
    end

    return 0
end

local cachedPetRenderer = nil
local function canAffordHatchLuck()
    local currentCash = getPlayerCash()
    local sd = LocalPlayer:FindFirstChild("SavedData")
    local curUp = (sd and sd:FindFirstChild("HatchUpgrades") and tonumber(sd.HatchUpgrades.Value)) or 0
    local usedFree = (sd and sd:FindFirstChild("UsedFreeHatchUpgrades") and tonumber(sd.UsedFreeHatchUpgrades.Value)) or 0
    local freeUp = (sd and sd:FindFirstChild("FreeHatchUpgrades") and tonumber(sd.FreeHatchUpgrades.Value)) or 0

    if SaveModule and type(SaveModule.Get) == "function" then
        pcall(function()
            local d = SaveModule.Get()
            if type(d) == "table" then
                if d.BaseUpgradeLevel and curUp == 0 then curUp = tonumber(d.BaseUpgradeLevel) or 0 end
                if d.FreeHatchUpgrades and freeUp == 0 then freeUp = tonumber(d.FreeHatchUpgrades) or 0 end
                if d.UsedFreeHatchUpgrades and usedFree == 0 then usedFree = tonumber(d.UsedFreeHatchUpgrades) or 0 end
            end
        end)
    end

    if freeUp > 0 then
        return true, 0, freeUp
    end

    local paidUp = curUp
    if HatchLuckModule and HatchLuckModule.GetPaidUpgrades then
        pcall(function()
            paidUp = HatchLuckModule.GetPaidUpgrades(curUp + freeUp, usedFree + freeUp) or curUp
        end)
    end

    local singlePrice = 0
    if HatchLuckModule and HatchLuckModule.GetPrice then
        pcall(function()
            singlePrice = HatchLuckModule.GetPrice(paidUp) or 0
        end)
    end

    -- If single price is known and player has less than 1 upgrade cost, reject
    if singlePrice > 0 and currentCash < singlePrice then
        return false, singlePrice, 0
    end

    if HatchLuckModule and HatchLuckModule.GetMaxAffordable then
        local ok, count, cost = pcall(HatchLuckModule.GetMaxAffordable, paidUp, currentCash)
        if ok and count and count > 0 and currentCash >= cost then
            return true, cost, count
        end
    end

    if currentCash >= singlePrice and currentCash > 0 then
        return true, singlePrice, 1
    end

    if singlePrice == 0 and currentCash > 0 then
        return true, 0, 1
    end

    return false, singlePrice, 0
end

local function isOnMyPlot()
    local char, hrp = getCharHrp()
    if not hrp then return false end
    local myPlot = getMyPlot()
    if not myPlot then return false end
    local pivot = myPlot:GetPivot()
    if not pivot then return false end
    local dist = (hrp.Position - pivot.Position).Magnitude
    return dist <= 125
end

local function getPetRenderer()
    if cachedPetRenderer then return cachedPetRenderer end
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts") then
            local gameFolder = LocalPlayer.PlayerScripts:FindFirstChild("Game")
            local petsFolder = gameFolder and gameFolder:FindFirstChild("Pets")
            local prMod = petsFolder and petsFolder:FindFirstChild("PetRenderer")
            if prMod then
                cachedPetRenderer = require(prMod)
            end
        end
    end)
    return cachedPetRenderer
end

local function normalizeMultiSelection(val)
    if not val then return {} end
    if type(val) == "string" then
        local s = val:gsub("^%s+", ""):gsub("%s+$", "")
        return #s > 0 and {s} or {}
    end
    if type(val) ~= "table" then return {} end
    local list = {}
    for k, v in pairs(val) do
        if type(k) == "number" and type(v) == "string" then
            local s = v:gsub("^%s+", ""):gsub("%s+$", "")
            if #s > 0 then table.insert(list, s) end
        elseif type(k) == "string" and (v == true or v == 1 or type(v) == "string") then
            local s = k:gsub("^%s+", ""):gsub("%s+$", "")
            if #s > 0 then table.insert(list, s) end
        elseif type(v) == "string" then
            local s = v:gsub("^%s+", ""):gsub("%s+$", "")
            if #s > 0 then table.insert(list, s) end
        end
    end
    return list
end

local function getEggScore(eggName)
    if not eggName or eggName == "" then return 0, "Common" end
    local rawName = tostring(eggName):gsub("%s*%b()", ""):gsub("%s*%b[]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cleanName = rawName:gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local withEgg = cleanName .. " Egg"

    local data = GameEggsData[withEgg] or GameEggsData[rawName] or GameEggsData[eggName] or GameEggsData[cleanName]
    if not data and GameEggsData then
        for k, v in pairs(GameEggsData) do
            local kClean = tostring(k):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if string.lower(kClean) == string.lower(cleanName) 
               or string.lower(tostring(k)) == string.lower(rawName) 
               or string.lower(tostring(k)) == string.lower(withEgg) then
                data = v
                break
            end
        end
    end

    local rarity = data and data.Rarity
    if not rarity then
        for rName in pairs(RarityScoreMap) do
            if rawName:lower():find(rName:lower(), 1, true) then
                rarity = rName
                break
            end
        end
    end

    local rScore = RarityScoreMap[rarity or "Common"] or 1
    local luck = (data and (data.Luck or data.luck)) or 1
    -- Total score: lower means weaker (กาก), higher means stronger (โหดสุด)
    local totalScore = (rScore * 1e12) + luck
    return totalScore, rarity or "Common"
end

local function getServerEggsList()
    local found = {}

    -- 1. All valid eggs from GameEggsData (The real master database of eggs)
    if GameEggsData then
        for k in pairs(GameEggsData) do
            local clean = tostring(k):gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if #clean > 0 then
                found[clean] = true
            end
        end
    end

    -- 2. Rendered eggs in workspace
    local rendered = workspace:FindFirstChild("RenderedEggs")
    if rendered then
        for _, egg in ipairs(rendered:GetChildren()) do
            local attrEgg = egg:GetAttribute("Egg") or egg:GetAttribute("EggType") or egg:GetAttribute("Type")
            local nameToCheck = (attrEgg and typeof(attrEgg) == "string" and attrEgg) or egg.Name
            if nameToCheck and #nameToCheck > 0 and not nameToCheck:find("^[0-9]+$") then
                local clean = nameToCheck:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                if #clean > 0 then
                    found[clean] = true
                end
            end
        end
    end

    -- 3. Active eggs in ServerData
    local serverData = ReplicatedStorage:FindFirstChild("ServerData")
    local activeEggs = serverData and serverData:FindFirstChild("ActiveEggs")
    if activeEggs then
        for _, ae in ipairs(activeEggs:GetChildren()) do
            local eggType = ae:GetAttribute("Egg") or ae:GetAttribute("EggType") or ae.Name
            if eggType and typeof(eggType) == "string" and #eggType > 0 then
                local clean = eggType:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                if #clean > 0 then
                    found[clean] = true
                end
            end
        end
    end

    local sorted = {}
    for name in pairs(found) do
        table.insert(sorted, name)
    end

    table.sort(sorted, function(a, b)
        local scoreA = getEggScore(a)
        local scoreB = getEggScore(b)
        if scoreA ~= scoreB then return scoreA < scoreB end
        return a < b
    end)

    local list = {"All / ทั้งหมด (เลือกตามกิโล หรือเก็บทุกชนิด)"}
    for _, name in ipairs(sorted) do
        local _, rarity = getEggScore(name)
        table.insert(list, name .. " [" .. rarity .. "]")
    end
    return list
end

local function getEggShownKG(realWeight)
    realWeight = tonumber(realWeight) or 1
    local ok, General = pcall(function() return require(ReplicatedStorage.GameData.General) end)
    if ok and General and General.ShownEggKG then
        local sOk, res = pcall(General.ShownEggKG, realWeight)
        if sOk and res then return res end
    end
    if realWeight <= 1.2 then return 15 end
    if realWeight <= 1.5 then
        local t = (realWeight - 1.2) / (1.5 - 1.2)
        return 10 ^ (math.log10(15) + t * (math.log10(1500) - math.log10(15)))
    elseif realWeight <= 2.0 then
        local t = (realWeight - 1.5) / (2.0 - 1.5)
        return 10 ^ (math.log10(1500) + t * (math.log10(240000) - math.log10(1500)))
    else
        local t = (realWeight - 2.0) / (3.0 - 2.0)
        return 10 ^ (math.log10(240000) + t * (math.log10(1500000) - math.log10(240000)))
    end
end

local function formatKG(kg)
    kg = tonumber(kg) or 0
    if kg >= 1e6 then
        return string.format("%.1fM KG", kg / 1e6)
    elseif kg >= 1e3 then
        return string.format("%.1fK KG", kg / 1e3)
    else
        return string.format("%.0f KG", kg)
    end
end

local function getActiveEggInfo(eggModel)
    if not eggModel then return nil, 1, 15 end
    local part = eggModel:FindFirstChildWhichIsA("BasePart") or eggModel.PrimaryPart
    local eggPos = part and part.Position or eggModel:GetPivot().Position
    local sd = ReplicatedStorage:FindFirstChild("ServerData")
    local activeFolder = sd and sd:FindFirstChild("ActiveEggs")
    if not activeFolder then return nil, 1, 15 end

    local bestMatch = nil
    local bestDist = 25.0
    for _, ae in ipairs(activeFolder:GetChildren()) do
        local posAttr = ae:GetAttribute("Position")
        local pVec = posAttr
        if typeof(posAttr) == "string" then
            local coords = string.split(posAttr, ",")
            if #coords == 3 then
                pVec = Vector3.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
            end
        end
        if typeof(pVec) == "Vector3" then
            local horizDist = (Vector3.new(pVec.X, 0, pVec.Z) - Vector3.new(eggPos.X, 0, eggPos.Z)).Magnitude
            local vertDist = math.abs(pVec.Y - eggPos.Y)
            if horizDist < 15.0 and vertDist < 45.0 and horizDist < bestDist then
                bestDist = horizDist
                bestMatch = ae
            end
        end
    end

    local realW = bestMatch and bestMatch:GetAttribute("Weight") or 1
    local shownKG = getEggShownKG(realW)
    return bestMatch, realW, shownKG
end

local function calculatePetScore(petName, weight, age)
    if not petName then return 0 end
    local cleanName = tostring(petName):gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local petInfo = GamePetsData[cleanName] or GamePetsData[petName] or {}
    local rScore = RarityScoreMap[petInfo.Rarity or "Common"] or 1
    local speed = petInfo.Speed or 50
    return (rScore * 100000) + (speed * 1000) + ((tonumber(weight) or 1) * 10) + (tonumber(age) or 1)
end

local activeFlightBv = nil

local function ensureFlightHold(hrp)
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    local oldBg = hrp:FindFirstChild("TwoSkiFlightGyro")
    if oldBg then oldBg:Destroy() end

    if not activeFlightBv or not activeFlightBv.Parent or activeFlightBv.Parent ~= hrp then
        local old = hrp:FindFirstChild("TwoSkiFlightHold")
        if old then old:Destroy() end
        activeFlightBv = Instance.new("BodyVelocity")
        activeFlightBv.Name = "TwoSkiFlightHold"
        activeFlightBv.MaxForce = Vector3.new(2e6, 2e6, 2e6) -- Stable rock-solid force (Zero Jump/Physics Lock)
        activeFlightBv.Velocity = Vector3.zero
        activeFlightBv.Parent = hrp
    end
end

local function releaseFlightHold()
    if activeFlightBv then
        pcall(function() activeFlightBv:Destroy() end)
        activeFlightBv = nil
    end
    local _, hrp, hum = getCharHrp()
    if hrp then
        pcall(function()
            local old1 = hrp:FindFirstChild("TwoSkiFlightHold")
            if old1 then old1:Destroy() end
            local old2 = hrp:FindFirstChild("TwoSkiFlightGyro")
            if old2 then old2:Destroy() end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            local yaw = select(2, hrp.CFrame:ToEulerAnglesYXZ())
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
        end)
    end
end

local function tweenFlight(targetPos, speed)
    local _, hrp, hum = getCharHrp()
    if not hrp then return false end
    local dist = (hrp.Position - targetPos).Magnitude
    if dist < 0.8 then return true end
    local dur = math.max(dist / (speed or 250), 0.06)

    ensureFlightHold(hrp)

    -- Calculate smooth horizontal yaw only when moving a meaningful horizontal distance
    local dx = targetPos.X - hrp.Position.X
    local dz = targetPos.Z - hrp.Position.Z
    local targetRot = hrp.CFrame.Rotation
    if (dx * dx + dz * dz) > 4.0 then
        local yaw = math.atan2(-dx, -dz)
        targetRot = CFrame.Angles(0, yaw, 0)
    end

    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos) * targetRot})
    tw:Play()
    tw.Completed:Wait()

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    ensureFlightHold(hrp)
    return true
end

local function isNestPhysicallyOccupied(nest, eggsFolder)
    if not nest then return true end
    if nest:GetAttribute("Unlocked") ~= true then return true end -- Only unlocked nests can accept eggs
    if nest:GetAttribute("Occupied") == true then return true end
    if eggsFolder then
        local nestPos = nest:GetPivot().Position
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            local nId = egg:GetAttribute("NestId")
            if nId and tostring(nId) == nest.Name then return true end
            local part = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
            local eggPos = part and part.Position or egg:GetPivot().Position
            if (Vector3.new(eggPos.X, 0, eggPos.Z) - Vector3.new(nestPos.X, 0, nestPos.Z)).Magnitude < 6.5 then
                return true
            end
        end
    end
    return false
end

local function findEmptyPlotNest()
    local myPlot = getMyPlot()
    if not myPlot or not myPlot:FindFirstChild("Nests") then return nil end
    local eggsFolder = myPlot:FindFirstChild("Eggs")
    for _, nest in ipairs(myPlot.Nests:GetChildren()) do
        if not isNestPhysicallyOccupied(nest, eggsFolder) then
            return nest
        end
    end
    return nil
end

local function triggerPrompt(prompt, holdTime)
    if not prompt or not prompt.Parent then return end
    local executed = false
    if fireproximityprompt then
        local ok = pcall(function() fireproximityprompt(prompt, 0) end)
        if ok then executed = true end
    end
    if not executed and prompt.InputHoldBegin and prompt.InputHoldEnd then
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(holdTime or (prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.05) or 0.15))
            prompt:InputHoldEnd()
        end)
    end
end

local function getAllEmptyPlotNests()
    local myPlot = getMyPlot()
    if not myPlot or not myPlot:FindFirstChild("Nests") then return {} end
    local eggsFolder = myPlot:FindFirstChild("Eggs")
    local list = {}
    for _, nest in ipairs(myPlot.Nests:GetChildren()) do
        if not isNestPhysicallyOccupied(nest, eggsFolder) then
            table.insert(list, nest)
        end
    end
    table.sort(list, function(a, b)
        return (tonumber(a.Name) or 999) < (tonumber(b.Name) or 999)
    end)
    return list
end

local function getEggToolRarity(eggTool)
    if not eggTool then return "Common" end
    local rAttr = eggTool:GetAttribute("Rarity")
    if rAttr and typeof(rAttr) == "string" and #rAttr > 0 then
        return rAttr
    end

    local toolName = eggTool.Name or ""
    local cleanName = toolName:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local withEgg = cleanName .. " Egg"

    local eggType = eggTool:GetAttribute("Egg") or eggTool:GetAttribute("EggType") or eggTool:GetAttribute("Type")
    local typeName = eggType and typeof(eggType) == "string" and eggType:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local typeWithEgg = typeName and (typeName .. " Egg")

    local eData = (typeWithEgg and GameEggsData[typeWithEgg]) 
               or (eggType and GameEggsData[eggType])
               or GameEggsData[withEgg] 
               or GameEggsData[toolName] 
               or GameEggsData[cleanName]

    if not eData and GameEggsData then
        for k, v in pairs(GameEggsData) do
            local kClean = tostring(k):gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if string.lower(kClean) == string.lower(cleanName)
               or (typeName and string.lower(kClean) == string.lower(typeName)) then
                eData = v
                break
            end
        end
    end

    if eData and eData.Rarity then return eData.Rarity end

    for rName in pairs(RarityScoreMap) do
        if toolName:lower():find(rName:lower(), 1, true) then
            return rName
        end
    end

    return "Common"
end

local function isEggToolRarityMatching(eggTool)
    if not eggTool then return false end
    local rarities = normalizeMultiSelection(State.PlaceEggRarityFilter)
    if #rarities == 0 then return true end
    for _, r in ipairs(rarities) do
        if r == "All Rarities" or r:find("All", 1, true) or r:find("ทั้งหมด", 1, true) then
            return true
        end
    end
    local eggRarity = getEggToolRarity(eggTool)
    for _, r in ipairs(rarities) do
        if string.lower(eggRarity) == string.lower(r) then
            return true
        end
    end
    return false
end

local function isEggToolTypeMatching(eggTool)
    if not eggTool then return false end
    local targets = normalizeMultiSelection(State.PlaceEggTarget)
    if #targets == 0 then return true end
    for _, t in ipairs(targets) do
        if t == "All / ทั้งหมด" or t == "All" or t:find("All", 1, true) or t:find("ทั้งหมด", 1, true) then
            return true
        end
    end

    local rawName = eggTool.Name:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local cleanTool = rawName:gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local attrEgg = eggTool:GetAttribute("Egg") or eggTool:GetAttribute("EggType") or eggTool:GetAttribute("Type")
    local candidates = { string.lower(rawName), string.lower(cleanTool) }
    if attrEgg and typeof(attrEgg) == "string" and #attrEgg > 0 then
        local attrClean = attrEgg:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(candidates, string.lower(attrEgg))
        table.insert(candidates, string.lower(attrClean))
    end

    for _, t in ipairs(targets) do
        local cleanT = string.lower(t:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("Egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
        for _, cand in ipairs(candidates) do
            if cand == cleanT or cand:find(cleanT, 1, true) or cleanT:find(cand, 1, true) then
                return true
            end
        end
    end
    return false
end

local function isEggToolMatching(eggTool)
    return isEggToolTypeMatching(eggTool) and isEggToolRarityMatching(eggTool)
end

local function getInventoryEggs(applyFilters)
    local eggs = {}
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Egg") or item:GetAttribute("Egg") or item:GetAttribute("IsEgg")) then
                if not applyFilters or isEggToolMatching(item) then
                    table.insert(eggs, item)
                end
            end
        end
    end
    if LocalPlayer.Backpack then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Egg") or item:GetAttribute("Egg") or item:GetAttribute("IsEgg")) then
                if not applyFilters or isEggToolMatching(item) then
                    table.insert(eggs, item)
                end
            end
        end
    end

    -- เรียงลำดับจากกากไปโหดสุด (Common -> Ethereal / Lowest Score to Highest Score)
    table.sort(eggs, function(a, b)
        local scoreA = getEggScore(a.Name)
        local scoreB = getEggScore(b.Name)
        if scoreA ~= scoreB then
            return scoreA < scoreB -- กากไปโหดสุด (Ascending: 1, 2, 3...)
        end
        return a.Name < b.Name
    end)

    return eggs
end

local function depositBasketToBackpack()
    local myPlot = getMyPlot()
    if not myPlot then return false end
    local baseplate = myPlot:FindFirstChild("Baseplate")
    if not baseplate then return false end
    local char, hrp = getCharHrp()
    if not char or not hrp then return false end

    local basket = LocalPlayer:FindFirstChild("Basket")
    if not basket or #basket:GetChildren() == 0 then return true end

    -- Check if player is already within baseplate horizontal area: DO NOT snap-warp if already there!
    local rel = baseplate.CFrame:PointToObjectSpace(hrp.Position)
    local isOnPlate = math.abs(rel.X) <= (baseplate.Size.X / 2 + 5) and math.abs(rel.Z) <= (baseplate.Size.Z / 2 + 5)
    if not isOnPlate then
        local surfaceY = baseplate.Position.Y + (baseplate.Size.Y / 2) + 2.5
        local targetPos = Vector3.new(baseplate.Position.X, surfaceY, baseplate.Position.Z)
        local yaw = select(2, hrp.CFrame:ToEulerAnglesYXZ())
        hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, yaw, 0)
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end)
        task.wait(0.08)
    end

    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, baseplate, 0)
            task.wait(0.04)
            firetouchinterest(hrp, baseplate, 1)
        end)
    end

    if basket and #basket:GetChildren() > 0 then
        local t0 = tick()
        while tick() - t0 < 1.2 and #basket:GetChildren() > 0 do
            task.wait(0.05)
        end
    end
    return true
end

local function getPlotPlantedEggs()
    local myPlot = getMyPlot()
    if not myPlot or not myPlot:FindFirstChild("Eggs") then return {} end
    local list = {}
    for _, egg in ipairs(myPlot.Eggs:GetChildren()) do
        if egg:IsA("Model") then
            table.insert(list, egg)
        end
    end
    return list
end

local function getOpenPlacementPositions(extraOccupiedSpots)
    local myPlot = getMyPlot()
    if not myPlot then return {} end
    local bp = myPlot:FindFirstChild("Baseplate")
    if not bp then return {} end

    local plantedEggs = getPlotPlantedEggs()
    local spots = {}

    local posY = bp.Position.Y + (bp.Size.Y / 2) + 0.5
    local center = Vector3.new(bp.Position.X, posY, bp.Position.Z)
    local halfX = math.clamp((bp.Size.X / 2) - 4, 10, 34)
    local halfZ = math.clamp((bp.Size.Z / 2) - 4, 10, 34)

    local function isSpotFree(pos)
        local posFlat = Vector3.new(pos.X, 0, pos.Z)
        for _, egg in ipairs(plantedEggs) do
            local pPart = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
            local pPos = pPart and pPart.Position or egg:GetPivot().Position
            if (Vector3.new(pPos.X, 0, pPos.Z) - posFlat).Magnitude < 4.2 then
                return false
            end
        end
        if extraOccupiedSpots then
            for _, occSpot in ipairs(extraOccupiedSpots) do
                if (Vector3.new(occSpot.X, 0, occSpot.Z) - posFlat).Magnitude < 4.2 then
                    return false
                end
            end
        end
        for _, existingSpot in ipairs(spots) do
            if (Vector3.new(existingSpot.X, 0, existingSpot.Z) - posFlat).Magnitude < 4.2 then
                return false
            end
        end
        return true
    end

    local step = 4.8
    for stepX = -halfX, halfX, step do
        for stepZ = -halfZ, halfZ, step do
            local candidatePos = center + Vector3.new(stepX, 0, stepZ)
            if isSpotFree(candidatePos) then
                table.insert(spots, candidatePos)
                if #spots >= 120 then
                    return spots
                end
            end
        end
    end

    return spots
end

local function placeEggOnPlot(eggTool, spot)
    if not eggTool or not eggTool.Parent then return false end
    local char, hrp, hum = getCharHrp()
    if not char or not hum or not hrp then return false end

    if hum.Sit then
        hum.Sit = false
        task.wait(0.04)
    end

    -- Ensure tool collision is disabled and massless so it never induces spin or physics impulse
    for _, p in ipairs(eggTool:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.CanCollide = false
                p.Massless = true
            end)
        end
    end

    if not spot then return false end

    -- Cleanly unequip currently held tools first to prevent tool switching deadlock
    if eggTool.Parent ~= char then
        pcall(function() hum:UnequipTools() end)
        task.wait(0.04)
        hum:EquipTool(eggTool)
        local t0 = tick()
        while tick() - t0 < 0.35 and eggTool.Parent ~= char and eggTool.Parent do
            task.wait(0.03)
        end
    end

    if eggTool.Parent ~= char then
        return false
    end

    pcall(function()
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)

    if Remote_EggPlaced then
        pcall(function()
            Remote_EggPlaced:FireServer({ PlantPosition = spot })
        end)
    end
    task.wait(0.18)
    return true
end

local function autoHatchPlotEggs()
    if not Remote_Hatch then return end
    local myPlot = getMyPlot()
    if not myPlot or not myPlot:FindFirstChild("Eggs") then return end
    for _, egg in ipairs(myPlot.Eggs:GetChildren()) do
        local key = egg:GetAttribute("EggKey")
        if key then
            local hp = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
            local hui = egg:FindFirstChild("HatchingUI", true)
            local timerLbl = hui and (hui:FindFirstChild("Timer") or hui:FindFirstChildWhichIsA("TextLabel", true))
            local isReady = false

            if hp and hp:IsA("ProximityPrompt") and hp.Enabled then
                isReady = true
            elseif timerLbl and (timerLbl.Text == "Ready!" or timerLbl.Text:lower():find("ready") or timerLbl.Text == "00:00" or timerLbl.Text == "0s") then
                isReady = true
            elseif not timerLbl and not egg:FindFirstChild("HatchingUI") then
                isReady = true
            end

            if isReady then
                lastPlotFullTime = 0
                if hp and hp:IsA("ProximityPrompt") then
                    hp.Enabled = true
                    triggerPrompt(hp, 0.05)
                end
                Remote_Hatch:FireServer({ EggKey = key })
                task.wait(0.15)
                if State.AutoPlaceEggs then
                    task.spawn(placeAllHeldEggsNow)
                end
            end
        end
    end
end

local isPlacingEggs = false
local lastPlotFullTime = 0

local function placeAllHeldEggsNow()
    if isPlacingEggs then return false end
    if tick() - lastPlotFullTime < 2.5 then return false end
    isPlacingEggs = true

    local myPlot = getMyPlot()
    if not myPlot then
        isPlacingEggs = false
        return false
    end

    local initialEggs = getInventoryEggs(true)
    if #initialEggs == 0 then initialEggs = getInventoryEggs(false) end
    if #initialEggs == 0 then
        isPlacingEggs = false
        return false
    end

    local totalPlaced = 0
    local consecutiveFails = 0
    local recentlyPlacedSpots = {}

    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        local curPlot = getMyPlot()
        if not curPlot then break end

        local curInv = getInventoryEggs(true)
        if #curInv == 0 then curInv = getInventoryEggs(false) end
        if #curInv == 0 then
            -- ไข่ในกระเป๋าหมดแล้ว
            break
        end

        local eggTool = curInv[1]
        if not eggTool or not eggTool.Parent then break end

        local openSpots = getOpenPlacementPositions(recentlyPlacedSpots)
        if #openSpots == 0 then
            lastPlotFullTime = tick()
            break
        end

        local prevPlantedCount = #getPlotPlantedEggs()
        local placedOk = false

        -- Try up to 3 candidate spots
        for spotIdx = 1, math.min(#openSpots, 3) do
            local candidateSpot = openSpots[spotIdx]
            local success = placeEggOnPlot(eggTool, candidateSpot)
            if success then
                local t0 = tick()
                while tick() - t0 < 0.45 do
                    if not eggTool.Parent or #getPlotPlantedEggs() > prevPlantedCount then
                        placedOk = true
                        table.insert(recentlyPlacedSpots, candidateSpot)
                        break
                    end
                    task.wait(0.04)
                end
            end
            if placedOk then break end
        end

        if placedOk then
            totalPlaced = totalPlaced + 1
            consecutiveFails = 0
            task.wait(0.08)
        else
            consecutiveFails = consecutiveFails + 1
            if consecutiveFails >= 2 then
                -- แปลงเต็มขีดจำกัดแล้ว
                lastPlotFullTime = tick()
                break
            end
            task.wait(0.15)
        end
    end

    isPlacingEggs = false

    local totalNow = #getPlotPlantedEggs()
    if _G.TwoSkiLoaded then
        if totalPlaced > 0 then
            WindUI:Notify({ Title = "2SKI", Content = "วางไข่สำเร็จ " .. tostring(totalPlaced) .. " ฟอง! (รวมในแปลง " .. tostring(totalNow) .. " ฟอง)" })
        elseif consecutiveFails >= 2 then
            WindUI:Notify({ Title = "2SKI", Content = "แปลงวางไข่เต็มแล้ว (" .. tostring(totalNow) .. " ฟอง)" })
        end
    end
    return totalPlaced > 0
end

local lastPetCollectNotice = 0
local function collectAllPlotPetsNow(silent)
    local totalCollected = 0
    local myPlot = getMyPlot()
    local petsFolder = myPlot and myPlot:FindFirstChild("Pets")
    if petsFolder and Remote_PickupPet then
        local pets = petsFolder:GetChildren()
        if #pets > 0 then
            for _, p in ipairs(pets) do
                local pKey = p:GetAttribute("PetKey")
                if pKey then
                    Remote_PickupPet:FireServer(pKey)
                    totalCollected = totalCollected + 1
                    task.wait(0.06)
                end
            end
        end
    end
    local PetRenderer = getPetRenderer()
    if PetRenderer and PetRenderer.GetAll and Remote_PickupPet then
        for _, pet in pairs(PetRenderer.GetAll()) do
            if pet.OwnerUserId == LocalPlayer.UserId and pet.PetKey then
                Remote_PickupPet:FireServer(pet.PetKey)
                totalCollected = totalCollected + 1
                task.wait(0.06)
            end
        end
    end

    if not silent and _G.TwoSkiLoaded and WindUI and WindUI.Notify then
        local now = tick()
        if now - lastPetCollectNotice > 2.0 then
            lastPetCollectNotice = now
            if totalCollected > 0 then
                WindUI:Notify({ Title = "2SKI", Content = "เก็บสัตว์เลี้ยงทั้งหมดในฐานลงกระเป๋าแล้ว (" .. tostring(totalCollected) .. " ตัว)" })
            else
                WindUI:Notify({ Title = "2SKI", Content = "ไม่พบสัตว์เลี้ยงในฐานให้เก็บ" })
            end
        end
    end
    return totalCollected
end

local function mountBestPetNow()
    local char, hrp, hum = getCharHrp()
    if not hum or not hrp then return false end

    local bestSource = nil
    local bestTool = nil
    local bestPlotPetKey = nil
    local bestSpeed = -1
    local bestPetName = ""

    local petsMod = nil
    pcall(function() petsMod = require(ReplicatedStorage.GameData.Pets) end)

    local function getSpeedFor(name)
        if not name then return 50 end
        local clean = tostring(name):gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
        local d = (petsMod and (petsMod[clean] or petsMod[name])) or GamePetsData[clean] or GamePetsData[name] or {}
        return d.Speed or d.RideSpeed or 50
    end

    -- 1. Check current held tool
    local held = char:FindFirstChildOfClass("Tool")
    if held and (held:GetAttribute("PetName") or held:GetAttribute("PetKey") or CollectionService:HasTag(held, "Pet")) then
        local pName = held:GetAttribute("PetName") or held.Name
        local spd = getSpeedFor(pName)
        if spd > bestSpeed then
            bestSpeed = spd
            bestTool = held
            bestSource = "char"
            bestPetName = pName
        end
    end

    -- 2. Check Backpack tools
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("PetName") or item:GetAttribute("PetKey") or CollectionService:HasTag(item, "Pet")) then
                local pName = item:GetAttribute("PetName") or item.Name
                local spd = getSpeedFor(pName)
                if spd > bestSpeed then
                    bestSpeed = spd
                    bestTool = item
                    bestSource = "backpack"
                    bestPetName = pName
                end
            end
        end
    end

    -- 3. Check Plot Pets
    local myPlot = getMyPlot()
    local petsFolder = myPlot and myPlot:FindFirstChild("Pets")
    if petsFolder then
        for _, p in ipairs(petsFolder:GetChildren()) do
            local pName = p:GetAttribute("PetName") or p.Name
            local spd = getSpeedFor(pName)
            local pKey = p:GetAttribute("PetKey")
            if spd > bestSpeed and pKey then
                bestSpeed = spd
                bestPlotPetKey = pKey
                bestSource = "plot"
                bestPetName = pName
            end
        end
    end

    if not bestSource then
        if _G.TwoSkiLoaded then
            WindUI:Notify({ Title = "2SKI", Content = "ไม่พบสัตว์เลี้ยงสำหรับขี่!" })
        end
        return false
    end

    -- Check if already riding the best pet
    local joint = hrp:FindFirstChild("PetMountJoint")
    local isRiding = (LocalPlayer:GetAttribute("IsRiding") == true) or (joint ~= nil)
    local cleanBest = bestPetName:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if isRiding and joint and joint.Part1 and joint.Part1.Parent and joint.Part1.Parent.Name:find(cleanBest, 1, true) then
        return true
    end

    -- Dismount first if riding something else
    if isRiding and Remote_PetDismount then
        Remote_PetDismount:FireServer()
        task.wait(0.3)
    end

    -- If best pet is on plot, pickup to backpack
    if bestSource == "plot" and bestPlotPetKey and Remote_PickupPet then
        Remote_PickupPet:FireServer(bestPlotPetKey)
        task.wait(0.3)
        if LocalPlayer:FindFirstChild("Backpack") then
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") and item:GetAttribute("PetKey") == bestPlotPetKey then
                    bestTool = item
                    break
                end
            end
        end
    end

    if bestTool then
        if bestTool.Parent ~= char then
            pcall(function() hum:UnequipTools() end)
            task.wait(0.08)
            hum:EquipTool(bestTool)
            task.wait(0.2)
        end
        if Remote_Mounting then
            Remote_Mounting:FireServer()
            task.wait(0.3)
        end
        if _G.TwoSkiLoaded then
            WindUI:Notify({ Title = "2SKI", Content = "ขี่สัตว์เลี้ยง " .. tostring(cleanBest) .. " (ความเร็ว " .. tostring(bestSpeed) .. ") เรียบร้อย!" })
        end
        return true
    end
    return false
end

-- State Management
local State = {
    -- Tab 1: Eggs & Hatching (All OFF by default)
    AutoFlyEggs = false,
    AutoPlaceEggs = false,
    PlaceEggTarget = {},
    PlaceEggRarityFilter = {},
    MinEggWeight = "0 KG+ (ไม่จำกัด)",
    PrioritizeHeaviestEgg = false,
    FlySpeed = 250,
    TargetEggs = {},
    RarityFilter = {},
    AutoHatch = false,
    AutoBreakBaskets = false,
    EggESP = false,
    ESPMode = "All / ทั้งหมด (แสดงทุกฟอง)",
    TargetRebirthEgg = false,

    -- Tab 2: Pet Controls & Riding
    AutoMountBest = false,
    RideFastSpeed = false,
    RideSpeedValue = 100,
    AutoPlaceBestPets = false,
    AutoCollectPets = false,
    TargetPet = "",
    PetCollectRadius = 25,
    PetActionDelay = 0.5,

    -- Tab 3: Silent Feeding
    AutoFeedPets = false,
    SelectedFood = "Grass",
    FeedTargetPet = "All / ทั้งหมด (ป้อนทุกตัวในแปลง)",
    FeedInterval = 1.0,
    FeedBatchAmount = 5,

    -- Tab 4: Shop & Plot Upgrades
    AutoBuyFood = false,
    AutoBuyGears = false,
    SelectedGear = "Royal Radar",
    AutoSellCollect = false,
    AutoUpgradeAll = false,
    AutoUpgradeLuck = false,
    AutoUpgradeNests = false,
    MuteScreenAlerts = true,

    -- Tab 5: Warp & Servers
    ServerHopTarget = "Lowest",

    -- Tab 6: Rebirth & Stats
    AutoRebirth = false,
    AutoClaimIndex = false,
    AutoClaimRewards = false,

    -- Tab 7: Player & Settings
    WalkSpeed = 16,
    JumpPower = 100,
    InfiniteJump = false,
    Noclip = false,
    ManualFly = false,
    ManualFlySpeed = 100,
    AntiAfk = false,
    CurrentTheme = "2SKI Cyber Cyan (ธีมหลักทางการ - ขาว ฟ้าเรืองแสง Electric Blue)",
    FloatingButtonVisible = true,
    AutoLoadConfig = false,
}

local Connections = {}
local UIControls = {}
local petSwapCooldown = {}
local originalCollisions = {}
local noclipCon = nil
local manualFlyBv = nil
local manualFlyBg = nil
local manualFlyCon = nil

local function setContainerNoclip(container, noclipState)
    if not container then return end
    pcall(function()
        for _, p in ipairs(container:GetDescendants()) do
            if p:IsA("BasePart") then
                local n = p.Name:lower()
                if not (n:find("floor") or n:find("baseplate") or n:find("ground")) then
                    if noclipState then
                        if p.CanCollide then
                            originalCollisions[p] = true
                            p.CanCollide = false
                        end
                    else
                        if originalCollisions[p] then
                            p.CanCollide = true
                        end
                    end
                end
            end
        end
    end)
end

local function updateNoclipConnection()
    if State.Noclip or State.ManualFly then
        if not noclipCon then
            noclipCon = RunService.Stepped:Connect(function()
                if not (State.Noclip or State.ManualFly) then
                    if noclipCon then noclipCon:Disconnect(); noclipCon = nil end
                    return
                end
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetChildren()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(Connections, noclipCon)
        end
    else
        if noclipCon then
            noclipCon:Disconnect()
            noclipCon = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local n = p.Name
                    if n == "HumanoidRootPart" or n == "UpperTorso" or n == "LowerTorso" or n == "Torso" then
                        p.CanCollide = true
                    else
                        p.CanCollide = false
                    end
                end
            end
        end
    end
end

local function updateManualFly()
    if State.ManualFly then
        local char, hrp, hum = getCharHrp()
        if not hrp or not hum then return end

        if not manualFlyBv or not manualFlyBv.Parent or manualFlyBv.Parent ~= hrp then
            local oldBv = hrp:FindFirstChild("TwoSkiManualFlyBV")
            if oldBv then oldBv:Destroy() end
            manualFlyBv = Instance.new("BodyVelocity")
            manualFlyBv.Name = "TwoSkiManualFlyBV"
            manualFlyBv.MaxForce = Vector3.new(2e6, 2e6, 2e6)
            manualFlyBv.P = 1e5
            manualFlyBv.Velocity = Vector3.zero
            manualFlyBv.Parent = hrp
        end

        if not manualFlyBg or not manualFlyBg.Parent or manualFlyBg.Parent ~= hrp then
            local oldBg = hrp:FindFirstChild("TwoSkiManualFlyBG")
            if oldBg then oldBg:Destroy() end
            manualFlyBg = Instance.new("BodyGyro")
            manualFlyBg.Name = "TwoSkiManualFlyBG"
            -- PURE YAW ONLY: Locking pitch/roll torque to 0 completely eliminates Humanoid upright spring vibration & twitching!
            manualFlyBg.MaxTorque = Vector3.new(0, 4e6, 0)
            manualFlyBg.P = 4000
            manualFlyBg.D = 400
            manualFlyBg.CFrame = hrp.CFrame
            manualFlyBg.Parent = hrp
        end

        hum.PlatformStand = true
        updateNoclipConnection()

        if not manualFlyCon then
            local flyCurrentVel = Vector3.zero
            manualFlyCon = RunService.RenderStepped:Connect(function(dt)
                if not State.ManualFly then
                    if manualFlyCon then manualFlyCon:Disconnect(); manualFlyCon = nil end
                    return
                end
                local c, h, hm = getCharHrp()
                if not h or not hm or hm.Health <= 0 then return end

                hm.PlatformStand = true

                local cam = workspace.CurrentCamera
                local camCF = cam and cam.CFrame or h.CFrame
                local speed = State.ManualFlySpeed or 100

                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    dir = dir + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    dir = dir - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    dir = dir - Vector3.new(0, 1, 0)
                end

                -- Mobile touch input support
                if dir.Magnitude == 0 and hm.MoveDirection.Magnitude > 0 then
                    local rel = camCF:VectorToObjectSpace(hm.MoveDirection)
                    dir = (camCF.LookVector * (-rel.Z) + camCF.RightVector * rel.X)
                end

                local targetVel = Vector3.zero
                if dir.Magnitude > 0.05 then
                    targetVel = dir.Unit * speed
                end

                -- Silky smooth responsive Lerp (Zero sudden jerk, instant stop)
                flyCurrentVel = flyCurrentVel:Lerp(targetVel, math.clamp(dt * 18, 0.15, 1.0))

                if manualFlyBv and manualFlyBv.Parent == h then
                    manualFlyBv.Velocity = flyCurrentVel
                end
                if manualFlyBg and manualFlyBg.Parent == h then
                    local look = camCF.LookVector
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude > 0.001 then
                        manualFlyBg.CFrame = CFrame.lookAt(h.Position, h.Position + flatLook.Unit)
                    end
                end
            end)
            table.insert(Connections, manualFlyCon)
        end
    else
        if manualFlyCon then
            manualFlyCon:Disconnect()
            manualFlyCon = nil
        end
        if manualFlyBv then
            pcall(function() manualFlyBv:Destroy() end)
            manualFlyBv = nil
        end
        if manualFlyBg then
            pcall(function() manualFlyBg:Destroy() end)
            manualFlyBg = nil
        end
        local _, hrp, hum = getCharHrp()
        if hum then
            hum.PlatformStand = false
        end
        if hrp then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end)
        end
        updateNoclipConnection()
    end
end

local function getFeedPetTargetList()
    local list = { "All / ทั้งหมด (ป้อนทุกตัวในแปลง)" }
    local found = {}

    local pr = getPetRenderer()
    if pr then
        pcall(function()
            for _, pet in pairs(pr.GetAll()) do
                if pet.OwnerUserId == LocalPlayer.UserId and pet.Model and pet.Model.Name then
                    local name = pet.Model.Name
                    if not found[name] then
                        found[name] = true
                        table.insert(list, name)
                    end
                end
            end
        end)
    end

    if GamePetsData then
        for pName in pairs(GamePetsData) do
            if not found[pName] then
                found[pName] = true
                table.insert(list, pName)
            end
        end
    end

    return list
end

local function isPetMatchingFeedTarget(pet)
    local target = State.FeedTargetPet
    if not target or target == "All / ทั้งหมด (ป้อนทุกตัวในแปลง)" or target == "All / ทั้งหมด" or target == "All" or target:find("ทั้งหมด", 1, true) then
        return true
    end
    local pName = pet.Model and pet.Model.Name or ""
    local cleanTarget = target:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if pName:lower():find(cleanTarget:lower(), 1, true) or cleanTarget:lower():find(pName:lower(), 1, true) then
        return true
    end
    if pet.PetKey and tostring(pet.PetKey) == target then
        return true
    end
    return false
end

_G.TwoSkiCleanup = function()
    _G.TwoSkiRunning = false
    _G.TwoSkiLoaded = false
    if manualFlyCon then pcall(function() manualFlyCon:Disconnect() end) end
    if manualFlyBv then pcall(function() manualFlyBv:Destroy() end) end
    if manualFlyBg then pcall(function() manualFlyBg:Destroy() end) end
    if noclipCon then pcall(function() noclipCon:Disconnect() end) end
    local _, hrp, hum = getCharHrp()
    if hum then hum.PlatformStand = false end
    for _, c in ipairs(Connections) do
        if typeof(c) == "RBXScriptConnection" then pcall(function() c:Disconnect() end) end
    end
    safeDestroyGui("TwoSki_EggESP")
    safeDestroyGui("TwoSki_RideAPet_Floating")
    safeDestroyGui("WindUI")
    if WindUI and WindUI.Window and WindUI.Window.Destroy then
        pcall(function() WindUI.Window:Destroy() end)
        WindUI.Window = nil
    end
end

-- Load WindUI Engine
local WindUILoadUrls = {
    "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://pastebin.com/raw/8hL69sK9"
}

local WindUI = nil
for _, url in ipairs(WindUILoadUrls) do
    local ok, res = pcall(function()
        local raw = game:HttpGet(url)
        if raw and #raw > 500 then
            raw = raw:gsub("https://raw%.githubusercontent%.com/Footagesus/Icons/refs/heads/main/", "https://cdn.jsdelivr.net/gh/Footagesus/Icons@main/")
            return loadstring(raw)()
        end
    end)
    if ok and res and type(res) == "table" then
        WindUI = res
        break
    end
end

if not WindUI then
    warn("[2SKI] Critical Error: Cannot load WindUI engine.")
    return
end

-- Register Custom Themes
local function regTheme(name, hexAcc, hexBg, hexDlg, hexBtn, hexPnl, hexElm)
    local cAcc = Color3.fromHex(hexAcc)
    WindUI:AddTheme({
        Name = name,
        Accent = cAcc,
        Dialog = Color3.fromHex(hexDlg),
        Outline = cAcc,
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = cAcc,
        Background = Color3.fromHex(hexBg),
        Button = Color3.fromHex(hexBtn),
        Icon = cAcc,
        Toggle = cAcc,
        Slider = cAcc,
        Checkbox = cAcc,
        PanelBackground = Color3.fromHex(hexPnl),
        ElementBackground = Color3.fromHex(hexElm)
    })
end

regTheme("Tiffany", "#00FFE0", "#10282C", "#163A40", "#24555E", "#17373D", "#1E464E")
regTheme("Sky",     "#00D0FF", "#102538", "#153652", "#255278", "#173550", "#1F4568")
regTheme("Emerald", "#00FF99", "#102B1E", "#153E2A", "#235B3E", "#173C2A", "#1F4E37")
regTheme("Purple",  "#C866FF", "#241538", "#331E50", "#4E2E78", "#321E4E", "#422766")
regTheme("Rose",    "#FF3377", "#2B121C", "#3E1827", "#5E243A", "#3D1A28", "#4F2235")
regTheme("Amber",   "#FFB700", "#2A200E", "#3E2D12", "#5C451D", "#3B2D14", "#4C3A1A")
regTheme("Blue",    "#3D8EFF", "#14223B", "#1C3054", "#2C497E", "#1C3054", "#253F6D")

-- Create Original 2SKI Window (Glassy Tiffany + macOS 3 Colored Dots + Responsive Mobile)
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
local winWidth = isMobile and math.clamp(math.floor(vp.X * 0.88), 360, 560) or 580
local winHeight = isMobile and math.clamp(math.floor(vp.Y * 0.82), 275, 430) or 460
local minW = isMobile and math.clamp(math.floor(vp.X * 0.68), 290, 440) or 480
local minH = isMobile and math.clamp(math.floor(vp.Y * 0.60), 220, 310) or 320

-- 2SKI Custom Official Logo (Cloud CDN Cached Asset)
local TwoSkiLogoAsset = nil
local function get2SkiLogoAsset()
    local getAsset = getcustomasset or getsynasset
    local fileName = "2ski_official_logo.png"
    if writefile and getAsset then
        local ok, asset = pcall(function()
            if not (isfile and isfile(fileName)) then
                local content = game:HttpGet("https://files.catbox.moe/jrwfti.png")
                if content and #content > 0 then
                    writefile(fileName, content)
                end
            end
            return getAsset(fileName)
        end)
        if ok and asset then return asset end
    end
    return nil
end
TwoSkiLogoAsset = get2SkiLogoAsset()

local Window = WindUI:CreateWindow({
    Title = "2SKI",
    SubTitle = "ขี่สัตว์เลี้ยง (Ride a Pet)",
    Folder = "2ski_ride_a_pet",
    Theme = "Sky",
    Transparent = false,
    SideBarWidth = isMobile and 140 or 195,
    HasOutline = true,
    Keybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(winWidth, winHeight),
    MinSize = Vector2.new(minW, minH),
    OpenButton = { Enabled = false, Draggable = false, OnlyMobile = false },
    User = { Enabled = true, Anonymous = false },
    Topbar = { Height = isMobile and 40 or 44, ButtonsType = "Mac" }
})
_G.TwoSkiWindow = Window

-- Window Display Order Fixer
local function fixWindUIOrder()
    pcall(function()
        local targets = {}
        if gethui then pcall(function() table.insert(targets, gethui()) end) end
        if CoreGui then
            pcall(function() table.insert(targets, CoreGui:FindFirstChild("RobloxGui")) end)
            table.insert(targets, CoreGui)
        end
        if LocalPlayer then table.insert(targets, LocalPlayer:FindFirstChild("PlayerGui")) end
        for _, p in ipairs(targets) do
            if p then
                for _, c in ipairs(p:GetChildren()) do
                    if c:IsA("ScreenGui") and (c.Name:find("WindUI") or c.Name == "WindUI") then
                        c.DisplayOrder = 99995
                    end
                end
            end
        end
    end)
end
fixWindUIOrder()

-- Palette Themes (Featuring Official 2SKI Cyber Cyan Palette)
local ThemePresets = {
    ["2SKI Cyber Cyan (ธีมหลักทางการ - ขาว ฟ้าเรืองแสง Electric Blue)"] = {
        WindTheme = "Sky",
        Hex = "#00BFFF",
        C1 = Color3.fromRGB(248, 251, 255), -- ขาวหลัก #F8FBFF
        C2 = Color3.fromRGB(125, 235, 255), -- ฟ้าอ่อน Cyan #7DEBFF
        C3 = Color3.fromRGB(0, 191, 255),   -- ฟ้าเรืองแสง #00BFFF
        C4 = Color3.fromRGB(0, 140, 255),   -- Electric Blue #008CFF
        Glow = Color3.fromRGB(0, 140, 255), -- แสง Glow #008CFF
        GlowTransparency = 0.55,
        Bg = Color3.fromRGB(0, 0, 0),       -- พื้นหลัง #000000
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(248, 251, 255)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(125, 235, 255)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 140, 255))
        })
    },
    ["Tiffany Pastel Mint (สีเขียวมิ้นท์พาสเทล)"] = { WindTheme = "Tiffany", Hex = "#00FFE0", C1 = Color3.fromRGB(0,255,224), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(80,230,210), Glow = Color3.fromRGB(0,255,224), GlowTransparency = 0.55 },
    ["Sky Blue Glow (ฟ้านีออนสว่าง)"]            = { WindTheme = "Sky",     Hex = "#00D0FF", C1 = Color3.fromRGB(0,208,255), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(100,225,255), Glow = Color3.fromRGB(0,208,255), GlowTransparency = 0.55 },
    ["Neon Emerald (เขียวมรกตนีออน)"]             = { WindTheme = "Emerald", Hex = "#00FF99", C1 = Color3.fromRGB(0,255,153), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(90,255,180), Glow = Color3.fromRGB(0,255,153), GlowTransparency = 0.55 },
    ["Cyber Violet (ม่วงไซเบอร์)"]                = { WindTheme = "Purple",  Hex = "#C866FF", C1 = Color3.fromRGB(200,102,255), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(220,160,255), Glow = Color3.fromRGB(200,102,255), GlowTransparency = 0.55 },
    ["Neon Rose (ชมพูกุหลาบไฟ)"]                = { WindTheme = "Rose",    Hex = "#FF3377", C1 = Color3.fromRGB(255,51,119), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(255,140,180), Glow = Color3.fromRGB(255,51,119), GlowTransparency = 0.55 },
    ["Golden Amber (ทองอำพันพรีเมียม)"]           = { WindTheme = "Amber",   Hex = "#FFB700", C1 = Color3.fromRGB(255,183,0), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(255,215,100), Glow = Color3.fromRGB(255,183,0), GlowTransparency = 0.55 },
    ["Electric Blue (น้ำเงินสดใส)"]               = { WindTheme = "Blue",    Hex = "#3D8EFF", C1 = Color3.fromRGB(61,142,255), C2 = Color3.fromRGB(255,255,255), C3 = Color3.fromRGB(140,190,255), Glow = Color3.fromRGB(61,142,255), GlowTransparency = 0.55 }
}

-- Floating Rotating Squircle Toggle Button (Multi-Layer Neon Light Engine)
local GuiParent = getSafeGuiContainer() or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 10))
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "TwoSki_RideAPet_Floating"
ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 999999
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.IgnoreGuiInset = true
ToggleGui.Parent = GuiParent

-- Root Movable Container (Ultra-Compact 38x38 px, perfectly sized for mobile & PC)
local FloatingContainer = Instance.new("Frame")
FloatingContainer.Name = "FloatingContainer"
FloatingContainer.Size = UDim2.fromOffset(38, 38)
FloatingContainer.Position = UDim2.new(0.02, 0, 0.22, 0)
FloatingContainer.BackgroundTransparency = 1
FloatingContainer.BorderSizePixel = 0
FloatingContainer.Active = true
FloatingContainer.ZIndex = 1000
FloatingContainer.Parent = ToggleGui

-- Layer 1: Outer Rotating Neon Aura (Intense bloom around the rotating comet head)
local GlowFrame = Instance.new("Frame")
GlowFrame.Name = "GlowHalo"
GlowFrame.Size = UDim2.new(1, 6, 1, 6)
GlowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
GlowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
GlowFrame.BackgroundTransparency = 1
GlowFrame.BorderSizePixel = 0
GlowFrame.ZIndex = 999
GlowFrame.Parent = FloatingContainer

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 13)
GlowCorner.Parent = GlowFrame

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Name = "GlowStroke"
GlowStroke.Thickness = 3.2
GlowStroke.Color = Color3.fromRGB(0, 220, 255)
GlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
GlowStroke.Parent = GlowFrame

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.12, Color3.fromRGB(125, 235, 255)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(0, 191, 255)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 70, 200)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
})
GlowGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.05),
    NumberSequenceKeypoint.new(0.15, 0.2),
    NumberSequenceKeypoint.new(0.32, 0.85),
    NumberSequenceKeypoint.new(0.45, 1.0),
    NumberSequenceKeypoint.new(1.0, 1.0)
})
GlowGradient.Parent = GlowStroke

-- Layer 2: Subtle Dark Cyber Track (Defines the squircle edge)
local TrackFrame = Instance.new("Frame")
TrackFrame.Name = "BaseTrack"
TrackFrame.Size = UDim2.new(1, 0, 1, 0)
TrackFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TrackFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TrackFrame.BackgroundTransparency = 1
TrackFrame.BorderSizePixel = 0
TrackFrame.ZIndex = 1000
TrackFrame.Parent = FloatingContainer

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 11)
TrackCorner.Parent = TrackFrame

local TrackStroke = Instance.new("UIStroke")
TrackStroke.Thickness = 1.6
TrackStroke.Color = Color3.fromRGB(15, 30, 55)
TrackStroke.Transparency = 0.4
TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TrackStroke.Parent = TrackFrame

-- Layer 3: Main Button & Hyper-Vivid Rotating Laser Comet Beam (วิ่งช้า ชัดเจน ไม่แสบตา)
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingSquircle"
FloatingButton.Size = UDim2.new(1, 0, 1, 0)
FloatingButton.Position = UDim2.new(0.5, 0, 0.5, 0)
FloatingButton.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingButton.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
FloatingButton.AutoButtonColor = false
FloatingButton.Text = ""
FloatingButton.BorderSizePixel = 0
FloatingButton.Active = true
FloatingButton.ClipsDescendants = false
FloatingButton.ZIndex = 1001
FloatingButton.Parent = FloatingContainer

local SquircleCorner = Instance.new("UICorner")
SquircleCorner.CornerRadius = UDim.new(0, 11)
SquircleCorner.Parent = FloatingButton

local BorderStroke = Instance.new("UIStroke")
BorderStroke.Name = "BorderStroke"
BorderStroke.Thickness = 2.4
BorderStroke.Color = Color3.fromRGB(255, 255, 255)
BorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BorderStroke.Parent = FloatingButton

local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),   -- หัวเลเซอร์ขาวสว่างจ้า (Neon Flare Tip)
    ColorSequenceKeypoint.new(0.10, Color3.fromRGB(135, 245, 255)),  -- ฟ้าอ่อนนีออน Cyan
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 191, 255)),    -- ฟ้าเรืองแสง Electric Blue
    ColorSequenceKeypoint.new(0.38, Color3.fromRGB(0, 80, 240)),     -- หางน้ำเงินเรืองแสง
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
})
-- High-Contrast Comet Transparency: 30% prominent laser comet + 70% dark track
BorderGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.0),    -- หัวแสง 100% ชัดตา
    NumberSequenceKeypoint.new(0.12, 0.0),   -- ลำแสงเต็มความเข้ม
    NumberSequenceKeypoint.new(0.28, 0.75),  -- หางแสงค่อยๆ ไล่จาง
    NumberSequenceKeypoint.new(0.38, 1.0),   -- ส่วนที่เหลือโปร่งใส 100% เผยแทร็กไซเบอร์เข้ม
    NumberSequenceKeypoint.new(0.92, 1.0),   -- คงความมืดไว้
    NumberSequenceKeypoint.new(1.0, 0.0)
})
BorderGradient.Parent = BorderStroke

-- Ultra-Smooth Cinematic Pace (42 deg/sec - หมุนช้า นุ่ม พริ้วตา เห็นไฟวิ่งรอบสี่เหลี่ยมโค้งชัดเจน 100%)
local rotSpeed = 42
local currentRot = 0
local rotConnection = RunService.RenderStepped:Connect(function(dt)
    if not _G.TwoSkiRunning or _G.TwoSkiActiveToken ~= myToken then return end
    if not State.FloatingButtonVisible or not ToggleGui or not ToggleGui.Enabled then return end
    currentRot = (currentRot + dt * rotSpeed) % 360
    if BorderGradient and BorderGradient.Parent then
        BorderGradient.Rotation = currentRot
    end
    if GlowGradient and GlowGradient.Parent then
        GlowGradient.Rotation = currentRot
    end
end)
table.insert(Connections, rotConnection)

local MintDot = Instance.new("Frame")
MintDot.Name = "MintIndicatorDot"
MintDot.Size = UDim2.fromOffset(7, 7)
MintDot.Position = UDim2.new(1, -9.5, 0, 3)
MintDot.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
MintDot.BorderSizePixel = 0
MintDot.ZIndex = 1003
MintDot.Parent = FloatingButton

local MintCorner = Instance.new("UICorner")
MintCorner.CornerRadius = UDim.new(1, 0)
MintCorner.Parent = MintDot

local MintStroke = Instance.new("UIStroke")
MintStroke.Thickness = 1
MintStroke.Color = Color3.fromRGB(0, 87, 255)
MintStroke.Parent = MintDot

local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoImage"
LogoImage.Size = UDim2.new(1, -6, 1, -6)
LogoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImage.BackgroundTransparency = 1
LogoImage.ScaleType = Enum.ScaleType.Fit
LogoImage.ZIndex = 1002
LogoImage.Image = TwoSkiLogoAsset or ""
LogoImage.Visible = (TwoSkiLogoAsset ~= nil and TwoSkiLogoAsset ~= "")
LogoImage.Parent = FloatingButton

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 10)
LogoCorner.Parent = LogoImage

local LogoText = Instance.new("TextLabel")
LogoText.Name = "LogoTypography"
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.RichText = true
LogoText.Font = Enum.Font.FredokaOne
LogoText.Text = '<font color="#FFFFFF">2</font><font color="#6DD9C8">SKI</font>'
LogoText.TextSize = 15
LogoText.TextXAlignment = Enum.TextXAlignment.Center
LogoText.TextYAlignment = Enum.TextYAlignment.Center
LogoText.ZIndex = 1002
LogoText.Visible = (TwoSkiLogoAsset == nil or TwoSkiLogoAsset == "")
LogoText.Parent = FloatingButton

local function applyThemePreset(presetName)
    local p = ThemePresets[presetName]
    if not p then return end
    pcall(function() if WindUI and WindUI.SetTheme then WindUI:SetTheme(p.WindTheme) end end)
    if BorderGradient then
        BorderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.18, p.C1 or Color3.fromRGB(125, 235, 255)),
            ColorSequenceKeypoint.new(0.42, p.C2 or Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(0.7, p.C3 or Color3.fromRGB(0, 100, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
        })
    end
    if GlowGradient then
        GlowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, p.C1 or Color3.fromRGB(125, 235, 255)),
            ColorSequenceKeypoint.new(0.6, p.C2 or Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
        })
    end
    if MintDot then MintDot.BackgroundColor3 = p.C3 or p.C1 end
    if LogoText then LogoText.Text = '<font color="#FFFFFF">2</font><font color="' .. p.Hex .. '">SKI</font>' end
end

-- Toggle Window Logic
local lastToggleTime = 0
local function toggleMainWindow()
    local now = tick()
    if now - lastToggleTime < 0.2 then return end
    lastToggleTime = now

    pcall(function()
        if not Window then return end
        fixWindUIOrder()
        if Window.Closed then
            if Window.UIElements and Window.UIElements.Main then
                Window.UIElements.Main.Visible = true
            end
            Window:Open()
        else
            Window:Close()
        end
    end)
end

-- Draggable & Tap Engine (Zero Glitch, Single-Trigger Window Toggle)
local isDragging = false
local hasMoved = false
local dragStartPos = nil
local startBtnPos = nil
local touchStartTime = 0
local activeDragInput = nil

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        hasMoved = false
        activeDragInput = input
        dragStartPos = input.Position
        touchStartTime = tick()
        startBtnPos = Vector2.new(FloatingContainer.AbsolutePosition.X, FloatingContainer.AbsolutePosition.Y)
    end
end)

local dragChangeCon = UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input == activeDragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        if delta.Magnitude > (isTouchDevice and 10 or 4) then
            hasMoved = true
        end
        if hasMoved then
            local cam = workspace.CurrentCamera
            local currentVp = cam and cam.ViewportSize or Vector2.new(1280, 720)
            local btnSize = FloatingContainer.AbsoluteSize
            local maxX = math.max(0, currentVp.X - btnSize.X)
            local maxY = math.max(0, currentVp.Y - btnSize.Y)
            local newX = math.clamp(startBtnPos.X + delta.X, 0, maxX)
            local newY = math.clamp(startBtnPos.Y + delta.Y, 0, maxY)
            FloatingContainer.Position = UDim2.fromOffset(newX, newY)
        end
    end
end)
table.insert(Connections, dragChangeCon)

local dragEndCon = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDragging and (activeDragInput == nil or input == activeDragInput) then
            isDragging = false
            activeDragInput = nil
            local dist = (input.Position - dragStartPos).Magnitude
            local duration = tick() - touchStartTime
            if not hasMoved and (dist < (isTouchDevice and 16 or 6) or duration < 0.35) then
                toggleMainWindow()
            end
        end
    end
end)
table.insert(Connections, dragEndCon)

local keybindCon = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        toggleMainWindow()
    end
end)
table.insert(Connections, keybindCon)

-- Config Manager
local CONFIG_FILE = "2SKI_RideAPet_Config.json"

local saveDebounce = false
local function saveConfig(silent)
    if not writefile then return false end
    local cleanState = {}
    for k, v in pairs(State) do
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then
            cleanState[k] = v
        elseif t == "table" then
            local cleanT = {}
            for subK, subV in pairs(v) do
                if type(subV) == "string" or type(subV) == "number" or type(subV) == "boolean" then
                    cleanT[subK] = subV
                end
            end
            cleanState[k] = cleanT
        end
    end

    local ok, encoded = pcall(function() return HttpService:JSONEncode(cleanState) end)
    if ok and encoded then
        local sOk = pcall(function() writefile(CONFIG_FILE, encoded) end)
        if sOk then
            if not silent and _G.TwoSkiLoaded and WindUI and WindUI.Notify then
                WindUI:Notify({ Title = "2SKI", Content = "บันทึกการตั้งค่าลงเครื่องเรียบร้อย!" })
            end
            return true
        end
    end
    if not silent and _G.TwoSkiLoaded and WindUI and WindUI.Notify then
        WindUI:Notify({ Title = "2SKI", Content = "บันทึกการตั้งค่าไม่สำเร็จ" })
    end
    return false
end

local function autoSaveConfig()
    if saveDebounce then return end
    saveDebounce = true
    task.delay(0.6, function()
        saveDebounce = false
        saveConfig(true)
    end)
end

local function syncLoadedStateToUI()
    pcall(function()
        for k, v in pairs(UIControls) do
            if v and v.Set and State[k] ~= nil then
                v:Set(State[k])
            elseif v and v.Select and State[k] ~= nil then
                v:Select(State[k])
            end
        end
    end)
end

local function loadConfig(silent)
    if readfile and isfile and isfile(CONFIG_FILE) then
        local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
        if ok and data then
            local okDecode, parsed = pcall(function() return HttpService:JSONDecode(data) end)
            if okDecode and type(parsed) == "table" then
                if silent and parsed.AutoLoadConfig ~= true then
                    return false
                end
                if parsed.AutoPlaceEgg ~= nil and parsed.AutoPlaceEggs == nil then
                    parsed.AutoPlaceEggs = parsed.AutoPlaceEgg
                end
                for k, v in pairs(parsed) do
                    if State[k] ~= nil then State[k] = v end
                end
                syncLoadedStateToUI()
                if not silent and _G.TwoSkiLoaded then
                    WindUI:Notify({ Title = "2SKI", Content = "โหลดการตั้งค่าสำเร็จ!" })
                end
                return true
            end
        end
    end
    if not silent and _G.TwoSkiLoaded then
        WindUI:Notify({ Title = "2SKI", Content = "ไม่พบไฟล์บันทึกการตั้งค่า" })
    end
    return false
end

-- Rebirth Pet & Egg Targeter Maps
local RebirthBestEggsMap = {
    ["Horse"] = { "Leaf Egg", "Stone Egg", "Easter Egg", "Cracked Egg", "Mushroom Egg", "Ice Egg" },
    ["Fox"] = { "Golden Egg", "Diamond Egg", "Crystal Egg", "Flaming Egg", "Asteroid Egg", "Dominus Egg", "Soul Egg", "Galaxy Egg", "Aurora Egg" },
    ["Unicorn"] = { "Aurora Egg", "Galaxy Egg", "Blackhole Egg", "Solaris Egg", "Cherub Egg" },
    ["Phoenix"] = { "Galaxy Egg", "Aurora Egg", "Blackhole Egg", "Solaris Egg", "Cherub Egg" },
    ["Kitsune"] = { "Solaris Egg", "Blackhole Egg", "Cherub Egg", "Galaxy Egg" },
    ["Dragon"] = { "Dragon Egg", "Solaris Egg", "Blackhole Egg", "Cherub Egg", "Galaxy Egg" }
}

local function getBestEggsForRebirthPet(petName)
    if not petName then return {} end
    return RebirthBestEggsMap[petName] or { "Solaris Egg", "Blackhole Egg", "Cherub Egg", "Galaxy Egg", "Aurora Egg" }
end

local function isEggGoodForRebirthPet(eggName, petName)
    local best = getBestEggsForRebirthPet(petName)
    local clean = string.lower(tostring(eggName):gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", ""))
    for _, b in ipairs(best) do
        local bClean = string.lower(b:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", ""))
        if clean == bClean or clean:find(bClean, 1, true) or bClean:find(clean, 1, true) then
            return true
        end
    end
    local score, rarity = getEggScore(eggName)
    if (petName == "Kitsune" or petName == "Dragon" or petName == "Phoenix") and (rarity == "Divine" or rarity == "Ethereal") then
        return true
    end
    return false
end

-- Rebirth Verification Logic (Strict Pet & Cash Check)
local function canDoRebirth()
    local sd = LocalPlayer:FindFirstChild("SavedData")
    if not sd then return false, "ไม่มีข้อมูล SavedData", nil, 0, false end

    local curRebirths = sd:FindFirstChild("Rebirths") and tonumber(sd.Rebirths.Value) or 0
    local nextIndex = curRebirths + 1

    local okGen, General = pcall(function() return require(ReplicatedStorage.GameData.General) end)
    local reqList = (okGen and General and General.RebirthRequirements) or {"Horse", "Fox", "Unicorn", "Phoenix", "Kitsune", "Dragon"}

    if nextIndex > #reqList then
        return false, "รีเบิร์ธตันแล้ว (สูงสุดระดับ " .. tostring(#reqList) .. ")", nil, 0, true
    end

    local reqPet = reqList[nextIndex]

    local okRb, Rebirths = pcall(function() return require(ReplicatedStorage.GameData.Rebirths) end)
    local cost = 0
    if okRb and Rebirths then
        if type(Rebirths.GetCost) == "function" then
            pcall(function() cost = Rebirths.GetCost(curRebirths) end)
        elseif Rebirths.RiggedCost and Rebirths.RiggedCost[nextIndex] then
            cost = Rebirths.RiggedCost[nextIndex]
        end
    end
    if not cost or cost == 0 then
        local defaultCosts = { [1] = 1000000, [2] = 500000000, [3] = 2500000000, [4] = 125000000000, [5] = 6250000000000, [6] = 1e15 }
        cost = defaultCosts[nextIndex] or 1000000
    end

    -- 1. Check OwnedPets string in SavedData
    local hasPet = false
    local ownedPets = sd:FindFirstChild("OwnedPets") and sd.OwnedPets.Value
    if ownedPets and reqPet then
        if string.find("," .. tostring(ownedPets) .. ",", "," .. reqPet .. ",") then
            hasPet = true
        end
    end

    -- 2. Check Backpack
    if not hasPet and reqPet and LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            local pName = item:GetAttribute("PetName") or item.Name
            if pName == reqPet or item.Name == reqPet then
                hasPet = true
                break
            end
        end
    end

    -- 3. Check Character
    if not hasPet and reqPet and LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            local pName = item:GetAttribute("PetName") or item.Name
            if pName == reqPet or item.Name == reqPet then
                hasPet = true
                break
            end
        end
    end

    -- 4. Check Placed Pets on plot
    if not hasPet and reqPet then
        pcall(function()
            local pr = getPetRenderer()
            if pr and pr.GetAll then
                for _, pet in pairs(pr.GetAll()) do
                    if pet.OwnerUserId == LocalPlayer.UserId then
                        local mName = pet.Model and pet.Model.Name
                        if mName == reqPet then
                            hasPet = true
                            break
                        end
                    end
                end
            end
        end)
    end

    local curCash = getPlayerCash()

    if not hasPet then
        return false, "ต้องการสัตว์: " .. tostring(reqPet) .. " (ยังไม่มีในตัว/ฟาร์ม)", reqPet, cost, false
    end

    if curCash < cost then
        return false, "เงินไม่พอรีเบิร์ธ (ต้องการ $" .. tostring(cost) .. ")", reqPet, cost, true
    end

    return true, "เงื่อนไขครบ พร้อมรีเบิร์ธ!", reqPet, cost, true
end

-- Egg Filter Matcher (100% User Target Priority & Type-Safe)
local function isEggMatching(egg)
    if not egg then return false end

    local candidateNames = {}
    if egg.Name and #egg.Name > 0 then
        table.insert(candidateNames, string.lower(egg.Name))
    end
    local attrEgg = egg:GetAttribute("Egg") or egg:GetAttribute("EggType") or egg:GetAttribute("Type")
    if attrEgg and typeof(attrEgg) == "string" and #attrEgg > 0 then
        table.insert(candidateNames, string.lower(attrEgg))
    end
    local pp = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
    if pp then
        if pp.ObjectText and #pp.ObjectText > 0 then
            table.insert(candidateNames, string.lower(pp.ObjectText))
        end
        if pp.ActionText and #pp.ActionText > 0 then
            table.insert(candidateNames, string.lower(pp.ActionText))
        end
    end

    local function isAllSelection(str)
        if not str then return false end
        local s = string.lower(tostring(str))
        return s:find("all", 1, true) ~= nil or s:find("ทั้งหมด", 1, true) ~= nil
    end

    -- 1. Min Egg Weight Filter (กิโลไข่ที่จะเก็บ) - Enforced First!
    local minKGStr = State.MinEggWeight or "0 KG+ (ไม่จำกัด)"
    if not isAllSelection(minKGStr) and not minKGStr:find("0 KG") then
        local targetMin = 0
        if minKGStr:find("240,000") or minKGStr:find("240000") then targetMin = 240000
        elseif minKGStr:find("100,000") or minKGStr:find("100000") then targetMin = 100000
        elseif minKGStr:find("50,000") or minKGStr:find("50000") then targetMin = 50000
        elseif minKGStr:find("10,000") or minKGStr:find("10000") then targetMin = 10000
        elseif minKGStr:find("1,500") or minKGStr:find("1500") then targetMin = 1500
        elseif minKGStr:find("100") then targetMin = 100
        elseif minKGStr:find("15") then targetMin = 15
        end

        if targetMin > 0 then
            local _, realW, shownKG = getActiveEggInfo(egg)
            local numShown = tonumber(tostring(shownKG):gsub("[^0-9.]", "")) or tonumber(realW) or 0
            if numShown < targetMin then
                return false
            end
        end
    end

    -- 2. Check User Explicit Target Selection (Always Prioritized when specified)
    local targets = normalizeMultiSelection(State.TargetEggs)
    local hasSpecificTargets = false
    if #targets > 0 then
        for _, t in ipairs(targets) do
            if not isAllSelection(t) and #t:gsub("%s+", "") > 0 then
                hasSpecificTargets = true
                break
            end
        end
    end

    if hasSpecificTargets then
        -- User explicitly chose specific eggs in dropdown: MUST match user selection!
        local typeMatch = false
        for _, t in ipairs(targets) do
            if isAllSelection(t) then
                typeMatch = true
                break
            end
            local cleanT = string.lower(t:gsub("%s*%b[]", ""):gsub("%s*%b()", ""):gsub("egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
            for _, cName in ipairs(candidateNames) do
                local cleanC = cName:gsub("egg", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                if cName == cleanT or cleanC == cleanT or cName:find(cleanT, 1, true) or cleanT:find(cleanC, 1, true) then
                    typeMatch = true
                    break
                end
            end
            if typeMatch then break end
        end
        if not typeMatch then return false end
    elseif State.TargetRebirthEgg then
        -- Only use Rebirth Hunter when user has NOT chosen specific target eggs!
        local canRb, msg, reqPet, cost, hasPet = canDoRebirth()
        if reqPet and not hasPet then
            local isRebirthTarget = false
            for _, cName in ipairs(candidateNames) do
                if isEggGoodForRebirthPet(cName, reqPet) then
                    isRebirthTarget = true
                    break
                end
            end
            if not isRebirthTarget then
                return false
            end
        end
    end

    -- 3. Rarity Filter
    local rarities = normalizeMultiSelection(State.RarityFilter)
    local allRarities = (#rarities == 0)
    for _, r in ipairs(rarities or {}) do
        if isAllSelection(r) or r == "All Rarities" then
            allRarities = true
            break
        end
    end
    if not allRarities then
        local eggRarity = egg:GetAttribute("Rarity")
        if not eggRarity then
            for _, cName in ipairs(candidateNames) do
                local _, r = getEggScore(cName)
                if r and r ~= "Common" then
                    eggRarity = r
                    break
                elseif r and not eggRarity then
                    eggRarity = r
                end
            end
        end
        if eggRarity then
            local rarityMatched = false
            for _, r in ipairs(rarities or {}) do
                if string.lower(eggRarity) == string.lower(r) then
                    rarityMatched = true
                    break
                end
            end
            if not rarityMatched then return false end
        end
    end

    return true
end

local function isEggEspMatching(egg)
    if not egg then return false end
    local mode = State.ESPMode or "All / ทั้งหมด (แสดงทุกฟอง)"
    if mode == "All / ทั้งหมด (แสดงทุกฟอง)" or mode:find("All") or mode:find("ทั้งหมด") then
        return true
    elseif mode:find("Match") or mode:find("ตามที่เลือก") then
        return isEggMatching(egg)
    elseif mode:find("Rebirth") then
        local canRb, msg, reqPet, cost, hasPet = canDoRebirth()
        if reqPet and not hasPet then
            return isEggGoodForRebirthPet(egg.Name, reqPet)
        end
        return false
    elseif mode:find("Rare+") then
        local _, rarity = getEggScore(egg.Name)
        return rarity ~= "Common" and rarity ~= "Uncommon"
    elseif mode:find("Legendary+") then
        local _, rarity = getEggScore(egg.Name)
        return rarity == "Legendary" or rarity == "Mythic" or rarity == "Divine" or rarity == "Ethereal"
    end
    return true
end

local ESPFolder = getSafeGuiContainer():FindFirstChild("TwoSki_EggESP")
if not ESPFolder then
    pcall(function()
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "TwoSki_EggESP"
        ESPFolder.Parent = getSafeGuiContainer()
    end)
end

local activeESPBoxes = {}
local RarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Uncommon = Color3.fromRGB(80, 220, 100),
    Rare = Color3.fromRGB(50, 150, 255),
    Epic = Color3.fromRGB(180, 70, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 60, 60),
    Divine = Color3.fromRGB(0, 240, 255),
    Ethereal = Color3.fromRGB(255, 105, 180)
}

local function clearEggESP()
    for egg, esp in pairs(activeESPBoxes) do
        pcall(function()
            if esp.BB then esp.BB:Destroy() end
            if esp.HL then esp.HL:Destroy() end
        end)
    end
    table.clear(activeESPBoxes)
    if ESPFolder then
        pcall(function() ESPFolder:ClearAllChildren() end)
    end
end

local function updateEggESP()
    if not State.EggESP then
        clearEggESP()
        return
    end

    local renderedFolder = workspace:FindFirstChild("RenderedEggs")
    local _, hrp, _ = getCharHrp()
    local myPos = hrp and hrp.Position or Vector3.zero

    local aliveEggs = {}
    if renderedFolder then
        for _, egg in ipairs(renderedFolder:GetChildren()) do
            if isEggEspMatching(egg) then
                local part = egg:FindFirstChildWhichIsA("BasePart")
                if part then
                    aliveEggs[egg] = true
                    if not activeESPBoxes[egg] then
                        local score, rarity = getEggScore(egg.Name)
                        local color = RarityColors[rarity] or Color3.fromRGB(0, 255, 224)

                        -- BillboardGui
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "EggESP_" .. egg.Name
                        bb.Adornee = part
                        bb.Size = UDim2.fromOffset(130, 42)
                        bb.StudsOffset = Vector3.new(0, 2.2, 0)
                        bb.AlwaysOnTop = true
                        bb.MaxDistance = 10000
                        bb.Parent = ESPFolder

                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Size = UDim2.new(1, 0, 0, 18)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextSize = 13
                        nameLabel.TextColor3 = color
                        nameLabel.TextStrokeTransparency = 0.2
                        nameLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 10)
                        local _, realW, shownKG = getActiveEggInfo(egg)
                        local kgText = formatKG(shownKG)
                        local isRbTarget = false
                        if State.TargetRebirthEgg then
                            local _, _, reqPet, _, hasPet = canDoRebirth()
                            if reqPet and not hasPet and isEggGoodForRebirthPet(egg.Name, reqPet) then
                                isRbTarget = true
                            end
                        end
                        if isRbTarget then
                            nameLabel.Text = string.format("⭐ [REBIRTH] %s [%s] | %s", egg.Name, rarity, kgText)
                            nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                        else
                            nameLabel.Text = string.format("%s [%s] | %s", egg.Name, rarity, kgText)
                        end
                        nameLabel.Parent = bb

                        local distLabel = Instance.new("TextLabel")
                        distLabel.Size = UDim2.new(1, 0, 0, 16)
                        distLabel.Position = UDim2.new(0, 0, 0, 18)
                        distLabel.BackgroundTransparency = 1
                        distLabel.Font = Enum.Font.GothamMedium
                        distLabel.TextSize = 11
                        distLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
                        distLabel.TextStrokeTransparency = 0.3
                        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        distLabel.Text = "0m"
                        distLabel.Parent = bb

                        -- Optional Highlight
                        local hl = Instance.new("Highlight")
                        hl.Name = "EggHL"
                        hl.Adornee = egg
                        hl.FillColor = isRbTarget and Color3.fromRGB(255, 215, 0) or color
                        hl.FillTransparency = isRbTarget and 0.45 or 0.65
                        hl.OutlineColor = isRbTarget and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = isRbTarget and 0.0 or 0.2
                        hl.Parent = ESPFolder

                        activeESPBoxes[egg] = { BB = bb, HL = hl, Dist = distLabel, Part = part }
                    else
                        local d = math.floor((part.Position - myPos).Magnitude)
                        activeESPBoxes[egg].Dist.Text = tostring(d) .. " Studs"
                    end
                end
            end
        end
    end

    -- Clean stale ESPs
    for egg, esp in pairs(activeESPBoxes) do
        if not aliveEggs[egg] or not egg.Parent then
            pcall(function()
                if esp.BB then esp.BB:Destroy() end
                if esp.HL then esp.HL:Destroy() end
            end)
            activeESPBoxes[egg] = nil
        end
    end
end

task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if State.EggESP then
            updateEggESP()
            task.wait(0.35) -- ~3 FPS: perfectly smooth for distance text, zero FPS drop
        else
            task.wait(1.2) -- completely idle when disabled
        end
    end
end)

-- TAB 1: ไข่ & ฟักไข่
-- Auto-Save Config Wrapper for all Tabs (Debounced, 100% Automatic on any Toggle/Slider/Dropdown change)
local function wrapTabWithAutoSave(tab)
    local oldToggle = tab.Toggle
    if oldToggle then
        tab.Toggle = function(self, opt)
            local origCb = opt.Callback
            opt.Callback = function(val)
                if origCb then origCb(val) end
                if autoSaveConfig then autoSaveConfig() end
            end
            return oldToggle(self, opt)
        end
    end
    local oldSlider = tab.Slider
    if oldSlider then
        tab.Slider = function(self, opt)
            local origCb = opt.Callback
            opt.Callback = function(val)
                if origCb then origCb(val) end
                if autoSaveConfig then autoSaveConfig() end
            end
            return oldSlider(self, opt)
        end
    end
    local oldDropdown = tab.Dropdown
    if oldDropdown then
        tab.Dropdown = function(self, opt)
            if opt.Multi and opt.AllowNone == nil then
                opt.AllowNone = true
            end
            local origCb = opt.Callback
            opt.Callback = function(val)
                if origCb then origCb(val) end
                if autoSaveConfig then autoSaveConfig() end
            end
            return oldDropdown(self, opt)
        end
    end
    return tab
end

local origWindowTab = Window.Tab
Window.Tab = function(self, opt)
    local t = origWindowTab(self, opt)
    return wrapTabWithAutoSave(t)
end

local TabEgg = Window:Tab({ Title = "ไข่ & ฟักไข่", Icon = "egg" })

TabEgg:Section({ Title = "การบินเก็บไข่ในแมพ (Egg Flight & Auto Pick)" })

UIControls.AutoFlyEggs = TabEgg:Toggle({
    Title = "บินเก็บไข่แล้ววางรัง (Fly & Nest Eggs)",
    Value = State.AutoFlyEggs,
    Callback = function(val)
        State.AutoFlyEggs = val
        if not val then
            releaseFlightHold()
            State.Noclip = false
            updateNoclipConnection()
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เริ่มบินเก็บไข่และนำมาวางรัง!" or "หยุดระบบบินเก็บไข่" }) end
    end
})

UIControls.TargetEggs = TabEgg:Dropdown({
    Title = "เลือกชนิดไข่ในเซิร์ฟ (Server Eggs Multi-Select)",
    Values = getServerEggsList(),
    Value = State.TargetEggs,
    Multi = true,
    AllowNone = true,
    Callback = function(val)
        State.TargetEggs = type(val) == "table" and val or {val}
    end
})

UIControls.RarityFilter = TabEgg:Dropdown({
    Title = "กรองตามระดับความหายาก (Egg Rarity Filter)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Ethereal"},
    Value = State.RarityFilter,
    Multi = true,
    AllowNone = true,
    Callback = function(val)
        State.RarityFilter = type(val) == "table" and val or {val}
    end
})

UIControls.MinEggWeight = TabEgg:Dropdown({
    Title = "กรองกิโลไข่ขั้นต่ำที่จะเก็บ (Min Egg KG)",
    Values = {
        "0 KG+ (ไม่จำกัด)",
        "15 KG+ (ทั่วไป)",
        "100 KG+",
        "1,500 KG+ (ปานกลาง)",
        "10,000 KG+",
        "50,000 KG+",
        "100,000 KG+",
        "240,000 KG+ (สูงสุด Max KG)"
    },
    Value = State.MinEggWeight,
    Callback = function(val)
        State.MinEggWeight = val
    end
})

UIControls.PrioritizeHeaviestEgg = TabEgg:Toggle({
    Title = "บินเก็บไข่กิโลมากสุดก่อน (Prioritize Heaviest)",
    Value = State.PrioritizeHeaviestEgg,
    Callback = function(val)
        State.PrioritizeHeaviestEgg = val
    end
})

TabEgg:Button({
    Title = "รีเฟรชรายชื่อไข่ในเซิร์ฟ (Refresh Server Eggs)",
    Callback = function()
        local list = getServerEggsList()
        if UIControls.TargetEggs then
            if UIControls.TargetEggs.Refresh then pcall(function() UIControls.TargetEggs:Refresh(list) end)
            elseif UIControls.TargetEggs.SetValues then pcall(function() UIControls.TargetEggs:SetValues(list) end) end
        end
        if UIControls.PlaceEggTarget then
            if UIControls.PlaceEggTarget.Refresh then pcall(function() UIControls.PlaceEggTarget:Refresh(list) end)
            elseif UIControls.PlaceEggTarget.SetValues then pcall(function() UIControls.PlaceEggTarget:SetValues(list) end) end
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "รีเฟรชรายชื่อไข่สำเร็จ (" .. tostring(#list - 1) .. " ชนิดในเซิร์ฟ)" }) end
    end
})

UIControls.FlySpeed = TabEgg:Slider({
    Title = "ความเร็วในการบิน (Fly Speed)",
    Step = 10,
    Value = { Min = 50, Max = 350, Default = 250 },
    Callback = function(val) State.FlySpeed = val end
})

TabEgg:Section({ Title = "ระบบวางไข่ & ฟักไข่ (Auto Place Eggs & Hatching)" })

UIControls.AutoPlaceEggs = TabEgg:Toggle({
    Title = "วางไข่อัตโนมัติ (วางจนเต็มแปลง / NoNest)",
    Value = State.AutoPlaceEggs,
    Callback = function(val)
        State.AutoPlaceEggs = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดระบบวางไข่ลงแปลงอัตโนมัติ (วางจนเต็มแปลง)!" or "ปิดระบบวางไข่อัตโนมัติ" }) end
    end
})

UIControls.PlaceEggTarget = TabEgg:Dropdown({
    Title = "เลือกชนิดไข่ที่จะวางลงแปลง (Select Eggs to Place)",
    Values = getServerEggsList(),
    Value = State.PlaceEggTarget,
    Multi = true,
    AllowNone = true,
    Callback = function(val)
        State.PlaceEggTarget = type(val) == "table" and val or {val}
    end
})

UIControls.PlaceEggRarityFilter = TabEgg:Dropdown({
    Title = "เลือกระดับความหายากในการวางไข่ (Place Egg Rarity Filter)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Ethereal"},
    Value = State.PlaceEggRarityFilter,
    Multi = true,
    AllowNone = true,
    Callback = function(val)
        State.PlaceEggRarityFilter = type(val) == "table" and val or {val}
    end
})

TabEgg:Button({
    Title = "วางไข่ทั้งหมดลงแปลงทันที (วางจนเต็มแปลง / NoNest)",
    Callback = function()
        placeAllHeldEggsNow()
    end
})

UIControls.AutoHatch = TabEgg:Toggle({
    Title = "ฟักไข่อัตโนมัติ (Auto Hatch Eggs)",
    Value = State.AutoHatch,
    Callback = function(val)
        State.AutoHatch = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดฟักไข่อัตโนมัติ" or "ปิดฟักไข่" }) end
    end
})

UIControls.AutoBreakBaskets = TabEgg:Toggle({
    Title = "ทุบตะกร้าไข่อัตโนมัติ (Auto Basket Drop)",
    Value = State.AutoBreakBaskets,
    Callback = function(val) State.AutoBreakBaskets = val end
})

-- TAB 2: ระบบสัตว์เลี้ยง (Pets & Fast Riding)
local TabPet = Window:Tab({ Title = "ระบบสัตว์เลี้ยง", Icon = "footprints" })
TabPet:Section({ Title = "ระบบขี่สัตว์เลี้ยงวิ่งเร็ว (Fast Pet Riding)" })

UIControls.RideFastSpeed = TabPet:Toggle({
    Title = "ขี่สัตว์วิ่งเร็วอัตโนมัติ (Fast Pet Riding)",
    Value = State.RideFastSpeed,
    Callback = function(val)
        State.RideFastSpeed = val
        local _, _, hum = getCharHrp()
        if hum then
            hum.WalkSpeed = val and (State.RideSpeedValue or 100) or 20
        end
        if _G.TwoSkiLoaded then
            WindUI:Notify({ Title = "2SKI", Content = val and ("เปิดระบบขี่สัตว์วิ่งเร็ว (ความเร็ว: " .. tostring(State.RideSpeedValue or 100) .. ")") or "ปิดระบบขี่สัตว์วิ่งเร็ว" })
        end
    end
})

UIControls.RideSpeedValue = TabPet:Slider({
    Title = "ความเร็วขี่สัตว์ (Ride Speed)",
    Step = 5,
    Value = { Min = 20, Max = 300, Default = State.RideSpeedValue },
    Callback = function(val)
        State.RideSpeedValue = val
        if State.RideFastSpeed then
            local _, _, hum = getCharHrp()
            if hum then hum.WalkSpeed = val end
        end
    end
})

TabPet:Section({ Title = "ควบคุมสัตว์เลี้ยง (Pet Controls)" })

UIControls.AutoMountBest = TabPet:Toggle({
    Title = "ขี่สัตว์เลี้ยงตัวที่ดีที่สุดอัตโนมัติ (Auto Best Mount)",
    Value = State.AutoMountBest,
    Callback = function(val)
        State.AutoMountBest = val
        if val then
            task.spawn(mountBestPetNow)
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดระบบขี่สัตว์เลี้ยงที่ดีที่สุด" or "ปิดระบบขี่สัตว์เลี้ยง" }) end
    end
})

TabPet:Button({
    Title = "ขี่สัตว์เลี้ยงตัวที่ดีที่สุดทันที (Mount Best Pet Now)",
    Callback = function()
        mountBestPetNow()
    end
})

UIControls.AutoPlaceBestPets = TabPet:Toggle({
    Title = "วางสัตว์ที่ดีที่สุด (Auto Place Best Pets)",
    Value = State.AutoPlaceBestPets,
    Callback = function(val)
        State.AutoPlaceBestPets = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดวางสัตว์ที่ดีที่สุด" or "ปิดวางสัตว์ที่ดีที่สุด" }) end
    end
})

UIControls.AutoCollectPets = TabPet:Toggle({
    Title = "เก็บสัตว์เลี้ยงทั้งหมดในฐานอัตโนมัติ (Auto Collect Base Pets)",
    Value = State.AutoCollectPets,
    Callback = function(val)
        State.AutoCollectPets = val
        if val then
            task.spawn(function() collectAllPlotPetsNow(true) end)
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดระบบเก็บสัตว์เลี้ยงในฐานอัตโนมัติ" or "ปิดระบบเก็บสัตว์เลี้ยง" }) end
    end
})

TabPet:Button({
    Title = "เก็บสัตว์เลี้ยงทั้งหมดในฐานทันที (Collect All Plot Pets Now)",
    Callback = function()
        collectAllPlotPetsNow(false)
    end
})

UIControls.TargetPet = TabPet:Dropdown({
    Title = "เลือกชนิดสัตว์เลี้ยง (Target Pet Filter)",
    Values = {"Unicorn (Divine)", "TRex (Divine)", "Phoenix (Divine)", "Dragon (Ethereal)", "Kitsune (Ethereal)", "Fox (Mythic)", "Giraffe (Mythic)"},
    Value = State.TargetPet,
    Callback = function(val) State.TargetPet = val end
})

UIControls.PetCollectRadius = TabPet:Slider({
    Title = "รัศมีตรวจจับสัตว์เลี้ยง (Studs)",
    Step = 1,
    Value = { Min = 5, Max = 100, Default = State.PetCollectRadius },
    Callback = function(val) State.PetCollectRadius = val end
})

UIControls.PetActionDelay = TabPet:Slider({
    Title = "ความเร็วในการทำคำสั่ง (วินาที)",
    Step = 0.1,
    Value = { Min = 0.1, Max = 5.0, Default = State.PetActionDelay },
    Callback = function(val) State.PetActionDelay = val end
})

-- TAB 3: อาหาร & ป้อนสัตว์ (Silent Feeding)
local TabFood = Window:Tab({ Title = "อาหาร & ป้อนสัตว์", Icon = "drumstick" })
TabFood:Section({ Title = "ระบบให้อาหารสัตว์เลี้ยง (Silent Feeding)" })

UIControls.AutoFeedPets = TabFood:Toggle({
    Title = "ให้อาหารสัตว์เลี้ยงอัตโนมัติ (Silent Auto Feed)",
    Value = State.AutoFeedPets,
    Callback = function(val)
        State.AutoFeedPets = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เริ่มให้อาหารสัตว์เลี้ยงเงียบๆ" or "หยุดให้อาหารสัตว์" }) end
    end
})

UIControls.FeedTargetPet = TabFood:Dropdown({
    Title = "เลือกสัตว์เลี้ยงที่จะป้อนอาหาร (Target Pet)",
    Values = getFeedPetTargetList(),
    Value = State.FeedTargetPet,
    Callback = function(val) State.FeedTargetPet = val end
})

TabFood:Button({
    Title = "รีเฟรชรายชื่อสัตว์ในแปลง (Refresh Pet List)",
    Callback = function()
        if UIControls.FeedTargetPet then
            if UIControls.FeedTargetPet.Refresh then pcall(function() UIControls.FeedTargetPet:Refresh(list) end)
            elseif UIControls.FeedTargetPet.SetValues then pcall(function() UIControls.FeedTargetPet:SetValues(list) end) end
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "รีเฟรชรายชื่อสัตว์เลี้ยงเรียบร้อย (" .. tostring(#list) .. " ตัวเลือก)" }) end
    end
})

UIControls.SelectedFood = TabFood:Dropdown({
    Title = "เลือกอาหารที่ต้องการป้อน",
    Values = {"Grass", "Bone", "Meat", "Magic Apple", "Dragonfruit"},
    Value = State.SelectedFood,
    Callback = function(val) State.SelectedFood = val end
})

UIControls.FeedInterval = TabFood:Slider({
    Title = "ดีเลย์การป้อนอาหาร (วินาที)",
    Step = 0.2,
    Value = { Min = 0.4, Max = 5.0, Default = State.FeedInterval },
    Callback = function(val) State.FeedInterval = val end
})

UIControls.FeedBatchAmount = TabFood:Slider({
    Title = "จำนวนคำสั่งป้อนต่อรอบ (Batch Amount)",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = State.FeedBatchAmount },
    Callback = function(val) State.FeedBatchAmount = val end
})

TabFood:Button({
    Title = "กดให้อาหารสัตว์ตามที่เลือกทันที (Feed Selected Now)",
    Callback = function()
        local PetRenderer = getPetRenderer()
        local count = 0
        local foodName = State.SelectedFood
        local char, _, hum = getCharHrp()
        local foodTool = (char and char:FindFirstChild(foodName)) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(foodName))
        if foodTool and hum then hum:EquipTool(foodTool) task.wait(0.15) end

        for _, pet in pairs(PetRenderer.GetAll()) do
            if pet.OwnerUserId == LocalPlayer.UserId and pet.PetKey and Remote_FeedPet and isPetMatchingFeedTarget(pet) then
                pcall(function() Remote_FeedPet:FireServer(pet.PetKey, foodName) end)
                count = count + 1
            end
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ป้อนอาหารสัตว์เลี้ยง (" .. tostring(State.FeedTargetPet) .. ") สำเร็จ " .. tostring(count) .. " ตัว!" }) end
    end
})

-- TAB 4: ร้านค้า & แปลง
local TabShop = Window:Tab({ Title = "ร้านค้า & แปลง", Icon = "shopping-cart" })
TabShop:Section({ Title = "ระบบซื้อและจัดเก็บ (Purchases & Plot)" })

UIControls.AutoBuyFood = TabShop:Toggle({
    Title = "ซื้อ Food ออโต้",
    Value = State.AutoBuyFood,
    Callback = function(val)
        State.AutoBuyFood = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ซื้อ Food ออโต้: " .. tostring(val) }) end
    end
})

UIControls.AutoBuyGears = TabShop:Toggle({
    Title = "ซื้อ Gears ออโต้",
    Value = State.AutoBuyGears,
    Callback = function(val)
        State.AutoBuyGears = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ซื้อ Gears ออโต้: " .. tostring(val) }) end
    end
})

UIControls.SelectedGear = TabShop:Dropdown({
    Title = "เลือกชนิด Gears",
    Values = {"Advanced Radar", "Jewel Radar", "Royal Radar", "Magic Radar", "Angelic Radar", "Eternal Radar"},
    Value = State.SelectedGear,
    Callback = function(val) State.SelectedGear = val end
})

UIControls.AutoSellCollect = TabShop:Toggle({
    Title = "Sell & Collect ออโต้",
    Value = State.AutoSellCollect,
    Callback = function(val)
        State.AutoSellCollect = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "Sell & Collect ออโต้: " .. tostring(val) }) end
    end
})

TabShop:Section({ Title = "ระบบอัพเกรดอัตโนมัติเมื่อเงินถึง (Instant Upgrades)" })

UIControls.AutoUpgradeAll = TabShop:Toggle({
    Title = "อัปเกรดทุกอย่างอัตโนมัติ (Auto Upgrade All)",
    Value = State.AutoUpgradeAll,
    Callback = function(val)
        State.AutoUpgradeAll = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดระบบอัปเกรดทุกอย่างเมื่อเงินถึง" or "ปิดระบบอัปเกรดทุกอย่าง" }) end
    end
})

UIControls.AutoUpgradeLuck = TabShop:Toggle({
    Title = "อัปเกรด Hatch Luck อัตโนมัติ (Upgrade Luck)",
    Value = State.AutoUpgradeLuck,
    Callback = function(val)
        State.AutoUpgradeLuck = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดอัปเกรด Hatch Luck อัตโนมัติ" or "ปิดอัปเกรด Hatch Luck" }) end
    end
})

UIControls.AutoUpgradeNests = TabShop:Toggle({
    Title = "ปลดล็อกรังวางไข่อัตโนมัติ (Auto Upgrade Nests)",
    Value = State.AutoUpgradeNests,
    Callback = function(val)
        State.AutoUpgradeNests = val
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = val and "เปิดปลดล็อกรังวางไข่อัตโนมัติ" or "ปิดปลดล็อกรังวางไข่" }) end
    end
})

TabShop:Section({ Title = "ปุ่มกดสั่งการทันที (Quick Actions)" })

TabShop:Button({
    Title = "อัปเกรด Hatch Luck ทันที (Force Luck Max)",
    Callback = function()
        local canAfford, cost, count = canAffordHatchLuck()
        if canAfford and Remote_PlotUpgrades then
            Remote_PlotUpgrades:FireServer("Max")
            if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ส่งคำสั่งอัปเกรด Hatch Luck Max เรียบร้อย!" }) end
        else
            if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "เงินไม่พอสำหรับการอัปเกรด Hatch Luck" }) end
        end
    end
})

TabShop:Button({
    Title = "ปลดล็อกรังวางไข่ถัดไป (Force Unlock Next Nest)",
    Callback = function()
        local currentCash = getPlayerCash()
        local myPlot = getMyPlot()
        if myPlot and myPlot:FindFirstChild("Nests") and Remote_PlotNests then
            for i = 1, 5 do
                local n = myPlot.Nests:FindFirstChild(tostring(i))
                if n and n:GetAttribute("Unlocked") ~= true then
                    local price = NestPrices[i] or 0
                    if currentCash >= price and price > 0 then
                        Remote_PlotNests:FireServer(i)
                        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ส่งคำสั่งปลดล็อกรัง #" .. tostring(i) }) end
                    else
                        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "เงินไม่พอปลดล็อกรัง #" .. tostring(i) .. " (ต้องการ $" .. tostring(price) .. ")" }) end
                    end
                    break
                end
            end
        end
    end
})

TabShop:Button({
    Title = "รับของขวัญกลุ่ม & อีเวนท์ (Claim Rewards)",
    Callback = function()
        if Remote_ClaimGroupReward then pcall(function() Remote_ClaimGroupReward:FireServer() end) end
        if Remote_ClaimEventReward then pcall(function() Remote_ClaimEventReward:FireServer() end) end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "เคลมรางวัลกลุ่มและอีเวนท์เรียบร้อย!" }) end
    end
})

local CachedServers = {}

local function queueScriptOnTeleport()
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/MxdLL/2SKI/main/2ski_ride_a_pet_protected.lua?t=" .. tick()))()')
        end)
    end
end

local function fetchServerList()
    CachedServers = {}
    local labels = {}
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
    
    local body = nil
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        local ok, res = pcall(function()
            return req({
                Url = url,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "Roblox/WinInet",
                    ["Accept"] = "application/json"
                }
            })
        end)
        if ok and res and (res.StatusCode == 200 or res.Status == 200) then
            body = res.Body
        end
    end
    if not body then
        local ok, b = pcall(function() return game:HttpGet(url) end)
        if ok and b and not b:find('"errors"') then body = b end
    end

    if body then
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if ok and data and data.data then
            for _, s in ipairs(data.data) do
                if s.id and s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 20) and (s.playing or 0) > 0 then
                    local pingStr = s.ping and (tostring(s.ping) .. "ms") or "N/A"
                    local label = string.format("ผู้เล่น: %d/%d (Ping: %s) [%s]", s.playing, s.maxPlayers, pingStr, s.id:sub(1, 8))
                    table.insert(CachedServers, {
                        id = s.id,
                        playing = s.playing or 0,
                        maxPlayers = s.maxPlayers or 20,
                        ping = tonumber(s.ping) or 999,
                        label = label
                    })
                    table.insert(labels, label)
                end
            end
        end
    end

    if #labels == 0 then
        table.insert(labels, "สุ่มเซิร์ฟเวอร์อัตโนมัติ (Roblox Hop)")
    end
    return labels
end

local function queueScriptOnTeleport()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/MxdLL/2khub/main/main.lua?t=" .. tick()))()')
        end)
    end
end

local function performServerHop(targetServerId)
    queueScriptOnTeleport()
    if _G.TwoSkiLoaded then
        WindUI:Notify({ Title = "2SKI", Content = "กำลังทำการย้ายเซิร์ฟเวอร์..." })
    end

    if targetServerId and targetServerId ~= "" then
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, LocalPlayer)
        end)
        if ok then return true end
    end

    if #CachedServers > 0 then
        table.sort(CachedServers, function(a, b)
            return a.playing < b.playing
        end)
        for _, s in ipairs(CachedServers) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                if ok then return true end
                task.wait(0.3)
            end
        end
    end

    -- Fallback to native Teleport
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    return true
end

local function rejoinSameServer()
    queueScriptOnTeleport()
    if _G.TwoSkiLoaded then
        WindUI:Notify({ Title = "2SKI", Content = "กำลังเชื่อมต่อเข้าเซิร์ฟเวอร์เดิม..." })
    end
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not ok then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end

-- TAB 5: วาร์ป & เซิร์ฟเวอร์
local TabTP = Window:Tab({ Title = "วาร์ป & เซิร์ฟเวอร์", Icon = "compass" })
TabTP:Section({ Title = "ระบบค้นหา & ย้ายเซิร์ฟเวอร์ (Server Browser)" })

local serverLabels = { "กดรีเฟรชเพื่อโหลดรายชื่อเซิร์ฟ..." }
local selectedServerId = nil

UIControls.SelectedServer = TabTP:Dropdown({
    Title = "เลือกเซิร์ฟเวอร์ปลายทาง (Server List)",
    Values = serverLabels,
    Value = serverLabels[1],
    Callback = function(val)
        for _, s in ipairs(CachedServers) do
            if s.label == val then
                selectedServerId = s.id
                break
            end
        end
    end
})

TabTP:Button({
    Title = "รีเฟรชรายชื่อเซิร์ฟเวอร์ (Refresh Server List)",
    Callback = function()
        local list = fetchServerList()
        if UIControls.SelectedServer then
            if UIControls.SelectedServer.Refresh then pcall(function() UIControls.SelectedServer:Refresh(list) end)
            elseif UIControls.SelectedServer.SetValues then pcall(function() UIControls.SelectedServer:SetValues(list) end) end
        end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "พบเซิร์ฟเวอร์ว่าง " .. tostring(#CachedServers) .. " เซิร์ฟเวอร์" }) end
    end
})

TabTP:Button({
    Title = "ย้ายไปยังเซิร์ฟเวอร์ที่เลือก (Hop Selected Server)",
    Callback = function()
        if selectedServerId then
            performServerHop(selectedServerId)
        else
            performServerHop()
        end
    end
})

TabTP:Button({
    Title = "ย้ายไปเซิร์ฟคนน้อยที่สุด (Hop Lowest Player Server)",
    Callback = function() performServerHop() end
})

TabTP:Button({
    Title = "รีจอยน์เซิร์ฟเวอร์เดิม (Rejoin Same Server)",
    Callback = function()
        rejoinSameServer()
    end
})

TabTP:Section({ Title = "วาร์ปสถานที่สำคัญ (Quick Teleports)" })

TabTP:Button({
    Title = "วาร์ปกลับแปลงของฉัน (Teleport To My Plot)",
    Callback = function()
        local myPlot = getMyPlot()
        local _, hrp, _ = getCharHrp()
        if myPlot and hrp then
            local base = myPlot:FindFirstChild("Baseplate")
            if base then
                hrp.CFrame = base.CFrame + Vector3.new(0, 4, 0)
                if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "วาร์ปมายังแปลงส่วนตัวแล้ว!" }) end
                return
            end
        end
    end
})

TabTP:Button({
    Title = "วาร์ปไปแท่นอัปเกรด Luck (Hatch Luck Station)",
    Callback = function()
        local myPlot = getMyPlot()
        local _, hrp, _ = getCharHrp()
        if myPlot and hrp and myPlot:FindFirstChild("Upgrades") then
            local luckStation = myPlot.Upgrades:FindFirstChild("Luck")
            if luckStation then
                hrp.CFrame = luckStation:GetPivot() + Vector3.new(0, 3, 0)
                if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "วาร์ปมาแท่นอัปเกรด Luck แล้ว!" }) end
                return
            end
        end
    end
})

TabTP:Button({
    Title = "วาร์ปไปโซนรังไข่ (Nests Area)",
    Callback = function()
        local myPlot = getMyPlot()
        local _, hrp, _ = getCharHrp()
        if myPlot and hrp and myPlot:FindFirstChild("Nests") then
            local nest1 = myPlot.Nests:FindFirstChild("1")
            if nest1 then
                hrp.CFrame = nest1:GetPivot() + Vector3.new(0, 3, 0)
                if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "วาร์ปมาโซนรังไข่แล้ว!" }) end
                return
            end
        end
    end
})



-- TAB 6: รีเบิร์ธ & สถิติ
local TabRebirth = Window:Tab({ Title = "เกิดใหม่ & สถิติ", Icon = "flame" })
TabRebirth:Section({ Title = "ระบบรีเบิร์ธอัจฉริยะ (Smart Rebirth & Pet Check)" })

UIControls.RebirthStatusParagraph = TabRebirth:Paragraph({
    Title = "สถานะการรีเบิร์ธถัดไป",
    Content = "กำลังตรวจสอบสัตว์เลี้ยงและเงินที่ต้องใช้..."
})

local function updateRebirthDisplay()
    pcall(function()
        local canRb, msg, reqPet, cost, hasPet = canDoRebirth()
        local txt = msg or "ไม่ทราบสถานะ"
        if reqPet then
            local bestEggs = getBestEggsForRebirthPet(reqPet)
            local eggStr = table.concat(bestEggs, ", ")
            txt = "สัตว์ที่ต้องการ: " .. tostring(reqPet) .. "\nสถานะ: " .. tostring(msg) .. "\nไข่ที่แนะนำให้เก็บ: " .. eggStr
        end
        if UIControls.RebirthStatusParagraph and UIControls.RebirthStatusParagraph.SetContent then
            UIControls.RebirthStatusParagraph:SetContent(txt)
        end
    end)
end
task.spawn(function()
    task.wait(2)
    updateRebirthDisplay()
end)

UIControls.TargetRebirthEgg = TabRebirth:Toggle({
    Title = "เปิดโหมดล่าไข่สำหรับ Rebirth อัตโนมัติ (Rebirth Hunter)",
    Value = State.TargetRebirthEgg,
    Callback = function(val)
        State.TargetRebirthEgg = val
        updateRebirthDisplay()
        if _G.TwoSkiLoaded then
            local _, _, reqPet = canDoRebirth()
            WindUI:Notify({
                Title = "2SKI Rebirth Hunter",
                Content = val and ("เปิดโหมดล่าไข่ Rebirth! (เป้าหมาย: " .. tostring(reqPet or "N/A") .. ")") or "ปิดโหมดล่าไข่ Rebirth"
            })
        end
    end
})

UIControls.AutoRebirth = TabRebirth:Toggle({
    Title = "รีเบิร์ธอัตโนมัติ (Auto Rebirth)",
    Value = State.AutoRebirth,
    Callback = function(val)
        State.AutoRebirth = val
        updateRebirthDisplay()
        if _G.TwoSkiLoaded then
            local canRb, msg = canDoRebirth()
            WindUI:Notify({
                Title = "2SKI Rebirth",
                Content = val and ("เปิดรีเบิร์ธอัตโนมัติ (" .. tostring(msg) .. ")") or "ปิดระบบรีเบิร์ธ"
            })
        end
    end
})

TabRebirth:Button({
    Title = "กดรีเบิร์ธทันที (Force Rebirth Now)",
    Callback = function()
        updateRebirthDisplay()
        local canRb, msg, reqPet, cost = canDoRebirth()
        if canRb and Remote_Rebirth then
            Remote_Rebirth:FireServer()
            if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ส่งคำสั่งรีเบิร์ธสำเร็จ!" }) end
        else
            if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "ไม่สามารถรีเบิร์ธได้: " .. tostring(msg) }) end
        end
    end
})

TabRebirth:Section({ Title = "ระบบเคลมของรางวัลอัตโนมัติ (Auto Rewards)" })

UIControls.AutoClaimIndex = TabRebirth:Toggle({
    Title = "เคลมสมุดสัตว์เลี้ยงอัตโนมัติ (Auto Claim Index)",
    Value = State.AutoClaimIndex,
    Callback = function(val) State.AutoClaimIndex = val end
})

UIControls.AutoClaimRewards = TabRebirth:Toggle({
    Title = "เคลมรางวัลกลุ่ม & อีเวนท์ต่อเนื่อง (Loop Rewards)",
    Value = State.AutoClaimRewards,
    Callback = function(val) State.AutoClaimRewards = val end
})

TabRebirth:Button({
    Title = "เคลมรางวัลออฟไลน์ (Claim Offline Earnings)",
    Callback = function()
        if Remote_OfflineEarnings then
            Remote_OfflineEarnings:FireServer()
            if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI", Content = "รับเงินออฟไลน์เรียบร้อย!" }) end
        end
    end
})

-- TAB 7: ผู้เล่น & ตั้งค่า
local TabSettings = Window:Tab({ Title = "ผู้เล่น & ตั้งค่า", Icon = "user" })
TabSettings:Section({ Title = "ความสามารถตัวละคร (Character Physics)" })

UIControls.WalkSpeed = TabSettings:Slider({
    Title = "ความเร็วเดิน (WalkSpeed)",
    Step = 1,
    Value = { Min = 16, Max = 250, Default = State.WalkSpeed },
    Callback = function(val)
        State.WalkSpeed = val
        local _, _, hum = getCharHrp()
        if hum then hum.WalkSpeed = val end
    end
})

UIControls.JumpPower = TabSettings:Slider({
    Title = "พลังการกระโดด (JumpPower)",
    Step = 1,
    Value = { Min = 50, Max = 300, Default = State.JumpPower },
    Callback = function(val)
        State.JumpPower = val
        local _, _, hum = getCharHrp()
        if hum then hum.UseJumpPower = true; hum.JumpPower = val end
    end
})

UIControls.InfiniteJump = TabSettings:Toggle({
    Title = "กระโดดไร้ขีดจำกัด (Infinite Jump)",
    Value = State.InfiniteJump,
    Callback = function(val) State.InfiniteJump = val end
})

local lastInfJumpTick = 0
local infJumpCon = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local now = tick()
        if now - lastInfJumpTick < 0.16 then return end
        local _, hrp, hum = getCharHrp()
        if hrp and hum and hum.Health > 0 then
            lastInfJumpTick = now
            local jPower = (State.JumpPower and State.JumpPower > 0) and State.JumpPower or (hum.JumpPower > 0 and hum.JumpPower or 100)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, math.clamp(jPower, 70, 350), hrp.AssemblyLinearVelocity.Z)
        end
    end
end)
table.insert(Connections, infJumpCon)

-- Snappy Athletic Jump & Descent Controller (Eliminates floaty slow-mo & sticking)
local fastFallCon = RunService.Heartbeat:Connect(function(dt)
    if not _G.TwoSkiRunning or _G.TwoSkiActiveToken ~= myToken then return end
    if State.ManualFly then return end
    local _, hrp, hum = getCharHrp()
    if hrp and hum and hum.Health > 0 then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Freefall and hrp.AssemblyLinearVelocity.Y < -2 then
            local currentVy = hrp.AssemblyLinearVelocity.Y
            if currentVy > -180 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, currentVy - (dt * 120), hrp.AssemblyLinearVelocity.Z)
            end
        end
    end
end)
table.insert(Connections, fastFallCon)

UIControls.Noclip = TabSettings:Toggle({
    Title = "เดินทะลุกำแพง & ทะลุภูเขา (Noclip All)",
    Value = State.Noclip,
    Callback = function(val) State.Noclip = val; updateNoclipConnection() end
})

UIControls.ManualFly = TabSettings:Toggle({
    Title = "บินอิสระ / บินเอง (Manual Fly [F])",
    Value = State.ManualFly,
    Callback = function(val)
        State.ManualFly = val
        updateManualFly()
        if _G.TwoSkiLoaded then
            WindUI:Notify({
                Title = "2SKI Fly",
                Content = val and "เปิดโหมดบินอิสระ (กดปุ่ม F เพื่อเปิด/ปิด)" or "ปิดโหมดบินอิสระ"
            })
        end
    end
})

UIControls.ManualFlySpeed = TabSettings:Slider({
    Title = "ความเร็วบินอิสระ (Manual Fly Speed)",
    Step = 5,
    Value = { Min = 20, Max = 350, Default = State.ManualFlySpeed },
    Callback = function(val) State.ManualFlySpeed = val end
})

local flyKeyCon = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        State.ManualFly = not State.ManualFly
        if UIControls.ManualFly then
            if UIControls.ManualFly.Set then pcall(function() UIControls.ManualFly:Set(State.ManualFly) end)
            elseif UIControls.ManualFly.SetValue then pcall(function() UIControls.ManualFly:SetValue(State.ManualFly) end) end
        end
        updateManualFly()
        if _G.TwoSkiLoaded then
            WindUI:Notify({
                Title = "2SKI Fly",
                Content = State.ManualFly and "เปิดโหมดบินอิสระ [F]" or "ปิดโหมดบินอิสระ [F]"
            })
        end
    end
end)
table.insert(Connections, flyKeyCon)

UIControls.AntiAfk = TabSettings:Toggle({
    Title = "ป้องกันการหลุดอัตโนมัติ (Anti-AFK 24/7)",
    Value = State.AntiAfk,
    Callback = function(val)
        State.AntiAfk = val
        if _G.TwoSkiLoaded then
            WindUI:Notify({
                Title = "2SKI Anti-AFK",
                Content = val and "เปิดการทำงาน Anti-AFK (ป้องกันหลุด)" or "ปิดการทำงาน Anti-AFK"
            })
        end
    end
})

TabSettings:Section({ Title = "การมองเห็น & ตรวจจับไข่ (Egg Visuals & ESP)" })

UIControls.EggESP = TabSettings:Toggle({
    Title = "มองเห็นไข่ทะลุกำแพง (Egg ESP & Distance)",
    Value = State.EggESP,
    Callback = function(val)
        State.EggESP = val
        if not val then clearEggESP() else updateEggESP() end
        if _G.TwoSkiLoaded then WindUI:Notify({ Title = "2SKI ESP", Content = val and "เปิดการมองเห็นไข่ (Egg ESP)" or "ปิดการมองเห็นไข่" }) end
    end
})

UIControls.ESPMode = TabSettings:Dropdown({
    Title = "โหมดตัวกรอง ESP (ESP Filter Mode)",
    Values = {
        "All / ทั้งหมด (แสดงทุกฟอง)",
        "Match Auto-Farm / ตามที่เลือกในฟาร์ม",
        "Rebirth Only / เฉพาะไข่ที่ใช้เกิดใหม่",
        "Rare+ / ระดับ Rare ขึ้นไป",
        "Legendary+ / ระดับ Legendary ขึ้นไป"
    },
    Value = State.ESPMode or "All / ทั้งหมด (แสดงทุกฟอง)",
    Callback = function(val)
        State.ESPMode = val
        clearEggESP()
        if State.EggESP then updateEggESP() end
    end
})

local function syncSpeedToHumanoid(hum)
    if not hum then return end
    pcall(function()
        if State.RideFastSpeed then
            hum.WalkSpeed = State.RideSpeedValue or 100
        elseif State.WalkSpeed and State.WalkSpeed ~= 16 then
            hum.WalkSpeed = State.WalkSpeed
        end
    end)
end

local charAddedCon = LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
    if hum then syncSpeedToHumanoid(hum) end
    if State.Noclip then updateNoclipConnection() end
end)
table.insert(Connections, charAddedCon)
if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then syncSpeedToHumanoid(hum) end
end


TabSettings:Section({ Title = "การแจ้งเตือน & หน้าจอ (Alerts & Screen)" })

UIControls.MuteScreenAlerts = TabSettings:Toggle({
    Title = "ซ่อนแจ้งเตือนกวนใจ (Mute Alerts)",
    Value = State.MuteScreenAlerts,
    Callback = function(val)
        State.MuteScreenAlerts = val
        if _G.TwoSkiLoaded then
            WindUI:Notify({
                Title = "2SKI Alerts",
                Content = val and "เปิดซ่อนแจ้งเตือนหน้าจอเรียบร้อย" or "ปิดการซ่อนแจ้งเตือน"
            })
        end
    end
})

TabSettings:Section({ Title = "ธีมและปุ่มลอย 2SKI (Aesthetics & Glow)" })

UIControls.CurrentTheme = TabSettings:Dropdown({
    Title = "เลือกพาเลทสี 2SKI (Theme Selector)",
    Values = {
        "2SKI Cyber Cyan (ธีมหลักทางการ - ขาว ฟ้าเรืองแสง Electric Blue)",
        "Tiffany Pastel Mint (สีเขียวมิ้นท์พาสเทล)",
        "Sky Blue Glow (ฟ้านีออนสว่าง)",
        "Neon Emerald (เขียวมรกตนีออน)",
        "Cyber Violet (ม่วงไซเบอร์)",
        "Neon Rose (ชมพูกุหลาบไฟ)",
        "Golden Amber (ทองอำพันพรีเมียม)",
        "Electric Blue (น้ำเงินสดใส)"
    },
    Value = State.CurrentTheme,
    Callback = function(val)
        State.CurrentTheme = val
        applyThemePreset(val)
    end
})

UIControls.FloatingButtonVisible = TabSettings:Toggle({
    Title = "แสดงปุ่มลอย 2SKI (Floating Button)",
    Value = State.FloatingButtonVisible,
    Callback = function(val)
        State.FloatingButtonVisible = val
        if ToggleGui then ToggleGui.Enabled = val end
    end
})

TabSettings:Section({ Title = "คอมมูนิตี้ & ช่องทางติดต่อ (Discord)" })
TabSettings:Button({
    Title = "เข้าร่วม Discord",
    Callback = function()
        safeCopy("https://discord.gg/pWpyGnq5qz")
        pcall(function()
            local req = request or http_request or (syn and syn.request) or (http and http.request)
            if req then
                req({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
                    Body = HttpService:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        args = { code = "pWpyGnq5qz" },
                        nonce = HttpService:GenerateGUID(false)
                    })
                })
            end
        end)
        WindUI:Notify({
            Title = "2SKI Discord",
            Content = "คัดลอกลิงก์ดิสคอร์ด https://discord.gg/pWpyGnq5qz เรียบร้อย!"
        })
    end
})

TabSettings:Section({ Title = "ระบบบันทึกการตั้งค่า (Configuration System)" })

TabSettings:Button({
    Title = "บันทึกการตั้งค่าลงเครื่อง (Save Config)",
    Callback = function() saveConfig() end
})

TabSettings:Button({
    Title = "โหลดการตั้งค่าจากเครื่อง (Load Config)",
    Callback = function() loadConfig(false) end
})

TabSettings:Button({
    Title = "รีเซ็ตการตั้งค่าเป็นค่าเริ่มต้น (Reset to Default)",
    Callback = function()
        pcall(function()
            if delfile and isfile and isfile(CONFIG_FILE) then
                delfile(CONFIG_FILE)
            elseif writefile then
                writefile(CONFIG_FILE, "{}")
            end
        end)
        if _G.TwoSkiLoaded and WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "2SKI", Content = "ลบไฟล์ Config และรีเซ็ตเป็นค่าเริ่มต้นเรียบร้อย!" })
        end
    end
})

UIControls.AutoLoadConfig = TabSettings:Toggle({
    Title = "โหลดการตั้งค่าอัตโนมัติเมื่อเปิดสคริปต์ (Auto Load)",
    Value = State.AutoLoadConfig,
    Callback = function(val) State.AutoLoadConfig = val end
})

-- Anti-AFK Engine (Dual Method: LocalPlayer.Idled event + Fail-safe Heartbeat)
local antiAfkCon = LocalPlayer.Idled:Connect(function()
    if State.AntiAfk then
        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            elseif VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
            end
        end)
    end
end)
table.insert(Connections, antiAfkCon)

task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        task.wait(480) -- 8 minutes heartbeat
        if State.AntiAfk then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.zero)
                end
            end)
        end
    end
end)

---------------------------------------------------------------------
-- BACKGROUND AUTOMATION LOOPS
---------------------------------------------------------------------

-- Loop 1: High-Performance Character & Riding Speed Controller (Smooth & Anti-Stutter)
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        local targetSpeed = nil
        if State.RideFastSpeed then
            targetSpeed = State.RideSpeedValue or 100
        elseif State.WalkSpeed and State.WalkSpeed ~= 16 then
            targetSpeed = State.WalkSpeed
        end

        local _, _, hum = getCharHrp()
        if hum then
            if targetSpeed and hum.WalkSpeed ~= targetSpeed then
                pcall(function() hum.WalkSpeed = targetSpeed end)
            end
            -- Maintain crisp high jump continuously (Always enforce UseJumpPower and exact matching JumpHeight)
            pcall(function()
                local jp = State.JumpPower or 100
                local g = (workspace.Gravity and workspace.Gravity > 0) and workspace.Gravity or 250
                hum.UseJumpPower = true
                hum.JumpPower = jp
                hum.JumpHeight = (jp ^ 2) / (2 * g)
            end)
        end
        task.wait(targetSpeed and 0.25 or 0.4)
    end
end)

-- Loop 2: Instant Auto Upgrades (Strict Balance Check & Adaptive Sleep)
local lastLuckUpgradeTime = 0
local lastNestUpgradeTime = 0
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if not (State.AutoUpgradeAll or State.AutoUpgradeLuck or State.AutoUpgradeNests) then
            task.wait(1.5)
        else
            task.wait(1.0)
            local now = tick()
            if (State.AutoUpgradeAll or State.AutoUpgradeLuck) and Remote_PlotUpgrades and (now - lastLuckUpgradeTime >= 2.0) then
                pcall(function()
                    local canAfford, cost, count = canAffordHatchLuck()
                    if canAfford then
                        Remote_PlotUpgrades:FireServer("Max")
                        lastLuckUpgradeTime = tick()
                    end
                end)
            end

            if (State.AutoUpgradeAll or State.AutoUpgradeNests) and Remote_PlotNests and (now - lastNestUpgradeTime >= 2.0) then
                pcall(function()
                    local currentCash = getPlayerCash()
                    local myPlot = getMyPlot()
                    if myPlot and myPlot:FindFirstChild("Nests") then
                        for i = 2, 5 do
                            local nest = myPlot.Nests:FindFirstChild(tostring(i))
                            if nest and nest:GetAttribute("Unlocked") ~= true then
                                local price = NestPrices[i] or 0
                                if currentCash >= price and price > 0 then
                                    Remote_PlotNests:FireServer(i)
                                    lastNestUpgradeTime = tick()
                                end
                                break
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- Loop 3: Silent Pet Feeding (Prevent "Feed Pets On Your Ranch" Alert)
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if not State.AutoFeedPets then
            task.wait(1.5)
            continue
        end
        task.wait(State.FeedInterval or 1.2)
        if Remote_FeedPet then
            pcall(function()
                -- Only feed when player is on or near their ranch to avoid server rejection!
                if not isOnMyPlot() then return end

                local pr = getPetRenderer()
                if not pr then return end
                local foodName = State.SelectedFood or "Grass"
                local char, _, hum = getCharHrp()
                local foodTool = (char and char:FindFirstChild(foodName)) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(foodName))
                if foodTool and hum then hum:EquipTool(foodTool); task.wait(0.05) end

                for _, pet in pairs(pr.GetAll()) do
                    if pet.OwnerUserId == LocalPlayer.UserId and pet.PetKey and isPetMatchingFeedTarget(pet) then
                        for b = 1, (State.FeedBatchAmount or 1) do
                            Remote_FeedPet:FireServer(pet.PetKey, foodName)
                        end
                        task.wait(0.03)
                    end
                end
            end)
        end
    end
end)

-- Screen Notification Suppressor (Completely Mutes "Not Enough Coins" & "Feed Pets On Your Ranch")
local function suppressAlertObject(obj)
    if not obj or not obj:IsA("GuiObject") then return end
    if not State.MuteScreenAlerts then return end
    pcall(function()
        local name = string.lower(tostring(obj.Name))
        local isTarget = name:find("not enough") or name:find("feed pet") or name:find("ranch") or name:find("coin") or name:find("money") or name:find("cash") or name:find("need a") or name:find("you need")
        if not isTarget then
            for _, lbl in ipairs(obj:GetDescendants()) do
                if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and lbl.Text then
                    local txt = string.lower(tostring(lbl.Text))
                    if txt:find("not enough") or (txt:find("feed pet") and txt:find("ranch")) or txt:find("feed pets on your ranch") or txt:find("not enough coins") or txt:find("you need a") or txt:find("need a") then
                        isTarget = true
                        break
                    end
                end
            end
        end
        if isTarget then
            obj.Visible = false
            pcall(function() obj.Position = UDim2.new(10, 0, 10, 0) end)
            pcall(function() obj:Destroy() end)
        end
    end)
end

-- Layer 1: Hook Reusable.GameMessages.Handler (intercept before UI creation & SFX)
task.spawn(function()
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
        local reusable = pg and pg:WaitForChild("Reusable", 10)
        local gm = reusable and reusable:WaitForChild("GameMessages", 10)
        local handlerScript = gm and gm:WaitForChild("Handler", 10)
        if handlerScript and handlerScript:IsA("ModuleScript") then
            local Handler = require(handlerScript)
            if Handler and type(Handler.AddMessage) == "function" and not Handler._TwoSkiHooked then
                Handler._TwoSkiHooked = true
                local origAddMessage = Handler.AddMessage
                Handler.AddMessage = function(self, msg, duration, rarity, ...)
                    if State.MuteScreenAlerts then
                        local s = tostring(msg):lower()
                        if s:find("not enough") or (s:find("feed pet") and s:find("ranch")) or s:find("coin") or s:find("money") or s:find("cash") then
                            return nil
                        end
                    end
                    return origAddMessage(self, msg, duration, rarity, ...)
                end
            end
        end
    end)
end)

-- Layer 2 & 3: ChildAdded and DescendantAdded observers
task.spawn(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    local reusable = pg and pg:WaitForChild("Reusable", 10)
    local gm = reusable and reusable:WaitForChild("GameMessages", 10)
    if gm then
        for _, child in ipairs(gm:GetChildren()) do
            suppressAlertObject(child)
        end
        local c = gm.ChildAdded:Connect(function(child)
            suppressAlertObject(child)
        end)
        table.insert(Connections, c)
    end

    local gw = reusable and reusable:FindFirstChild("GameWarning")
    if gw then
        local c2 = gw:GetPropertyChangedSignal("Text"):Connect(function()
            if State.MuteScreenAlerts and gw.Text then
                local txt = string.lower(gw.Text)
                if txt:find("not enough") or (txt:find("feed pet") and txt:find("ranch")) or txt:find("coin") then
                    gw.Visible = false
                    gw.Text = ""
                end
            end
        end)
        table.insert(Connections, c2)
    end

    -- Layer 3: Relaxed Watchdog Loop (sweeps any remaining banners every 1.5s - zero overhead)
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        task.wait(1.5)
        if State.MuteScreenAlerts then
            pcall(function()
                if gm then
                    for _, child in ipairs(gm:GetChildren()) do
                        if child:IsA("GuiObject") then
                            suppressAlertObject(child)
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 4: Auto Sell & Collect + Auto Buy Food / Gears + Rewards
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if not (State.AutoSellCollect or State.AutoBuyFood or State.AutoBuyGears or State.AutoClaimRewards or State.AutoClaimIndex or State.AutoRebirth) then
            task.wait(2.0)
            continue
        end
        task.wait(1.2)
        if State.AutoSellCollect and Remote_PetCollect then
            pcall(function()
                local PetRenderer = getPetRenderer()
                for _, pet in pairs(PetRenderer.GetAll()) do
                    if pet.OwnerUserId == LocalPlayer.UserId and pet.PetKey then
                        Remote_PetCollect:FireServer(pet.PetKey)
                    end
                end
            end)
        end

        if State.AutoBuyFood and Remote_BuyWithCash then
            pcall(function()
                local foodName = State.SelectedFood or "Grass"
                local hasFood = (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(foodName)) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(foodName))
                if not hasFood then Remote_BuyWithCash:FireServer("Food", foodName) end
            end)
        end

        if State.AutoBuyGears and Remote_BuyWithCash and State.SelectedGear then
            pcall(function() Remote_BuyWithCash:FireServer("Gear", State.SelectedGear) end)
        end

        if State.AutoClaimRewards then
            pcall(function()
                if Remote_ClaimGroupReward then Remote_ClaimGroupReward:FireServer() end
                if Remote_ClaimEventReward then Remote_ClaimEventReward:FireServer() end
            end)
        end

        if State.AutoClaimIndex and Remote_ClaimIndex then
            pcall(function() Remote_ClaimIndex:FireServer() end)
        end

        if State.AutoRebirth and Remote_Rebirth then
            pcall(function()
                local canRb, msg = canDoRebirth()
                if canRb then
                    Remote_Rebirth:FireServer()
                end
            end)
        end
    end
end)


-- Loop 5: Auto Best Mount & Pet Management
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if not (State.AutoMountBest or State.AutoCollectPets or State.AutoPlaceBestPets) then
            task.wait(1.5)
            continue
        end
        task.wait(State.PetActionDelay or 0.8)

        -- Auto Best Mount
        if State.AutoMountBest then
            pcall(mountBestPetNow)
        end

        -- Auto Collect All Base Pets (Silent in background)
        if State.AutoCollectPets then
            pcall(function() collectAllPlotPetsNow(true) end)
        end

        if State.AutoPlaceBestPets and Remote_PlacePet then
            pcall(function()
                local maxPets = LocalPlayer:GetAttribute("MaxPets") or 5
                local PetRenderer = getPetRenderer()
                local plotPets = {}
                for _, pet in pairs(PetRenderer.GetAll()) do
                    if pet.OwnerUserId == LocalPlayer.UserId and pet.PetKey then table.insert(plotPets, pet) end
                end

                local backpackPets = {}
                for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    local pKey = item:GetAttribute("PetKey")
                    if pKey then
                        local pName = item:GetAttribute("PetName") or item.Name
                        local weight = item:GetAttribute("Weight") or item:GetAttribute("BaseWeight") or 1
                        local age = item:GetAttribute("Age") or item:GetAttribute("CurrentAge") or 1
                        local score = calculatePetScore(pName, weight, age)
                        table.insert(backpackPets, { tool = item, key = pKey, score = score, name = pName })
                    end
                end
                table.sort(backpackPets, function(a, b) return a.score > b.score end)

                local myPlot = getMyPlot()
                local baseplate = myPlot and myPlot:FindFirstChild("Baseplate")
                local targetPos = baseplate and (baseplate.Position + Vector3.new(0, 3, 0)) or Vector3.new(0, 40315, 600)

                -- Empty slot on plot: place best pet directly
                if #plotPets < maxPets and #backpackPets > 0 then
                    local best = backpackPets[1]
                    local _, _, hum = getCharHrp()
                    if hum then
                        hum:EquipTool(best.tool)
                        task.wait(0.15)
                        Remote_PlacePet:FireServer(best.key, targetPos)
                        task.wait(0.3)
                    end
                elseif #plotPets >= maxPets and #backpackPets > 0 and Remote_PickupPet then
                    -- Plot full: find worst plot pet using accurate BaseWeight and CurrentAge
                    local worstPlotPet, lowestScore = nil, math.huge
                    for _, pp in ipairs(plotPets) do
                        local pName = pp.Model and pp.Model.Name or "Unknown"
                        local weight = pp.BaseWeight or pp.Weight or 1
                        local age = pp.CurrentAge or pp.Age or 1
                        local score = calculatePetScore(pName, weight, age)
                        if score < lowestScore then
                            lowestScore = score
                            worstPlotPet = pp
                        end
                    end

                    local bestBackpack = backpackPets[1]
                    local now = tick()
                    local isCooldown = (now - (petSwapCooldown[bestBackpack.key] or 0) < 12)
                                    or (worstPlotPet and (now - (petSwapCooldown[worstPlotPet.PetKey] or 0) < 12))

                    -- Only swap if backpack pet is strictly better by a significant threshold (+50) and not on cooldown
                    if not isCooldown and worstPlotPet and (bestBackpack.score > lowestScore + 50) then
                        petSwapCooldown[bestBackpack.key] = now
                        petSwapCooldown[worstPlotPet.PetKey] = now
                        Remote_PickupPet:FireServer(worstPlotPet.PetKey)
                        task.wait(0.4)
                        local _, _, hum = getCharHrp()
                        if hum then
                            hum:EquipTool(bestBackpack.tool)
                            task.wait(0.15)
                            Remote_PlacePet:FireServer(bestBackpack.key, targetPos)
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 6: Complete Flight Egg Collection (Safe Sky Corridor & Coordinated Auto-Placement)
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if not State.AutoFlyEggs then
            releaseFlightHold()
            task.wait(1.0)
            continue
        end

        local char, hrp, hum = getCharHrp()
        if not hrp or not hum or hum.Health <= 0 then
            releaseFlightHold()
            task.wait(1.0)
            continue
        end

        -- Bank any leftover basket egg to backpack before flying out
        local curBasket = LocalPlayer:FindFirstChild("Basket")
        if curBasket and #curBasket:GetChildren() > 0 then
            depositBasketToBackpack()
            task.wait(0.12)
        end

        local candidates = {}
        local renderedFolder = workspace:FindFirstChild("RenderedEggs")
        if renderedFolder then
            for _, egg in ipairs(renderedFolder:GetChildren()) do
                local matchOk, isMatch = pcall(isEggMatching, egg)
                if matchOk and isMatch then
                    local part = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
                    if part then
                        local d = (part.Position - hrp.Position).Magnitude
                        local ae, realW, shownKG = getActiveEggInfo(egg)
                        table.insert(candidates, {
                            egg = egg,
                            activeEgg = ae,
                            eggUuid = ae and ae.Name,
                            part = part,
                            dist = d,
                            weight = realW,
                            shownKG = shownKG
                        })
                    end
                end
            end
        end

        if #candidates == 0 then
            releaseFlightHold()
            task.wait(0.5)
            continue
        end

        -- Always fly to the best candidate: Heaviest first if enabled or if MinEggWeight is set, otherwise closest distance!
        local shouldSortByWeight = State.PrioritizeHeaviestEgg or (State.MinEggWeight and State.MinEggWeight ~= "0 KG+ (ไม่จำกัด)" and not State.MinEggWeight:find("0 KG"))
        if shouldSortByWeight then
            table.sort(candidates, function(a, b)
                local wA = tonumber(a.shownKG) or tonumber(a.weight) or 1
                local wB = tonumber(b.shownKG) or tonumber(b.weight) or 1
                if math.abs(wA - wB) > 0.5 then
                    return wA > wB
                end
                return a.dist < b.dist
            end)
        else
            table.sort(candidates, function(a, b)
                return a.dist < b.dist
            end)
        end

        local closestEgg = candidates[1].egg

        pcall(function()
            local eggPart = closestEgg:FindFirstChildWhichIsA("BasePart") or closestEgg.PrimaryPart
            local eggPos = eggPart and eggPart.Position or closestEgg:GetPivot().Position
            local targetEggPos = eggPos + Vector3.new(0, 1.8, 0)
            local prevNoclip = State.Noclip
            State.Noclip = true
            updateNoclipConnection()
            ensureFlightHold(hrp)

            -- Gentle Low-Altitude Corridor: only 5 studs above ground (Zero rocket-high flights!)
            local startPos = hrp.Position
            local cruisingY = math.max(startPos.Y, targetEggPos.Y) + 5

            -- Ascend slightly if lower than cruising altitude
            if startPos.Y < cruisingY - 2 then
                tweenFlight(Vector3.new(startPos.X, cruisingY, startPos.Z), State.FlySpeed * 1.2)
            end

            -- Fly horizontally across smoothly directly over egg
            tweenFlight(Vector3.new(targetEggPos.X, cruisingY, targetEggPos.Z), State.FlySpeed)

            -- Descend right onto the egg (1.8 studs)
            tweenFlight(targetEggPos, State.FlySpeed * 1.1)
            task.wait(0.08)

            -- Pickup confirmation: actively ensure egg enters Basket or is grabbed
            local prompt = closestEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
            local targetUuid = candidates[1] and candidates[1].eggUuid
            local basket = LocalPlayer:FindFirstChild("Basket")
            local prevBasketCount = basket and #basket:GetChildren() or 0

            local pickupSuccess = false
            local t0 = tick()
            while tick() - t0 < 0.75 do
                if prompt and prompt.Enabled then
                    triggerPrompt(prompt, 0.08)
                end
                if Remote_EggPickup then
                    if targetUuid then
                        pcall(function() Remote_EggPickup:FireServer(targetUuid) end)
                    else
                        pcall(function() Remote_EggPickup:FireServer(closestEgg.Name) end)
                    end
                end
                task.wait(0.08)
                if not closestEgg.Parent or (basket and #basket:GetChildren() > prevBasketCount) then
                    pickupSuccess = true
                    break
                end
            end

            -- Only fly back to plot if basket actually contains an egg or pickup succeeded!
            if (basket and #basket:GetChildren() > 0) or pickupSuccess then
                local myPlot = getMyPlot()
                local baseplate = myPlot and myPlot:FindFirstChild("Baseplate")
                local basePos = baseplate and (baseplate.Position + Vector3.new(0, 2.8, 0)) or (getPlotCenterPos() or Vector3.new(172, 40316, 1067))
                local returnCruisingY = math.max(hrp.Position.Y, basePos.Y) + 5

                -- Ascend slightly to return cruising altitude
                if hrp.Position.Y < returnCruisingY - 2 then
                    tweenFlight(Vector3.new(hrp.Position.X, returnCruisingY, hrp.Position.Z), State.FlySpeed * 1.2)
                end

                -- Fly horizontally across back to plot
                tweenFlight(Vector3.new(basePos.X, returnCruisingY, basePos.Z), State.FlySpeed)

                -- Descend smoothly onto baseplate
                tweenFlight(basePos, State.FlySpeed * 1.1)
                task.wait(0.05)

                -- Deposit into backpack cleanly (waits until basket is confirmed empty!)
                depositBasketToBackpack()

                -- Immediately place newly acquired egg on plot if AutoPlaceEggs is on!
                if State.AutoPlaceEggs then
                    pcall(placeAllHeldEggsNow)
                end
            end

            State.Noclip = prevNoclip
            updateNoclipConnection()
            releaseFlightHold()
        end)

        releaseFlightHold()
        task.wait(0.2)
    end
end)

-- Dedicated Coordinated Egg Placement & Nesting Worker (Places continuously until plot is truly full)
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if State.AutoPlaceEggs and not isPlacingEggs then
            pcall(function()
                local invEggs = getInventoryEggs(true)
                if #invEggs == 0 then invEggs = getInventoryEggs(false) end
                if #invEggs > 0 then
                    local char, hrp = getCharHrp()
                    local myPlot = getMyPlot()
                    local bp = myPlot and myPlot:FindFirstChild("Baseplate")
                    local isNearPlot = false
                    if hrp and bp then
                        isNearPlot = (hrp.Position - bp.Position).Magnitude < 100
                    end
                    if not State.AutoFlyEggs or isNearPlot then
                        placeAllHeldEggsNow()
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(1.5)
        end
    end
end)

-- Dedicated Auto Hatch Loop (Runs smoothly every 0.8s, never misses an egg)
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        if State.AutoHatch then
            pcall(autoHatchPlotEggs)
            task.wait(0.8)
        else
            task.wait(1.5)
        end
    end
end)

-- Anti-Void & Map-Fall Guardian (Permits Desert Underground Caves down to Y=40200, Only Catches True Void Drops!)
local lastRescueNoticeTime = 0
task.spawn(function()
    while _G.TwoSkiRunning and _G.TwoSkiActiveToken == myToken do
        task.wait(0.15)
        pcall(function()
            local char, hrp, hum = getCharHrp()
            if hrp and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
                -- Lowest desert cave is at Y=40208. Only trigger if falling below Y=40150 into the void!
                if hrp.Position.Y > 1000 and hrp.Position.Y < 40150 and hrp.AssemblyLinearVelocity.Y < -25 then
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                    end)
                    local myPlot = getMyPlot()
                    local bp = myPlot and myPlot:FindFirstChild("Baseplate")
                    local rescuePos = bp and (bp.Position + Vector3.new(0, 3.5, 0)) or (getPlotCenterPos() or Vector3.new(286, 40316, 970))
                    hrp.CFrame = CFrame.new(rescuePos)
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                    end)
                    releaseFlightHold()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)

                    local now = tick()
                    if now - lastRescueNoticeTime > 4.0 then
                        lastRescueNoticeTime = now
                        if _G.TwoSkiLoaded and WindUI and WindUI.Notify then
                            WindUI:Notify({ Title = "2SKI Anti-Void", Content = "กู้คืนตัวละครกลับมาที่แปลงเรียบร้อย!" })
                        end
                    end
                end
            end
        end)
    end
end)

_G.TwoSkiLoaded = true
-- Initialize UI & Settings
pcall(function() if Window and Window.SelectTab then Window:SelectTab(1) end end)
applyThemePreset(State.CurrentTheme)
_G.TwoSkiState = State
_G.TwoSkiControls = UIControls

task.defer(function()
    if isfile and isfile(CONFIG_FILE) then
        loadConfig(true)
    end
end)

WindUI:Notify({
    Title = "2SKI Master Edition",
    Content = isMobile and "โหมดมือถือ & iOS พร้อมใช้งาน! ลื่นไหล 0% แตะหรือลากปุ่ม 2SKI ได้ทันที" or "ธีม 2SKI Cyber Cyan พร้อมใช้งาน! กด Left Ctrl หรือคลิกปุ่มลอย 2SKI เพื่อเปิด/ปิด"
})
print("[2SKI] Master Edition successfully loaded.")
