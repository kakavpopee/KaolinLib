-- ============================================================
--  KaolinHub v2.0  |  "Like Bricks, Built Solid."
--  Educational Roblox Studio Testing Script
--  GitHub: https://raw.githubusercontent.com/kakavpopee/KaolinLib/main/KaolinLib.lua
-- ============================================================

-- ============================================================
--  CONFIG  (edit these values at the top of your script)
-- ============================================================
local CFG = {
    Key      = "KAOLIN2024",       -- Key players must type to unlock the hub
    KeyHint  = "Enter your access key",
    Title    = "KaolinHub",
    Version  = "v2.0",
    Creator  = "kakavpopee",
}

-- ============================================================
--  EMOJI (UTF-8 byte escapes - reliable on ALL Roblox devices)
-- ============================================================
local E = {
    BRICK  = "\240\159\167\177",
    RUN    = "\240\159\143\131",
    PERSON = "\240\159\145\164",
    PEOPLE = "\240\159\145\165",
    EARTH  = "\240\159\140\141",
    GEAR   = "\226\154\153",
    CROSS  = "\226\156\149",
    DASH   = "\226\136\146",
    UP     = "\226\172\134",
    DOWN   = "\226\172\135",
    LEFT   = "\226\172\133",
    RIGHT  = "\226\158\161",
    RISE   = "\240\159\148\188",
    FALL   = "\240\159\148\189",
    STAR   = "\226\152\133",
    CHECK  = "\226\156\147",
    LOCK   = "\240\159\148\146",
    KEY    = "\240\159\148\145",
    FLASH  = "\226\154\161",
    EYE    = "\240\159\145\129",
    SHIELD = "\240\159\155\161",
    CHAT   = "\240\159\146\172",
    HOSP   = "\240\159\143\165",
    SPIN   = "\240\159\140\128",
    MAP    = "\240\159\151\186",
    SAVE   = "\240\159\146\190",
    WARN   = "\226\154\160",
    SKULL  = "\240\159\146\128",
}

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  MOBILE DETECTION
-- ============================================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  STATE
-- ============================================================
local State = {
    -- Movement
    FlyEnabled      = false,
    FlySpeed        = 60,
    NoclipEnabled   = false,
    InfJumpEnabled  = false,
    SprintEnabled   = false,
    SprintSpeed     = 50,
    NoFallDmg       = false,
    AntiVoidEnabled = false,
    AntiGravEnabled = false,
    SpeedEnabled    = false,
    WalkSpeed       = 50,
    JumpPower       = 100,
    LoopTPEnabled   = false,
    SavedCFrame     = nil,

    -- Player
    GodModeEnabled  = false,
    AutoHealEnabled = false,
    AutoHealPct     = 30,
    InvisEnabled    = false,
    GhostEnabled    = false,
    RagdollEnabled  = false,
    SpinEnabled     = false,
    SpinSpeed       = 3,
    ESPEnabled      = false,
    AnimSpeed       = 1,

    -- World
    FullbrightOn    = false,
    RemoveFogOn     = false,
    LockSunOn       = false,
    LockedTime      = 14,

    -- Misc
    AntiAFKOn       = false,
    ChatCmdsOn      = false,
    FpsDisplayOn    = false,
    PosDisplayOn    = false,
}

local Connections   = {}
local ESPHighlights = {}
local FlyDir        = { Forward=false,Backward=false,Left=false,Right=false,Up=false,Down=false }
local FlyPadFrame   -- assigned later

-- ============================================================
--  HELPERS
-- ============================================================
local function GetChar() return LocalPlayer.Character end
local function GetHRP()  local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()  local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function DC(c)     if c then c:Disconnect() end end
local function Tw(o,p,i) TweenService:Create(o,i or TweenInfo.new(0.15,Enum.EasingStyle.Quad),p):Play() end

-- ============================================================
--  FEATURE: FLY
-- ============================================================
local BodyVel, BodyGyr, FlyConn

local function StartFly()
    local hrp = GetHRP() if not hrp then return end
    BodyVel = Instance.new("BodyVelocity")
    BodyVel.Velocity = Vector3.new(0,0,0)
    BodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
    BodyVel.P        = 1e4
    BodyVel.Parent   = hrp
    BodyGyr = Instance.new("BodyGyro")
    BodyGyr.MaxTorque = Vector3.new(1e5,1e5,1e5)
    BodyGyr.D         = 100
    BodyGyr.P         = 1e4
    BodyGyr.CFrame    = hrp.CFrame
    BodyGyr.Parent    = hrp
    local hum = GetHum() if hum then hum.PlatformStand = true end
    FlyConn = RunService.Heartbeat:Connect(function()
        local h2 = GetHRP() if not h2 then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        local spd = State.FlySpeed
        if IsMobile then
            if FlyDir.Forward  then dir = dir + cam.CFrame.LookVector  end
            if FlyDir.Backward then dir = dir - cam.CFrame.LookVector  end
            if FlyDir.Left     then dir = dir - cam.CFrame.RightVector end
            if FlyDir.Right    then dir = dir + cam.CFrame.RightVector end
            if FlyDir.Up       then dir = dir + Vector3.new(0,1,0)     end
            if FlyDir.Down     then dir = dir - Vector3.new(0,1,0)     end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0)     end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0)     end
        end
        BodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * spd or Vector3.new(0,0,0)
        BodyGyr.CFrame   = cam.CFrame
    end)
end

local function StopFly()
    DC(FlyConn) FlyConn = nil
    if BodyVel then BodyVel:Destroy() BodyVel = nil end
    if BodyGyr  then BodyGyr:Destroy()  BodyGyr  = nil end
    local hum = GetHum() if hum then hum.PlatformStand = false end
end

local function SetFly(on)
    State.FlyEnabled = on
    if on then StartFly() else StopFly() end
    if FlyPadFrame then FlyPadFrame.Visible = on end
end

-- ============================================================
--  FEATURE: NOCLIP
-- ============================================================
local NoclipConn

local function SetNoclip(on)
    State.NoclipEnabled = on
    DC(NoclipConn) NoclipConn = nil
    if on then
        NoclipConn = RunService.Stepped:Connect(function()
            local c = GetChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        local c = GetChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ============================================================
--  FEATURE: INFINITE JUMP
-- ============================================================
local InfJumpConn

local function SetInfJump(on)
    State.InfJumpEnabled = on
    DC(InfJumpConn) InfJumpConn = nil
    if on then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = GetHum()
            if hum and State.InfJumpEnabled then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

-- ============================================================
--  FEATURE: SPRINT  (PC: hold LeftShift while sprint toggle is on)
-- ============================================================
local SprintConn

local function SetSprint(on)
    State.SprintEnabled = on
    DC(SprintConn) SprintConn = nil
    if on then
        SprintConn = RunService.Heartbeat:Connect(function()
            local hum = GetHum()
            if not hum then return end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                hum.WalkSpeed = State.SprintSpeed
            else
                hum.WalkSpeed = State.SpeedEnabled and State.WalkSpeed or 16
            end
        end)
    else
        local hum = GetHum()
        if hum then hum.WalkSpeed = State.SpeedEnabled and State.WalkSpeed or 16 end
    end
end

-- ============================================================
--  FEATURE: NO FALL DAMAGE
-- ============================================================
local FallDmgConn

local function SetNoFallDmg(on)
    State.NoFallDmg = on
    DC(FallDmgConn) FallDmgConn = nil
    if on then
        local hum = GetHum()
        if not hum then return end
        FallDmgConn = hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Landed then
                local h = GetHum()
                if h then h.Health = h.MaxHealth end
            end
        end)
    end
end

-- ============================================================
--  FEATURE: ANTI-VOID  (teleports back if Y < -150)
-- ============================================================
local AntiVoidConn
local LastSafePos = nil

local function SetAntiVoid(on)
    State.AntiVoidEnabled = on
    DC(AntiVoidConn) AntiVoidConn = nil
    if on then
        AntiVoidConn = RunService.Heartbeat:Connect(function()
            local hrp = GetHRP() if not hrp then return end
            if hrp.Position.Y > -100 then
                LastSafePos = hrp.CFrame
            elseif LastSafePos then
                hrp.CFrame = LastSafePos
            end
        end)
    end
end

-- ============================================================
--  FEATURE: GOD MODE
-- ============================================================
local GodConn

local function SetGodMode(on)
    State.GodModeEnabled = on
    DC(GodConn) GodConn = nil
    local hum = GetHum() if not hum then return end
    if on then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        GodConn = RunService.Heartbeat:Connect(function()
            local h = GetHum()
            if h and State.GodModeEnabled then h.Health = math.huge end
        end)
    else
        hum.MaxHealth = 100
        hum.Health    = 100
    end
end

-- ============================================================
--  FEATURE: AUTO HEAL  (heals when HP drops below threshold%)
-- ============================================================
local AutoHealConn

