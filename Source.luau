local SarXNightLib = {}
SarXNightLib.__index = SarXNightLib

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- Detect mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Themes (2023 redesign palette)
local Themes = {
    default = { -- SarXNight
        Main       = Color3.fromRGB(24, 24, 36),
        Secondary  = Color3.fromRGB(32, 32, 48),
        Tertiary   = Color3.fromRGB(42, 42, 62),
        Element    = Color3.fromRGB(48, 48, 70),
        Accent     = Color3.fromRGB(130, 100, 235),
        AccentDark = Color3.fromRGB(95, 70, 180),
        Text       = Color3.fromRGB(238, 238, 248),
        SubText    = Color3.fromRGB(165, 165, 190),
        Stroke     = Color3.fromRGB(58, 58, 88),
        Toggle     = Color3.fromRGB(66, 66, 96),
    },
    dark = {
        Main       = Color3.fromRGB(18, 18, 18),
        Secondary  = Color3.fromRGB(26, 26, 26),
        Tertiary   = Color3.fromRGB(36, 36, 36),
        Element    = Color3.fromRGB(44, 44, 44),
        Accent     = Color3.fromRGB(0, 170, 255),
        AccentDark = Color3.fromRGB(0, 130, 200),
        Text       = Color3.fromRGB(240, 240, 240),
        SubText    = Color3.fromRGB(160, 160, 160),
        Stroke     = Color3.fromRGB(52, 52, 52),
        Toggle     = Color3.fromRGB(58, 58, 58),
    },
}

-- Utility
local function Create(class, props)
    local inst = Instance.new(class)
    for prop, val in pairs(props or {}) do
        if prop ~= "Parent" then
            inst[prop] = val
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent,
    })
end

local function Stroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Padding(parent, all)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all),
        PaddingRight = UDim.new(0, all),
        Parent = parent,
    })
end

-- Make a frame draggable (mobile + desktop)
local function MakeDraggable(dragHandle, target)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--========================================================--
-- CONFIG (JSON) HELPERS
--========================================================--
local function ensureFolder(folder)
    if not folder or folder == "" then return end
    pcall(function()
        if isfolder and not isfolder(folder) then
            makefolder(folder)
        end
    end)
end

local function saveConfig(path, data)
    local ok = pcall(function()
        if writefile then
            writefile(path, HttpService:JSONEncode(data))
        end
    end)
    return ok
end

local function loadConfig(path)
    local data
    pcall(function()
        if readfile and isfile and isfile(path) then
            data = HttpService:JSONDecode(readfile(path))
        end
    end)
    return data or {}
end

--========================================================--
-- LOADING SCREEN
--========================================================--
local function ShowLoadingScreen(parentGui, Theme, cfg, onDone)
    cfg = cfg or {}
    local title = cfg.Title or "SarXNightLib"
    local subtitle = cfg.Subtitle or "Loading..."
    local duration = cfg.Duration or 2.5

    local overlay = Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = parentGui,
    })

    local box = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 150),
        Position = UDim2.new(0.5, -160, 0.5, -75),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = overlay,
    })
    Corner(box, 12)
    Stroke(box, Theme.Accent, 1)

    local tLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 24),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        ZIndex = 102,
        Parent = box,
    })

    local sLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 58),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 102,
        Parent = box,
    })

    local barBg = Create("Frame", {
        Size = UDim2.new(1, -40, 0, 8),
        Position = UDim2.new(0, 20, 1, -32),
        BackgroundColor3 = Theme.Toggle,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = box,
    })
    Corner(barBg, 4)

    local barFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 103,
        Parent = barBg,
    })
    Corner(barFill, 4)

    task.spawn(function()
        Tween(barFill, duration, {Size = UDim2.new(1, 0, 1, 0)})
        task.wait(duration)
        Tween(overlay, 0.4, {BackgroundTransparency = 1})
        Tween(box, 0.4, {BackgroundTransparency = 1})
        Tween(tLbl, 0.4, {TextTransparency = 1})
        Tween(sLbl, 0.4, {TextTransparency = 1})
        task.wait(0.4)
        overlay:Destroy()
        if onDone then onDone() end
    end)
