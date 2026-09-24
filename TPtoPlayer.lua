local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    TeleportOffset = 3,
    AutoFollow = false,
    FollowTarget = nil,
}

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function findPlayerByName(name)
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name, 1, true) then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName:lower() == name then return p end
    end
    return nil
end

local function teleportToPlayer(target)
    if not target then return false, "Player gak ditemukan" end
    if target == LocalPlayer then return false, "Gak bisa teleport ke diri sendiri" end

    local targetChar = target.Character
    if not targetChar then return false, "Target belum spawn" end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or targetHum.Health <= 0 then
        return false, "Target mati / gak ada root"
    end

    local myRoot = getRoot()
    local myHum = getHumanoid()
    if not myRoot or not myHum then return false, "Karakter lu belum spawn" end

    pcall(function()
        myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, Config.TeleportOffset)
        myRoot.Velocity = Vector3.new(0, 0, 0)
    end)

    return true, "Berhasil teleport ke " .. target.Name
end

-- Auto follow
RunService.Heartbeat:Connect(function()
    if not Config.AutoFollow then return end
    if not Config.FollowTarget then return end
    if not Config.FollowTarget.Parent then
        Config.AutoFollow = false
        Config.FollowTarget = nil
        return
    end
    local targetRoot = Config.FollowTarget.Character
        and Config.FollowTarget.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = getRoot()
    if targetRoot and myRoot then
        pcall(function()
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, Config.TeleportOffset)
            myRoot.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end)

