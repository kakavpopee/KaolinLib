# KaolinHub v2.0 — Complete Documentation
**"Like Bricks, Built Solid."**
**GitHub:** https://github.com/kakavpopee/KaolinLib

---

## Table of Contents

1. [Quick Start](#1-quick-start)
2. [CFG Table — Hub Configuration](#2-cfg-table--hub-configuration)
3. [Key System — Full Guide](#3-key-system--full-guide)
4. [Premade Key System Scripts](#4-premade-key-system-scripts)
5. [Theme System — Full Guide](#5-theme-system--full-guide)
6. [Theme Presets](#6-theme-presets)
7. [Emoji System](#7-emoji-system)
8. [Movement Features](#8-movement-features)
9. [Player Features](#9-player-features)
10. [World Features](#10-world-features)
11. [Players Tab](#11-players-tab)
12. [Misc Features](#12-misc-features)
13. [Chat Commands](#13-chat-commands)
14. [HUD — FPS & Position Display](#14-hud--fps--position-display)
15. [PC Keybinds](#15-pc-keybinds)
16. [Mobile D-Pad](#16-mobile-d-pad)
17. [State Table — Reading Feature Status](#17-state-table--reading-feature-status)
18. [Feature Functions — API Reference](#18-feature-functions--api-reference)
19. [Component Builders — API Reference](#19-component-builders--api-reference)
20. [Window Controls](#20-window-controls)
21. [Common Errors & Fixes](#21-common-errors--fixes)
22. [Full Customised Example](#22-full-customised-example)

---

## 1. Quick Start

### Load from GitHub

Paste this at the very top of a **LocalScript** inside `StarterPlayerScripts`:

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"
))()
```

> **HTTP Requests must be enabled.**
> Studio → Home → Game Settings → Security → Allow HTTP Requests → ON

That's it. The hub loads, the Key System screen appears, and players must type the correct key to open the hub.

---

## 2. CFG Table — Hub Configuration

The `CFG` table is at the very top of the script. It controls the key, title, version, and creator name. Change these before uploading to GitHub.

```lua
local CFG = {
    Key      = "KAOLIN2024",         -- The key players must type
    KeyHint  = "Enter your access key",  -- Hint shown below the title on the key screen
    Title    = "KaolinHub",          -- Title shown in the title bar and key screen
    Version  = "v2.0",               -- Version shown in the title bar subtitle
    Creator  = "kakavpopee",         -- Creator name shown in title bar subtitle
}
```

### Changing the key

Find `CFG.Key` and replace the value:

```lua
local CFG = {
    Key     = "MySecretKey123",   -- players must type exactly this
    KeyHint = "DM me for the key",
    Title   = "MyHub",
    Version = "v1.0",
    Creator = "YourName",
}
```

The key is **case-sensitive**. `"KAOLIN2024"` and `"kaolin2024"` are different keys.

---

## 3. Key System — Full Guide

### What it does

When the script loads, a **full-screen lock screen** appears before the hub. The player must type the correct key and press Enter or click Verify. If the key is wrong, the card shakes and an error message appears. If the key is correct, the screen fades out and the hub slides in.

### How it works step by step

```
Script loads
    └── Key GUI appears (full-screen overlay)
            └── Player types key + presses Enter or clicks Verify
                    ├── CORRECT → green flash → screen fades → hub slides in
                    └── WRONG   → card shakes → red error → input clears → try again
```

### Key verification logic

The verification function inside the script:

```lua
local function VerifyKey()
    local input = keyInput.Text
    if input == CFG.Key then
        -- SUCCESS path
        keyMsg.TextColor3 = T.Green
        keyMsg.Text       = E.CHECK .. "  Access Granted!"
        -- ... fades key screen, enables hub GUI
    else
        -- FAIL path
        keyMsg.Text = E.CROSS .. "  Invalid key. Try again."
        task.spawn(ShakeCard)   -- shake animation
        keyInput.Text = ""      -- clear input
    end
end
```

### Changing what happens on wrong key

You can edit the fail path to add a kick, a warning, or extra logging. Find `-- FAIL` inside `VerifyKey()`:

```lua
-- FAIL path - add your own logic here
keyMsg.TextColor3 = T.Red
keyMsg.Text       = E.CROSS .. "  Invalid key. Try again."
task.spawn(ShakeCard)
keyInput.Text = ""

-- Example: add a wait penalty after 3 wrong attempts
wrongAttempts = (wrongAttempts or 0) + 1
if wrongAttempts >= 3 then
    keyMsg.Text = "Too many attempts. Wait 10s."
    verifyBtn.Active = false
    task.delay(10, function()
        verifyBtn.Active = true
        wrongAttempts = 0
        keyMsg.Text = ""
    end)
end
```

### Bypassing the key system (testing only)

If you want to skip the key screen during testing, change:

```lua
ScreenGui.Enabled = false  -- hidden until key passes
```

to:

```lua
ScreenGui.Enabled = true   -- skip key screen
```

And add at the bottom of the script, right before the `print` line:

```lua
if LocalPlayer.PlayerGui:FindFirstChild("KaolinKeyGui") then
    LocalPlayer.PlayerGui.KaolinKeyGui:Destroy()
end
```

---

## 4. Premade Key System Scripts

These are complete ready-to-use variations of the `CFG` block. Copy and paste any of these over the existing CFG at the top of KaolinHub.

---

### Script A — Single Static Key (default)

Simple. One key. Everyone who knows it can open the hub.

```lua
local CFG = {
    Key      = "KAOLIN2024",
    KeyHint  = "Enter your access key",
    Title    = "KaolinHub",
    Version  = "v2.0",
    Creator  = "kakavpopee",
}
```

---

### Script B — Whitelist System (multiple allowed keys)

Allows several different keys. Useful for giving different players unique keys.

```lua
local CFG = {
    Key      = "",   -- leave blank, not used in whitelist mode
    KeyHint  = "Enter your personal key",
    Title    = "KaolinHub",
    Version  = "v2.0",
    Creator  = "kakavpopee",
}

-- Whitelist: add as many keys as you want
local VALID_KEYS = {
    "KAOLIN-ALPHA-001",
    "KAOLIN-BETA-002",
    "KAOLIN-VIP-999",
    "YourFriendKey",
    "AnotherKey123",
}

-- Replace VerifyKey() body with this:
-- Find the function `local function VerifyKey()` and replace the
-- `if input == CFG.Key then` line with:
--
--   local valid = false
--   for _, k in ipairs(VALID_KEYS) do
--       if input == k then valid = true break end
--   end
--   if valid then
--       ... (success code)
--   else
--       ... (fail code)
```

Full drop-in replacement for the `VerifyKey` function:

```lua
local VALID_KEYS = {
    "KAOLIN-ALPHA-001",
    "KAOLIN-BETA-002",
    "KAOLIN-VIP-999",
}

local function VerifyKey()
    local input = keyInput.Text
    local valid = false
    for _, k in ipairs(VALID_KEYS) do
        if input == k then valid = true break end
    end

    if valid then
        keyMsg.TextColor3 = T.Green
        keyMsg.Text       = E.CHECK .. "  Access Granted!"
        Tw(verifyBtn, {BackgroundColor3 = T.Green}, TW_FAST)
        Tw(cardStroke, {Color = T.Green}, TW_FAST)
        task.wait(0.8)
        Tw(KeyOverlay, {BackgroundTransparency = 1}, TweenInfo.new(0.5, Enum.EasingStyle.Quad))
        task.wait(0.5)
        KeyGui:Destroy()
        ScreenGui.Enabled = true
        Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
        Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_BACK)
    else
        keyMsg.TextColor3 = T.Red
        keyMsg.Text       = E.CROSS .. "  Invalid key. Try again."
        Tw(inputStroke, {Color = T.Red}, TW_FAST)
        task.spawn(ShakeCard)
        task.delay(1.5, function()
            keyMsg.Text = ""
            Tw(inputStroke, {Color = T.TextDim}, TW_FAST)
        end)
        keyInput.Text = ""
    end
end
```

---

### Script C — Username Whitelist (no key needed, just username)

Players with matching Roblox usernames automatically pass. No typing required.

Replace the full `VerifyKey()` function AND the key screen setup with this:

```lua
-- Put this block BEFORE the Key GUI section (before "local KeyGui = ...")
local ALLOWED_USERS = {
    "kakavpopee",
    "YourFriendUsername",
    "AnotherTrustedUser",
}

local isAllowed = false
for _, name in ipairs(ALLOWED_USERS) do
    if LocalPlayer.Name == name then isAllowed = true break end
end

if isAllowed then
    -- Skip key screen entirely
    ScreenGui.Enabled = true
    Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
    Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_BACK)
else
    -- Show key screen as normal for non-whitelisted players
    -- (keep the rest of the Key GUI code)
end
```

---

### Script D — Attempt Limiter (lockout after X wrong tries)

Locks the input after 3 wrong attempts for 30 seconds.

Paste this right after `local wrongAttempts = 0` at the top of the script, then use this `VerifyKey`:

```lua
local wrongAttempts = 0
local lockedOut     = false

local function VerifyKey()
    if lockedOut then
        keyMsg.TextColor3 = T.Red
        keyMsg.Text = E.WARN .. "  Locked. Wait for cooldown."
        return
    end

    local input = keyInput.Text
    if input == CFG.Key then
        wrongAttempts = 0
        keyMsg.TextColor3 = T.Green
        keyMsg.Text = E.CHECK .. "  Access Granted!"
        Tw(verifyBtn, {BackgroundColor3 = T.Green}, TW_FAST)
        Tw(cardStroke, {Color = T.Green}, TW_FAST)
        task.wait(0.8)
        Tw(KeyOverlay, {BackgroundTransparency = 1}, TweenInfo.new(0.5, Enum.EasingStyle.Quad))
        task.wait(0.5)
        KeyGui:Destroy()
        ScreenGui.Enabled = true
        Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
        Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_BACK)
    else
        wrongAttempts = wrongAttempts + 1
        keyInput.Text  = ""
        task.spawn(ShakeCard)
        Tw(inputStroke, {Color = T.Red}, TW_FAST)

        if wrongAttempts >= 3 then
            lockedOut = true
            keyMsg.TextColor3 = T.Red
            keyMsg.Text = E.WARN .. "  3 wrong attempts. Locked 30s."
            verifyBtn.Active = false
            task.delay(30, function()
                lockedOut     = false
                wrongAttempts = 0
                verifyBtn.Active = true
                keyMsg.Text = ""
                Tw(inputStroke, {Color = T.TextDim}, TW_FAST)
            end)
        else
            keyMsg.TextColor3 = T.Red
            keyMsg.Text = E.CROSS .. "  Wrong key. " .. (3 - wrongAttempts) .. " attempts left."
            task.delay(1.5, function()
                keyMsg.Text = ""
                Tw(inputStroke, {Color = T.TextDim}, TW_FAST)
            end)
        end
    end
end
```

---

## 5. Theme System — Full Guide

The theme is controlled by the `T` table near the top of the script (after the HUD section). Every color used in the entire GUI comes from this one table. Change any value here and the whole hub updates automatically.

```lua
local T = {
    Accent    = Color3.fromRGB(200, 160, 80),   -- Gold: title bar, toggles, sliders, accents
    AccentDk  = Color3.fromRGB(160, 120, 50),   -- Darker gold: button hover state
    BgRoot    = Color3.fromRGB(15,  15,  20),   -- Darkest bg: main window background
    BgDark    = Color3.fromRGB(10,  10,  14),   -- Tab sidebar background
    BgCard    = Color3.fromRGB(24,  24,  32),   -- Toggle/slider/label card background
    BgContent = Color3.fromRGB(19,  19,  26),   -- Content area background (right panel)
    TextMain  = Color3.fromRGB(225, 225, 230),  -- Primary text on components
    TextDim   = Color3.fromRGB(95,  95,  112),  -- Secondary/description text
    TextOn    = Color3.fromRGB(15,  15,  20),   -- Text drawn on top of Accent color
    TogOff    = Color3.fromRGB(50,  50,  62),   -- Toggle pill when OFF
    SlTrack   = Color3.fromRGB(40,  40,  52),   -- Slider unfilled track
    Red       = Color3.fromRGB(220, 70,  70),   -- Error messages, wrong key
    Green     = Color3.fromRGB(70,  200, 110),  -- Success messages, correct key
}
```

### Color Reference Table

| Key | Where it appears | Default |
|-----|-----------------|---------|
| `Accent` | Title bar, toggle ON, slider fill, section headers, button borders, scrollbar | Gold `(200,160,80)` |
| `AccentDk` | Button hover background, darker highlights | Dark gold `(160,120,50)` |
| `BgRoot` | Main window background | Near-black `(15,15,20)` |
| `BgDark` | Left sidebar background | Darkest `(10,10,14)` |
| `BgCard` | Every toggle, slider, label card | Dark card `(24,24,32)` |
| `BgContent` | Right content panel | Slightly lighter dark `(19,19,26)` |
| `TextMain` | All main labels on components | Near-white `(225,225,230)` |
| `TextDim` | Description text, dim labels | Grey `(95,95,112)` |
| `TextOn` | Text that sits on top of the Accent color (title bar text, tab active text) | Dark `(15,15,20)` |
| `TogOff` | Toggle switch background when OFF | Dark grey `(50,50,62)` |
| `SlTrack` | Slider unfilled background track | Dark grey `(40,40,52)` |
| `Red` | Error messages, wrong key highlight | Red `(220,70,70)` |
| `Green` | Success messages, correct key highlight | Green `(70,200,110)` |

### How to change a theme

Find the `T` table in the script (search for `local T = {`) and change any values:

```lua
local T = {
    Accent    = Color3.fromRGB(80, 160, 255),  -- change gold to blue
    AccentDk  = Color3.fromRGB(50, 120, 200),
    BgRoot    = Color3.fromRGB(10, 10, 18),
    -- leave the rest as defaults
    ...
}
```

---

## 6. Theme Presets

Copy and paste any of these over the entire `T = { ... }` block in the script.

---

### Default Gold (built-in)
```lua
local T = {
    Accent    = Color3.fromRGB(200, 160, 80),
    AccentDk  = Color3.fromRGB(160, 120, 50),
    BgRoot    = Color3.fromRGB(15,  15,  20),
    BgDark    = Color3.fromRGB(10,  10,  14),
    BgCard    = Color3.fromRGB(24,  24,  32),
    BgContent = Color3.fromRGB(19,  19,  26),
    TextMain  = Color3.fromRGB(225, 225, 230),
    TextDim   = Color3.fromRGB(95,  95,  112),
    TextOn    = Color3.fromRGB(15,  15,  20),
    TogOff    = Color3.fromRGB(50,  50,  62),
    SlTrack   = Color3.fromRGB(40,  40,  52),
    Red       = Color3.fromRGB(220, 70,  70),
    Green     = Color3.fromRGB(70,  200, 110),
}
```

---

### Ice Blue
```lua
local T = {
    Accent    = Color3.fromRGB(80,  170, 255),
    AccentDk  = Color3.fromRGB(50,  130, 210),
    BgRoot    = Color3.fromRGB(10,  12,  20),
    BgDark    = Color3.fromRGB(6,   8,   16),
    BgCard    = Color3.fromRGB(18,  22,  36),
    BgContent = Color3.fromRGB(14,  18,  28),
    TextMain  = Color3.fromRGB(220, 230, 245),
    TextDim   = Color3.fromRGB(80,  100, 140),
    TextOn    = Color3.fromRGB(6,   10,  20),
    TogOff    = Color3.fromRGB(40,  50,  72),
    SlTrack   = Color3.fromRGB(30,  40,  60),
    Red       = Color3.fromRGB(220, 70,  70),
    Green     = Color3.fromRGB(70,  200, 110),
}
```

---

### Blood Red
```lua
local T = {
    Accent    = Color3.fromRGB(210, 50,  50),
    AccentDk  = Color3.fromRGB(165, 30,  30),
    BgRoot    = Color3.fromRGB(14,  10,  10),
    BgDark    = Color3.fromRGB(9,   6,   6),
    BgCard    = Color3.fromRGB(28,  18,  18),
    BgContent = Color3.fromRGB(22,  14,  14),
    TextMain  = Color3.fromRGB(235, 220, 220),
    TextDim   = Color3.fromRGB(120, 80,  80),
    TextOn    = Color3.fromRGB(14,  8,   8),
    TogOff    = Color3.fromRGB(60,  35,  35),
    SlTrack   = Color3.fromRGB(48,  28,  28),
    Red       = Color3.fromRGB(220, 70,  70),
    Green     = Color3.fromRGB(70,  200, 110),
}
```

---

### Toxic Green
```lua
local T = {
    Accent    = Color3.fromRGB(80,  220, 100),
    AccentDk  = Color3.fromRGB(55,  170, 75),
    BgRoot    = Color3.fromRGB(10,  14,  10),
    BgDark    = Color3.fromRGB(6,   10,  6),
    BgCard    = Color3.fromRGB(18,  26,  18),
    BgContent = Color3.fromRGB(14,  20,  14),
    TextMain  = Color3.fromRGB(210, 240, 210),
    TextDim   = Color3.fromRGB(80,  120, 80),
    TextOn    = Color3.fromRGB(8,   14,  8),
    TogOff    = Color3.fromRGB(35,  55,  35),
    SlTrack   = Color3.fromRGB(28,  44,  28),
    Red       = Color3.fromRGB(220, 70,  70),
    Green     = Color3.fromRGB(70,  200, 110),
}
```

---

### Purple / Violet
```lua
local T = {
    Accent    = Color3.fromRGB(165, 90,  255),
    AccentDk  = Color3.fromRGB(120, 55,  200),
    BgRoot    = Color3.fromRGB(12,  10,  20),
    BgDark    = Color3.fromRGB(8,   6,   16),
    BgCard    = Color3.fromRGB(24,  18,  38),
    BgContent = Color3.fromRGB(18,  14,  30),
    TextMain  = Color3.fromRGB(230, 220, 245),
    TextDim   = Color3.fromRGB(100, 80,  140),
    TextOn    = Color3.fromRGB(8,   6,   18),
    TogOff    = Color3.fromRGB(50,  35,  72),
    SlTrack   = Color3.fromRGB(40,  28,  58),
    Red       = Color3.fromRGB(220, 70,  70),
    Green     = Color3.fromRGB(70,  200, 110),
}
```

---

### White / Minimal Light Mode
```lua
local T = {
    Accent    = Color3.fromRGB(50,  50,  50),
    AccentDk  = Color3.fromRGB(30,  30,  30),
    BgRoot    = Color3.fromRGB(245, 245, 248),
    BgDark    = Color3.fromRGB(225, 225, 230),
    BgCard    = Color3.fromRGB(255, 255, 255),
    BgContent = Color3.fromRGB(240, 240, 244),
    TextMain  = Color3.fromRGB(30,  30,  40),
    TextDim   = Color3.fromRGB(140, 140, 160),
    TextOn    = Color3.fromRGB(245, 245, 248),
    TogOff    = Color3.fromRGB(190, 190, 200),
    SlTrack   = Color3.fromRGB(210, 210, 220),
    Red       = Color3.fromRGB(200, 50,  50),
    Green     = Color3.fromRGB(50,  170, 80),
}
```

---

## 7. Emoji System

KaolinHub stores every emoji as **UTF-8 byte escape sequences** in the `E` table. This is the only reliable way to use emojis in Roblox on mobile — raw emoji characters in source code break depending on how the file is saved or transferred.

```lua
local E = {
    BRICK  = "\240\159\167\177",   -- Used in title bar, about section
    RUN    = "\240\159\143\131",   -- Movement tab icon
    PERSON = "\240\159\145\164",   -- Player tab icon
    PEOPLE = "\240\159\145\165",   -- Players tab icon
    EARTH  = "\240\159\140\141",   -- World tab icon
    GEAR   = "\226\154\153",       -- Misc tab icon
    CROSS  = "\226\156\149",       -- Close button, error messages
    DASH   = "\226\136\146",       -- Minimise button
    UP     = "\226\172\134",       -- D-pad forward
    DOWN   = "\226\172\135",       -- D-pad backward
    LEFT   = "\226\172\133",       -- D-pad left
    RIGHT  = "\226\158\161",       -- D-pad right, buttons arrow
    RISE   = "\240\159\148\188",   -- D-pad up, dropdown open
    FALL   = "\240\159\148\189",   -- D-pad down, dropdown closed
    STAR   = "\226\152\133",       -- Minimised icon, Lock Sun, presets
    CHECK  = "\226\156\147",       -- Key success message
    LOCK   = "\240\159\148\146",   -- Unused (available for your use)
    KEY    = "\240\159\148\145",   -- Key screen icon, verify button
    FLASH  = "\226\154\161",       -- Fullbright toggle
    EYE    = "\240\159\145\129",   -- ESP, Invisible, Spectate
    SHIELD = "\240\159\155\161",   -- God Mode
    CHAT   = "\240\159\146\172",   -- Chat Commands section
    HOSP   = "\240\159\143\165",   -- God Mode, Auto Heal, heal button
    SPIN   = "\240\159\140\128",   -- Spin toggle
    MAP    = "\240\159\151\186",   -- Teleport buttons
    SAVE   = "\240\159\146\190",   -- Save Position button
    WARN   = "\226\154\160",       -- Warning messages
    SKULL  = "\240\159\146\128",   -- Ghost Mode
}
```

### Adding a new emoji

1. Find the emoji you want on [emojipedia.org](https://emojipedia.org)
2. Get its Unicode code point (e.g. `U+1F525` for fire)
3. Run this Python snippet to get the Lua escape string:

```python
cp = 0x1F525  # replace with your emoji's code point
b  = chr(cp).encode("utf-8")
print("".join(f"\\{x}" for x in b))
# output: \240\159\148\165
```

4. Add it to the `E` table:

```lua
FIRE = "\240\159\148\165",  -- fire emoji
```

5. Use it anywhere in the script:

```lua
NewToggle(MovPage, E.FIRE .. " Rocket Boost", "Go very fast", function(v) end)
```

---

## 8. Movement Features

All movement features are in the **Move** tab (first tab, running emoji icon).

---

### Fly

Lets your character fly freely using WASD + Space/Shift on PC, or the on-screen D-pad on mobile.

**Toggle object:**
```lua
local flyTgl = NewToggle(MovPage, "Fly", "desc", function(v) SetFly(v) end)
```

**Turn on from code:**
```lua
flyTgl.Set(true)   -- turns fly on
flyTgl.Set(false)  -- turns fly off
```

**Check current state:**
```lua
if flyTgl.Get() then
    print("Fly is ON")
end
```

**Fly speed** is controlled by the `FlySpeed` slider (10–300). Change the default:
```lua
-- In State table at the top:
FlySpeed = 100,  -- default fly speed
```

**PC controls while flying:**
- `W` / `S` — forward / backward
- `A` / `D` — strafe left / right
- `Space` — fly up
- `LeftShift` — fly down

---

### Noclip

Disables collision so you walk through walls and floors.

```lua
noclipTgl.Set(true)   -- enable
noclipTgl.Set(false)  -- disable
```

When disabled, all `CanCollide` properties are restored to `true`.

---

### Infinite Jump

Lets you jump as many times as you want mid-air by intercepting `JumpRequest`.

```lua
infJmpTgl.Set(true)
```

---

### Sprint

On PC: hold `LeftShift` while the Sprint toggle is ON to sprint at the Sprint Speed.
On mobile: turning on Sprint just applies the Sprint Speed slider value directly.

```lua
sprintTgl.Set(true)
-- change sprint speed:
State.SprintSpeed = 80  -- or use the slider
```

---

### Anti-Gravity

Sets `workspace.Gravity` to `10`. Restores original gravity when turned off.

```lua
antigravTgl.Set(true)
```

---

### No Fall Damage

Automatically heals to full HP whenever you land. Uses `Humanoid.StateChanged`.

```lua
noFallTgl.Set(true)
```

---

### Anti-Void

Saves your last known safe position (Y > -100) every frame and teleports you back if you fall below Y = -100.

```lua
antiVoidTgl.Set(true)
```

---

### Click / Tap Teleport

**PC:** Click on any surface with your mouse and your character teleports there.
**Mobile:** Tap any surface and you teleport there.

```lua
tpTgl.Set(true)
```

---

### Save Position & Go To Saved

Saves your current `CFrame` and lets you teleport back to it.

```lua
-- These are buttons in the UI, but you can also set from code:
State.SavedCFrame = GetHRP().CFrame  -- save
GetHRP().CFrame   = State.SavedCFrame  -- restore
```

---

### Loop TP

When enabled, teleports you to your Saved Position every frame, effectively **freezing you in place** at that position. Useful for staying in one spot while other things happen.

```lua
-- First save a position, then:
loopTpTgl.Set(true)
```

---

### Walk Speed / Jump Power / Fly Speed / Sprint Speed sliders

All sliders return an object with `Set()` and `Get()`:

```lua
speedSld.Set(100)      -- set walk speed to 100
jumpSld.Set(300)       -- set jump power to 300
flySpSld.Set(150)      -- set fly speed to 150
sprintSld.Set(80)      -- set sprint speed to 80

print(speedSld.Get())  -- read current walk speed value
```

---

## 9. Player Features

All in the **Player** tab (person emoji icon).

---

### God Mode

Sets `MaxHealth` and `Health` to `math.huge` every frame via Heartbeat.

```lua
godTgl.Set(true)    -- enable
godTgl.Set(false)   -- disable (resets max health to 100)
```

---

### Auto Heal

Monitors HP every frame. When `Health / MaxHealth * 100` drops below the **Heal Threshold** slider value, it heals to full.

```lua
autoHealTgl.Set(true)

-- Change heal threshold from code:
State.AutoHealPct = 50  -- heal when below 50%
-- or use the slider:
healSld.Set(50)
```

---

### ESP Highlights

Adds a red `Highlight` instance above every other player's character that shows through walls.

```lua
espTgl.Set(true)
```

---

### Invisible

Sets `Transparency = 1` on all `BasePart`s in your character. Restores original values when turned off.

```lua
invisTgl.Set(true)   -- go invisible
invisTgl.Set(false)  -- become visible again
```

---

### Ghost Mode

Enables both **Invisible** and **Noclip** at the same time.

```lua
ghostTgl.Set(true)
```

---

### Ragdoll

Changes your Humanoid state to `Physics`, causing a ragdoll effect.

```lua
ragdollTgl.Set(true)   -- ragdoll
ragdollTgl.Set(false)  -- get back up
```

---

### Spin

Rotates your `HumanoidRootPart` around the Y axis every Heartbeat at the speed set by the Spin Speed slider.

```lua
spinTgl.Set(true)

-- Change spin speed from code:
State.SpinSpeed = 10  -- fast
-- or use the slider:
spinSld.Set(10)
```

---

### Animation Speed

Adjusts the speed of all currently playing animation tracks via `AdjustSpeed()`.

```lua
animSld.Set(2)   -- 2x speed
animSld.Set(0.5) -- half speed
animSld.Set(0)   -- freeze all animations
animSld.Set(1)   -- back to normal
```

---

### Head Size / Body Scale

```lua
-- These are sliders, no toggle object returned.
-- Control them via State or just use the slider UI.
-- Head Size: 0.5x to 5x
-- Body Scale: 0.5x to 3x (affects all NumberValue Scale children of Humanoid)
```

---

## 10. World Features

All in the **World** tab (earth emoji icon).

---

### Time of Day

Sets `Lighting.ClockTime`. Range 0–24 hours.

```lua
timeSld.Set(18)  -- golden hour
timeSld.Set(2)   -- night
timeSld.Set(12)  -- noon
```

---

### Lock Sun

Freezes `Lighting.ClockTime` at its current value every Heartbeat. Turn it on after dragging the time slider to the exact position you want.

```lua
lockSunTgl.Set(true)   -- freeze time at current value
lockSunTgl.Set(false)  -- unfreeze
```

---

### Fullbright

Sets `Lighting.Brightness = 10` and `Ambient = white`. Restores saved values when turned off.

```lua
brightTgl.Set(true)
```

---

### Remove Fog

Sets `FogEnd` and `FogStart` to `900,000,000` (effectively no fog).

```lua
removeFogTgl.Set(true)
```

---

### Rainbow Ambient

Cycles `Lighting.Ambient` and `Lighting.OutdoorAmbient` through HSV colors on Heartbeat. To stop it and get normal ambient back, toggle it off.

---

### Gravity Slider

Sets `workspace.Gravity`. Range 5–500. Default is `196` (Roblox default).

---

### Lighting Presets (buttons)

| Button | What it does |
|--------|-------------|
| Golden Hour | ClockTime = 18, Brightness = 1.5 |
| Dark Night | ClockTime = 2, Brightness = 0.4 |
| Foggy Storm | ClockTime = 10, Brightness = 0.3, FogEnd = 400 |
| Clear Day (Reset) | Resets everything back to defaults |

---

## 11. Players Tab

The **Players** tab (two people emoji icon) lets you select another player from a dropdown and perform actions on them.

---

### Selecting a Player

Tap the dropdown header to open it. It shows all players currently in the server except yourself. Pick one name from the list — this becomes the **selected player** for all action buttons.

```lua
-- The dropdown object:
local playerDrop = NewDropdown(PlsPage, "Select Player", GetPlayerNames, function(name) end)

-- Read who is selected from code:
local name = playerDrop.GetSelected()

-- Set selected from code:
playerDrop.Set("PlayerName")
```

---

### Teleport To Player

Teleports your character to stand 3 studs away from the selected player.

---

### Spectate Player

Switches camera to `Scriptable` mode and follows the selected player from behind. Disable the toggle to get your camera control back.

```lua
spectateTgl.Set(true)   -- start spectating selected player
spectateTgl.Set(false)  -- stop spectating
```

> **Important:** Spectate changes your camera type. If the camera feels stuck after disabling, also try clicking anywhere in-game.

---

### Copy Player Position

Copies the selected player's `CFrame` into `State.SavedCFrame`. Then use **Go To Saved** or **Loop TP** to use it.

---

## 12. Misc Features

In the **Misc** tab (gear emoji icon).

---

### Anti-AFK

Fires a jump every 4.5 minutes (270 seconds) to prevent the Roblox AFK kick. Uses `Heartbeat` accumulation.

```lua
-- Toggle is in the UI. No API needed.
-- Internally:
State.AntiAFKOn = true
```

---

### Hide HUD

Calls `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)` to hide the Roblox health bar, backpack, chat, etc.

---

### FPS Counter

Shows `FPS: XX` in the top-right corner of the screen. Updates every 1 second by counting Heartbeat frames.

---

### Position HUD

Shows `X: Y: Z:` coordinates in the top-right corner, updated every frame from `HumanoidRootPart.Position`.

---

## 13. Chat Commands

Chat commands require the **Enable Chat Commands** toggle to be ON (in Misc tab). Type commands in the Roblox chat box while in the game.

| Command | What it does | Example |
|---------|-------------|---------|
| `/speed [n]` | Sets your walk speed | `/speed 100` |
| `/fly` | Toggles fly on/off | `/fly` |
| `/noclip` | Toggles noclip on/off | `/noclip` |
| `/god` | Toggles god mode on/off | `/god` |
| `/heal` | Full heals you instantly | `/heal` |
| `/invis` | Toggles invisible | `/invis` |
| `/ghost` | Toggles ghost mode (invis + noclip) | `/ghost` |
| `/spin` | Toggles spin | `/spin` |
| `/bright` | Toggles fullbright | `/bright` |
| `/fog` | Toggles remove fog | `/fog` |
| `/gravity [n]` | Sets workspace gravity | `/gravity 50` |
| `/time [0-24]` | Sets time of day | `/time 18` |
| `/tp [name]` | Teleports you to a player | `/tp PlayerName` |
| `/reset` | Respawns your character | `/reset` |

### Adding your own chat command

Find `ParseCommands()` in the script and add a new `elseif` block:

```lua
elseif cmd == "/bighead" then
    local char = GetChar()
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(5, 5, 5)
    end

elseif cmd == "/normalhead" then
    local char = GetChar()
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(2, 1, 1)  -- default Roblox head
    end

elseif cmd == "/kill" then
    local hum = GetHum()
    if hum then hum.Health = 0 end

elseif cmd == "/jump" then
    local hum = GetHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
```

---

## 14. HUD — FPS & Position Display

The HUD is a separate `ScreenGui` named `KaolinHud` that is always visible (independent of the main hub window). It shows small labels in the top-right corner.

**FPS Counter** — shows actual frames per second counted over 1-second windows via `RunService.Heartbeat`.

**Position HUD** — shows your character's `HumanoidRootPart.Position` as `X: Y: Z:` rounded to the nearest stud, updated every frame.

Both are **off by default** and toggled from the Misc tab. You can also control them from code:

```lua
FpsLabel.Visible = true   -- show FPS
PosLabel.Visible = true   -- show position
FpsLabel.Visible = false  -- hide FPS
PosLabel.Visible = false  -- hide position
```

### Changing HUD colors

Find `FpsLabel` and `PosLabel` in the script:

```lua
FpsLabel.TextColor3 = Color3.fromRGB(200, 160, 80)   -- FPS label color (default gold)
PosLabel.TextColor3 = Color3.fromRGB(160, 200, 160)  -- Position label color (default green)
```

---

## 15. PC Keybinds

These keybinds work on PC only and are ignored silently on mobile.

| Key | Action |
|-----|--------|
| `H` | Show / Hide the hub window |
| `F` | Toggle Fly |
| `N` | Toggle Noclip |
| `G` | Toggle God Mode |
| `E` | Toggle ESP |
| `V` | Toggle Invisible |

### Adding a custom keybind

Find the `UserInputService.InputBegan` block near the bottom of the script and add a new `if` line:

```lua
-- Existing keybinds:
if inp.KeyCode == Enum.KeyCode.H then ... end
if inp.KeyCode == Enum.KeyCode.F then flyTgl.Set(not flyTgl.Get()) end

-- Add yours:
if inp.KeyCode == Enum.KeyCode.T then
    spinTgl.Set(not spinTgl.Get())   -- T to toggle spin
end
if inp.KeyCode == Enum.KeyCode.R then
    LocalPlayer:LoadCharacter()       -- R to respawn
end
if inp.KeyCode == Enum.KeyCode.X then
    antigravTgl.Set(not antigravTgl.Get())  -- X to toggle anti-gravity
end
```

---

## 16. Mobile D-Pad

When **Fly** is turned on while on mobile, a semi-transparent D-pad appears in the bottom-left corner of the screen.

| Button | Direction |
|--------|-----------|
| UP arrow | Move forward |
| DOWN arrow | Move backward |
| LEFT arrow | Strafe left |
| RIGHT arrow | Strafe right |
| RISE (up triangle) | Fly upward |
| FALL (down triangle) | Fly downward |

The D-pad is automatically shown when fly is enabled and hidden when fly is disabled. You can reposition it by changing:

```lua
FlyPad.Position = UDim2.new(0, 10, 1, -180)
-- UDim2.new(xScale, xOffset, yScale, yOffset)
-- Default: bottom-left, 10px from left, 180px from bottom
```

### Changing D-pad size

```lua
FlyPad.Size = UDim2.new(0, 216, 0, 168)
-- Change 216 (width) and 168 (height) to resize
```

---

## 17. State Table — Reading Feature Status

The `State` table stores the current on/off status and value of every feature. You can read from it anywhere in the script.

```lua
-- Check if a feature is currently on:
if State.FlyEnabled then
    print("Flying right now")
end

if State.GodModeEnabled then
    print("God mode is active")
end

-- Read current values:
print("Walk speed:", State.WalkSpeed)
print("Fly speed:",  State.FlySpeed)
print("Jump power:", State.JumpPower)

-- Check saved position:
if State.SavedCFrame then
    print("Saved position exists:", State.SavedCFrame.Position)
end
```

### Full State table reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `FlyEnabled` | bool | false | Is fly currently on |
| `FlySpeed` | number | 60 | Current fly speed |
| `NoclipEnabled` | bool | false | Is noclip on |
| `InfJumpEnabled` | bool | false | Is infinite jump on |
| `SprintEnabled` | bool | false | Is sprint on |
| `SprintSpeed` | number | 50 | Sprint speed value |
| `NoFallDmg` | bool | false | Is no fall damage on |
| `AntiVoidEnabled` | bool | false | Is anti-void on |
| `AntiGravEnabled` | bool | false | Is anti-gravity on |
| `SpeedEnabled` | bool | false | Is speed boost on |
| `WalkSpeed` | number | 50 | Walk speed slider value |
| `JumpPower` | number | 100 | Jump power slider value |
| `LoopTPEnabled` | bool | false | Is loop teleport on |
| `SavedCFrame` | CFrame/nil | nil | Saved position CFrame |
| `GodModeEnabled` | bool | false | Is god mode on |
| `AutoHealEnabled` | bool | false | Is auto heal on |
| `AutoHealPct` | number | 30 | Auto heal threshold % |
| `InvisEnabled` | bool | false | Is invisible on |
| `GhostEnabled` | bool | false | Is ghost mode on |
| `RagdollEnabled` | bool | false | Is ragdoll on |
| `SpinEnabled` | bool | false | Is spin on |
| `SpinSpeed` | number | 3 | Spin speed multiplier |
| `ESPEnabled` | bool | false | Is ESP on |
| `AnimSpeed` | number | 1 | Animation speed multiplier |
| `FullbrightOn` | bool | false | Is fullbright on |
| `RemoveFogOn` | bool | false | Is remove fog on |
| `LockSunOn` | bool | false | Is lock sun on |
| `LockedTime` | number | 14 | Time locked at |
| `AntiAFKOn` | bool | false | Is anti-AFK on |
| `ChatCmdsOn` | bool | false | Are chat commands on |
| `FpsDisplayOn` | bool | false | Is FPS counter visible |
| `PosDisplayOn` | bool | false | Is position HUD visible |

---

## 18. Feature Functions — API Reference

These are the internal functions that control each feature. You can call them directly from your own code added to the script.

```lua
SetFly(true/false)            -- toggle fly
SetNoclip(true/false)         -- toggle noclip
SetInfJump(true/false)        -- toggle infinite jump
SetSprint(true/false)         -- toggle sprint
SetNoFallDmg(true/false)      -- toggle no fall damage
SetAntiVoid(true/false)       -- toggle anti-void
SetAntiGrav(true/false)       -- toggle anti-gravity
SetGodMode(true/false)        -- toggle god mode
SetAutoHeal(true/false)       -- toggle auto heal
SetInvisible(true/false)      -- toggle invisible
SetGhostMode(true/false)      -- toggle ghost (invis + noclip)
SetRagdoll(true/false)        -- toggle ragdoll
SetSpin(true/false)           -- toggle spin
SetESP(true/false)            -- toggle ESP
SetTeleport(true/false)       -- toggle click/tap teleport
SetLoopTP(true/false)         -- toggle loop teleport
SetFullbright(true/false)     -- toggle fullbright
SetRemoveFog(true/false)      -- toggle remove fog
SetLockSun(true/false)        -- toggle lock sun
SetAntiAFK(true/false)        -- toggle anti-afk
SetSpectate(true/false, player)  -- toggle spectate (pass player object or nil)
ApplyAnimSpeed(number)        -- apply animation speed (0 = freeze, 1 = normal, 2 = double)
```

### Example — turn on several features at once

```lua
-- After the script loads, auto-enable these features:
task.delay(1, function()
    SetGodMode(true)
    SetAntiVoid(true)
    SetAntiAFK(true)
    godTgl.Set(true)       -- also update the toggle UI
    antiVoidTgl.Set(true)
end)
```

> **Note:** Always call both the function AND the toggle's `Set()` so the visual toggle stays in sync. For example, `SetGodMode(true)` turns it on internally but the toggle pill won't move unless you also call `godTgl.Set(true)`.

---

## 19. Component Builders — API Reference

These functions create UI elements. Use them to add your own custom components to any tab page.

---

### NewPage()

Creates a new scrollable content page. Assign it to a variable and pass it to `NewTabBtn`.

```lua
local MyPage = NewPage()
```

---

### NewTabBtn(icon, label, page, order)

Creates a sidebar tab button that switches to the given page.

```lua
local MyBtn = NewTabBtn(E.STAR, "Custom", MyPage, 6)
-- icon   = emoji from E table
-- label  = text shown under the icon
-- page   = the page returned from NewPage()
-- order  = position in the sidebar (1=top, higher=lower)
```

---

### NewSection(page, text)

Adds a gold section header label.

```lua
NewSection(MyPage, "MY SECTION")
```

---

### NewSep(page)

Adds a thin 1px horizontal divider line.

```lua
NewSep(MyPage)
```

---

### NewLabel(page, text) → { Set(text) }

Adds a read-only text label card. Returns an object with `Set()` to update the text.

```lua
local myLbl = NewLabel(MyPage, "Current value: 0")

-- Update from code:
myLbl.Set("Current value: " .. tostring(someNumber))
```

---

### NewToggle(page, label, desc, callback) → { Set(bool), Get() }

Adds an animated toggle switch.

```lua
local myTgl = NewToggle(MyPage, "My Feature", "Short description", function(on)
    if on then
        print("turned ON")
        -- your logic here
    else
        print("turned OFF")
    end
end)

-- Control from code:
myTgl.Set(true)    -- turns on, fires callback
myTgl.Set(false)   -- turns off, fires callback
myTgl.Get()        -- returns true or false
```

---

### NewSlider(page, label, min, max, default, suffix, callback) → { Set(n), Get() }

Adds a draggable slider.

```lua
local mySld = NewSlider(MyPage, "My Value", 0, 100, 50, "%", function(value)
    print("Value is now:", value)
    -- your logic here
end)

-- Control from code:
mySld.Set(75)    -- sets slider to 75, fires callback
mySld.Get()      -- returns current number
```

**Note:** Values with a decimal range (e.g. 0.5 to 5) will show one decimal place automatically.

---

### NewButton(page, label, desc, callback)

Adds a clickable button. `desc` can be `nil` for a compact button.

```lua
NewButton(MyPage, "Do Something", "Short description of what it does", function()
    print("Button clicked!")
    -- your logic here
end)

-- Compact button (no description):
NewButton(MyPage, "Quick Action", nil, function()
    -- your logic here
end)
```

---

### NewDropdown(page, label, getOptionsFunction, callback) → { GetSelected(), Set(text), Refresh() }

Adds an expandable dropdown list.

```lua
local myDrop = NewDropdown(MyPage, "Pick a value",
    function()
        -- This function is called every time the dropdown opens
        -- Return a table of strings
        return {"Option A", "Option B", "Option C"}
    end,
    function(selected)
        print("Player picked:", selected)
    end
)

-- Read selected:
local picked = myDrop.GetSelected()

-- Set selected:
myDrop.Set("Option B")

-- Rebuild list (call after options change):
myDrop.Refresh()
```

---

## 20. Window Controls

### Close button (✕)

Hides the main window. Shows the floating brick restore button.

### Minimise button (−)

Collapses the window to just the title bar. Click again to restore. The icon switches to a star when minimised.

### Restore button (🧱)

Visible only when the window is closed. Click it to bring the hub back.

### Dragging

Grab the gold title bar and drag. Works with mouse on PC and finger touch on mobile.

### PC toggle with H key

Press `H` to show/hide the entire hub window.

---

## 21. Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `HttpService is not enabled` | HTTP is off in Studio | Game Settings → Security → Allow HTTP Requests → ON |
| Hub loads but no key screen appears | `ScreenGui.Enabled` set to `true` early | Make sure `ScreenGui.Enabled = false` is set before the Key GUI section |
| Emojis show as `?` boxes | File encoding issue | Use the byte escape `E` table (already implemented) — do NOT paste raw emoji into the script |
| Key screen won't go away after correct key | `KeyGui:Destroy()` not being reached | Check the `VerifyKey` function for Lua errors in the verify block |
| Toggles don't visually match feature state | Calling `SetXxx()` without calling `toggle.Set()` | Always call both: `SetGodMode(true)` + `godTgl.Set(true)` |
| Fly D-pad not appearing on mobile | `FlyPadFrame` reference issue | Make sure `FlyPadFrame = FlyPad` line exists after the FlyPad is created |
| Spectate camera stuck | Camera type not restored | Toggle Spectate off — it sets `CameraType = Custom` which restores control |
| Sprint not working on mobile | Sprint needs `LeftShift` on PC | On mobile, Sprint just directly applies sprint speed — no key hold needed |
| Chat commands not working | Toggle is off | Go to Misc tab and turn on **Enable Chat Commands** |
| `attempt to index nil with 'Set'` | Using toggle object before it's defined | Make sure you define the toggle before you call `.Set()` on it |

---

## 22. Full Customised Example

A complete example showing how to add a **custom tab with custom features** to KaolinHub. Paste this block just before the `SELECT FIRST TAB` section.

```lua
-- ============================================================
--  CUSTOM TAB EXAMPLE
-- ============================================================
local CustomPage = NewPage()
local CustomBtn  = NewTabBtn(E.STAR, "Custom", CustomPage, 6)

-- Section header
NewSection(CustomPage, "MY CUSTOM FEATURES")

-- A live status label
local statusLbl = NewLabel(CustomPage, "Status: Idle")

-- Custom toggle that updates the label
NewToggle(CustomPage, "Speed Hack x10", "Sets walk speed to 160", function(on)
    local hum = GetHum()
    if hum then
        hum.WalkSpeed = on and 160 or 16
    end
    statusLbl.Set(on and "Status: SPEED HACK ACTIVE" or "Status: Idle")
end)

-- Custom toggle that enables both fly and god mode
NewToggle(CustomPage, "God Fly Mode", "Fly + infinite health together", function(on)
    flyTgl.Set(on)
    godTgl.Set(on)
    SetFly(on)
    SetGodMode(on)
end)

-- Custom slider that controls head size AND spin speed together
NewSlider(CustomPage, "Chaos Level", 1, 10, 1, "", function(v)
    State.SpinSpeed = v * 2
    local char = GetChar()
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(v * 0.5, v * 0.5, v * 0.5)
    end
end)

NewSep(CustomPage)
NewSection(CustomPage, "QUICK ACTIONS")

NewButton(CustomPage, E.SAVE .. "  Save + Anti-Void", "Save position and enable anti-void", function()
    local hrp = GetHRP()
    if hrp then
        State.SavedCFrame = hrp.CFrame
        antiVoidTgl.Set(true)
    end
end)

NewButton(CustomPage, E.SPIN .. "  Big Spin", "Giant head + max spin for 5 seconds", function()
    local char = GetChar()
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(8, 8, 8)
    end
    State.SpinSpeed = 20
    spinTgl.Set(true)
    task.delay(5, function()
        spinTgl.Set(false)
        if char and char:FindFirstChild("Head") then
            char.Head.Size = Vector3.new(2, 1, 1)
        end
        State.SpinSpeed = 3
    end)
end)

NewButton(CustomPage, "Full Reset", "Disables all features and resets everything", function()
    -- Turn off all toggles
    flyTgl.Set(false)        noclipTgl.Set(false)
    godTgl.Set(false)        espTgl.Set(false)
    invisTgl.Set(false)      ghostTgl.Set(false)
    spinTgl.Set(false)       ragdollTgl.Set(false)
    autoHealTgl.Set(false)   brightTgl.Set(true)
    -- Reset world
    workspace.Gravity        = OrigGravity
    Lighting.ClockTime       = 14
    Lighting.Brightness      = 1
    Lighting.FogEnd          = 10000
    -- Reset character
    local hum = GetHum()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.Health    = hum.MaxHealth
    end
    statusLbl.Set("Status: Reset complete!")
end)

NewSep(CustomPage)
NewSection(CustomPage, "PLAYER INFO")

local infoLbl = NewLabel(CustomPage, "Click Refresh to see info")

NewButton(CustomPage, "Refresh Info", nil, function()
    local hrp = GetHRP()
    local hum = GetHum()
    if hrp and hum then
        local p = hrp.Position
        infoLbl.Set(string.format(
            "HP: %.0f / %.0f\nSpeed: %.0f  |  Pos: %.0f, %.0f, %.0f",
            hum.Health, hum.MaxHealth,
            hum.WalkSpeed,
            p.X, p.Y, p.Z
        ))
    else
        infoLbl.Set("Character not found")
    end
end)
```

---

*KaolinHub v2.0 Documentation | Created by kakavpopee | "Like Bricks, Built Solid."*
*GitHub: https://github.com/kakavpopee/KaolinLib*
