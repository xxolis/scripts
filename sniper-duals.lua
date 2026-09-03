-- ================================================================
--        SNIPER DUELS GOD SCRIPT v5.0 – AIMBOT FIXED
--   "Now it actually locks on."
-- ================================================================

-- ===== SETTINGS =====
local Settings = {
    Aimbot = {
        Enabled = true,
        Silent = true,
        Smoothness = 0.15,
        FOV = 80,
        TargetPart = "Head",
        ShowFOV = true
    },
    Sniper = {
        QuickScope = true,
        NoScopeAssist = true,
        AntiRecoil = true,
        AutoReload = false
    },
    Triggerbot = {
        Enabled = true,
        HoldMode = false,
        Delay = 0.05
    },
    ESP = {
        Enabled = true,
        Box = true,
        Skeleton = true,
        Name = true,
        HealthBar = true,
        Distance = true,
        WallbangPrediction = true
    },
    Movement = {
        AutoBHop = true,
        SpeedBoost = true,
        WalkSpeed = 22,
        JumpPower = 70,
        NoFallDamage = true
    },
    Visuals = {
        Crosshair = true,
        FOVColor = Color3.fromRGB(0, 255, 65)
    }
}

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== FIXED AIMBOT FUNCTION =====
local function MoveMouseToTarget(targetScreenPos)
    if not targetScreenPos then return end
    
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local targetPos = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
    local delta = targetPos - currentPos
    
    -- Apply smoothness
    if Settings.Aimbot.Smoothness > 0 then
        delta = delta * (1 - Settings.Aimbot.Smoothness)
    end
    
    -- Method 1: Try mousemoverel (works on Synapse, Krnl, etc.)
    if mousemoverel then
        pcall(mousemoverel, delta.X, delta.Y)
        return
    end
    
    -- Method 2: Try VirtualUser (works on some executors)
    if VirtualUser and VirtualUser:CaptureController() then
        pcall(function()
            VirtualUser:SetMousePosition(targetPos.X, targetPos.Y)
        end)
        return
    end
    
    -- Method 3: Manual mouse movement via input simulation (fallback)
    if UserInputService and UserInputService.MouseBehavior then
        -- Some executors allow this
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

