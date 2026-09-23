local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    WalkSpeed = 100,
    JumpPower = 100,
    Enabled = true,
}

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function forceSpeed()
    local hum = getHumanoid()
    if not hum then return end
    pcall(function()
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
        hum.UseJumpPower = true
        hum.HipHeight = 2
    end)
end

RunService.Heartbeat:Connect(function()
    if Config.Enabled then forceSpeed() end
end)

RunService.RenderStepped:Connect(function()
    if Config.Enabled then forceSpeed() end
end)

RunService.Stepped:Connect(function()
    if Config.Enabled then forceSpeed() end
end)

pcall(function()
    if LocalPlayer.Kick then
        LocalPlayer.Kick = function() end
    end
end)

RunService.Stepped:Connect(function()
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

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 260)
    Main.Position = UDim2.new(0.5, -160, 0.5, -130)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(139, 0, 0)
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    Title.BorderSizePixel = 0
    Title.Text = "⚡ Speed Script All Game ⚡"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    SpeedLabel.Text = "WalkSpeed: 100"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    SpeedLabel.TextSize = 14
    SpeedLabel.Font = Enum.Font.GothamBold
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = Main

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 30)
    InputFrame.Position = UDim2.new(0, 10, 0, 90)
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Main

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -10, 1, 0)
    Input.Position = UDim2.new(0, 5, 0, 0)
    Input.BackgroundTransparency = 1
    Input.Text = "100"
    Input.PlaceholderText = "Ketik speed..."
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    Input.TextSize = 14
    Input.Font = Enum.Font.Gotham
    Input.Parent = InputFrame

    local presets = {50, 100, 200, 500}
    for i, val in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.23, -5, 0, 30)
        btn.Position = UDim2.new((i-1) * 0.25, 5, 0, 130)
        btn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        btn.Text = tostring(val)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    ApplyBtn.Position = UDim2.new(0, 10, 0, 170)
    ApplyBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    ApplyBtn.Text = "✅ APPLY SPEED"
    ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyBtn.TextSize = 14
    ApplyBtn.Font = Enum.Font.GothamBold
    ApplyBtn.BorderSizePixel = 0
    ApplyBtn.Parent = Main

    local ApplyCorner = Instance.new("UICorner")
    ApplyCorner.CornerRadius = UDim.new(0, 6)
    ApplyCorner.Parent = ApplyBtn

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(1, -20, 0, 30)
    ResetBtn.Position = UDim2.new(0, 10, 0, 210)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ResetBtn.Text = "🔄 RESET (16)"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 13
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.BorderSizePixel = 0
    ResetBtn.Parent = Main

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetBtn

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -20)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = Color3.fromRGB(139, 0, 0)
    Footer.TextSize = 11
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
        forceSpeed()
        ApplyBtn.Text = "✅ APPLIED!"
        task.wait(1)
        ApplyBtn.Text = "✅ APPLY SPEED"
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        Config.WalkSpeed = 16
        SpeedLabel.Text = "WalkSpeed: 16"
        Input.Text = "16"
        forceSpeed()
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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

print("[✅] Speed Script All Game")
print("[©] 0xDarkSyntax")
