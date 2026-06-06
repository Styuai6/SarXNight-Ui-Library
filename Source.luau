local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local SarXNightLib = {
	Elements = {}, ThemeObjects = {}, Connections = {}, Flags = {},
	Themes = {
		Default = { -- SarXNight Purple & Night
			Main = Color3.fromRGB(22, 22, 34), Second = Color3.fromRGB(30, 30, 46),
			Stroke = Color3.fromRGB(56, 56, 86), Divider = Color3.fromRGB(56, 56, 86),
			Text = Color3.fromRGB(238, 238, 248), TextDark = Color3.fromRGB(165, 165, 190),
			Accent = Color3.fromRGB(135, 105, 240)
		},
		Dark = {
			Main = Color3.fromRGB(16, 16, 16), Second = Color3.fromRGB(24, 24, 24),
			Stroke = Color3.fromRGB(50, 50, 50), Divider = Color3.fromRGB(50, 50, 50),
			Text = Color3.fromRGB(240, 240, 240), TextDark = Color3.fromRGB(160, 160, 160),
			Accent = Color3.fromRGB(0, 170, 255)
		}
	},
	SelectedTheme = "Default", Folder = nil, SaveCfg = false
}

local Sarx = Instance.new("ScreenGui")
Sarx.Name = "SarXNight"
Sarx.IgnoreGuiInset = true
if syn then
	syn.protect_gui(Sarx); Sarx.Parent = game.CoreGui
else
	Sarx.Parent = gethui() or game.CoreGui
end

for _, Interface in ipairs((gethui() or game.CoreGui):GetChildren()) do
	if Interface.Name == Sarx.Name and Interface ~= Sarx then Interface:Destroy() end
end

function SarXNightLib:IsRunning()
	return Sarx.Parent == (gethui() or game:GetService("CoreGui"))
end

local function AddConnection(Signal, Function)
	if not SarXNightLib:IsRunning() then return end
	local c = Signal:Connect(Function)
	table.insert(SarXNightLib.Connections, c)
	return c
end

task.spawn(function()
	while SarXNightLib:IsRunning() do wait() end
	for _, c in next, SarXNightLib.Connections do c:Disconnect() end
end)

-- FIXED dragging (clean offset, mobile + desktop)
local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true; MousePos = Input.Position; FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do Object[i] = v end
	for _, v in next, Children or {} do v.Parent = Object end
	return Object
end
local function CreateElement(n, f) SarXNightLib.Elements[n] = function(...) return f(...) end end
local function MakeElement(n, ...) return SarXNightLib.Elements[n](...) end
local function SetProps(e, p) for k, v in next, p do e[k] = v end return e end
local function SetChildren(e, c) for _, ch in next, c do ch.Parent = e end return e end
local function Round(n, f)
	local r = math.floor(n/f + (math.sign(n) * 0.5)) * f
	if r < 0 then r = r + f end
	return r
end

