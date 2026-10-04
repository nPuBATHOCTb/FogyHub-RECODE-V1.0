if getgenv().AL_MM2_Loaded then
    pcall(getgenv().AL_MM2_Cleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local PARENT
if gethui then
    local ok, h = pcall(gethui)
    if ok and h then PARENT = h end
end
PARENT = PARENT or LP:WaitForChild("PlayerGui")

for _, c in ipairs(PARENT:GetChildren()) do
    if c.Name:sub(1, 6) == "AL_MM2" then c:Destroy() end
end

getgenv().AL_MM2_Loaded = true
getgenv().AL_MM2_Conns = {}
getgenv().AL_MM2_Binds = {}

local function addConn(c)
    table.insert(getgenv().AL_MM2_Conns, c)
    return c
end

local function addBind(name, prio, fn)
    pcall(function() RunService:UnbindFromRenderStep(name) end)
    pcall(function() RunService:BindToRenderStep(name, prio, fn) end)
    table.insert(getgenv().AL_MM2_Binds, name)
end

getgenv().AL_MM2_Cleanup = function()
    getgenv().AL_MM2_Loaded = false
    for _, c in ipairs(getgenv().AL_MM2_Conns) do
        pcall(function() c:Disconnect() end)
    end
    getgenv().AL_MM2_Conns = {}
    for _, n in ipairs(getgenv().AL_MM2_Binds) do
        pcall(function() RunService:UnbindFromRenderStep(n) end)
    end
    getgenv().AL_MM2_Binds = {}
    pcall(function()
        local container = gethui and gethui() or game:GetService("CoreGui")
        for _, c in ipairs(container:GetChildren()) do
            if c.Name:sub(1, 6) == "AL_MM2" then c:Destroy() end
        end
    end)
end

local CLR = {
    bg      = Color3.fromRGB(11, 13, 20),
    panel   = Color3.fromRGB(20, 24, 36),
    element = Color3.fromRGB(30, 36, 52),
    elem_hi = Color3.fromRGB(42, 50, 70),
    border  = Color3.fromRGB(50, 58, 80),
    text    = Color3.fromRGB(230, 235, 245),
    text_d  = Color3.fromRGB(140, 150, 175),
    text_dd = Color3.fromRGB(85, 92, 115),
    accent  = Color3.fromRGB(66, 148, 255),
    accent_h = Color3.fromRGB(110, 180, 255),
    accent_d = Color3.fromRGB(42, 98, 180),
    green   = Color3.fromRGB(85, 220, 130),
    red     = Color3.fromRGB(255, 90, 110),
    yellow  = Color3.fromRGB(255, 210, 90),
    purple  = Color3.fromRGB(180, 90, 220),
}

local F  = Enum.Font.Gotham
local FM = Enum.Font.GothamMedium
local FB = Enum.Font.GothamBold
local FBK = Enum.Font.GothamBlack

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = col or CLR.border
    s.Thickness = th or 1
    s.Transparency = tr or 0.4
    return s
end

local function tw(o, prop, val, t)
    local tr = TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), {[prop] = val})
    tr:Play()
    return tr
end

local Cfg = {
    Language = "ru",
    MenuKey = Enum.KeyCode.RightShift,
    Visuals = {
        ESP_Murderer = false,
        ESP_Sheriff = false,
        ESP_Hero = false,
        ESP_Innocent = false,
        ESP_Boxes = false,
        ESP_GunDrop = false,
        NoFog = false,
        FullBright = false,
        TimeOfDay = 14,
    },
    Combat = {
        Aimlock = false,
        AimlockKey = Enum.KeyCode.E,
        AutoShoot = false,
        KillAura = false,
        KillAuraRange = 25,
        AutoDodgeKnife = false,
    },
    Utility = {
        AutoGrabGun = false,
        SpeedGlitch = false,
        SpeedValue = 45,
        Noclip = false,
        AntiFling = false,
        AutoFarmCoins = false,
        Invisibility = false,
        TP_Lobby = false,
        TP_Map = false,
    },
    Mobile = {
        Locked = false,
        Scale = 1.0,
        Buttons = {
            ["Fling Murderer"] = false,
            ["Fling Sheriff"] = false,
            ["Fling Hero"] = false,
            ["Grab Gun"] = false,
            ["Speed Glitch"] = false,
            ["Noclip"] = false,
            ["Kill Aura"] = false,
            ["Aimlock"] = false,
            ["Invisibility"] = false,
            ["TP Lobby"] = false,
            ["TP Map"] = false,
        },
        Positions = {},
    },
}

local configFile = "al_mm2_config.json"
local HttpService = game:GetService("HttpService")

local function saveConfig()
    if writefile then
        pcall(function()
            writefile(configFile, HttpService:JSONEncode(Cfg))
        end)
    end
end

local function loadConfig()
    if readfile and isfile and isfile(configFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(configFile))
            if data then
                if data.Language then Cfg.Language = data.Language end
                if data.MenuKey then Cfg.MenuKey = data.MenuKey end
                for k, v in pairs(data.Visuals or {}) do Cfg.Visuals[k] = v end
                for k, v in pairs(data.Combat or {}) do Cfg.Combat[k] = v end
                for k, v in pairs(data.Utility or {}) do Cfg.Utility[k] = v end
                if data.Mobile then
                    if data.Mobile.Locked ~= nil then Cfg.Mobile.Locked = data.Mobile.Locked end
                    if data.Mobile.Scale then Cfg.Mobile.Scale = data.Mobile.Scale end
                    for k, v in pairs(data.Mobile.Buttons or {}) do Cfg.Mobile.Buttons[k] = v end
                    for k, v in pairs(data.Mobile.Positions or {}) do Cfg.Mobile.Positions[k] = v end
                end
            end
        end)
    end