end

--========================================================--
-- WINDOW
--========================================================--
function SarXNightLib:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "SarXNightLib"
    local themeName = config.Theme or "default"
    local Theme = Themes[themeName] or Themes.default

    local self = setmetatable({}, SarXNightLib)
    self.Theme = Theme
    self.ThemeName = themeName
    self.Tabs = {}
    self.Notifications = {}
    self.Flags = {}            -- registered config-aware elements
    self.ConfigFolder = config.ConfigFolder or "SarXNightLib"
    self.ConfigName = config.ConfigName or "config"
    self.ConfigPath = self.ConfigFolder .. "/" .. self.ConfigName .. ".json"
    ensureFolder(self.ConfigFolder)

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "SarXNightLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    -- Protect / parent
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = CoreGui
        end
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.ScreenGui = ScreenGui

    -- Mobile-friendly sizing
    local winW = IsMobile and 460 or 580
    local winH = IsMobile and 320 or 400
    -- clamp to viewport
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    winW = math.min(winW, vp.X - 20)
    winH = math.min(winH, vp.Y - 20)

    -- Main Window Frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, winW, 0, winH),
        Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    Corner(Main, 10)
    Stroke(Main, Theme.Stroke, 1)
    self.Main = Main

    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Corner(TopBar, 10)
    Create("Frame", { -- mask bottom corners
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    MakeDraggable(TopBar, Main)

    local Title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = windowName,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = TopBar,
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -32, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(210, 65, 65),
        Text = "✕",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Corner(CloseBtn, 7)

    -- Minimize Button
    local MinBtn = Create("TextButton", {
        Name = "Min",
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -64, 0.5, -13),
        BackgroundColor3 = Theme.Tertiary,
        Text = "—",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Corner(MinBtn, 7)

    -- ===== Tab Sidebar Container (left) =====
    local sidebarW = IsMobile and 130 or 150
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarW, 1, -48),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Corner(Sidebar, 8)

    -- Search bar for tabs
    local SearchBox = Create("TextBox", {
        Name = "TabSearch",
        Size = UDim2.new(1, -12, 0, 26),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Theme.Tertiary,
        Text = "",
        PlaceholderText = "🔍 Search tabs...",
        PlaceholderColor3 = Theme.SubText,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Parent = Sidebar,
    })
    Corner(SearchBox, 6)
    Create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = SearchBox})

    -- Tab List (scrolling)
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -8, 1, -42),
        Position = UDim2.new(0, 4, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList,
    })
    Create("UIPadding", {PaddingTop = UDim.new(0,2), PaddingLeft = UDim.new(0,2), PaddingRight = UDim.new(0,2), Parent = TabList})
    self.TabList = TabList

    -- Search filter logic
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchBox.Text:lower()
        for _, t in pairs(self.Tabs) do
            if q == "" then
                t.Button.Visible = true
            else
                t.Button.Visible = t.Name:lower():find(q, 1, true) ~= nil
            end
        end
    end)

    -- Content Container (right side)
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -(sidebarW + 24), 1, -48),
        Position = UDim2.new(0, sidebarW + 16, 0, 44),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Corner(Content, 8)
    self.Content = Content

    -- Notification Holder
    local NotifHolder = Create("Frame", {
        Name = "NotifHolder",
        Size = UDim2.new(0, IsMobile and 240 or 280, 1, -20),
        Position = UDim2.new(1, -(IsMobile and 250 or 290), 0, 10),
        BackgroundTransparency = 1,
        Parent = ScreenGui,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = NotifHolder,
    })
    self.NotifHolder = NotifHolder

    -- ===== Mobile floating toggle button (open/close UI) =====
    local MobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0, 12, 0.4, 0),
        BackgroundColor3 = Theme.Accent,
        Text = "≡",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        BorderSizePixel = 0,
        Visible = IsMobile,
        Parent = ScreenGui,
    })
    Corner(MobileToggle, 24)
    Stroke(MobileToggle, Theme.Stroke, 1)
    MakeDraggable(MobileToggle, MobileToggle)
    MobileToggle.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    -- Close logic
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    -- Minimize logic
    local minimized = false
    local savedSize = Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Sidebar.Visible = false
            Content.Visible = false
            Tween(Main, 0.2, {Size = UDim2.new(0, savedSize.X.Offset, 0, 38)})
        else
            Tween(Main, 0.2, {Size = savedSize})
            task.wait(0.2)
            Sidebar.Visible = true
            Content.Visible = true
        end
    end)

    -- Toggle UI with keybind (desktop)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            Main.Visible = not Main.Visible
        end
    end)

    -- Loading screen
    if config.LoadingScreen ~= false then
        local ls = type(config.LoadingScreen) == "table" and config.LoadingScreen or {}
        ls.Title = ls.Title or windowName
        Main.Visible = false
        if IsMobile then MobileToggle.Visible = false end
        ShowLoadingScreen(ScreenGui, Theme, ls, function()
            Main.Visible = true
            if IsMobile then MobileToggle.Visible = true end
        end)
    end

    return self