local function SetAutoHeal(on)
    State.AutoHealEnabled = on
    DC(AutoHealConn) AutoHealConn = nil
    if on then
        AutoHealConn = RunService.Heartbeat:Connect(function()
            local hum = GetHum() if not hum then return end
            if hum.MaxHealth ~= math.huge and hum.Health / hum.MaxHealth * 100 < State.AutoHealPct then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end

-- ============================================================
--  FEATURE: INVISIBLE
-- ============================================================
local OrigTransparency = {}

local function SetInvisible(on)
    State.InvisEnabled = on
    local char = GetChar() if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then
                OrigTransparency[p] = p.Transparency
                p.Transparency = p.Name == "HumanoidRootPart" and 1 or 1
            else
                p.Transparency = OrigTransparency[p] or (p.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
    end
    if not on then OrigTransparency = {} end
end

-- ============================================================
--  FEATURE: GHOST MODE  (noclip + invisible)
-- ============================================================
local function SetGhostMode(on)
    State.GhostEnabled = on
    SetNoclip(on)
    SetInvisible(on)
end

-- ============================================================
--  FEATURE: RAGDOLL
-- ============================================================
local function SetRagdoll(on)
    State.RagdollEnabled = on
    local hum = GetHum() if not hum then return end
    if on then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    else
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- ============================================================
--  FEATURE: SPIN
-- ============================================================
local SpinConn

local function SetSpin(on)
    State.SpinEnabled = on
    DC(SpinConn) SpinConn = nil
    if on then
        SpinConn = RunService.Heartbeat:Connect(function(dt)
            local hrp = GetHRP()
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, State.SpinSpeed * dt, 0) end
        end)
    end
end

-- ============================================================
--  FEATURE: ESP
-- ============================================================
local function AddESP(player)
    if player == LocalPlayer then return end
    local function apply()
        local char = player.Character if not char then return end
        if ESPHighlights[player] then ESPHighlights[player]:Destroy() end
        local h = Instance.new("Highlight")
        h.FillColor           = Color3.fromRGB(255,80,80)
        h.OutlineColor        = Color3.fromRGB(255,255,255)
        h.FillTransparency    = 0.5
        h.OutlineTransparency = 0
        h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent              = char
        ESPHighlights[player] = h
    end
    apply()
    table.insert(Connections, player.CharacterAdded:Connect(function()
        if State.ESPEnabled then apply() end
    end))
end

local function RemoveESP(p)
    if ESPHighlights[p] then ESPHighlights[p]:Destroy() ESPHighlights[p] = nil end
end

local function SetESP(on)
    State.ESPEnabled = on
    if on then
        for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
        table.insert(Connections, Players.PlayerAdded:Connect(function(p)
            if State.ESPEnabled then AddESP(p) end
        end))
    else
        for _,p in ipairs(Players:GetPlayers()) do RemoveESP(p) end
    end
end

-- ============================================================
--  FEATURE: ANTI-GRAVITY
-- ============================================================
local OrigGravity = workspace.Gravity

local function SetAntiGrav(on)
    State.AntiGravEnabled = on
    workspace.Gravity = on and 10 or OrigGravity
end

-- ============================================================
--  FEATURE: TAP/CLICK TELEPORT
-- ============================================================
local TeleportOn  = false
local TeleportConn2

local function SetTeleport(on)
    TeleportOn = on
    DC(TeleportConn2) TeleportConn2 = nil
    if not on then return end
    if IsMobile then
        TeleportConn2 = UserInputService.TouchTap:Connect(function(touches)
            if not TeleportOn then return end
            local hrp = GetHRP() if not hrp or not touches[1] then return end
            local ray = workspace.CurrentCamera:ScreenPointToRay(touches[1].X, touches[1].Y)
            local par = RaycastParams.new()
            par.FilterDescendantsInstances = {GetChar()}
            par.FilterType = Enum.RaycastFilterType.Exclude
            local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, par)
            if res then hrp.CFrame = CFrame.new(res.Position + Vector3.new(0,3,0)) end
        end)
    else
        local mouse = LocalPlayer:GetMouse()
        TeleportConn2 = mouse.Button1Down:Connect(function()
            if not TeleportOn then return end
            local hrp = GetHRP()
            if hrp and mouse.Target then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
        end)
    end
end

-- ============================================================
--  FEATURE: LOOP TELEPORT TO SAVED POSITION
-- ============================================================
local LoopTPConn

local function SetLoopTP(on)
    State.LoopTPEnabled = on
    DC(LoopTPConn) LoopTPConn = nil
    if on and State.SavedCFrame then
        LoopTPConn = RunService.Heartbeat:Connect(function()
            local hrp = GetHRP()
            if hrp and State.SavedCFrame then hrp.CFrame = State.SavedCFrame end
        end)
    end
end

-- ============================================================
--  FEATURE: FULLBRIGHT
-- ============================================================
local OrigBrightness, OrigAmbient, OrigOutdoor

local function SetFullbright(on)
    State.FullbrightOn = on
    if on then
        OrigBrightness = Lighting.Brightness
        OrigAmbient    = Lighting.Ambient
        OrigOutdoor    = Lighting.OutdoorAmbient
        Lighting.Brightness     = 10
        Lighting.Ambient        = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness     = OrigBrightness or 1
        Lighting.Ambient        = OrigAmbient    or Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient = OrigOutdoor    or Color3.fromRGB(127,127,127)
    end
end

-- ============================================================
--  FEATURE: REMOVE FOG
-- ============================================================
local function SetRemoveFog(on)
    State.RemoveFogOn = on
    Lighting.FogEnd   = on and 9e8 or 10000
    Lighting.FogStart = on and 9e8 or 0
end

-- ============================================================
--  FEATURE: LOCK SUN
-- ============================================================
local LockSunConn

local function SetLockSun(on)
    State.LockSunOn = on
    DC(LockSunConn) LockSunConn = nil
    if on then
        State.LockedTime = Lighting.ClockTime
        LockSunConn = RunService.Heartbeat:Connect(function()
            if State.LockSunOn then Lighting.ClockTime = State.LockedTime end
        end)
    end
end

-- ============================================================
--  FEATURE: ANTI-AFK
-- ============================================================
local AntiAFKConn
local afkTimer = 0

local function SetAntiAFK(on)
    State.AntiAFKOn = on
    DC(AntiAFKConn) AntiAFKConn = nil
    afkTimer = 0
    if on then
        AntiAFKConn = RunService.Heartbeat:Connect(function(dt)
            afkTimer = afkTimer + dt
            if afkTimer >= 270 then -- every 4.5 minutes
                afkTimer = 0
                local hum = GetHum()
                if hum then hum.Jump = true end
            end
        end)
    end
end

-- ============================================================
--  FEATURE: CHAT COMMANDS
-- ============================================================
local function ParseCommands()
    LocalPlayer.Chatted:Connect(function(msg)
        if not State.ChatCmdsOn then return end
        local parts = {}
        for w in msg:gmatch("%S+") do table.insert(parts, w) end
        if #parts == 0 then return end
        local cmd = parts[1]:lower()

        if cmd == "/speed" and parts[2] then
            local n = tonumber(parts[2])
            if n then local h=GetHum() if h then h.WalkSpeed=n end end

        elseif cmd == "/fly" then
            SetFly(not State.FlyEnabled)

        elseif cmd == "/noclip" then
            SetNoclip(not State.NoclipEnabled)

        elseif cmd == "/god" then
            SetGodMode(not State.GodModeEnabled)

        elseif cmd == "/heal" then
            local h=GetHum() if h then h.Health = h.MaxHealth end

        elseif cmd == "/invis" then
            SetInvisible(not State.InvisEnabled)

        elseif cmd == "/bright" then
            SetFullbright(not State.FullbrightOn)

        elseif cmd == "/fog" then
            SetRemoveFog(not State.RemoveFogOn)

        elseif cmd == "/gravity" and parts[2] then
            local n = tonumber(parts[2])
            if n then workspace.Gravity = n end

        elseif cmd == "/time" and parts[2] then
            local n = tonumber(parts[2])
            if n then Lighting.ClockTime = n end

        elseif cmd == "/reset" then
            LocalPlayer:LoadCharacter()

        elseif cmd == "/spin" then
            SetSpin(not State.SpinEnabled)

        elseif cmd == "/ghost" then
            SetGhostMode(not State.GhostEnabled)

        elseif cmd == "/tp" and parts[2] then
            local target = Players:FindFirstChild(parts[2])
            if target and target.Character then
                local hrp2 = target.Character:FindFirstChild("HumanoidRootPart")
                local hrp  = GetHRP()
                if hrp and hrp2 then hrp.CFrame = hrp2.CFrame + Vector3.new(3,0,0) end
            end
        end
    end)
