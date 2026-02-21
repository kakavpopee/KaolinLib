# 🧱 KaolinLib — Official Documentation
**Version 1.0 | "Like Bricks, Built Solid."**

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Loading the Library](#loading-the-library)
3. [CreateWindow](#createwindow)
4. [CreateTab](#createtab)
5. [CreateSection](#createsection)
6. [CreateSeparator](#createseparator)
7. [CreateLabel](#createlabel)
8. [CreateToggle](#createtoggle)
9. [CreateSlider](#createslider)
10. [CreateButton](#createbutton)
11. [CreateTextBox](#createtextbox)
12. [CreateDropdown](#createdropdown)
13. [CreateColorPicker](#createcolorpicker)
14. [Notify](#notify)
15. [BindKey](#bindkey)
16. [BindToggleKey](#bindtogglekey)
17. [Theming](#theming)
18. [Full Theme Reference](#full-theme-reference)
19. [Mobile Support](#mobile-support)
20. [Common Errors](#common-errors)
21. [Full Example](#full-example)

---

## Getting Started

KaolinLib is a **Roblox Luau UI library** that lets you build professional script hub interfaces with just a few lines of code. It works on both **PC and Mobile** automatically.

### Requirements
- Roblox Studio (for testing)
- HTTP Requests enabled in Game Settings
- A LocalScript

### How to enable HTTP Requests in Studio
1. Click **Home** at the top of Studio
2. Click **Game Settings**
3. Go to the **Security** tab
4. Turn on **Allow HTTP Requests**
5. Click Save

---

## Loading the Library

### From GitHub (Recommended)
Paste this at the very top of your LocalScript:

```lua
local KaolinLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"
))()
```

Replace `YOURNAME` with your actual GitHub username.

### From a ModuleScript (Studio Only)
1. Put `KaolinLib.lua` inside a **ModuleScript** in `StarterPlayerScripts`
2. Name the ModuleScript `KaolinLib`
3. In your LocalScript:

```lua
local KaolinLib = require(script.Parent.KaolinLib)
```

---

## CreateWindow

Creates the main hub window. This is always the **first thing** you call.

```lua
local Window = KaolinLib:CreateWindow(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Title` | string | No | The name shown in the title bar. Default: `"KaolinLib"` |
| `SubTitle` | string | No | Smaller text underneath the title. Default: `"v1.0"` |
| `Theme` | table | No | Color overrides (see Theming section) |

### Example

```lua
local Window = KaolinLib:CreateWindow({
    Title    = "KaolinHub",
    SubTitle = "v1.0 by YourName",
})
```

### What You Get Automatically

Every window comes with these built in — you don't need to do anything extra:

**Dragging** — grab the gold title bar and drag the window anywhere on screen. Works with both mouse and finger touch.

**Close Button (✕)** — hides the window. A small 🧱 brick button appears in the corner so you can bring it back.

**Minimise Button (—)** — collapses the window down to just the title bar to save screen space. Click it again to restore.

**Slide-in Animation** — the window smoothly slides in from above when your script loads.

**Notification System** — call `Window:Notify()` from anywhere in your script to show pop-up alerts (see Notify section).

---

## CreateTab

Creates a tab inside your window. Tabs appear as buttons in the left sidebar.

```lua
local Tab = Window:CreateTab(name, icon)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | The label shown on the tab button |
| `icon` | string | No | An emoji shown above the label |

### Example

```lua
local MoveTab   = Window:CreateTab("Movement", "🏃")
local PlayerTab = Window:CreateTab("Player",   "👤")
local WorldTab  = Window:CreateTab("World",    "🌍")
local MiscTab   = Window:CreateTab("Misc",     "⚙️")
```

### Notes

- The **first tab you create** is automatically selected and visible when the hub loads
- You can create as many tabs as you want
- All components are added **inside** a tab using the Tab variable

---

## CreateSection

Adds a gold section header label inside a tab to organise your components into groups.

```lua
Tab:CreateSection(text)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | string | Yes | The text shown in the section header |

### Example

```lua
MoveTab:CreateSection("Locomotion")
MoveTab:CreateSection("Speed Settings")
MoveTab:CreateSection("Teleport")
```

### Returns
Nothing. This is purely visual.

---

## CreateSeparator

Adds a thin horizontal line to visually separate components.

```lua
Tab:CreateSeparator()
```

### Parameters
None.

### Example

```lua
MoveTab:CreateToggle({ Name = "Fly", Callback = function(v) end })
MoveTab:CreateSeparator()
MoveTab:CreateToggle({ Name = "Noclip", Callback = function(v) end })
```

### Returns
Nothing.

---

## CreateLabel

Adds a line of display text. Can be updated from code at any time.

```lua
local Label = Tab:CreateLabel(text)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | string | Yes | The text to display |

### Example

```lua
local statusLabel = MoveTab:CreateLabel("Status: Idle")
```

### Returns — Label Object

| Method | Description |
|--------|-------------|
| `Label:Set(text)` | Changes the displayed text |

### Full Example

```lua
local statusLabel = MoveTab:CreateLabel("Status: Idle")

-- Later in your code, update it:
statusLabel:Set("Status: Flying!")
statusLabel:Set("Status: " .. tostring(someValue))
```

---

## CreateToggle

Adds an animated on/off switch.

```lua
local Toggle = Tab:CreateToggle(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown next to the toggle |
| `Desc` | string | No | Smaller description text below the name |
| `Default` | boolean | No | Starting state. `true` = on, `false` = off. Default: `false` |
| `Callback` | function | Yes | Function called when the toggle changes. Receives `Value` (boolean) |

### Example

```lua
local flyToggle = MoveTab:CreateToggle({
    Name     = "Fly",
    Desc     = "WASD + Space/Shift to navigate",
    Default  = false,
    Callback = function(Value)
        if Value then
            print("Fly turned ON")
            -- start your fly code here
        else
            print("Fly turned OFF")
            -- stop your fly code here
        end
    end
})
```

### Returns — Toggle Object

| Method | Description |
|--------|-------------|
| `Toggle:Set(boolean)` | Turns the toggle on or off from code and fires the Callback |
| `Toggle:Get()` | Returns the current state (`true` or `false`) |

### Full Example

```lua
local flyToggle = MoveTab:CreateToggle({
    Name     = "Fly",
    Default  = false,
    Callback = function(Value)
        -- your logic here
    end
})

-- Turn on from code (e.g. from a keybind):
flyToggle:Set(true)

-- Turn off from code:
flyToggle:Set(false)

-- Check current state:
if flyToggle:Get() then
    print("Fly is currently ON")
end
```

### Hover Effect
Toggles automatically highlight when you hover over them (PC only).

---

## CreateSlider

Adds a draggable slider for numeric values. Works with both mouse drag and touch drag on mobile.

```lua
local Slider = Tab:CreateSlider(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown above the slider |
| `Min` | number | Yes | The minimum value |
| `Max` | number | Yes | The maximum value |
| `Default` | number | No | Starting value. Defaults to `Min` |
| `Suffix` | string | No | Text added after the number (e.g. `" studs/s"`) |
| `Callback` | function | Yes | Function called when value changes. Receives `Value` (number) |

### Example

```lua
local speedSlider = MoveTab:CreateSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 200,
    Default  = 50,
    Suffix   = " sp",
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value
        end
    end
})
```

### Returns — Slider Object

| Method | Description |
|--------|-------------|
| `Slider:Set(number)` | Sets the slider to a value from code and fires the Callback |
| `Slider:Get()` | Returns the current value as a number |

### Full Example

```lua
local speedSlider = MoveTab:CreateSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 200,
    Default  = 50,
    Callback = function(Value)
        -- apply value
    end
})

-- Set from a button:
MoveTab:CreateButton({
    Name     = "Reset Speed",
    Callback = function()
        speedSlider:Set(16)  -- snaps back to default
    end
})

-- Read current value:
print("Current speed:", speedSlider:Get())
```

### Notes
- Values are always **whole numbers** (integers), never decimals
- The slider clamps automatically — you can't go below Min or above Max

---

## CreateButton

Adds a clickable button with hover and click animations.

```lua
Tab:CreateButton(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown on the button |
| `Desc` | string | No | Smaller description text below the name |
| `Callback` | function | Yes | Function called when the button is clicked |

### Example

```lua
MoveTab:CreateButton({
    Name     = "Teleport to Spawn",
    Desc     = "Moves you to 0, 0, 0",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, 10, 0)
        end
    end
})
```

### Returns
Nothing. Buttons don't return an object because you don't need to control them from code.

### Animations
- **Hover** — background fades to a warm tint when your mouse enters
- **Click** — flashes gold for 0.1 seconds then returns to normal

---

## CreateTextBox

Adds a text input field the player can type into.

```lua
local TextBox = Tab:CreateTextBox(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown above the input field |
| `Default` | string | No | Placeholder text shown before typing |
| `ClearOnFocus` | boolean | No | If `true`, clears the box when clicked. Default: `false` |
| `Numeric` | boolean | No | If `true`, only allows numbers. Default: `false` |
| `Callback` | function | Yes | Function called when Enter is pressed or focus is lost. Receives `Value` (string) |

### Example

```lua
local nameBox = PlayerTab:CreateTextBox({
    Name         = "Target Player",
    Default      = "Enter player name...",
    ClearOnFocus = true,
    Callback     = function(Value)
        print("Searching for:", Value)
        local target = game.Players:FindFirstChild(Value)
        if target then
            print("Found:", target.Name)
        else
            print("Player not found")
        end
    end
})
```

### Returns — TextBox Object

| Method | Description |
|--------|-------------|
| `TextBox:Set(string)` | Sets the text inside the box from code |
| `TextBox:Get()` | Returns the current text as a string |

### Full Example

```lua
local nameBox = PlayerTab:CreateTextBox({
    Name     = "Custom Message",
    Default  = "Type here...",
    Callback = function(Value)
        print("You typed:", Value)
    end
})

-- Pre-fill the box from code:
nameBox:Set("Hello World")

-- Read whatever is typed:
local currentText = nameBox:Get()
```

### Notes
- The Callback fires when the player **presses Enter** or **clicks away** from the box
- If `Numeric = true` and the player types letters, the box reverts to the Default value
- The box highlights gold when focused

---

## CreateDropdown

Adds an expandable pick-one list. Tapping the header opens/closes the list.

```lua
local Dropdown = Tab:CreateDropdown(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown above the dropdown |
| `Options` | table | Yes | A list of strings to show as options |
| `Default` | string | No | The option selected by default. Defaults to first option |
| `Callback` | function | Yes | Function called when an option is picked. Receives `Value` (string) |

### Example

```lua
local teamDropdown = PlayerTab:CreateDropdown({
    Name     = "Select Team",
    Options  = {"Red Team", "Blue Team", "Green Team", "Spectator"},
    Default  = "Red Team",
    Callback = function(Value)
        print("Team selected:", Value)
        -- your team logic here
    end
})
```

### Returns — Dropdown Object

| Method | Description |
|--------|-------------|
| `Dropdown:Set(string)` | Sets the selected option from code |
| `Dropdown:Refresh(table)` | Replaces the entire options list with a new one |
| `Dropdown:Get()` | Returns the currently selected option as a string |

### Full Example

```lua
local gameDD = MiscTab:CreateDropdown({
    Name     = "Game Mode",
    Options  = {"Normal", "Hard", "Impossible"},
    Default  = "Normal",
    Callback = function(Value)
        print("Mode:", Value)
    end
})

-- Change selected from code:
gameDD:Set("Hard")

-- Completely swap out the options:
gameDD:Refresh({"Easy", "Medium", "Hard", "Expert", "Nightmare"})

-- Read what's currently selected:
print("Current mode:", gameDD:Get())
```

### Notes
- The list shows up to **5 items** at once then scrolls
- Each option highlights on hover
- The currently selected option is shown in gold bold text inside the list

---

## CreateColorPicker

Adds an HSV color picker. Tap the colored swatch to open and close it. Has Hue, Saturation, and Value sliders.

```lua
local ColorPicker = Tab:CreateColorPicker(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | string | Yes | The label shown next to the color swatch |
| `Default` | Color3 | No | The starting color. Default: red |
| `Callback` | function | Yes | Function called whenever the color changes. Receives a `Color3` value |

### Example

```lua
local highlightPicker = PlayerTab:CreateColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(Color)
        -- Color is a Color3 value
        print("R:", math.floor(Color.R * 255))
        print("G:", math.floor(Color.G * 255))
        print("B:", math.floor(Color.B * 255))
        -- apply to your ESP highlights etc
    end
})
```

### Returns — ColorPicker Object

| Method | Description |
|--------|-------------|
| `ColorPicker:Set(Color3)` | Sets the color from code and updates all sliders |
| `ColorPicker:Get()` | Returns the current color as a `Color3` value |

### Full Example

```lua
local bgPicker = WorldTab:CreateColorPicker({
    Name     = "Fog Color",
    Default  = Color3.fromRGB(200, 200, 220),
    Callback = function(Color)
        game:GetService("Lighting").FogColor = Color
    end
})

-- Set from code:
bgPicker:Set(Color3.fromRGB(255, 100, 50))

-- Read current color:
local currentColor = bgPicker:Get()
print(currentColor)
```

### How HSV Works
- **Hue** — the color itself (red → orange → yellow → green → blue → purple → back to red)
- **Saturation** — how vivid the color is (0 = grey, 1 = full color)
- **Value** — how bright the color is (0 = black, 1 = full brightness)

---

## Notify

Shows a pop-up notification that slides in from the right and auto-dismisses.

```lua
Window:Notify(config)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Title` | string | Yes | The bold title line of the notification |
| `Message` | string | Yes | The body text of the notification |
| `Duration` | number | No | How many seconds it stays on screen. Default: `3` |
| `Type` | string | No | Changes the accent color. Options: `"info"`, `"success"`, `"error"`. Default: `"info"` |

### Type Colors

| Type | Color | Use For |
|------|-------|---------|
| `"info"` | 🟡 Gold | General messages, status updates |
| `"success"` | 🟢 Green | Feature enabled, action completed |
| `"error"` | 🔴 Red | Something went wrong, invalid input |

### Example

```lua
-- Info notification (default)
Window:Notify({
    Title   = "KaolinHub",
    Message = "Hub loaded successfully!",
    Duration = 4,
    Type    = "info",
})

-- Success notification
Window:Notify({
    Title   = "Fly Enabled",
    Message = "You are now flying!",
    Type    = "success",
})

-- Error notification
Window:Notify({
    Title   = "Error",
    Message = "Player not found in server.",
    Duration = 5,
    Type    = "error",
})
```

### Notes
- Multiple notifications stack vertically
- Each one slides in from the right and slides out automatically
- You can call `Window:Notify()` from inside any Callback

---

## BindKey

Connects a keyboard key to a function. Only works on PC.

```lua
KaolinLib:BindKey(KeyCode, callback)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `KeyCode` | Enum.KeyCode | Yes | The key to listen for |
| `callback` | function | Yes | The function to run when the key is pressed |

### Example

```lua
-- Press F to toggle fly
KaolinLib:BindKey(Enum.KeyCode.F, function()
    print("F was pressed")
    flyToggle:Set(not flyToggle:Get())
end)

-- Press G to toggle god mode
KaolinLib:BindKey(Enum.KeyCode.G, function()
    godToggle:Set(not godToggle:Get())
end)

-- Press N to toggle noclip
KaolinLib:BindKey(Enum.KeyCode.N, function()
    noclipToggle:Set(not noclipToggle:Get())
end)
```

### Common KeyCodes

| Key | KeyCode |
|-----|---------|
| F | `Enum.KeyCode.F` |
| G | `Enum.KeyCode.G` |
| H | `Enum.KeyCode.H` |
| N | `Enum.KeyCode.N` |
| E | `Enum.KeyCode.E` |
| R | `Enum.KeyCode.R` |
| T | `Enum.KeyCode.T` |
| Left Shift | `Enum.KeyCode.LeftShift` |
| Left Ctrl | `Enum.KeyCode.LeftControl` |
| Tab | `Enum.KeyCode.Tab` |
| F1–F12 | `Enum.KeyCode.F1` through `Enum.KeyCode.F12` |

---

## BindToggleKey

A shortcut that makes a key show/hide your entire hub window.

```lua
KaolinLib:BindToggleKey(KeyCode, Window)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `KeyCode` | Enum.KeyCode | Yes | The key that toggles the hub |
| `Window` | Window object | Yes | The window returned from `CreateWindow` |

### Example

```lua
-- Press H to show/hide the hub
KaolinLib:BindToggleKey(Enum.KeyCode.H, Window)
```

When the hub is hidden, the floating 🧱 brick button is shown so you can restore it on mobile too.

---

## Theming

You can change any color in KaolinLib by passing a `Theme` table to `CreateWindow`. You only need to include the colors you want to change — everything else stays as the default gold theme.

```lua
local Window = KaolinLib:CreateWindow({
    Title    = "My Hub",
    SubTitle = "v1.0",
    Theme    = {
        Accent     = Color3.fromRGB(80, 180, 255),   -- change gold to blue
        Background = Color3.fromRGB(10, 10, 15),
        Card       = Color3.fromRGB(20, 20, 30),
    }
})
```

### Theme Preset Examples

**Blue Theme:**
```lua
Theme = {
    Accent        = Color3.fromRGB(80, 160, 255),
    ToggleOn      = Color3.fromRGB(80, 160, 255),
    TextSecondary = Color3.fromRGB(100, 120, 150),
}
```

**Red Theme:**
```lua
Theme = {
    Accent   = Color3.fromRGB(220, 60, 60),
    ToggleOn = Color3.fromRGB(220, 60, 60),
}
```

**Green Theme:**
```lua
Theme = {
    Accent   = Color3.fromRGB(60, 200, 100),
    ToggleOn = Color3.fromRGB(60, 200, 100),
}
```

**Dark Minimal Theme:**
```lua
Theme = {
    Accent      = Color3.fromRGB(200, 200, 200),
    ToggleOn    = Color3.fromRGB(200, 200, 200),
    Background  = Color3.fromRGB(10, 10, 10),
    BackgroundDark = Color3.fromRGB(6, 6, 6),
    Card        = Color3.fromRGB(18, 18, 18),
    ContentBg   = Color3.fromRGB(13, 13, 13),
}
```

---

## Full Theme Reference

Every color key you can override:

| Key | Default | Controls |
|-----|---------|----------|
| `Background` | Dark grey-black | Main window background |
| `BackgroundDark` | Darker grey-black | Tab sidebar background |
| `Card` | Slightly lighter dark | Toggle, slider, label background cards |
| `ContentBg` | Mid dark | The content panel next to the tabs |
| `Accent` | Gold `(200,160,80)` | Title bar, toggle on, slider fill, highlights |
| `AccentDark` | Darker gold | Accent hover states |
| `TextPrimary` | Near white | Main text on components |
| `TextSecondary` | Dim grey-blue | Description text, dim labels |
| `TextOnAccent` | Very dark | Text drawn on top of the Accent color |
| `ToggleOff` | Dark grey | Toggle pill when off |
| `ToggleOn` | Gold | Toggle pill when on |
| `ButtonBg` | Dark blue-grey | Button background |
| `ButtonHover` | Warm dark | Button on hover |
| `SliderTrack` | Dark blue-grey | The unfilled slider track |
| `DropdownBg` | Very dark | The dropdown list background |
| `DropdownItem` | Slightly lighter dark | Each option in the dropdown |
| `DropdownHover` | Warm dark | Dropdown option on hover |
| `InputBg` | Very dark | TextBox input background |
| `SeparatorColor` | Dark blue-grey | The separator line color |
| `ErrorColor` | Red `(220,80,80)` | Error notification accent |
| `SuccessColor` | Green `(80,200,120)` | Success notification accent |

---

## Mobile Support

KaolinLib automatically detects whether you're on mobile using:

```lua
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
```

### What Changes on Mobile

| Feature | PC | Mobile |
|---------|-----|--------|
| Dragging | Mouse drag on title bar | Finger drag on title bar |
| Sliders | Mouse drag | Touch drag with bigger handle and hit area |
| Toggles | Click | Tap (same) |
| Buttons | Click | Tap (same, slightly taller) |
| Dropdown | Click | Tap |
| Color Picker | Click swatch | Tap swatch |
| Teleport | Click on ground | Tap on ground (uses TouchTap) |
| Keyboard Shortcuts | Works | Does not work (no keyboard) |
| Restore Button | Works | Works (important since no `H` key) |
| Window size | 520×400 | 400×480 |
| Tab width | 110px | 80px |
| Text sizes | Slightly larger | Slightly smaller to fit screen |
| Scroll bar | 3px thick | 5px thick for easier grabbing |

### Mobile-Specific Notes
- All sliders have an invisible tall hit area above them so your finger doesn't need to be pixel-perfect
- Keybinds set with `BindKey` and `BindToggleKey` are silently ignored on mobile — they won't cause errors
- The floating 🧱 restore button is especially important on mobile since there's no H key

---

## Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `HttpService is not enabled` | HTTP is turned off in Studio | Go to Game Settings → Security → Allow HTTP Requests |
| `attempt to index nil with 'CreateTab'` | Window was not created successfully | Make sure `CreateWindow` came first and returned a value |
| `attempt to index nil with 'CreateToggle'` | Tab variable is nil | Check the tab was created with `Window:CreateTab()` |
| `attempt to call nil value` | Callback is not a function | Make sure `Callback = function(Value) ... end` |
| Raw URL returns HTML | Repo is private | Set GitHub repo to **Public** |
| Old code loading after update | GitHub CDN cache | Wait 5 minutes and try again |
| `loadstring is not enabled` | Running in a regular Script | Switch to a **LocalScript** |

---

## Full Example

A complete hub using every single feature in KaolinLib:

```lua
-- Load from GitHub
local KaolinLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"
))()

local Players    = game:GetService("Players")
local Lighting   = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local function GetHum()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- ── Window ────────────────────────────────────────────────────
local Window = KaolinLib:CreateWindow({
    Title    = "KaolinHub",
    SubTitle = "v1.0 — Full Demo",
    Theme    = {
        Accent = Color3.fromRGB(200, 160, 80),  -- default gold, change if you want
    }
})

-- ── MOVEMENT TAB ──────────────────────────────────────────────
local MoveTab = Window:CreateTab("Movement", "🏃")

MoveTab:CreateSection("Locomotion")

local flyToggle = MoveTab:CreateToggle({
    Name     = "Fly",
    Desc     = "WASD + Space to fly (PC)",
    Default  = false,
    Callback = function(Value)
        if Value then
            Window:Notify({ Title = "Fly", Message = "Flying enabled!", Type = "success" })
        else
            Window:Notify({ Title = "Fly", Message = "Flying disabled.", Type = "info" })
        end
        -- add your fly logic here
    end
})

MoveTab:CreateToggle({
    Name     = "Noclip",
    Desc     = "Walk through walls",
    Default  = false,
    Callback = function(Value)
        -- add your noclip logic here
    end
})

MoveTab:CreateToggle({
    Name     = "Infinite Jump",
    Desc     = "Jump over and over in midair",
    Default  = false,
    Callback = function(Value)
        -- add your infinite jump logic here
    end
})

MoveTab:CreateSeparator()
MoveTab:CreateSection("Speed & Jump")

local speedSlider = MoveTab:CreateSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 200,
    Default  = 50,
    Suffix   = " sp",
    Callback = function(Value)
        local hum = GetHum()
        if hum then hum.WalkSpeed = Value end
    end
})

MoveTab:CreateSlider({
    Name     = "Jump Power",
    Min      = 50,
    Max      = 300,
    Default  = 100,
    Callback = function(Value)
        local hum = GetHum()
        if hum then hum.JumpPower = Value end
    end
})

MoveTab:CreateSlider({
    Name     = "Fly Speed",
    Min      = 10,
    Max      = 200,
    Default  = 50,
    Suffix   = " sp",
    Callback = function(Value)
        -- store fly speed in your fly logic
    end
})

MoveTab:CreateButton({
    Name     = "Reset Speed",
    Desc     = "Returns walk speed to default",
    Callback = function()
        speedSlider:Set(16)
        Window:Notify({ Title = "Reset", Message = "Walk speed reset to 16.", Type = "info" })
    end
})

MoveTab:CreateSection("Teleport")

MoveTab:CreateButton({
    Name     = "Teleport to Origin",
    Desc     = "Moves you to 0, 50, 0",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(0, 50, 0)
            Window:Notify({ Title = "Teleported", Message = "Moved to origin!", Type = "success" })
        end
    end
})

-- ── PLAYER TAB ────────────────────────────────────────────────
local PlayerTab = Window:CreateTab("Player", "👤")

PlayerTab:CreateSection("Health")

local godToggle = PlayerTab:CreateToggle({
    Name     = "God Mode",
    Desc     = "Infinite health",
    Default  = false,
    Callback = function(Value)
        local hum = GetHum()
        if not hum then return end
        if Value then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
            Window:Notify({ Title = "God Mode ON", Message = "You cannot die!", Type = "success" })
        else
            hum.MaxHealth = 100
            hum.Health    = 100
            Window:Notify({ Title = "God Mode OFF", Message = "Health returned to 100.", Type = "info" })
        end
    end
})

PlayerTab:CreateSection("Visuals")

PlayerTab:CreateToggle({
    Name     = "ESP",
    Desc     = "Red outline on all players",
    Default  = false,
    Callback = function(Value)
        -- add your ESP logic here
    end
})

PlayerTab:CreateColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(Color)
        -- apply Color to your ESP highlights
        print("ESP Color:", Color)
    end
})

PlayerTab:CreateSection("Character Size")

PlayerTab:CreateSlider({
    Name     = "Head Size",
    Min      = 0.5,
    Max      = 4,
    Default  = 1,
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Head") then
            char.Head.Size = Vector3.new(Value, Value, Value)
        end
    end
})

PlayerTab:CreateSection("Info")

local posLabel = PlayerTab:CreateLabel("Position: unknown")

PlayerTab:CreateButton({
    Name     = "Refresh Position",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            local p = hrp.Position
            posLabel:Set(string.format(
                "X: %.1f  Y: %.1f  Z: %.1f",
                p.X, p.Y, p.Z
            ))
        end
    end
})

-- ── WORLD TAB ─────────────────────────────────────────────────
local WorldTab = Window:CreateTab("World", "🌍")

WorldTab:CreateSection("Lighting")

WorldTab:CreateSlider({
    Name     = "Time of Day",
    Min      = 0,
    Max      = 24,
    Default  = 14,
    Suffix   = "h",
    Callback = function(Value)
        Lighting.ClockTime = Value
    end
})

WorldTab:CreateSlider({
    Name     = "Brightness",
    Min      = 0,
    Max      = 5,
    Default  = 1,
    Callback = function(Value)
        Lighting.Brightness = Value
    end
})

WorldTab:CreateSlider({
    Name     = "Fog End",
    Min      = 100,
    Max      = 10000,
    Default  = 10000,
    Callback = function(Value)
        Lighting.FogEnd = Value
    end
})

WorldTab:CreateColorPicker({
    Name     = "Fog Color",
    Default  = Color3.fromRGB(190, 190, 190),
    Callback = function(Color)
        Lighting.FogColor = Color
    end
})

WorldTab:CreateSection("Physics")

WorldTab:CreateSlider({
    Name     = "Gravity",
    Min      = 5,
    Max      = 200,
    Default  = 196,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

WorldTab:CreateSection("Presets")

WorldTab:CreateDropdown({
    Name     = "Weather Preset",
    Options  = {"Clear Day", "Foggy", "Dark Night", "Golden Hour", "Stormy"},
    Default  = "Clear Day",
    Callback = function(Value)
        if Value == "Clear Day" then
            Lighting.ClockTime = 14
            Lighting.FogEnd    = 100000
            Lighting.Brightness = 2
        elseif Value == "Foggy" then
            Lighting.FogEnd = 200
        elseif Value == "Dark Night" then
            Lighting.ClockTime = 2
            Lighting.Brightness = 0.5
        elseif Value == "Golden Hour" then
            Lighting.ClockTime = 18
            Lighting.Brightness = 1.5
        elseif Value == "Stormy" then
            Lighting.ClockTime = 10
            Lighting.Brightness = 0.3
            Lighting.FogEnd    = 500
        end
        Window:Notify({
            Title   = "Weather Changed",
            Message = Value .. " preset applied!",
            Type    = "success",
        })
    end
})

-- ── MISC TAB ──────────────────────────────────────────────────
local MiscTab = Window:CreateTab("Misc", "⚙️")

MiscTab:CreateSection("Tools")

MiscTab:CreateTextBox({
    Name         = "Print to Output",
    Default      = "Type something...",
    ClearOnFocus = false,
    Callback     = function(Value)
        print("[KaolinHub]", Value)
        Window:Notify({
            Title   = "Printed",
            Message = Value,
            Type    = "success",
            Duration = 2,
        })
    end
})

MiscTab:CreateTextBox({
    Name     = "Set WalkSpeed (number)",
    Default  = "16",
    Numeric  = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            speedSlider:Set(num)
        end
    end
})

MiscTab:CreateSection("UI")

MiscTab:CreateToggle({
    Name     = "Hide HUD",
    Desc     = "Hides the Roblox UI",
    Default  = false,
    Callback = function(Value)
        pcall(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(
                Enum.CoreGuiType.All, not Value
            )
        end)
    end
})

MiscTab:CreateSection("Keybinds (PC)")

MiscTab:CreateLabel("H  →  Show / Hide hub")
MiscTab:CreateLabel("F  →  Toggle Fly")
MiscTab:CreateLabel("G  →  Toggle God Mode")

MiscTab:CreateSection("About")

MiscTab:CreateLabel("KaolinHub v1.0")
MiscTab:CreateLabel("Built with KaolinLib 🧱")
MiscTab:CreateLabel("Like Bricks, Built Solid.")

-- ── Keybinds ──────────────────────────────────────────────────
KaolinLib:BindToggleKey(Enum.KeyCode.H, Window)

KaolinLib:BindKey(Enum.KeyCode.F, function()
    flyToggle:Set(not flyToggle:Get())
end)

KaolinLib:BindKey(Enum.KeyCode.G, function()
    godToggle:Set(not godToggle:Get())
end)

-- ── Startup Notification ──────────────────────────────────────
Window:Notify({
    Title    = "KaolinHub Loaded! 🧱",
    Message  = "Press H to toggle the hub.",
    Duration = 4,
    Type     = "success",
})

print("🧱 KaolinHub loaded!")
```

---

*KaolinLib v1.0 Documentation | "Like Bricks, Built Solid." 🧱*
