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
