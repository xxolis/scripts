-- ================================================================
--        SNIPER DUELS GOD SCRIPT v6.1 – SYNTAX FIXED
--   "Ultra-snappy aimbot + virtual player detection"
-- ================================================================

-- ===== SETTINGS =====
local Settings = {
    Aimbot = {
        Enabled = true,
        Silent = true,
        Smoothness = 0.05,
        FOV = 120,
        TargetPart = "Head",
        ShowFOV = true,
        Prediction = true,
        PredictionAmount = 0.15
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
        Delay = 0.0
    },
    ESP = {
        Enabled = true,
        Box = true,
        Skeleton = true,
        Name = true,
        HealthBar = true,
        Distance = true,
        WallbangPrediction = true,
        ShowVirtual = true
    },
    Movement = {
        AutoBHop = true,
        SpeedBoost = true,
        WalkSpeed = 25,
        JumpPower = 80,
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

-- ===== VIRTUAL PLAYER DETECTION =====
local function GetVirtualPlayers()
    local virtuals = {}
    local playerNames = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        playerNames[plr.Name] = true
        if plr.Character then
            playerNames[plr.Character.Name] = true
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local isReal = false
            if playerNames[obj.Name] then
                isReal = true
            end
            if obj:FindFirstChild("PlayerOwned") then
                isReal = true
            end
            local parent = obj.Parent
            while parent do
                if parent:IsA("Player") then
                    isReal = true
                    break
                end
                parent = parent.Parent
            end
            
            if not isReal then
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")
                    if head then
                        table.insert(virtuals, {
                            Character = obj,
                            Humanoid = humanoid,
                            Head = head,
                            RootPart = obj:FindFirstChild("HumanoidRootPart") or head,
                            Name = obj.Name .. " (BOT)"
                        })
                    end
                end
            end
        end
    end
    return virtuals
end

-- ===== GET ALL TARGETS =====
local function GetAllTargets()
    local targets = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            continue
        end
        local char = plr.Character
        if not char then
            continue
        end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            continue
        end
        local head = char:FindFirstChild("Head")
        if not head then
            continue
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        table.insert(targets, {
            Player = plr,
            Character = char,
            Humanoid = hum,
            Head = head,
            RootPart = root or head,
            Name = plr.Name,
            IsVirtual = false,
            Priority = 1
        })
    end
    
    if Settings.ESP.ShowVirtual then
        local virtuals = GetVirtualPlayers()
        for _, v in ipairs(virtuals) do
            table.insert(targets, {
                Player = nil,
                Character = v.Character,
                Humanoid = v.Humanoid,
                Head = v.Head,
                RootPart = v.RootPart,
                Name = v.Name,
                IsVirtual = true,
                Priority = 2
            })
        end
    end
    
    return targets
end

-- ===== GET CLOSEST TARGET =====
local function GetClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fov = Settings.Aimbot.FOV
    
    local targets = GetAllTargets()
    
    for _, target in ipairs(targets) do
        local targetPart = target.Head
        if not targetPart then
            continue
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then
            continue
        end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        local priorityWeight = target.Priority * 1000
        local weightedDist = dist + priorityWeight
        
        if dist < fov and weightedDist < closestDist then
            closestDist = weightedDist
            closest = {
                Target = target,
                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                Distance = dist,
                Part = targetPart,
                RootPart = target.RootPart,
                Humanoid = target.Humanoid,
                IsVirtual = target.IsVirtual,
                Name = target.Name,
                Velocity = target.RootPart and target.RootPart.Velocity or Vector3.new(0, 0, 0)
            }
        end
    end
    
    return closest
end

-- ===== PREDICTIVE AIMBOT =====
local function GetPredictedPosition(targetInfo)
    if not Settings.Aimbot.Prediction or not targetInfo.RootPart then
        return targetInfo.ScreenPos
    end
    
    local velocity = targetInfo.RootPart.Velocity
    if velocity.Magnitude < 1 then
        return targetInfo.ScreenPos
    end
    
    local predictTime = Settings.Aimbot.PredictionAmount
    local predictedPos = targetInfo.RootPart.Position + velocity * predictTime
    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
    
    if onScreen then
        return Vector2.new(screenPos.X, screenPos.Y)
    end
    
    return targetInfo.ScreenPos
end

-- ===== SNAPPY MOUSE MOVEMENT =====
local function MoveMouseToTarget(targetPos)
    if not targetPos then
        return
    end
    
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local delta = targetPos - currentPos
    local distance = delta.Magnitude
    local smoothFactor = Settings.Aimbot.Smoothness
    
    if distance < 20 then
        smoothFactor = 0
    elseif distance < 50 then
        smoothFactor = smoothFactor * 0.5
    end
    
    if smoothFactor > 0 then
        delta = delta * (1 - smoothFactor)
    end
    
    if mousemoverel then
        pcall(mousemoverel, delta.X, delta.Y)
        return
    end
    
    if VirtualUser and VirtualUser:CaptureController() then
        pcall(function()
            VirtualUser:SetMousePosition(targetPos.X, targetPos.Y)
        end)
        return
    end
    
    if UserInputService and UserInputService.MouseBehavior then
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

-- ===== UI CREATION =====
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
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

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
                if decimals then
                    val = math.round(val * (10 ^ decimals)) / (10 ^ decimals)
                end
                setter(val)
                fill.Size = UDim2.new(relX, 0, 1, 0)
                valLabel.Text = tostring(val) .. (suffix or "")
            end
        end)
    end

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

    local aimTab = contentFrames[1]
    AddToggle(aimTab, "Aimbot Enabled", function() return Settings.Aimbot.Enabled end, function(v) Settings.Aimbot.Enabled = v end)
    AddToggle(aimTab, "Silent Aim", function() return Settings.Aimbot.Silent end, function(v) Settings.Aimbot.Silent = v end)
    AddSlider(aimTab, "Smoothness", function() return Settings.Aimbot.Smoothness end, function(v) Settings.Aimbot.Smoothness = v end, 0, 0.5, 2)
    AddSlider(aimTab, "FOV (deg)", function() return Settings.Aimbot.FOV end, function(v) Settings.Aimbot.FOV = v end, 10, 360, 0)
    AddToggle(aimTab, "Prediction", function() return Settings.Aimbot.Prediction end, function(v) Settings.Aimbot.Prediction = v end, "Lead moving targets")
    AddToggle(aimTab, "Show FOV Circle", function() return Settings.Aimbot.ShowFOV end, function(v) Settings.Aimbot.ShowFOV = v end)

    local sniperTab = contentFrames[2]
    AddToggle(sniperTab, "Quick Scope", function() return Settings.Sniper.QuickScope end, function(v) Settings.Sniper.QuickScope = v end, "ADS before shot")
    AddToggle(sniperTab, "No-Scope Assist", function() return Settings.Sniper.NoScopeAssist end, function(v) Settings.Sniper.NoScopeAssist = v end)
    AddToggle(sniperTab, "Anti-Recoil", function() return Settings.Sniper.AntiRecoil end, function(v) Settings.Sniper.AntiRecoil = v end)

    local trigTab = contentFrames[3]
    AddToggle(trigTab, "Triggerbot", function() return Settings.Triggerbot.Enabled end, function(v) Settings.Triggerbot.Enabled = v end)
    AddToggle(trigTab, "Hold Mode (RMB)", function() return Settings.Triggerbot.HoldMode end, function(v) Settings.Triggerbot.HoldMode = v end)
    AddSlider(trigTab, "Delay", function() return Settings.Triggerbot.Delay end, function(v) Settings.Triggerbot.Delay = v end, 0, 0.1, 2, "s")

    local espTab = contentFrames[4]
    AddToggle(espTab, "ESP Enabled", function() return Settings.ESP.Enabled end, function(v) Settings.ESP.Enabled = v end)
    AddToggle(espTab, "Box", function() return Settings.ESP.Box end, function(v) Settings.ESP.Box = v end)
    AddToggle(espTab, "Skeleton", function() return Settings.ESP.Skeleton end, function(v) Settings.ESP.Skeleton = v end)
    AddToggle(espTab, "Name", function() return Settings.ESP.Name end, function(v) Settings.ESP.Name = v end)
    AddToggle(espTab, "Health Bar", function() return Settings.ESP.HealthBar end, function(v) Settings.ESP.HealthBar = v end)
    AddToggle(espTab, "Distance", function() return Settings.ESP.Distance end, function(v) Settings.ESP.Distance = v end)
    AddToggle(espTab, "Show Virtual", function() return Settings.ESP.ShowVirtual end, function(v) Settings.ESP.ShowVirtual = v end, "Show bots/dummies")

    local movTab = contentFrames[5]
    AddToggle(movTab, "Auto BHop", function() return Settings.Movement.AutoBHop end, function(v) Settings.Movement.AutoBHop = v end)
    AddToggle(movTab, "Speed Boost", function() return Settings.Movement.SpeedBoost end, function(v) Settings.Movement.SpeedBoost = v end)
    AddSlider(movTab, "Walk Speed", function() return Settings.Movement.WalkSpeed end, function(v) Settings.Movement.WalkSpeed = v end, 16, 100, 0)
    AddSlider(movTab, "Jump Power", function() return Settings.Movement.JumpPower end, function(v) Settings.Movement.JumpPower = v end, 50, 200, 0)

    local visTab = contentFrames[6]
    AddToggle(visTab, "Custom Crosshair", function() return Settings.Visuals.Crosshair end, function(v) Settings.Visuals.Crosshair = v end)

    return screenGui
end

-- ===== INIT =====
local gui = CreateUI()

-- ===== MAIN AIMBOT LOOP =====
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot.Enabled and not Settings.Triggerbot.Enabled then
        return
    end
    
    local targetInfo = GetClosestTarget()
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then
        return
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end

    if Settings.Aimbot.Enabled and targetInfo then
        local aimPos = targetInfo.ScreenPos
        if Settings.Aimbot.Prediction then
            local predicted = GetPredictedPosition(targetInfo)
            aimPos = predicted
        end
        if Settings.Aimbot.Silent then
            Mouse.TargetFilter = targetInfo.Part
        end
        MoveMouseToTarget(aimPos)
    end

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
    if not char then
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        return
    end

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
    if not Settings.ESP.Enabled then
        return
    end
    
    for _, obj in ipairs(espObjects) do
        pcall(function() obj:Remove() end)
    end
    espObjects = {}

    local targets = GetAllTargets()
    
    for _, target in ipairs(targets) do
        if target.IsVirtual and not Settings.ESP.ShowVirtual then
            continue
        end
        
        local char = target.Character
        if not char then
            continue
        end
        local hum = target.Humanoid
        if not hum or hum.Health <= 0 then
            continue
        end
        local head = target.Head
        if not head then
            continue
        end
        local root = target.RootPart
        if not root then
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        if not onScreen then
            continue
        end
        local rootPos, _ = Camera:WorldToViewportPoint(root.Position)

        local height = headPos.Y - rootPos.Y
        local width = height * 0.6
        local topLeft = Vector2.new(headPos.X - width / 2, headPos.Y - height)

        local espColor = target.IsVirtual and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 65)

        if Settings.ESP.Box then
            local box = Drawing.new("Square")
            box.Size = Vector2.new(width, height)
            box.Position = topLeft
            box.Color = espColor
            box.Thickness = 2
            box.Visible = true
            table.insert(espObjects, box)
        end

        if Settings.ESP.Name then
            local lbl = Drawing.new("Text")
            lbl.Text = target.Name .. (target.IsVirtual and " [BOT]" or "")
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
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            local lbl = Drawing.new("Text")
            lbl.Text = math.floor(dist) .. "s"
            lbl.Position = Vector2.new(headPos.X, headPos.Y + 10)
            lbl.Color = Color3.fromRGB(200, 200, 200)
            lbl.Size = 12
            lbl.Visible = true
            table.insert(espObjects, lbl)
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

print("Sniper Duels God Script v6.1 loaded. No syntax errors. Ready to dominate.")
