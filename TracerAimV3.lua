local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    Enabled = true,
    ShowTracer = true,
    ShowName = true,
    ShowDistance = true,
    ShowOffscreen = false,
    Color = Color3.fromRGB(255, 0, 0),
    MaxDistance = 2000,
    TeamCheck = false,
    VisibleCheck = false,
    UpdateRate = 2,
    
    -- AUTO FIRE
    AutoFire = false,
    FireFOV = 50,
    FireDelay = 0.1,
    FireMethod = 1,
    VisibleCheckFire = true,
    MaxFireDistance = 500,
}

local drawings = {}
local frameCount = 0
local lastFire = 0

local function hasDrawing()
    return Drawing ~= nil
end

local function createDrawing(type, props)
    if not hasDrawing() then return nil end
    local ok, d = pcall(function() return Drawing.new(type) end)
    if not ok or not d then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    pcall(function() d.Visible = false end)
    return d
end

local function initDrawing(player)
    if not hasDrawing() then return end
    if drawings[player] then return end

    drawings[player] = {
        tracer = createDrawing("Line", {
            Thickness = 1,
            Color = Config.Color,
            Transparency = 0.9,
            ZIndex = 999
        }),
        name = createDrawing("Text", {
            Size = 14, Center = true, Outline = true,
            Color = Color3.fromRGB(255, 255, 255), Font = 0
        }),
        distance = createDrawing("Text", {
            Size = 12, Center = true, Outline = true,
            Color = Color3.fromRGB(255, 255, 0), Font = 0
        }),
    }
end

local function removeDrawing(player)
    if drawings[player] then
        for _, d in pairs(drawings[player]) do
            pcall(function() d:Remove() end)
        end
        drawings[player] = nil
    end
end

local function isVisible(targetChar, targetHead)
    if not Config.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetHead.Position - origin).Unit * (targetHead.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

local function isVisibleForFire(targetChar, targetHead)
    if not Config.VisibleCheckFire then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetHead.Position - origin).Unit * (targetHead.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

local function isEnemy(player)
    if not Config.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

-- ============================================================
-- FIRE METHOD
-- ============================================================

-- Method 1: Simulasi klik mouse di tengah layar
local function fireMethod1()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2,
            0, true, game, 1
        )
        task.wait(0.05)
        vim:SendMouseButtonEvent(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2,
            0, false, game, 1
        )
    end)
end

-- Method 2: Pake tool:Activate()
local function fireMethod2()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end

-- Method 3: Simulasi MouseButton1Click
local function fireMethod3()
    pcall(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse:Click()
        end
    end)
end

local function doFire()
    local now = tick()
    if now - lastFire < Config.FireDelay then return end
    lastFire = now

    if Config.FireMethod == 1 then
        fireMethod1()
    elseif Config.FireMethod == 2 then
        fireMethod2()
    elseif Config.FireMethod == 3 then
        fireMethod3()
    end
end

-- ============================================================
-- AUTO FIRE LOGIC
-- ============================================================
local function checkAutoFire()
    if not Config.AutoFire then return end

    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local closestPlayer = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then continue end

        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end

        -- Cek apakah player ini punya Humanoid (berarti player asli, bukan NPC)
        -- NPC biasanya gak punya Player object
        if not player:IsA("Player") then continue end
        if not isEnemy(player) then continue end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if headPos.Z < 0 then continue end

        local dist3D = (Camera.CFrame.Position - head.Position).Magnitude
        if dist3D > Config.MaxFireDistance then continue end

        local dist2D = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
        if dist2D > Config.FireFOV then continue end

        if not isVisibleForFire(char, head) then continue end

        if dist2D < closestDist then
            closestDist = dist2D
            closestPlayer = player
        end
    end

    if closestPlayer then
        doFire()
    end
end