end

loadConfig()

local L = {
    ru = {
        Title = "ALWAYSLOSE MM2",
        Visuals = "Визуалы",
        Combat = "Бой",
        Utility = "Утилиты",
        Mobile = "Кнопки",
        Configs = "Конфиги",
        ESP_M = "ESP Убийца",
        ESP_S = "ESP Шериф",
        ESP_H = "ESP Герой",
        ESP_I = "ESP Мирные",
        ESP_B = "3D Боксы",
        ESP_G = "ESP Пистолет",
        NoFog = "Убрать туман",
        FullBright = "Полная яркость",
        TimeOfDay = "Время суток",
        Aimlock = "Аимлок",
        AimKey = "Клавиша аимлока",
        AutoShoot = "Авто-выстрел в убийцу",
        KillAura = "Kill Aura",
        KillAuraRange = "Радиус Kill Aura",
        AutoDodge = "Авто-уклон от ножей",
        AutoGrab = "Авто-подбор пистолета",
        SpeedGlitch = "Спидглитч",
        SpeedValue = "Скорость",
        Noclip = "Noclip",
        AntiFling = "Anti-Fling",
        AutoFarm = "Авто-фарм монет",
        Invis = "Невидимость",
        TP_Lobby = "ТП в лобби",
        TP_Map = "ТП на карту",
        LockMobile = "Заблокировать кнопки",
        MobileScale = "Размер кнопок",
        Save = "Сохранить",
        Load = "Загрузить",
        Reset = "Сбросить",
        Lang = "Язык",
        FlingM = "Флинг Убийцы",
        FlingS = "Флинг Шерифа",
        FlingH = "Флинг Героя",
        GrabGun = "Взять пистолет",
        ButInvis = "Невидимость",
        ButAim = "Аимлок",
        ButKA = "Kill Aura",
        ButNoclip = "Noclip",
        ButSpeed = "Спидглитч",
        ButTpLobby = "ТП в лобби",
        ButTpMap = "ТП на карту",
        NoM = "Убийца не найден",
        NoS = "Шериф не найден",
        NoH = "Герой не найден",
        NoGun = "Пистолет не найден",
        NoKnife = "Ты не убийца",
        Loaded = "ALWAYSLOSE MM2 загружен",
        Saved = "Сохранено",
        LoadedConf = "Загружено",
        ResetConf = "Сброшено",
        Flinging = "Флинг: ",
        SitErr = " сидит, флинг невозможен",
        NoclipOn = "Noclip ВКЛ",
        NoclipOff = "Noclip ВЫКЛ",
        SpeedOn = "Спидглитч ВКЛ",
        SpeedOff = "Спидглитч ВЫКЛ",
    },
    en = {
        Title = "ALWAYSLOSE MM2",
        Visuals = "Visuals",
        Combat = "Combat",
        Utility = "Utility",
        Mobile = "Buttons",
        Configs = "Configs",
        ESP_M = "ESP Murderer",
        ESP_S = "ESP Sheriff",
        ESP_H = "ESP Hero",
        ESP_I = "ESP Innocent",
        ESP_B = "3D Boxes",
        ESP_G = "ESP Gun Drop",
        NoFog = "No Fog",
        FullBright = "Fullbright",
        TimeOfDay = "Time of Day",
        Aimlock = "Aimlock",
        AimKey = "Aimlock Key",
        AutoShoot = "Auto-Shoot Murderer",
        KillAura = "Kill Aura",
        KillAuraRange = "Kill Aura Range",
        AutoDodge = "Auto-Dodge Knives",
        AutoGrab = "Auto-Grab Gun",
        SpeedGlitch = "Speed Glitch",
        SpeedValue = "Speed",
        Noclip = "Noclip",
        AntiFling = "Anti-Fling",
        AutoFarm = "Auto-Farm Coins",
        Invis = "Invisibility",
        TP_Lobby = "TP to Lobby",
        TP_Map = "TP to Map",
        LockMobile = "Lock Buttons",
        MobileScale = "Button Scale",
        Save = "Save",
        Load = "Load",
        Reset = "Reset",
        Lang = "Language",
        FlingM = "Fling Murderer",
        FlingS = "Fling Sheriff",
        FlingH = "Fling Hero",
        GrabGun = "Grab Gun",
        ButInvis = "Invisibility",
        ButAim = "Aimlock",
        ButKA = "Kill Aura",
        ButNoclip = "Noclip",
        ButSpeed = "Speed Glitch",
        ButTpLobby = "TP Lobby",
        ButTpMap = "TP Map",
        NoM = "Murderer not found",
        NoS = "Sheriff not found",
        NoH = "Hero not found",
        NoGun = "Gun not found",
        NoKnife = "You are not murderer",
        Loaded = "ALWAYSLOSE MM2 loaded",
        Saved = "Saved",
        LoadedConf = "Loaded",
        ResetConf = "Reset",
        Flinging = "Flinging: ",
        SitErr = " is sitting, cannot fling",
        NoclipOn = "Noclip ON",
        NoclipOff = "Noclip OFF",
        SpeedOn = "Speed Glitch ON",
        SpeedOff = "Speed Glitch OFF",
    },
}

local function T(k)
    return (L[Cfg.Language] or L.ru)[k] or L.ru[k] or k
end

local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not WindUI then
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end

