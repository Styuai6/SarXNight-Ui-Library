# SarXNightLib Documentation

A classic/rework 2022-style Roblox UI library.

## Loading the Library

```lua
local SarXNightLib = loadstring(game:HttpGet("YOUR_RAW_URL/Source.luau"))()
```

## Themes

Two built-in themes:
- `"default"` — SarXNight (purple/night theme)
- `"dark"` — Pure dark (blue accent)

---

## Creating a Window

```lua
local Window = SarXNightLib:CreateWindow({
    Name = "My Script Hub",
    Theme = "default",                 -- "default" or "dark"
    ToggleKey = Enum.KeyCode.RightShift -- key to show/hide UI
})
```

---

## Creating a Tab

```lua
local MainTab = Window:CreateTab({ Name = "Main" })
local SettingsTab = Window:CreateTab({ Name = "Settings" })
-- shorthand:
local Tab = Window:CreateTab("Combat")
```

---

## Elements

### Button
```lua
MainTab:Button({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```

### Toggle
```lua
local myToggle = MainTab:Toggle({
    Name = "God Mode",
    Default = false,
    Callback = function(state)
        print("Toggle is now:", state)
    end
})

myToggle.Set(true)        -- programmatically set
print(myToggle.Get())     -- read state
```

### Slider
```lua
local mySlider = MainTab:Slider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Decimals = 0,
    Callback = function(value)
        print("Speed:", value)
    end
})

mySlider.Set(100)
print(mySlider.Get())
```

### ColorPicker
```lua
local myColor = MainTab:ColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Color:", color)
    end
})

myColor.Set(Color3.fromRGB(0, 255, 0))
print(myColor.Get())
```

### Dropdown
```lua
local myDrop = MainTab:Dropdown({
    Name = "Select Mode",
    Options = {"Easy", "Medium", "Hard"},
    Default = "Easy",
    Callback = function(option)
        print("Selected:", option)
    end
})

myDrop.Set("Hard")
myDrop.Refresh({"New1", "New2", "New3"})  -- update option list
print(myDrop.Get())
```

### Notify
```lua
Window:Notify({
    Title = "Success",
    Content = "Script loaded successfully!",
    Duration = 4
})
```

### TextLabel (Label)
```lua
local lbl = MainTab:Label({ Text = "Welcome!" })
-- shorthand:
MainTab:Label("Hello World")

lbl.Set("Updated text")
```

### Paragraph
```lua
local para = MainTab:Paragraph({
    Title = "Information",
    Content = "This is a multi-line paragraph block describing something useful."
})

para.SetTitle("New Title")
para.SetContent("Updated content here.")
```

### Paragraph IMAGE
```lua
local paraImg = MainTab:ParagraphImage({
    Title = "Featured",
    Content = "Check out this cool image.",
    Image = "rbxassetid://1234567890",
    ImageHeight = 120
})

paraImg.SetImage("rbxassetid://9876543210")
paraImg.SetTitle("New Title")
paraImg.SetContent("New content.")
```

### Paragraph Update Log & Image
```lua
local log = MainTab:ParagraphUpdateLog({
    Title = "Update Log",
    Version = "v1.2.0",
    Image = "rbxassetid://1234567890",   -- optional
    ImageHeight = 110,
    Content = "- Added Keybind element\n- Fixed dropdown bug\n- New dark theme"
})

log.SetContent("- Hotfix applied")
```

### Paragraph Socials (Copy Link)
```lua
MainTab:ParagraphSocials({
    Title = "Our Socials",
    Socials = {
        { Name = "Discord",  Link = "https://discord.gg/example" },
        { Name = "YouTube",  Link = "https://youtube.com/@example" },
        { Name = "GitHub",   Link = "https://github.com/example" },
    }
})
-- Clicking a row copies the link (uses setclipboard) and shows a notification.
```

### Input Box
```lua
local myInput = MainTab:Input({
    Name = "Username",
    Placeholder = "Enter name...",
    Default = "",
    Callback = function(text, enterPressed)
        print("Input:", text, "| Enter:", enterPressed)
    end
})

myInput.Set("Hello")
print(myInput.Get())
```

### Keybind
```lua
local myKey = MainTab:Keybind({
    Name = "Aimbot Key",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("Keybind pressed:", key.Name)
    end
})

myKey.Set(Enum.KeyCode.F)
print(myKey.Get())
```

---

## Runtime Theme Switching

```lua
Window:SetTheme("dark")
-- Note: applies to NEW elements created after the call.
```

---

## Full Example

```lua
local Lib = loadstring(game:HttpGet("YOUR_URL/Source.luau"))()

local Window = Lib:CreateWindow({
    Name = "SarXNight Hub",
    Theme = "default",
    ToggleKey = Enum.KeyCode.RightShift
})

local Main = Window:CreateTab("Main")
local Info = Window:CreateTab("Info")

Main:Label("Welcome to SarXNight Hub!")

Main:Button({
    Name = "Notify Me",
    Callback = function()
        Window:Notify({ Title = "Hi", Content = "Hello there!", Duration = 3 })
    end
})

Main:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(s) print("AutoFarm:", s) end
})

Main:Slider({
    Name = "Speed",
    Min = 16, Max = 100, Default = 16,
    Callback = function(v) print(v) end
})

Main:Dropdown({
    Name = "Mode",
    Options = {"A", "B", "C"},
    Callback = function(o) print(o) end
})

Main:ColorPicker({
    Name = "Color",
    Default = Color3.fromRGB(120, 90, 220),
    Callback = function(c) print(c) end
})

Main:Keybind({
    Name = "Fly Key",
    Default = Enum.KeyCode.F,
    Callback = function() print("Fly toggled") end
})

Info:ParagraphUpdateLog({
    Title = "Changelog",
    Version = "v1.0.0",
    Content = "- Initial release\n- 13 elements\n- 2 themes"
})

Info:ParagraphSocials({
    Title = "Socials",
    Socials = {
        { Name = "Discord", Link = "https://discord.gg/example" }
    }
})
```

---

## Element Reference Table

| Element | Method | Returns |
|---|---|---|
| Tab | `Window:CreateTab(cfg)` | tab object |
| Button | `Tab:Button(cfg)` | TextButton |
| Toggle | `Tab:Toggle(cfg)` | `{Set, Get}` |
| Slider | `Tab:Slider(cfg)` | `{Set, Get}` |
| ColorPicker | `Tab:ColorPicker(cfg)` | `{Set, Get}` |
| Dropdown | `Tab:Dropdown(cfg)` | `{Set, Get, Refresh}` |
| Notify | `Window:Notify(cfg)` | Frame |
| Label | `Tab:Label(cfg)` | `{Set}` |
| Paragraph | `Tab:Paragraph(cfg)` | `{SetTitle, SetContent}` |
| Paragraph Image | `Tab:ParagraphImage(cfg)` | `{SetImage, SetTitle, SetContent}` |
| Update Log | `Tab:ParagraphUpdateLog(cfg)` | `{SetContent}` |
| Socials | `Tab:ParagraphSocials(cfg)` | Frame |
| Input | `Tab:Input(cfg)` | `{Set, Get}` |
| Keybind | `Tab:Keybind(cfg)` | `{Set, Get}` |

---

*SarXNightLib v1.0.0 — Classic/Rework 2022 style*
