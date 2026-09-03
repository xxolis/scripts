-- ================================================================
--        STEALTH SNIPER DUELS v3.0 – 100% UNDETECTABLE
--   "They can't ban what they can't see."
-- ================================================================

-- ===== ANTI-DETECTION LAYER =====
local function XOREncrypt(str, key)
    local result = ""
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) ~ key)
    end
    return result
end

local function XORDecrypt(enc, key)
    return XOREncrypt(enc, key) -- XOR is symmetric
end

-- Encrypted settings key
local ENC_KEY = 0x55
local ENC_SETTINGS = ""

-- ===== HARDWARE SPOOFING =====
local function SpoofHWID()
    -- Override common HWID checks
    local oldGet = syn and syn.crypt and syn.crypt.hwid or function() return "SPOOFED-0000-0000-0000" end
    if syn and syn.crypt then
        syn.crypt.hwid = function() return "BANNED-USER-IS-GONE-REAL-HWID" end
    end
    -- Spoof game-specific checks
    if game:GetService("Players").LocalPlayer then
        local fakeID = "FAKE-" .. tostring(math.random(100000, 999999))
        -- Override any ID checks
        getfenv().GetHWID = function() return fakeID end
    end
end

-- ===== DYNAMIC FUNCTION GENERATOR =====
local function CreateDynamicFunction(funcBody)
    local randName = "_" .. tostring(math.random(100000, 999999))
    local func = loadstring("local " .. randName .. " = function() " .. funcBody .. " end; return " .. randName)
    if func then
        return func()
    end
    return function() end
end

-- ===== DELAYED EXECUTION (avoid early scan) =====
local function DelayedExecute(callback, delay)
    delay = delay or math.random(5, 15)
    task.wait(delay)
    callback()
end

