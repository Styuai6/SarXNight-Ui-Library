--[[
    SarXNightLib - Classic/Rework 2022 UI Library
    Version: 1.0.0
    Author: SarXNight
]]

local SarXNightLib = {}
SarXNightLib.__index = SarXNightLib

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Themes
local Themes = {
    default = { -- SarXNight
        Main       = Color3.fromRGB(30, 30, 45),
        Secondary  = Color3.fromRGB(40, 40, 60),
        Tertiary   = Color3.fromRGB(50, 50, 75),
        Accent     = Color3.fromRGB(120, 90, 220),
        AccentDark = Color3.fromRGB(90, 65, 170),
        Text       = Color3.fromRGB(235, 235, 245),
        SubText    = Color3.fromRGB(170, 170, 190),
        Stroke     = Color3.fromRGB(60, 60, 90),
        Toggle     = Color3.fromRGB(70, 70, 100),
    },
    dark = {
        Main       = Color3.fromRGB(20, 20, 20),
        Secondary  = Color3.fromRGB(30, 30, 30),
        Tertiary   = Color3.fromRGB(40, 40, 40),
        Accent     = Color3.fromRGB(0, 170, 255),
        AccentDark = Color3.fromRGB(0, 130, 200),
        Text       = Color3.fromRGB(240, 240, 240),
        SubText    = Color3.fromRGB(160, 160, 160),
        Stroke     = Color3.fromRGB(55, 55, 55),
        Toggle     = Color3.fromRGB(60, 60, 60),
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

-- Make a frame draggable
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

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "SarXNightLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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

    -- Main Window Frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    Corner(Main, 8)
    Stroke(Main, Theme.Stroke, 1)
    self.Main = Main

    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Corner(TopBar, 8)
    Create("Frame", { -- mask bottom corners
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    MakeDraggable(TopBar, Main)

    local Title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = windowName,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Parent = TopBar,
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Text = "✕",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Corner(CloseBtn, 6)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    -- Minimize Button
    local MinBtn = Create("TextButton", {
        Name = "Min",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = Theme.Tertiary,
        Text = "—",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Corner(MinBtn, 6)

    -- Tab Container (left side)
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(0, 140, 1, -46),
        Position = UDim2.new(0, 8, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Main,
    })
    Corner(TabList, 6)
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList,
    })
    Padding(TabList, 6)
    self.TabList = TabList

    -- Content Container (right side)
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -164, 1, -46),
        Position = UDim2.new(0, 156, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Corner(Content, 6)
    self.Content = Content

    -- Notification Holder
    local NotifHolder = Create("Frame", {
        Name = "NotifHolder",
        Size = UDim2.new(0, 280, 1, -20),
        Position = UDim2.new(1, -290, 0, 10),
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

    -- Minimize logic
    local minimized = false
    local savedSize = Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TabList.Visible = false
            Content.Visible = false
            Tween(Main, 0.2, {Size = UDim2.new(0, 560, 0, 36)})
        else
            Tween(Main, 0.2, {Size = savedSize})
            task.wait(0.2)
            TabList.Visible = true
            Content.Visible = true
        end
    end)

    -- Toggle UI with keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            Main.Visible = not Main.Visible
        end
    end)

    return self
end

--========================================================--
-- TAB
--========================================================--
function SarXNightLib:CreateTab(config)
    config = config or {}
    local Theme = self.Theme
    local tabName = type(config) == "string" and config or (config.Name or "Tab")

    local tabObj = {}
    tabObj.Lib = self

    -- Tab Button
    local TabBtn = Create("TextButton", {
        Name = tabName,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = 0.4,
        Text = tabName,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = self.TabList,
    })
    Corner(TabBtn, 6)

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
    local Lib = self

    -- BUTTON
    function tabObj:Button(cfg)
        cfg = cfg or {}
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            Text = cfg.Name or "Button",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = Page,
        })
        Corner(btn, 6)
        Stroke(btn, Theme.Stroke, 1)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Tertiary})
        end)
        btn.MouseButton1Click:Connect(function()
            Tween(btn, 0.08, {BackgroundColor3 = Theme.AccentDark})
            task.wait(0.08)
            Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent})
            if cfg.Callback then cfg.Callback() end
        end)
        return btn
    end

    -- TOGGLE
    function tabObj:Toggle(cfg)
        cfg = cfg or {}
        local state = cfg.Default or false

        local holder = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = Page,
        })
        Corner(holder, 6)
        Stroke(holder, Theme.Stroke, 1)

        Create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
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
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = state and Theme.Accent or Theme.Toggle,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(switch, 10)

        local knob = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = switch,
        })
        Corner(knob, 8)

        local function set(val)
            state = val
            Tween(switch, 0.15, {BackgroundColor3 = state and Theme.Accent or Theme.Toggle})
            Tween(knob, 0.15, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
            if cfg.Callback then cfg.Callback(state) end
        end

        holder.MouseButton1Click:Connect(function()
            set(not state)
        end)

        if cfg.Default then
            if cfg.Callback then cfg.Callback(state) end
        end

        return {
            Set = set,
            Get = function() return state end,
        }
    end

    -- SLIDER
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
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
        Stroke(holder, Theme.Stroke, 1)

        local label = Create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 20),
            Position = UDim2.new(0, 12, 0, 4),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Slider",
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

        local valLabel = Create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -56, 0, 4),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = holder,
        })

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

        local function update(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            value = round(min + (max - min) * rel)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valLabel.Text = tostring(value)
            if cfg.Callback then cfg.Callback(value) end
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

        return {
            Set = function(v)
                value = round(math.clamp(v, min, max))
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valLabel.Text = tostring(value)
                if cfg.Callback then cfg.Callback(value) end
            end,
            Get = function() return value end,
        }
    end

    -- COLORPICKER
    function tabObj:ColorPicker(cfg)
        cfg = cfg or {}
        local color = cfg.Default or Color3.fromRGB(255, 255, 255)

        local holder = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ClipsDescendants = false,
            Parent = Page,
        })
        Corner(holder, 6)
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
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = holder,
        })
        Corner(preview, 4)
        Stroke(preview, Theme.Stroke, 1)

        -- Picker popup
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
            local lbl = Create("TextLabel", {
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    drag = true upd(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if drag and input.UserInputType == Enum.UserInputType.MouseMovement then upd(input) end
            end)
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

        return {
            Set = function(c)
                color = c
                h, s, v = Color3.toHSV(c)
                preview.BackgroundColor3 = c
                if cfg.Callback then cfg.Callback(c) end
            end,
            Get = function() return color end,
        }
    end

    -- DROPDOWN
    function tabObj:Dropdown(cfg)
        cfg = cfg or {}
        local options = cfg.Options or {}
        local selected = cfg.Default or (options[1] or "None")

        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = Page,
        })
        Corner(holder, 6)
        Stroke(holder, Theme.Stroke, 1)

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
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
            Size = UDim2.new(0.5, -36, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(selected),
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            Parent = holder,
        })

        local arrow = Create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -24, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Theme.SubText,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = holder,
        })

        local optHolder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = holder,
        })
        local layout = Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = optHolder,
        })

        local open = false
        local function buildOptions()
            for _, c in pairs(optHolder:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, opt in pairs(options) do
                local oBtn = Create("TextButton", {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundColor3 = Theme.Secondary,
                    Text = tostring(opt),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    BorderSizePixel = 0,
                    Parent = optHolder,
                })
                Corner(oBtn, 4)
                oBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLabel.Text = tostring(opt)
                    open = false
                    Tween(holder, 0.2, {Size = UDim2.new(1, 0, 0, 34)})
                    Tween(arrow, 0.2, {Rotation = 0})
                    if cfg.Callback then cfg.Callback(opt) end
                end)
            end
        end
        buildOptions()

        btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local h = 34 + (#options * 28) + 4
                Tween(holder, 0.2, {Size = UDim2.new(1, 0, 0, h)})
                Tween(arrow, 0.2, {Rotation = 180})
            else
                Tween(holder, 0.2, {Size = UDim2.new(1, 0, 0, 34)})
                Tween(arrow, 0.2, {Rotation = 0})
            end
        end)

        return {
            Set = function(v)
                selected = v
                selLabel.Text = tostring(v)
                if cfg.Callback then cfg.Callback(v) end
            end,
            Get = function() return selected end,
            Refresh = function(newOpts)
                options = newOpts
                buildOptions()
            end,
        }
    end

    -- TEXTLABEL
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
        return {
            Set = function(t) lbl.Text = t end,
        }
    end

    -- PARAGRAPH
    function tabObj:Paragraph(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Page,
        })
        Corner(holder, 6)
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
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
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

    -- PARAGRAPH UPDATE LOG & IMAGE
    function tabObj:ParagraphUpdateLog(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
        Stroke(holder, Theme.Accent, 1)
        Padding(holder, 10)
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })

        -- Version header
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

        return {
            SetContent = function(t) body.Text = t end,
        }
    end

    -- PARAGRAPH SOCIALS (copy link)
    function tabObj:ParagraphSocials(cfg)
        cfg = cfg or {}
        local socials = cfg.Socials or {}

        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
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
                if setclipboard then
                    setclipboard(social.Link or "")
                end
                copyLbl.Text = "Copied!"
                Lib:Notify({Title = "Copied", Content = social.Name .. " link copied!", Duration = 2})
                task.wait(1.5)
                copyLbl.Text = "Copy Link"
            end)
        end

        return holder
    end

    -- INPUT BOX
    function tabObj:Input(cfg)
        cfg = cfg or {}
        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
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

        return {
            Set = function(t) box.Text = t end,
            Get = function() return box.Text end,
        }
    end

    -- KEYBIND
    function tabObj:Keybind(cfg)
        cfg = cfg or {}
        local currentKey = cfg.Default or Enum.KeyCode.None
        local listening = false

        local holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = Page,
        })
        Corner(holder, 6)
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
            Size = UDim2.new(0, 70, 0, 22),
            Position = UDim2.new(1, -80, 0.5, -11),
            BackgroundColor3 = Theme.Secondary,
            Text = currentKey ~= Enum.KeyCode.None and currentKey.Name or "None",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = holder,
        })
        Corner(keyBtn, 4)

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

        return {
            Set = function(k)
                currentKey = k
                keyBtn.Text = k.Name
            end,
            Get = function() return currentKey end,
        }
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
    Corner(notif, 6)
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

    -- Animate in
    Tween(notif, 0.3, {BackgroundTransparency = 0})
    Tween(notifStroke, 0.3, {Transparency = 0})
    Tween(title, 0.3, {TextTransparency = 0})
    Tween(body, 0.3, {TextTransparency = 0})

    -- Auto dismiss
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
