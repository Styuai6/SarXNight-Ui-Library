# SarXNight Library — Documentation

A clean, mobile-friendly Roblox UI library with image-based icons, search-filtered tabs, scrollable dropdowns, typeable sliders, rich paragraphs, and a polished animated loading screen.

---

## What's New

- **Slider input box** — type an exact value next to any slider. Drag *or* type.
- **Paragraph image** — paragraphs now support an optional left-aligned image/logo.
- **Paragraph socials** — add copyable social links (Discord, YouTube, etc.) right inside a paragraph. One click copies to clipboard with a confirmation notification.
- Fully backward-compatible: the old `AddParagraph("Title", "Content")` call still works.

---

## Quick Start

```lua
local SarXNight = loadstring(game:HttpGet("https://github.com/Styuai6/SarXNight-Ui-Library/blob/main/Source.luau"))()

local Window = SarXNight:MakeWindow({
    Name = "My Hub",
    InterfaceId = "rbxassetid://11436111346",
    LoadingLogoId = "rbxassetid://11436111346",
    IntroText = "My Hub",
    SaveConfig = true,
    ConfigFolder = "MyHub"
})

local Main = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://10723345516" })

Main:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "autofarm", Save = true,
    Callback = function(v) print("Auto Farm:", v) end
})

SarXNight:Init()
```

---

## Loading the Library

```lua
local SarXNight = loadstring(game:HttpGet("YOUR_URL/Source.luau"))()
```

---

## Creating a Window

```lua
local Window = SarXNight:MakeWindow({
    Name = "My Script Hub",
    InterfaceId = "rbxassetid://11436111346",   -- window + mobile toggle icon
    LoadingLogoId = "rbxassetid://11436111346", -- loading screen logo
    IntroEnabled = true,
    IntroText = "Welcome",
    SaveConfig = true,
    ConfigFolder = "MyScriptHub",
    CloseCallback = function()
        print("UI was hidden")
    end
})
```

### MakeWindow parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | string | `"SarXNight Library"` | Window title text |
| `InterfaceId` | string | default asset | rbxassetid for the window title icon and mobile floating toggle |
| `LoadingLogoId` | string | default asset | rbxassetid for the logo shown inside the loading-screen circle |
| `IntroEnabled` | bool | `true` | Show loading screen on startup |
| `IntroText` | string | `"SarXNight Library"` | Typewriter text under the logo |
| `SaveConfig` | bool | `false` | Auto-save flagged elements to file |
| `ConfigFolder` | string | `Name` | Folder name for the config file |
| `CloseCallback` | function | empty | Called when the X button is pressed |

> **Legacy support:** `Icon` is accepted as an alias for `InterfaceId`, and `IntroIcon` for `LoadingLogoId`.

---

## Creating a Tab

```lua
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10723345516"
})
```

| Field | Type | Description |
|---|---|---|
| `Name` | string | Tab label (used by the search filter) |
| `Icon` | string | rbxassetid for the tab icon |

> Use the search box at the top of the sidebar to filter tabs in real time.

---

## Sections

```lua
local Section = Tab:AddSection({ Name = "Combat" })
Section:AddButton({ ... })
```

---

## Elements

### Button
```lua
Tab:AddButton({
    Name = "Click me",
    Callback = function() print("Clicked!") end
})
```

### Toggle
```lua
local myToggle = Tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Color = Color3.fromRGB(130,110,230), -- optional
    Flag = "autofarm",
    Save = true,
    Callback = function(v) print(v) end
})

myToggle:Set(true) -- programmatically set
```

### Slider (Drag + Type) — **Updated**
The slider now includes a number input box. Users can **drag** the bar or **type** an exact value.

```lua
local mySlider = Tab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Increment = 1,
    ValueName = "studs/s",
    Color = Color3.fromRGB(130,110,230), -- optional
    Flag = "walkspeed",
    Save = true,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

mySlider:Set(120) -- updates bar AND input box
```

| Field | Type | Description |
|---|---|---|
| `Min` / `Max` | number | Range bounds |
| `Increment` | number | Step size for rounding |
| `Default` | number | Starting value |
| `ValueName` | string | Suffix shown on the bar (e.g. "studs/s") |
| `Flag` / `Save` | string / bool | Persistence |

> Typed values are automatically clamped to `Min`/`Max`. Invalid input reverts to the last valid value.

### Dropdown (max 3 visible, scrollable)
```lua
local myDropdown = Tab:AddDropdown({
    Name = "Mode",
    Options = {"One", "Two", "Three", "Four", "Five", "Six"},
    Default = "One",
    Flag = "mode", Save = true,
    Callback = function(v) print(v) end
})

-- Repopulate dynamically (clears old options)
myDropdown:Refresh({"New1", "New2", "New3"}, true)
myDropdown:Set("New2")
```