-- ============================================================
-- UPDATE DRAWINGS
-- ============================================================
local function updateDrawings()
    if not hasDrawing() then return end

    local screenSize = Camera.ViewportSize
    local centerScreen = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        initDrawing(player)
        local d = drawings[player]
        if not d then continue end

        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local shouldShow = Config.Enabled and char and head and hum and hum.Health > 0 and isEnemy(player)

        if shouldShow then
            local headPos = Camera:WorldToViewportPoint(head.Position)
            local distance = (Camera.CFrame.Position - head.Position).Magnitude

            if distance > Config.MaxDistance then
                shouldShow = false
            elseif Config.VisibleCheck and not isVisible(char, head) then
                shouldShow = false
            elseif not Config.ShowOffscreen and headPos.Z < 0 then
                shouldShow = false
            end

            if shouldShow then
                if Config.ShowTracer and d.tracer then
                    d.tracer.From = centerScreen
                    d.tracer.To = Vector2.new(headPos.X, headPos.Y)
                    d.tracer.Color = Config.Color
                    d.tracer.Visible = true
                elseif d.tracer then
                    d.tracer.Visible = false
                end

                if Config.ShowName and d.name then
                    d.name.Text = player.Name
                    d.name.Position = Vector2.new(headPos.X, headPos.Y - 30)
                    d.name.Visible = true
                elseif d.name then
                    d.name.Visible = false
                end

                if Config.ShowDistance and d.distance then
                    d.distance.Text = string.format("[%d m]", math.floor(distance))
                    d.distance.Position = Vector2.new(headPos.X, headPos.Y - 15)
                    d.distance.Visible = true
                elseif d.distance then
                    d.distance.Visible = false
                end
            else
                for _, draw in pairs(d) do
                    if draw then draw.Visible = false end
                end
            end
        else
            for _, draw in pairs(d) do
                if draw then draw.Visible = false end
            end
        end
    end

    checkAutoFire()
end

RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    if frameCount % Config.UpdateRate == 0 then
        pcall(updateDrawings)
    end
end)

Players.PlayerRemoving:Connect(removeDrawing)

