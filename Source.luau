--[[
    SarXNightLib v1.1.0
    Inspired by Orion UI Library (Discontinued)
    Reworked design - Mobile friendly - No Premium - No Feather Icons
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local SarXNightLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(28, 26, 38),
			Second = Color3.fromRGB(36, 33, 50),
			Stroke = Color3.fromRGB(70, 64, 95),
			Divider = Color3.fromRGB(70, 64, 95),
			Text = Color3.fromRGB(240, 240, 245),
			TextDark = Color3.fromRGB(155, 150, 175),
			Accent = Color3.fromRGB(120, 90, 220)
		},
		Dark = {
			Main = Color3.fromRGB(18, 18, 18),
			Second = Color3.fromRGB(28, 28, 28),
			Stroke = Color3.fromRGB(55, 55, 55),
			Divider = Color3.fromRGB(55, 55, 55),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150),
			Accent = Color3.fromRGB(0, 170, 255)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

-- ScreenGui setup
local SarX = Instance.new("ScreenGui")
SarX.Name = "SarXNightLib"
SarX.ResetOnSpawn = false
if syn and syn.protect_gui then
	syn.protect_gui(SarX)
	SarX.Parent = game.CoreGui
elseif gethui then
	SarX.Parent = gethui()
else
	SarX.Parent = game.CoreGui
end

-- Clean old instances
if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == SarX.Name and Interface ~= SarX then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == SarX.Name and Interface ~= SarX then
			Interface:Destroy()
		end
	end
end

function SarXNightLib:IsRunning()
	if gethui then
		return SarX.Parent == gethui()
	else
		return SarX.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if not SarXNightLib:IsRunning() then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(SarXNightLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while SarXNightLib:IsRunning() do task.wait() end
	for _, Connection in next, SarXNightLib.Connections do
		Connection:Disconnect()
	end
end)

-- FIXED dragging (supports Mouse + Touch, no broken pcall swallow)
local function AddDraggingFunctionality(DragPoint, Main)
	local Dragging, DragInput, MousePos, FramePos = false
	AddConnection(DragPoint.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	AddConnection(DragPoint.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)
	AddConnection(UserInputService.InputChanged, function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
		end
	end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	SarXNightLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	return SarXNightLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	for Property, Value in next, Props do
		Element[Property] = Value
	end
	return Element
end

local function SetChildren(Element, Children)
	for _, Child in next, Children do
		Child.Parent = Element
	end
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
	if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if Object:IsA("UIStroke") then return "Color" end
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
	if not SarXNightLib.ThemeObjects[Type] then
		SarXNightLib.ThemeObjects[Type] = {}
	end
	table.insert(SarXNightLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = SarXNightLib.Themes[SarXNightLib.SelectedTheme][Type]
	return Object
end

local function SetTheme()
	for Name, Type in pairs(SarXNightLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = SarXNightLib.Themes[SarXNightLib.SelectedTheme][Name]
		end
	end
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	for a, b in next, Data do
		if SarXNightLib.Flags[a] then
			task.spawn(function()
				if SarXNightLib.Flags[a].Type == "Colorpicker" then
					SarXNightLib.Flags[a]:Set(UnpackColor(b))
				else
					SarXNightLib.Flags[a]:Set(b)
				end
			end)
		else
			warn("SarXNightLib Config Loader - Could not find ", a, b)
		end
	end
end

local function SaveCfg(Name)
	local Data = {}
	for i, v in pairs(SarXNightLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end
	end
	if writefile then
		writefile(SarXNightLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
	end
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then return true end
	end
end

--========== BASE ELEMENTS ==========--
CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", { CornerRadius = UDim.new(Scale or 0, Offset or 10) })
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", { BackgroundTransparency = 1 })
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", { CornerRadius = UDim.new(Scale, Offset) })
	})
end)

CreateElement("Button", function()
	return Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)

CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
end)

CreateElement("Image", function(ImageID)
	return Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
end)

CreateElement("ImageButton", function(ImageID)
	return Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

--========== NOTIFICATIONS ==========--
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 8)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = SarX
})

function SarXNightLib:MakeNotification(NotificationConfig)
	task.spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second, 0, 10), {
			Parent = NotificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent, 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		task.wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		task.wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		task.wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
		task.wait(1.35)
		NotificationFrame:Destroy()
	end)
