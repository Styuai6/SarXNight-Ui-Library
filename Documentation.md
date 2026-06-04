# SarXNightLib Documentation — v1.1.0

A classic/rework Roblox UI library with a **2023 redesign**, mobile support, search bar, scrollable dropdowns, JSON config, and a loading screen.

## What's New in v1.1.0
- ✅ Fixed tab element functions (Flag support added)
- 🎚️ Slider now has an **editable input box** (type exact values)
- 📱 **Mobile** floating ≡ button to open/close UI + resized window
- 📂 Dropdowns are **never clipped** (rendered as overlay), **scrollable**, max **3 options visible**
- 🎨 New **2023 UI design** + tab **search bar**
- 💾 **JSON config** save/load via Flags
- ⏳ **Loading screen** on startup

---

## Loading

```lua
local SarXNightLib = loadstring(game:HttpGet("YOUR_RAW_URL/Source.luau"))()
```

## Creating a Window

```lua
local Window = SarXNightLib:CreateWindow({
    Name = "My Script Hub",
    Theme = "default",                      -- "default" or "dark"
    ToggleKey = Enum.KeyCode.RightShift,    -- desktop show/hide
    ConfigFolder = "MyHub",                 -- folder for config json
    ConfigName = "settings",                -- file name (-> MyHub/settings.json)
    LoadingScreen = {                       -- set to false to disable
        Title = "My Script Hub",
        Subtitle = "Loading assets...",
        Duration = 2.5
    }
})
```

---

## Tabs & Search

```lua
local Main = Window:CreateTab({ Name = "Main" })
local Combat = Window:CreateTab("Combat")  -- shorthand
```
A **search bar** at the top of the sidebar filters tabs live as you type.

---

## Config System (JSON)

Add a `Flag` to any stateful element. Then save/load all at once.

```lua
Main:Toggle({ Name = "God Mode", Flag = "godmode", Callback = function(s) end })
Main:Slider({ Name = "Speed", Min=16, Max=200, Flag = "speed" })

-- Save / Load
Window:SaveConfig()  -- writes to ConfigFolder/ConfigName.json
Window:LoadConfig()  -- reads file and applies to all flagged elements
```
Supports: Toggle, Slider, ColorPicker, Dropdown, Input, Keybind.
Color3 and EnumItem (keybinds) are serialized automatically.

---

## Elements

### Button
```lua
Main:Button({ Name = "Click Me", Callback = function() print("clicked") end })
```

### Toggle
```lua
local t = Main:Toggle({ Name = "Auto", Default = false, Flag = "auto",
    Callback = function(s) print(s) end })
t.Set(true); print(t.Get())
```

### Slider (with input box)
```lua
local s = Main:Slider({ Name = "Speed", Min=16, Max=200, Default=16, Decimals=0,
    Flag = "speed", Callback = function(v) print(v) end })
s.Set(100); print(s.Get())
```
You can now **click the value box and type** an exact number.

### ColorPicker
```lua
local c = Main:ColorPicker({ Name = "ESP", Default = Color3.fromRGB(255,0,0),
    Flag = "esp", Callback = function(col) print(col) end })
c.Set(Color3.fromRGB(0,255,0)); print(c.Get())
```

### Dropdown (overlay, scrollable, max 3 visible)
```lua
local d = Main:Dropdown({
    Name = "Mode",
    Options = {"Easy","Medium","Hard","Insane","Nightmare"},
    Default = "Easy",
    Flag = "mode",
    Callback = function(o) print(o) end
})
d.Set("Hard")
d.Refresh({"A","B","C"})
print(d.Get())
```
The dropdown popup renders **above all other UI** (never clipped). If more than 3 options exist, the list **scrolls**.

### Notify
```lua
Window:Notify({ Title = "Done", Content = "Loaded!", Duration = 4 })
```

