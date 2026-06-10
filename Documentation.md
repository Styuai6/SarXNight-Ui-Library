# SarXNightLib Documentation — v1.2.5-BETA

> Successor to the discontinued **OrionLib**. Inspired by Orion (thanks!).

## What's New in v1.2.5-BETA
- 📱 **Mobile-friendly sizing** — window auto-shrinks (470×300) on touch devices, sidebar narrows to 130px, and clamps to the viewport.
- 🕹️ **Legacy dragging** — the window AND mobile ≡ toggle now use the smooth tween-based "legacy Orion" drag.
- 📝 **Update Log reworked** — no more raw `\n-`! Pass a **table of lines** or a string; they auto-format into clean **• bullets**.
- 🎨 **New v1.2.5 design** — refined spacing, big-bar slider, themed search box.
- 📊 **Slider reworked** — **big bar** style like the Orion library (value shown *inside* the bar) + editable input box.
- 🐛 **Fixed:** search bar white-color issue (now uses theme `Main` background + theme text color).
- ⚡ **Zero-lag / better performance** — reduced polling, lighter search filter, single render-step connections for colorpicker.

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
    Theme = "Default",                          -- "Default" (Purple&Night) or "Dark"
    ConfigFolder = "SarXNight",
    SaveConfig = true,
    IntroEnabled = true,                         -- typewriter loading screen
    IntroText = "SarXNight Hub",
    IntroIcon = "rbxassetid://8834748103",
    ShowIcon = true,
    Icon = "rbxassetid://8834748103",
    InterfaceToggleImageId = "rbxassetid://8834748103",  -- mobile ≡ button image
    CloseCallback = function() print("closed") end
})

SarXNightLib:Init()   -- auto-load saved config
```

### MakeWindow Config Reference
| Key | Type | Default | Description |
|---|---|---|---|
| `Name` | string | `"SarXNightLib"` | Window title |
| `Theme` | string | `"Default"` | `"Default"` or `"Dark"` |
| `ConfigFolder` | string | `Name` | Folder for config files |
| `SaveConfig` | bool | `false` | Enable per-game config saving |
| `IntroEnabled` | bool | `true` | Show the typewriter loading screen |
| `IntroText` | string | `"SarXNightLib"` | Loading screen text (animated) |
| `IntroIcon` | string | rbxasset | Loading screen logo |
| `ShowIcon` | bool | `false` | Show icon in top bar |
| `Icon` | string | rbxasset | Top bar icon |
| `InterfaceToggleImageId` | string | rbxasset | Image inside the mobile ≡ button |
| `CloseCallback` | function | empty | Called when UI is closed/hidden |

---

## Themes

| Theme | Description | Accent |
|---|---|---|
| `Default` | SarXNight Purple & Night | Purple `(128,96,232)` |
| `Dark` | Pure dark | Blue `(0,175,255)` |

### Switch theme at runtime
```lua
SarXNightLib:SetTheme("Dark")     -- updates ALL existing elements live
SarXNightLib:SetTheme("Default")
```

---

## Search Bar

Every window has a **search bar** at the top of the sidebar — type to filter tabs by name.
The white-color bug is **fixed**; it now properly uses the theme's background and text colors.

---

## Tabs (no sections)

```lua
local Main = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998"   -- optional, "" = no icon
})
```
Tabs are searchable and the first tab is auto-selected.

---

## Elements

### Label
```lua
local lbl = Main:AddLabel("Hello World")
lbl:Set("Updated text")
```

### Paragraph
```lua
local p = Main:AddParagraph("Title", "Some long content text.")
p:Set("New content")
```

### Paragraph Image
```lua
local pi = Main:AddParagraphImage({
    Title = "Featured",
    Content = "Check this out.",
    Image = "rbxassetid://1234567890",
    ImageHeight = 110
})
pi:SetImage("rbxassetid://9999")
pi:SetTitle("New Title")
pi:SetContent("New body")
```

### Paragraph Update Log (NEW formatting — no `\n-`)
You can now pass a **table of lines** (recommended) or a string. Both auto-format into clean **• bullets**.

```lua
-- Recommended: table of lines
Main:AddParagraphUpdateLog({
    Title = "Changelog",
    Version = "v1.2.5-BETA",
    Image = "rbxassetid://1234567890",   -- optional
    ImageHeight = 100,
    Content = {
        "Mobile-friendly sizing",
        "Legacy dragging for window + toggle",
        "Big-bar slider (Orion style)",
        "Fixed search bar color",
        "Zero-lag performance",
    }
})