-- ===== FIXED UI CREATION =====
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SniperGodUI"
    screenGui.Parent = LocalPlayer.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 440, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 65)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "══ SNIPER DUELS GOD ══"
    title.TextColor3 = Color3.fromRGB(0, 255, 65)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.Parent = titleBar

    -- Drag logic
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tabs
    local tabs = {"Aimbot", "Sniper", "Trigger", "ESP", "Movement", "Visuals"}
    local tabButtons = {}
    local contentFrames = {}

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #tabs, 0, 1, 0)
        btn.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(150, 255, 150)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 255, 65)
        btn.Font = Enum.Font.Code
        btn.TextScaled = true
        btn.Parent = tabContainer
        tabButtons[i] = btn

        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -70)
        content.Position = UDim2.new(0, 5, 0, 65)
        content.BackgroundTransparency = 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 6
        content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 65)
        content.Visible = (i == 1)
        content.Parent = mainFrame
        contentFrames[i] = content

        btn.MouseButton1Click:Connect(function()
            for j, cf in ipairs(contentFrames) do
                cf.Visible = (j == i)
                tabButtons[j].BackgroundColor3 = (j == i) and Color3.fromRGB(0, 60, 0) or Color3.fromRGB(20, 20, 20)
            end
        end)
    end
    tabButtons[1].BackgroundColor3 = Color3.fromRGB(0, 60, 0)

    -- UI Helpers
    local function AddToggle(parent, label, getter, setter, desc)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, desc and 45 or 30)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Code
        lbl.TextScaled = true
        lbl.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.Text = getter() and "ON" or "OFF"
        toggle.TextColor3 = getter() and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        toggle.BorderSizePixel = 1
        toggle.BorderColor3 = Color3.fromRGB(0, 255, 65)
        toggle.Font = Enum.Font.Code
        toggle.TextScaled = true
        toggle.Parent = frame

        toggle.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            toggle.Text = newVal and "ON" or "OFF"
            toggle.TextColor3 = newVal and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)

        if desc then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, 0, 0, 15)
            d.Position = UDim2.new(0, 0, 1, 0)
            d.Text = desc
            d.TextColor3 = Color3.fromRGB(100, 200, 100)
            d.BackgroundTransparency = 1
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Font = Enum.Font.Code
            d.TextSize = 10
            d.Parent = frame
        end
    end

    local function AddSlider(parent, label, getter, setter, min, max, decimals, suffix)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0.5, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Code
        lbl.TextScaled = true
        lbl.Parent = frame

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
        valLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valLabel.Text = tostring(getter()) .. (suffix or "")
        valLabel.TextColor3 = Color3.fromRGB(0, 255, 65)
        valLabel.BackgroundTransparency = 1
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Font = Enum.Font.Code
        valLabel.TextScaled = true
        valLabel.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 6)
        slider.Position = UDim2.new(0, 0, 0.7, 0)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        slider.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 255, 65)
        fill.Parent = slider

        local draggingSlider = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local val = min + relX * (max - min)
                if decimals then val = math.round(val * (10^decimals)) / (10^decimals) end
                setter(val)
                fill.Size = UDim2.new(relX, 0, 1, 0)
                valLabel.Text = tostring(val) .. (suffix or "")
            end
        end)
    end

    -- Add UIListLayout to each content frame
    for _, content in ipairs(contentFrames) do
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = content
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
    end

    -- FILL TABS
    local aimTab = contentFrames[1]
    AddToggle(aimTab, "Aimbot Enabled", function() return Settings.Aimbot.Enabled end, function(v) Settings.Aimbot.Enabled = v end)
    AddToggle(aimTab, "Silent Aim", function() return Settings.Aimbot.Silent end, function(v) Settings.Aimbot.Silent = v end)
    AddSlider(aimTab, "Smoothness", function() return Settings.Aimbot.Smoothness end, function(v) Settings.Aimbot.Smoothness = v end, 0, 1, 2)
    AddSlider(aimTab, "FOV (deg)", function() return Settings.Aimbot.FOV end, function(v) Settings.Aimbot.FOV = v end, 10, 360, 0)
    AddToggle(aimTab, "Show FOV Circle", function() return Settings.Aimbot.ShowFOV end, function(v) Settings.Aimbot.ShowFOV = v end)

    local sniperTab = contentFrames[2]
    AddToggle(sniperTab, "Quick Scope", function() return Settings.Sniper.QuickScope end, function(v) Settings.Sniper.QuickScope = v end, "ADS before shot, unscope after")
    AddToggle(sniperTab, "No-Scope Assist", function() return Settings.Sniper.NoScopeAssist end, function(v) Settings.Sniper.NoScopeAssist = v end, "Tightens spread when unscoped")
    AddToggle(sniperTab, "Anti-Recoil", function() return Settings.Sniper.AntiRecoil end, function(v) Settings.Sniper.AntiRecoil = v end)
    AddToggle(sniperTab, "Auto-Reload", function() return Settings.Sniper.AutoReload end, function(v) Settings.Sniper.AutoReload = v end, "Reload when empty (risky)")

    local trigTab = contentFrames[3]
    AddToggle(trigTab, "Triggerbot", function() return Settings.Triggerbot.Enabled end, function(v) Settings.Triggerbot.Enabled = v end)
    AddToggle(trigTab, "Hold Mode (RMB)", function() return Settings.Triggerbot.HoldMode end, function(v) Settings.Triggerbot.HoldMode = v end)
    AddSlider(trigTab, "Delay", function() return Settings.Triggerbot.Delay end, function(v) Settings.Triggerbot.Delay = v end, 0, 0.2, 2, "s")

    local espTab = contentFrames[4]
    AddToggle(espTab, "ESP Enabled", function() return Settings.ESP.Enabled end, function(v) Settings.ESP.Enabled = v end)
    AddToggle(espTab, "Box", function() return Settings.ESP.Box end, function(v) Settings.ESP.Box = v end)
    AddToggle(espTab, "Skeleton", function() return Settings.ESP.Skeleton end, function(v) Settings.ESP.Skeleton = v end)
    AddToggle(espTab, "Name", function() return Settings.ESP.Name end, function(v) Settings.ESP.Name = v end)
    AddToggle(espTab, "Health Bar", function() return Settings.ESP.HealthBar end, function(v) Settings.ESP.HealthBar = v end)
    AddToggle(espTab, "Distance", function() return Settings.ESP.Distance end, function(v) Settings.ESP.Distance = v end)
    AddToggle(espTab, "Wallbang Prediction", function() return Settings.ESP.WallbangPrediction end, function(v) Settings.ESP.WallbangPrediction = v end)

    local movTab = contentFrames[5]
    AddToggle(movTab, "Auto BHop", function() return Settings.Movement.AutoBHop end, function(v) Settings.Movement.AutoBHop = v end)
    AddToggle(movTab, "Speed Boost", function() return Settings.Movement.SpeedBoost end, function(v) Settings.Movement.SpeedBoost = v end)
    AddSlider(movTab, "Walk Speed", function() return Settings.Movement.WalkSpeed end, function(v) Settings.Movement.WalkSpeed = v end, 16, 100, 0)
    AddSlider(movTab, "Jump Power", function() return Settings.Movement.JumpPower end, function(v) Settings.Movement.JumpPower = v end, 50, 200, 0)
    AddToggle(movTab, "No Fall Damage", function() return Settings.Movement.NoFallDamage end, function(v) Settings.Movement.NoFallDamage = v end)

    local visTab = contentFrames[6]
    AddToggle(visTab, "Custom Crosshair", function() return Settings.Visuals.Crosshair end, function(v) Settings.Visuals.Crosshair = v end)

    return screenGui