end

ParseCommands()

-- ============================================================
--  FEATURE: SPECTATE
-- ============================================================
local SpectateConn
local SpectateTarget = nil

local function SetSpectate(on, player)
    DC(SpectateConn) SpectateConn = nil
    SpectateTarget = nil
    if not on then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        return
    end
    SpectateTarget = player
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    SpectateConn = RunService.RenderStepped:Connect(function()
        if not SpectateTarget or not SpectateTarget.Character then return end
        local hrp = SpectateTarget.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        workspace.CurrentCamera.CFrame = hrp.CFrame * CFrame.new(0, 4, -10) * CFrame.Angles(0, math.pi, 0)
    end)
end

-- ============================================================
--  FEATURE: ANIMATION SPEED
-- ============================================================
local function ApplyAnimSpeed(speed)
    State.AnimSpeed = speed
    local hum = GetHum() if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") if not anim then return end
    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(speed)
    end
end

-- ============================================================
--  GUI CLEANUP
-- ============================================================
if LocalPlayer.PlayerGui:FindFirstChild("KaolinHub")    then LocalPlayer.PlayerGui:FindFirstChild("KaolinHub"):Destroy()    end
if LocalPlayer.PlayerGui:FindFirstChild("KaolinKeyGui") then LocalPlayer.PlayerGui:FindFirstChild("KaolinKeyGui"):Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("KaolinHud")    then LocalPlayer.PlayerGui:FindFirstChild("KaolinHud"):Destroy()    end

-- ============================================================
--  HUD GUI  (FPS + Position display - always visible corner)
-- ============================================================
local HudGui = Instance.new("ScreenGui")
HudGui.Name             = "KaolinHud"
HudGui.ResetOnSpawn     = false
HudGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
HudGui.Parent           = LocalPlayer.PlayerGui

local HudHolder = Instance.new("Frame")
HudHolder.Size            = UDim2.new(0,180,0,44)
HudHolder.Position        = UDim2.new(1,-188,0,8)
HudHolder.BackgroundTransparency = 1
HudHolder.Parent          = HudGui

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size             = UDim2.new(1,0,0,20)
FpsLabel.Position         = UDim2.new(0,0,0,0)
FpsLabel.BackgroundColor3 = Color3.fromRGB(10,10,14)
FpsLabel.BackgroundTransparency = 0.3
FpsLabel.TextColor3       = Color3.fromRGB(200,160,80)
FpsLabel.TextSize         = 11
FpsLabel.Font             = Enum.Font.Code
FpsLabel.Text             = "FPS: --"
FpsLabel.Visible          = false
FpsLabel.Parent           = HudHolder
Instance.new("UICorner",FpsLabel).CornerRadius = UDim.new(0,4)

local PosLabel = Instance.new("TextLabel")
PosLabel.Size             = UDim2.new(1,0,0,20)
PosLabel.Position         = UDim2.new(0,0,0,24)
PosLabel.BackgroundColor3 = Color3.fromRGB(10,10,14)
PosLabel.BackgroundTransparency = 0.3
PosLabel.TextColor3       = Color3.fromRGB(160,200,160)
PosLabel.TextSize         = 10
PosLabel.Font             = Enum.Font.Code
PosLabel.Text             = "X:0 Y:0 Z:0"
PosLabel.Visible          = false
PosLabel.Parent           = HudHolder
Instance.new("UICorner",PosLabel).CornerRadius = UDim.new(0,4)

-- HUD update loop
local fpsAccum, fpsCount = 0, 0
RunService.Heartbeat:Connect(function(dt)
    fpsAccum  = fpsAccum + dt
    fpsCount  = fpsCount + 1
    if fpsAccum >= 1 then
        if FpsLabel.Visible then FpsLabel.Text = "FPS: " .. fpsCount end
        fpsAccum = 0 fpsCount = 0
    end
    if PosLabel.Visible then
        local hrp = GetHRP()
        if hrp then
            local p = hrp.Position
            PosLabel.Text = string.format("X:%.0f Y:%.0f Z:%.0f", p.X, p.Y, p.Z)
        end
    end
end)

-- ============================================================
--  THEME
-- ============================================================
local T = {
    Accent    = Color3.fromRGB(200,160,80),
    AccentDk  = Color3.fromRGB(160,120,50),
    BgRoot    = Color3.fromRGB(15,15,20),
    BgDark    = Color3.fromRGB(10,10,14),
    BgCard    = Color3.fromRGB(24,24,32),
    BgContent = Color3.fromRGB(19,19,26),
    TextMain  = Color3.fromRGB(225,225,230),
    TextDim   = Color3.fromRGB(95,95,112),
    TextOn    = Color3.fromRGB(15,15,20),
    TogOff    = Color3.fromRGB(50,50,62),
    SlTrack   = Color3.fromRGB(40,40,52),
    Red       = Color3.fromRGB(220,70,70),
    Green     = Color3.fromRGB(70,200,110),
}

local GUI_W = IsMobile and 410 or 530
local GUI_H = IsMobile and 490 or 410
local TAB_W = IsMobile and 84  or 112
local TW_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_BACK = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ============================================================
--  MAIN HUB SCREENGUI  (starts invisible until key verified)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "KaolinHub"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset   = true
ScreenGui.Enabled          = false   -- hidden until key passes
ScreenGui.Parent           = LocalPlayer.PlayerGui

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size             = UDim2.new(0,GUI_W,0,GUI_H)
Main.Position         = UDim2.new(0.5,-GUI_W/2,0.5,-GUI_H/2)
Main.BackgroundColor3 = T.BgRoot
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Main.Parent           = ScreenGui
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)
local ms = Instance.new("UIStroke",Main)
ms.Color = T.Accent ms.Thickness = 2

-- TITLE BAR
local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1,0,0,46)
TBar.BackgroundColor3 = T.Accent
TBar.BorderSizePixel  = 0
TBar.Parent           = Main
Instance.new("UICorner",TBar).CornerRadius = UDim.new(0,10)
local TBarPatch = Instance.new("Frame")
TBarPatch.Size = UDim2.new(1,0,0,12) TBarPatch.Position = UDim2.new(0,0,1,-12)
TBarPatch.BackgroundColor3 = T.Accent TBarPatch.BorderSizePixel = 0 TBarPatch.Parent = TBar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text = E.BRICK.."  "..CFG.Title
TitleLbl.Size = UDim2.new(1,-80,0,30) TitleLbl.Position = UDim2.new(0,12,0,4)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3 = T.TextOn TitleLbl.TextSize = IsMobile and 15 or 18
TitleLbl.Font = Enum.Font.GothamBold TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TBar

local SubLbl = Instance.new("TextLabel")
SubLbl.Text = CFG.Version.."  |  by "..CFG.Creator
SubLbl.Size = UDim2.new(1,-80,0,14) SubLbl.Position = UDim2.new(0,12,0,30)
SubLbl.BackgroundTransparency = 1
SubLbl.TextColor3 = T.TextOn SubLbl.TextTransparency = 0.35
SubLbl.TextSize = 9 SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left SubLbl.Parent = TBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0,28,0,28) MinBtn.Position = UDim2.new(1,-64,0,9)
MinBtn.BackgroundColor3 = T.BgRoot MinBtn.Text = E.DASH
MinBtn.TextColor3 = Color3.fromRGB(220,220,220) MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold MinBtn.BorderSizePixel = 0 MinBtn.Parent = TBar
Instance.new("UICorner",MinBtn).CornerRadius = UDim.new(1,0)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28) CloseBtn.Position = UDim2.new(1,-32,0,9)
CloseBtn.BackgroundColor3 = T.BgRoot CloseBtn.Text = E.CROSS
CloseBtn.TextColor3 = Color3.fromRGB(220,220,220) CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold CloseBtn.BorderSizePixel = 0 CloseBtn.Parent = TBar
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(1,0)

-- RESTORE BUTTON
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0,48,0,48) RestoreBtn.Position = UDim2.new(0,8,0.5,-24)
RestoreBtn.BackgroundColor3 = T.Accent RestoreBtn.Text = E.BRICK
RestoreBtn.TextSize = 22 RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.BorderSizePixel = 0 RestoreBtn.Visible = false RestoreBtn.ZIndex = 10
RestoreBtn.Parent = ScreenGui
Instance.new("UICorner",RestoreBtn).CornerRadius = UDim.new(0,12)

-- CLOSE / MINIMISE / RESTORE LOGIC
local minimised = false
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false RestoreBtn.Visible = true
end)
RestoreBtn.MouseButton1Click:Connect(function()
    Main.Visible = true RestoreBtn.Visible = false
end)
MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    Tw(Main, {Size = minimised and UDim2.new(0,GUI_W,0,46) or UDim2.new(0,GUI_W,0,GUI_H)}, TW_FAST)
    MinBtn.Text = minimised and E.STAR or E.DASH
