# SarXNightLib v1.2.2-BETA Documentation

> Inspired by Orion UI Library (**discontinued**). New design rework.

## What's New in v1.2.2-BETA
- ✅ **New design v1.2.2** — refined colors, larger window (625×350), glow accents
- ✅ **Search Tabs** — search bar above the tab list filters tabs live
- ✅ `MakeWindow` → **`InterfaceToggleImageId`** (custom mobile toggle button image)
- ✅ **Fixed Slider** — track + fill + knob, no more glitched overlap; input box centered
- ✅ **New loading screen** — bounce logo, **typewriter text effect**, progress bar, pulsing glow
- ✅ **Fixed mobile toggle drag** — click vs drag detection (was broken before)

---

## Loading
```lua
local SarXNightLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Styuai6/SarXNight-Ui-Library/refs/heads/main/Source.luau"))()
```

---

## Creating a Window
```lua
local Window = SarXNightLib:MakeWindow({
    Name = "SarXNight Hub",
    Theme = "Default",                              -- "Default" or "Dark"
    SaveConfig = true,
    ConfigFolder = "SarXNightHub",
    IntroEnabled = true,
    IntroText = "SarXNight Hub",                     -- typewriter animated
    IntroIcon = "rbxassetid://8834748103",
    ShowIcon = true,
    Icon = "rbxassetid://8834748103",
    InterfaceToggleImageId = "rbxassetid://8834748103",  -- NEW: mobile floating button image
    CloseCallback = function() print("Closed") end
})
```

| New Option | Type | Description |
|---|---|---|
| `InterfaceToggleImageId` | string (rbxassetid) | Image shown inside the mobile floating open/close button |

---

## Search Tabs
The search bar is **automatic** — it appears at the top of the tab sidebar. Just type to filter tabs by name. No setup needed.

---

## Creating a Tab
```lua
local Main = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://7733964640" })
local Info = Window:MakeTab({ Name = "Info" })
```

---

## Elements

### Button
```lua
Main:AddButton({ Name = "Click", Callback = function() print("hi") end })
```

### Toggle
```lua
local t = Main:AddToggle({ Name = "God", Default = false, Flag = "God", Save = true,
    Callback = function(v) print(v) end })
t:Set(true)
```

### Slider (FIXED design)
```lua
local s = Main:AddSlider({
    Name = "Speed", Min = 16, Max = 200, Increment = 1, Default = 16,
    ValueName = "spd", Flag = "Speed", Save = true,
    Callback = function(v) print(v) end
})
s:Set(100)
```
> Now has a clean **track + fill + knob** design (no glitch). Drag the bar (mouse/touch) or **type a value** in the centered box.

### Dropdown (max 3 visible + scroll)
```lua
local d = Main:AddDropdown({
    Name = "Mode", Options = {"A","B","C","D","E"}, Default = "A",
    Flag = "Mode", Save = true, Callback = function(o) print(o) end
})
d:Set("C")
d:Refresh({"X","Y","Z"}, true)
```

### Colorpicker (mobile + mouse)
```lua
Main:AddColorpicker({ Name = "ESP", Default = Color3.fromRGB(255,0,0),
    Flag = "ESP", Save = true, Callback = function(c) print(c) end })
```

### Keybind
```lua
Main:AddBind({ Name = "Fly", Default = Enum.KeyCode.F, Flag = "Fly", Save = true,
    Callback = function() print("fly") end })
```

### Textbox / Input
```lua
local box = Main:AddTextbox({ Name = "Name", Default = "",
    TextDisappear = false, Callback = function(t) print(t) end })
box:Set("Hello"); print(box:Get())
```

### Label & Paragraph
```lua
Main:AddLabel("Welcome!")
Main:AddParagraph("Title", "Body content")
```

### Paragraph Image
```lua
Info:AddParagraphImage({ Title = "Banner", Content = "Preview",
    Image = "rbxassetid://4384403532", ImageHeight = 110 })
```

### Paragraph Update Log (+ optional image)
```lua
Info:AddParagraphUpdateLog({
    Title = "Changelog", Version = "v1.2.2-BETA",
    Image = "rbxassetid://4384403532",   -- optional
    Content = "- New design\n- Search tabs\n- Fixed slider\n- New loading screen"
})
```

### Paragraph Socials (Copy Link)
```lua
Info:AddParagraphSocials({ Title = "Socials", Socials = {
    { Name = "Discord", Link = "https://discord.gg/example" },
    { Name = "YouTube", Link = "https://youtube.com/@example" }
}})
```

---

## Notifications
```lua
SarXNightLib:MakeNotification({ Name = "Hi", Content = "Loaded!", Time = 5 })
```

---

## Config Saving
```lua
-- after building everything:
SarXNightLib:Init()
```
Give elements `Flag` + `Save = true`. Supported: Toggle, Slider, Dropdown, Colorpicker, Bind.

---

## Themes
```lua
SarXNightLib:MakeWindow({ Theme = "Dark" })
SarXNightLib:SetTheme("Dark")  -- runtime switch
```

---

## Mobile
- Floating toggle button (custom image via `InterfaceToggleImageId`) — **tap** to open/close, **drag** to reposition (fixed!).
- **RightShift** reopens on PC.
- Slider, Colorpicker, Dropdown, Bind, window drag all support **Touch**.

---

## Destroy
```lua
SarXNightLib:Destroy()
```

---

## Element Reference

| Element | Method | Returns |
|---|---|---|
| Window | `:MakeWindow(cfg)` | window |
| Tab | `:MakeTab(cfg)` | tab |
| Button | `:AddButton(cfg)` | `{Set}` |
| Toggle | `:AddToggle(cfg)` | `{Set, Value}` |
| Slider | `:AddSlider(cfg)` | `{Set, Value}` |
| Dropdown | `:AddDropdown(cfg)` | `{Set, Refresh, Value}` |
| Colorpicker | `:AddColorpicker(cfg)` | `{Set, Value}` |
| Keybind | `:AddBind(cfg)` | `{Set, Value}` |
| Textbox | `:AddTextbox(cfg)` | `{Set, Get}` |
| Label | `:AddLabel(text)` | `{Set}` |
| Paragraph | `:AddParagraph(t, c)` | `{Set}` |
| Paragraph Image | `:AddParagraphImage(cfg)` | `{SetImage, SetTitle, SetContent}` |
| Update Log | `:AddParagraphUpdateLog(cfg)` | `{SetContent}` |
| Socials | `:AddParagraphSocials(cfg)` | Frame |
| Notify | `SarXNightLib:MakeNotification(cfg)` | — |
| Init | `SarXNightLib:Init()` | — |
| Theme | `SarXNightLib:SetTheme(name)` | — |
| Destroy | `SarXNightLib:Destroy()` | — |

*SarXNightLib v1.2.2-BETA — New Design • Search Tabs • Fixed Slider • Animated Loading*
````

---

## Changelog Summary (v1.2.2-BETA)

| # | Change | Status |
|---|--------|--------|
| 1 | New design v1.2.2 (625×350, refined theme, glow) | ✅ |
| 2 | **Search Tabs** bar (live filter) | ✅ |
| 3 | `InterfaceToggleImageId` in `MakeWindow` | ✅ |
| 4 | **Fixed Slider** (track + fill + knob, no glitch) | ✅ |
| 5 | New loading screen + **typewriter text animation** | ✅ |
| 6 | **Fixed mobile toggle** broken drag (click vs drag detection) | ✅ |
