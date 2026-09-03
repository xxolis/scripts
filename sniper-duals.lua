-- ================================================================
--        SNIPER DUELS HUB v1.0 – LOADSTRING EDITION
--   "Small footprint, big impact."
-- ================================================================

-- ===== HUB CONFIG =====
local Hub = {
    Name = "Sniper Duels Hub",
    Version = "1.0",
    ScriptURL = "https://gist.githubusercontent.com/Scripter-Coder/5a256b5d2a2322ec1c1630bb27ebb6f9/raw/8b26d7ae9d0443be23a83b57e6121f83381a6641/PC%2520Version" -- Replace with your actual raw URL
}

-- ===== UI CREATION (minimal) =====
local function CreateHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SniperHub"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 65)
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
    title.Text = "══ SNIPER DUELS HUB ══"
    title.TextColor3 = Color3.fromRGB(0, 255, 65)
    title.Font = Enum.Font.Code
    title.TextScaled = true
    title.Parent = frame

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.8, 0, 0, 40)
    loadBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
    loadBtn.Text = "LOAD SCRIPT"
    loadBtn.TextColor3 = Color3.fromRGB(0, 255, 65)
    loadBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    loadBtn.BorderSizePixel = 1
    loadBtn.BorderColor3 = Color3.fromRGB(0, 255, 65)
    loadBtn.Font = Enum.Font.Code
    loadBtn.TextScaled = true
    loadBtn.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.7, 0)
    status.Text = "Ready"
    status.TextColor3 = Color3.fromRGB(100, 200, 100)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Code
    status.TextScaled = true
    status.Parent = frame

    loadBtn.MouseButton1Click:Connect(function()
        status.Text = "Loading..."
        status.TextColor3 = Color3.fromRGB(255, 255, 0)
        local success, result = pcall(function()
            local script = game:HttpGet(Hub.ScriptURL)
            loadstring(script)()
        end)
        if success then
            status.Text = "Loaded!"
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
            frame:Destroy()
        else
            status.Text = "Failed to load"
            status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)

    return screenGui
end

-- ===== CREATE THE HUB =====
CreateHub()