local notify = function(title, content, dur)
    pcall(function()
        WindUI:Notify({Title = title, Content = content, Duration = dur or 3})
    end)
end

local roles = {}
local Murder, Sheriff, Hero = nil, nil, nil
local lastMurder, lastSheriff = nil, nil
local originalFog = Lighting.FogEnd
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient
local originalTime = Lighting.TimeOfDay

local invisOn = false
local invisSeat = nil
local invisOutline = nil
local savedCFrame = nil
local savedCamSubject = nil
local savedAutoRotate = nil

local grabbingGun = false
local lastDodge = 0

local function getChar(p)
    p = p or LP
    return p.Character or workspace:FindFirstChild(p.Name)
end

local function getHRP(p)
    local c = getChar(p)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum(p)
    local c = getChar(p)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHead(p)
    local c = getChar(p)
    return c and c:FindFirstChild("Head")
end

local function isAlive(p)
    local data = roles[p.Name]
    if data then
        return not data.Killed and not data.Dead
    end
    local h = getHum(p)
    return h and h.Health > 0
end

local function getRole()
    local ok, data = pcall(function()
        local remote = RS:FindFirstChild("GetPlayerData", true)
        return remote and remote:InvokeServer()
    end)
    if ok and data then
        roles = data
        local m, s, h = nil, nil, nil
        for name, info in pairs(data) do
            if info.Role == "Murderer" then m = name
            elseif info.Role == "Sheriff" then s = name
            elseif info.Role == "Hero" then h = name end
        end
        Murder, Sheriff, Hero = m, s, h
    end
end

local function getMurderer()
    if Murder then
        local p = Players:FindFirstChild(Murder)
        if p and isAlive(p) then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if (bp and bp:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife") then
                return p
            end
        end
    end
    return nil
end

local function getSheriff()
    if Sheriff then
        local p = Players:FindFirstChild(Sheriff)
        if p and isAlive(p) then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) or p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver") then
                return p
            end
        end
    end
    return nil
end

local function getHero()
    if Hero then
        local p = Players:FindFirstChild(Hero)
        if p and isAlive(p) then return p end
    end
    local m = getMurderer()
    local s = getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p ~= m and p ~= s and p.Character and isAlive(p) then
            local bp = p:FindFirstChild("Backpack")
            if (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) or p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver") then
                return p
            end
        end
    end
    return nil
end

local function applyHighlight(player, color)
    local char = player.Character
    if not char then return end
    local h = char:FindFirstChild("AL_MM2_ESP")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "AL_MM2_ESP"
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
    end
    if h.FillColor ~= color then
        h.FillColor = color
        h.OutlineColor = color
    end
end

local function removeHighlight(player)
    local char = player.Character
    if char then
        local h = char:FindFirstChild("AL_MM2_ESP")
        if h then h:Destroy() end
    end
end

local function applyBox(player, color)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local box = hrp:FindFirstChild("AL_MM2_Box") or Instance.new("BoxHandleAdornment")
    box.Name = "AL_MM2_Box"
    box.Size = Vector3.new(4, 5.5, 2.5)
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.65
    box.Adornee = hrp
    box.Parent = hrp
end

