# SarXNightLib v1.3.0 Documentation

> Inspired by Orion UI Library (**discontinued**). Reworked design v1.3.0.

## What's New in v1.3.0
- ✅ **Legacy dragging — NO smooth, NO tween** (raw direct position, like old Orion) for both window & toggle
- ✅ **InterfaceToggle** uses **native `Draggable = true` + `Active = true`** (legacy, no tween) — drag applies **only** to the toggle button, **not** the window
- ✅ New reworked **Design v1.3.0**
- ✅ **Mobile-friendly new slider** (taller touch bar, value-in-bar, input box)
- ✅ **Reworked theme** (deeper purple-night colors)
- ✅ `MakeWindow` → **`SizeWindow`** (`"Mobile"` / `"PC"` / `"Recommend"`)
- ✅ New reworked **loading screen** (card + spinning orbit ring + typewriter + bar)
- ✅ **Fixed Colorpicker drag** (was broken — now tracks active input across the global stream)

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
    InterfaceToggleImageId = "rbxassetid://8834748103",  -- image on the floating toggle button
    SizeWindow = "Recommend",                        -- NEW: "Mobile" | "PC" | "Recommend"
    CloseCallback = function() print("Closed") end
})
```

### `SizeWindow` option (NEW)
| Value | Size | Sidebar |
|---|---|---|
| `"Mobile"` | 470 × 300 | 130 |
| `"PC"` | 625 × 350 | 160 |
| `"Recommend"` | Auto — picks Mobile on touch devices, PC on desktop | auto |

> The window is also auto-clamped to the viewport so it never exceeds the screen.

---

## Dragging Behavior (v1.3.0)
| Element | Method | Smooth/Tween |
|---|---|---|
| **Window** | Legacy direct position via top-bar drag point | ❌ No smooth, no tween |
| **Interface Toggle** | Native Roblox `Draggable = true` + `Active = true` | ❌ No smooth, no tween |

- Window dragging is **raw legacy** — instant 1:1 follow, no easing.
- The floating toggle is a real **`ImageButton`** with `.Draggable = true` and `.Active = true`. Roblox's built-in drag handles its movement (legacy, instant). A 6px move-threshold separates **tap** (toggle the UI) from **drag** (reposition).
- The toggle drag is **isolated** — it never moves the window.

---

## Creating a Tab
```lua
local Main = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://7733964640" })
local Info = Window:MakeTab({ Name = "Info" })
```

The **search bar** above the tab list filters tabs live by name (automatic).

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

### Slider (mobile-friendly v1.3.0)
```lua
local s = Main:AddSlider({
    Name = "Speed", Min = 16, Max = 200, Increment = 1, Default = 16,
    ValueName = "spd", Flag = "Speed", Save = true,
    Callback = function(v) print(v) end
})
s:Set(100)
```
> Big bar with the value shown **inside** the fill, a **taller touch target on mobile** (32px vs 28px), and an editable **input box** on the right.

### Dropdown (max 3 visible + scroll)
```lua
local d = Main:AddDropdown({
    Name = "Mode", Options = {"A","B","C","D","E"}, Default = "A",
    Flag = "Mode", Save = true, Callback = function(o) print(o) end
})
d:Set("C")
d:Refresh({"X","Y","Z"}, true)
```

### Colorpicker (FIXED drag — mobile + mouse)
```lua
Main:AddColorpicker({ Name = "ESP", Default = Color3.fromRGB(255,0,0),
    Flag = "ESP", Save = true, Callback = function(c) print(c) end })
```
> Drag now works reliably. The picker tracks the **active input** (saturation/value box or hue strip) across the global input stream instead of relying on per-frame RenderStepped capture.

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

### Paragraph Update Log (bullet formatting + optional image)
```lua
-- Pass a TABLE of lines (auto-bulleted with •), or a "-" string
Info:AddParagraphUpdateLog({
    Title = "Changelog", Version = "v1.3.0",
    Image = "rbxassetid://4384403532",   -- optional
    Content = {
        "Legacy dragging (no smooth/no tween)",
        "Native Draggable toggle",
        "New design v1.3.0",
        "Mobile-friendly slider",
        "Fixed colorpicker drag"
    }
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

## Themes (reworked v1.3.0)
```lua
SarXNightLib:MakeWindow({ Theme = "Dark" })
SarXNightLib:SetTheme("Dark")  -- runtime switch
```

| Theme | Accent | Main |
|---|---|---|
| Default | `RGB(140,105,245)` | `RGB(22,20,32)` |
| Dark | `RGB(0,170,255)` | `RGB(14,14,14)` |

---

## Mobile
- Floating toggle button (custom image via `InterfaceToggleImageId`) — **tap** to open/close, **drag** to reposition (native `Draggable`).
- **RightShift** reopens on PC.
- Slider (taller bar), Colorpicker, Dropdown, Bind all support **Touch**.
- Use `SizeWindow = "Mobile"` (or `"Recommend"`) for the compact 470×300 layout.

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

*SarXNightLib v1.3.0 — Legacy Dragging • SizeWindow • Reworked Design & Theme • Fixed Colorpicker*
````

---

## Changelog Summary (v1.3.0)

| # | Change | Status |
|---|--------|--------|
| 1 | Window drag = **legacy, no smooth, no tween** (raw direct position) | ✅ |
| 2 | InterfaceToggle = native **`Draggable = true` + `Active = true`** (legacy, toggle only, not window) | ✅ |
| 3 | New reworked **Design v1.3.0** | ✅ |
| 4 | **Mobile-friendly slider** (taller touch bar, value-in-bar, input box) | ✅ |
| 5 | **Reworked theme** (deeper purple-night palette) | ✅ |
| 6 | `MakeWindow` → **`SizeWindow`** (`Mobile`/`PC`/`Recommend`) | ✅ |
| 7 | New reworked **loading screen** (card + spinning orbit ring + typewriter + bar) | ✅ |
| 8 | **Fixed Colorpicker drag** (now tracks active input on the global stream) | ✅ |

### Key technical notes
- **Window dragging** changed from the v1.2.5 tween-based drag back to **raw `Main.Position` assignment** — instant, no easing.
- **Interface toggle** is now an `ImageButton` with `.Draggable = true` and `.Active = true`, so Roblox's native legacy drag moves it (isolated from the window). A 6px threshold still distinguishes tap-to-toggle from drag.
- **Colorpicker** was broken because the old RenderStepped capture could drop the connection; v1.3.0 uses a simple `ColorActive`/`HueActive` boolean tracked through the single global `InputChanged` stream with `GetMouseLocation()` — works for both mouse and touch.
