--[[
    SxiNight UI Library 2026
    Version: 1.0.0
    A modern, sleek UI library for Roblox
]]

local SxiNight = {}
SxiNight.__index = SxiNight

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(22, 22, 30),
    Tertiary = Color3.fromRGB(30, 30, 40),
    Accent = Color3.fromRGB(138, 43, 226),
    AccentHover = Color3.fromRGB(158, 63, 246),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(45, 45, 60),
    Success = Color3.fromRGB(80, 220, 100),
    Error = Color3.fromRGB(255, 80, 80),
}

-- Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(obj, time, props, style, direction)
    local info = TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea = dragArea or frame
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main Library
function SxiNight:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "SxiNight UI"
    local windowSize = config.Size or UDim2.new(0, 600, 0, 400)
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "SxiNightUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = CoreGui
        end
    end)
    
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
        Size = windowSize,
        ClipsDescendants = true,
    })
    
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Border,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
    })
    Create("UICorner", { Parent = TitleBar, CornerRadius = UDim.new(0, 8) })
    
    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
    })
    
    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = windowTitle,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Close Button
    local CloseButton = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.SubText,
        TextSize = 20,
    })
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, 0.15, { TextColor3 = Theme.Error })
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, 0.15, { TextColor3 = Theme.SubText })
    end)
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, 0.25, { Size = UDim2.new(0, 0, 0, 0) }).Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Tab Container (Left Sidebar)
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 140, 1, -35),
    })
    
    local TabList = Create("ScrollingFrame", {
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    
    Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = TabList,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 35),
        Size = UDim2.new(1, -140, 1, -35),
    })
    
    local Window = {}
    local Tabs = {}
    local CurrentTab = nil
    
    function Window:CreateTab(tabName)
        local TabButton = Create("TextButton", {
            Parent = TabList,
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 13,
        })
        Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 6) })
        
        local TabContent = Create("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        
        Create("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
        })
        
        local function SelectTab()
            if CurrentTab then
                CurrentTab.Content.Visible = false
                Tween(CurrentTab.Button, 0.2, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
            end
            TabContent.Visible = true
            Tween(TabButton, 0.2, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
            CurrentTab = { Button = TabButton, Content = TabContent }
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        if not CurrentTab then SelectTab() end
        
        local Tab = {}
        
        function Tab:CreateButton(config)
            config = config or {}
            local Btn = Create("TextButton", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Font = Enum.Font.Gotham,
                Text = config.Name or "Button",
                TextColor3 = Theme.Text,
                TextSize = 13,
                AutoButtonColor = false,
            })
            Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = Btn, Color = Theme.Border, Thickness = 1 })
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn, 0.15, { BackgroundColor3 = Theme.Tertiary })
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, 0.15, { BackgroundColor3 = Theme.Secondary })
            end)
            Btn.MouseButton1Click:Connect(function()
                if config.Callback then
                    pcall(config.Callback)
                end
            end)
            
            return Btn
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            local state = config.Default or false
            
            local ToggleFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
            })
            Create("UICorner", { Parent = ToggleFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = ToggleFrame, Color = Theme.Border, Thickness = 1 })
            
            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name or "Toggle",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local Switch = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -42, 0.5, -9),
                Size = UDim2.new(0, 32, 0, 18),
            })
            Create("UICorner", { Parent = Switch, CornerRadius = UDim.new(1, 0) })
            
            local Knob = Create("Frame", {
                Parent = Switch,
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0.5, -7),
                Size = UDim2.new(0, 14, 0, 14),
            })
            Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })
            
            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
            })
            
            local function Update()
                if state then
                    Tween(Switch, 0.2, { BackgroundColor3 = Theme.Accent })
                    Tween(Knob, 0.2, { Position = UDim2.new(1, -16, 0.5, -7) })
                else
                    Tween(Switch, 0.2, { BackgroundColor3 = Theme.Tertiary })
                    Tween(Knob, 0.2, { Position = UDim2.new(0, 2, 0.5, -7) })
                end
                if config.Callback then pcall(config.Callback, state) end
            end
            
            Button.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)
            
            if state then Update() end
            
            return {
                Set = function(_, val) state = val; Update() end,
                Get = function() return state end,
            }
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local value = default
            
            local SliderFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
            })
            Create("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = SliderFrame, Color = Theme.Border, Thickness = 1 })
            
            Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -60, 0, 18),
                Font = Enum.Font.Gotham,
                Text = config.Name or "Slider",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 6),
                Size = UDim2.new(0, 40, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = tostring(default),
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            
            local SliderBG = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 1, -16),
                Size = UDim2.new(1, -24, 0, 6),
            })
            Create("UICorner", { Parent = SliderBG, CornerRadius = UDim.new(1, 0) })
            
            local Fill = Create("Frame", {
                Parent = SliderBG,
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            })
            Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })
            
            local dragging = false
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                if config.Callback then pcall(config.Callback, value) end
            end
            
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
                or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            return {
                Set = function(_, val)
                    value = math.clamp(val, min, max)
                    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                end,
                Get = function() return value end,
            }
        end
        
        function Tab:CreateLabel(text)
            local Label = Create("TextLabel", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text or "Label",
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            return {
                Set = function(_, t) Label.Text = t end
            }
        end
        
        function Tab:CreateTextbox(config)
            config = config or {}
            local Frame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
            })
            Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = Frame, Color = Theme.Border, Thickness = 1 })
            
            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name or "Textbox",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local TextBox = Create("TextBox", {
                Parent = Frame,
                BackgroundColor3 = Theme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0.42, 0, 0.5, -12),
                Size = UDim2.new(0.55, -12, 0, 24),
                Font = Enum.Font.Gotham,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Enter text...",
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 12,
                ClearTextOnFocus = false,
            })
            Create("UICorner", { Parent = TextBox, CornerRadius = UDim.new(0, 4) })
            Create("UIPadding", { Parent = TextBox, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            
            TextBox.FocusLost:Connect(function(enter)
                if config.Callback then pcall(config.Callback, TextBox.Text, enter) end
            end)
            
            return TextBox
        end
        
        function Tab:CreateDropdown(config)
            config = config or {}
            local options = config.Options or {}
            local selected = config.Default or options[1] or "Select..."
            local open = false
            
            local Frame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                ClipsDescendants = true,
            })
            Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = Frame, Color = Theme.Border, Thickness = 1 })
            
            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.5, 0, 0, 36),
                Font = Enum.Font.Gotham,
                Text = config.Name or "Dropdown",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local SelectedLabel = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -30, 0, 36),
                Font = Enum.Font.Gotham,
                Text = selected,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            
            local Arrow = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 0),
                Size = UDim2.new(0, 20, 0, 36),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = Theme.SubText,
                TextSize = 10,
            })
            
            local OptionList = Create("Frame", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 40),
                Size = UDim2.new(1, -16, 1, -48),
            })
            local OptionLayout = Create("UIListLayout", {
                Parent = OptionList,
                Padding = UDim.new(0, 4),
            })
            
            local Button = Create("TextButton", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
            })
            
            local function RefreshOptions()
                for _, c in ipairs(OptionList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Parent = OptionList,
                        BackgroundColor3 = Theme.Tertiary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                    })
                    Create("UICorner", { Parent = OptBtn, CornerRadius = UDim.new(0, 4) })
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        SelectedLabel.Text = opt
                        open = false
                        Tween(Frame, 0.2, { Size = UDim2.new(1, 0, 0, 36) })
                        Tween(Arrow, 0.2, { Rotation = 0 })
                        if config.Callback then pcall(config.Callback, opt) end
                    end)
                end
            end
            RefreshOptions()
            
            Button.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local h = 44 + (#options * 30)
                    Tween(Frame, 0.2, { Size = UDim2.new(1, 0, 0, h) })
                    Tween(Arrow, 0.2, { Rotation = 180 })
                else
                    Tween(Frame, 0.2, { Size = UDim2.new(1, 0, 0, 36) })
                    Tween(Arrow, 0.2, { Rotation = 0 })
                end
            end)
            
            return {
                Set = function(_, val) selected = val; SelectedLabel.Text = val end,
                Get = function() return selected end,
                Refresh = function(_, newOpts) options = newOpts; RefreshOptions() end,
            }
        end
        
        function Tab:CreateSection(name)
            local Section = Create("TextLabel", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = name or "Section",
                TextColor3 = Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            return Section
        end
        
        table.insert(Tabs, Tab)
        return Tab
    end
    
    function Window:Notify(config)
        config = config or {}
        local NotifGui = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -310, 1, -90),
            Size = UDim2.new(0, 300, 0, 70),
        })
        Create("UICorner", { Parent = NotifGui, CornerRadius = UDim.new(0, 8) })
        Create("UIStroke", { Parent = NotifGui, Color = Theme.Accent, Thickness = 1 })
        
        Create("TextLabel", {
            Parent = NotifGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -24, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = config.Title or "Notification",
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        Create("TextLabel", {
            Parent = NotifGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 28),
            Size = UDim2.new(1, -24, 0, 34),
            Font = Enum.Font.Gotham,
            Text = config.Content or "",
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
        })
        
        NotifGui.Position = UDim2.new(1, 10, 1, -90)
        Tween(NotifGui, 0.3, { Position = UDim2.new(1, -310, 1, -90) })
        
        task.delay(config.Duration or 3, function()
            Tween(NotifGui, 0.3, { Position = UDim2.new(1, 10, 1, -90) }).Completed:Connect(function()
                NotifGui:Destroy()
            end)
        end)
    end
    
    return Window
end

return SxiNight