end)

-- DRAG
do
    local dragging, dragStart, startPos = false, nil, nil
    local function dBegin(pos) dragging=true dragStart=pos startPos=Main.Position end
    local function dMove(pos)
        if not dragging then return end
        local d=pos-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
    local function dEnd() dragging=false end
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dBegin(Vector2.new(i.Position.X,i.Position.Y)) end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dEnd() end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dMove(Vector2.new(i.Position.X,i.Position.Y)) end
    end)
end

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,TAB_W,1,-46) Sidebar.Position = UDim2.new(0,0,0,46)
Sidebar.BackgroundColor3 = T.BgDark Sidebar.BorderSizePixel = 0 Sidebar.Parent = Main
local SL = Instance.new("UIListLayout",Sidebar)
SL.Padding = UDim.new(0,4) SL.SortOrder = Enum.SortOrder.LayoutOrder
local SP = Instance.new("UIPadding",Sidebar)
SP.PaddingTop=UDim.new(0,8) SP.PaddingLeft=UDim.new(0,5) SP.PaddingRight=UDim.new(0,5)

-- CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1,-TAB_W,1,-46) ContentArea.Position = UDim2.new(0,TAB_W,0,46)
ContentArea.BackgroundColor3 = T.BgContent ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true ContentArea.Parent = Main
local Div = Instance.new("Frame",ContentArea)
Div.Size = UDim2.new(0,1,1,0) Div.BackgroundColor3 = T.Accent Div.BorderSizePixel = 0

-- ============================================================
--  COMPONENT BUILDERS
-- ============================================================
local AllBtns, AllPages = {}, {}
local SectionOrder = 0

local function NewPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1,-10,1,0) pg.Position = UDim2.new(0,10,0,0)
    pg.BackgroundTransparency = 1 pg.BorderSizePixel = 0
    pg.ScrollBarThickness = IsMobile and 5 or 3
    pg.ScrollBarImageColor3 = T.Accent
    pg.CanvasSize = UDim2.new(0,0,0,0) pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false pg.Parent = ContentArea
    local l=Instance.new("UIListLayout",pg) l.Padding=UDim.new(0,8) l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",pg)
    p.PaddingTop=UDim.new(0,10) p.PaddingBottom=UDim.new(0,10) p.PaddingRight=UDim.new(0,4)
    return pg
end

local function NewTabBtn(icon, label, page, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,IsMobile and 50 or 42)
    btn.BackgroundColor3 = T.BgRoot
    btn.Text = icon.."\n"..label
    btn.TextColor3 = T.TextDim btn.TextSize = IsMobile and 9 or 10
    btn.Font = Enum.Font.GothamBold btn.TextWrapped = true
    btn.BorderSizePixel = 0 btn.LayoutOrder = order btn.Parent = Sidebar
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        for _,b in ipairs(AllBtns) do b.BackgroundColor3=T.BgRoot b.TextColor3=T.TextDim end
        for _,p in ipairs(AllPages) do p.Visible=false end
        btn.BackgroundColor3 = Color3.fromRGB(28,25,16) btn.TextColor3 = T.Accent
        page.Visible = true
    end)
    table.insert(AllBtns,btn) table.insert(AllPages,page)
    return btn
end

local function NewSection(page, text)
    SectionOrder = SectionOrder + 1
    local l = Instance.new("TextLabel")
    l.Text = "  "..text l.Size = UDim2.new(1,0,0,22)
    l.BackgroundColor3 = T.Accent l.BackgroundTransparency = 0.82
    l.TextColor3 = T.Accent l.TextSize = 10 l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left l.BorderSizePixel = 0
    l.LayoutOrder = SectionOrder l.Parent = page
    Instance.new("UICorner",l).CornerRadius = UDim.new(0,6)
end

local function NewSep(page)
    SectionOrder = SectionOrder + 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,1) f.BackgroundColor3 = Color3.fromRGB(45,45,58)
    f.BorderSizePixel = 0 f.LayoutOrder = SectionOrder f.Parent = page
end

local function NewLabel(page, text)
    SectionOrder = SectionOrder + 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,34) f.BackgroundColor3 = T.BgCard
    f.BorderSizePixel = 0 f.LayoutOrder = SectionOrder f.Parent = page
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
    local l = Instance.new("TextLabel")
    l.Text = text l.Size = UDim2.new(1,-16,1,0) l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1 l.TextColor3 = T.TextDim
    l.TextSize = IsMobile and 10 or 11 l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left l.TextWrapped = true l.Parent = f
    return { Set = function(s) l.Text = s end }
end

local function NewToggle(page, label, desc, cb)
    SectionOrder = SectionOrder + 1
    local H = IsMobile and 64 or 56
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,H) row.BackgroundColor3 = T.BgCard
    row.BorderSizePixel = 0 row.LayoutOrder = SectionOrder row.Parent = page
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local nl = Instance.new("TextLabel")
    nl.Text = label nl.Size = UDim2.new(1,-70,0,22) nl.Position = UDim2.new(0,12,0,8)
    nl.BackgroundTransparency=1 nl.TextColor3=T.TextMain nl.TextSize=IsMobile and 12 or 13
    nl.Font=Enum.Font.GothamBold nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=row
    if desc then
        local dl=Instance.new("TextLabel")
        dl.Text=desc dl.Size=UDim2.new(1,-70,0,14) dl.Position=UDim2.new(0,12,0,32)
        dl.BackgroundTransparency=1 dl.TextColor3=T.TextDim dl.TextSize=9
        dl.Font=Enum.Font.Gotham dl.TextXAlignment=Enum.TextXAlignment.Left dl.Parent=row
    end
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,44,0,24) pill.Position=UDim2.new(1,-56,0.5,-12)
    pill.BackgroundColor3=T.TogOff pill.BorderSizePixel=0 pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,18,0,18) dot.Position=UDim2.new(0,3,0.5,-9)
    dot.BackgroundColor3=Color3.fromRGB(210,210,210) dot.BorderSizePixel=0 dot.Parent=pill
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,1,0) hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=2 hit.Parent=row
    local enabled=false
    local function SetState(v, silent)
        enabled=v
        Tw(dot,{Position=enabled and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},TW_FAST)
        Tw(pill,{BackgroundColor3=enabled and T.Accent or T.TogOff},TW_FAST)
        if not silent then cb(enabled) end
    end
    hit.MouseButton1Click:Connect(function() SetState(not enabled) end)
    hit.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=Color3.fromRGB(30,30,42)},TW_FAST) end)
    hit.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=T.BgCard},TW_FAST) end)
    return { Set=function(v) SetState(v,false) end, Get=function() return enabled end }
end

local function NewSlider(page, label, minV, maxV, defV, suffix, cb)
    SectionOrder = SectionOrder + 1
    suffix = suffix or ""
    local TH = IsMobile and 9 or 7
    local HS = IsMobile and 22 or 16
    local row = Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,66) row.BackgroundColor3=T.BgCard
    row.BorderSizePixel=0 row.LayoutOrder=SectionOrder row.Parent=page
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local nl=Instance.new("TextLabel")
    nl.Text=label nl.Size=UDim2.new(0.65,0,0,20) nl.Position=UDim2.new(0,12,0,8)
    nl.BackgroundTransparency=1 nl.TextColor3=T.TextMain nl.TextSize=IsMobile and 11 or 12
    nl.Font=Enum.Font.GothamBold nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=row
    local vl=Instance.new("TextLabel")
    vl.Text=string.format("%.10g",defV)..suffix vl.Size=UDim2.new(0.35,-12,0,20)
    vl.Position=UDim2.new(0.65,0,0,8) vl.BackgroundTransparency=1 vl.TextColor3=T.Accent
    vl.TextSize=IsMobile and 11 or 12 vl.Font=Enum.Font.GothamBold
    vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=row
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,TH) track.Position=UDim2.new(0,12,0,42)
    track.BackgroundColor3=T.SlTrack track.BorderSizePixel=0 track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct0=(defV-minV)/(maxV-minV)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct0,0,1,0) fill.BackgroundColor3=T.Accent fill.BorderSizePixel=0 fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local handle=Instance.new("Frame")
    handle.Size=UDim2.new(0,HS,0,HS) handle.AnchorPoint=Vector2.new(0.5,0.5)
    handle.Position=UDim2.new(pct0,0,0.5,0) handle.BackgroundColor3=Color3.fromRGB(255,255,255)
    handle.BorderSizePixel=0 handle.Parent=track
    Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)
    local curVal=defV local dragging=false
    local function updX(x)
        local abs=track.AbsolutePosition local sz=track.AbsoluteSize
        local rel=math.clamp((x-abs.X)/sz.X,0,1)
        curVal=math.floor((minV+rel*(maxV-minV))*10)/10
        vl.Text=string.format("%.10g",curVal)..suffix
        fill.Size=UDim2.new(rel,0,1,0) handle.Position=UDim2.new(rel,0,0.5,0)
        cb(curVal)
    end
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,0,46) hit.Position=UDim2.new(0,0,0,26)
    hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=2 hit.Parent=row
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true updX(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then updX(i.Position.X) end
    end)
    return {
        Set=function(v)
            curVal=math.clamp(v,minV,maxV)
            local rel=(curVal-minV)/(maxV-minV)
            vl.Text=string.format("%.10g",curVal)..suffix
            fill.Size=UDim2.new(rel,0,1,0) handle.Position=UDim2.new(rel,0,0.5,0)
            cb(curVal)
        end,
        Get=function() return curVal end
    }
