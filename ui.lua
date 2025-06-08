local UILib = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Settings persistence
local SETTINGS_FILE = "executor_ui_settings"
local settings = {}

-- Load saved settings
pcall(function()
    settings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
end)

local function save()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
end

-- Main UI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUILib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Rounded corner utility function
local function addRoundedCorners(frame, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, radius or 8)
    uicorner.Parent = frame
    return uicorner
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
addRoundedCorners(MainFrame, 12)

-- Dragging logic (unchanged)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
addRoundedCorners(TitleBar, 12)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Text = "Executor UI"
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 10, 0, 0)

-- Control Buttons container
local Controls = Instance.new("Frame", TitleBar)
Controls.Size = UDim2.new(0, 110, 1, 0)
Controls.Position = UDim2.new(1, -110, 0, 0)
Controls.BackgroundTransparency = 1

local function createControlButton(parent, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.AutoButtonColor = false
    addRoundedCorners(btn, 6)
    return btn
end

local MinimizeBtn = createControlButton(Controls, "─", Color3.fromRGB(60, 60, 60))
MinimizeBtn.Position = UDim2.new(0, 0, 0, 5)
local FullscreenBtn = createControlButton(Controls, "⬜", Color3.fromRGB(80, 80, 80))
FullscreenBtn.Position = UDim2.new(0, 40, 0, 5)
local CloseBtn = createControlButton(Controls, "✕", Color3.fromRGB(180, 50, 50))
CloseBtn.Position = UDim2.new(0, 80, 0, 5)

local minimized = false
local fullscreen = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

MinimizeBtn.MouseButton1Click:Connect(function()
    if minimized then
        -- Restore
        MainFrame.Size = originalSize
        ContentHolder.Visible = true
        Sidebar.Visible = true
        minimized = false
    else
        -- Minimize
        originalSize = MainFrame.Size
        MainFrame.Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 40)
        ContentHolder.Visible = false
        Sidebar.Visible = false
        minimized = true
    end
end)

FullscreenBtn.MouseButton1Click:Connect(function()
    if fullscreen then
        MainFrame.Size = originalSize
        MainFrame.Position = originalPosition
        fullscreen = false
    else
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        MainFrame.Size = UDim2.new(1, -20, 1, -20)
        MainFrame.Position = UDim2.new(0, 10, 0, 10)
        fullscreen = true
    end
end)

-- Confirmation Popup for Close
local function showCloseConfirm()
    local popup = Instance.new("Frame", ScreenGui)
    popup.Size = UDim2.new(0, 300, 0, 150)
    popup.Position = UDim2.new(0.5, -150, 0.5, -75)
    popup.BackgroundColor3 = Color3.fromRGB(30,30,30)
    addRoundedCorners(popup, 12)
    popup.ZIndex = 1000

    local label = Instance.new("TextLabel", popup)
    label.Text = "Are you sure you want to close?"
    label.Size = UDim2.new(1, -20, 0, 60)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    local yesBtn = Instance.new("TextButton", popup)
    yesBtn.Text = "Yes"
    yesBtn.Size = UDim2.new(0, 100, 0, 40)
    yesBtn.Position = UDim2.new(0, 40, 1, -60)
    yesBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
    yesBtn.TextColor3 = Color3.new(1,1,1)
    addRoundedCorners(yesBtn, 8)

    local noBtn = Instance.new("TextButton", popup)
    noBtn.Text = "No"
    noBtn.Size = UDim2.new(0, 100, 0, 40)
    noBtn.Position = UDim2.new(1, -140, 1, -60)
    noBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
    noBtn.TextColor3 = Color3.new(1,1,1)
    addRoundedCorners(noBtn, 8)

    yesBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    noBtn.MouseButton1Click:Connect(function()
        popup:Destroy()
    end)
end

CloseBtn.MouseButton1Click:Connect(showCloseConfirm)

-- Sidebar & ContentHolder (rounded corners + nicer layout)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
addRoundedCorners(Sidebar, 8)

local SideListLayout = Instance.new("UIListLayout", Sidebar)
SideListLayout.Padding = UDim.new(0, 10)
SideListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.Size = UDim2.new(1, -140, 1, -40)
ContentHolder.Position = UDim2.new(0, 140, 0, 40)
ContentHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
addRoundedCorners(ContentHolder, 8)

-- Tabs container and logic
local Tabs = {}
local currentTab

function UILib:AddTab(name, iconId)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Text = "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.AutoButtonColor = false
    addRoundedCorners(btn, 6)

    -- Add icon image if iconId is provided
    if iconId then
        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0, 4, 0.5, -12)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(iconId)
    end

    local tabFrame = Instance.new("Frame", ContentHolder)
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false

    btn.MouseButton1Click:Connect(function()
        if currentTab then
            -- Tween out old tab
            TweenService:Create(currentTab, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            currentTab.Visible = false
        end
        tabFrame.Visible = true
        -- Tween in new tab
        tabFrame.BackgroundTransparency = 0
        currentTab = tabFrame

        -- Highlight selected button
        for _, b in ipairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)

    if #Tabs == 0 then
        -- Auto select first tab
        btn:MouseButton1Click()
    end

    table.insert(Tabs, {Name = name, Button = btn, Frame = tabFrame})

    return tabFrame
end

-- Keybind toggle UI visibility
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

return UILib
