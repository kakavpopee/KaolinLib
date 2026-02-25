# KaolinHub

<a href="https://github.com/kakavpopee/KaolinLib/stargazers"><img src="https://img.shields.io/github/stars/kakavpopee/KaolinLib?style=for-the-badge&color=yellow" alt="Stars"></a>
<a href="https://github.com/kakavpopee/KaolinLib/forks"><img src="https://img.shields.io/github/forks/kakavpopee/KaolinLib?style=for-the-badge&color=teal" alt="Forks"></a>
<a href="https://github.com/kakavpopee/KaolinLib/issues"><img src="https://img.shields.io/github/issues/kakavpopee/KaolinLib?style=for-the-badge&color=red" alt="Issues"></a>
<a href="https://github.com/kakavpopee/KaolinLib/releases"><img src="https://img.shields.io/github/v/release/kakavpopee/KaolinLib?style=for-the-badge&color=brightgreen" alt="Release"></a>

**KaolinHub** is a complete, ready-to-use Roblox script hub built in Luau using KaolinLib. It provides a modern GUI with cheats and utilities like fly, noclip, god mode, ESP, lighting controls, and more. Features a key system for access control, mobile/PC compatibility, keybinds, chat commands, dropdowns for player selection, and extensive theming.

Version 2.0 | "Like Bricks, Built Solid." 🧱

## Features

- **Key System**: Secure access with customizable key entry screen.
- **Movement**: Fly (with mobile D-pad), noclip, infinite jump, sprint, no fall damage, anti-void, anti-gravity, custom speed/jump/fly/sprint sliders, tap/click teleport, save/load/loop position.
- **Player**: God mode, auto-heal (with threshold slider), invisible, ghost mode (invis + noclip), ragdoll, spin (with speed slider), ESP highlights, animation speed slider, head/body scaling, remove accessories.
- **World**: Time of day slider, lock sun, fullbright, remove fog, brightness/fog end sliders, gravity slider, rainbow ambient, lighting presets (golden hour, dark night, foggy storm, clear day).
- **Players**: Dropdown for player selection, teleport to player, spectate, copy player position.
- **Misc**: Anti-AFK, hide HUD, FPS/position HUD, chat commands toggle, command list, mobile/PC tips/keybinds info, about section.
- **UI Components**: Windows with drag/minimize/close/restore, tabs, sections, separators, labels (updatable), toggles, sliders, buttons, dropdowns.
- **Theming**: Customizable gold/dark theme with accents for backgrounds, text, toggles, sliders, etc.
- **Mobile Support**: Touch dragging, larger elements, fly D-pad, ignored keybinds, adjusted sizes/scrollbars.
- **Animations**: Smooth tweens for UI interactions, hub slide-in.
- **Keybinds/Chat**: PC keybinds (H toggle hub, F fly, etc.), chat commands (/fly, /god, etc.).
- **HUD**: Corner overlays for FPS and position.
- **Key System Integration**: Built-in key verification GUI.
- **Dropdowns**: Used for player selection; dynamic refresh.
- **Color Picker**: Not in v2.0 core (was in v1.0); can be added via extension (example below).
- **Everything Else**: Notifications (internal), bindings, state management.

## Installation