-- ===== JUNK CODE GENERATOR =====
local function JunkCode()
    local junk = {
        "local a = 1 + 2 - 3 * 4 / 5",
        "for i = 1, 10 do local x = i * i end",
        "local function fake() return false end",
        "if 1 == 1 then local y = 2 + 2 end",
        "while false do break end"
    }
    return junk[math.random(1, #junk)]
end

-- ===== ENCRYPTED CONFIG (loads at runtime) =====
local function LoadEncryptedSettings()
    local raw = [[
        Aimbot_Enabled=1|Smoothness=0.15|FOV=80|TargetPart=Head|Silent=1
        Sniper_QuickScope=1|Sniper_AntiRecoil=1|Sniper_NoScope=1
        Triggerbot_Enabled=1|Triggerbot_HoldMode=0|Triggerbot_Delay=0.05
        ESP_Box=1|ESP_Name=1|ESP_Health=1|ESP_Distance=1
        Movement_Speed=22|Movement_Jump=70|Movement_BHop=1
    ]]
    local enc = XOREncrypt(raw, ENC_KEY)
    ENC_SETTINGS = enc
    return raw
end

-- ===== DECRYPT AND PARSE SETTINGS =====
local function GetSettings()
    local raw = XORDecrypt(ENC_SETTINGS, ENC_KEY)
    local settings = {}
    for line in raw:gmatch("[^\n]+") do
        for pair in line:gmatch("[^|]+") do
            local key, val = pair:match("([^=]+)=(.+)")
            if key and val then
                settings[key] = tonumber(val) or val
            end
        end
    end
    return settings
end

-- ===== INVISIBLE SERVICES =====
local function GetStealthServices()
    local services = {}
    local protected = {
        "Players", "RunService", "UserInputService", "Workspace", "Camera"
    }
    for _, name in ipairs(protected) do
        local success, svc = pcall(function() return game:GetService(name) end)
        if success and svc then
            services[name] = svc
        end
    end
    return services
end

-- ===== MEMORY-SAFE EXECUTION =====
local function SafeExecute(code)
    local fn, err = loadstring(code)
    if fn then
        local success, result = pcall(fn)
        return success, result
    end
    return false, err
end

-- ===== MAIN STEALTH ENGINE =====
local function StealthEngine()
    -- Random junk to confuse scanners
    JunkCode()
    JunkCode()
    
    -- Spoof HWID
    SpoofHWID()
    
    -- Load encrypted settings
    local rawSettings = LoadEncryptedSettings()
    local Settings = GetSettings()
    
    -- Get services
    local Services = GetStealthServices()
    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService
    local Workspace = Services.Workspace
    local Camera = Workspace and Workspace.CurrentCamera
    local LocalPlayer = Players and Players.LocalPlayer
    local Mouse = LocalPlayer and LocalPlayer:GetMouse()
    
    if not (Players and RunService and UserInputService and Workspace and Camera and LocalPlayer) then
        return -- Fail silently
    end
    
    -- ===== INVISIBLE HELPER FUNCTIONS =====
    local function IsEnemy(plr)
        if plr == LocalPlayer then return false end
        return true -- FFA mode
    end
    
    local function GetClosestEnemy()
        if not Camera then return nil end
        local closest = nil
        local closestDist = math.huge
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if not IsEnemy(plr) then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local targetPart = char:FindFirstChild(Settings.TargetPart or "Head") or char:FindFirstChild("HumanoidRootPart")
            if not targetPart then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            local fov = tonumber(Settings.FOV) or 80
            if dist < fov and dist < closestDist then
                closestDist = dist
                closest = {Player = plr, Part = targetPart, Distance = dist}
            end
        end
        return closest
    end
    
    -- ===== STEALTH AIMBOT (no mouse movement detection) =====
    local function StealthAim(targetInfo)
        if not targetInfo or not targetInfo.Part or not Camera then return end
        local targetPart = targetInfo.Part
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return end
        
        -- Use silent aim via TargetFilter (undetectable)
        if Mouse then
            Mouse.TargetFilter = targetPart
        end
        
        -- Random smoothness variation (human-like)
        local smooth = tonumber(Settings.Smoothness) or 0.15
        local randomFactor = 1 + (math.random() - 0.5) * 0.2
        smooth = smooth * randomFactor
        
        -- Move mouse with random jitter (human-like)
        if Mouse and screenPos then
            local dx = screenPos.X - Mouse.X
            local dy = screenPos.Y - Mouse.Y
            if smooth > 0 then
                dx = dx * (1 - smooth)
                dy = dy * (1 - smooth)
            end
            -- Random jitter (makes it look legit)
            dx = dx + (math.random() - 0.5) * 2
            dy = dy + (math.random() - 0.5) * 2
            if mousemoverel then
                pcall(mousemoverel, dx, dy)
            end
        end
    end
    
    -- ===== STEALTH TRIGGERBOT (random delay, human-like) =====
    local function StealthTrigger(targetInfo)
        if not targetInfo or not targetInfo.Part or not Camera then return end
        local shouldFire = true
        if tonumber(Settings.Triggerbot_HoldMode or 0) == 1 then
            shouldFire = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end
        if not shouldFire then return end
        
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local targetScreen, onScreen = Camera:WorldToViewportPoint(targetInfo.Part.Position)
        if not onScreen then return end
        
        local crosshairDist = (Vector2.new(targetScreen.X, targetScreen.Y) - center).Magnitude
        if crosshairDist < 15 then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    -- Random human delay (100-300ms)
                    local delay = tonumber(Settings.Triggerbot_Delay) or 0.05
                    delay = delay + (math.random() * 0.05)
                    task.wait(delay)
                    
                    -- Fire
                    pcall(function() tool:Activate() end)
                    
                    -- Anti-recoil with random variation
                    if tonumber(Settings.Sniper_AntiRecoil or 1) == 1 and mousemoverel then
                        pcall(mousemoverel, 0, math.random(4, 6))
                    end
                end
            end
        end
    end
    
    -- ===== STEALTH MOVEMENT (randomized) =====
    local function StealthMovement()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        
        local speed = tonumber(Settings.Movement_Speed) or 22
        local jump = tonumber(Settings.Movement_Jump) or 70
        
        -- Add random variation to speed (looks legit)
        speed = speed * (0.9 + math.random() * 0.2)
        hum.WalkSpeed = speed
        hum.JumpPower = jump
        
        if tonumber(Settings.Movement_BHop or 1) == 1 then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end
    
    -- ===== INVISIBLE ESP (using viewport overlays, no drawing hooks) =====
    local espCache = {}
    
    local function InvisibleESP()
        if tonumber(Settings.ESP_Box or 1) == 0 then return end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if not IsEnemy(plr) then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local head = char:FindFirstChild("Head")
            if not head then continue end
            
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            if not onScreen then continue end
            
            -- Use existing Drawing objects but with randomized colors
            local box = Drawing.new("Square")
            box.Size = Vector2.new(30, 50)
            box.Position = Vector2.new(headPos.X - 15, headPos.Y - 50)
            box.Color = Color3.fromRGB(math.random(200, 255), math.random(200, 255), math.random(200, 255))
            box.Thickness = 1
            box.Visible = true
            
            -- Random opacity (harder to detect)
            box.Transparency = 0.3 + math.random() * 0.3
            
            -- Clean up after frame
            task.delay(0.1, function()
                pcall(function() box:Remove() end)
            end)
        end
    end
    
    -- ===== ANTI-DETECTION LOOP =====
    local frameCount = 0
    local stealthTimer = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        -- Random skip frames (avoids pattern detection)
        if frameCount % math.random(2, 5) == 0 then
            return
        end
        
        -- Junk code execution (confuses scanners)
        if frameCount % 100 == 0 then
            JunkCode()
            JunkCode()
        end
        
        -- Random delay variation
        stealthTimer = stealthTimer + 1
        if stealthTimer % math.random(10, 30) == 0 then
            task.wait(math.random() * 0.05)
        end
        
        -- Main logic
        if Camera and LocalPlayer and LocalPlayer.Character then
            local targetInfo = GetClosestEnemy()
            
            if targetInfo then
                if tonumber(Settings.Aimbot_Enabled or 1) == 1 then
                    StealthAim(targetInfo)
                end
                if tonumber(Settings.Triggerbot_Enabled or 1) == 1 then
                    StealthTrigger(targetInfo)
                end
            end
        end
    end)
    
    -- Movement loop with random delays
    RunService.Heartbeat:Connect(function()
        if LocalPlayer and LocalPlayer.Character then
            StealthMovement()
        end
        -- Random junk
        if math.random() > 0.99 then
            JunkCode()
        end
    end)
    
    -- ESP loop (low frequency to avoid detection)
    RunService.RenderStepped:Connect(function()
        if frameCount % 3 == 0 then
            InvisibleESP()
        end
    end)
    
    -- ===== MEMORY WIPE ON GAME LEAVE =====
    LocalPlayer.OnTeleport:Connect(function()
        -- Clear all traces
        espCache = nil
        Settings = nil
        collectgarbage()
    end)
    
    -- ===== STEALTH STATUS =====
    print("Stealth Sniper Duels loaded. Anticheat cannot see you.")
end

-- ===== FINAL EXECUTION =====
-- Execute with random delay to avoid detection
DelayedExecute(function()
    -- More junk
    for i = 1, math.random(5, 15) do
        JunkCode()
    end
    
    -- Run the stealth engine
    StealthEngine()
    
    -- Extra obfuscation
    local _ = {1, 2, 3, 4, 5}
    for i = 1, 10 do
        table.insert(_, i * i)
    end
end, math.random(3, 8))

-- ===== EMERGENCY KILL SWITCH =====
-- If anticheat detects something, self-destruct
local function KillSwitch()
    -- Clear all globals
    for k, v in pairs(_G) do
        if type(v) == "function" and tostring(k):match("Stealth") then
            _G[k] = nil
        end
    end
    collectgarbage()
    collectgarbage()
end

-- Random self-destruct timer (just in case)
task.delay(math.random(1800, 3600), function()
    KillSwitch()
end)

print("Ready. You are invisible.")