### Label / Paragraph / ParagraphImage / ParagraphUpdateLog / ParagraphSocials
*(unchanged API — see usage below)*
```lua
Main:Label("Welcome!")
Main:Paragraph({ Title="Info", Content="Multi-line text." })
Main:ParagraphImage({ Title="Featured", Content="...", Image="rbxassetid://123", ImageHeight=120 })
Main:ParagraphUpdateLog({ Title="Changelog", Version="v1.1.0", Content="- New stuff" })
Main:ParagraphSocials({ Title="Socials", Socials={ {Name="Discord", Link="https://..."} } })
```

### Input
```lua
local i = Main:Input({ Name="Name", Placeholder="...", Flag="name",
    Callback=function(txt, enter) print(txt, enter) end })
i.Set("hi"); print(i.Get())
```

### Keybind
```lua
local k = Main:Keybind({ Name="Fly", Default=Enum.KeyCode.F, Flag="flykey",
    Callback=function(key) print(key.Name) end })
k.Set(Enum.KeyCode.G); print(k.Get())
```

---

## Mobile Support
- A floating **≡** button appears on touch devices to open/close the UI (draggable).
- Window auto-resizes smaller and clamps to the viewport.
- Sliders, dropdowns, and color pickers all respond to **touch** input.

---

## Full Example

```lua
local Lib = loadstring(game:HttpGet("YOUR_URL/Source.luau"))()

local Window = Lib:CreateWindow({
    Name = "SarXNight Hub",
    Theme = "default",
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigFolder = "SarXNight",
    ConfigName = "config",
    LoadingScreen = { Subtitle = "Initializing..." }
})

local Main = Window:CreateTab("Main")
local Settings = Window:CreateTab("Settings")

Main:Toggle({ Name="Auto Farm", Flag="autofarm", Callback=function(s) print(s) end })
Main:Slider({ Name="Speed", Min=16, Max=100, Default=16, Flag="speed",
    Callback=function(v) print(v) end })
Main:Dropdown({ Name="Mode", Options={"A","B","C","D","E"}, Flag="mode",
    Callback=function(o) print(o) end })

Settings:Button({ Name="Save Config", Callback=function() Window:SaveConfig() end })
Settings:Button({ Name="Load Config", Callback=function() Window:LoadConfig() end })
```

---

## Element Reference Table

| Element | Method | Returns | Flag |
|---|---|---|---|
| Tab | `Window:CreateTab(cfg)` | tab object | — |
| Button | `Tab:Button(cfg)` | TextButton | — |
| Toggle | `Tab:Toggle(cfg)` | `{Set, Get}` | ✅ |
| Slider | `Tab:Slider(cfg)` | `{Set, Get}` | ✅ |
| ColorPicker | `Tab:ColorPicker(cfg)` | `{Set, Get}` | ✅ |
| Dropdown | `Tab:Dropdown(cfg)` | `{Set, Get, Refresh}` | ✅ |
| Notify | `Window:Notify(cfg)` | Frame | — |
| Label | `Tab:Label(cfg)` | `{Set}` | — |
| Paragraph | `Tab:Paragraph(cfg)` | `{SetTitle, SetContent}` | — |
| Paragraph Image | `Tab:ParagraphImage(cfg)` | `{SetImage, SetTitle, SetContent}` | — |
| Update Log | `Tab:ParagraphUpdateLog(cfg)` | `{SetContent}` | — |
| Socials | `Tab:ParagraphSocials(cfg)` | Frame | — |
| Input | `Tab:Input(cfg)` | `{Set, Get}` | ✅ |
| Keybind | `Tab:Keybind(cfg)` | `{Set, Get}` | ✅ |

| Window Method | Description |
|---|---|
| `Window:SaveConfig()` | Save all flagged elements to JSON |
| `Window:LoadConfig()` | Load JSON and apply to flagged elements |
| `Window:Notify(cfg)` | Show a notification |
| `Window:SetTheme(name)` | Switch theme (affects new elements) |

---

*SarXNightLib v1.1.0 — 2023 Redesign*