### Bind (Keybind)
```lua
Tab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Flag = "togglekey", Save = true,
    Callback = function() print("pressed") end
})
```

### Textbox
```lua
Tab:AddTextbox({
    Name = "Username",
    Default = "",
    TextDisappear = false,
    Callback = function(text) print(text) end
})
```

### Colorpicker
```lua
Tab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255,0,0),
    Flag = "espcolor", Save = true,
    Callback = function(c) print(c) end
})
```

### Label
```lua
local lbl = Tab:AddLabel("Status: Ready")
lbl:Set("Status: Running")
```

### Paragraph — **Updated**
The paragraph supports two call styles. The new table style unlocks an optional **image** and **copyable socials**.

**Legacy style (still works):**
```lua
local p = Tab:AddParagraph("Title", "Long descriptive content...")
p:Set("New content")
```

**New table style:**
```lua
Tab:AddParagraph({
    Title = "Nightfall Hub",
    Content = "Thanks for using our hub! Join our community below.",
    Image = "rbxassetid://11436111346", -- optional left logo
    Socials = {
        { Name = "Discord", Value = "https://discord.gg/yourinvite", Icon = "rbxassetid://10723415903" },
        { Name = "YouTube", Value = "https://youtube.com/@yourchannel", Icon = "rbxassetid://10734950309" },
        { Name = "Copy Key", Value = "FREE-KEY-12345" }
    }
})
```

| Field | Type | Description |
|---|---|---|
| `Title` | string | Bold heading |
| `Content` | string | Wrapped body text |
| `Image` | string | *(optional)* rbxassetid shown on the left |
| `Socials` | table | *(optional)* array of `{ Name, Value, Icon }` — each is a copy-to-clipboard chip |

> Clicking a social chip copies its `Value` to the clipboard, flashes **"Copied!"**, and fires a notification.

---

## Notifications

```lua
SarXNight:MakeNotification({
    Name = "Loaded",
    Content = "Welcome to the hub!",
    Image = "rbxassetid://10709751939", -- optional
    Time = 5
})
```

---

## Hiding & Showing the UI

- **PC:** press `RightShift` to re-show the UI after closing.
- **Mobile:** a draggable floating icon (using your `InterfaceId`) appears. **Tap** it to reopen — dragging won't trigger a reopen.

---

## Saving Config

Call `SarXNight:Init()` after building all your elements:

```lua
-- ... build window, tabs, elements with Flag and Save = true ...
SarXNight:Init()
```

---

## Destroying the UI

```lua
SarXNight:Destroy()
```

---

## Full Example