end

--========================================================--
-- CONFIG: register / save / load
--========================================================--
function SarXNightLib:_register(flag, getter, setter)
    if flag then
        self.Flags[flag] = {Get = getter, Set = setter}
    end
end

function SarXNightLib:SaveConfig()
    local data = {}
    for flag, ctrl in pairs(self.Flags) do
        local ok, v = pcall(ctrl.Get)
        if ok then
            -- serialize Color3
            if typeof(v) == "Color3" then
                data[flag] = {__type = "Color3", r = v.R, g = v.G, b = v.B}
            elseif typeof(v) == "EnumItem" then
                data[flag] = {__type = "Enum", name = v.Name}
            else
                data[flag] = v
            end
        end
    end
    return saveConfig(self.ConfigPath, data)
end

function SarXNightLib:LoadConfig()
    local data = loadConfig(self.ConfigPath)
    for flag, v in pairs(data) do
        local ctrl = self.Flags[flag]
        if ctrl then
            if type(v) == "table" and v.__type == "Color3" then
                pcall(ctrl.Set, Color3.new(v.r, v.g, v.b))
            elseif type(v) == "table" and v.__type == "Enum" then
                pcall(ctrl.Set, Enum.KeyCode[v.name])
            else
                pcall(ctrl.Set, v)
            end
        end
    end
end

