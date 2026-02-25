-- Example GUI using KaolinLib v1.0 API
-- Load the library
local KaolinLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua"))()

-- Create the main window
local Window = KaolinLib:CreateWindow({
    Title = "Example GUI",
    SubTitle = "v1.0 Demo",
    Theme = {
        Accent = Color3.fromRGB(100, 200, 255),  -- Custom blue accent
    }
})

-- Create tabs
local MainTab = Window:CreateTab("Main", "🏠")
local SettingsTab = Window:CreateTab("Settings", "⚙️")

-- Main Tab: Sections and components
MainTab:CreateSection("Player Features")

local flyToggle = MainTab:CreateToggle({
    Name = "Fly Mode",
    Desc = "Enable flying (WASD + Space/Shift)",
    Default = false,
    Callback = function(Value)
        if Value then
            Window:Notify({Title = "Fly", Message = "Fly enabled!", Type = "success"})
            -- Add fly logic here
        else
            -- Disable fly
        end
    end
})

MainTab:CreateSeparator()

MainTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Suffix = " studs/s",
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})

MainTab:CreateButton({
    Name = "Teleport to Origin",
    Desc = "TP to (0, 10, 0)",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
        Window:Notify({Title = "Teleport", Message = "Teleported to origin!", Type = "info"})
    end
})

local statusLabel = MainTab:CreateLabel("Status: Idle")
-- Update label example
statusLabel:Set("Status: Active")

-- Settings Tab: More components
SettingsTab:CreateSection("UI Customization")

SettingsTab:CreateDropdown({
    Name = "Theme Preset",
    Options = {"Default", "Blue", "Red", "Green"},
    Default = "Default",
    Callback = function(Value)
        local theme = {}
        if Value == "Blue" then
            theme.Accent = Color3.fromRGB(80, 160, 255)
        elseif Value == "Red" then
            theme.Accent = Color3.fromRGB(220, 60, 60)
        elseif Value == "Green" then
            theme.Accent = Color3.fromRGB(60, 200, 100)
        end
        -- Apply theme (assuming lib supports dynamic theming)
    end
})

SettingsTab:CreateColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(200, 160, 80),
    Callback = function(Color)
        -- Apply custom color
        print("New accent:", Color)
    end
})

SettingsTab:CreateTextBox({
    Name = "Custom Message",
    Default = "Enter text...",
    ClearOnFocus = true,
    Callback = function(Value)
        Window:Notify({Title = "Message", Message = Value, Duration = 5})
    end
})

-- Keybinds
KaolinLib:BindToggleKey(Enum.KeyCode.RightShift, Window)  -- Toggle GUI with RightShift
KaolinLib:BindKey(Enum.KeyCode.F, function()
    flyToggle:Set(not flyToggle:Get())
end)

-- Startup notification
Window:Notify({
    Title = "Example GUI Loaded",
    Message = "Press RightShift to toggle.",
    Type = "success",
    Duration = 4
})