local function ReturnProperty(o)
	if o:IsA("Frame") or o:IsA("TextButton") then return "BackgroundColor3" end
	if o:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if o:IsA("UIStroke") then return "Color" end
	if o:IsA("TextLabel") or o:IsA("TextBox") then return "TextColor3" end
	if o:IsA("ImageLabel") or o:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
	if not SarXNightLib.ThemeObjects[Type] then SarXNightLib.ThemeObjects[Type] = {} end
	table.insert(SarXNightLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = SarXNightLib.Themes[SarXNightLib.SelectedTheme][Type]
	Object:SetAttribute("ThemeType", Type)
	return Object
end

local function SetTheme()
	for Name, Type in pairs(SarXNightLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = SarXNightLib.Themes[SarXNightLib.SelectedTheme][Name]
		end
	end
end

local function PackColor(c) return {R = c.R * 255, G = c.G * 255, B = c.B * 255} end
local function UnpackColor(c) return Color3.fromRGB(c.R, c.G, c.B) end

local function LoadCfg(Config)
	for a, b in next, HttpService:JSONDecode(Config) do
		if SarXNightLib.Flags[a] then
			task.spawn(function()
				if SarXNightLib.Flags[a].Type == "Colorpicker" then
					SarXNightLib.Flags[a]:Set(UnpackColor(b))
				else
					SarXNightLib.Flags[a]:Set(b)
				end
			end)
		end
	end
end

local function SaveCfg(Name)
	local Data = {}
	for i, v in pairs(SarXNightLib.Flags) do
		if v.Save then
			Data[i] = (v.Type == "Colorpicker") and PackColor(v.Value) or v.Value
		end
	end
	if writefile then writefile(SarXNightLib.Folder .. "/" .. Name .. ".txt", HttpService:JSONEncode(Data)) end
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}
local function CheckKey(t, k) for _, v in next, t do if v == k then return true end end end

-- Base elements
CreateElement("Corner", function(s, o) return Create("UICorner", {CornerRadius = UDim.new(s or 0, o or 10)}) end)
CreateElement("Stroke", function(c, t) return Create("UIStroke", {Color = c or Color3.fromRGB(255,255,255), Thickness = t or 1}) end)
CreateElement("List", function(s, o) return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(s or 0, o or 0)}) end)
CreateElement("Padding", function(b, l, r, t) return Create("UIPadding", {PaddingBottom = UDim.new(0, b or 4), PaddingLeft = UDim.new(0, l or 4), PaddingRight = UDim.new(0, r or 4), PaddingTop = UDim.new(0, t or 4)}) end)
CreateElement("TFrame", function() return Create("Frame", {BackgroundTransparency = 1}) end)
CreateElement("Frame", function(c) return Create("Frame", {BackgroundColor3 = c or Color3.fromRGB(255,255,255), BorderSizePixel = 0}) end)
CreateElement("RoundFrame", function(c, s, o) return Create("Frame", {BackgroundColor3 = c or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(s, o)})}) end)
CreateElement("Button", function() return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0}) end)
CreateElement("ScrollFrame", function(c, w) return Create("ScrollingFrame", {BackgroundTransparency = 1, ScrollBarImageColor3 = c, BorderSizePixel = 0, ScrollBarThickness = w, CanvasSize = UDim2.new(0,0,0,0)}) end)
CreateElement("Image", function(id) return Create("ImageLabel", {Image = id, BackgroundTransparency = 1}) end)
CreateElement("Label", function(t, ts, tr) return Create("TextLabel", {Text = t or "", TextColor3 = Color3.fromRGB(240,240,240), TextTransparency = tr or 0, TextSize = ts or 15, Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left}) end)

-- Notifications
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8)})
}), {Position = UDim2.new(1, -25, 1, -25), Size = UDim2.new(0, IsMobile and 250 or 300, 1, -25), AnchorPoint = Vector2.new(1, 1), Parent = Sarx})