end

function SarXNightLib:Init()
	if SarXNightLib.SaveCfg then
		pcall(function()
			if isfile and isfile(SarXNightLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(SarXNightLib.Folder .. "/" .. game.GameId .. ".txt"))
				SarXNightLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)
	end
end

--========== WINDOW ==========--
function SarXNightLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "SarXNightLib"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
	WindowConfig.IntroText = WindowConfig.IntroText or "SarXNightLib"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	SarXNightLib.Folder = WindowConfig.ConfigFolder
	SarXNightLib.SaveCfg = WindowConfig.SaveConfig
	if WindowConfig.Theme then SarXNightLib.SelectedTheme = WindowConfig.Theme end

	if WindowConfig.SaveConfig then
		if makefolder and not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"),
			AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
				Size = UDim2.new(1, -20, 0, 14),
				Position = UDim2.new(0, 12, 0.5, -7),
				Font = Enum.Font.GothamBold
			}), "TextDark")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = SarX,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"),
				CloseBtn,
				MinimizeBtn
			}), "Second"),
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	-- Mobile floating toggle button (open/close)
	local MobileToggle = SetChildren(SetProps(MakeElement("Button"), {
		Parent = SarX,
		Size = UDim2.new(0, 42, 0, 42),
		Position = UDim2.new(0, 15, 0, 120),
		BackgroundTransparency = 0
	}), {
		Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
		SetProps(MakeElement("Image", "rbxassetid://8834748103"), {
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0.5, -12, 0.5, -12),
			ImageColor3 = Color3.fromRGB(255, 255, 255)
		})
	})
	MobileToggle.BackgroundColor3 = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent
	AddDraggingFunctionality(MobileToggle, MobileToggle)

	AddConnection(MobileToggle.MouseButton1Click, function()
		UIHidden = not UIHidden
		MainWindow.Visible = not UIHidden
	end)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		SarXNightLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap RightShift or the floating button to reopen.",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			UIHidden = false
			MainWindow.Visible = true
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			task.wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			task.wait(0.1)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	-- Reworked loading screen
	local function LoadSequence()
		MainWindow.Visible = false
		local Logo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = SarX,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			Size = UDim2.new(0, 50, 0, 50),
			ImageColor3 = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent,
			ImageTransparency = 1
		})
		local Text = SetProps(MakeElement("Label", WindowConfig.IntroText, 16), {
			Parent = SarX,
			Size = UDim2.new(1, 0, 0, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.55, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		local Bar = SetProps(MakeElement("RoundFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second, 0, 4), {
			Parent = SarX,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.62, 0),
			Size = UDim2.new(0, 160, 0, 6)
		})
		local Fill = SetProps(MakeElement("RoundFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent, 0, 4), {
			Parent = Bar,
			Size = UDim2.new(0, 0, 1, 0)
		})

		TweenService:Create(Logo, TweenInfo.new(.4, Enum.EasingStyle.Quad), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.42, 0)}):Play()
		task.wait(0.3)
		TweenService:Create(Text, TweenInfo.new(.4, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
		TweenService:Create(Fill, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
		task.wait(1.4)
		TweenService:Create(Logo, TweenInfo.new(.3), {ImageTransparency = 1}):Play()
		TweenService:Create(Text, TweenInfo.new(.3), {TextTransparency = 1}):Play()
		TweenService:Create(Bar, TweenInfo.new(.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(Fill, TweenInfo.new(.3), {BackgroundTransparency = 1}):Play()
		task.wait(0.35)
		MainWindow.Visible = true
		Logo:Destroy() Text:Destroy() Bar:Destroy()
	end

	if WindowConfig.IntroEnabled then LoadSequence() end

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, TabConfig.Icon ~= "" and 35 or 12, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
				end
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end)

		local ElementFunction = {}
		local ItemParent = Container

		-- LABEL
		function ElementFunction:AddLabel(Text)
			local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 0.7,
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			local LabelFunction = {}
			function LabelFunction:Set(ToChange)
				LabelFrame.Content.Text = ToChange
			end
			return LabelFunction
		end

		-- PARAGRAPH
		function ElementFunction:AddParagraph(Text, Content)
			Text = Text or "Text"
			Content = Content or "Content"
			local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 0.7,
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
					Size = UDim2.new(1, -12, 0, 14),
					Position = UDim2.new(0, 12, 0, 10),
					Font = Enum.Font.GothamBold,
					Name = "Title"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "", 13), {
					Size = UDim2.new(1, -24, 0, 0),
					Position = UDim2.new(0, 12, 0, 26),
					Font = Enum.Font.GothamSemibold,
					Name = "Content",
					TextWrapped = true
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")

			AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
				ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
				ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
			end)
			ParagraphFrame.Content.Text = Content

			local ParagraphFunction = {}
			function ParagraphFunction:Set(ToChange)
				ParagraphFrame.Content.Text = ToChange
			end
			return ParagraphFunction
		end

		-- PARAGRAPH IMAGE
		function ElementFunction:AddParagraphImage(Config)
			Config = Config or {}
			local Title = Config.Title or "Title"
			local Content = Config.Content or "Content"
			local ImageId = Config.Image or "rbxassetid://4384403532"
			local ImgHeight = Config.ImageHeight or 110

			local Frame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = ItemParent
			}), {
				MakeElement("Padding", 12, 12, 12, 12),
				MakeElement("List", 0, 8),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				SetProps(MakeElement("Image", ImageId), {
					Size = UDim2.new(1, 0, 0, ImgHeight),
					ScaleType = Enum.ScaleType.Crop,
					Name = "Img"
				}),
				AddThemeObject(SetProps(MakeElement("Label", Title, 15), {
					Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.GothamBold,
					Name = "Title"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", Content, 13), {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Font = Enum.Font.GothamSemibold,
					TextWrapped = true,
					Name = "Content"
				}), "TextDark")
			}), "Second")
			Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Frame.Img })

			return {
				SetImage = function(_, id) Frame.Img.Image = id end,
				SetTitle = function(_, t) Frame.Title.Text = t end,
				SetContent = function(_, c) Frame.Content.Text = c end
			}
		end

		-- PARAGRAPH UPDATE LOG (with optional image)
		function ElementFunction:AddParagraphUpdateLog(Config)
			Config = Config or {}
			local Title = Config.Title or "Update Log"
			local Version = Config.Version or "v1.0.0"
			local Content = Config.Content or "- Added stuff\n- Fixed bugs"
			local ImageId = Config.Image

			local Children = {
				MakeElement("Padding", 12, 12, 12, 12),
				MakeElement("List", 0, 8),
				AddThemeObject(MakeElement("Stroke", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent), "Accent"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 0, 18),
					Name = "Header"
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Title, 15), {
						Size = UDim2.new(0.6, 0, 1, 0),
						Font = Enum.Font.GothamBold
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", Version, 13), {
						Size = UDim2.new(0.4, 0, 1, 0),
						Position = UDim2.new(0.6, 0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Right,
						Font = Enum.Font.GothamBold
					}), "Accent")
				})
			}

			if ImageId then
				table.insert(Children, SetProps(MakeElement("Image", ImageId), {
					Size = UDim2.new(1, 0, 0, Config.ImageHeight or 100),
					ScaleType = Enum.ScaleType.Crop,
					Name = "Img"
				}))
			end

			table.insert(Children, AddThemeObject(SetProps(MakeElement("Label", Content, 13), {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = Enum.Font.GothamSemibold,
				TextWrapped = true,
				Name = "Content"
			}), "TextDark"))

			local Frame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = ItemParent
			}), Children), "Second")

			if Frame:FindFirstChild("Img") then
				Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Frame.Img })
			end

			return {
				SetContent = function(_, c) Frame.Content.Text = c end
			}
		end

		-- PARAGRAPH SOCIALS (copy link buttons)
		function ElementFunction:AddParagraphSocials(Config)
			Config = Config or {}
			local Title = Config.Title or "Socials"
			local Socials = Config.Socials or {}

			local Children = {
				MakeElement("Padding", 12, 12, 12, 12),
				MakeElement("List", 0, 6),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Label", Title, 15), {
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.GothamBold
				}), "Text")
			}

			local Frame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = ItemParent
			}), Children), "Second")

			for _, social in next, Socials do
				local Row = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 28),
					Parent = Frame
				}), {
					AddThemeObject(SetProps(MakeElement("Label", social.Name or "Social", 13), {
						Size = UDim2.new(0.5, 0, 1, 0),
						Position = UDim2.new(0, 8, 0, 0),
						Font = Enum.Font.GothamSemibold
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "Copy Link", 13), {
						Size = UDim2.new(0.5, -8, 1, 0),
						Position = UDim2.new(0.5, 0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Right,
						Font = Enum.Font.GothamBold,
						Name = "Copy"
					}), "Accent"),
					SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0), Name = "Click" })
				}), "Main")

				AddConnection(Row.Click.MouseButton1Click, function()
					if setclipboard then setclipboard(social.Link or "") end
					Row.Copy.Text = "Copied!"
					SarXNightLib:MakeNotification({
						Name = "Copied",
						Content = (social.Name or "Link") .. " copied to clipboard!",
						Time = 3
					})
					task.wait(1.5)
					Row.Copy.Text = "Copy Link"
				end)
			end

			return Frame
		end

		-- BUTTON
		function ElementFunction:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			ButtonConfig.Name = ButtonConfig.Name or "Button"
			ButtonConfig.Callback = ButtonConfig.Callback or function() end
			ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

			local Button = {}
			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 33),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
					Size = UDim2.new(0, 20, 0, 20),
					Position = UDim2.new(1, -30, 0, 7)
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				Click
			}), "Second")

			local function hover(d)
				local c = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second
				TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(c.R*255+d, c.G*255+d, c.B*255+d)}):Play()
			end
			AddConnection(Click.MouseEnter, function() hover(3) end)
			AddConnection(Click.MouseLeave, function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second}):Play()
			end)
			AddConnection(Click.MouseButton1Up, function()
				hover(3)
				task.spawn(ButtonConfig.Callback)
			end)
			AddConnection(Click.MouseButton1Down, function() hover(6) end)

			function Button:Set(t) ButtonFrame.Content.Text = t end
			return Button
		end

		-- TOGGLE
		function ElementFunction:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			ToggleConfig.Name = ToggleConfig.Name or "Toggle"
			ToggleConfig.Default = ToggleConfig.Default or false
			ToggleConfig.Callback = ToggleConfig.Callback or function() end
			ToggleConfig.Color = ToggleConfig.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent
			ToggleConfig.Flag = ToggleConfig.Flag or nil
			ToggleConfig.Save = ToggleConfig.Save or false

			local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -24, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5)
			}), {
				SetProps(MakeElement("Stroke"), { Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5 }),
				SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
					Size = UDim2.new(0, 20, 0, 20),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					Name = "Ico"
				})
			})

			local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 38),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				ToggleBox,
				Click
			}), "Second")

			function Toggle:Set(Value)
				Toggle.Value = Value
				TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Divider}):Play()
				TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Toggle.Value and ToggleConfig.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Stroke}):Play()
				TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
				ToggleConfig.Callback(Toggle.Value)
			end

			Toggle:Set(Toggle.Value)

			local function hover(d)
				local c = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second
				TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(c.R*255+d, c.G*255+d, c.B*255+d)}):Play()
			end
			AddConnection(Click.MouseEnter, function() hover(3) end)
			AddConnection(Click.MouseLeave, function()
				TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second}):Play()
			end)
			AddConnection(Click.MouseButton1Up, function()
				hover(3)
				SaveCfg(game.GameId)
				Toggle:Set(not Toggle.Value)
			end)
			AddConnection(Click.MouseButton1Down, function() hover(6) end)

			if ToggleConfig.Flag then SarXNightLib.Flags[ToggleConfig.Flag] = Toggle end
			return Toggle
		end

		-- SLIDER (with input box + mobile/touch support)
		function ElementFunction:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			SliderConfig.Name = SliderConfig.Name or "Slider"
			SliderConfig.Min = SliderConfig.Min or 0
			SliderConfig.Max = SliderConfig.Max or 100
			SliderConfig.Increment = SliderConfig.Increment or 1
			SliderConfig.Default = SliderConfig.Default or 50
			SliderConfig.Callback = SliderConfig.Callback or function() end
			SliderConfig.ValueName = SliderConfig.ValueName or ""
			SliderConfig.Color = SliderConfig.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent
			SliderConfig.Flag = SliderConfig.Flag or nil
			SliderConfig.Save = SliderConfig.Save or false

			local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
			local Dragging = false

			local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundTransparency = 0.3,
				ClipsDescendants = true
			}), {})

			-- Input box for typing value directly
			local ValueInput = AddThemeObject(Create("TextBox", {
				Size = UDim2.new(0, 60, 0, 20),
				Position = UDim2.new(1, -70, 0, 8),
				BackgroundTransparency = 1,
				Text = tostring(SliderConfig.Default),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				ClearTextOnFocus = false
			}), "Text")

			local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
				Size = UDim2.new(1, -24, 0, 26),
				Position = UDim2.new(0, 12, 0, 30),
				BackgroundTransparency = 0.9
			}), {
				SetProps(MakeElement("Stroke"), { Color = SliderConfig.Color }),
				AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
					Size = UDim2.new(1, -12, 0, 14),
					Position = UDim2.new(0, 12, 0, 6),
					Font = Enum.Font.GothamBold,
					Name = "Value",
					TextTransparency = 0.8
				}), "Text"),
				SliderDrag
			})

			local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(1, 0, 0, 65),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
					Size = UDim2.new(1, -80, 0, 14),
					Position = UDim2.new(0, 12, 0, 10),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				ValueInput,
				SliderBar
			}), "Second")

			-- Mobile + Mouse support
			AddConnection(SliderBar.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
				end
			end)
			AddConnection(SliderBar.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
				end
			end)
			AddConnection(UserInputService.InputChanged, function(Input)
				if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch) then
					local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
					SaveCfg(game.GameId)
				end
			end)

			-- Input box typing
			AddConnection(ValueInput.FocusLost, function()
				local num = tonumber(ValueInput.Text)
				if num then
					Slider:Set(num)
					SaveCfg(game.GameId)
				else
					ValueInput.Text = tostring(Slider.Value)
				end
			end)

			function Slider:Set(Value)
				self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
				TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
				SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
				ValueInput.Text = tostring(self.Value)
				SliderConfig.Callback(self.Value)
			end

			Slider:Set(Slider.Value)
			if SliderConfig.Flag then SarXNightLib.Flags[SliderConfig.Flag] = Slider end
			return Slider
		end

		-- DROPDOWN (max 3 visible + scroll)
		function ElementFunction:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
			DropdownConfig.Options = DropdownConfig.Options or {}
			DropdownConfig.Default = DropdownConfig.Default or ""
			DropdownConfig.Callback = DropdownConfig.Callback or function() end
			DropdownConfig.Flag = DropdownConfig.Flag or nil
			DropdownConfig.Save = DropdownConfig.Save or false

			local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
			local MaxElements = 3  -- limit 3 visible, rest scroll

			if not table.find(Dropdown.Options, Dropdown.Value) then
				Dropdown.Value = "..."
			end

			local DropdownList = MakeElement("List")
			local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Stroke, 4), {
				DropdownList
			}), {
				Parent = nil,
				Position = UDim2.new(0, 0, 0, 38),
				Size = UDim2.new(1, 0, 1, -38),
				ClipsDescendants = true
			}), "Divider")

			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 38),
				Parent = ItemParent,
				ClipsDescendants = true
			}), {
				DropdownContainer,
				SetProps(SetChildren(MakeElement("TFrame"), {
					AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(1, -30, 0.5, 0),
						ImageColor3 = Color3.fromRGB(240, 240, 240),
						Name = "Ico"
					}), "TextDark"),
					AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
						Size = UDim2.new(1, -40, 1, 0),
						Font = Enum.Font.Gotham,
						Name = "Selected",
						TextXAlignment = Enum.TextXAlignment.Right
					}), "TextDark"),
					AddThemeObject(SetProps(MakeElement("Frame"), {
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.new(0, 0, 1, -1),
						Name = "Line",
						Visible = false
					}), "Stroke"),
					Click
				}), {
					Size = UDim2.new(1, 0, 0, 38),
					ClipsDescendants = true,
					Name = "F"
				}),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner")
			}), "Second")

			AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
			end)

			local function AddOptions(Options)
				for _, Option in pairs(Options) do
					local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Second), {
						MakeElement("Corner", 0, 6),
						AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
							Position = UDim2.new(0, 8, 0, 0),
							Size = UDim2.new(1, -8, 1, 0),
							Name = "Title"
						}), "Text")
					}), {
						Parent = DropdownContainer,
						Size = UDim2.new(1, 0, 0, 28),
						BackgroundTransparency = 1,
						ClipsDescendants = true
					}), "Divider")

					AddConnection(OptionBtn.MouseButton1Click, function()
						Dropdown:Set(Option)
						SaveCfg(game.GameId)
					end)
					Dropdown.Buttons[Option] = OptionBtn
				end
			end

			function Dropdown:Refresh(Options, Delete)
				if Delete then
					for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
					table.clear(Dropdown.Options)
					table.clear(Dropdown.Buttons)
				end
				Dropdown.Options = Options
				AddOptions(Dropdown.Options)
			end

			function Dropdown:Set(Value)
				if not table.find(Dropdown.Options, Value) then
					Dropdown.Value = "..."
					DropdownFrame.F.Selected.Text = Dropdown.Value
					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
					end
					return
				end
				Dropdown.Value = Value
				DropdownFrame.F.Selected.Text = Dropdown.Value
				for _, v in pairs(Dropdown.Buttons) do
					TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
					TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
				end
				TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15), {BackgroundTransparency = 0}):Play()
				TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15), {TextTransparency = 0}):Play()
				return DropdownConfig.Callback(Dropdown.Value)
			end

			AddConnection(Click.MouseButton1Click, function()
				Dropdown.Toggled = not Dropdown.Toggled
				DropdownFrame.F.Line.Visible = Dropdown.Toggled
				TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
				-- Always cap at MaxElements (3), rest scrolls
				if #Dropdown.Options > MaxElements then
					TweenService:Create(DropdownFrame, TweenInfo.new(.15), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
				else
					TweenService:Create(DropdownFrame, TweenInfo.new(.15), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
				end
			end)

			Dropdown:Refresh(Dropdown.Options, false)
			Dropdown:Set(Dropdown.Value)
			if DropdownConfig.Flag then SarXNightLib.Flags[DropdownConfig.Flag] = Dropdown end
			return Dropdown
		end

		-- KEYBIND
		function ElementFunction:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			BindConfig.Name = BindConfig.Name or "Bind"
			BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
			BindConfig.Hold = BindConfig.Hold or false
			BindConfig.Callback = BindConfig.Callback or function() end
			BindConfig.Flag = BindConfig.Flag or nil
			BindConfig.Save = BindConfig.Save or false

			local Bind = {Value = nil, Binding = false, Type = "Bind", Save = BindConfig.Save}
			local Holding = false
			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					Name = "Value"
				}), "Text")
			}), "Main")

			local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 38),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				BindBox,
				Click
			}), "Second")

			AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
				TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
			end)

			AddConnection(Click.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch then
					if Bind.Binding then return end
					Bind.Binding = true
					BindBox.Value.Text = "..."
				end
			end)

			AddConnection(UserInputService.InputBegan, function(Input)
				if UserInputService:GetFocusedTextBox() then return end
				if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
					if BindConfig.Hold then
						Holding = true
						BindConfig.Callback(Holding)
					else
						BindConfig.Callback()
					end
				elseif Bind.Binding then
					local Key
					pcall(function()
						if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end
					end)
					pcall(function()
						if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end
					end)
					Key = Key or Bind.Value
					Bind:Set(Key)
					SaveCfg(game.GameId)
				end
			end)

			AddConnection(UserInputService.InputEnded, function(Input)
				if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
					if BindConfig.Hold and Holding then
						Holding = false
						BindConfig.Callback(Holding)
					end
				end
			end)

			function Bind:Set(Key)
				Bind.Binding = false
				Bind.Value = Key or Bind.Value
				Bind.Value = Bind.Value.Name or Bind.Value
				BindBox.Value.Text = Bind.Value
			end

			Bind:Set(BindConfig.Default)
			if BindConfig.Flag then SarXNightLib.Flags[BindConfig.Flag] = Bind end
			return Bind
		end

		-- TEXTBOX (Input)
		function ElementFunction:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			TextboxConfig.Name = TextboxConfig.Name or "Textbox"
			TextboxConfig.Default = TextboxConfig.Default or ""
			TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
			TextboxConfig.Callback = TextboxConfig.Callback or function() end

			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local TextboxActual = AddThemeObject(Create("TextBox", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
				PlaceholderText = "Input",
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextSize = 14,
				ClearTextOnFocus = false
			}), "Text")

			local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				TextboxActual
			}), "Main")

			local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 38),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				TextContainer,
				Click
			}), "Second")

			AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
				TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
			end)

			AddConnection(TextboxActual.FocusLost, function()
				TextboxConfig.Callback(TextboxActual.Text)
				if TextboxConfig.TextDisappear then TextboxActual.Text = "" end
			end)
			TextboxActual.Text = TextboxConfig.Default

			AddConnection(Click.MouseButton1Up, function()
				TextboxActual:CaptureFocus()
			end)

			return { Set = function(_, t) TextboxActual.Text = t end, Get = function() return TextboxActual.Text end }
		end

		-- COLORPICKER (mobile + mouse support)
		function ElementFunction:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
			ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
			ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
			ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
			ColorpickerConfig.Save = ColorpickerConfig.Save or false

			local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
			ColorH = 1 - ColorH
			local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

			local ColorSelection = Create("ImageLabel", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(select(2, Color3.toHSV(Colorpicker.Value)), 0, 1 - select(3, Color3.toHSV(Colorpicker.Value)), 0),
				ScaleType = Enum.ScaleType.Fit,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "http://www.roblox.com/asset/?id=4805639000"
			})

			local HueSelection = Create("ImageLabel", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value)), 0),
				ScaleType = Enum.ScaleType.Fit,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "http://www.roblox.com/asset/?id=4805639000"
			})

			local Color = Create("ImageLabel", {
				Size = UDim2.new(1, -25, 1, 0),
				Visible = false,
				Image = "rbxassetid://4155801252"
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
				ColorSelection
			})

			local Hue = Create("Frame", {
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -20, 0, 0),
				Visible = false
			}, {
				Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
					ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
					ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
					ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
					ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
					ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
				}}),
				Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
				HueSelection
			})

			local ColorpickerContainer = Create("Frame", {
				Position = UDim2.new(0, 0, 0, 32),
				Size = UDim2.new(1, 0, 1, -32),
				BackgroundTransparency = 1,
				ClipsDescendants = true
			}, {
				Hue, Color,
				Create("UIPadding", {
					PaddingLeft = UDim.new(0, 35),
					PaddingRight = UDim.new(0, 35),
					PaddingBottom = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 17)
				})
			})

			local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

			local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Main")

			local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 38),
				Parent = ItemParent
			}), {
				SetProps(SetChildren(MakeElement("TFrame"), {
					AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					ColorpickerBox,
					Click,
					AddThemeObject(SetProps(MakeElement("Frame"), {
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.new(0, 0, 1, -1),
						Name = "Line",
						Visible = false
					}), "Stroke")
				}), {
					Size = UDim2.new(1, 0, 0, 38),
					ClipsDescendants = true,
					Name = "F"
				}),
				ColorpickerContainer,
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")

			AddConnection(Click.MouseButton1Click, function()
				Colorpicker.Toggled = not Colorpicker.Toggled
				TweenService:Create(ColorpickerFrame, TweenInfo.new(.15), {Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
				Color.Visible = Colorpicker.Toggled
				Hue.Visible = Colorpicker.Toggled
				ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
			end)

			local function UpdateColorPicker()
				ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
				Colorpicker:Set(ColorpickerBox.BackgroundColor3)
				ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
				SaveCfg(game.GameId)
			end

			local ColorInput, HueInput

			-- Color area (mouse + touch)
			AddConnection(Color.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					if ColorInput then ColorInput:Disconnect() end
					ColorInput = AddConnection(RunService.RenderStepped, function()
						local mx = input.UserInputType == Enum.UserInputType.Touch and UserInputService:GetMouseLocation().X or Mouse.X
						local my = input.UserInputType == Enum.UserInputType.Touch and UserInputService:GetMouseLocation().Y or Mouse.Y
						local ColorX = math.clamp(mx - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X
						local ColorY = math.clamp(my - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y
						ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
						ColorS = ColorX
						ColorV = 1 - ColorY
						UpdateColorPicker()
					end)
				end
			end)
			AddConnection(Color.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					if ColorInput then ColorInput:Disconnect() end
				end
			end)

			-- Hue area (mouse + touch)
			AddConnection(Hue.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					if HueInput then HueInput:Disconnect() end
					HueInput = AddConnection(RunService.RenderStepped, function()
						local my = input.UserInputType == Enum.UserInputType.Touch and UserInputService:GetMouseLocation().Y or Mouse.Y
						local HueY = math.clamp(my - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y
						HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
						ColorH = 1 - HueY
						UpdateColorPicker()
					end)
				end
			end)
			AddConnection(Hue.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					if HueInput then HueInput:Disconnect() end
				end
			end)

			function Colorpicker:Set(Value)
				Colorpicker.Value = Value
				ColorpickerBox.BackgroundColor3 = Colorpicker.Value
				ColorpickerConfig.Callback(Colorpicker.Value)
			end

			Colorpicker:Set(Colorpicker.Value)
			if ColorpickerConfig.Flag then SarXNightLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
			return Colorpicker
		end

		return ElementFunction
	end

	return TabFunction
end

function SarXNightLib:Destroy()
	SarX:Destroy()
end

function SarXNightLib:SetTheme(name)
	if SarXNightLib.Themes[name] then
		SarXNightLib.SelectedTheme = name
		SetTheme()
	end
end

return SarXNightLib