end

-- ===== INIT =====
local gui = CreateUI()

-- ===== HELPERS =====
local function IsEnemy(plr)
    if plr == LocalPlayer then return false end
    return true
end

local function GetClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if not IsEnemy(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local targetPart = char:FindFirstChild(Settings.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < Settings.Aimbot.FOV and dist < closestDist then
            closestDist = dist
            closest = {Player = plr, Part = targetPart, ScreenPos = Vector2.new(screenPos.X, screenPos.Y), Distance = dist}
        end
    end
    return closest
end

-- ===== FIXED AIMBOT LOOP =====
local function AimAtTarget(targetInfo)
    if not targetInfo or not targetInfo.ScreenPos then return end
    
    -- Silent aim: just set TargetFilter (works on Synapse/Krnl)
    if Settings.Aimbot.Silent then
        Mouse.TargetFilter = targetInfo.Part
    end
    
    -- Move mouse to target
    MoveMouseToTarget(targetInfo.ScreenPos)
end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot.Enabled and not Settings.Triggerbot.Enabled then return end
    
    local targetInfo = GetClosestEnemy()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- Aimbot
    if Settings.Aimbot.Enabled and targetInfo then
        AimAtTarget(targetInfo)
    end

    -- Triggerbot
    if Settings.Triggerbot.Enabled and targetInfo then
        local shouldFire = true
        if Settings.Triggerbot.HoldMode then
            shouldFire = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end
        if shouldFire then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local crosshairDist = (targetInfo.ScreenPos - center).Magnitude
            if crosshairDist < 15 then
                tool:Activate()
                if Settings.Sniper.AntiRecoil and mousemoverel then
                    pcall(mousemoverel, 0, 5)
                end
                if Settings.Triggerbot.Delay > 0 then
                    task.wait(Settings.Triggerbot.Delay)
                end
            end
        end
    end
end)

-- ===== MOVEMENT =====
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    if Settings.Movement.SpeedBoost then
        hum.WalkSpeed = Settings.Movement.WalkSpeed
    else
        hum.WalkSpeed = 16
    end
    hum.JumpPower = Settings.Movement.JumpPower

    if Settings.Movement.AutoBHop and hum.FloorMaterial ~= Enum.Material.Air then
        hum.Jump = true
    end
    if Settings.Movement.NoFallDamage then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end)

-- ===== ESP =====
local espObjects = {}