-- ============================================================
-- UI
-- ============================================================
local function createUI()
    local old = CoreGui:FindFirstChild("AimbotUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotUI"
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
        FIRE = Color3.fromRGB(255, 80, 0),
    }

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 280, 0, 460)
    Main.Position = UDim2.new(0, 10, 0.5, -230)
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
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = THEME.HEADER
    Title.BorderSizePixel = 0
    Title.Text = "🎯 Tracer + Auto Fire"
    Title.TextColor3 = THEME.TEXT
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    local function makeToggle(y, text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 26)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Config[key] and THEME.BUTTON_ACTIVE or THEME.BUTTON
        btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
        btn.TextColor3 = THEME.TEXT
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = Main

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
            btn.BackgroundColor3 = Config[key] and THEME.BUTTON_ACTIVE or THEME.BUTTON
        end)
    end

    makeToggle(45, "Enabled", "Enabled")
    makeToggle(75, "Tracer", "ShowTracer")
    makeToggle(105, "Name", "ShowName")
    makeToggle(135, "Distance", "ShowDistance")
    makeToggle(165, "Visible Check (Tracer)", "VisibleCheck")
    makeToggle(195, "Team Check", "TeamCheck")
    makeToggle(225, "Show Offscreen", "ShowOffscreen")

    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(1, -20, 0, 1)
    Separator.Position = UDim2.new(0, 10, 0, 255)
    Separator.BackgroundColor3 = THEME.BORDER
    Separator.BorderSizePixel = 0
    Separator.Parent = Main

    local FireLabel = Instance.new("TextLabel")
    FireLabel.Size = UDim2.new(1, -20, 0, 20)
    FireLabel.Position = UDim2.new(0, 10, 0, 260)
    FireLabel.BackgroundTransparency = 1
    FireLabel.Text = "🔥 AUTO FIRE"
    FireLabel.TextColor3 = THEME.FIRE
    FireLabel.TextSize = 11
    FireLabel.Font = Enum.Font.GothamBold
    FireLabel.TextXAlignment = Enum.TextXAlignment.Left
    FireLabel.Parent = Main

    makeToggle(283, "Auto Fire", "AutoFire")
    makeToggle(313, "Visible Check (Fire)", "VisibleCheckFire")

    local FireDelayLabel = Instance.new("TextLabel")
    FireDelayLabel.Size = UDim2.new(0.5, -15, 0, 24)
    FireDelayLabel.Position = UDim2.new(0, 10, 0, 343)
    FireDelayLabel.BackgroundTransparency = 1
    FireDelayLabel.Text = "Delay (s):"
    FireDelayLabel.TextColor3 = THEME.SUBTEXT
    FireDelayLabel.TextSize = 10
    FireDelayLabel.Font = Enum.Font.Gotham
    FireDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    FireDelayLabel.Parent = Main

    local FireDelayInput = Instance.new("TextBox")
    FireDelayInput.Size = UDim2.new(0.5, -15, 0, 24)
    FireDelayInput.Position = UDim2.new(0.5, 5, 0, 343)
    FireDelayInput.BackgroundColor3 = THEME.BUTTON_DARK
    FireDelayInput.Text = tostring(Config.FireDelay)
    FireDelayInput.TextColor3 = THEME.TEXT
    FireDelayInput.TextSize = 11
    FireDelayInput.Font = Enum.Font.Gotham
    FireDelayInput.BorderSizePixel = 0
    FireDelayInput.Parent = Main

    local FDIc = Instance.new("UICorner")
    FDIc.CornerRadius = UDim.new(0, 6)
    FDIc.Parent = FireDelayInput

    FireDelayInput.FocusLost:Connect(function()
        local v = tonumber(FireDelayInput.Text)
        if v and v > 0 then Config.FireDelay = v end
    end)

    local FireFOVLabel = Instance.new("TextLabel")
    FireFOVLabel.Size = UDim2.new(0.5, -15, 0, 24)
    FireFOVLabel.Position = UDim2.new(0, 10, 0, 372)
    FireFOVLabel.BackgroundTransparency = 1
    FireFOVLabel.Text = "FOV (px):"
    FireFOVLabel.TextColor3 = THEME.SUBTEXT
    FireFOVLabel.TextSize = 10
    FireFOVLabel.Font = Enum.Font.Gotham
    FireFOVLabel.TextXAlignment = Enum.TextXAlignment.Left
    FireFOVLabel.Parent = Main

    local FireFOVInput = Instance.new("TextBox")
    FireFOVInput.Size = UDim2.new(0.5, -15, 0, 24)
    FireFOVInput.Position = UDim2.new(0.5, 5, 0, 372)
    FireFOVInput.BackgroundColor3 = THEME.BUTTON_DARK
    FireFOVInput.Text = tostring(Config.FireFOV)
    FireFOVInput.TextColor3 = THEME.TEXT
    FireFOVInput.TextSize = 11
    FireFOVInput.Font = Enum.Font.Gotham
    FireFOVInput.BorderSizePixel = 0
    FireFOVInput.Parent = Main

    local FFIc = Instance.new("UICorner")
    FFIc.CornerRadius = UDim.new(0, 6)
    FFIc.Parent = FireFOVInput

    FireFOVInput.FocusLost:Connect(function()
        local v = tonumber(FireFOVInput.Text)
        if v and v > 0 then Config.FireFOV = v end
    end)

    local MethodBtn = Instance.new("TextButton")
    MethodBtn.Size = UDim2.new(1, -20, 0, 26)
    MethodBtn.Position = UDim2.new(0, 10, 0, 401)
    MethodBtn.BackgroundColor3 = THEME.BUTTON
    MethodBtn.Text = "Fire Method: " .. Config.FireMethod
    MethodBtn.TextColor3 = THEME.TEXT
    MethodBtn.TextSize = 11
    MethodBtn.Font = Enum.Font.GothamBold
    MethodBtn.BorderSizePixel = 0
    MethodBtn.Parent = Main

    local MBc = Instance.new("UICorner")
    MBc.CornerRadius = UDim.new(0, 6)
    MBc.Parent = MethodBtn

    MethodBtn.MouseButton1Click:Connect(function()
        Config.FireMethod = Config.FireMethod % 3 + 1
        MethodBtn.Text = "Fire Method: " .. Config.FireMethod
    end)

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = THEME.SUBTEXT
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Main

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
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

print("[🎯] Tracer + Auto Fire Loaded")
print("[©] 0xDarkSyntax")