local function removeBox(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local box = hrp and hrp:FindFirstChild("AL_MM2_Box")
    if box then box:Destroy() end
end

local function safeTp(cf)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local wasAnchored = hrp.Anchored
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.Anchored = true
    hum.PlatformStand = true
    hrp.CFrame = cf
    char:PivotTo(cf)
    task.wait(0.12)
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.Anchored = wasAnchored
    hum.PlatformStand = false
end

local function flingPlayer(target)
    if not target or target == LP then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    if not char or not hum or not root then return end

    local tChar = target.Character
    if not tChar then return end
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart or tChar:FindFirstChild("HumanoidRootPart")
    local tHead = tChar:FindFirstChild("Head")

    if tHum and tHum.Sit then
        notify(T("Title"), target.Name .. T("SitErr"), 3)
        return
    end

    notify(T("Title"), T("Flinging") .. target.DisplayName, 2)

    local oldPos = root.CFrame

    local function FPos(bp, pos, ang)
        root.CFrame = CFrame.new(bp.Position) * pos * ang
        char:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang)
        root.Velocity = Vector3.new(9e7, 9e8, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(bp)
        local t0 = tick()
        local angle = 0
        repeat
            if root and tHum then
                if bp.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    FPos(bp, CFrame.new(0, 1.5, 0) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                else
                    FPos(bp, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until tick() - t0 > 2
    end

    local oldFPD = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local bv = Instance.new("BodyVelocity")
    bv.Parent = root
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if tRoot then SFBasePart(tRoot)
    elseif tHead then SFBasePart(tHead) end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    repeat
        root.CFrame = oldPos * CFrame.new(0, 0.5, 0)
        char:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
        hum:ChangeState("GettingUp")
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then
                p.Velocity, p.RotVelocity = Vector3.zero, Vector3.zero
            end
        end
        task.wait()
    until (root.Position - oldPos.p).Magnitude < 25

    workspace.FallenPartsDestroyHeight = oldFPD
end

local function grabGun()
    if grabbingGun then return end
    if not isAlive(LP) then return end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end

    local bp = LP:FindFirstChild("Backpack")
    local isMurderer = (char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife")) or (Murder and LP.Name == Murder)
    if isMurderer then return end

    if (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) then return end

    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
    if not gunDrop then return end
    local handle = gunDrop:FindFirstChild("Handle", true) or gunDrop:FindFirstChildOfClass("Part", true) or gunDrop
    if not handle or not handle:IsA("BasePart") then return end

    grabbingGun = true
    local oldCF = hrp.CFrame
    hrp.CFrame = handle.CFrame * CFrame.new(0, -1, 0)
    task.wait(0.15)
    if isAlive(LP) then hrp.CFrame = oldCF end
    grabbingGun = false
end

local function tpLobby()
    local target = CFrame.new(6, 505, -35)
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby then
        local sp = lobby:FindFirstChild("Spawn", true) or lobby:FindFirstChildOfClass("SpawnLocation", true)
        if sp then
            target = (sp:IsA("Model") and sp:GetPivot() or sp.CFrame) * CFrame.new(0, 3, 0)
        end
    end
    safeTp(target)
end

local function tpMap()
    local center = Vector3.new(12, 291, 9040)
    local normal = workspace:FindFirstChild("Normal")
    local best, minD = nil, math.huge

    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local weAreM = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))

    if normal then
        for _, obj in ipairs(normal:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.CanCollide then
                local d = (obj.Position - center).Magnitude
                if d < minD and d < 120 then minD = d; best = obj end
            end
        end
    end

    if best then
        safeTp(CFrame.new(best.Position + Vector3.new(0, 3.5, 0)))
        return
    end

    if not weAreM then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Name ~= Murder and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - Vector3.new(6, 505, -35)).Magnitude
                    if dist > 150 then
                        safeTp(hrp.CFrame * CFrame.new(0, 3, 0))
                        return
                    end
                end
            end
        end
    end

    safeTp(CFrame.new(center + Vector3.new(0, 3.5, 0)))
end

local function fireGun(gun, pos)
    local char = LP.Character
    if not char then return end
    local bp = LP:FindFirstChild("Backpack")
    if gun.Parent == bp then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(gun) end
        task.wait(0.05)
    end
    local origin
    local gs = gun:FindFirstChild("GunServer")
    if gs then
        local att = gs:FindFirstChild("GunRaycastAttachment1") or gs:FindFirstChild("RaycastAttachment")
        if att then origin = att.WorldCFrame end
    end
    if not origin then
        local h = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
        if h and h:IsA("BasePart") then origin = h.CFrame end
    end
    if not origin then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then origin = hrp.CFrame end
    end
    if not origin then return end

    local remote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
    if remote then
        pcall(function()
            remote:FireServer(CFrame.new(origin.Position, pos), CFrame.new(pos))
        end)
    else
        pcall(function()
            if RS:FindFirstChild("ShootGun") then
                RS.ShootGun:InvokeServer(1, pos, pos)
            end
        end)
    end
end

local function toggleNoclip(state)
    if state == nil then state = not Cfg.Utility.Noclip end
    Cfg.Utility.Noclip = state
    saveConfig()
    notify(T("Title"), state and T("NoclipOn") or T("NoclipOff"), 2)
end

local function toggleSpeed(state)
    if state == nil then state = not Cfg.Utility.SpeedGlitch end
    Cfg.Utility.SpeedGlitch = state
    saveConfig()
    notify(T("Title"), state and T("SpeedOn") or T("SpeedOff"), 2)
end

local function toggleInvis(state)
    if state == nil then state = not Cfg.Utility.Invisibility end
    Cfg.Utility.Invisibility = state
    saveConfig()

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if state then
        if not char or not hum or not hrp then return end
        invisOn = true
        savedCFrame = hrp.CFrame
        savedCamSubject = workspace.CurrentCamera.CameraSubject
        savedAutoRotate = hum.AutoRotate

        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.LocalTransparencyModifier = 1
            end
        end

        addConn(char.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
        end))

        if invisOutline then invisOutline:Destroy() end
        invisOutline = Instance.new("Highlight")
        invisOutline.FillTransparency = 1
        invisOutline.OutlineColor = Color3.new(1, 1, 1)
        invisOutline.Parent = char

        char:PivotTo(CFrame.new(-25.95, 84, 3537.55))
        task.wait(0.15)

        invisSeat = Instance.new("Seat")
        invisSeat.Name = "AL_MM2_Chair"
        invisSeat.Anchored = false
        invisSeat.CanCollide = false
        invisSeat.Transparency = 1
        invisSeat.Position = Vector3.new(-25.95, 84, 3537.55)
        invisSeat.Parent = workspace

        workspace.CurrentCamera.CameraSubject = hrp

        local weld = Instance.new("Weld")
        weld.Part0 = invisSeat
        weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        weld.Parent = invisSeat

        task.wait()
        invisSeat.CFrame = savedCFrame

        addConn(RunService.RenderStepped:Connect(function()
            if not invisOn or not invisSeat or not invisSeat.Parent then return end
            if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
                hum.AutoRotate = false
                local cam = workspace.CurrentCamera
                local look = cam.CFrame.LookVector
                look = Vector3.new(look.X, 0, look.Z)
                if look.Magnitude > 0 then
                    invisSeat.CFrame = CFrame.new(invisSeat.Position, invisSeat.Position + look.Unit)
                end
            else
                hum.AutoRotate = true
            end
        end))
    else
        invisOn = false
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
            if hum and savedAutoRotate ~= nil then hum.AutoRotate = savedAutoRotate end
            if savedCamSubject then workspace.CurrentCamera.CameraSubject = savedCamSubject end
        end
        if invisOutline then invisOutline:Destroy() invisOutline = nil end
        if invisSeat then invisSeat:Destroy() invisSeat = nil end
        savedCFrame = nil
        savedCamSubject = nil
        savedAutoRotate = nil
    end
end

local function clearVisuals(char)
    for _, i in ipairs(char:GetChildren()) do
        if i:IsA("Accessory") or i:IsA("Hat") or i:IsA("Shirt") or i:IsA("Pants") or i:IsA("ShirtGraphic") or i:IsA("CharacterMesh") then
            i:Destroy()
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") and d.Name:lower() == "face" then d:Destroy() end
        end
    end
    local bc = char:FindFirstChildOfClass("BodyColors")
    if bc then bc:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "AL_MM2_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 2147483647
gui.Parent = PARENT

local Window = WindUI:CreateWindow({
    Title = "ALWAYSLOSE MM2",
    Icon = "skull",
    Author = "Fox + Jack",
    Folder = "ALWAYSLOSE_MM2",
    Size = UDim2.fromOffset(580, 480),
    Theme = "Dark",
    ToggleKey = Cfg.MenuKey,
})

local VisualsTab = Window:Tab({Title = T("Visuals"), Icon = "eye"})
local CombatTab = Window:Tab({Title = T("Combat"), Icon = "swords"})
local UtilityTab = Window:Tab({Title = T("Utility"), Icon = "tool"})
local MobileTab = Window:Tab({Title = T("Mobile"), Icon = "smartphone"})
local ConfigTab = Window:Tab({Title = T("Configs"), Icon = "settings"})

local bindsGui = Instance.new("ScreenGui")
bindsGui.Name = "AL_MM2_Binds"
bindsGui.ResetOnSpawn = false
bindsGui.IgnoreGuiInset = true
bindsGui.Parent = PARENT

local screenButtons = {}

local buttonDefs = {
    ["Fling Murderer"] = {label = T("FlingM"), fn = function() local m = getMurderer() if m then flingPlayer(m) else notify(T("Title"), T("NoM"), 2) end end},
    ["Fling Sheriff"] = {label = T("FlingS"), fn = function() local s = getSheriff() if s then flingPlayer(s) else notify(T("Title"), T("NoS"), 2) end end},
    ["Fling Hero"] = {label = T("FlingH"), fn = function() local h = getHero() if h then flingPlayer(h) else notify(T("Title"), T("NoH"), 2) end end},
    ["Grab Gun"] = {label = T("GrabGun"), fn = grabGun},
    ["Speed Glitch"] = {label = T("ButSpeed"), fn = function() toggleSpeed() end},
    ["Noclip"] = {label = T("ButNoclip"), fn = function() toggleNoclip() end},
    ["Kill Aura"] = {label = T("ButKA"), fn = function() Cfg.Combat.KillAura = not Cfg.Combat.KillAura saveConfig() end},
    ["Aimlock"] = {label = T("ButAim"), fn = function() Cfg.Combat.Aimlock = not Cfg.Combat.Aimlock saveConfig() end},
    ["Invisibility"] = {label = T("ButInvis"), fn = function() toggleInvis() end},
    ["TP Lobby"] = {label = T("ButTpLobby"), fn = tpLobby},
    ["TP Map"] = {label = T("ButTpMap"), fn = tpMap},
}

local function createButton(name)
    if screenButtons[name] then screenButtons[name]:Destroy() end
    local def = buttonDefs[name]
    if not def then return end

    local size = UDim2.fromOffset(120 * Cfg.Mobile.Scale, 36 * Cfg.Mobile.Scale)
    local pos = Cfg.Mobile.Positions[name] or {X = 20, Y = 100}

    local f = Instance.new("Frame")
    f.Name = "AL_MM2_Btn_" .. name
    f.Size = size
    f.Position = UDim2.fromOffset(pos.X, pos.Y)
    f.BackgroundColor3 = CLR.panel
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.Active = true
    f.Parent = bindsGui
    corner(f, 6)
    stroke(f, CLR.accent, 1.5, 0.3)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = def.label
    btn.TextColor3 = CLR.text
    btn.Font = FB
    btn.TextSize = math.clamp(math.round(12 * Cfg.Mobile.Scale), 8, 22)
    btn.Parent = f

    btn.Activated:Connect(def.fn)

    local drag = false
    local ds, sp

    local function startDrag(input)
        drag = true
        ds = input.Position
        sp = f.Position
    end

    local function endDrag()
        if drag then
            drag = false
            Cfg.Mobile.Positions[name] = {X = f.Position.X.Offset, Y = f.Position.Y.Offset}
            saveConfig()
        end
    end

    f.InputBegan:Connect(function(i)
        if not Cfg.Mobile.Locked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            startDrag(i)
        end
    end)

    btn.InputBegan:Connect(function(i)
        if not Cfg.Mobile.Locked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            startDrag(i)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            f.Position = UDim2.new(0, sp.X.Offset + d.X, 0, sp.Y.Offset + d.Y)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)

    screenButtons[name] = f
end

local function removeButton(name)
    if screenButtons[name] then
        screenButtons[name]:Destroy()
        screenButtons[name] = nil
    end
end

local uiElements = {Visuals = {}, Combat = {}, Utility = {}, Mobile = {}}

local function setToggle(el, v)
    if el and el.Set then pcall(function() el:Set(v) end) end
end

local function setSlider(el, v)
    if el and el.Set then pcall(function() el:Set(v) end) end
end

uiElements.Visuals.ESP_M = VisualsTab:Toggle({Title = T("ESP_M"), Value = Cfg.Visuals.ESP_Murderer, Callback = function(s) Cfg.Visuals.ESP_Murderer = s saveConfig() end})
uiElements.Visuals.ESP_S = VisualsTab:Toggle({Title = T("ESP_S"), Value = Cfg.Visuals.ESP_Sheriff, Callback = function(s) Cfg.Visuals.ESP_Sheriff = s saveConfig() end})
uiElements.Visuals.ESP_H = VisualsTab:Toggle({Title = T("ESP_H"), Value = Cfg.Visuals.ESP_Hero, Callback = function(s) Cfg.Visuals.ESP_Hero = s saveConfig() end})
uiElements.Visuals.ESP_I = VisualsTab:Toggle({Title = T("ESP_I"), Value = Cfg.Visuals.ESP_Innocent, Callback = function(s) Cfg.Visuals.ESP_Innocent = s saveConfig() end})
uiElements.Visuals.ESP_B = VisualsTab:Toggle({Title = T("ESP_B"), Value = Cfg.Visuals.ESP_Boxes, Callback = function(s) Cfg.Visuals.ESP_Boxes = s saveConfig() end})
uiElements.Visuals.ESP_G = VisualsTab:Toggle({Title = T("ESP_G"), Value = Cfg.Visuals.ESP_GunDrop, Callback = function(s) Cfg.Visuals.ESP_GunDrop = s saveConfig() end})

VisualsTab:Toggle({Title = T("NoFog"), Value = Cfg.Visuals.NoFog, Callback = function(s)
    Cfg.Visuals.NoFog = s
    Lighting.FogEnd = s and 9e9 or originalFog
    saveConfig()
end})

VisualsTab:Toggle({Title = T("FullBright"), Value = Cfg.Visuals.FullBright, Callback = function(s)
    Cfg.Visuals.FullBright = s
    if s then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoor
    end
    saveConfig()
end})

VisualsTab:Slider({Title = T("TimeOfDay"), Step = 1, Value = {Min = 0, Max = 24, Default = Cfg.Visuals.TimeOfDay}, Callback = function(v)
    Cfg.Visuals.TimeOfDay = v
    Lighting.TimeOfDay = string.format("%02d:00:00", v)
    saveConfig()
end})

uiElements.Combat.Aim = CombatTab:Toggle({Title = T("Aimlock"), Value = Cfg.Combat.Aimlock, Callback = function(s) Cfg.Combat.Aimlock = s saveConfig() end})
uiElements.Combat.AutoShoot = CombatTab:Toggle({Title = T("AutoShoot"), Value = Cfg.Combat.AutoShoot, Callback = function(s) Cfg.Combat.AutoShoot = s saveConfig() end})
uiElements.Combat.KA = CombatTab:Toggle({Title = T("KillAura"), Value = Cfg.Combat.KillAura, Callback = function(s) Cfg.Combat.KillAura = s saveConfig() end})
CombatTab:Slider({Title = T("KillAuraRange"), Step = 5, Value = {Min = 10, Max = 50, Default = Cfg.Combat.KillAuraRange}, Callback = function(v) Cfg.Combat.KillAuraRange = v saveConfig() end})
uiElements.Combat.Dodge = CombatTab:Toggle({Title = T("AutoDodge"), Value = Cfg.Combat.AutoDodgeKnife, Callback = function(s) Cfg.Combat.AutoDodgeKnife = s saveConfig() end})

CombatTab:Button({Title = T("FlingM"), Callback = function()
    local m = getMurderer()
    if m then flingPlayer(m) else notify(T("Title"), T("NoM"), 2) end
end})
CombatTab:Button({Title = T("FlingS"), Callback = function()
    local s = getSheriff()
    if s then flingPlayer(s) else notify(T("Title"), T("NoS"), 2) end
end})
CombatTab:Button({Title = T("FlingH"), Callback = function()
    local h = getHero()
    if h then flingPlayer(h) else notify(T("Title"), T("NoH"), 2) end
end})

uiElements.Utility.Grab = UtilityTab:Toggle({Title = T("AutoGrab"), Value = Cfg.Utility.AutoGrabGun, Callback = function(s) Cfg.Utility.AutoGrabGun = s saveConfig() end})
uiElements.Utility.Speed = UtilityTab:Toggle({Title = T("SpeedGlitch"), Value = Cfg.Utility.SpeedGlitch, Callback = function(s) toggleSpeed(s) end})
UtilityTab:Slider({Title = T("SpeedValue"), Step = 5, Value = {Min = 15, Max = 100, Default = Cfg.Utility.SpeedValue}, Callback = function(v) Cfg.Utility.SpeedValue = v saveConfig() end})
uiElements.Utility.Noclip = UtilityTab:Toggle({Title = T("Noclip"), Value = Cfg.Utility.Noclip, Callback = function(s) toggleNoclip(s) end})
uiElements.Utility.Invis = UtilityTab:Toggle({Title = T("Invis"), Value = Cfg.Utility.Invisibility, Callback = function(s) toggleInvis(s) end})
uiElements.Utility.Farm = UtilityTab:Toggle({Title = T("AutoFarm"), Value = Cfg.Utility.AutoFarmCoins, Callback = function(s) Cfg.Utility.AutoFarmCoins = s saveConfig() end})

UtilityTab:Button({Title = T("TP_Lobby"), Callback = tpLobby})
UtilityTab:Button({Title = T("TP_Map"), Callback = tpMap})

uiElements.Mobile.Lock = MobileTab:Toggle({Title = T("LockMobile"), Value = Cfg.Mobile.Locked, Callback = function(s) Cfg.Mobile.Locked = s saveConfig() end})
MobileTab:Slider({Title = T("MobileScale"), Step = 0.1, Value = {Min = 0.5, Max = 2, Default = Cfg.Mobile.Scale}, Callback = function(v)
    Cfg.Mobile.Scale = v
    saveConfig()
    for name, f in pairs(screenButtons) do
        f.Size = UDim2.fromOffset(120 * v, 36 * v)
        local btn = f:FindFirstChildOfClass("TextButton")
        if btn then btn.TextSize = math.clamp(math.round(12 * v), 8, 22) end
    end
end})

for name, _ in pairs(buttonDefs) do
    MobileTab:Toggle({
        Title = name,
        Value = Cfg.Mobile.Buttons[name],
        Callback = function(s)
            Cfg.Mobile.Buttons[name] = s
            saveConfig()
            if s then createButton(name) else removeButton(name) end
        end
    })
end

ConfigTab:Button({Title = T("Save"), Callback = function()
    saveConfig()
    notify(T("Title"), T("Saved"), 2)
end})
ConfigTab:Button({Title = T("Load"), Callback = function()
    loadConfig()
    notify(T("Title"), T("LoadedConf"), 2)
end})
ConfigTab:Button({Title = T("Reset"), Callback = function()
    for k, v in pairs({ESP_Murderer = false, ESP_Sheriff = false, ESP_Hero = false, ESP_Innocent = false, ESP_Boxes = false, ESP_GunDrop = false, NoFog = false, FullBright = false, TimeOfDay = 14}) do
        Cfg.Visuals[k] = v
    end
    for k, v in pairs({Aimlock = false, AutoShoot = false, KillAura = false, KillAuraRange = 25, AutoDodgeKnife = false}) do
        Cfg.Combat[k] = v
    end
    for k, v in pairs({AutoGrabGun = false, SpeedGlitch = false, SpeedValue = 45, Noclip = false, AntiFling = false, AutoFarmCoins = false, Invisibility = false}) do
        Cfg.Utility[k] = v
    end
    saveConfig()
    notify(T("Title"), T("ResetConf"), 2)
end})

ConfigTab:Button({Title = "Русский", Callback = function()
    Cfg.Language = "ru"
    saveConfig()
    notify(T("Title"), "Перезапусти скрипт", 3)
end})
ConfigTab:Button({Title = "English", Callback = function()
    Cfg.Language = "en"
    saveConfig()
    notify(T("Title"), "Restart script", 3)
end})

task.spawn(function()
    while getgenv().AL_MM2_Loaded do
        pcall(getRole)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local isM = (p.Name == Murder) or p.Character:FindFirstChild("Knife")
                    local isS = (p.Name == Sheriff)
                    local isH = (p.Name == Hero)
                    local alive = isAlive(p)
                    local color = Color3.fromRGB(0, 255, 0)
                    local enabled = false

                    if isM and Cfg.Visuals.ESP_Murderer then enabled = true; color = Color3.fromRGB(255, 0, 0)
                    elseif isS and Cfg.Visuals.ESP_Sheriff then enabled = true; color = Color3.fromRGB(0, 100, 255)
                    elseif isH and Cfg.Visuals.ESP_Hero then enabled = true; color = Color3.fromRGB(255, 220, 0)
                    elseif not isM and not isS and not isH and Cfg.Visuals.ESP_Innocent then enabled = true; color = Color3.fromRGB(0, 255, 0)
                    end

                    if enabled and alive then
                        applyHighlight(p, color)
                        if Cfg.Visuals.ESP_Boxes then applyBox(p, color) end
                    else
                        removeHighlight(p)
                        removeBox(p)
                    end
                end
            end
        end)

        pcall(function()
            local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
            local handle = gunDrop and (gunDrop:FindFirstChild("Handle", true) or gunDrop:FindFirstChildOfClass("Part", true) or gunDrop)
            if handle then
                local h = handle:FindFirstChild("AL_MM2_GunESP")
                if Cfg.Visuals.ESP_GunDrop then
                    if not h then
                        h = Instance.new("Highlight")
                        h.Name = "AL_MM2_GunESP"
                        h.FillColor = Color3.fromRGB(0, 255, 100)
                        h.OutlineColor = Color3.fromRGB(0, 255, 100)
                        h.FillTransparency = 0.5
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = handle
                    end
                elseif h then
                    h:Destroy()
                end
            end
        end)

        task.wait(0.15)
    end
end)