function SarXNightLib:MakeNotification(c)
	task.spawn(function()
		c.Name = c.Name or "Notification"; c.Content = c.Content or "Test"
		c.Image = c.Image or "rbxassetid://4384403532"; c.Time = c.Time or 5
		local T = self.Themes[self.SelectedTheme]
		local P = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
		local F = SetChildren(SetProps(MakeElement("RoundFrame", T.Second, 0, 10), {
			Parent = P, Size = UDim2.new(1,0,0,0), Position = UDim2.new(1,-55,0,0), AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", T.Accent, 1.2), MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", c.Image), {Size = UDim2.new(0,20,0,20), ImageColor3 = T.Text, Name = "Icon"}),
			SetProps(MakeElement("Label", c.Name, 15), {Size = UDim2.new(1,-30,0,20), Position = UDim2.new(0,30,0,0), Font = Enum.Font.GothamBold, TextColor3 = T.Text, Name = "Title"}),
			SetProps(MakeElement("Label", c.Content, 14), {Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,25), Font = Enum.Font.GothamSemibold, Name = "Content", AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = T.TextDark, TextWrapped = true})
		})
		TweenService:Create(F, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
		wait(c.Time - 0.88)
		TweenService:Create(F.Icon, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
		TweenService:Create(F, TweenInfo.new(0.8), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(F.UIStroke, TweenInfo.new(0.6), {Transparency = 0.9}):Play()
		TweenService:Create(F.Title, TweenInfo.new(0.6), {TextTransparency = 0.4}):Play()
		TweenService:Create(F.Content, TweenInfo.new(0.6), {TextTransparency = 0.5}):Play()
		wait(0.05)
		F:TweenPosition(UDim2.new(1,20,0,0), 'In', 'Quint', 0.8, true)
		wait(1.35); F:Destroy()
	end)
end

function SarXNightLib:Init()
	if SarXNightLib.SaveCfg then
		pcall(function()
			if isfile and isfile(SarXNightLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(SarXNightLib.Folder .. "/" .. game.GameId .. ".txt"))
				SarXNightLib:MakeNotification({Name = "Configuration", Content = "Auto-loaded config for game " .. game.GameId .. ".", Time = 5})
			end
		end)
	end
end

function SarXNightLib:SetTheme(name)
	if SarXNightLib.Themes[name] then
		SarXNightLib.SelectedTheme = name
		SetTheme()
	end
end

--========================================================--
-- WINDOW
--========================================================--
function SarXNightLib:MakeWindow(WindowConfig)
	local FirstTab, Minimized, UIHidden = true, false, false
	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "SarXNight Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.InterfaceId = WindowConfig.InterfaceId or "SarXNight"
	if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
	WindowConfig.IntroText = WindowConfig.IntroText or "SarXNight Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.ToggleKey = WindowConfig.ToggleKey or Enum.KeyCode.RightShift
	SarXNightLib.Folder = WindowConfig.ConfigFolder
	SarXNightLib.SaveCfg = WindowConfig.SaveConfig
	SarXNightLib.InterfaceId = WindowConfig.InterfaceId

	if WindowConfig.SaveConfig and isfolder and not isfolder(WindowConfig.ConfigFolder) then
		makefolder(WindowConfig.ConfigFolder)
	end

	local winW = IsMobile and 480 or 615
	local winH = IsMobile and 300 or 344
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
	winW = math.min(winW, vp.X - 20); winH = math.min(winH, vp.Y - 20)

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {Size = UDim2.new(1,0,1,-50)}), {
		MakeElement("List"), MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")
	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0)}), {
		AddThemeObject(SetProps(MakeElement("Label", "✕", 18), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Ico"}), "Text")
	})
	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0)}), {
		AddThemeObject(SetProps(MakeElement("Label", "—", 18), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Ico"}), "Text")
	})
	local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50)})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {Size = UDim2.new(0,150,1,-50), Position = UDim2.new(0,0,0,50)}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,10)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0)}), "Stroke"),
		TabHolder
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {Size = UDim2.new(1,-30,2,0), Position = UDim2.new(0,25,0,-24), Font = Enum.Font.GothamBlack, TextSize = 20}), "Text")
	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1)}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
		Parent = Sarx, Position = UDim2.new(0.5,-winW/2,0.5,-winH/2), Size = UDim2.new(0,winW,0,winH), ClipsDescendants = true, Visible = false
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50), Name = "TopBar"}), {
			WindowName, WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 7), {Size = UDim2.new(0,70,0,30), Position = UDim2.new(1,-90,0,10)}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(0.5,0,0,0)}), "Stroke"),
				CloseBtn, MinimizeBtn
			}), "Second"),
		}),
		DragPoint, WindowStuff
	}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		SetProps(MakeElement("Image", WindowConfig.Icon), {Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,25,0,15), Parent = MainWindow.TopBar})
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	-- Mobile floating toggle
	local MobileToggle = SetChildren(SetProps(MakeElement("RoundFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent, 1, 0), {
		Size = UDim2.new(0,48,0,48), Position = UDim2.new(0,12,0.4,0), Parent = Sarx, Visible = false
	}), {
		AddThemeObject(MakeElement("Stroke"), "Stroke"),
		SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Btn"}),
		SetProps(MakeElement("Label", "≡", 26), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(255,255,255)})
	})
	AddDraggingFunctionality(MobileToggle, MobileToggle)
	AddConnection(MobileToggle.Btn.MouseButton1Click, function()
		MainWindow.Visible = not MainWindow.Visible
	end)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false; UIHidden = true
		SarXNightLib:MakeNotification({Name = "Interface Hidden", Content = IsMobile and "Tap ≡ to reopen." or "Tap " .. WindowConfig.ToggleKey.Name .. " to reopen.", Time = 5})
		WindowConfig.CloseCallback()
	end)
	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == WindowConfig.ToggleKey and UIHidden then MainWindow.Visible = true end
	end)
	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0,winW,0,winH)}):Play()
			MinimizeBtn.Ico.Text = "—"; wait(.02)
			MainWindow.ClipsDescendants = false; WindowStuff.Visible = true; WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true; WindowTopBarLine.Visible = false; MinimizeBtn.Ico.Text = "▢"
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1); WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	-- Loading screen (FIX: mobile toggle only appears AFTER loading finishes)
	local function LoadSequence()
		local T = SarXNightLib.Themes[SarXNightLib.SelectedTheme]
		local Overlay = SetChildren(SetProps(MakeElement("RoundFrame", T.Main, 0, 12), {
			Parent = Sarx, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,320,0,160)
		}), {
			MakeElement("Stroke", T.Accent, 1),
			SetProps(MakeElement("Image", WindowConfig.IntroIcon), {Name = "Logo", AnchorPoint = Vector2.new(0.5,0), Position = UDim2.new(0.5,0,0,22), Size = UDim2.new(0,36,0,36), ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = 1}),
			SetProps(MakeElement("Label", WindowConfig.IntroText, 18), {Name = "Txt", Size = UDim2.new(1,-20,0,24), Position = UDim2.new(0,10,0,70), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(255,255,255), TextTransparency = 1}),
			SetChildren(SetProps(MakeElement("RoundFrame", T.Stroke, 0, 4), {Name = "BarBg", Size = UDim2.new(1,-40,0,8), Position = UDim2.new(0,20,1,-30)}), {
				SetProps(MakeElement("RoundFrame", T.Accent, 0, 4), {Name = "Fill", Size = UDim2.new(0,0,1,0)})
			})
		})
		TweenService:Create(Overlay.Logo, TweenInfo.new(.4), {ImageTransparency = 0}):Play()
		TweenService:Create(Overlay.Txt, TweenInfo.new(.4), {TextTransparency = 0}):Play()
		TweenService:Create(Overlay.BarBg.Fill, TweenInfo.new(2, Enum.EasingStyle.Quad), {Size = UDim2.new(1,0,1,0)}):Play()
		wait(2.1)
		TweenService:Create(Overlay, TweenInfo.new(.4), {BackgroundTransparency = 1}):Play()
		TweenService:Create(Overlay.UIStroke, TweenInfo.new(.4), {Transparency = 1}):Play()
		TweenService:Create(Overlay.Logo, TweenInfo.new(.4), {ImageTransparency = 1}):Play()
		TweenService:Create(Overlay.Txt, TweenInfo.new(.4), {TextTransparency = 1}):Play()
		wait(0.4); Overlay:Destroy()
	end

	-- FIX: show UI/toggle only after loading completes (no early appearance)
	task.spawn(function()
		if WindowConfig.IntroEnabled then LoadSequence() end
		MainWindow.Visible = true
		if IsMobile then MobileToggle.Visible = true end
	end)

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,0,30), Parent = TabHolder}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,10,0.5,0), ImageTransparency = 0.4, Name = "Ico"}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0, TabConfig.Icon ~= "" and 35 or 12, 0, 0), Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"}), "Text")
		})

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
			Size = UDim2.new(1,-150,1,-50), Position = UDim2.new(0,150,0,50), Parent = MainWindow, Visible = false, Name = "ItemContainer"
		}), {MakeElement("List", 0, 6), MakeElement("Padding", 15, 10, 10, 15)}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0; TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack; Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25), {TextTransparency = 0.4}):Play()
				end
			end
			for _, IC in next, MainWindow:GetChildren() do
				if IC.Name == "ItemContainer" then IC.Visible = false end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack; Container.Visible = true
		end)

		local ItemParent = Container
		local ElementFunction = {}

		local function Hover(Frame, Click)
			local T = SarXNightLib.Themes[SarXNightLib.SelectedTheme]
			AddConnection(Click.MouseEnter, function() TweenService:Create(Frame, TweenInfo.new(0.25), {BackgroundColor3 = T.Accent}):Play() end)
			AddConnection(Click.MouseLeave, function() TweenService:Create(Frame, TweenInfo.new(0.25), {BackgroundColor3 = T.Second}):Play() end)
		end

		function ElementFunction:AddLabel(Text)
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			return {Set = function(_, t) F.Content.Text = t end}
		end

		function ElementFunction:AddParagraph(Text, Content)
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", Text or "Text", 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Title"}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "", 13), {Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,26), Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			AddConnection(F.Content:GetPropertyChangedSignal("Text"), function()
				F.Content.Size = UDim2.new(1,-24,0,F.Content.TextBounds.Y)
				F.Size = UDim2.new(1,0,0,F.Content.TextBounds.Y + 35)
			end)
			F.Content.Text = Content or "Content"
			return {Set = function(_, t) F.Content.Text = t end}
		end

		function ElementFunction:AddParagraphImage(C)
			C = C or {}
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.7, Parent = ItemParent}), {
				MakeElement("Padding", 10, 10, 10, 10), MakeElement("List", 0, 6), AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			local Img = SetChildren(SetProps(MakeElement("Image", C.Image or ""), {Size = UDim2.new(1,0,0,C.ImageHeight or 120), ScaleType = Enum.ScaleType.Crop, LayoutOrder = 1, Parent = F}), {MakeElement("Corner", 0, 6)})
			local Title = AddThemeObject(SetProps(MakeElement("Label", C.Title or "Title", 15), {Size = UDim2.new(1,0,0,18), Font = Enum.Font.GothamBold, LayoutOrder = 2, Parent = F}), "Text")
			local Body = AddThemeObject(SetProps(MakeElement("Label", C.Content or "Content", 13), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LayoutOrder = 3, Parent = F}), "TextDark")
			return {SetImage = function(i) Img.Image = i end, SetTitle = function(t) Title.Text = t end, SetContent = function(t) Body.Text = t end}
		end

		function ElementFunction:AddParagraphUpdateLog(C)
			C = C or {}
			local T = SarXNightLib.Themes[SarXNightLib.SelectedTheme]
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.7, Parent = ItemParent}), {
				MakeElement("Padding", 10, 10, 10, 10), MakeElement("List", 0, 6), MakeElement("Stroke", T.Accent, 1)
			}), "Second")
			local H = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,22), LayoutOrder = 1, Parent = F})
			AddThemeObject(SetProps(MakeElement("Label", C.Title or "Update Log", 15), {Size = UDim2.new(0.7,0,1,0), Font = Enum.Font.GothamBold, Parent = H}), "Text")
			SetProps(MakeElement("Label", C.Version or "v1.0.0", 13), {Size = UDim2.new(0.3,0,1,0), Position = UDim2.new(0.7,0,0,0), Font = Enum.Font.GothamBold, TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = H})
			if C.Image then
				SetChildren(SetProps(MakeElement("Image", C.Image), {Size = UDim2.new(1,0,0,C.ImageHeight or 110), ScaleType = Enum.ScaleType.Crop, LayoutOrder = 2, Parent = F}), {MakeElement("Corner", 0, 6)})
			end
			local Body = AddThemeObject(SetProps(MakeElement("Label", C.Content or "- Added features\n- Fixed bugs", 13), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LayoutOrder = 3, Parent = F}), "TextDark")
			return {SetContent = function(t) Body.Text = t end}
		end

		function ElementFunction:AddParagraphSocials(C)
			C = C or {}
			local T = SarXNightLib.Themes[SarXNightLib.SelectedTheme]
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.7, Parent = ItemParent}), {
				MakeElement("Padding", 10, 10, 10, 10), MakeElement("List", 0, 6), AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			AddThemeObject(SetProps(MakeElement("Label", C.Title or "Socials", 15), {Size = UDim2.new(1,0,0,18), Font = Enum.Font.GothamBold, LayoutOrder = 1, Parent = F}), "Text")
			local order = 2
			for _, s in pairs(C.Socials or {}) do
				local Row = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", T.Main, 0, 4), {Size = UDim2.new(1,0,0,28), LayoutOrder = order, Parent = F}), {
					SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"}),
					AddThemeObject(SetProps(MakeElement("Label", s.Name or "Social", 13), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0,8,0,0), Font = Enum.Font.GothamMedium}), "Text"),
					SetProps(MakeElement("Label", "Copy Link", 13), {Size = UDim2.new(0.5,-8,1,0), Position = UDim2.new(0.5,0,0,0), Font = Enum.Font.GothamMedium, TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right, Name = "CopyLbl"})
				}), "Main")
				order += 1
				AddConnection(Row.Click.MouseButton1Click, function()
					if setclipboard then setclipboard(s.Link or "") end
					Row.CopyLbl.Text = "Copied!"
					SarXNightLib:MakeNotification({Name = "Copied", Content = (s.Name or "Link") .. " copied!", Time = 2})
					wait(1.5); Row.CopyLbl.Text = "Copy Link"
				end)
			end
			return F
		end

		function ElementFunction:AddButton(C)
			C = C or {}; C.Name = C.Name or "Button"; C.Callback = C.Callback or function() end
			local Btn = {}
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,33), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), Click
			}), "Second")
			Hover(F, Click)
			AddConnection(Click.MouseButton1Up, function() task.spawn(C.Callback) end)
			function Btn:Set(t) F.Content.Text = t end
			return Btn
		end

		function ElementFunction:AddToggle(C)
			C = C or {}; C.Name = C.Name or "Toggle"; C.Default = C.Default or false
			C.Callback = C.Callback or function() end
			C.Color = C.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent
			C.Save = C.Save or false
			local Toggle = {Value = C.Default, Save = C.Save, Type = "Toggle"}
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local Box = SetChildren(SetProps(MakeElement("RoundFrame", C.Color, 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-24,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}), {
				SetProps(MakeElement("Stroke"), {Color = C.Color, Name = "Stroke", Transparency = 0.5}),
				SetProps(MakeElement("Image", "rbxassetid://3944680095"), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), ImageColor3 = Color3.fromRGB(255,255,255), Name = "Ico"})
			})
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), Box, Click
			}), "Second")
			function Toggle:Set(v)
				Toggle.Value = v
				local Div = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Divider
				local Str = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Stroke
				TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = v and C.Color or Div}):Play()
				TweenService:Create(Box.Stroke, TweenInfo.new(0.3), {Color = v and C.Color or Str}):Play()
				TweenService:Create(Box.Ico, TweenInfo.new(0.3), {ImageTransparency = v and 0 or 1, Size = v and UDim2.new(0,20,0,20) or UDim2.new(0,8,0,8)}):Play()
				C.Callback(v)
			end
			Toggle:Set(Toggle.Value)
			Hover(F, Click)
			AddConnection(Click.MouseButton1Up, function() SaveCfg(game.GameId); Toggle:Set(not Toggle.Value) end)
			if C.Flag then SarXNightLib.Flags[C.Flag] = Toggle end
			return Toggle
		end

		function ElementFunction:AddSlider(C)
			C = C or {}; C.Name = C.Name or "Slider"; C.Min = C.Min or 0; C.Max = C.Max or 100
			C.Increment = C.Increment or 1; C.Default = C.Default or 50; C.Callback = C.Callback or function() end
			C.ValueName = C.ValueName or ""; C.Color = C.Color or SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent; C.Save = C.Save or false
			local Slider = {Value = C.Default, Save = C.Save}
			local Dragging = false
			local Drag = SetProps(MakeElement("RoundFrame", C.Color, 0, 5), {Size = UDim2.new(0,0,1,0), BackgroundTransparency = 0.3, ClipsDescendants = true})
			local Bar = SetChildren(SetProps(MakeElement("RoundFrame", C.Color, 0, 5), {Size = UDim2.new(1,-75,0,26), Position = UDim2.new(0,12,0,30), BackgroundTransparency = 0.9}), {
				SetProps(MakeElement("Stroke"), {Color = C.Color}), Drag
			})
			local ValueBox = AddThemeObject(Create("TextBox", {Size = UDim2.new(0,55,0,26), Position = UDim2.new(1,-67,0,30), BackgroundColor3 = SarXNightLib.Themes[SarXNightLib.SelectedTheme].Main, Text = tostring(Slider.Value), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false}, {Create("UICorner", {CornerRadius = UDim.new(0,4)})}), "Text")
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(1,0,0,65), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), Bar, ValueBox
			}), "Second")
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true end end)
			Bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
			UserInputService.InputChanged:Connect(function(i)
				if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					local s = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					Slider:Set(C.Min + ((C.Max - C.Min) * s)); SaveCfg(game.GameId)
				end
			end)
			ValueBox.FocusLost:Connect(function()
				local n = tonumber(ValueBox.Text)
				if n then Slider:Set(n); SaveCfg(game.GameId) else ValueBox.Text = tostring(Slider.Value) end
			end)
			function Slider:Set(v)
				self.Value = math.clamp(Round(v, C.Increment), C.Min, C.Max)
				TweenService:Create(Drag, TweenInfo.new(.15), {Size = UDim2.fromScale((self.Value - C.Min) / (C.Max - C.Min), 1)}):Play()
				ValueBox.Text = tostring(self.Value) .. (C.ValueName ~= "" and (" " .. C.ValueName) or "")
				C.Callback(self.Value)
			end
			Slider:Set(Slider.Value)
			if C.Flag then SarXNightLib.Flags[C.Flag] = Slider end
			return Slider
		end

		-- DROPDOWN: NO LIMIT, max 3 visible, scrolls
		function ElementFunction:AddDropdown(C)
			C = C or {}; C.Name = C.Name or "Dropdown"; C.Options = C.Options or {}
			C.Default = C.Default or ""; C.Callback = C.Callback or function() end; C.Save = C.Save or false
			local Dropdown = {Value = C.Default, Options = C.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = C.Save}
			local MaxElements = 3
			if not table.find(Dropdown.Options, Dropdown.Value) then Dropdown.Value = "..." end
			local List = MakeElement("List")
			local Cont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Accent, 4), {List}), {Position = UDim2.new(0,0,0,38), Size = UDim2.new(1,0,1,-38), ClipsDescendants = true}), "Divider")
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent, ClipsDescendants = true}), {
				Cont,
				SetProps(SetChildren(MakeElement("TFrame"), {
					AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "▼", 14), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(1,-30,0.5,0), TextXAlignment = Enum.TextXAlignment.Center, Name = "Ico"}), "TextDark"),
					AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {Size = UDim2.new(1,-50,1,0), Font = Enum.Font.Gotham, Name = "Selected", TextXAlignment = Enum.TextXAlignment.Right}), "TextDark"),
					AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke"),
					Click
				}), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner")
			}), "Second")
			AddConnection(List:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				Cont.CanvasSize = UDim2.new(0,0,0,List.AbsoluteContentSize.Y)
			end)
			local function AddOptions(Options)
				for _, Option in pairs(Options) do
					local O = AddThemeObject(SetProps(SetChildren(MakeElement("Button", SarXNightLib.Themes[SarXNightLib.SelectedTheme].Main), {
						MakeElement("Corner", 0, 6),
						AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-8,1,0), Name = "Title"}), "Text")
					}), {Parent = Cont, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, ClipsDescendants = true}), "Divider")
					AddConnection(O.MouseButton1Click, function() Dropdown:Set(Option); SaveCfg(game.GameId) end)
					Dropdown.Buttons[Option] = O
				end
			end
			function Dropdown:Refresh(Options, Delete)
				if Delete then
					for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
					table.clear(Dropdown.Options); table.clear(Dropdown.Buttons)
				end
				Dropdown.Options = Options; AddOptions(Dropdown.Options)
			end
			function Dropdown:Set(Value)
				if not table.find(Dropdown.Options, Value) then
					Dropdown.Value = "..."; F.F.Selected.Text = Dropdown.Value
					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
					end
					return
				end
				Dropdown.Value = Value; F.F.Selected.Text = Dropdown.Value
				for _, v in pairs(Dropdown.Buttons) do
					TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
					TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
				end
				TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15), {BackgroundTransparency = 0}):Play()
				TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15), {TextTransparency = 0}):Play()
				return C.Callback(Dropdown.Value)
			end
			AddConnection(Click.MouseButton1Click, function()
				Dropdown.Toggled = not Dropdown.Toggled
				F.F.Line.Visible = Dropdown.Toggled
				TweenService:Create(F.F.Ico, TweenInfo.new(.15), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
				local h = #Dropdown.Options > MaxElements and (38 + (MaxElements * 28)) or (List.AbsoluteContentSize.Y + 38)
				TweenService:Create(F, TweenInfo.new(.15), {Size = Dropdown.Toggled and UDim2.new(1,0,0,h) or UDim2.new(1,0,0,38)}):Play()
			end)
			Dropdown:Refresh(Dropdown.Options, false)
			Dropdown:Set(Dropdown.Value)
			if C.Flag then SarXNightLib.Flags[C.Flag] = Dropdown end
			return Dropdown
		end

		function ElementFunction:AddBind(C)
			C.Name = C.Name or "Bind"; C.Default = C.Default or Enum.KeyCode.Unknown
			C.Hold = C.Hold or false; C.Callback = C.Callback or function() end; C.Save = C.Save or false
			local Bind = {Value, Binding = false, Type = "Bind", Save = C.Save}
			local Holding = false
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local Box = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 14), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Value"}), "Text")
			}), "Main")
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), Box, Click
			}), "Second")
			AddConnection(Box.Value:GetPropertyChangedSignal("Text"), function()
				TweenService:Create(Box, TweenInfo.new(0.25), {Size = UDim2.new(0, Box.Value.TextBounds.X + 16, 0, 24)}):Play()
			end)
			AddConnection(Click.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					if Bind.Binding then return end
					Bind.Binding = true; Box.Value.Text = ""
				end
			end)
			AddConnection(UserInputService.InputBegan, function(i)
				if UserInputService:GetFocusedTextBox() then return end
				if (i.KeyCode.Name == Bind.Value or i.UserInputType.Name == Bind.Value) and not Bind.Binding then
					if C.Hold then Holding = true; C.Callback(Holding) else C.Callback() end
				elseif Bind.Binding then
					local Key
					pcall(function() if not CheckKey(BlacklistedKeys, i.KeyCode) then Key = i.KeyCode end end)
					pcall(function() if CheckKey(WhitelistedMouse, i.UserInputType) and not Key then Key = i.UserInputType end end)
					Key = Key or Bind.Value; Bind:Set(Key); SaveCfg(game.GameId)
				end
			end)
			AddConnection(UserInputService.InputEnded, function(i)
				if i.KeyCode.Name == Bind.Value or i.UserInputType.Name == Bind.Value then
					if C.Hold and Holding then Holding = false; C.Callback(Holding) end
				end
			end)
			function Bind:Set(Key)
				Bind.Binding = false; Bind.Value = Key or Bind.Value
				Bind.Value = Bind.Value.Name or Bind.Value; Box.Value.Text = Bind.Value
			end
			Bind:Set(C.Default)
			if C.Flag then SarXNightLib.Flags[C.Flag] = Bind end
			return Bind
		end

		function ElementFunction:AddTextbox(C)
			C = C or {}; C.Name = C.Name or "Textbox"; C.Default = C.Default or ""
			C.TextDisappear = C.TextDisappear or false; C.Callback = C.Callback or function() end
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local TB = AddThemeObject(Create("TextBox", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), PlaceholderColor3 = Color3.fromRGB(210,210,210), PlaceholderText = "Input", Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Center, TextSize = 14, ClearTextOnFocus = false}), "Text")
			local Cont = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"), TB
			}), "Main")
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"), Cont, Click
			}), "Second")
			AddConnection(TB:GetPropertyChangedSignal("Text"), function()
				TweenService:Create(Cont, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TB.TextBounds.X + 16, 0, 24)}):Play()
			end)
			AddConnection(TB.FocusLost, function()
				C.Callback(TB.Text)
				if C.TextDisappear then TB.Text = "" end
			end)
			TB.Text = C.Default
			AddConnection(Click.MouseButton1Up, function() TB:CaptureFocus() end)
		end

		function ElementFunction:AddColorpicker(C)
			C = C or {}; C.Name = C.Name or "Colorpicker"; C.Default = C.Default or Color3.fromRGB(255,255,255)
			C.Callback = C.Callback or function() end; C.Save = C.Save or false
			local ColorH, ColorS, ColorV = 1, 1, 1
			local ColorInput, HueInput
			local Colorpicker = {Value = C.Default, Toggled = false, Type = "Colorpicker", Save = C.Save}
			local ColorSel = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
			local HueSel = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0.5,0,1 - select(1, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
			local Color = Create("ImageLabel", {Size = UDim2.new(1,-25,1,0), Visible = false, Image = "rbxassetid://4155801252"}, {Create("UICorner", {CornerRadius = UDim.new(0,5)}), ColorSel})
			local Hue = Create("Frame", {Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Visible = false}, {
				Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234,255,0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21,255,0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,17,255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255,0,251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,4))}}),
				Create("UICorner", {CornerRadius = UDim.new(0,5)}), HueSel
			})
			local PCont = Create("Frame", {Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32), BackgroundTransparency = 1, ClipsDescendants = true}, {
				Hue, Color, Create("UIPadding", {PaddingLeft = UDim.new(0,35), PaddingRight = UDim.new(0,35), PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,17)})
			})
			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
			local Box = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
			local F = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
				SetProps(SetChildren(MakeElement("TFrame"), {
					AddThemeObject(SetProps(MakeElement("Label", C.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
					Box, Click,
					AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke")
				}), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
				PCont, AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")
			AddConnection(Click.MouseButton1Click, function()
				Colorpicker.Toggled = not Colorpicker.Toggled
				TweenService:Create(F, TweenInfo.new(.15), {Size = Colorpicker.Toggled and UDim2.new(1,0,0,148) or UDim2.new(1,0,0,38)}):Play()
				Color.Visible = Colorpicker.Toggled; Hue.Visible = Colorpicker.Toggled; F.F.Line.Visible = Colorpicker.Toggled
			end)
			local function Upd()
				Box.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
				Colorpicker:Set(Box.BackgroundColor3); C.Callback(Box.BackgroundColor3); SaveCfg(game.GameId)
			end
			AddConnection(Color.InputBegan, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					if ColorInput then ColorInput:Disconnect() end
					ColorInput = AddConnection(RunService.RenderStepped, function()
						local px = IsMobile and UserInputService:GetMouseLocation().X or Mouse.X
						local py = IsMobile and UserInputService:GetMouseLocation().Y or Mouse.Y
						local cx = math.clamp(px - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X
						local cy = math.clamp(py - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y
						ColorSel.Position = UDim2.new(cx, 0, cy, 0); ColorS = cx; ColorV = 1 - cy; Upd()
					end)
				end
			end)
			AddConnection(Color.InputEnded, function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and ColorInput then ColorInput:Disconnect() end end)
			AddConnection(Hue.InputBegan, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					if HueInput then HueInput:Disconnect() end
					HueInput = AddConnection(RunService.RenderStepped, function()
						local py = IsMobile and UserInputService:GetMouseLocation().Y or Mouse.Y
						local hy = math.clamp(py - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y
						HueSel.Position = UDim2.new(0.5, 0, hy, 0); ColorH = 1 - hy; Upd()
					end)
				end
			end)
			AddConnection(Hue.InputEnded, function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and HueInput then HueInput:Disconnect() end end)
			function Colorpicker:Set(v) Colorpicker.Value = v; Box.BackgroundColor3 = v; C.Callback(v) end
			Colorpicker:Set(Colorpicker.Value)
			if C.Flag then SarXNightLib.Flags[C.Flag] = Colorpicker end
			return Colorpicker
		end

		return ElementFunction
	end
	return TabFunction
end

function SarXNightLib:Destroy() Sarx:Destroy() end

return SarXNightLib