-- Also works with a string (leading dashes auto-stripped → bullets)
Main:AddParagraphUpdateLog({
    Title = "Changelog",
    Version = "v1.2.5",
    Content = "- Added X\n- Fixed Y\n- Improved Z"
})
```
> Output renders as:
> ```
> • Added X
> • Fixed Y
> • Improved Z
> ```

### Paragraph Socials (copy link)
```lua
Main:AddParagraphSocials({
    Title = "Our Socials",
    Socials = {
        { Name = "Discord", Link = "https://discord.gg/example" },
        { Name = "YouTube", Link = "https://youtube.com/@example" },
    }
})
```

### Button
```lua
local btn = Main:AddButton({
    Name = "Execute",
    Icon = "rbxassetid://3944703587",   -- optional
    Callback = function() print("clicked") end
})
btn:Set("New Label")
```

### Toggle
```lua
local t = Main:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "autofarm", Save = true,
    Callback = function(state) print(state) end
})
t:Set(true)
print(t.Value)
```

### Slider (REWORKED — big bar, Orion style)
The slider is now a **big bar** with the value displayed **inside the bar**, plus an editable input box on the right.

```lua
local s = Main:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Increment = 1,
    Default = 16,
    ValueName = "spd",
    Color = Color3.fromRGB(128, 96, 232),  -- optional
    Flag = "speed", Save = true,
    Callback = function(v) print(v) end
})
s:Set(100)
print(s.Value)
```
> - Drag anywhere along the **big bar** (touch supported).
> - The value also shows **inside the fill** and **on the bar**.
> - Type an exact number in the box on the right.

### Dropdown (3 visible + scroll)
```lua
local d = Main:AddDropdown({
    Name = "Mode",
    Options = {"Easy","Medium","Hard","Insane","Nightmare"},
    Default = "Easy",
    Flag = "mode", Save = true,
    Callback = function(option) print(option) end
})
d:Set("Hard")
d:Refresh({"A","B","C"}, true)   -- (newOptions, deleteOld)
print(d.Value)
```

### Keybind (Bind)
```lua
local k = Main:AddBind({
    Name = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Hold = false,
    Flag = "flykey", Save = true,
    Callback = function() print("Fly pressed") end
})
k:Set(Enum.KeyCode.G)
print(k.Value)
```

### Textbox
```lua
local tb = Main:AddTextbox({
    Name = "Username",
    Default = "",
    TextDisappear = false,
    Callback = function(text) print(text) end
})
tb:Set("Hello")
print(tb.Get())
```

### Colorpicker (mobile-friendly)
```lua
local c = Main:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(128, 96, 232),
    Flag = "espcolor", Save = true,
    Callback = function(color) print(color) end
})
c:Set(Color3.fromRGB(0, 255, 0))
print(c.Value)
```
> Both the saturation/value square and the hue strip support **touch** on mobile,
> using a single render-step connection per drag for **better performance**.

---

## Notifications

```lua
SarXNightLib:MakeNotification({
    Name = "Success",
    Content = "Script loaded successfully!",
    Image = "rbxassetid://4384403532",   -- optional
    Time = 5
})
```

---

## Config System

Add a `Flag` and `Save = true` to any stateful element. Config is saved
automatically per **GameId** on change.

```lua
SarXNightLib:Init()   -- auto-loads <ConfigFolder>/<GameId>.txt
```
Supported: **Toggle, Slider, Dropdown, Bind, Colorpicker**.

---

## Mobile Support

- A draggable floating **≡** button (uses `InterfaceToggleImageId`) opens/closes the UI.
- **Legacy dragging** (smooth tween) for both the window and the toggle.
- **Tap vs drag** detection — a quick tap toggles, holding & moving drags.
- Window auto-resizes smaller (470×300) and the sidebar narrows (130px).
- Sliders, dropdowns, colorpicker and dragging all support **touch**.

---

## Performance (Zero-lag improvements in v1.2.5)

- Idle cleanup loop polls every **0.5s** instead of every frame.
- Search filter only flips frame **visibility** (no rebuilds).
- Colorpicker uses **one** `RenderStepped` connection per active drag and disconnects on release.
- Slider uses lightweight `InputChanged` instead of per-frame stepping.

---

## Hiding / Destroying

```lua
-- Hide: click ✕ (RightShift or ≡ to reopen)
SarXNightLib:Destroy()   -- remove entire UI
```

---

## Full Example

```lua
local Lib = loadstring(game:HttpGet("YOUR_URL/Source.luau"))()

local Window = Lib:MakeWindow({
    Name = "SarXNight Hub",
    Theme = "Default",
    ConfigFolder = "SarXNight",
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "SarXNight Hub",
    InterfaceToggleImageId = "rbxassetid://8834748103"
})

