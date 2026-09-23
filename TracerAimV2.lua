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
    ShowHealth = false,
    ShowOffscreen = false,
    Color = Color3.fromRGB(255, 0, 0),
    MaxDistance = 2000,
    TeamCheck = false,
    VisibleCheck = false,
    UpdateRate = 2,
}

local drawings = {}
local frameCount = 0

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
            Size = 14,
            Center = true,
            Outline = true,
            Color = Color3.fromRGB(255, 255, 255),
            Font = 0
        }),
        distance = createDrawing("Text", {
            Size = 12,
            Center = true,
            Outline = true,
            Color = Color3.fromRGB(255, 255, 0),
            Font = 0
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

local function isEnemy(player)
    if not Config.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

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
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
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
end

RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    if frameCount % Config.UpdateRate == 0 then
        pcall(updateDrawings)
    end
end)

Players.PlayerRemoving:Connect(removeDrawing)

local function createUI()
    local old = CoreGui:FindFirstChild("AimbotUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 280, 0, 360)
    Main.Position = UDim2.new(0, 10, 0.5, -180)
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
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    Title.BorderSizePixel = 0
    Title.Text = "Tracer Aim"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    local function makeToggle(y, text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 28)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(40, 40, 50)
        btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            btn.BackgroundColor3 = Config[key] and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(40, 40, 50)
        end)
    end

    makeToggle(45, "Enabled", "Enabled")
    makeToggle(78, "Tracer", "ShowTracer")
    makeToggle(111, "Name", "ShowName")
    makeToggle(144, "Distance", "ShowDistance")
    makeToggle(177, "Visible Check", "VisibleCheck")
    makeToggle(210, "Team Check", "TeamCheck")
    makeToggle(243, "Show Offscreen", "ShowOffscreen")

    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Size = UDim2.new(1, -20, 0, 28)
    ColorBtn.Position = UDim2.new(0, 10, 0, 276)
    ColorBtn.BackgroundColor3 = Config.Color
    ColorBtn.Text = "Warna Tracer"
    ColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorBtn.TextSize = 11
    ColorBtn.Font = Enum.Font.GothamBold
    ColorBtn.BorderSizePixel = 0
    ColorBtn.Parent = Main

    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 6)
    ColorCorner.Parent = ColorBtn

    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 150, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 255, 255),
    }
    local colorIdx = 1
    ColorBtn.MouseButton1Click:Connect(function()
        colorIdx = colorIdx % #colors + 1
        Config.Color = colors[colorIdx]
        ColorBtn.BackgroundColor3 = Config.Color
    end)

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = Color3.fromRGB(139, 0, 0)
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Main

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
end

createUI()

print("[🎯] Tracer Aim Loaded")
print("[©] 0xDarkSyntax")
