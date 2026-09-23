local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    WalkSpeed = 100,
    JumpPower = 100,
    Enabled = true,
    Paused = false,
}

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function forceSpeed()
    if not Config.Enabled then return end
    if Config.Paused then return end
    local hum = getHumanoid()
    if not hum then return end
    pcall(function()
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
        hum.UseJumpPower = true
        hum.HipHeight = 2
    end)
end

RunService.Heartbeat:Connect(forceSpeed)
RunService.RenderStepped:Connect(forceSpeed)
RunService.Stepped:Connect(forceSpeed)

pcall(function()
    if LocalPlayer.Kick then
        LocalPlayer.Kick = function() end
    end
end)

RunService.Stepped:Connect(function()
    if not Config.Enabled or Config.Paused then return end
    local hum = getHumanoid()
    if hum and hum.RootPart then
        if hum.WalkSpeed < Config.WalkSpeed - 5 then
            hum.WalkSpeed = Config.WalkSpeed
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    forceSpeed()
    for i = 1, 30 do
        forceSpeed()
        task.wait(0.1)
    end
end)

local function createUI()
    local old = CoreGui:FindFirstChild("SpeedScriptUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpeedScriptUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- ===== WARNA SKY BLUE =====
    local THEME = {
        BG = Color3.fromRGB(15, 30, 60),
        HEADER = Color3.fromRGB(30, 120, 200),
        ACCENT = Color3.fromRGB(60, 170, 255),
        BUTTON = Color3.fromRGB(40, 90, 150),
        BUTTON_ACTIVE = Color3.fromRGB(60, 170, 255),
        BUTTON_DARK = Color3.fromRGB(30, 60, 100),
        TEXT = Color3.fromRGB(240, 250, 255),
        SUBTEXT = Color3.fromRGB(180, 220, 255),
        BORDER = Color3.fromRGB(60, 170, 255),
        RESET = Color3.fromRGB(100, 150, 200),
        PAUSE = Color3.fromRGB(180, 150, 60),
        DANGER = Color3.fromRGB(200, 80, 80),
    }

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 310)
    Main.Position = UDim2.new(0.5, -160, 0.5, -155)
    Main.BackgroundColor3 = THEME.BG
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.BORDER
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = THEME.HEADER
    Title.BorderSizePixel = 0
    Title.Text = "⚡ Speed Script All Game ⚡"
    Title.TextColor3 = THEME.TEXT
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -20, 0, 30)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 55)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "WalkSpeed: " .. Config.WalkSpeed
    SpeedLabel.TextColor3 = THEME.ACCENT
    SpeedLabel.TextSize = 14
    SpeedLabel.Font = Enum.Font.GothamBold
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = Main

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 82)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: ACTIVE"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Main

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 30)
    InputFrame.Position = UDim2.new(0, 10, 0, 105)
    InputFrame.BackgroundColor3 = THEME.BUTTON_DARK
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Main

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -10, 1, 0)
    Input.Position = UDim2.new(0, 5, 0, 0)
    Input.BackgroundTransparency = 1
    Input.Text = tostring(Config.WalkSpeed)
    Input.PlaceholderText = "Ketik speed..."
    Input.TextColor3 = THEME.TEXT
    Input.PlaceholderColor3 = THEME.SUBTEXT
    Input.TextSize = 14
    Input.Font = Enum.Font.Gotham
    Input.Parent = InputFrame

    local presets = {50, 100, 200, 500}
    for i, val in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.23, -5, 0, 30)
        btn.Position = UDim2.new((i-1) * 0.25, 5, 0, 145)
        btn.BackgroundColor3 = THEME.BUTTON
        btn.Text = tostring(val)
        btn.TextColor3 = THEME.TEXT
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = Main

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            Config.WalkSpeed = val
            Input.Text = tostring(val)
            SpeedLabel.Text = "WalkSpeed: " .. val
            forceSpeed()
        end)
    end

    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Size = UDim2.new(1, -20, 0, 35)
    ApplyBtn.Position = UDim2.new(0, 10, 0, 185)
    ApplyBtn.BackgroundColor3 = THEME.BUTTON_ACTIVE
    ApplyBtn.Text = "✅ APPLY SPEED"
    ApplyBtn.TextColor3 = THEME.TEXT
    ApplyBtn.TextSize = 14
    ApplyBtn.Font = Enum.Font.GothamBold
    ApplyBtn.BorderSizePixel = 0
    ApplyBtn.Parent = Main

    local ApplyCorner = Instance.new("UICorner")
    ApplyCorner.CornerRadius = UDim.new(0, 6)
    ApplyCorner.Parent = ApplyBtn

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0.48, -10, 0, 35)
    ResetBtn.Position = UDim2.new(0, 10, 0, 230)
    ResetBtn.BackgroundColor3 = THEME.RESET
    ResetBtn.Text = "🔄 RESET"
    ResetBtn.TextColor3 = THEME.TEXT
    ResetBtn.TextSize = 13
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.BorderSizePixel = 0
    ResetBtn.Parent = Main

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetBtn

    local PauseBtn = Instance.new("TextButton")
    PauseBtn.Size = UDim2.new(0.48, -10, 0, 35)
    PauseBtn.Position = UDim2.new(0.52, 0, 0, 230)
    PauseBtn.BackgroundColor3 = THEME.PAUSE
    PauseBtn.Text = "⏸️ PAUSE"
    PauseBtn.TextColor3 = THEME.TEXT
    PauseBtn.TextSize = 13
    PauseBtn.Font = Enum.Font.GothamBold
    PauseBtn.BorderSizePixel = 0
    PauseBtn.Parent = Main

    local PauseCorner = Instance.new("UICorner")
    PauseCorner.CornerRadius = UDim.new(0, 6)
    PauseCorner.Parent = PauseBtn

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = THEME.SUBTEXT
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Main

    Input.FocusLost:Connect(function()
        local num = tonumber(Input.Text)
        if num then
            Config.WalkSpeed = num
            SpeedLabel.Text = "WalkSpeed: " .. num
            forceSpeed()
        end
    end)

    ApplyBtn.MouseButton1Click:Connect(function()
        Config.Enabled = true
        Config.Paused = false
        forceSpeed()
        ApplyBtn.Text = "✅ APPLIED!"
        StatusLabel.Text = "Status: ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        PauseBtn.Text = "⏸️ PAUSE"
        task.wait(1)
        ApplyBtn.Text = "✅ APPLY SPEED"
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        Config.Enabled = false
        Config.Paused = true
        Config.WalkSpeed = 16
        Config.JumpPower = 50

        local hum = getHumanoid()
        if hum then
            pcall(function()
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.UseJumpPower = true
                hum.HipHeight = 0
            end)
        end

        Input.Text = "16"
        SpeedLabel.Text = "WalkSpeed: 16"
        StatusLabel.Text = "Status: RESET (16)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        PauseBtn.Text = "▶️ RESUME"
        print("[🔄] Speed di-reset ke 16")
    end)

    PauseBtn.MouseButton1Click:Connect(function()
        Config.Paused = not Config.Paused

        if Config.Paused then
            Config.Enabled = false
            PauseBtn.Text = "▶️ RESUME"
            StatusLabel.Text = "Status: PAUSED"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            Config.Enabled = true
            PauseBtn.Text = "⏸️ PAUSE"
            StatusLabel.Text = "Status: ACTIVE"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
            forceSpeed()
        end
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = THEME.DANGER
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = THEME.TEXT
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Title

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
end

forceSpeed()
createUI()

print("[⚡] Speed Script All Game")
print("[©] 0xDarkSyntax")