```lua
local SarXNight = loadstring(game:HttpGet("https://github.com/Styuai6/SarXNight-Ui-Library/blob/main/Source.luau"))()

local Window = SarXNight:MakeWindow({
    Name = "Nightfall Hub",
    InterfaceId = "rbxassetid://11436111346",
    LoadingLogoId = "rbxassetid://11436111346",
    IntroText = "Nightfall Hub",
    IntroEnabled = true,
    SaveConfig = true,
    ConfigFolder = "NightfallHub",
    CloseCallback = function() print("Hidden") end
})

-- ===== HOME TAB =====
local Home = Window:MakeTab({ Name = "Home", Icon = "rbxassetid://10723345516" })

Home:AddParagraph({
    Title = "Welcome!",
    Content = "Thanks for using Nightfall Hub. Join our community for updates and support.",
    Image = "rbxassetid://11436111346",
    Socials = {
        { Name = "Discord", Value = "https://discord.gg/example" },
        { Name = "YouTube", Value = "https://youtube.com/@example" }
    }
})

local Status = Home:AddLabel("Status: Idle")

Home:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

-- ===== PLAYER TAB =====
local Player = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://10747384394" })

local function getHum()
    local c = game.Players.LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

Player:AddSlider({
    Name = "WalkSpeed", Min = 16, Max = 300, Default = 16, ValueName = "studs/s",
    Flag = "ws", Save = true,
    Callback = function(v) local h = getHum(); if h then h.WalkSpeed = v end end
})

Player:AddSlider({
    Name = "JumpPower", Min = 50, Max = 500, Default = 50, ValueName = "power",
    Flag = "jp", Save = true,
    Callback = function(v) local h = getHum(); if h then h.JumpPower = v end end
})

Player:AddToggle({
    Name = "Infinite Jump", Default = false,
    Flag = "infjump", Save = true,
    Callback = function(s) _G.InfJump = s end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then local h = getHum(); if h then h:ChangeState("Jumping") end end
end)

-- ===== COMBAT TAB =====
local Combat = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://10734898355" })

Combat:AddSection({ Name = "Auto Farm" })

Combat:AddToggle({
    Name = "Enable Auto Farm", Default = false,
    Flag = "autofarm", Save = true,
    Callback = function(s) _G.AutoFarm = s end
})

local targetDrop = Combat:AddDropdown({
    Name = "Target Mob",
    Options = {"Bandit", "Goblin", "Wolf", "Troll", "Dragon", "Boss"},
    Default = "Bandit",
    Flag = "target", Save = true,
    Callback = function(v) _G.Target = v end
})

Combat:AddSlider({
    Name = "Attack Range", Min = 5, Max = 100, Default = 15, ValueName = "studs",
    Flag = "range", Save = true,
    Callback = function(v) _G.Range = v end
})

-- ===== VISUALS TAB =====
local Visual = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://10747373144" })

Visual:AddToggle({
    Name = "ESP", Default = false,
    Flag = "esp", Save = true,
    Callback = function(s) _G.ESP = s end
})

Visual:AddColorpicker({
    Name = "ESP Color", Default = Color3.fromRGB(255,0,0),
    Flag = "espcolor", Save = true,
    Callback = function(c) _G.ESPColor = c end
})

-- ===== SETTINGS TAB =====
local Settings = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://10709751939" })

Settings:AddBind({
    Name = "Toggle UI", Default = Enum.KeyCode.RightShift,
    Flag = "uitoggle", Save = true,
    Callback = function() end
})

Settings:AddTextbox({
    Name = "Webhook URL", Default = "",
    Callback = function(t) _G.Webhook = t end
})

Settings:AddButton({
    Name = "Unload",
    Callback = function()
        SarXNight:MakeNotification({ Name = "Unloading", Content = "Bye!", Time = 2 })
        wait(2); SarXNight:Destroy()
    end
})

-- ===== INIT (always last) =====
SarXNight:Init()

SarXNight:MakeNotification({
    Name = "Nightfall Hub",
    Content = "Loaded! Press RightShift to hide.",
    Time = 6
})
```

---

## All Methods Reference

### Library
| Method | Description |
|---|---|
| `SarXNight:MakeWindow(config)` | Creates the main window, returns a Window |
| `SarXNight:MakeNotification(config)` | Shows a bottom-right notification |
| `SarXNight:Init()` | Loads saved config (call last) |
| `SarXNight:Destroy()` | Removes the entire UI |

### Window
| Method | Description |
|---|---|
| `Window:MakeTab(config)` | Creates a sidebar tab, returns a Tab |

### Tab / Section
| Method | Returns | `:Set()` |
|---|---|---|
| `:AddSection({Name})` | Section | — |
| `:AddLabel(text)` | Label | ✅ |
| `:AddParagraph(title, content)` *or* `:AddParagraph({...})` | Paragraph | ✅ |
| `:AddButton({Name, Callback})` | Button | ✅ (text) |
| `:AddToggle({...})` | Toggle | ✅ |
| `:AddSlider({...})` | Slider | ✅ |
| `:AddDropdown({...})` | Dropdown | ✅ + `:Refresh()` |
| `:AddBind({...})` | Bind | ✅ |
| `:AddTextbox({...})` | — | — |
| `:AddColorpicker({...})` | Colorpicker | ✅ |

---

## Best Practices

- **Always set `Flag` + `Save = true`** on persistent settings.
- **Call `SarXNight:Init()` last**, after all elements are created.
- **Wrap risky callbacks in `pcall`** to avoid breaking your script.
- **Use sections** to group related controls.
- **Keep dropdowns short** or use `:Refresh()` to repopulate (max 3 visible, rest scroll).
- **Use paragraph socials** instead of plain text links — they're one-click copyable.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Library doesn't show up | Verify the raw URL and that your executor supports `loadstring + HttpGet` |
| Icons are blank | Replace placeholder `rbxassetid://` with your own uploaded IDs |
| Mobile toggle vanishes | It appears only after the X button is clicked. Drag it where you want. |
| Config not saving | Set `SaveConfig = true` on the window AND `Save = true` + a unique `Flag` per element |
| Slider input won't accept value | Only numbers are accepted; out-of-range values are clamped automatically |
| Socials don't copy | Your executor must support `setclipboard` |

---

## License

Free to use, modify, and redistribute. Credit appreciated but not required.
