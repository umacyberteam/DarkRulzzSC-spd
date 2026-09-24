local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Points = {},
    MaxPoints = 20,
}

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getPosition()
    local root = getRoot()
    if not root then return nil end
    return root.CFrame
end

-- ============================================================
-- SAVE / LOAD
-- ============================================================
local function savePoints()
    pcall(function()
        writefile("teleport_points.json", HttpService:JSONEncode(Config.Points))
    end)
end

local function loadPoints()
    pcall(function()
        if isfile and isfile("teleport_points.json") then
            local data = readfile("teleport_points.json")
            Config.Points = HttpService:JSONDecode(data)
        end
    end)
end

-- ============================================================
-- TELEPORT
-- ============================================================
local function teleportToPoint(point)
    local root = getRoot()
    if not root then return false, "Karakter belum spawn" end
    
    pcall(function()
        root.CFrame = CFrame.new(
            point.x,
            point.y,
            point.z
        )
        root.Velocity = Vector3.new(0, 0, 0)
    end)
    
    return true, "Teleport ke " .. point.name
end

-- ============================================================
-- UI
-- ============================================================
local function createUI()
    local old = CoreGui:FindFirstChild("TeleportPointUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TeleportPointUI"
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
        YELLOW = Color3.fromRGB(255, 200, 80),
    }

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 450)
    Main.Position = UDim2.new(0, 10, 0.5, -225)
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
    Title.Text = "📍 Teleport Points"
    Title.TextColor3 = THEME.TEXT
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    -- SET POINT SECTION
    local SetLabel = Instance.new("TextLabel")
    SetLabel.Size = UDim2.new(1, -20, 0, 20)
    SetLabel.Position = UDim2.new(0, 10, 0, 48)
    SetLabel.BackgroundTransparency = 1
    SetLabel.Text = "SET POINT"
    SetLabel.TextColor3 = THEME.ACCENT
    SetLabel.TextSize = 11
    SetLabel.Font = Enum.Font.GothamBold
    SetLabel.TextXAlignment = Enum.TextXAlignment.Left
    SetLabel.Parent = Main

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 30)
    InputFrame.Position = UDim2.new(0, 10, 0, 70)
    InputFrame.BackgroundColor3 = THEME.BUTTON_DARK
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Main

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame

    local NameInput = Instance.new("TextBox")
    NameInput.Size = UDim2.new(1, -10, 1, 0)
    NameInput.Position = UDim2.new(0, 5, 0, 0)
    NameInput.BackgroundTransparency = 1
    NameInput.Text = ""
    NameInput.PlaceholderText = "Nama point (misal: Base, Loot, dll)"
    NameInput.TextColor3 = THEME.TEXT
    NameInput.PlaceholderColor3 = THEME.SUBTEXT
    NameInput.TextSize = 12
    NameInput.Font = Enum.Font.Gotham
    NameInput.ClearTextOnFocus = false
    NameInput.Parent = InputFrame

    local SetBtn = Instance.new("TextButton")
    SetBtn.Size = UDim2.new(1, -20, 0, 32)
    SetBtn.Position = UDim2.new(0, 10, 0, 108)
    SetBtn.BackgroundColor3 = THEME.BUTTON_ACTIVE
    SetBtn.Text = "📌 SET POINT (Posisi Sekarang)"
    SetBtn.TextColor3 = THEME.TEXT
    SetBtn.TextSize = 12
    SetBtn.Font = Enum.Font.GothamBold
    SetBtn.BorderSizePixel = 0
    SetBtn.Parent = Main

    local SetBtnCorner = Instance.new("UICorner")
    SetBtnCorner.CornerRadius = UDim.new(0, 6)
    SetBtnCorner.Parent = SetBtn

    -- STATUS
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 24)
    StatusLabel.Position = UDim2.new(0, 10, 0, 145)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Total points: 0/" .. Config.MaxPoints
    StatusLabel.TextColor3 = THEME.SUBTEXT
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Main

    -- LIST POINT SECTION
    local ListLabel = Instance.new("TextLabel")
    ListLabel.Size = UDim2.new(1, -20, 0, 20)
    ListLabel.Position = UDim2.new(0, 10, 0, 172)
    ListLabel.BackgroundTransparency = 1
    ListLabel.Text = "LIST POINT"
    ListLabel.TextColor3 = THEME.ACCENT
    ListLabel.TextSize = 11
    ListLabel.Font = Enum.Font.GothamBold
    ListLabel.TextXAlignment = Enum.TextXAlignment.Left
    ListLabel.Parent = Main

    local PointScroll = Instance.new("ScrollingFrame")
    PointScroll.Size = UDim2.new(1, -20, 0, 220)
    PointScroll.Position = UDim2.new(0, 10, 0, 195)
    PointScroll.BackgroundColor3 = THEME.BUTTON_DARK
    PointScroll.BorderSizePixel = 0
    PointScroll.ScrollBarThickness = 6
    PointScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    PointScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PointScroll.Parent = Main

    local PSCorner = Instance.new("UICorner")
    PSCorner.CornerRadius = UDim.new(0, 6)
    PSCorner.Parent = PointScroll

    local PointList = Instance.new("UIListLayout")
    PointList.Padding = UDim.new(0, 4)
    PointList.SortOrder = Enum.SortOrder.LayoutOrder
    PointList.Parent = PointScroll

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "© 0xDarkSyntax"
    Footer.TextColor3 = THEME.SUBTEXT
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Main

    -- ============================================================
    -- RENDER POINT LIST
    -- ============================================================
    local function renderPoints()
        for _, c in ipairs(PointScroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        for i, point in ipairs(Config.Points) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 60)
            row.BackgroundColor3 = THEME.BG
            row.BorderSizePixel = 0
            row.Parent = PointScroll

            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 6)
            rowCorner.Parent = row

            -- Nama point
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -10, 0, 22)
            nameLbl.Position = UDim2.new(0, 5, 0, 2)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = point.name
            nameLbl.TextColor3 = THEME.TEXT
            nameLbl.TextSize = 12
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row

            -- Koordinat
            local coordLbl = Instance.new("TextLabel")
            coordLbl.Size = UDim2.new(1, -10, 0, 14)
            coordLbl.Position = UDim2.new(0, 5, 0, 22)
            coordLbl.BackgroundTransparency = 1
            coordLbl.Text = string.format("X: %d  Y: %d  Z: %d",
                math.floor(point.x), math.floor(point.y), math.floor(point.z))
            coordLbl.TextColor3 = THEME.SUBTEXT
            coordLbl.TextSize = 9
            coordLbl.Font = Enum.Font.Gotham
            coordLbl.TextXAlignment = Enum.TextXAlignment.Left
            coordLbl.Parent = row

            -- Tombol TELEPORT
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0.4, -5, 0, 26)
            tpBtn.Position = UDim2.new(0, 5, 0, 32)
            tpBtn.BackgroundColor3 = THEME.GREEN
            tpBtn.Text = "🚀 TP"
            tpBtn.TextColor3 = THEME.TEXT
            tpBtn.TextSize = 10
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.BorderSizePixel = 0
            tpBtn.Parent = row

            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0, 4)
            tpCorner.Parent = tpBtn

            tpBtn.MouseButton1Click:Connect(function()
                local ok, msg = teleportToPoint(point)
                StatusLabel.Text = msg
                StatusLabel.TextColor3 = ok and THEME.GREEN or THEME.RED
            end)

            -- Tombol RENAME
            local renameBtn = Instance.new("TextButton")
            renameBtn.Size = UDim2.new(0.3, -5, 0, 26)
            renameBtn.Position = UDim2.new(0.4, 0, 0, 32)
            renameBtn.BackgroundColor3 = THEME.YELLOW
            renameBtn.Text = "✏️"
            renameBtn.TextColor3 = THEME.TEXT
            renameBtn.TextSize = 12
            renameBtn.Font = Enum.Font.GothamBold
            renameBtn.BorderSizePixel = 0
            renameBtn.Parent = row

            local renameCorner = Instance.new("UICorner")
            renameCorner.CornerRadius = UDim.new(0, 4)
            renameCorner.Parent = renameBtn

            -- Tombol DELETE
            local deleteBtn = Instance.new("TextButton")
            deleteBtn.Size = UDim2.new(0.3, -5, 0, 26)
            deleteBtn.Position = UDim2.new(0.7, 0, 0, 32)
            deleteBtn.BackgroundColor3 = THEME.RED
            deleteBtn.Text = "🗑️"
            deleteBtn.TextColor3 = THEME.TEXT
            deleteBtn.TextSize = 12
            deleteBtn.Font = Enum.Font.GothamBold
            deleteBtn.BorderSizePixel = 0
            deleteBtn.Parent = row

            local deleteCorner = Instance.new("UICorner")
            deleteCorner.CornerRadius = UDim.new(0, 4)
            deleteCorner.Parent = deleteBtn

            -- Rename dialog
            renameBtn.MouseButton1Click:Connect(function()
                local dialog = Instance.new("TextBox")
                dialog.Size = UDim2.new(1, -10, 0, 22)
                dialog.Position = UDim2.new(0, 5, 0, 2)
                dialog.BackgroundColor3 = THEME.BUTTON_DARK
                dialog.Text = point.name
                dialog.TextColor3 = THEME.TEXT
                dialog.TextSize = 12
                dialog.Font = Enum.Font.GothamBold
                dialog.BorderSizePixel = 0
                dialog.ClearTextOnFocus = false
                dialog.Parent = row

                local dCorner = Instance.new("UICorner")
                dCorner.CornerRadius = UDim.new(0, 4)
                dCorner.Parent = dialog

                nameLbl.Visible = false
                dialog:CaptureFocus()

                dialog.FocusLost:Connect(function()
                    local newName = dialog.Text:gsub("^%s+", ""):gsub("%s+$", "")
                    if newName ~= "" then
                        Config.Points[i].name = newName
                        savePoints()
                        renderPoints()
                    else
                        dialog:Destroy()
                        nameLbl.Visible = true
                    end
                end)
            end)

            -- Delete
            deleteBtn.MouseButton1Click:Connect(function()
                table.remove(Config.Points, i)
                savePoints()
                renderPoints()
                StatusLabel.Text = "Point dihapus"
                StatusLabel.TextColor3 = THEME.YELLOW
            end)
        end

        StatusLabel.Text = "Total points: " .. #Config.Points .. "/" .. Config.MaxPoints
    end

    -- Set point
    SetBtn.MouseButton1Click:Connect(function()
        if #Config.Points >= Config.MaxPoints then
            StatusLabel.Text = "Point penuh! (max " .. Config.MaxPoints .. ")"
            StatusLabel.TextColor3 = THEME.RED
            return
        end

        local pos = getPosition()
        if not pos then
            StatusLabel.Text = "Karakter belum spawn"
            StatusLabel.TextColor3 = THEME.RED
            return
        end

        local name = NameInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then
            name = "Point " .. (#Config.Points + 1)
        end

        table.insert(Config.Points, {
            name = name,
            x = pos.X,
            y = pos.Y,
            z = pos.Z,
        })

        savePoints()
        NameInput.Text = ""
        renderPoints()
        StatusLabel.Text = "Point '" .. name .. "' disimpan!"
        StatusLabel.TextColor3 = THEME.GREEN
    end)

    -- Close
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

    -- Toggle
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    renderPoints()
end

-- Load points yang udah disave
loadPoints()
createUI()

print("[📍] Teleport Points Loaded")
print("[©] 0xDarkSyntax")