addBind("AL_MM2_Aim", Enum.RenderPriority.Camera.Value + 1, function()
    if not Cfg.Combat.Aimlock then return end
    local m = getMurderer()
    if m and m.Character then
        local head = m.Character:FindFirstChild("Head")
        if head then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, head.Position)
        end
    end
end)

addConn(RunService.Heartbeat:Connect(function()
    pcall(function()
        if Cfg.Combat.AutoShoot then
            local m = getMurderer()
            if m and m.Character then
                local hrp = m.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local char = LP.Character
                    local gun = char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))
                    local bp = LP:FindFirstChild("Backpack")
                    gun = gun or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
                    if gun then fireGun(gun, hrp.Position) end
                end
            end
        end
    end)
end))

addConn(RunService.Heartbeat:Connect(function()
    pcall(function()
        if Cfg.Combat.KillAura then
            local char = LP.Character
            local bp = LP:FindFirstChild("Backpack")
            local knife = char and char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
            if knife and char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if knife.Parent == bp then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(knife) end
                    end
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v ~= LP and v.Character then
                            local vhrp = v.Character:FindFirstChild("HumanoidRootPart")
                            local vhum = v.Character:FindFirstChildOfClass("Humanoid")
                            if vhrp and vhum and vhum.Health > 0 then
                                local d = (hrp.Position - vhrp.Position).Magnitude
                                if d <= Cfg.Combat.KillAuraRange then
                                    knife:Activate()
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end))

addConn(RunService.Stepped:Connect(function()
    pcall(function()
        if not Cfg.Utility.Noclip then return end
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end))

addConn(RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        if not Cfg.Utility.SpeedGlitch then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hum and hum.MoveDirection.Magnitude > 0 then
            local v = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z).Unit
            hrp.CFrame = hrp.CFrame + (v * (Cfg.Utility.SpeedValue * dt))
        end
    end)
end))