end

local function NewButton(page, label, desc, cb)
    SectionOrder = SectionOrder + 1
    local H = IsMobile and (desc and 58 or 46) or (desc and 52 or 40)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,H) btn.BackgroundColor3=Color3.fromRGB(28,28,40)
    btn.Text="" btn.BorderSizePixel=0 btn.LayoutOrder=SectionOrder btn.Parent=page
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",btn) stroke.Color=T.Accent stroke.Thickness=1
    local nl=Instance.new("TextLabel")
    nl.Text=label nl.Size=UDim2.new(1,-40,0,20)
    nl.Position=UDim2.new(0,12,desc and 0 or 0.5,desc and 8 or -10)
    nl.BackgroundTransparency=1 nl.TextColor3=T.Accent
    nl.TextSize=IsMobile and 12 or 13 nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=btn
    if desc then
        local dl=Instance.new("TextLabel")
        dl.Text=desc dl.Size=UDim2.new(1,-40,0,14) dl.Position=UDim2.new(0,12,0,30)
        dl.BackgroundTransparency=1 dl.TextColor3=T.TextDim dl.TextSize=9
        dl.Font=Enum.Font.Gotham dl.TextXAlignment=Enum.TextXAlignment.Left dl.Parent=btn
    end
    local al=Instance.new("TextLabel")
    al.Text=E.RIGHT al.Size=UDim2.new(0,20,1,0) al.Position=UDim2.new(1,-28,0,0)
    al.BackgroundTransparency=1 al.TextColor3=T.Accent al.TextSize=14
    al.Font=Enum.Font.GothamBold al.Parent=btn
    btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(38,34,18)},TW_FAST) end)
    btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(28,28,40)},TW_FAST) end)
    btn.MouseButton1Click:Connect(function()
        Tw(btn,{BackgroundColor3=T.Accent},TweenInfo.new(0.08))
        task.delay(0.12,function() Tw(btn,{BackgroundColor3=Color3.fromRGB(28,28,40)},TW_FAST) end)
        cb()
    end)
end

-- Dropdown for player selection
local function NewDropdown(page, label, getOptions, cb)
    SectionOrder = SectionOrder + 1
    local selected = "None"
    local isOpen   = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,58) container.BackgroundColor3 = T.BgCard
    container.BorderSizePixel = 0 container.LayoutOrder = SectionOrder
    container.ClipsDescendants = true container.Parent = page
    Instance.new("UICorner",container).CornerRadius = UDim.new(0,8)

    local nl = Instance.new("TextLabel")
    nl.Text = label nl.Size = UDim2.new(1,-16,0,18) nl.Position = UDim2.new(0,10,0,6)
    nl.BackgroundTransparency=1 nl.TextColor3=T.TextMain nl.TextSize=IsMobile and 11 or 12
    nl.Font=Enum.Font.GothamBold nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=container

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1,-20,0,26) header.Position = UDim2.new(0,10,0,26)
    header.BackgroundColor3 = Color3.fromRGB(22,22,30) header.Text = ""
    header.BorderSizePixel = 0 header.Parent = container
    Instance.new("UICorner",header).CornerRadius = UDim.new(0,6)

    local selLbl = Instance.new("TextLabel")
    selLbl.Text = selected selLbl.Size = UDim2.new(1,-30,1,0) selLbl.Position = UDim2.new(0,8,0,0)
    selLbl.BackgroundTransparency=1 selLbl.TextColor3=T.TextMain selLbl.TextSize=IsMobile and 10 or 11
    selLbl.Font=Enum.Font.Gotham selLbl.TextXAlignment=Enum.TextXAlignment.Left selLbl.Parent=header

    local arrowLbl = Instance.new("TextLabel")
    arrowLbl.Text = E.FALL arrowLbl.Size = UDim2.new(0,20,1,0) arrowLbl.Position = UDim2.new(1,-22,0,0)
    arrowLbl.BackgroundTransparency=1 arrowLbl.TextColor3=T.Accent arrowLbl.TextSize=12
    arrowLbl.Font=Enum.Font.GothamBold arrowLbl.Parent=header

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1,-20,0,0) listFrame.Position = UDim2.new(0,10,0,56)
    listFrame.BackgroundColor3 = Color3.fromRGB(20,20,28) listFrame.BorderSizePixel=0
    listFrame.ClipsDescendants=true listFrame.Parent=container
    Instance.new("UICorner",listFrame).CornerRadius=UDim.new(0,6)
    local listLayout = Instance.new("UIListLayout",listFrame)
    listLayout.Padding=UDim.new(0,2) listLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local listPad=Instance.new("UIPadding",listFrame)
    listPad.PaddingTop=UDim.new(0,4) listPad.PaddingBottom=UDim.new(0,4)
    listPad.PaddingLeft=UDim.new(0,4) listPad.PaddingRight=UDim.new(0,4)

    local ITEM_H = IsMobile and 34 or 28

    local function BuildList()
        for _,c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local opts = getOptions()
        for _, opt in ipairs(opts) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1,0,0,ITEM_H)
            item.BackgroundColor3 = Color3.fromRGB(28,28,38) item.Text = "  "..opt
            item.TextColor3 = opt == selected and T.Accent or T.TextMain
            item.TextSize = IsMobile and 10 or 11 item.Font = Enum.Font.Gotham
            item.TextXAlignment = Enum.TextXAlignment.Left item.BorderSizePixel = 0
            item.Parent = listFrame
            Instance.new("UICorner",item).CornerRadius=UDim.new(0,4)
            item.MouseButton1Click:Connect(function()
                selected = opt selLbl.Text = opt cb(opt)
                BuildList()
                isOpen = false arrowLbl.Text = E.FALL
                Tw(container,{Size=UDim2.new(1,0,0,58)},TW_FAST)
                Tw(listFrame,{Size=UDim2.new(1,-20,0,0)},TW_FAST)
            end)
        end
    end
    BuildList()

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then BuildList() end
        local opts = getOptions()
        local h = math.min(#opts, 5) * (ITEM_H+2) + 8
        arrowLbl.Text = isOpen and E.RISE or E.FALL
        if isOpen then
            Tw(container,{Size=UDim2.new(1,0,0,58+h+6)},TW_FAST)
            Tw(listFrame,{Size=UDim2.new(1,-20,0,h)},TW_FAST)
        else
            Tw(container,{Size=UDim2.new(1,0,0,58)},TW_FAST)
            Tw(listFrame,{Size=UDim2.new(1,-20,0,0)},TW_FAST)
        end
    end)

    return {
        GetSelected = function() return selected end,
        Refresh     = function() BuildList() end,
        Set         = function(v) selected=v selLbl.Text=v BuildList() end,
    }
end

-- ============================================================
--  BUILD: MOVEMENT TAB
-- ============================================================
local MovPage = NewPage()
local MovBtn  = NewTabBtn(E.RUN,    "Move",   MovPage, 1)

NewSection(MovPage, "LOCOMOTION")
local flyTgl     = NewToggle(MovPage, "Fly",    IsMobile and "Use D-pad below" or "WASD + Space/Shift", function(v) SetFly(v) end)
local noclipTgl  = NewToggle(MovPage, "Noclip", "Walk through walls",   function(v) SetNoclip(v) end)
local infJmpTgl  = NewToggle(MovPage, "Infinite Jump", "Jump endlessly mid-air", function(v) SetInfJump(v) end)
local sprintTgl  = NewToggle(MovPage, "Sprint", IsMobile and "Increases speed (slider below)" or "Hold LeftShift to sprint", function(v) SetSprint(v) end)
local antigravTgl= NewToggle(MovPage, "Anti-Gravity",  "Reduces gravity to 10", function(v) SetAntiGrav(v) end)
local noFallTgl  = NewToggle(MovPage, "No Fall Damage","Auto-heals on land",    function(v) SetNoFallDmg(v) end)
local antiVoidTgl= NewToggle(MovPage, "Anti-Void",     "Snaps back if you fall into void", function(v) SetAntiVoid(v) end)
local tpTgl      = NewToggle(MovPage, IsMobile and "Tap Teleport" or "Click Teleport", IsMobile and "Tap surface to teleport" or "Click surface to teleport", function(v) SetTeleport(v) end)