--========================================================--
-- TAB
--========================================================--
function SarXNightLib:CreateTab(config)
    config = config or {}
    local Theme = self.Theme
    local tabName = type(config) == "string" and config or (config.Name or "Tab")
    local Lib = self

    local tabObj = {}
    tabObj.Lib = self
    tabObj.Name = tabName

    -- Tab Button
    local TabBtn = Create("TextButton", {
        Name = tabName,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = 0.4,
        Text = tabName,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = self.TabList,
    })
    Corner(TabBtn, 7)

    -- Tab Page
    local Page = Create("ScrollingFrame", {
        Name = tabName .. "_Page",
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Content,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Page,
    })
    Create("UIPadding", {PaddingRight = UDim.new(0, 4), Parent = Page})

    tabObj.Page = Page
    tabObj.Button = TabBtn

    -- Tab switch logic
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Button, 0.15, {BackgroundTransparency = 0.4, TextColor3 = Theme.SubText})
        end
        Page.Visible = true
        Tween(TabBtn, 0.15, {BackgroundTransparency = 0, TextColor3 = Theme.Text})
    end)

    table.insert(self.Tabs, tabObj)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.TextColor3 = Theme.Text
    end

    -- ================= ELEMENTS =================

    -- BUTTON
    function tabObj:Button(cfg)
        cfg = cfg or {}
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            Text = cfg.Name or "Button",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = Page,
        })
        Corner(btn, 7)
        Stroke(btn, Theme.Stroke, 1)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Element})
        end)
        btn.MouseButton1Click:Connect(function()
            Tween(btn, 0.08, {BackgroundColor3 = Theme.AccentDark})
            task.wait(0.08)
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Element})
            if cfg.Callback then cfg.Callback() end
        end)
        return btn
    end

    -- TOGGLE
    function tabObj:Toggle(cfg)
        cfg = cfg or {}
        local state = cfg.Default or false

        local holder = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)

        Create("TextLabel", {
            Size = UDim2.new(1, -64, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Toggle",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

        local switch = Create("Frame", {
            Size = UDim2.new(0, 42, 0, 22),
            Position = UDim2.new(1, -52, 0.5, -11),
            BackgroundColor3 = state and Theme.Accent or Theme.Toggle,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(switch, 11)

        local knob = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = switch,
        })
        Corner(knob, 8)

        local function set(val)
            state = val
            Tween(switch, 0.15, {BackgroundColor3 = state and Theme.Accent or Theme.Toggle})
            Tween(knob, 0.15, {Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)})
            if cfg.Callback then cfg.Callback(state) end
        end

        holder.MouseButton1Click:Connect(function()
            set(not state)
        end)

        if cfg.Default and cfg.Callback then cfg.Callback(state) end

        local api = {
            Set = set,
            Get = function() return state end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    -- SLIDER (now with editable input box)
    function tabObj:Slider(cfg)
        cfg = cfg or {}
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min
        local decimals = cfg.Decimals or 0

        local function round(v)
            local m = 10 ^ decimals
            return math.floor(v * m + 0.5) / m
        end

        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)

        Create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 20),
            Position = UDim2.new(0, 12, 0, 5),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Slider",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

        -- editable value box
        local valBox = Create("TextBox", {
            Size = UDim2.new(0, 56, 0, 20),
            Position = UDim2.new(1, -62, 0, 5),
            BackgroundColor3 = Theme.Secondary,
            Text = tostring(value),
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Parent = holder,
        })
        Corner(valBox, 4)

        local bar = Create("Frame", {
            Size = UDim2.new(1, -24, 0, 6),
            Position = UDim2.new(0, 12, 1, -16),
            BackgroundColor3 = Theme.Toggle,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(bar, 3)

        local fill = Create("Frame", {
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = bar,
        })
        Corner(fill, 3)

        local dragging = false

        local function apply(v, fireCb)
            value = round(math.clamp(v, min, max))
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valBox.Text = tostring(value)
            if fireCb and cfg.Callback then cfg.Callback(value) end
        end

        local function update(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            apply(min + (max - min) * rel, true)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)

        -- input box typing
        valBox.FocusLost:Connect(function()
            local num = tonumber(valBox.Text)
            if num then
                apply(num, true)
            else
                valBox.Text = tostring(value)
            end
        end)

        local api = {
            Set = function(v) apply(v, true) end,
            Get = function() return value end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    -- COLORPICKER
    function tabObj:ColorPicker(cfg)
        cfg = cfg or {}
        local color = cfg.Default or Color3.fromRGB(255, 255, 255)

        local holder = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ClipsDescendants = false,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)

        Create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Color",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

        local preview = Create("Frame", {
            Size = UDim2.new(0, 32, 0, 20),
            Position = UDim2.new(1, -42, 0.5, -10),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(preview, 4)
        Stroke(preview, Theme.Stroke, 1)

        local picker = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Theme.Main,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 5,
            Parent = holder,
        })
        Corner(picker, 6)
        Stroke(picker, Theme.Stroke, 1)

        local h, s, v = Color3.toHSV(color)

        local function makeSlider(name, yPos, default, callback)
            Create("TextLabel", {
                Size = UDim2.new(0, 20, 0, 16),
                Position = UDim2.new(0, 8, 0, yPos),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ZIndex = 6,
                Parent = picker,
            })
            local sBar = Create("Frame", {
                Size = UDim2.new(1, -40, 0, 8),
                Position = UDim2.new(0, 32, 0, yPos + 4),
                BackgroundColor3 = Theme.Toggle,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = picker,
            })
            Corner(sBar, 4)
            local sFill = Create("Frame", {
                Size = UDim2.new(default, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 7,
                Parent = sBar,
            })
            Corner(sFill, 4)

            local drag = false
            local function upd(input)
                local rel = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                sFill.Size = UDim2.new(rel, 0, 1, 0)
                callback(rel)
            end
            sBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    drag = true upd(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then drag = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if drag and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then upd(input) end
            end)
            return sFill
        end

        local function refresh()
            color = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = color
            if cfg.Callback then cfg.Callback(color) end
        end

        makeSlider("H", 8, h, function(r) h = r refresh() end)
        makeSlider("S", 32, s, function(r) s = r refresh() end)
        makeSlider("V", 56, v, function(r) v = r refresh() end)

        local open = false
        holder.MouseButton1Click:Connect(function()
            open = not open
            picker.Visible = true
            Tween(picker, 0.2, {Size = UDim2.new(1, 0, 0, open and 84 or 0)})
            if not open then
                task.wait(0.2)
                picker.Visible = false
            end
        end)

        local api = {
            Set = function(c)
                color = c
                h, s, v = Color3.toHSV(c)
                preview.BackgroundColor3 = c
                if cfg.Callback then cfg.Callback(c) end
            end,
            Get = function() return color end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    -- DROPDOWN (overlay popup, never clipped, scrollable, max 3 visible)
    function tabObj:Dropdown(cfg)
        cfg = cfg or {}
        local options = cfg.Options or {}
        local selected = cfg.Default or (options[1] or "None")
        local MAX_VISIBLE = 3
        local OPT_HEIGHT = 26
        local OPT_PAD = 2

        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = holder,
        })

        Create("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Dropdown",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

        local selLabel = Create("TextLabel", {
            Size = UDim2.new(0.5, -40, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(selected),
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            Parent = holder,
        })

        local arrow = Create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -26, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Theme.SubText,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = holder,
        })

        -- popup parented to ScreenGui so it's NEVER clipped
        local popup = Create("ScrollingFrame", {
            Name = "DropdownPopup",
            Size = UDim2.new(0, 100, 0, 0),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 50,
            Parent = Lib.ScreenGui,
        })
        Corner(popup, 6)
        Stroke(popup, Theme.Accent, 1)
        Create("UIListLayout", {
            Padding = UDim.new(0, OPT_PAD),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = popup,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
            Parent = popup,
        })

        local open = false

        local function closePopup()
            open = false
            Tween(arrow, 0.2, {Rotation = 0})
            Tween(popup, 0.18, {Size = UDim2.new(0, popup.Size.X.Offset, 0, 0)})
            task.wait(0.18)
            popup.Visible = false
        end

        local function positionPopup()
            local absPos = holder.AbsolutePosition
            local absSize = holder.AbsoluteSize
            popup.Size = UDim2.new(0, absSize.X, 0, 0)
            popup.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
        end

        local function buildOptions()
            for _, c in pairs(popup:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, opt in pairs(options) do
                local oBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, OPT_HEIGHT),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = tostring(opt),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    BorderSizePixel = 0,
                    ZIndex = 51,
                    Parent = popup,
                })
                Corner(oBtn, 4)
                oBtn.MouseEnter:Connect(function()
                    Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Accent})
                end)
                oBtn.MouseLeave:Connect(function()
                    Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Tertiary})
                end)
                oBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLabel.Text = tostring(opt)
                    task.spawn(closePopup)
                    if cfg.Callback then cfg.Callback(opt) end
                end)
            end
        end
        buildOptions()

        btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                positionPopup()
                popup.Visible = true
                -- max 3 visible, rest scrolls
                local count = math.min(#options, MAX_VISIBLE)
                local height = (count * OPT_HEIGHT) + ((count - 1) * OPT_PAD) + 6
                Tween(arrow, 0.2, {Rotation = 180})
                Tween(popup, 0.2, {Size = UDim2.new(0, holder.AbsoluteSize.X, 0, height)})
            else
                task.spawn(closePopup)
            end
        end)

        -- reposition popup if window moves while open
        holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if open then positionPopup() end
        end)

        -- close when clicking elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if open and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) then
                local m = input.Position
                local hp, hs = holder.AbsolutePosition, holder.AbsoluteSize
                local pp, ps = popup.AbsolutePosition, popup.AbsoluteSize
                local inHolder = m.X >= hp.X and m.X <= hp.X+hs.X and m.Y >= hp.Y and m.Y <= hp.Y+hs.Y
                local inPopup = m.X >= pp.X and m.X <= pp.X+ps.X and m.Y >= pp.Y and m.Y <= pp.Y+ps.Y
                if not inHolder and not inPopup then
                    task.spawn(closePopup)
                end
            end
        end)

        local api = {
            Set = function(vv)
                selected = vv
                selLabel.Text = tostring(vv)
                if cfg.Callback then cfg.Callback(vv) end
            end,
            Get = function() return selected end,
            Refresh = function(newOpts)
                options = newOpts
                buildOptions()
            end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    -- LABEL
    function tabObj:Label(cfg)
        cfg = cfg or {}
        local text = type(cfg) == "string" and cfg or (cfg.Text or "Label")
        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = Page,
        })
        return { Set = function(t) lbl.Text = t end }
    end

    -- PARAGRAPH
    function tabObj:Paragraph(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)
        Padding(holder, 10)
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })

        local title = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = cfg.Title or "Title",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = holder,
        })
        local body = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = cfg.Content or "Content",
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = holder,
        })
        return {
            SetTitle = function(t) title.Text = t end,
            SetContent = function(t) body.Text = t end,
        }
    end

    -- PARAGRAPH IMAGE
    function tabObj:ParagraphImage(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)
        Padding(holder, 10)
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })
        local img = Create("ImageLabel", {
            Size = UDim2.new(1, 0, 0, cfg.ImageHeight or 120),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Image = cfg.Image or "",
            ScaleType = Enum.ScaleType.Crop,
            Parent = holder,
        })
        Corner(img, 6)
        local title = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = cfg.Title or "Title",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = holder,
        })
        local body = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = cfg.Content or "Content",
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = holder,
        })
        return {
            SetImage = function(i) img.Image = i end,
            SetTitle = function(t) title.Text = t end,
            SetContent = function(t) body.Text = t end,
        }
    end

    -- PARAGRAPH UPDATE LOG
    function tabObj:ParagraphUpdateLog(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Accent, 1)
        Padding(holder, 10)
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })
        local header = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Parent = holder,
        })
        Create("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Title or "Update Log",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = header,
        })
        Create("TextLabel", {
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Version or "v1.0.0",
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = header,
        })
        if cfg.Image then
            local img = Create("ImageLabel", {
                Size = UDim2.new(1, 0, 0, cfg.ImageHeight or 110),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Image = cfg.Image,
                ScaleType = Enum.ScaleType.Crop,
                Parent = holder,
            })
            Corner(img, 6)
        end
        local body = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = cfg.Content or "- Added new features\n- Fixed bugs",
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = holder,
        })
        return { SetContent = function(t) body.Text = t end }
    end

    -- PARAGRAPH SOCIALS
    function tabObj:ParagraphSocials(cfg)
        cfg = cfg or {}
        local socials = cfg.Socials or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)
        Padding(holder, 10)
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = cfg.Title or "Socials",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = holder,
        })
        for _, social in pairs(socials) do
            local row = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Theme.Secondary,
                Text = "",
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Parent = holder,
            })
            Corner(row, 4)
            Create("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = social.Name or "Social",
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                Parent = row,
            })
            local copyLbl = Create("TextLabel", {
                Size = UDim2.new(0.5, -8, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = "Copy Link",
                TextColor3 = Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                Parent = row,
            })
            row.MouseButton1Click:Connect(function()
                if setclipboard then setclipboard(social.Link or "") end
                copyLbl.Text = "Copied!"
                Lib:Notify({Title = "Copied", Content = (social.Name or "Link") .. " copied!", Duration = 2})
                task.wait(1.5)
                copyLbl.Text = "Copy Link"
            end)
        end
        return holder
    end

    -- INPUT
    function tabObj:Input(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)
        Create("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Input",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })
        local boxFrame = Create("Frame", {
            Size = UDim2.new(0.55, -12, 0, 24),
            Position = UDim2.new(0.45, 0, 0.5, -12),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(boxFrame, 4)
        local box = Create("TextBox", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Default or "",
            PlaceholderText = cfg.Placeholder or "Enter text...",
            PlaceholderColor3 = Theme.SubText,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ClearTextOnFocus = false,
            Parent = boxFrame,
        })
        box.FocusLost:Connect(function(enter)
            if cfg.Callback then cfg.Callback(box.Text, enter) end
        end)
        local api = {
            Set = function(t) box.Text = t end,
            Get = function() return box.Text end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    -- KEYBIND
    function tabObj:Keybind(cfg)
        cfg = cfg or {}
        local currentKey = cfg.Default or Enum.KeyCode.None
        local listening = false
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 7)
        Stroke(holder, Theme.Stroke, 1)
        Create("TextLabel", {
            Size = UDim2.new(1, -90, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Keybind",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })
        local keyBtn = Create("TextButton", {
            Size = UDim2.new(0, 70, 0, 24),
            Position = UDim2.new(1, -80, 0.5, -12),
            BackgroundColor3 = Theme.Secondary,
            Text = currentKey ~= Enum.KeyCode.None and currentKey.Name or "None",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = holder,
        })
        Corner(keyBtn, 5)
        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = Theme.Accent
        end)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyBtn.Text = currentKey.Name
                keyBtn.TextColor3 = Theme.Text
                listening = false
            elseif not gpe and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.None then
                if cfg.Callback then cfg.Callback(currentKey) end
            end
        end)
        local api = {
            Set = function(k)
                currentKey = k
                keyBtn.Text = (k == Enum.KeyCode.None) and "None" or k.Name
            end,
            Get = function() return currentKey end,
        }
        Lib:_register(cfg.Flag, api.Get, api.Set)
        return api
    end

    return tabObj
end

--========================================================--
-- NOTIFICATION
--========================================================--
function SarXNightLib:Notify(cfg)
    cfg = cfg or {}
    local Theme = self.Theme
    local duration = cfg.Duration or 4

    local notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = self.NotifHolder,
    })
    Corner(notif, 7)
    local notifStroke = Stroke(notif, Theme.Accent, 1)
    notifStroke.Transparency = 1
    Padding(notif, 10)
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notif,
    })
    local title = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Notification",
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = notif,
    })
    local body = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = cfg.Content or "",
        TextColor3 = Theme.SubText,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = notif,
    })

    Tween(notif, 0.3, {BackgroundTransparency = 0})
    Tween(notifStroke, 0.3, {Transparency = 0})
    Tween(title, 0.3, {TextTransparency = 0})
    Tween(body, 0.3, {TextTransparency = 0})

    task.spawn(function()
        task.wait(duration)
        Tween(notif, 0.3, {BackgroundTransparency = 1})
        Tween(notifStroke, 0.3, {Transparency = 1})
        Tween(title, 0.3, {TextTransparency = 1})
        Tween(body, 0.3, {TextTransparency = 1})
        task.wait(0.3)
        notif:Destroy()
    end)

    return notif
end

-- Set theme at runtime (basic)
function SarXNightLib:SetTheme(name)
    self.Theme = Themes[name] or self.Theme
    self.ThemeName = name
end

return SarXNightLib