addConn(RunService.Heartbeat:Connect(function()
    pcall(function()
        if not Cfg.Combat.AutoDodgeKnife then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "ThrownKnife" and obj:IsA("BasePart") then
                local d = (hrp.Position - obj.Position).Magnitude
                if d < 22 and (tick() - lastDodge > 0.6) then
                    lastDodge = tick()
                    local tgt = hrp.CFrame + (hrp.CFrame.RightVector * 14)
                    local wasA = hrp.Anchored
                    hrp.Anchored = true
                    hrp.CFrame = tgt
                    char:PivotTo(tgt)
                    task.wait(0.04)
                    hrp.Anchored = wasA
                    break
                end
            end
        end
    end)
end))

task.spawn(function()
    while getgenv().AL_MM2_Loaded do
        pcall(function()
            if Cfg.Utility.AutoGrabGun and isAlive(LP) then
                local char = LP.Character
                local bp = LP:FindFirstChild("Backpack")
                local isM = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife")) or (Murder and LP.Name == Murder)
                if not isM then
                    if workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true) then
                        grabGun()
                    end
                end
            end
        end)
        task.wait(1.2)
    end
end)

task.spawn(function()
    while getgenv().AL_MM2_Loaded do
        pcall(function()
            if Cfg.Utility.AutoFarmCoins then
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local nearest, minD = nil, math.huge
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name == "Coin_Highlight" or v.Name == "CoinContainer" or v.Name == "Coin") then
                            local d = (v.Position - hrp.Position).Magnitude
                            if d < minD then minD = d; nearest = v end
                        end
                    end
                    if nearest then
                        local conn
                        conn = RunService.Heartbeat:Connect(function(dt)
                            if not Cfg.Utility.AutoFarmCoins or not nearest.Parent or not hrp.Parent then
                                if conn then conn:Disconnect() end
                                return
                            end
                            local dir = (nearest.Position - hrp.Position).Unit
                            hrp.CFrame = hrp.CFrame + (dir * 22 * dt)
                            if (nearest.Position - hrp.Position).Magnitude < 4 then
                                if conn then conn:Disconnect() end
                            end
                        end)
                        local t = 0
                        while nearest and nearest.Parent and Cfg.Utility.AutoFarmCoins and t < 100 do
                            if (nearest.Position - hrp.Position).Magnitude < 4 then break end
                            task.wait(0.05)
                            t = t + 1
                        end
                        if conn then conn:Disconnect() end
                    end
                end
            end
        end)
        task.wait(0.3)
    end