local function createUI()
    local old = CoreGui:FindFirstChild("TeleportUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TeleportUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

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
        GREEN = Color3.fromRGB(60, 200, 120),
        RED = Color3.fromRGB(200, 80, 80),
    }

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 380)
    Main.Position = UDim2.new(0, 10, 0.5, -190)
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
    Title.Text = "📍 Teleport to Player"
    Title.TextColor3 = THEME.TEXT
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 20)
    InfoLabel.Position = UDim2.new(0, 10, 0, 48)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Ketik username target:"
    InfoLabel.TextColor3 = THEME.SUBTEXT
    InfoLabel.TextSize = 11
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = Main

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 32)
    InputFrame.Position = UDim2.new(0, 10, 0, 72)
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
    Input.Text = ""
    Input.PlaceholderText = "Username..."
    Input.TextColor3 = THEME.TEXT
    Input.PlaceholderColor3 = THEME.SUBTEXT
    Input.TextSize = 13
    Input.Font = Enum.Font.Gotham
    Input.ClearTextOnFocus = false
    Input.Parent = InputFrame

    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Size = UDim2.new(1, -20, 0, 36)
    TeleportBtn.Position = UDim2.new(0, 10, 0, 112)
    TeleportBtn.BackgroundColor3 = THEME.BUTTON_ACTIVE
    TeleportBtn.Text = "🚀 TELEPORT"
    TeleportBtn.TextColor3 = THEME.TEXT
    TeleportBtn.TextSize = 14
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.BorderSizePixel = 0
    TeleportBtn.Parent = Main

    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 6)
    TeleportCorner.Parent = TeleportBtn

    local FollowBtn = Instance.new("TextButton")
    FollowBtn.Size = UDim2.new(1, -20, 0, 32)
    FollowBtn.Position = UDim2.new(0, 10, 0, 156)
    FollowBtn.BackgroundColor3 = THEME.BUTTON
    FollowBtn.Text = "👣 AUTO FOLLOW: OFF"
    FollowBtn.TextColor3 = THEME.TEXT
    FollowBtn.TextSize = 12
    FollowBtn.Font = Enum.Font.GothamBold
    FollowBtn.BorderSizePixel = 0
    FollowBtn.Parent = Main

    local FollowCorner = Instance.new("UICorner")
    FollowCorner.CornerRadius = UDim.new(0, 6)
    FollowCorner.Parent = FollowBtn

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 0, 196)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Pilih player dari list atau ketik manual"
    StatusLabel.TextColor3 = THEME.SUBTEXT
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = Main

    local ListLabel = Instance.new("TextLabel")
    ListLabel.Size = UDim2.new(1, -20, 0, 20)
    ListLabel.Position = UDim2.new(0, 10, 0, 228)
    ListLabel.BackgroundTransparency = 1
    ListLabel.Text = "Player List:"
    ListLabel.TextColor3 = THEME.ACCENT
    ListLabel.TextSize = 11
    ListLabel.Font = Enum.Font.GothamBold
    ListLabel.TextXAlignment = Enum.TextXAlignment.Left
    ListLabel.Parent = Main

    local PlayerScroll = Instance.new("ScrollingFrame")
    PlayerScroll.Size = UDim2.new(1, -20, 0, 120)
    PlayerScroll.Position = UDim2.new(0, 10, 0, 250)
    PlayerScroll.BackgroundColor3 = THEME.BUTTON_DARK
    PlayerScroll.BorderSizePixel = 0
    PlayerScroll.ScrollBarThickness = 6
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PlayerScroll.Parent = Main

    local PSCorner = Instance.new("UICorner")
    PSCorner.CornerRadius = UDim.new(0, 6)
    PSCorner.Parent = PlayerScroll

    local PlayerList = Instance.new("UIListLayout")
    PlayerList.Padding = UDim.new(0, 3)
    PlayerList.SortOrder = Enum.SortOrder.LayoutOrder
    PlayerList.Parent = PlayerScroll

    local function refreshList()
        for _, c in ipairs(PlayerScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 28)
            btn.BackgroundColor3 = THEME.BUTTON
            btn.Text = "👤 " .. p.Name
            btn.TextColor3 = THEME.TEXT
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = PlayerScroll

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = btn

            btn.MouseButton1Click:Connect(function()
                Input.Text = p.Name
                StatusLabel.Text = "Selected: " .. p.Name
                StatusLabel.TextColor3 = THEME.ACCENT
            end)
        end
    end

    refreshList()
    Players.PlayerAdded:Connect(function() task.wait(0.5) refreshList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshList() end)

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = THEME.SUBTEXT
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Main

    TeleportBtn.MouseButton1Click:Connect(function()
        local username = Input.Text:gsub("%s+", "")
        if username == "" then
            StatusLabel.Text = "Ketik username dulu!"
            StatusLabel.TextColor3 = THEME.RED
            return
        end

        local target = findPlayerByName(username)
        local ok, msg = teleportToPlayer(target)
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = ok and THEME.GREEN or THEME.RED
    end)

    FollowBtn.MouseButton1Click:Connect(function()
        if Config.AutoFollow then
            Config.AutoFollow = false
            Config.FollowTarget = nil
            FollowBtn.Text = "👣 AUTO FOLLOW: OFF"
            FollowBtn.BackgroundColor3 = THEME.BUTTON
            StatusLabel.Text = "Auto follow OFF"
            StatusLabel.TextColor3 = THEME.SUBTEXT
        else
            local username = Input.Text:gsub("%s+", "")
            if username == "" then
                StatusLabel.Text = "Ketik username dulu!"
                StatusLabel.TextColor3 = THEME.RED
                return
            end
            local target = findPlayerByName(username)
            if not target then
                StatusLabel.Text = "Player gak ditemukan"
                StatusLabel.TextColor3 = THEME.RED
                return
            end
            Config.AutoFollow = true
            Config.FollowTarget = target
            FollowBtn.Text = "👣 AUTO FOLLOW: ON"
            FollowBtn.BackgroundColor3 = THEME.BUTTON_ACTIVE
            StatusLabel.Text = "Following: " .. target.Name
            StatusLabel.TextColor3 = THEME.GREEN
        end
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = THEME.RED
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

createUI()

print("[📍] Teleport to Player Loaded")
print("[©] 0xDarkSyntax")