local Main = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
local Settings = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483345998" })
local Info = Window:MakeTab({ Name = "Info" })

Main:AddLabel("Welcome!")

Main:AddSlider({
    Name = "Speed", Min = 16, Max = 200, Default = 16, ValueName = "spd",
    Flag = "speed", Save = true,
    Callback = function(v) print("Speed:", v) end
})

Main:AddToggle({
    Name = "Auto Farm", Flag = "autofarm", Save = true,
    Callback = function(s) print("AutoFarm:", s) end
})

Main:AddDropdown({
    Name = "Mode", Options = {"A","B","C","D","E"},
    Flag = "mode", Save = true,
    Callback = function(o) print("Mode:", o) end
})

Main:AddColorpicker({
    Name = "ESP Color", Default = Color3.fromRGB(128, 96, 232),
    Flag = "esp", Save = true,
    Callback = function(c) print(c) end
})

Settings:AddDropdown({
    Name = "Theme", Options = {"Default", "Dark"}, Default = "Default",
    Callback = function(t) Lib:SetTheme(t) end
})

Info:AddParagraphUpdateLog({
    Title = "Changelog",
    Version = "v1.2.5-BETA",
    Content = {
        "Mobile-friendly sizing",
        "Legacy dragging for window + toggle",
        "Big-bar slider (Orion style)",
        "Update log now uses clean bullets",
        "Fixed search bar color",
        "Zero-lag performance",
    }
})

Info:AddParagraphSocials({
    Title = "Socials",
    Socials = { { Name = "Discord", Link = "https://discord.gg/example" } }
})

Lib:Init()
```

---

## Element Reference Table

| Element | Method | Returns | Flag/Save |
|---|---|---|---|
| Tab | `Window:MakeTab(cfg)` | tab object | — |
| Label | `Tab:AddLabel(text)` | `{Set}` | — |
| Paragraph | `Tab:AddParagraph(title, content)` | `{Set}` | — |
| Paragraph Image | `Tab:AddParagraphImage(cfg)` | `{SetImage, SetTitle, SetContent}` | — |
| Update Log | `Tab:AddParagraphUpdateLog(cfg)` | `{SetContent}` | — |
| Socials | `Tab:AddParagraphSocials(cfg)` | Frame | — |
| Button | `Tab:AddButton(cfg)` | `{Set}` | — |
| Toggle | `Tab:AddToggle(cfg)` | `{Set, Value}` | ✅ |
| Slider | `Tab:AddSlider(cfg)` | `{Set, Value}` | ✅ |
| Dropdown | `Tab:AddDropdown(cfg)` | `{Set, Refresh, Value}` | ✅ |
| Bind | `Tab:AddBind(cfg)` | `{Set, Value}` | ✅ |
| Textbox | `Tab:AddTextbox(cfg)` | `{Set, Get}` | — |
| Colorpicker | `Tab:AddColorpicker(cfg)` | `{Set, Value}` | ✅ |

| Library Method | Description |
|---|---|
| `SarXNightLib:MakeWindow(cfg)` | Create the main window |
| `SarXNightLib:MakeNotification(cfg)` | Show a notification |
| `SarXNightLib:SetTheme(name)` | Switch theme live (`"Default"`/`"Dark"`) |
| `SarXNightLib:Init()` | Auto-load saved config |
| `SarXNightLib:Destroy()` | Remove the entire UI |

---

*SarXNightLib v1.2.5-BETA — successor to OrionLib (discontinued). Inspired by Orion UI Library.*
```

---

## Summary of v1.2.5-BETA Changes

### ✨ New / Reworked
1. **Mobile-friendly sizing** — `winW/winH` shrink to `470×300` on touch, sidebar to `130px`, both clamp to viewport.
2. **Legacy dragging** — `AddDraggingFunctionality` now tweens position (smooth Orion-style) for both the window and the mobile ≡ toggle.
3. **Update Log reworked** — new `buildContent` helper accepts a **table of lines** or a string, auto-converting to clean `•` bullets (no raw `\n-`). RichText enabled.
4. **Slider rework (big bar / Orion-style)** — value shows **inside the fill** and **on the bar**, with an editable input box on the right.
5. **v1.2.5 design** refresh — themed search box, consistent spacing.

### 🐛 Fixes
6. **Search bar white-color issue** — now registered as a theme object using `Main` background + theme text color + themed placeholder.

### ⚡ Performance (Zero-lag)
7. Cleanup loop polls every **0.5s** instead of every frame.
8. Search filter only toggles frame **visibility**.
9. Colorpicker uses **one** render-step connection per drag (disconnects on release).