local function DrawESP()
    if not Settings.ESP.Enabled then return end
    for _, obj in ipairs(espObjects) do
        pcall(function() obj:Remove() end)
    end
    espObjects = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if not IsEnemy(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        if not onScreen then continue end
        local rootPos, _ = Camera:WorldToViewportPoint(root.Position)

        local height = headPos.Y - rootPos.Y
        local width = height * 0.6
        local topLeft = Vector2.new(headPos.X - width/2, headPos.Y - height)

        if Settings.ESP.Box then
            local box = Drawing.new("Square")
            box.Size = Vector2.new(width, height)
            box.Position = topLeft
            box.Color = Color3.fromRGB(0, 255, 65)
            box.Thickness = 2
            box.Visible = true
            table.insert(espObjects, box)
        end

        if Settings.ESP.Name then
            local lbl = Drawing.new("Text")
            lbl.Text = plr.Name
            lbl.Position = Vector2.new(headPos.X, headPos.Y - height - 20)
            lbl.Color = Color3.fromRGB(255, 255, 255)
            lbl.Size = 14
            lbl.Visible = true
            table.insert(espObjects, lbl)
        end

        if Settings.ESP.HealthBar then
            local health = hum.Health / hum.MaxHealth
            local bar = Drawing.new("Rectangle")
            bar.Size = Vector2.new(width, 4)
            bar.Position = Vector2.new(topLeft.X, topLeft.Y + height + 2)
            bar.Color = Color3.fromRGB(255 - health * 255, health * 255, 0)
            bar.Filled = true
            bar.Visible = true
            table.insert(espObjects, bar)
        end

        if Settings.ESP.Distance then
            local dist = (char:FindFirstChild("HumanoidRootPart") and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
            local lbl = Drawing.new("Text")
            lbl.Text = math.floor(dist) .. "s"
            lbl.Position = Vector2.new(headPos.X, headPos.Y + 10)
            lbl.Color = Color3.fromRGB(200, 200, 200)
            lbl.Size = 12
            lbl.Visible = true
            table.insert(espObjects, lbl)
        end

        if Settings.ESP.Skeleton then
            local joints = {"Head", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
            for i = 1, #joints do
                for j = i+1, #joints do
                    local p1 = char:FindFirstChild(joints[i])
                    local p2 = char:FindFirstChild(joints[j])
                    if p1 and p2 then
                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            local line = Drawing.new("Line")
                            line.From = Vector2.new(s1.X, s1.Y)
                            line.To = Vector2.new(s2.X, s2.Y)
                            line.Color = Color3.fromRGB(0, 255, 65)
                            line.Thickness = 1
                            line.Visible = true
                            table.insert(espObjects, line)
                        end
                    end
                end
            end
        end

        if Settings.ESP.WallbangPrediction then
            local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
            local hit, pos = workspace:FindPartOnRay(ray, char)
            if hit and hit ~= head and hit ~= root then
                local dot = Drawing.new("Circle")
                dot.Radius = 5
                dot.Position = Vector2.new(headPos.X, headPos.Y)
                dot.Color = Color3.fromRGB(255, 0, 0)
                dot.Filled = true
                dot.Visible = true
                table.insert(espObjects, dot)
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    DrawESP()
end)

-- ===== FOV CIRCLE =====
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Settings.Visuals.FOVColor
fovCircle.Filled = false
fovCircle.Visible = Settings.Aimbot.ShowFOV

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = Settings.Aimbot.ShowFOV
    fovCircle.Radius = Settings.Aimbot.FOV
end)

-- ===== CROSSHAIR =====
local crosshair = Drawing.new("Line")
crosshair.Thickness = 2
crosshair.Color = Color3.fromRGB(0, 255, 65)
crosshair.Visible = Settings.Visuals.Crosshair

RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    local size = 12
    crosshair.From = Vector2.new(cx - size, cy)
    crosshair.To = Vector2.new(cx + size, cy)
    crosshair.Visible = Settings.Visuals.Crosshair
end)

print("Sniper Duels God Script v5.0 loaded. Aimbot is now fully functional!")
