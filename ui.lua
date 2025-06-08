local UILib = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Settings persistence
local SETTINGS_FILE = "executor_ui_settings"
local settings = {}

-- Load saved settings
pcall(function()
    settings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
end)

-- Save settings
local function save()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
end

-- Create GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUILib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Draggable Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Dragging logic
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

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "Executor UI"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Tab container & sidebar
local Tabs = {}
local currentTab
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundTransparency = 1

local SideListLayout = Instance.new("UIListLayout", Sidebar)
SideListLayout.Padding = UDim.new(0, 5)
SideListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.Size = UDim2.new(1, -120, 1, -40)
ContentHolder.Position = UDim2.new(0, 120, 0, 40)
ContentHolder.BackgroundTransparency = 1

-- Notification Drawer
local NotificationFrame = Instance.new("Frame", ScreenGui)
NotificationFrame.Position = UDim2.new(0, 10, 0, 10)
NotificationFrame.Size = UDim2.new(0, 250, 0, 0)
NotificationFrame.BackgroundTransparency = 1

function UILib:CreateNotification(title, text, duration)
    local notif = Instance.new("Frame", NotificationFrame)
    notif.Size = UDim2.new(1, 0, 0, 60)
    notif.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notif.BorderSizePixel = 0
    
    local T = Instance.new("TextLabel", notif)
    T.Text = title
    T.Font = Enum.Font.SourceSansBold
    T.TextSize = 18
    T.TextColor3 = Color3.new(1,1,1)
    T.BackgroundTransparency = 1
    T.Size = UDim2.new(1, 0, 0, 25)

    local B = Instance.new("TextLabel", notif)
    B.Text = text
    B.Font = Enum.Font.SourceSans
    B.TextSize = 14
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundTransparency = 1
    B.Position = UDim2.new(0,0,0,25)
    B.Size = UDim2.new(1,0,0,30)

    -- Slide down
    notif:TweenSize(UDim2.new(1,0,0,60), "Out", "Quad", 0.2,true)
    
    -- Auto-remove
    delay(duration, function()
        notif:TweenSize(UDim2.new(1,0,0,0), "In", "Quad", 0.2,true)
        wait(0.3)
        notif:Destroy()
    end)
end

-- Add Tab
function UILib:CreateTab(name)
    local tabFrame = Instance.new("Frame", ContentHolder)
    tabFrame.Size = UDim2.new(1,0,1,0)
    tabFrame.Visible = false
    
    local btn = Instance.new("TextButton", Sidebar)
    btn.Text = name
    btn.Size = UDim2.new(1,0,0,30)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Visible = false end
        tabFrame.Visible = true
        currentTab = tabFrame
    end)
    Tabs[name] = tabFrame
    
    -- make first tab default
if not currentTab then
    tabFrame.Visible = true
    currentTab = tabFrame
end

    
    return tabFrame
end

-- UI Elements
function UILib:AddButton(tab, text, callback)
    local btn = Instance.new("TextButton", tab)
    btn.Text = text
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0,10,0, (#tab:GetChildren())*35)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

function UILib:AddToggle(tab, text, default, callback)
    local state = settings[text] ~= nil and settings[text] or default
    settings[text] = state
    
    local btn = Instance.new("TextButton", tab)
    btn.Text = text .. ": " .. (state and "ON" or "OFF")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0,10,0,(#tab:GetChildren())*35)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        state = not state
        settings[text] = state
        save()
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        pcall(callback, state)
    end)
end

function UILib:AddSlider(tab, text, min, max, default, callback)
    settings[text] = settings[text] or default
    local frame = Instance.new("Frame", tab)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0,10,0,(#tab:GetChildren())*55)
    
    local label = Instance.new("TextLabel", frame)
    label.Text = text .. ": " .. settings[text]
    label.Size = UDim2.new(1,0,0,20)
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    
    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new((settings[text]-min)/(max-min), 0, 0, 10)
    slider.Position = UDim2.new(0,0,0,25)
    slider.BackgroundColor3 = Color3.fromRGB(120,120,120)
    
    local dragging = false
    slider.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (i.Position.X - slider.AbsolutePosition.X) / frame.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = math.floor(min + rel*(max-min))
            settings[text] = val
            save()
            label.Text = text .. ": " .. val
            slider.Size = UDim2.new(rel, 0,0,10)
            pcall(callback, val)
        end
    end)
end

function UILib:AddDropdown(tab, text, options, callback)
    settings[text] = settings[text] or options[1]
    local label = Instance.new("TextLabel", tab)
    label.Text = text..": "..settings[text]
    label.Size = UDim2.new(1,-20,0,30)
    label.Position = UDim2.new(0,10,0,(#tab:GetChildren())*35)
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    
    local dropdown = Instance.new("TextButton", tab)
    dropdown.Text = "▼"
    dropdown.Size = UDim2.new(0,30,0,30)
    dropdown.Position = UDim2.new(1,-40,(#tab:GetChildren())*35)
    dropdown.MouseButton1Click:Connect(function()
        local list = Instance.new("Frame", tab)
        list.Size = UDim2.new(0,150,0,#options*25)
        list.Position = dropdown.Position+UDim2.new(0,0,0,30)
        list.BackgroundColor3 = Color3.fromRGB(60,60,60)
        for i,opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", list)
            optBtn.Text = opt
            optBtn.Size = UDim2.new(1,0,0,25)
            optBtn.Position = UDim2.new(0,0,0,(i-1)*25)
            optBtn.MouseButton1Click:Connect(function()
                settings[text] = opt
                save()
                label.Text = text..": "..opt
                pcall(callback, opt)
                list:Destroy()
            end)
        end
    end)
end

function UILib:AddKeybind(tab, text, defaultKey, callback)
    settings[text] = settings[text] or defaultKey

    local label = Instance.new("TextLabel", tab)
    label.Text = text .. ": [" .. settings[text] .. "]"
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, (#tab:GetChildren()) * 35)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local changeBtn = Instance.new("TextButton", tab)
    changeBtn.Text = "Change"
    changeBtn.Size = UDim2.new(0, 60, 0, 30)
    changeBtn.Position = UDim2.new(1, -70, 0, (#tab:GetChildren() - 1) * 35)
    changeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    changeBtn.TextColor3 = Color3.new(1, 1, 1)

    changeBtn.MouseButton1Click:Connect(function()
        label.Text = text .. ": [Press any key]"
        local conn
        conn = UserInput.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                settings[text] = keyName
                save()
                label.Text = text .. ": [" .. keyName .. "]"
                conn:Disconnect()
            end
        end)
    end)

    -- Key trigger listener
    UserInput.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name == settings[text] then
                pcall(callback)
            end
        end
    end)
end


-- Export
return UILib