NewSep(MovPage)
NewSection(MovPage, "POSITION")
NewButton(MovPage, E.SAVE.."  Save Position", "Saves your current position", function()
    local hrp = GetHRP()
    if hrp then State.SavedCFrame = hrp.CFrame end
end)
NewButton(MovPage, E.MAP.."  Go To Saved", "Teleports to your saved position", function()
    local hrp = GetHRP()
    if hrp and State.SavedCFrame then hrp.CFrame = State.SavedCFrame end
end)
local loopTpTgl = NewToggle(MovPage, "Loop TP", "Keeps teleporting to saved position", function(v) SetLoopTP(v) end)

NewSep(MovPage)
NewSection(MovPage, "SPEED & JUMP")
local speedSld = NewSlider(MovPage, "Walk Speed", 16, 250, 50, " sp", function(v) State.WalkSpeed=v if State.SpeedEnabled then local h=GetHum() if h then h.WalkSpeed=v end end end)
local speedTgl = NewToggle(MovPage, "Speed Boost", "Apply custom walk speed", function(v) State.SpeedEnabled=v local h=GetHum() if h then h.WalkSpeed=v and State.WalkSpeed or 16 end end)
local jumpSld  = NewSlider(MovPage, "Jump Power",  50, 500, 100, "", function(v) State.JumpPower=v local h=GetHum() if h then h.JumpPower=v end end)
local flySpSld = NewSlider(MovPage, "Fly Speed",   10, 300, 60,  " sp", function(v) State.FlySpeed=v end)
local sprintSld= NewSlider(MovPage, "Sprint Speed",20, 300, 50,  " sp", function(v) State.SprintSpeed=v end)
NewButton(MovPage, "Reset Movement", "Restores defaults", function()
    speedSld.Set(50) jumpSld.Set(100) flySpSld.Set(60)
    speedTgl.Set(false) sprintTgl.Set(false) antigravTgl.Set(false)
    workspace.Gravity = OrigGravity
end)

-- ============================================================
--  BUILD: PLAYER TAB
-- ============================================================
local PlrPage = NewPage()
local PlrBtn  = NewTabBtn(E.PERSON, "Player", PlrPage, 2)

NewSection(PlrPage, "HEALTH")
local godTgl      = NewToggle(PlrPage, E.SHIELD.." God Mode",    "Infinite health",         function(v) SetGodMode(v) end)
local autoHealTgl = NewToggle(PlrPage, E.HOSP.." Auto Heal",   "Heals when HP is low",     function(v) SetAutoHeal(v) end)
local healSld     = NewSlider(PlrPage, "Heal Threshold", 10, 90, 30, "%", function(v) State.AutoHealPct=v end)
NewButton(PlrPage, E.HOSP.."  Full Heal Now", "Instantly heals to full", function()
    local h=GetHum() if h then h.Health=h.MaxHealth end
end)

NewSep(PlrPage)
NewSection(PlrPage, "VISUALS")
local espTgl     = NewToggle(PlrPage, E.EYE.." ESP Highlights",  "Red outline on all players", function(v) SetESP(v) end)
local invisTgl   = NewToggle(PlrPage, E.EYE.." Invisible",        "Makes you invisible",         function(v) SetInvisible(v) end)
local ghostTgl   = NewToggle(PlrPage, E.SKULL.." Ghost Mode",   "Invisible + Noclip",          function(v) SetGhostMode(v) end)

NewSep(PlrPage)
NewSection(PlrPage, "PHYSICS")
local ragdollTgl = NewToggle(PlrPage, "Ragdoll",    "Physics-based ragdoll",    function(v) SetRagdoll(v) end)
local spinTgl    = NewToggle(PlrPage, E.SPIN.." Spin",      "Spin your character",      function(v) SetSpin(v) end)
local spinSld    = NewSlider(PlrPage, "Spin Speed", 1, 20, 3, "x", function(v) State.SpinSpeed=v end)

NewSep(PlrPage)
NewSection(PlrPage, "ANIMATION")
local animSld = NewSlider(PlrPage, "Animation Speed", 0, 3, 1, "x", function(v) ApplyAnimSpeed(v) end)
NewButton(PlrPage, "Reset Animation Speed", nil, function() animSld.Set(1) end)

NewSep(PlrPage)
NewSection(PlrPage, "CHARACTER")
NewSlider(PlrPage, "Head Size", 0.5, 5, 1, "x", function(v)
    local c=GetChar() if c and c:FindFirstChild("Head") then c.Head.Size=Vector3.new(v,v,v) end
end)
NewSlider(PlrPage, "Body Scale", 0.5, 3, 1, "x", function(v)
    local h=GetHum() if not h then return end
    for _,c in ipairs(h:GetChildren()) do
        if c:IsA("NumberValue") and c.Name:find("Scale") then c.Value=v end
    end
end)
NewButton(PlrPage, "Remove Accessories", "Removes hats, tools, etc.", function()
    local c=GetChar() if not c then return end
    for _,a in ipairs(c:GetChildren()) do
        if a:IsA("Accessory") then a:Destroy() end
    end
end)
NewButton(PlrPage, "Reset Character", "Respawn to restore accessories", function()
    LocalPlayer:LoadCharacter()
end)

-- ============================================================
--  BUILD: WORLD TAB
-- ============================================================
local WldPage = NewPage()
local WldBtn  = NewTabBtn(E.EARTH,  "World",  WldPage, 3)

NewSection(WldPage, "LIGHTING")
local timeSld      = NewSlider(WldPage, "Time of Day", 0, 24, 14, "h", function(v) Lighting.ClockTime=v end)
local lockSunTgl   = NewToggle(WldPage, E.STAR.." Lock Sun",    "Freeze current time",            function(v) SetLockSun(v) end)
local brightTgl    = NewToggle(WldPage, E.FLASH.." Fullbright", "Max ambient lighting",           function(v) SetFullbright(v) end)
NewSlider(WldPage, "Brightness", 0, 5, 1, "", function(v) Lighting.Brightness=v end)

NewSep(WldPage)
NewSection(WldPage, "ATMOSPHERE")
NewSlider(WldPage, "Fog End",  100, 50000, 10000, "", function(v) Lighting.FogEnd=v end)
local removeFogTgl = NewToggle(WldPage, "Remove Fog", "Sets fog end to maximum",       function(v) SetRemoveFog(v) end)
NewToggle(WldPage, "Rainbow Ambient", "Cycles sky ambient color",  function(v)
    if v then
        local hue=0
        local rc=RunService.Heartbeat:Connect(function(dt)
            if not v then return end
            hue=(hue+dt*0.05)%1
            Lighting.Ambient=Color3.fromHSV(hue,0.6,0.9)
            Lighting.OutdoorAmbient=Color3.fromHSV((hue+0.3)%1,0.5,0.8)
        end)
        table.insert(Connections,rc)
    else
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end)

NewSep(WldPage)
NewSection(WldPage, "PHYSICS")
NewSlider(WldPage, "Gravity", 5, 500, 196, "", function(v) workspace.Gravity=v end)
NewButton(WldPage, "Reset Gravity", nil, function() workspace.Gravity=OrigGravity end)

NewSep(WldPage)
NewSection(WldPage, "PRESETS")
NewButton(WldPage, E.STAR.."  Golden Hour", nil, function()
    Lighting.ClockTime=18 Lighting.Brightness=1.5
end)
NewButton(WldPage, "Dark Night", nil, function()
    Lighting.ClockTime=2 Lighting.Brightness=0.4
end)
NewButton(WldPage, "Foggy Storm", nil, function()
    Lighting.ClockTime=10 Lighting.Brightness=0.3 Lighting.FogEnd=400
end)
NewButton(WldPage, "Clear Day (Reset)", nil, function()
    Lighting.ClockTime=14 Lighting.Brightness=1
    Lighting.FogEnd=10000 Lighting.FogStart=0
    Lighting.Ambient=Color3.fromRGB(127,127,127)
    Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    workspace.Gravity=OrigGravity
end)

-- ============================================================
--  BUILD: PLAYERS TAB
-- ============================================================
local PlsPage = NewPage()
local PlsBtn  = NewTabBtn(E.PEOPLE, "Players", PlsPage, 4)

NewSection(PlsPage, "SELECT PLAYER")

local function GetPlayerNames()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then names = {"(no other players)"} end
    return names
end

local playerDrop = NewDropdown(PlsPage, E.PEOPLE.." Select Player", GetPlayerNames, function(name) end)

NewButton(PlsPage, "Refresh Player List", "Updates the dropdown", function()
    playerDrop.Refresh()
end)

NewSep(PlsPage)
NewSection(PlsPage, "ACTIONS")