end)

addConn(LP.CharacterAdded:Connect(function()
    if invisOn then toggleInvis(false) end
end))

addConn(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Cfg.Combat.AimlockKey then
        Cfg.Combat.Aimlock = not Cfg.Combat.Aimlock
    elseif i.KeyCode == Enum.KeyCode.F then
        local m = getMurderer() if m then flingPlayer(m) end
    elseif i.KeyCode == Enum.KeyCode.G then
        local s = getSheriff() if s then flingPlayer(s) end
    elseif i.KeyCode == Enum.KeyCode.T then
        grabGun()
    elseif i.KeyCode == Enum.KeyCode.C then
        toggleSpeed()
    elseif i.KeyCode == Enum.KeyCode.V then
        toggleNoclip()
    elseif i.KeyCode == Enum.KeyCode.Y then
        toggleInvis()
    end
end))

task.wait(0.5)

setToggle(uiElements.Visuals.ESP_M, Cfg.Visuals.ESP_Murderer)
setToggle(uiElements.Visuals.ESP_S, Cfg.Visuals.ESP_Sheriff)
setToggle(uiElements.Visuals.ESP_H, Cfg.Visuals.ESP_Hero)
setToggle(uiElements.Visuals.ESP_I, Cfg.Visuals.ESP_Innocent)
setToggle(uiElements.Visuals.ESP_B, Cfg.Visuals.ESP_Boxes)
setToggle(uiElements.Visuals.ESP_G, Cfg.Visuals.ESP_GunDrop)
setToggle(uiElements.Combat.Aim, Cfg.Combat.Aimlock)
setToggle(uiElements.Combat.AutoShoot, Cfg.Combat.AutoShoot)
setToggle(uiElements.Combat.KA, Cfg.Combat.KillAura)
setToggle(uiElements.Combat.Dodge, Cfg.Combat.AutoDodgeKnife)
setToggle(uiElements.Utility.Grab, Cfg.Utility.AutoGrabGun)
setToggle(uiElements.Utility.Speed, Cfg.Utility.SpeedGlitch)
setToggle(uiElements.Utility.Noclip, Cfg.Utility.Noclip)
setToggle(uiElements.Utility.Invis, Cfg.Utility.Invisibility)
setToggle(uiElements.Utility.Farm, Cfg.Utility.AutoFarmCoins)

for name, _ in pairs(buttonDefs) do
    if Cfg.Mobile.Buttons[name] then createButton(name) end
end

notify(T("Title"), T("Loaded"), 4)