Load directly in a LocalScript:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"))()
```

Enable HTTP Requests in Game Settings > Security.

## Quick Start

The script auto-loads the key screen. After verification, the hub appears.

Customize config:

```lua
local CFG = {
    Key      = "KAOLIN2024",       -- Key for access
    KeyHint  = "Enter your access key",
    Title    = "KaolinHub",
    Version  = "v2.0",
    Creator  = "kakavpopee",
}
```

## API Reference

KaolinLib (underlying the hub) uses builder functions for UI components. These are internal but can be used to extend the hub. Below are detailed examples for each, based on v2.0 patterns (e.g., NewToggle) and v1.0 methods where applicable. For v2, components are created on pages from NewPage().

### Window / Hub Creation
The hub is auto-created, but to customize:

- Internal: Main frame with title bar, sidebar, content area.
- Dragging, minimize (to title bar), close (hides, shows restore button).

Example (extending):
```lua
-- Access internal Main or recreate similar
local ScreenGui = -- ... (see script for full setup)
```

### Tab / Page Creation
```lua
local page = NewPage()  -- Creates scrolling frame for content
local btn = NewTabBtn(icon, label, page, order)  -- Icon (emoji), label, linked page, layout order
```
Example:
```lua
local CustomPage = NewPage()
NewTabBtn("🆕", "Custom", CustomPage, 6)  -- Adds tab after Misc
-- Now add components to CustomPage
```

### Section Creation
```lua
NewSection(page, text)  -- Gold header label
```
Example:
```lua
NewSection(MovPage, "Advanced Movement")
-- Groups following components
```

### Separator Creation
```lua
NewSep(page)  -- Thin horizontal line
```
Example:
```lua
NewToggle(...)  -- Some toggle
NewSep(MovPage)
NewSlider(...)  -- Separated slider
```

### Label Creation
```lua
local label = NewLabel(page, text)  -- Returns {Set(text)}
```
Example:
```lua
local posLabel = NewLabel(MovPage, "Position: 0,0,0")
-- Update dynamically
RunService.Heartbeat:Connect(function()
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    if hrp then posLabel.Set(string.format("Position: %.0f,%.0f,%.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)) end
end)
```

### Toggle Creation
```lua
local toggle = NewToggle(page, label, desc, callback)  -- Returns {Set(bool), Get()}
```
Parameters: label (string), desc (string, optional), callback(function(value))
Example:
```lua
local espToggle = NewToggle(PlrPage, "ESP", "Highlights players", function(on)
    if on then
        -- Enable ESP logic
    else
        -- Disable
    end
end)
-- Set from elsewhere
espToggle.Set(true)
print(espToggle.Get())  -- true
```

### Slider Creation
```lua
local slider = NewSlider(page, label, min, max, default, suffix, callback)  -- Returns {Set(num), Get()}
```
Parameters: label (string), min/max/default (number), suffix (string, optional), callback(function(value))
Example:
```lua
local speedSlider = NewSlider(MovPage, "Walk Speed", 16, 200, 50, " sp", function(value)
    local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)
-- Set value
speedSlider.Set(100)
print(speedSlider.Get())  -- 100
```

### Button Creation
```lua
NewButton(page, label, desc, callback)  -- No return; fire-and-forget
```
Parameters: label (string), desc (string, optional), callback(function())
Example:
```lua
NewButton(MovPage, "Reset Speed", "Back to default", function()
    speedSlider.Set(16)  -- Ties to slider
end)
```

### Dropdown Creation
```lua
local dropdown = NewDropdown(page, label, getOptionsFunc, callback)  -- Returns {GetSelected(), Refresh(), Set(value)}
```
Parameters: label (string), getOptions (function returning table of strings), callback(function(selected))
Example:
```lua
local playerDD = NewDropdown(PlsPage, "Select Player", function()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end, function(selected)
    print("Selected:", selected)
end)
-- Refresh after players join
playerDD.Refresh()
-- Set selection
playerDD.Set("SomePlayer")
print(playerDD.GetSelected())  -- "SomePlayer"
```

### Color Picker (Extension Example)
v2.0 doesn't have built-in, but add like v1.0:
```lua
-- Custom NewColorPicker (adapt from v1.0)
local function NewColorPicker(page, label, default, callback)
    -- Implement HSV sliders, swatch, etc. (full code similar to v1.0 CreateColorPicker)
    -- Returns {Set(Color3), Get()}
end
```
Example:
```lua
local espColor = NewColorPicker(PlrPage, "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    -- Apply to ESP highlights
end)
espColor.Set(Color3.fromRGB(0, 255, 0))
```

### Notifications (Internal)
Internal use; extend via Window:Notify (from v1.0 style).
Example:
```lua
-- Assuming access to internal Notify
Notify({Title = "Success", Message = "Action done!", Type = "success", Duration = 3})
```

### Keybinds
Internal BindKey, BindToggleKey.
Example:
```lua
KaolinLib:BindKey(Enum.KeyCode.F, function() flyToggle.Set(not flyToggle.Get()) end)
KaolinLib:BindToggleKey(Enum.KeyCode.H, Main)  -- Toggle hub
```

### Key System
Integrated GUI; customize via CFG.Key.
To use in custom lib:
```lua
-- Setup KeyGui as in script, with VerifyKey function.
keyInput.FocusLost:Connect(VerifyKey)
```

### Theming
Modify T table:
```lua
T.Accent = Color3.fromRGB(80, 180, 255)  -- Blue theme
```

## Full Example

See the provided script for a complete hub using all components.

## Customization

- Add Color Picker: Implement NewColorPicker with HSV sliders.
- Extend: Add tabs/pages with new components.

## Contributing

PRs for color picker, more examples.

## License

MIT License

Made with ❤️ by kakavpopee