NewButton(PlsPage, E.MAP.."  Teleport To Player", "Teleports you to selected player", function()
    local name = playerDrop.GetSelected()
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local hrp2 = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = GetHRP()
        if hrp and hrp2 then hrp.CFrame = hrp2.CFrame + Vector3.new(3,0,0) end
    end
end)

local spectateTgl = NewToggle(PlsPage, E.EYE.." Spectate Player", "Camera follows selected player", function(v)
    local name = playerDrop.GetSelected()
    local target = Players:FindFirstChild(name)
    if v and target then
        SetSpectate(true, target)
    else
        SetSpectate(false, nil)
    end
end)

NewButton(PlsPage, "Copy Player Position", "Saves selected player's position", function()
    local name = playerDrop.GetSelected()
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local hrp2 = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp2 then State.SavedCFrame = hrp2.CFrame end
    end
end)

NewSep(PlsPage)
NewSection(PlsPage, "INFO")
NewLabel(PlsPage, "Refresh the list after players join/leave. Spectate changes camera mode - disable it to get control back.")

-- ============================================================
--  BUILD: MISC TAB
-- ============================================================
local MscPage = NewPage()
local MscBtn  = NewTabBtn(E.GEAR,   "Misc",   MscPage, 5)

NewSection(MscPage, "UTILITY")
NewToggle(MscPage, "Anti-AFK", "Prevents AFK kick (~4.5 min intervals)", function(v) SetAntiAFK(v) end)
NewToggle(MscPage, "Hide HUD", "Hides Roblox core UI",                   function(v)
    pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not v) end)
end)
NewToggle(MscPage, "FPS Counter", "Shows FPS in top-right corner",       function(v) FpsLabel.Visible = v State.FpsDisplayOn=v end)
NewToggle(MscPage, "Position HUD","Shows XYZ coords in top-right",       function(v) PosLabel.Visible = v State.PosDisplayOn=v end)

NewSep(MscPage)
NewSection(MscPage, E.CHAT.." CHAT COMMANDS")
NewToggle(MscPage, "Enable Chat Commands", "Type commands in Roblox chat", function(v) State.ChatCmdsOn=v end)

SectionOrder = SectionOrder + 1
local cmdFrame = Instance.new("Frame")
cmdFrame.Size = UDim2.new(1,0,0,IsMobile and 188 or 168)
cmdFrame.BackgroundColor3 = T.BgCard cmdFrame.BorderSizePixel=0
cmdFrame.LayoutOrder=SectionOrder cmdFrame.Parent=MscPage
Instance.new("UICorner",cmdFrame).CornerRadius=UDim.new(0,8)
local cmdLbl = Instance.new("TextLabel")
cmdLbl.Size=UDim2.new(1,-16,1,-8) cmdLbl.Position=UDim2.new(0,8,0,6)
cmdLbl.BackgroundTransparency=1 cmdLbl.TextColor3=Color3.fromRGB(160,160,180)
cmdLbl.TextSize=IsMobile and 9 or 10 cmdLbl.Font=Enum.Font.Code
cmdLbl.TextWrapped=true cmdLbl.TextXAlignment=Enum.TextXAlignment.Left
cmdLbl.TextYAlignment=Enum.TextYAlignment.Top
cmdLbl.Text =
    "/speed [n]    - set walk speed\n"..
    "/fly           - toggle fly\n"..
    "/noclip        - toggle noclip\n"..
    "/god           - toggle god mode\n"..
    "/heal          - full heal\n"..
    "/invis         - toggle invisible\n"..
    "/ghost         - invisible + noclip\n"..
    "/spin          - toggle spin\n"..
    "/bright        - toggle fullbright\n"..
    "/fog           - toggle remove fog\n"..
    "/gravity [n]   - set gravity\n"..
    "/time [0-24]   - set time of day\n"..
    "/tp [name]     - teleport to player\n"..
    "/reset         - reset your character"
cmdLbl.Parent=cmdFrame

NewSep(MscPage)
NewSection(MscPage, IsMobile and "MOBILE TIPS" or "PC KEYBINDS")
SectionOrder = SectionOrder + 1
local kbFrame = Instance.new("Frame")
kbFrame.Size = UDim2.new(1,0,0,IsMobile and 80 or 68)
kbFrame.BackgroundColor3=T.BgCard kbFrame.BorderSizePixel=0
kbFrame.LayoutOrder=SectionOrder kbFrame.Parent=MscPage
Instance.new("UICorner",kbFrame).CornerRadius=UDim.new(0,8)
local kbLbl = Instance.new("TextLabel")
kbLbl.Size=UDim2.new(1,-16,1,0) kbLbl.Position=UDim2.new(0,10,0,0)
kbLbl.BackgroundTransparency=1 kbLbl.TextColor3=Color3.fromRGB(160,160,180)
kbLbl.TextSize=IsMobile and 10 or 11 kbLbl.Font=Enum.Font.Code
kbLbl.TextWrapped=true kbLbl.TextXAlignment=Enum.TextXAlignment.Left
kbLbl.TextYAlignment=Enum.TextYAlignment.Center
kbLbl.Text = IsMobile and
    "- Toggle Fly to show the D-pad\n- Tap Teleport: tap any surface\n- Drag hub from the gold title bar\n- Tap "..E.BRICK.." button to restore hub" or
    "[H] Toggle Hub     [F] Fly         [N] Noclip\n[G] God Mode       [E] ESP         [V] Invisible\nFly: WASD + Space (up) + LeftShift (down)"
kbLbl.Parent=kbFrame

NewSep(MscPage)
NewSection(MscPage, "ABOUT")
SectionOrder = SectionOrder + 1
local aboutFrame = Instance.new("Frame")
aboutFrame.Size=UDim2.new(1,0,0,62) aboutFrame.BackgroundColor3=T.BgCard
aboutFrame.BorderSizePixel=0 aboutFrame.LayoutOrder=SectionOrder aboutFrame.Parent=MscPage
Instance.new("UICorner",aboutFrame).CornerRadius=UDim.new(0,8)
local aLbl = Instance.new("TextLabel")
aLbl.Size=UDim2.new(1,-16,1,0) aLbl.Position=UDim2.new(0,10,0,0)
aLbl.BackgroundTransparency=1 aLbl.TextColor3=Color3.fromRGB(140,140,160)
aLbl.TextSize=11 aLbl.Font=Enum.Font.Gotham aLbl.TextWrapped=true
aLbl.Text= E.BRICK.." KaolinHub "..CFG.Version.."\n"
    .."Created by "..CFG.Creator.."\n"
    .."Like Bricks, Built Solid."
aLbl.Parent=aboutFrame

-- ============================================================
--  SELECT FIRST TAB
-- ============================================================
MovBtn.BackgroundColor3 = Color3.fromRGB(28,25,16)
MovBtn.TextColor3       = T.Accent
MovPage.Visible         = true

-- ============================================================
--  MOBILE FLY D-PAD
-- ============================================================
local FlyPad = Instance.new("Frame")
FlyPad.Name               = "FlyPad"
FlyPad.Size               = UDim2.new(0,216,0,168)
FlyPad.Position           = UDim2.new(0,10,1,-180)
FlyPad.BackgroundColor3   = Color3.fromRGB(0,0,0)
FlyPad.BackgroundTransparency = 0.42
FlyPad.BorderSizePixel    = 0
FlyPad.Visible            = false
FlyPad.ZIndex             = 5
FlyPad.Parent             = ScreenGui
Instance.new("UICorner",FlyPad).CornerRadius=UDim.new(0,14)
FlyPadFrame = FlyPad

local ptl=Instance.new("TextLabel")
ptl.Text="FLY PAD" ptl.Size=UDim2.new(1,0,0,14) ptl.Position=UDim2.new(0,0,0,3)
ptl.BackgroundTransparency=1 ptl.TextColor3=T.Accent ptl.TextSize=9
ptl.Font=Enum.Font.GothamBold ptl.TextXAlignment=Enum.TextXAlignment.Center
ptl.ZIndex=6 ptl.Parent=FlyPad

local function DBtn(icon, x, y, w, h, dk)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,w,0,h) b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=T.Accent b.BackgroundTransparency=0.2
    b.Text=icon b.TextSize=16 b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.fromRGB(255,255,255) b.BorderSizePixel=0 b.ZIndex=6 b.Parent=FlyPad
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            FlyDir[dk]=true Tw(b,{BackgroundTransparency=0},TW_FAST)
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            FlyDir[dk]=false Tw(b,{BackgroundTransparency=0.2},TW_FAST)
        end
    end)
end
DBtn(E.UP,   80,  18, 54, 40, "Forward")
DBtn(E.LEFT, 18,  62, 54, 40, "Left")
DBtn(E.DOWN, 80,  62, 54, 40, "Backward")
DBtn(E.RIGHT,138, 62, 54, 40, "Right")
DBtn(E.RISE, 18, 112, 88, 40, "Up")
DBtn(E.FALL,112, 112, 88, 40, "Down")

