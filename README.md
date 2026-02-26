# KaolinHub v3.0 — Documentation
> *"Like Bricks, Built Solid."*  
> Built with **KaolinLib** · by **kakavpopee**  
> GitHub: https://github.com/kakavpopee/KaolinLib

---

## Table of Contents

| # | Section |
|---|---------|
| 1 | [Quick Start](#1-quick-start) |
| 2 | [Configuration (CFG Table)](#2-configuration-cfg-table) |
| 3 | [Key System](#3-key-system) |
| 4 | [Key System Variants](#4-key-system-variants) |
| 5 | [Theme System](#5-theme-system) |
| 6 | [Theme Presets](#6-theme-presets) |
| 7 | [Emoji System](#7-emoji-system) |
| 8 | [Move Tab](#8-move-tab) |
| 9 | [Player Tab](#9-player-tab) |
| 10 | [World Tab](#10-world-tab) |
| 11 | [Players Tab](#11-players-tab) |
| 12 | [Misc Tab](#12-misc-tab) |
| 13 | [Chat Commands](#13-chat-commands) |
| 14 | [Mobile D-Pad](#14-mobile-d-pad) |
| 15 | [PC Keybinds](#15-pc-keybinds) |
| 16 | [State Table Reference](#16-state-table-reference) |
| 17 | [Feature Functions API](#17-feature-functions-api) |
| 18 | [KaolinLib Component API](#18-kaolinlib-component-api) |
| 19 | [Window Controls](#19-window-controls) |
| 20 | [Troubleshooting](#20-troubleshooting) |
| 21 | [Custom Tab Example](#21-custom-tab-example) |

---

## 1. Quick Start

### Requirements
- A **LocalScript** inside `StarterPlayerScripts`
- **HTTP Requests enabled:** Studio → Game Settings → Security → Allow HTTP Requests → ON

### Load the hub

```lua
-- Paste this into a LocalScript in StarterPlayerScripts
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"
))()
```

That's all. On run the key screen appears. Type the correct key and press Enter. The hub slides in.

---

## 2. Configuration (CFG Table)

The `CFG` table is at the very top of the script. Edit these values before publishing.

```lua
local CFG = {
    Key      = "KAOLIN2024",          -- what players must type to unlock the hub
    KeyHint  = "Enter your access key", -- subtitle on the key screen
    Title    = "KaolinHub",           -- hub name shown in the title bar
    Version  = "v3.0",                -- version shown next to the title
    Creator  = "kakavpopee",          -- creator name in the subtitle
}
```

The key is **case-sensitive.** `"KAOLIN2024"` and `"kaolin2024"` are different keys.

---

## 3. Key System

### How it works

```
Script loads
  └─ Key overlay appears (full-screen, blocks the hub)
       └─ Player types key → Enter or clicks Verify
              ├─ CORRECT  →  green flash → overlay fades → hub slides in
              └─ WRONG    →  card shakes → red error → input clears → try again
```

### Verification logic

```lua
local function VerifyKey()
    local input = keyInput.Text

    if input == CFG.Key then
        -- success: fade overlay, slide in hub
        keyMsg.TextColor3 = T.Green
        keyMsg.Text       = E.CHECK .. "  Access Granted!"
        task.wait(0.8)
        KeyGui:Destroy()
        ScreenGui.Enabled = true

    else
        -- fail: shake card, show error, clear input
        keyMsg.TextColor3 = T.Red
        keyMsg.Text       = E.CROSS .. "  Invalid key. Try again."
        task.spawn(ShakeCard)
        keyInput.Text = ""
    end
end
```

### Skip the key screen (testing only)

Find `ScreenGui.Enabled = false` and change it to `true`. Then destroy the key GUI manually at the bottom of the script:

```lua
-- Add this just before the final print() line
if LocalPlayer.PlayerGui:FindFirstChild("KaolinKeyGui") then
    LocalPlayer.PlayerGui.KaolinKeyGui:Destroy()
end
```

---

## 4. Key System Variants

### A — Single static key (default)

One key, everyone who knows it gets access.

```lua
local CFG = {
    Key     = "KAOLIN2024",
    KeyHint = "Enter your access key",
    Title   = "KaolinHub",
    Version = "v3.0",
    Creator = "kakavpopee",
}
```

---

### B — Multiple keys (whitelist)

Each player can have their own unique key.

```lua
local VALID_KEYS = {
    "KAOLIN-ALPHA-001",
    "KAOLIN-BETA-002",
    "KAOLIN-VIP-999",
}

-- Replace the line `if input == CFG.Key then` with:
local valid = false
for _, k in ipairs(VALID_KEYS) do
    if input == k then valid = true break end
end
if valid then
    -- success code ...
else
    -- fail code ...
end
```

Full drop-in `VerifyKey` function:

```lua
local VALID_KEYS = { "KAOLIN-ALPHA-001", "KAOLIN-BETA-002", "KAOLIN-VIP-999" }

local function VerifyKey()
    local input = keyInput.Text
    local valid = false
    for _, k in ipairs(VALID_KEYS) do
        if input == k then valid = true break end
    end

    if valid then
        keyMsg.TextColor3 = T.Green
        keyMsg.Text = E.CHECK .. "  Access Granted!"
        Tw(verifyBtn, {BackgroundColor3 = T.Green}, TW_FAST)
        task.wait(0.8)
        Tw(KeyOverlay, {BackgroundTransparency = 1}, TweenInfo.new(0.5))
        task.wait(0.5)
        KeyGui:Destroy()
        ScreenGui.Enabled = true
        Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
        Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_BACK)
    else
        keyMsg.TextColor3 = T.Red
        keyMsg.Text = E.CROSS .. "  Invalid key. Try again."
        Tw(inputStroke, {Color = T.Red}, TW_FAST)
        task.spawn(ShakeCard)
        task.delay(1.5, function() keyMsg.Text = "" end)
        keyInput.Text = ""
    end
end
```

---

### C — Username whitelist (no typing needed)

Players whose Roblox username is in the list skip the key screen entirely.

```lua
-- Paste this BEFORE the Key GUI section
local ALLOWED_USERS = { "kakavpopee", "YourFriend", "AnotherUser" }

local isAllowed = false
for _, name in ipairs(ALLOWED_USERS) do
    if LocalPlayer.Name == name then isAllowed = true break end
end

if isAllowed then
    ScreenGui.Enabled = true
    Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
    Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_BACK)
else
    -- rest of the Key GUI code runs normally for everyone else
end
```

---

### D — Attempt limiter (lockout after 3 wrong tries)

```lua
local wrongAttempts = 0
local lockedOut     = false

local function VerifyKey()
    if lockedOut then
        keyMsg.TextColor3 = T.Red
        keyMsg.Text = E.WARN .. "  Locked out. Wait 30s."
        return
    end

    local input = keyInput.Text
    if input == CFG.Key then
        wrongAttempts = 0
        -- ... success code ...
    else
        wrongAttempts += 1
        keyInput.Text = ""
        task.spawn(ShakeCard)

        if wrongAttempts >= 3 then
            lockedOut = true
            keyMsg.Text = E.WARN .. "  3 wrong attempts. Locked 30s."
            verifyBtn.Active = false
            task.delay(30, function()
                lockedOut     = false
                wrongAttempts = 0
                verifyBtn.Active = true
                keyMsg.Text = ""
            end)
        else
            keyMsg.TextColor3 = T.Red
            keyMsg.Text = E.CROSS .. "  Wrong. " .. (3 - wrongAttempts) .. " left."
            task.delay(1.5, function() keyMsg.Text = "" end)
        end
    end
end
```

---

## 5. Theme System

All colours come from the `T` table inside the script. Change any value here and the entire UI updates automatically.

```lua
local T = {
    -- Accent colours
    Accent    = Color3.fromRGB(200, 160, 80),   -- title bar, toggles ON, sliders, borders
    AccentDk  = Color3.fromRGB(160, 120, 50),   -- button hover state

    -- Backgrounds
    BgRoot    = Color3.fromRGB(15,  15,  20),   -- main window background
    BgDark    = Color3.fromRGB(10,  10,  14),   -- left sidebar
    BgCard    = Color3.fromRGB(24,  24,  32),   -- toggle / slider / label cards
    BgContent = Color3.fromRGB(19,  19,  26),   -- right content panel

    -- Text
    TextMain  = Color3.fromRGB(225, 225, 230),  -- primary label text
    TextDim   = Color3.fromRGB(95,  95,  112),  -- description / dim text
    TextOn    = Color3.fromRGB(15,  15,  20),   -- text drawn on top of Accent

    -- Component states
    TogOff    = Color3.fromRGB(50,  50,  62),   -- toggle pill when OFF
    SlTrack   = Color3.fromRGB(40,  40,  52),   -- slider unfilled track

    -- Status colours
    Red       = Color3.fromRGB(220, 70,  70),   -- errors, wrong key
    Green     = Color3.fromRGB(70,  200, 110),  -- success, correct key
}
```

### Quick reference

| Key | Appears on | Default colour |
|-----|-----------|---------------|
| `Accent` | Title bar, toggle ON, slider fill, section headers | Gold `(200,160,80)` |
| `AccentDk` | Button hover | Dark gold `(160,120,50)` |
| `BgRoot` | Main window | Near-black `(15,15,20)` |
| `BgDark` | Sidebar | Darkest `(10,10,14)` |
| `BgCard` | Every toggle, slider, label | Dark card `(24,24,32)` |
| `BgContent` | Right content panel | `(19,19,26)` |
| `TextMain` | All primary labels | Near-white `(225,225,230)` |
| `TextDim` | Descriptions, subtitles | Grey `(95,95,112)` |
| `TextOn` | Text sitting on Accent (title, active tab) | Dark `(15,15,20)` |
| `TogOff` | Toggle pill when OFF | Dark grey `(50,50,62)` |
| `SlTrack` | Slider unfilled track | `(40,40,52)` |
| `Red` | Errors, wrong key | `(220,70,70)` |
| `Green` | Success, correct key | `(70,200,110)` |

---

## 6. Theme Presets

Copy any block and paste it over the entire `T = { ... }` section in the script.

### Default Gold
```lua
local T = {
    Accent = Color3.fromRGB(200,160,80), AccentDk = Color3.fromRGB(160,120,50),
    BgRoot = Color3.fromRGB(15,15,20),   BgDark   = Color3.fromRGB(10,10,14),
    BgCard = Color3.fromRGB(24,24,32),   BgContent= Color3.fromRGB(19,19,26),
    TextMain = Color3.fromRGB(225,225,230), TextDim= Color3.fromRGB(95,95,112),
    TextOn = Color3.fromRGB(15,15,20),   TogOff  = Color3.fromRGB(50,50,62),
    SlTrack= Color3.fromRGB(40,40,52),   Red     = Color3.fromRGB(220,70,70),
    Green  = Color3.fromRGB(70,200,110),
}
```

### Ice Blue
```lua
local T = {
    Accent = Color3.fromRGB(80,170,255),  AccentDk = Color3.fromRGB(50,130,210),
    BgRoot = Color3.fromRGB(10,12,20),    BgDark   = Color3.fromRGB(6,8,16),
    BgCard = Color3.fromRGB(18,22,36),    BgContent= Color3.fromRGB(14,18,28),
    TextMain = Color3.fromRGB(220,230,245),TextDim = Color3.fromRGB(80,100,140),
    TextOn = Color3.fromRGB(6,10,20),     TogOff  = Color3.fromRGB(40,50,72),
    SlTrack= Color3.fromRGB(30,40,60),    Red     = Color3.fromRGB(220,70,70),
    Green  = Color3.fromRGB(70,200,110),
}
```

### Blood Red
```lua
local T = {
    Accent = Color3.fromRGB(210,50,50),   AccentDk = Color3.fromRGB(165,30,30),
    BgRoot = Color3.fromRGB(14,10,10),    BgDark   = Color3.fromRGB(9,6,6),
    BgCard = Color3.fromRGB(28,18,18),    BgContent= Color3.fromRGB(22,14,14),
    TextMain = Color3.fromRGB(235,220,220),TextDim = Color3.fromRGB(120,80,80),
    TextOn = Color3.fromRGB(14,8,8),      TogOff  = Color3.fromRGB(60,35,35),
    SlTrack= Color3.fromRGB(48,28,28),    Red     = Color3.fromRGB(220,70,70),
    Green  = Color3.fromRGB(70,200,110),
}
```

### Toxic Green
```lua
local T = {
    Accent = Color3.fromRGB(80,220,100),  AccentDk = Color3.fromRGB(55,170,75),
    BgRoot = Color3.fromRGB(10,14,10),    BgDark   = Color3.fromRGB(6,10,6),
    BgCard = Color3.fromRGB(18,26,18),    BgContent= Color3.fromRGB(14,20,14),
    TextMain = Color3.fromRGB(210,240,210),TextDim = Color3.fromRGB(80,120,80),
    TextOn = Color3.fromRGB(8,14,8),      TogOff  = Color3.fromRGB(35,55,35),
    SlTrack= Color3.fromRGB(28,44,28),    Red     = Color3.fromRGB(220,70,70),
    Green  = Color3.fromRGB(70,200,110),
}
```

### Purple / Violet
```lua
local T = {
    Accent = Color3.fromRGB(165,90,255),  AccentDk = Color3.fromRGB(120,55,200),
    BgRoot = Color3.fromRGB(12,10,20),    BgDark   = Color3.fromRGB(8,6,16),
    BgCard = Color3.fromRGB(24,18,38),    BgContent= Color3.fromRGB(18,14,30),
    TextMain = Color3.fromRGB(230,220,245),TextDim = Color3.fromRGB(100,80,140),
    TextOn = Color3.fromRGB(8,6,18),      TogOff  = Color3.fromRGB(50,35,72),
    SlTrack= Color3.fromRGB(40,28,58),    Red     = Color3.fromRGB(220,70,70),
    Green  = Color3.fromRGB(70,200,110),
}
```

### Light Mode
```lua
local T = {
    Accent = Color3.fromRGB(50,50,50),    AccentDk = Color3.fromRGB(30,30,30),
    BgRoot = Color3.fromRGB(245,245,248), BgDark   = Color3.fromRGB(225,225,230),
    BgCard = Color3.fromRGB(255,255,255), BgContent= Color3.fromRGB(240,240,244),
    TextMain = Color3.fromRGB(30,30,40),  TextDim  = Color3.fromRGB(140,140,160),
    TextOn = Color3.fromRGB(245,245,248), TogOff   = Color3.fromRGB(190,190,200),
    SlTrack= Color3.fromRGB(210,210,220), Red      = Color3.fromRGB(200,50,50),
    Green  = Color3.fromRGB(50,170,80),
}
```

---

## 7. Emoji System

Emojis are stored in the `E` table as **UTF-8 byte escape sequences**. This is the only reliable method — pasting raw emoji into a Lua file often breaks on mobile or different editors.

```lua
local E = {
    RUN    = "\240\159\143\131",   -- running man   (Move tab icon)
    PERSON = "\240\159\145\164",   -- bust           (Player tab icon)
    EARTH  = "\240\159\140\141",   -- globe          (World tab icon)
    PEOPLE = "\240\159\145\165",   -- two people     (Players tab icon)
    GEAR   = "\226\154\153",       -- gear           (Misc tab icon)
    SHIELD = "\240\159\155\161",   -- shield         (God Mode)
    EYE    = "\240\159\145\129",   -- eye            (ESP, Invisible, Spectate)
    SKULL  = "\240\159\146\128",   -- skull          (Ghost Mode)
    SPIN   = "\240\159\140\128",   -- cyclone        (Spin toggle)
    SAVE   = "\240\159\146\190",   -- floppy disk    (Save Position)
    MAP    = "\240\159\151\186",   -- map            (Teleport buttons)
    FLASH  = "\226\154\161",       -- lightning bolt (Fullbright)
    STAR   = "\226\152\133",       -- star           (Lock Sun)
    CHECK  = "\226\156\147",       -- checkmark      (Key success)
    CROSS  = "\226\156\149",       -- cross          (Key error)
    WARN   = "\226\154\160",       -- warning        (Lockout messages)
    HOSP   = "\240\159\143\165",   -- hospital       (Auto Heal, God Mode)
    CHAT   = "\240\159\146\172",   -- speech bubble  (Chat Commands)
    PAINT  = "\240\159\142\168",   -- artist palette (Color pickers)
    SPEED  = "\240\159\146\168",   -- rocket         (Speed section)
}
```

### Adding a new emoji

1. Find the emoji on [emojipedia.org](https://emojipedia.org) and note its code point (e.g. `U+1F525` for fire)
2. Run this snippet to get the Lua escape bytes:

```python
cp = 0x1F525  # your emoji's code point
b  = chr(cp).encode("utf-8")
print("".join(f"\\{x}" for x in b))
# prints: \240\159\148\165
```

3. Add to `E` and use anywhere:

```lua
E.FIRE = "\240\159\148\165"

-- example use in a toggle label:
Tab:CreateToggle({ Name = E.FIRE .. " Fire Mode", ... })
```

---

## 8. Move Tab

Controls all movement and position features.

---

### Fly

Flies your character using `BodyVelocity` + `BodyGyro`. On PC uses WASD + Space/Shift. On mobile uses the D-pad overlay (see [Section 14](#14-mobile-d-pad)).

When fly is turned off or your character respawns/dies, the D-pad hides automatically and all connections clean up.

```lua
flyTgl:Set(true)    -- enable fly
flyTgl:Set(false)   -- disable fly
flyTgl:Get()        -- returns true / false

-- Change default fly speed (before runtime):
State.FlySpeed = 80

-- Change fly speed at runtime:
-- use the Fly Speed slider in the UI, or:
State.FlySpeed = 120
```

**PC controls while flying:**

| Key | Action |
|-----|--------|
| `W` / `S` | Forward / backward |
| `A` / `D` | Strafe left / right |
| `Space` | Fly upward |
| `LeftShift` | Fly downward |

---

### Noclip

Sets `CanCollide = false` on all character `BasePart`s every `Stepped` frame. Restores all collision when turned off.

```lua
noclipTgl:Set(true)
noclipTgl:Set(false)
```

---

### Infinite Jump

Intercepts `UserInputService.JumpRequest` and forces `Jumping` state on every press, mid-air or not.

```lua
infJumpTgl:Set(true)
```

---

### Sprint

On PC: hold `LeftShift` while sprint is ON to sprint at `State.SprintSpeed`. On mobile: enabling sprint applies the speed immediately without needing a key hold.

```lua
sprintTgl:Set(true)
State.SprintSpeed = 80  -- or use the Sprint Speed slider
```

---

### No Fall Damage

Listens for `Humanoid.StateChanged` → `Landed` and immediately resets `Health` to `MaxHealth`.

```lua
noFallTgl:Set(true)
```

---

### Anti-Void

Every frame saves your `HumanoidRootPart.CFrame` as long as `Y > -80`. If you fall below `Y = -80`, you are immediately teleported back to the last saved CFrame.

```lua
antiVoidTgl:Set(true)
```

---

### Click Teleport

**PC:** `Mouse.Button1Down` on any surface teleports you there (3 studs above hit position).  
**Mobile:** `TouchTap` on any surface teleports you there.

```lua
tpTgl:Set(true)
```

---

### Save Position / Go To Saved

Saves your current `CFrame` to `State.SavedCFrame` and teleports back on demand.

```lua
-- From code:
State.SavedCFrame = GetHRP().CFrame   -- save
GetHRP().CFrame   = State.SavedCFrame -- restore
```

---

### Speed & Jump Sliders

```lua
speedSld:Set(100)   -- set walk speed value (also enable Speed Boost toggle)
jumpSld:Set(200)    -- set jump power — applies immediately to Humanoid

speedSld:Get()      -- read current slider value
jumpSld:Get()
```

---

### Reset Movement

Turns off Fly, Noclip, Infinite Jump, Sprint, and Speed Boost. Restores `WalkSpeed = 16` and `JumpPower = 50`. Also hides the fly pad correctly.

---

## 9. Player Tab

Controls your character's health, appearance, and physics.

---

### God Mode

Sets `Humanoid.MaxHealth` and `Health` to `math.huge` every `Heartbeat`. When disabled, resets both to `100`.

```lua
godTgl:Set(true)
godTgl:Set(false)
```

---

### Auto Heal

Monitors `Health / MaxHealth * 100` every `Heartbeat`. When it drops below `State.AutoHealPct`, heals to full. Does nothing if God Mode is active.

```lua
autoHealTgl:Set(true)
healSld:Set(50)       -- heal when below 50%
State.AutoHealPct = 50
```

---

### Full Heal (button)

Instantly sets `Health = MaxHealth` once. No toggle, fires immediately on click.

---

### ESP Highlights

Adds a `Highlight` instance to every other player's character with `DepthMode = AlwaysOnTop`. Works through walls. Also auto-applies to players who join after ESP is turned on.

```lua
espTgl:Set(true)

-- Change highlight colour with the colour picker in the UI,
-- or from code (re-applies to all current highlights):
State.ESPColor = Color3.fromRGB(0, 200, 255)
```

---

### Invisible

Sets `Transparency = 1` on all your `BasePart`s. Stores original values and restores them when turned off.

```lua
invisTgl:Set(true)
invisTgl:Set(false)   -- restores original transparency
```

---

### Spin

Rotates `HumanoidRootPart` on Y axis every `Heartbeat` at `State.SpinSpeed` radians/second.

```lua
spinTgl:Set(true)
State.SpinSpeed = 10   -- or use the Spin Speed slider
```

---

### Ragdoll

Changes `Humanoid` state to `Physics`. Turning off changes state to `GettingUp`.

```lua
ragdollTgl:Set(true)
ragdollTgl:Set(false)
```

---

### Animation Speed

Calls `AdjustSpeed()` on all currently playing `AnimationTrack`s.

```lua
animSld:Set(2)    -- double speed
animSld:Set(0)    -- freeze all animations
animSld:Set(1)    -- normal speed
```

---

### Head Size / Body Scale / Remove Accessories / Reset Character

All accessed through the UI. Reset Character first disables Fly (hiding the D-pad) then calls `LocalPlayer:LoadCharacter()`.

---

## 10. World Tab

Controls lighting, fog, gravity, and time.

---

### Time of Day

Sets `Lighting.ClockTime` to a value between 0 and 24.

```lua
timeSld:Set(18)   -- golden hour
timeSld:Set(2)    -- night
timeSld:Set(12)   -- noon
```

---

### Lock Sun

Freezes `Lighting.ClockTime` at whatever value it currently is, every `Heartbeat`. Set your time first, then enable Lock Sun.

```lua
lockSunTgl:Set(true)    -- freeze at current time
lockSunTgl:Set(false)   -- allow time to change again
```

---

### Fullbright

Sets `Brightness = 10`, `Ambient` and `OutdoorAmbient` to white. Saves and restores originals when turned off.

```lua
brightTgl:Set(true)
brightTgl:Set(false)  -- restores saved values
```

---

### Remove Fog

Pushes `FogEnd` and `FogStart` to `9×10⁸` (effectively invisible). Restores defaults when turned off.

---

### Rainbow Ambient

Cycles `Lighting.Ambient` and `OutdoorAmbient` through HSV on every `Heartbeat`. Turning off restores them to `(127,127,127)`.

---

### Gravity

Sets `workspace.Gravity`. Range 5–500. Anti-Gravity toggle sets it to `10`. Reset Gravity button restores the original value from when the script loaded.

---

### Lighting Presets

| Preset | What changes |
|--------|-------------|
| Default | Resets ClockTime, Brightness, Fog, Ambient to originals |
| Golden Hour | ClockTime = 18, Brightness = 1.5, warm amber ambient |
| Dark Night | ClockTime = 2, Brightness = 0.3, dark blue ambient |
| Foggy Storm | ClockTime = 10, Brightness = 0.3, FogEnd = 300 |
| Blood Red | ClockTime = 12, red ambient and outdoor ambient |

---

## 11. Players Tab

Lets you pick another player from a dropdown and act on them.

---

### Selecting a Player

Click the dropdown to open a list of all players except yourself. Click a name to select them. That player becomes the target for all action buttons.

```lua
playerDrop:Get()            -- returns the currently selected name (string)
playerDrop:Set("PlayerName") -- select a player by name programmatically
playerDrop:Refresh(GetPlayerNames()) -- rebuild the list after someone joins/leaves
```

---

### Teleport To Player

Teleports your `HumanoidRootPart` 3 studs beside the selected player's `HumanoidRootPart`.

---

### Spectate Player

Switches `Camera.CameraType` to `Scriptable` and uses `RenderStepped` to follow the selected player from behind at `CFrame.new(0, 4, -10)`. Turning off restores `CameraType = Custom`.

```lua
specTgl:Set(true)    -- start spectating the selected player
specTgl:Set(false)   -- stop, camera returns to normal
```

> If your camera feels stuck after stopping spectate, click anywhere in the game viewport.

---

### Copy Their Position

Saves the selected player's `HumanoidRootPart.CFrame` into `State.SavedCFrame`. Then use Go To Saved or Loop TP to use it.

---

### Refresh Info

Reads the selected player's current `Health`, `MaxHealth`, and position, and displays it in the info label.

---

## 12. Misc Tab

---

### Anti-AFK

Accumulates `Heartbeat` delta time. Every 270 seconds (4.5 minutes) it fires `Humanoid.Jump = true` to reset the Roblox AFK timer.

---

### Hide HUD

Calls `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)` to hide the Roblox health bar, backpack, leaderboard, and chat. Toggle off to show them again.

---

### Chat Commands

Requires the **Enable Chat Commands** toggle to be ON. Hooks into `LocalPlayer.Chatted` and parses messages. See [Section 13](#13-chat-commands) for the full command list.

---

### Set Exact Walk Speed (TextBox)

Type any number and press Enter to apply it directly to `Humanoid.WalkSpeed`. Accepts only numeric input.

---

## 13. Chat Commands

Enable the **Enable Chat Commands** toggle in the Misc tab first. Then type any of these in the Roblox chat.

| Command | What it does | Example |
|---------|-------------|---------|
| `/help` | Shows command list as a notification | `/help` |
| `/fly` | Toggles fly on/off | `/fly` |
| `/noclip` | Toggles noclip on/off | `/noclip` |
| `/god` | Toggles god mode on/off | `/god` |
| `/heal` | Full heals you instantly | `/heal` |
| `/invis` | Toggles invisible on/off | `/invis` |
| `/spin` | Toggles spin on/off | `/spin` |
| `/bright` | Toggles fullbright on/off | `/bright` |
| `/speed [n]` | Sets walk speed to n | `/speed 100` |
| `/gravity [n]` | Sets workspace gravity to n | `/gravity 50` |
| `/time [0–24]` | Sets time of day | `/time 18` |
| `/reset` | Stops fly (hides D-pad) then respawns | `/reset` |

### Adding your own command

Find the `LocalPlayer.Chatted` block and add an `elseif` inside it:

```lua
elseif cmd == "/bighead" then
    local c = GetChar()
    if c and c:FindFirstChild("Head") then
        c.Head.Size = Vector3.new(6, 6, 6)
    end

elseif cmd == "/normalhead" then
    local c = GetChar()
    if c and c:FindFirstChild("Head") then
        c.Head.Size = Vector3.new(2, 1, 1)
    end

elseif cmd == "/kill" then
    local hum = GetHum()
    if hum then hum.Health = 0 end

elseif cmd == "/tp" and parts[2] then
    local target = Players:FindFirstChild(parts[2])
    if target and target.Character then
        local hrp2 = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = GetHRP()
        if hrp and hrp2 then hrp.CFrame = hrp2.CFrame + Vector3.new(3,0,0) end
    end
```

---

## 14. Mobile D-Pad

When **Fly** is toggled ON on a mobile device, a transparent D-pad overlay appears in the bottom-left corner of the screen. It disappears automatically when fly is turned off, when the character resets, or when the character dies.

### Button layout

```
        [ ^ FWD ]
  [ < LFT ] [ v BCK ] [ > RGT ]
  [    UP    ]  [    DN    ]
```

| Button | FlyDir flag set | What it does |
|--------|----------------|-------------|
| `^` | `Forward` | Move in camera's forward direction |
| `v` | `Backward` | Move in camera's backward direction |
| `<` | `Left` | Strafe left |
| `>` | `Right` | Strafe right |
| `UP` | `Up` | Rise vertically |
| `DN` | `Down` | Descend vertically |

Buttons are pressed and held — moving starts the moment you touch and stops the moment you release.

### Repositioning the D-pad

Find the `Pad.Position` line in the D-pad section of the script:

```lua
Pad.Position = UDim2.new(0, 10, 1, -174)
--                        ^ 10px from left, 174px from bottom
```

Change the offsets to move it anywhere on screen. For example, bottom-right:

```lua
Pad.Position = UDim2.new(1, -220, 1, -174)
```

### Resizing the D-pad

```lua
Pad.Size = UDim2.new(0, 210, 0, 162)
-- change 210 (width) and 162 (height)
```

---

## 15. PC Keybinds

These fire via `KaolinLib:BindKey()` and are silently ignored on mobile.

| Key | Action |
|-----|--------|
| `H` | Show / hide the hub window |
| `F` | Toggle Fly |
| `N` | Toggle Noclip |
| `G` | Toggle God Mode |
| `E` | Toggle ESP |
| `V` | Toggle Invisible |

### Adding a custom keybind

Use `KaolinLib:BindKey()` at the bottom of the script alongside the existing ones:

```lua
-- Toggle spin with T
KaolinLib:BindKey(Enum.KeyCode.T, function()
    spinTgl:Set(not spinTgl:Get())
end)

-- Toggle anti-gravity with X
KaolinLib:BindKey(Enum.KeyCode.X, function()
    -- find the antigrav toggle object and use :Set()
    antiGravTgl:Set(not antiGravTgl:Get())
end)

-- Instant heal with J
KaolinLib:BindKey(Enum.KeyCode.J, function()
    local hum = GetHum()
    if hum then hum.Health = hum.MaxHealth end
end)
```

---

## 16. State Table Reference

The `State` table holds the current value of every feature. Read from it anywhere in the script.

```lua
print(State.FlyEnabled)    -- true / false
print(State.FlySpeed)      -- number
print(State.SavedCFrame)   -- CFrame or nil
```

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `FlyEnabled` | bool | false | Is fly active |
| `FlySpeed` | number | 60 | Fly speed (studs/s) |
| `WalkSpeed` | number | 50 | Walk speed slider value |
| `SprintSpeed` | number | 60 | Sprint speed value |
| `JumpPower` | number | 100 | Jump power value |
| `SpinSpeed` | number | 5 | Spin speed (rad/s) |
| `AutoHealPct` | number | 30 | Auto-heal threshold (%) |
| `SavedCFrame` | CFrame/nil | nil | Saved position |
| `ESPColor` | Color3 | red | ESP highlight fill colour |
| `FlyEnabled` | bool | false | Is fly on |
| `SpeedEnabled` | bool | false | Is speed boost on |
| `GodEnabled` | bool | false | Is god mode on |
| `ESPEnabled` | bool | false | Is ESP on |

---

## 17. Feature Functions API

These are the internal functions that power each feature. Call them directly if you want to trigger a feature from your own added code. Always call the matching toggle's `:Set()` too so the UI stays in sync.

```lua
-- Movement
SetFly(true/false)          -- also shows/hides the D-pad
SetNoclip(true/false)
SetInfJump(true/false)
SetSprint(true/false)
SetNoFallDmg(true/false)
SetAntiVoid(true/false)
SetTeleport(true/false)     -- click/tap to teleport
SetLoopTP(true/false)       -- freeze at saved position

-- Player
SetGodMode(true/false)
SetAutoHeal(true/false)
SetInvisible(true/false)
SetSpin(true/false)
SetRagdoll(true/false)
SetESP(true/false)
SetSpectate(true/false, playerObject)

-- World
SetFullbright(true/false)
SetRemoveFog(true/false)
SetLockSun(true/false)
SetAntiAFK(true/false)
```

### Example — enable multiple features at once

```lua
-- Auto-enable god mode + anti-void + anti-AFK on load
task.delay(1, function()
    SetGodMode(true)    godTgl:Set(true)
    SetAntiVoid(true)   antiVoidTgl:Set(true)
    SetAntiAFK(true)    -- Misc tab toggle (find the toggle object reference)
end)
```

> **Rule:** always pair each `SetXxx()` call with the matching `tgl:Set()` call so the visual toggle pill stays in sync with the actual state.

---

## 18. KaolinLib Component API

KaolinHub v3.0 is built on top of **KaolinLib**. Here is the full API for every component the library provides.

---

### Window

```lua
local Window = KaolinLib:CreateWindow({
    Title    = "MyHub",
    SubTitle = "v1.0  |  by me",
    Theme    = {
        -- any DefaultTheme keys to override, e.g.:
        Accent = Color3.fromRGB(100, 200, 100),
    },
})
```

---

### Notification

```lua
Window:Notify({
    Title    = "Hello",
    Message  = "Something happened.",
    Type     = "success",   -- "success" | "error" | "info"
    Duration = 3,           -- seconds before it disappears
})
```

---

### Tab

```lua
local Tab = Window:CreateTab("Tab Name", "ICON")
-- icon can be any emoji string from the E table, e.g. E.RUN
```

---

### Section header

```lua
Tab:CreateSection("SECTION NAME")
-- renders a tinted label across the full width of the tab
```

---

### Separator

```lua
Tab:CreateSeparator()
-- renders a 1px horizontal line
```

---

### Label

```lua
local lbl = Tab:CreateLabel("Initial text here.")

-- Update text at any time:
lbl:Set("New text.")
```

---

### Toggle

```lua
local tgl = Tab:CreateToggle({
    Name     = "My Feature",
    Desc     = "Short description shown below the name",  -- optional
    Default  = false,
    Callback = function(value)  -- value is true or false
        -- your logic here
    end,
})

tgl:Set(true)    -- turn on (fires callback)
tgl:Set(false)   -- turn off (fires callback)
tgl:Get()        -- returns current state (bool)
```

---

### Slider

```lua
local sld = Tab:CreateSlider({
    Name     = "My Value",
    Min      = 0,
    Max      = 100,
    Default  = 50,
    Suffix   = "%",   -- appended after the number in the display
    Callback = function(value)  -- value is a rounded integer
        -- your logic here
    end,
})

sld:Set(75)    -- set value (fires callback)
sld:Get()      -- returns current number
```

---

### Button

```lua
Tab:CreateButton({
    Name     = "Click Me",
    Desc     = "Optional description",   -- omit for compact button
    Callback = function()
        -- your logic here
    end,
})
```

---

### TextBox

```lua
local box = Tab:CreateTextBox({
    Name         = "Enter Value",
    Default      = "Type here...",
    ClearOnFocus = true,
    Numeric      = false,   -- true = only allows numbers
    Callback     = function(value)  -- fires when Enter pressed or focus lost
        -- value is a string
    end,
})

box:Set("Hello")   -- set text programmatically
box:Get()          -- returns current text string
```

---

### Dropdown

```lua
local dd = Tab:CreateDropdown({
    Name     = "Choose Option",
    Options  = { "Alpha", "Beta", "Gamma" },
    Default  = "Alpha",
    Callback = function(selected)   -- selected is the chosen string
        -- your logic here
    end,
})

dd:Set("Beta")                -- select an option programmatically
dd:Get()                      -- returns currently selected string
dd:Refresh({ "X", "Y", "Z" }) -- replace the options list
```

---

### Color Picker

```lua
local picker = Tab:CreateColorPicker({
    Name     = "Pick a Colour",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(color)   -- color is a Color3
        -- your logic here
    end,
})

picker:Set(Color3.fromRGB(0, 255, 0))   -- set colour programmatically
picker:Get()                             -- returns current Color3
```

---

### Keybind helpers

```lua
-- Fire a function when a key is pressed (PC only, silent on mobile)
KaolinLib:BindKey(Enum.KeyCode.T, function()
    print("T was pressed")
end)

-- Toggle the hub window visibility with a key
KaolinLib:BindToggleKey(Enum.KeyCode.H, Window)
```

---

## 19. Window Controls

| Control | How to use |
|---------|-----------|
| **Drag** | Click and drag the gold title bar. Works with mouse and touch. |
| **Close (X)** | Hides the window. The floating brick button appears to restore it. |
| **Minimise (−)** | Collapses to just the title bar. Click again to expand. |
| **Restore (brick button)** | Only visible when window is closed. Click to reopen. |
| **H key** | Toggles window visibility on PC. |

---

## 20. Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `HttpService is not enabled` | HTTP off in Studio | Game Settings → Security → Allow HTTP Requests → ON |
| Emojis show as `?` squares | Raw emoji in source | Use the `E` table byte escapes — never paste raw emoji into Lua |
| Key screen appears but Verify does nothing | Lua error inside `VerifyKey` | Open the Developer Console (F9) and check for errors |
| Fly pad doesn't appear on mobile | Not on mobile, or `HubGui` not found at build time | Confirm `IsMobile` is true; check the D-pad section runs after `CreateWindow` |
| Fly pad stays visible after turning fly off | Old code path | Use v3.0 — `SetFly` now always sets `FlyPadFrame.Visible` |
| Fly pad stays after character reset | Old code path | v3.0 has a `CharacterRemoving` listener that hides it automatically |
| Toggle pill doesn't match feature state | Calling `SetXxx()` without `:Set()` | Always call both: `SetGodMode(true)` and `godTgl:Set(true)` |
| Spectate camera stuck after disabling | `CameraType` not restored | Toggle Spectate off — it sets `CameraType = Custom`. Click in the viewport if still stuck. |
| Chat commands not working | Toggle is OFF | Enable **Enable Chat Commands** in the Misc tab first |
| Sprint not working on mobile | Needs `LeftShift` on PC | On mobile, sprint applies immediately when toggled — no key hold needed |
| `attempt to index nil with 'Set'` | Toggle object used before being defined | Move the `:Set()` call to after the toggle is created |

---

## 21. Custom Tab Example

A complete working example of a custom tab using every KaolinLib component. Paste this block **after** `Window:CreateTab` calls but **before** the PC Keybinds section.

```lua
-- ============================================================
--  CUSTOM TAB EXAMPLE
-- ============================================================
local MyTab = Window:CreateTab("Custom", E.STAR)

MyTab:CreateSection("STATUS")

local statusLbl = MyTab:CreateLabel("Status: Idle")

MyTab:CreateSection("FEATURES")

MyTab:CreateToggle({
    Name     = "Speed x10",
    Desc     = "Sets walk speed to 160",
    Default  = false,
    Callback = function(on)
        local hum = GetHum()
        if hum then hum.WalkSpeed = on and 160 or 16 end
        statusLbl:Set(on and "Status: SPEED ACTIVE" or "Status: Idle")
    end,
})

MyTab:CreateToggle({
    Name     = "God Fly",
    Desc     = "Fly + infinite health at once",
    Default  = false,
    Callback = function(on)
        flyTgl:Set(on)
        godTgl:Set(on)
    end,
})

MyTab:CreateSlider({
    Name     = "Chaos Level",
    Min      = 1,
    Max      = 10,
    Default  = 1,
    Suffix   = "x",
    Callback = function(v)
        State.SpinSpeed = v * 2
        local c = GetChar()
        if c and c:FindFirstChild("Head") then
            c.Head.Size = Vector3.new(v * 0.6, v * 0.6, v * 0.6)
        end
    end,
})

MyTab:CreateColorPicker({
    Name     = "ESP Colour",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(col)
        State.ESPColor = col
        if State.ESPEnabled then
            for _, p in ipairs(Players:GetPlayers()) do RemoveESP(p) end
            for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
        end
    end,
})

MyTab:CreateDropdown({
    Name     = "Preset Speed",
    Options  = { "Walk (16)", "Jog (32)", "Run (60)", "Blaze (150)" },
    Default  = "Walk (16)",
    Callback = function(v)
        local speeds = { ["Walk (16)"]=16, ["Jog (32)"]=32, ["Run (60)"]=60, ["Blaze (150)"]=150 }
        local hum = GetHum()
        if hum and speeds[v] then hum.WalkSpeed = speeds[v] end
    end,
})

MyTab:CreateSeparator()
MyTab:CreateSection("QUICK ACTIONS")

MyTab:CreateButton({
    Name     = "Save + Anti-Void",
    Desc     = "Save position and enable anti-void together",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            State.SavedCFrame = hrp.CFrame
            antiVoidTgl:Set(true)
            Window:Notify({ Title = "Done", Message = "Position saved and anti-void enabled.", Type = "success", Duration = 2 })
        end
    end,
})

MyTab:CreateButton({
    Name     = "5-Second Spin Burst",
    Desc     = "Big head + max spin for 5 seconds",
    Callback = function()
        local c = GetChar()
        if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(8,8,8) end
        State.SpinSpeed = 20
        spinTgl:Set(true)
        task.delay(5, function()
            spinTgl:Set(false)
            State.SpinSpeed = 5
            local c2 = GetChar()
            if c2 and c2:FindFirstChild("Head") then c2.Head.Size = Vector3.new(2,1,1) end
        end)
    end,
})

MyTab:CreateButton({
    Name     = "Full Reset Everything",
    Desc     = "Turn off all features and restore defaults",
    Callback = function()
        flyTgl:Set(false)
        noclipTgl:Set(false)
        godTgl:Set(false)
        espTgl:Set(false)
        invisTgl:Set(false)
        spinTgl:Set(false)
        ragdollTgl:Set(false)
        autoHealTgl:Set(false)
        workspace.Gravity   = OrigGravity
        Lighting.ClockTime  = 14
        Lighting.Brightness = 1
        Lighting.FogEnd     = 10000
        local hum = GetHum()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.Health    = hum.MaxHealth
        end
        statusLbl:Set("Status: Reset complete!")
        Window:Notify({ Title = "Reset", Message = "All features off, defaults restored.", Type = "info", Duration = 3 })
    end,
})

MyTab:CreateSeparator()
MyTab:CreateSection("LIVE INFO")

local infoLbl = MyTab:CreateLabel("Press Refresh to see stats.")

MyTab:CreateTextBox({
    Name         = "Custom Walk Speed",
    Default      = "16",
    Numeric      = true,
    ClearOnFocus = true,
    Callback     = function(v)
        local n = tonumber(v)
        if n then
            local hum = GetHum()
            if hum then hum.WalkSpeed = n end
        end
    end,
})

MyTab:CreateButton({
    Name     = "Refresh Stats",
    Callback = function()
        local hum = GetHum()
        local hrp = GetHRP()
        if hum and hrp then
            local p = hrp.Position
            infoLbl:Set(string.format(
                "HP: %.0f/%.0f  Speed: %.0f  Pos: %.0f, %.0f, %.0f",
                hum.Health, hum.MaxHealth, hum.WalkSpeed, p.X, p.Y, p.Z
            ))
        else
            infoLbl:Set("Character not loaded yet.")
        end
    end,
})
```

---

*KaolinHub v3.0 Documentation · kakavpopee · "Like Bricks, Built Solid."*  
*GitHub: https://github.com/kakavpopee/KaolinLib*
