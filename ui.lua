local UILib = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUILib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "My Executor UI"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIList.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame

function UILib:AddButton(text, callback)
	local Button = Instance.new("TextButton")
	Button.Text = text
	Button.Size = UDim2.new(1, 0, 0, 30)
	Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.Font = Enum.Font.SourceSans
	Button.TextSize = 18
	Button.Parent = ContentFrame

	Button.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
end

function UILib:AddToggle(text, default, callback)
	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1, 0, 0, 30)
	Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Toggle.TextColor3 = Color3.new(1, 1, 1)
	Toggle.Font = Enum.Font.SourceSans
	Toggle.TextSize = 18
	Toggle.Parent = ContentFrame

	local state = default
	local function updateText()
		Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
	end

	updateText()

	Toggle.MouseButton1Click:Connect(function()
		state = not state
		updateText()
		pcall(callback, state)
	end)
end

function UILib:AddLabel(text)
	local Label = Instance.new("TextLabel")
	Label.Text = text
	Label.Size = UDim2.new(1, 0, 0, 30)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 18
	Label.Parent = ContentFrame
end

return UILib