-- ============================================================
--  PC KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.H then
        Main.Visible = not Main.Visible
        RestoreBtn.Visible = not Main.Visible
    end
    if inp.KeyCode == Enum.KeyCode.F then flyTgl.Set(not flyTgl.Get())         end
    if inp.KeyCode == Enum.KeyCode.N then noclipTgl.Set(not noclipTgl.Get())   end
    if inp.KeyCode == Enum.KeyCode.G then godTgl.Set(not godTgl.Get())         end
    if inp.KeyCode == Enum.KeyCode.E then espTgl.Set(not espTgl.Get())         end
    if inp.KeyCode == Enum.KeyCode.V then invisTgl.Set(not invisTgl.Get())     end
end)

-- ============================================================
--  KEY SYSTEM GUI
-- ============================================================
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name             = "KaolinKeyGui"
KeyGui.ResetOnSpawn     = false
KeyGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
KeyGui.IgnoreGuiInset   = true
KeyGui.Parent           = LocalPlayer.PlayerGui

-- Fullscreen dark overlay
local KeyOverlay = Instance.new("Frame")
KeyOverlay.Size             = UDim2.new(1,0,1,0)
KeyOverlay.BackgroundColor3 = Color3.fromRGB(8,8,12)
KeyOverlay.BackgroundTransparency = 0
KeyOverlay.BorderSizePixel  = 0
KeyOverlay.Parent           = KeyGui

-- Centered card
local Card = Instance.new("Frame")
Card.Size             = UDim2.new(0, IsMobile and 320 or 380, 0, 260)
Card.AnchorPoint      = Vector2.new(0.5,0.5)
Card.Position         = UDim2.new(0.5,0,0.5,0)
Card.BackgroundColor3 = T.BgCard
Card.BorderSizePixel  = 0
Card.Parent           = KeyOverlay
Instance.new("UICorner",Card).CornerRadius=UDim.new(0,14)
local cardStroke=Instance.new("UIStroke",Card)
cardStroke.Color=T.Accent cardStroke.Thickness=2

-- Key icon
local keyIcon = Instance.new("TextLabel")
keyIcon.Text              = E.KEY
keyIcon.Size              = UDim2.new(1,0,0,42)
keyIcon.Position          = UDim2.new(0,0,0,18)
keyIcon.BackgroundTransparency = 1
keyIcon.TextColor3        = T.Accent
keyIcon.TextSize          = 34
keyIcon.Font              = Enum.Font.GothamBold
keyIcon.TextXAlignment    = Enum.TextXAlignment.Center
keyIcon.Parent            = Card

-- Title
local keyTitle = Instance.new("TextLabel")
keyTitle.Text             = CFG.Title
keyTitle.Size             = UDim2.new(1,0,0,28)
keyTitle.Position         = UDim2.new(0,0,0,58)
keyTitle.BackgroundTransparency = 1
keyTitle.TextColor3       = T.TextMain
keyTitle.TextSize         = IsMobile and 18 or 22
keyTitle.Font             = Enum.Font.GothamBold
keyTitle.TextXAlignment   = Enum.TextXAlignment.Center
keyTitle.Parent           = Card

-- Hint text
local keyHint = Instance.new("TextLabel")
keyHint.Text              = CFG.KeyHint
keyHint.Size              = UDim2.new(1,-40,0,18)
keyHint.Position          = UDim2.new(0,20,0,90)
keyHint.BackgroundTransparency = 1
keyHint.TextColor3        = T.TextDim
keyHint.TextSize          = 11
keyHint.Font              = Enum.Font.Gotham
keyHint.TextXAlignment    = Enum.TextXAlignment.Center
keyHint.Parent            = Card

-- Input box background
local inputBg = Instance.new("Frame")
inputBg.Size             = UDim2.new(1,-40,0,38)
inputBg.Position         = UDim2.new(0,20,0,118)
inputBg.BackgroundColor3 = Color3.fromRGB(18,18,26)
inputBg.BorderSizePixel  = 0
inputBg.Parent           = Card
Instance.new("UICorner",inputBg).CornerRadius=UDim.new(0,8)
local inputStroke=Instance.new("UIStroke",inputBg)
inputStroke.Color=T.TextDim inputStroke.Thickness=1

local keyInput = Instance.new("TextBox")
keyInput.Size             = UDim2.new(1,-20,1,0)
keyInput.Position         = UDim2.new(0,10,0,0)
keyInput.BackgroundTransparency = 1
keyInput.Text             = ""
keyInput.PlaceholderText  = "Type your key here..."
keyInput.PlaceholderColor3 = T.TextDim
keyInput.TextColor3       = T.TextMain
keyInput.TextSize         = 13
keyInput.Font             = Enum.Font.Code
keyInput.ClearTextOnFocus = true
keyInput.TextXAlignment   = Enum.TextXAlignment.Left
keyInput.Parent           = inputBg

keyInput.Focused:Connect(function()
    Tw(inputStroke,{Color=T.Accent},TW_FAST)
end)
keyInput.FocusLost:Connect(function()
    Tw(inputStroke,{Color=T.TextDim},TW_FAST)
end)

-- Verify button
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size             = UDim2.new(1,-40,0,40)
verifyBtn.Position         = UDim2.new(0,20,0,170)
verifyBtn.BackgroundColor3 = T.Accent
verifyBtn.Text             = E.KEY.."  VERIFY KEY"
verifyBtn.TextColor3       = T.TextOn
verifyBtn.TextSize         = 14
verifyBtn.Font             = Enum.Font.GothamBold
verifyBtn.BorderSizePixel  = 0
verifyBtn.Parent           = Card
Instance.new("UICorner",verifyBtn).CornerRadius=UDim.new(0,8)

-- Error / success label
local keyMsg = Instance.new("TextLabel")
keyMsg.Text               = ""
keyMsg.Size               = UDim2.new(1,-20,0,18)
keyMsg.Position           = UDim2.new(0,10,0,218)
keyMsg.BackgroundTransparency = 1
keyMsg.TextColor3         = T.Red
keyMsg.TextSize           = 11
keyMsg.Font               = Enum.Font.GothamBold
keyMsg.TextXAlignment     = Enum.TextXAlignment.Center
keyMsg.Parent             = Card

-- Shake animation for wrong key
local function ShakeCard()
    local origPos = Card.Position
    local steps = {10,-10,8,-8,5,-5,0}
    for _,x in ipairs(steps) do
        Tw(Card, {Position = UDim2.new(0.5, x, 0.5, 0)}, TweenInfo.new(0.04))
        task.wait(0.05)
    end
    Card.Position = origPos
end

-- Key verification
local function VerifyKey()
    local input = keyInput.Text
    if input == CFG.Key then
        -- SUCCESS
        keyMsg.TextColor3 = T.Green
        keyMsg.Text       = E.CHECK.."  Access Granted!"
        Tw(verifyBtn, {BackgroundColor3 = T.Green}, TW_FAST)
        Tw(cardStroke, {Color = T.Green}, TW_FAST)
        task.wait(0.8)
        -- Fade out key screen
        Tw(KeyOverlay, {BackgroundTransparency = 1}, TweenInfo.new(0.5, Enum.EasingStyle.Quad))
        task.wait(0.5)
        KeyGui:Destroy()
        -- Show main hub with slide-in
        ScreenGui.Enabled = true
        Main.Position = UDim2.new(0.5,-GUI_W/2,-0.6,0)
        Tw(Main, {Position = UDim2.new(0.5,-GUI_W/2,0.5,-GUI_H/2)}, TW_BACK)
    else
        -- FAIL
        keyMsg.TextColor3 = T.Red
        keyMsg.Text       = E.CROSS.."  Invalid key. Try again."
        Tw(inputStroke, {Color = T.Red}, TW_FAST)
        task.spawn(ShakeCard)
        task.delay(1.5, function()
            keyMsg.Text = ""
            Tw(inputStroke, {Color = T.TextDim}, TW_FAST)
        end)
        keyInput.Text = ""
    end
end

verifyBtn.MouseButton1Click:Connect(VerifyKey)
keyInput.FocusLost:Connect(function(enter) if enter then VerifyKey() end end)

verifyBtn.MouseEnter:Connect(function() Tw(verifyBtn,{BackgroundColor3=T.AccentDk},TW_FAST) end)
verifyBtn.MouseLeave:Connect(function() Tw(verifyBtn,{BackgroundColor3=T.Accent},TW_FAST) end)

-- ============================================================
--  DONE
-- ============================================================
print("KaolinHub "..CFG.Version.." loaded | ".. (IsMobile and "Mobile" or "PC") .." | Key system active")
