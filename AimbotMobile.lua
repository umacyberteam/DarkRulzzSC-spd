local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- GANTI URL LOGO DI SINI
-- ============================================================
local LOGO_URL = "https://i.ibb.co.com/TDCKtLvR/04aab61812d34dafe6746eb46a4c4717.jpg"

local Config = {
    Enabled = true,
    AimbotEnabled = false,
    ShowFOV = true,
    FOV = 120,
    Smoothness = 5,
    MaxDistance = 500,
    TeamCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
}

local isAiming = false

-- ============================================================
-- UTIL
-- ============================================================
local function isEnemy(player)
    if not Config.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function isVisible(targetChar, targetPart)
    if not Config.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

local function getClosestTarget()
    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local closest = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not isEnemy(player) then continue end

        local char = player.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local part = char:FindFirstChild(Config.TargetPart)
            or char:FindFirstChild("Head")
            or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
        if dist3D > Config.MaxDistance then continue end

        local pos = Camera:WorldToViewportPoint(part.Position)
        if pos.Z < 0 then continue end

        local dist2D = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist2D > Config.FOV then continue end

        if not isVisible(char, part) then continue end

        if dist2D < closestDist then
            closestDist = dist2D
            closest = player
        end
    end

    return closest
end

local function aimAt(target)
    if not target then return end
    local char = target.Character
    if not char then return end
    local part = char:FindFirstChild(Config.TargetPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
    if not part then return end

    local camPos = Camera.CFrame.Position
    local direction = (part.Position - camPos).Unit
    local currentLook = Camera.CFrame.LookVector
    local newLook = currentLook:Lerp(direction, 1 / Config.Smoothness)
    Camera.CFrame = CFrame.new(camPos, camPos + newLook)
end

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local fovCircle = nil

local function createFOVCircle()
    if Drawing == nil then return end
    local ok, d = pcall(function() return Drawing.new("Circle") end)
    if not ok or not d then return end
    d.Thickness = 2
    d.Color = Color3.fromRGB(60, 170, 255)
    d.Transparency = 0.6
    d.NumSides = 60
    d.Filled = false
    d.Visible = false
    fovCircle = d
end

local function updateFOVCircle()
    if not fovCircle then return end
    if not Config.ShowFOV then
        fovCircle.Visible = false
        return
    end
    local screenSize = Camera.ViewportSize
    fovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    fovCircle.Radius = Config.FOV
    fovCircle.Visible = true
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    updateFOVCircle()

    if not Config.AimbotEnabled then return end
    if not isAiming then return end

    local target = getClosestTarget()
    if target then
        aimAt(target)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local MainPanel, LogoButton

local function createUI()
    local old = CoreGui:FindFirstChild("AimbotMobileUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotMobileUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local THEME = {
        BG = Color3.fromRGB(15, 30, 60),
        HEADER = Color3.fromRGB(30, 120, 200),
        ACCENT = Color3.fromRGB(60, 170, 255),
        BUTTON = Color3.fromRGB(40, 90, 150),
        BUTTON_ACTIVE = Color3.fromRGB(60, 200, 120),
        BUTTON_DARK = Color3.fromRGB(30, 60, 100),
        TEXT = Color3.fromRGB(240, 250, 255),
        SUBTEXT = Color3.fromRGB(180, 220, 255),
        BORDER = Color3.fromRGB(60, 170, 255),
        GREEN = Color3.fromRGB(60, 200, 120),
        RED = Color3.fromRGB(200, 80, 80),
        YELLOW = Color3.fromRGB(255, 200, 80),
    }

    -- ===== LOGO BUTTON (yang ngambang, terpisah) =====
    LogoButton = Instance.new("ImageButton")
    LogoButton.Name = "LogoButton"
    LogoButton.Size = UDim2.new(0, 60, 0, 60)
    LogoButton.Position = UDim2.new(1, -80, 0.5, -30)
    LogoButton.BackgroundColor3 = THEME.BG
    LogoButton.BorderSizePixel = 0
    LogoButton.Image = LOGO_URL
    LogoButton.Visible = false
    LogoButton.Active = true
    LogoButton.Draggable = true
    LogoButton.Parent = ScreenGui

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(1, 0)
    LogoCorner.Parent = LogoButton

    local LogoStroke = Instance.new("UIStroke")
    LogoStroke.Color = THEME.BORDER
    LogoStroke.Thickness = 2
    LogoStroke.Parent = LogoButton

    -- ===== MAIN PANEL =====
    MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Size = UDim2.new(0, 280, 0, 380)
    MainPanel.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainPanel.BackgroundColor3 = THEME.BG
    MainPanel.BorderSizePixel = 0
    MainPanel.Active = true
    MainPanel.Draggable = true
    MainPanel.Parent = ScreenGui

    local PC = Instance.new("UICorner")
    PC.CornerRadius = UDim.new(0, 10)
    PC.Parent = MainPanel

    local PS = Instance.new("UIStroke")
    PS.Color = THEME.BORDER
    PS.Thickness = 2
    PS.Parent = MainPanel

    -- Title
    local PT = Instance.new("TextLabel")
    PT.Size = UDim2.new(1, 0, 0, 38)
    PT.BackgroundColor3 = THEME.HEADER
    PT.BorderSizePixel = 0
    PT.Text = "🎯 Aimbot Mobile"
    PT.TextColor3 = THEME.TEXT
    PT.TextSize = 14
    PT.Font = Enum.Font.GothamBold
    PT.Parent = MainPanel

    local PTC = Instance.new("UICorner")
    PTC.CornerRadius = UDim.new(0, 10)
    PTC.Parent = PT

    -- Tombol CLOSE (jadiin logo)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 5)
    CloseBtn.BackgroundColor3 = THEME.YELLOW
    CloseBtn.Text = "—"
    CloseBtn.TextColor3 = THEME.TEXT
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = PT

    local CBC = Instance.new("UICorner")
    CBC.CornerRadius = UDim.new(1, 0)
    CBC.Parent = CloseBtn

    -- Toggle function
    local function makeToggle(y, text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Config[key] and THEME.BUTTON_ACTIVE or THEME.BUTTON
        btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
        btn.TextColor3 = THEME.TEXT
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = MainPanel

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
            btn.BackgroundColor3 = Config[key] and THEME.BUTTON_ACTIVE or THEME.BUTTON
        end)
    end

    -- === TOMBOL UTAMA: AIMBOT ON/OFF ===
    local AimToggle = Instance.new("TextButton")
    AimToggle.Size = UDim2.new(1, -20, 0, 45)
    AimToggle.Position = UDim2.new(0, 10, 0, 50)
    AimToggle.BackgroundColor3 = Config.AimbotEnabled and THEME.BUTTON_ACTIVE or THEME.RED
    AimToggle.Text = "AIMBOT: OFF"
    AimToggle.TextColor3 = THEME.TEXT
    AimToggle.TextSize = 14
    AimToggle.Font = Enum.Font.GothamBold
    AimToggle.BorderSizePixel = 0
    AimToggle.Parent = MainPanel

    local ATC = Instance.new("UICorner")
    ATC.CornerRadius = UDim.new(0, 8)
    ATC.Parent = AimToggle

    -- === TOMBOL AIM (buat ditahan / tap) ===
    local AimBtn = Instance.new("TextButton")
    AimBtn.Size = UDim2.new(1, -20, 0, 45)
    AimBtn.Position = UDim2.new(0, 10, 0, 100)
    AimBtn.BackgroundColor3 = THEME.BUTTON
    AimBtn.Text = "🎯 TAP TO AIM"
    AimBtn.TextColor3 = THEME.TEXT
    AimBtn.TextSize = 13
    AimBtn.Font = Enum.Font.GothamBold
    AimBtn.BorderSizePixel = 0
    AimBtn.Parent = MainPanel

    local AimBtnC = Instance.new("UICorner")
    AimBtnC.CornerRadius = UDim.new(0, 8)
    AimBtnC.Parent = AimBtn

    -- Settings lain
    makeToggle(155, "Show FOV", "ShowFOV")
    makeToggle(190, "Team Check", "TeamCheck")
    makeToggle(225, "Visible Check", "VisibleCheck")

    -- FOV Input
    local FL = Instance.new("TextLabel")
    FL.Size = UDim2.new(0.5, -15, 0, 26)
    FL.Position = UDim2.new(0, 10, 0, 260)
    FL.BackgroundTransparency = 1
    FL.Text = "FOV (px):"
    FL.TextColor3 = THEME.SUBTEXT
    FL.TextSize = 11
    FL.Font = Enum.Font.GothamBold
    FL.TextXAlignment = Enum.TextXAlignment.Left
    FL.Parent = MainPanel

    local FI = Instance.new("TextBox")
    FI.Size = UDim2.new(0.5, -15, 0, 26)
    FI.Position = UDim2.new(0.5, 5, 0, 260)
    FI.BackgroundColor3 = THEME.BUTTON_DARK
    FI.Text = tostring(Config.FOV)
    FI.TextColor3 = THEME.TEXT
    FI.TextSize = 12
    FI.Font = Enum.Font.Gotham
    FI.BorderSizePixel = 0
    FI.Parent = MainPanel

    local FIC = Instance.new("UICorner")
    FIC.CornerRadius = UDim.new(0, 6)
    FIC.Parent = FI

    FI.FocusLost:Connect(function()
        local v = tonumber(FI.Text)
        if v and v > 0 then Config.FOV = v end
    end)

    -- Smoothness Input
    local SL = Instance.new("TextLabel")
    SL.Size = UDim2.new(0.5, -15, 0, 26)
    SL.Position = UDim2.new(0, 10, 0, 292)
    SL.BackgroundTransparency = 1
    SL.Text = "Smooth:"
    SL.TextColor3 = THEME.SUBTEXT
    SL.TextSize = 11
    SL.Font = Enum.Font.GothamBold
    SL.TextXAlignment = Enum.TextXAlignment.Left
    SL.Parent = MainPanel

    local SI = Instance.new("TextBox")
    SI.Size = UDim2.new(0.5, -15, 0, 26)
    SI.Position = UDim2.new(0.5, 5, 0, 292)
    SI.BackgroundColor3 = THEME.BUTTON_DARK
    SI.Text = tostring(Config.Smoothness)
    SI.TextColor3 = THEME.TEXT
    SI.TextSize = 12
    SI.Font = Enum.Font.Gotham
    SI.BorderSizePixel = 0
    SI.Parent = MainPanel

    local SIC = Instance.new("UICorner")
    SIC.CornerRadius = UDim.new(0, 6)
    SIC.Parent = SI

    SI.FocusLost:Connect(function()
        local v = tonumber(SI.Text)
        if v and v > 0 then Config.Smoothness = v end
    end)

    -- Target Part
    local TP = Instance.new("TextButton")
    TP.Size = UDim2.new(1, -20, 0, 28)
    TP.Position = UDim2.new(0, 10, 0, 324)
    TP.BackgroundColor3 = THEME.BUTTON
    TP.Text = "Target: " .. Config.TargetPart
    TP.TextColor3 = THEME.TEXT
    TP.TextSize = 11
    TP.Font = Enum.Font.GothamBold
    TP.BorderSizePixel = 0
    TP.Parent = MainPanel

    local TPC = Instance.new("UICorner")
    TPC.CornerRadius = UDim.new(0, 6)
    TPC.Parent = TP

    local targetParts = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }
    TP.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(targetParts) do
            if v == Config.TargetPart then idx = i break end
        end
        idx = idx % #targetParts + 1
        Config.TargetPart = targetParts[idx]
        TP.Text = "Target: " .. Config.TargetPart
    end)

    -- Footer
    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = THEME.SUBTEXT
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = MainPanel

    -- ============================================================
    -- AIMBOT ON/OFF TOGGLE
    -- ============================================================
    AimToggle.MouseButton1Click:Connect(function()
        Config.AimbotEnabled = not Config.AimbotEnabled
        AimToggle.Text = "AIMBOT: " .. (Config.AimbotEnabled and "ON" or "OFF")
        AimToggle.BackgroundColor3 = Config.AimbotEnabled and THEME.BUTTON_ACTIVE or THEME.RED
    end)

    -- ============================================================
    -- TAP TO AIM (buat hold / tap)
    -- ============================================================
    AimBtn.MouseButton1Down:Connect(function()
        isAiming = true
        AimBtn.BackgroundColor3 = THEME.BUTTON_ACTIVE
    end)

    AimBtn.MouseButton1Up:Connect(function()
        isAiming = false
        AimBtn.BackgroundColor3 = THEME.BUTTON
    end)

    -- Kalo mouse keluar dari tombol, matiin aiming
    AimBtn.MouseLeave:Connect(function()
        isAiming = false
        AimBtn.BackgroundColor3 = THEME.BUTTON
    end)

    -- ============================================================
    -- CLOSE → ganti ke LOGO
    -- ============================================================
    CloseBtn.MouseButton1Click:Connect(function()
        MainPanel.Visible = false
        LogoButton.Visible = true
    end)

    -- ============================================================
    -- KLIK LOGO → balik ke PANEL
    -- ============================================================
    LogoButton.MouseButton1Click:Connect(function()
        MainPanel.Visible = true
        LogoButton.Visible = false
    end)
end

-- Init
createFOVCircle()
createUI()

print("[🎯] Aimbot Mobile Loaded")
print("[©] 0xDarkSyntax")
