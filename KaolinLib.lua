-- KaolinHub v1.2 | Fixed | Mobile + PC
-- Educational Roblox Studio Testing Script
-- "Like Bricks, Built Solid."

-- ============================================================
--  EMOJI TABLE  (byte escape sequences - work on ALL devices)
--  This is how you use emojis reliably in Roblox Luau.
--  Each \xxx is one UTF-8 byte, constructed at runtime so
--  file encoding never matters.
-- ============================================================
local E = {
    BRICK  = "\240\159\167\177",  -- 
    RUN    = "\240\159\143\131",  -- 
    PERSON = "\240\159\145\164", -- 
    EARTH  = "\240\159\140\141", -- 
    GEAR   = "\226\154\153",     -- 
    CROSS  = "\226\156\149",     -- 
    DASH   = "\226\136\146",     -- 
    UP     = "\226\172\134",     -- 
    DOWN   = "\226\172\135",     -- 
    LEFT   = "\226\172\133",     -- 
    RIGHT  = "\226\158\161",     -- 
    RISE   = "\240\159\148\188", -- 
    FALL   = "\240\159\148\189", -- 
    STAR   = "\226\152\133",     -- 
    CHECK  = "\226\156\147",     -- 
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
    FlyEnabled      = false,
    NoclipEnabled   = false,
    SpeedEnabled    = false,
    InfJumpEnabled  = false,
    GodModeEnabled  = false,
    ESPEnabled      = false,
    AntiGravEnabled = false,
    FlySpeed        = 50,
    WalkSpeed       = 50,
    JumpPower       = 100,
}

-- Store RBXScriptConnections so we can disconnect them cleanly
local Connections   = {}
local ESPHighlights = {}

-- Mobile D-pad fly direction flags
local FlyDir = {
    Forward  = false,
    Backward = false,
    Left     = false,
    Right    = false,
    Up       = false,
    Down     = false,
}

-- ============================================================
--  HELPERS
-- ============================================================
local function GetChar()
    return LocalPlayer.Character
end
local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function Disconnect(conn)
    if conn then conn:Disconnect() end
end

-- ============================================================
--  FEATURE: FLY
-- ============================================================
local BodyVel, BodyGyr
local FlyConn

local function StartFly()
    local hrp = GetHRP()
    if not hrp then return end

    BodyVel           = Instance.new("BodyVelocity")
    BodyVel.Velocity  = Vector3.new(0, 0, 0)
    BodyVel.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    BodyVel.P         = 1e4
    BodyVel.Parent    = hrp

    BodyGyr           = Instance.new("BodyGyro")
    BodyGyr.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BodyGyr.D         = 100
    BodyGyr.P         = 1e4
    BodyGyr.CFrame    = hrp.CFrame
    BodyGyr.Parent    = hrp

    local hum = GetHum()
    if hum then hum.PlatformStand = true end

    FlyConn = RunService.Heartbeat:Connect(function()
        local hrp2 = GetHRP()
        if not hrp2 then return end
        local cam   = workspace.CurrentCamera
        local dir   = Vector3.new(0, 0, 0)
        local spd   = State.FlySpeed

        if IsMobile then
            if FlyDir.Forward  then dir = dir + cam.CFrame.LookVector  end
            if FlyDir.Backward then dir = dir - cam.CFrame.LookVector  end
            if FlyDir.Left     then dir = dir - cam.CFrame.RightVector end
            if FlyDir.Right    then dir = dir + cam.CFrame.RightVector end
            if FlyDir.Up       then dir = dir + Vector3.new(0, 1, 0)   end
            if FlyDir.Down     then dir = dir - Vector3.new(0, 1, 0)   end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0, 1, 0)   end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0)   end
        end

        BodyVel.Velocity = dir.Magnitude > 0 and (dir.Unit * spd) or Vector3.new(0, 0, 0)
        BodyGyr.CFrame   = cam.CFrame
    end)
end

local function StopFly()
    Disconnect(FlyConn) FlyConn = nil
    if BodyVel then BodyVel:Destroy() BodyVel = nil end
    if BodyGyr  then BodyGyr:Destroy()  BodyGyr = nil  end
    local hum = GetHum()
    if hum then hum.PlatformStand = false end
end

-- Reference to FlyPad frame, assigned later
local FlyPadFrame

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
    Disconnect(NoclipConn) NoclipConn = nil

    if on then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = GetChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    else
        local char = GetChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ============================================================
--  FEATURE: SPEED
-- ============================================================
local function SetSpeed(on)
    State.SpeedEnabled = on
    local hum = GetHum()
    if not hum then return end
    hum.WalkSpeed = on and State.WalkSpeed or 16
end

-- ============================================================
--  FEATURE: INFINITE JUMP
-- ============================================================
local InfJumpConn

local function SetInfJump(on)
    State.InfJumpEnabled = on
    Disconnect(InfJumpConn) InfJumpConn = nil
    if on then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            if not State.InfJumpEnabled then return end
            local hum = GetHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

-- ============================================================
--  FEATURE: GOD MODE
-- ============================================================
local GodConn

local function SetGodMode(on)
    State.GodModeEnabled = on
    Disconnect(GodConn) GodConn = nil
    local hum = GetHum()
    if not hum then return end
    if on then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        GodConn = RunService.Heartbeat:Connect(function()
            if not State.GodModeEnabled then return end
            local h = GetHum()
            if h then h.Health = math.huge end
        end)
    else
        hum.MaxHealth = 100
        hum.Health    = 100
    end
end

-- ============================================================
--  FEATURE: ESP
-- ============================================================
local function AddESP(player)
    if player == LocalPlayer then return end
    local function apply()
        local char = player.Character
        if not char then return end
        if ESPHighlights[player] then
            ESPHighlights[player]:Destroy()
        end
        local h = Instance.new("Highlight")
        h.FillColor           = Color3.fromRGB(255, 80, 80)
        h.OutlineColor        = Color3.fromRGB(255, 255, 255)
        h.FillTransparency    = 0.5
        h.OutlineTransparency = 0
        h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent              = char
        ESPHighlights[player] = h
    end
    apply()
    table.insert(Connections,
        player.CharacterAdded:Connect(function()
            if State.ESPEnabled then apply() end
        end)
    )
end

local function RemoveESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
end

local function SetESP(on)
    State.ESPEnabled = on
    if on then
        for _, p in ipairs(Players:GetPlayers()) do AddESP(p) end
        table.insert(Connections,
            Players.PlayerAdded:Connect(function(p)
                if State.ESPEnabled then AddESP(p) end
            end)
        )
    else
        for _, p in ipairs(Players:GetPlayers()) do RemoveESP(p) end
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
--  FEATURE: TAP / CLICK TELEPORT
-- ============================================================
local TeleportOn   = false
local TeleportConn

local function SetTeleport(on)
    TeleportOn = on
    Disconnect(TeleportConn) TeleportConn = nil
    if not on then return end

    if IsMobile then
        TeleportConn = UserInputService.TouchTap:Connect(function(touches)
            if not TeleportOn then return end
            local hrp = GetHRP()
            if not hrp or not touches[1] then return end
            local cam    = workspace.CurrentCamera
            local ray    = cam:ScreenPointToRay(touches[1].X, touches[1].Y)
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {GetChar()}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if result then
                hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        local mouse = LocalPlayer:GetMouse()
        TeleportConn = mouse.Button1Down:Connect(function()
            if not TeleportOn then return end
            local hrp = GetHRP()
            if hrp and mouse.Target then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
end

-- ============================================================
--  GUI CLEANUP
-- ============================================================
if LocalPlayer.PlayerGui:FindFirstChild("KaolinHub") then
    LocalPlayer.PlayerGui:FindFirstChild("KaolinHub"):Destroy()
end

-- ============================================================
--  SCREEN GUI
-- ============================================================
local ScreenGui              = Instance.new("ScreenGui")
ScreenGui.Name               = "KaolinHub"
ScreenGui.ResetOnSpawn       = false
ScreenGui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset     = true
ScreenGui.Parent             = LocalPlayer.PlayerGui

-- ============================================================
--  THEME
-- ============================================================
local T = {
    Accent    = Color3.fromRGB(200, 160, 80),
    BgRoot    = Color3.fromRGB(18,  18,  22),
    BgDark    = Color3.fromRGB(12,  12,  16),
    BgCard    = Color3.fromRGB(28,  28,  36),
    BgContent = Color3.fromRGB(22,  22,  28),
    TextMain  = Color3.fromRGB(230, 230, 230),
    TextDim   = Color3.fromRGB(100, 100, 115),
    TextOn    = Color3.fromRGB(18,  18,  22),
    TogOff    = Color3.fromRGB(55,  55,  68),
    SlTrack   = Color3.fromRGB(45,  45,  58),
}

local GUI_W = IsMobile and 400 or 520
local GUI_H = IsMobile and 480 or 400
local TAB_W = IsMobile and 82  or 110
local TW    = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_SL = TweenInfo.new(0.4,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function Tw(obj, props, info)
    TweenService:Create(obj, info or TW, props):Play()
end

-- ============================================================
--  MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame")
Main.Name              = "Main"
Main.Size              = UDim2.new(0, GUI_W, 0, GUI_H)
Main.Position          = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
Main.BackgroundColor3  = T.BgRoot
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = ScreenGui

local mc = Instance.new("UICorner", Main)
mc.CornerRadius = UDim.new(0, 10)

local ms = Instance.new("UIStroke", Main)
ms.Color     = T.Accent
ms.Thickness = 2

-- ============================================================
--  TITLE BAR
-- ============================================================
local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1, 0, 0, 46)
TBar.BackgroundColor3 = T.Accent
TBar.BorderSizePixel  = 0
TBar.Parent           = Main

local tbc = Instance.new("UICorner", TBar)
tbc.CornerRadius = UDim.new(0, 10)

-- Patch the bottom corners of TBar (rounded top only)
local TBarPatch = Instance.new("Frame")
TBarPatch.Size             = UDim2.new(1, 0, 0, 12)
TBarPatch.Position         = UDim2.new(0, 0, 1, -12)
TBarPatch.BackgroundColor3 = T.Accent
TBarPatch.BorderSizePixel  = 0
TBarPatch.Parent           = TBar

-- Title text
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text                = E.BRICK .. "  KaolinHub"
TitleLbl.Size                = UDim2.new(1, -80, 1, -16)
TitleLbl.Position            = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3          = T.TextOn
TitleLbl.TextSize            = IsMobile and 15 or 18
TitleLbl.Font                = Enum.Font.GothamBold
TitleLbl.TextXAlignment      = Enum.TextXAlignment.Left
TitleLbl.TextYAlignment      = Enum.TextYAlignment.Center
TitleLbl.Parent              = TBar

-- Sub text
local SubLbl = Instance.new("TextLabel")
SubLbl.Text                  = IsMobile and "v1.2  Mobile + PC" or "v1.2  Educational Testing Script"
SubLbl.Size                  = UDim2.new(1, -80, 0, 14)
SubLbl.Position              = UDim2.new(0, 12, 1, -16)
SubLbl.BackgroundTransparency = 1
SubLbl.TextColor3            = T.TextOn
SubLbl.TextTransparency      = 0.3
SubLbl.TextSize              = 9
SubLbl.Font                  = Enum.Font.Gotham
SubLbl.TextXAlignment        = Enum.TextXAlignment.Left
SubLbl.Parent                = TBar

-- Minimise button
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 28, 0, 28)
MinBtn.Position         = UDim2.new(1, -64, 0, 9)
MinBtn.BackgroundColor3 = T.BgRoot
MinBtn.Text             = E.DASH
MinBtn.TextColor3       = Color3.fromRGB(220, 220, 220)
MinBtn.TextSize         = 14
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.Parent           = TBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -32, 0, 9)
CloseBtn.BackgroundColor3 = T.BgRoot
CloseBtn.Text             = E.CROSS
CloseBtn.TextColor3       = Color3.fromRGB(220, 220, 220)
CloseBtn.TextSize         = 12
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Floating restore button
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size             = UDim2.new(0, 48, 0, 48)
RestoreBtn.Position         = UDim2.new(0, 8, 0.5, -24)
RestoreBtn.BackgroundColor3 = T.Accent
RestoreBtn.Text             = E.BRICK
RestoreBtn.TextSize         = 22
RestoreBtn.Font             = Enum.Font.GothamBold
RestoreBtn.BorderSizePixel  = 0
RestoreBtn.Visible          = false
RestoreBtn.ZIndex           = 10
RestoreBtn.Parent           = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 12)

-- Close / restore logic
local minimised = false

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible        = false
    RestoreBtn.Visible  = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    Main.Visible        = true
    RestoreBtn.Visible  = false
end)

MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    if minimised then
        Tw(Main, {Size = UDim2.new(0, GUI_W, 0, 46)}, TW)
        MinBtn.Text = E.STAR
    else
        Tw(Main, {Size = UDim2.new(0, GUI_W, 0, GUI_H)}, TW)
        MinBtn.Text = E.DASH
    end
end)

-- ============================================================
--  DRAGGING  (Mouse + Touch)
-- ============================================================
do
    local dragging, dragStart, startPos = false, nil, nil

    local function dragBegin(pos)
        dragging  = true
        dragStart = pos
        startPos  = Main.Position
    end
    local function dragMove(pos)
        if not dragging then return end
        local d = pos - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
    local function dragEnd() dragging = false end

    TBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragBegin(Vector2.new(inp.Position.X, inp.Position.Y))
        end
    end)
    TBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragEnd()
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragMove(Vector2.new(inp.Position.X, inp.Position.Y))
        end
    end)
end

-- ============================================================
--  TAB SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, TAB_W, 1, -46)
Sidebar.Position         = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = T.BgDark
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = Main

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding   = UDim.new(0, 4)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop   = UDim.new(0, 8)
SidePad.PaddingLeft  = UDim.new(0, 5)
SidePad.PaddingRight = UDim.new(0, 5)

-- ============================================================
--  CONTENT AREA
-- ============================================================
local ContentArea = Instance.new("Frame")
ContentArea.Size             = UDim2.new(1, -TAB_W, 1, -46)
ContentArea.Position         = UDim2.new(0, TAB_W, 0, 46)
ContentArea.BackgroundColor3 = T.BgContent
ContentArea.BorderSizePixel  = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent           = Main

-- Thin accent divider line
local Divider = Instance.new("Frame", ContentArea)
Divider.Size             = UDim2.new(0, 1, 1, 0)
Divider.BackgroundColor3 = T.Accent
Divider.BorderSizePixel  = 0

-- ============================================================
--  COMPONENT FACTORY
-- ============================================================
local AllTabBtns  = {}
local AllTabPages = {}

-- Create a scrollable page inside ContentArea
local function NewPage()
    local page = Instance.new("ScrollingFrame")
    page.Size                 = UDim2.new(1, -10, 1, 0)
    page.Position             = UDim2.new(0, 10, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel      = 0
    page.ScrollBarThickness   = IsMobile and 5 or 3
    page.ScrollBarImageColor3 = T.Accent
    page.CanvasSize           = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    page.Visible              = false
    page.Parent               = ContentArea

    local lay = Instance.new("UIListLayout", page)
    lay.Padding   = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 4)

    return page
end

-- Create a sidebar tab button
local function NewTabBtn(icon, label, page, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, IsMobile and 50 or 42)
    btn.BackgroundColor3 = T.BgRoot
    btn.Text             = icon .. "\n" .. label
    btn.TextColor3       = T.TextDim
    btn.TextSize         = IsMobile and 9 or 10
    btn.Font             = Enum.Font.GothamBold
    btn.TextWrapped      = true
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.Parent           = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(AllTabBtns) do
            b.BackgroundColor3 = T.BgRoot
            b.TextColor3       = T.TextDim
        end
        for _, p in ipairs(AllTabPages) do
            p.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(30, 27, 18)
        btn.TextColor3       = T.Accent
        page.Visible         = true
    end)

    table.insert(AllTabBtns,  btn)
    table.insert(AllTabPages, page)
    return btn
end

-- Section header
local SectionOrder = 0
local function NewSection(page, text)
    SectionOrder = SectionOrder + 1
    local lbl = Instance.new("TextLabel")
    lbl.Text                   = "  " .. text
    lbl.Size                   = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundColor3       = T.Accent
    lbl.BackgroundTransparency = 0.82
    lbl.TextColor3             = T.Accent
    lbl.TextSize               = 10
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.BorderSizePixel        = 0
    lbl.LayoutOrder            = SectionOrder
    lbl.Parent                 = page
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
end

-- Toggle switch
local function NewToggle(page, label, desc, callback)
    SectionOrder = SectionOrder + 1
    local H   = IsMobile and 64 or 56
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, H)
    row.BackgroundColor3 = T.BgCard
    row.BorderSizePixel  = 0
    row.LayoutOrder      = SectionOrder
    row.Parent           = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text           = label
    nameLbl.Size           = UDim2.new(1, -70, 0, 22)
    nameLbl.Position       = UDim2.new(0, 12, 0, 8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3     = T.TextMain
    nameLbl.TextSize       = IsMobile and 12 or 13
    nameLbl.Font           = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent         = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Text           = desc or ""
    descLbl.Size           = UDim2.new(1, -70, 0, 14)
    descLbl.Position       = UDim2.new(0, 12, 0, 32)
    descLbl.BackgroundTransparency = 1
    descLbl.TextColor3     = T.TextDim
    descLbl.TextSize       = 9
    descLbl.Font           = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent         = row

    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, 44, 0, 24)
    pill.Position         = UDim2.new(1, -56, 0.5, -12)
    pill.BackgroundColor3 = T.TogOff
    pill.BorderSizePixel  = 0
    pill.Parent           = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 18, 0, 18)
    dot.Position         = UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    dot.BorderSizePixel  = 0
    dot.Parent           = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    -- Invisible button covering the whole row for easy tapping
    local hit = Instance.new("TextButton")
    hit.Size                  = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                  = ""
    hit.ZIndex                = 2
    hit.Parent                = row

    local enabled = false

    local function SetState(val, silent)
        enabled = val
        local dotPos  = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local pillCol = enabled and T.Accent or T.TogOff
        Tw(dot,  {Position = dotPos})
        Tw(pill, {BackgroundColor3 = pillCol})
        if not silent then callback(enabled) end
    end

    hit.MouseButton1Click:Connect(function()
        SetState(not enabled)
    end)
    hit.MouseEnter:Connect(function()
        Tw(row, {BackgroundColor3 = Color3.fromRGB(34, 34, 46)})
    end)
    hit.MouseLeave:Connect(function()
        Tw(row, {BackgroundColor3 = T.BgCard})
    end)

    -- Return controller
    return {
        Set = function(v) SetState(v, false) end,
        Get = function() return enabled end,
    }
end

-- Slider
local function NewSlider(page, label, minV, maxV, defV, suffix, callback)
    SectionOrder = SectionOrder + 1
    suffix = suffix or ""
    local TH = IsMobile and 9  or 7
    local HS = IsMobile and 22 or 16

    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 66)
    row.BackgroundColor3 = T.BgCard
    row.BorderSizePixel  = 0
    row.LayoutOrder      = SectionOrder
    row.Parent           = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text           = label
    nameLbl.Size           = UDim2.new(0.65, 0, 0, 20)
    nameLbl.Position       = UDim2.new(0, 12, 0, 8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3     = T.TextMain
    nameLbl.TextSize       = IsMobile and 11 or 12
    nameLbl.Font           = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent         = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Text            = string.format("%.10g", defV) .. suffix
    valLbl.Size            = UDim2.new(0.35, -12, 0, 20)
    valLbl.Position        = UDim2.new(0.65, 0, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3      = T.Accent
    valLbl.TextSize        = IsMobile and 11 or 12
    valLbl.Font            = Enum.Font.GothamBold
    valLbl.TextXAlignment  = Enum.TextXAlignment.Right
    valLbl.Parent          = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -24, 0, TH)
    track.Position         = UDim2.new(0, 12, 0, 42)
    track.BackgroundColor3 = T.SlTrack
    track.BorderSizePixel  = 0
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct0 = (defV - minV) / (maxV - minV)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = T.Accent
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local handle = Instance.new("Frame")
    handle.Size             = UDim2.new(0, HS, 0, HS)
    handle.AnchorPoint      = Vector2.new(0.5, 0.5)
    handle.Position         = UDim2.new(pct0, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel  = 0
    handle.Parent           = track
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

    local curVal  = defV
    local dragging = false

    local function updateFromX(x)
        local abs = track.AbsolutePosition
        local sz  = track.AbsoluteSize
        local rel = math.clamp((x - abs.X) / sz.X, 0, 1)
        curVal    = math.floor((minV + rel * (maxV - minV)) * 10) / 10
        valLbl.Text     = string.format("%.10g", curVal) .. suffix
        fill.Size       = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
        callback(curVal)
    end

    -- Large invisible hit zone for easier touch
    local hit = Instance.new("TextButton")
    hit.Size                  = UDim2.new(1, 0, 0, 46)
    hit.Position              = UDim2.new(0, 0, 0, 26)
    hit.BackgroundTransparency = 1
    hit.Text                  = ""
    hit.ZIndex                = 2
    hit.Parent                = row

    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            updateFromX(inp.Position.X)
        end
    end)

    return {
        Set = function(v)
            curVal = math.clamp(v, minV, maxV)
            local rel = (curVal - minV) / (maxV - minV)
            valLbl.Text     = string.format("%.10g", curVal) .. suffix
            fill.Size       = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, 0, 0.5, 0)
            callback(curVal)
        end,
        Get = function() return curVal end,
    }
end

-- Button
local function NewButton(page, label, desc, callback)
    SectionOrder = SectionOrder + 1
    local H = IsMobile and (desc and 58 or 46) or (desc and 52 or 40)

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, H)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    btn.Text             = ""
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = SectionOrder
    btn.Parent           = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color     = T.Accent
    stroke.Thickness = 1

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text           = label
    nameLbl.Size           = UDim2.new(1, -40, 0, 20)
    nameLbl.Position       = UDim2.new(0, 12, desc and 0 or 0.5, desc and 8 or -10)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3     = T.Accent
    nameLbl.TextSize       = IsMobile and 12 or 13
    nameLbl.Font           = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent         = btn

    if desc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Text           = desc
        descLbl.Size           = UDim2.new(1, -40, 0, 14)
        descLbl.Position       = UDim2.new(0, 12, 0, 30)
        descLbl.BackgroundTransparency = 1
        descLbl.TextColor3     = T.TextDim
        descLbl.TextSize       = 9
        descLbl.Font           = Enum.Font.Gotham
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent         = btn
    end

    local arrow = Instance.new("TextLabel")
    arrow.Text             = E.RIGHT
    arrow.Size             = UDim2.new(0, 20, 1, 0)
    arrow.Position         = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3       = T.Accent
    arrow.TextSize         = 14
    arrow.Font             = Enum.Font.GothamBold
    arrow.Parent           = btn

    btn.MouseEnter:Connect(function()
        Tw(btn, {BackgroundColor3 = Color3.fromRGB(42, 38, 22)})
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, {BackgroundColor3 = Color3.fromRGB(32, 32, 44)})
    end)
    btn.MouseButton1Click:Connect(function()
        Tw(btn, {BackgroundColor3 = T.Accent}, TweenInfo.new(0.08))
        task.delay(0.1, function()
            Tw(btn, {BackgroundColor3 = Color3.fromRGB(32, 32, 44)})
        end)
        callback()
    end)
end

-- Separator
local function NewSep(page)
    SectionOrder = SectionOrder + 1
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1, 0, 0, 1)
    f.BackgroundColor3 = Color3.fromRGB(50, 50, 64)
    f.BorderSizePixel  = 0
    f.LayoutOrder      = SectionOrder
    f.Parent           = page
end

-- ============================================================
--  BUILD TABS
-- ============================================================

-- --- MOVEMENT ?????????????????????????????????????????????????
local MovPage = NewPage()
local MovBtn  = NewTabBtn(E.RUN, "Move", MovPage, 1)

NewSection(MovPage, "LOCOMOTION")

local flyToggle = NewToggle(MovPage, "Fly",
    IsMobile and "Use the D-pad below" or "WASD + Space / Shift",
    function(on) SetFly(on) end)

local noclipToggle = NewToggle(MovPage, "Noclip",
    "Walk through walls",
    function(on) SetNoclip(on) end)

local infJumpToggle = NewToggle(MovPage, "Infinite Jump",
    "Jump repeatedly mid-air",
    function(on) SetInfJump(on) end)

local antiGravToggle = NewToggle(MovPage, "Anti-Gravity",
    "Low gravity (10 studs/s^2)",
    function(on) SetAntiGrav(on) end)

local teleportToggle = NewToggle(MovPage, IsMobile and "Tap Teleport" or "Click Teleport",
    IsMobile and "Tap any surface to teleport" or "Click any surface to teleport",
    function(on) SetTeleport(on) end)

NewSep(MovPage)
NewSection(MovPage, "SPEED & JUMP")

local speedSlider = NewSlider(MovPage, "Walk Speed", 16, 200, 50, " sp", function(v)
    State.WalkSpeed = v
    if State.SpeedEnabled then
        local hum = GetHum()
        if hum then hum.WalkSpeed = v end
    end
end)

local speedToggle = NewToggle(MovPage, "Speed Boost",
    "Apply the walk speed above",
    function(on) SetSpeed(on) end)

local jumpSlider = NewSlider(MovPage, "Jump Power", 50, 300, 100, "", function(v)
    State.JumpPower = v
    local hum = GetHum()
    if hum then hum.JumpPower = v end
end)

NewSlider(MovPage, "Fly Speed", 10, 200, 50, " sp", function(v)
    State.FlySpeed = v
end)

NewButton(MovPage, "Reset All Movement", nil, function()
    speedSlider.Set(50)
    jumpSlider.Set(100)
    local hum = GetHum()
    if hum then
        hum.WalkSpeed  = 16
        hum.JumpPower  = 50
    end
    workspace.Gravity = OrigGravity
    antiGravToggle.Set(false)
    speedToggle.Set(false)
end)

-- --- PLAYER ???????????????????????????????????????????????????
local PlrPage = NewPage()
local PlrBtn  = NewTabBtn(E.PERSON, "Player", PlrPage, 2)

NewSection(PlrPage, "HEALTH")

local godToggle = NewToggle(PlrPage, "God Mode",
    "Infinite health",
    function(on) SetGodMode(on) end)

NewSep(PlrPage)
NewSection(PlrPage, "VISUALS")

local espToggle = NewToggle(PlrPage, "ESP Highlights",
    "Red outline on all players",
    function(on) SetESP(on) end)

NewSep(PlrPage)
NewSection(PlrPage, "CHARACTER SIZE")

NewSlider(PlrPage, "Head Size", 0.5, 4, 1, "x", function(v)
    local char = GetChar()
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(v, v, v)
    end
end)

NewSlider(PlrPage, "Body Scale", 0.5, 3, 1, "x", function(v)
    local hum = GetHum()
    if not hum then return end
    for _, c in ipairs(hum:GetChildren()) do
        if c:IsA("NumberValue") and c.Name:find("Scale") then
            c.Value = v
        end
    end
end)

-- --- WORLD ????????????????????????????????????????????????????
local WldPage = NewPage()
local WldBtn  = NewTabBtn(E.EARTH, "World", WldPage, 3)

NewSection(WldPage, "LIGHTING")

NewSlider(WldPage, "Time of Day", 0, 24, 14, "h", function(v)
    Lighting.ClockTime = v
end)

NewSlider(WldPage, "Brightness", 0, 5, 1, "", function(v)
    Lighting.Brightness = v
end)

NewSlider(WldPage, "Fog End", 100, 10000, 10000, "", function(v)
    Lighting.FogEnd = v
end)

NewSep(WldPage)
NewSection(WldPage, "PHYSICS")

NewSlider(WldPage, "Gravity", 5, 200, 196, "", function(v)
    workspace.Gravity = v
end)

NewSep(WldPage)
NewSection(WldPage, "ATMOSPHERE")

NewToggle(WldPage, "Rainbow Ambient",
    "Cycles sky color",
    function(on)
        if on then
            local hue = 0
            local rc = RunService.Heartbeat:Connect(function(dt)
                if not on then return end
                hue = (hue + dt * 0.05) % 1
                Lighting.Ambient        = Color3.fromHSV(hue, 0.6, 0.9)
                Lighting.OutdoorAmbient = Color3.fromHSV((hue + 0.3) % 1, 0.5, 0.8)
            end)
            table.insert(Connections, rc)
        else
            Lighting.Ambient        = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end)

-- --- MISC ?????????????????????????????????????????????????????
local MscPage = NewPage()
local MscBtn  = NewTabBtn(E.GEAR, "Misc", MscPage, 4)

NewSection(MscPage, "UI")

NewToggle(MscPage, "Hide HUD",
    "Toggle Roblox core UI",
    function(on)
        pcall(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(
                Enum.CoreGuiType.All, not on
            )
        end)
    end)

NewSep(MscPage)
NewSection(MscPage, IsMobile and "MOBILE TIPS" or "PC KEYBINDS")

SectionOrder = SectionOrder + 1
local kbFrame = Instance.new("Frame")
kbFrame.Size             = UDim2.new(1, 0, 0, IsMobile and 88 or 76)
kbFrame.BackgroundColor3 = T.BgCard
kbFrame.BorderSizePixel  = 0
kbFrame.LayoutOrder      = SectionOrder
kbFrame.Parent           = MscPage
Instance.new("UICorner", kbFrame).CornerRadius = UDim.new(0, 8)

local kbLbl = Instance.new("TextLabel")
kbLbl.Size   = UDim2.new(1, -20, 1, 0)
kbLbl.Position = UDim2.new(0, 10, 0, 0)
kbLbl.BackgroundTransparency = 1
kbLbl.TextColor3 = Color3.fromRGB(170, 170, 185)
kbLbl.TextSize   = IsMobile and 10 or 11
kbLbl.Font       = Enum.Font.Code
kbLbl.TextWrapped = true
kbLbl.TextXAlignment = Enum.TextXAlignment.Left
kbLbl.TextYAlignment = Enum.TextYAlignment.Center
kbLbl.Text = IsMobile and
    "- Toggle Fly to show the D-pad\n- Tap Teleport: tap any floor surface\n- Drag hub from the gold title bar\n- Tap BRICK button to restore hub" or
    "[H] Show/Hide Hub      [F] Fly\n[N] Noclip              [G] God Mode\n[E] ESP\nFly controls: WASD + Space + Shift"
kbLbl.Parent = kbFrame

NewSep(MscPage)
NewSection(MscPage, "ABOUT")

SectionOrder = SectionOrder + 1
local aboutFrame = Instance.new("Frame")
aboutFrame.Size             = UDim2.new(1, 0, 0, 58)
aboutFrame.BackgroundColor3 = T.BgCard
aboutFrame.BorderSizePixel  = 0
aboutFrame.LayoutOrder      = SectionOrder
aboutFrame.Parent           = MscPage
Instance.new("UICorner", aboutFrame).CornerRadius = UDim.new(0, 8)

local aboutLbl = Instance.new("TextLabel")
aboutLbl.Size   = UDim2.new(1, -20, 1, 0)
aboutLbl.Position = UDim2.new(0, 10, 0, 0)
aboutLbl.BackgroundTransparency = 1
aboutLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
aboutLbl.TextSize   = 11
aboutLbl.Font       = Enum.Font.Gotham
aboutLbl.TextWrapped = true
aboutLbl.Text = E.BRICK .. " KaolinHub v1.2\nBuilt for Roblox Studio testing & education.\nLike Bricks, Built Solid."
aboutLbl.Parent = aboutFrame

-- ============================================================
--  MOBILE FLY D-PAD
-- ============================================================
local FlyPad = Instance.new("Frame")
FlyPad.Name              = "FlyPad"
FlyPad.Size              = UDim2.new(0, 216, 0, 168)
FlyPad.Position          = UDim2.new(0, 10, 1, -180)
FlyPad.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
FlyPad.BackgroundTransparency = 0.42
FlyPad.BorderSizePixel   = 0
FlyPad.Visible           = false
FlyPad.ZIndex            = 5
FlyPad.Parent            = ScreenGui
Instance.new("UICorner", FlyPad).CornerRadius = UDim.new(0, 14)

FlyPadFrame = FlyPad  -- assign global reference

local padTitle = Instance.new("TextLabel")
padTitle.Text              = "FLY PAD"
padTitle.Size              = UDim2.new(1, 0, 0, 14)
padTitle.Position          = UDim2.new(0, 0, 0, 3)
padTitle.BackgroundTransparency = 1
padTitle.TextColor3        = T.Accent
padTitle.TextSize          = 9
padTitle.Font              = Enum.Font.GothamBold
padTitle.TextXAlignment    = Enum.TextXAlignment.Center
padTitle.ZIndex            = 6
padTitle.Parent            = FlyPad

local function DPadBtn(icon, x, y, w, h, dirKey)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, w, 0, h)
    b.Position         = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = T.Accent
    b.BackgroundTransparency = 0.2
    b.Text             = icon
    b.TextSize         = IsMobile and 16 or 14
    b.Font             = Enum.Font.GothamBold
    b.TextColor3       = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel  = 0
    b.ZIndex           = 6
    b.Parent           = FlyPad
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            FlyDir[dirKey] = true
            Tw(b, {BackgroundTransparency = 0})
        end
    end)
    b.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            FlyDir[dirKey] = false
            Tw(b, {BackgroundTransparency = 0.2})
        end
    end)
end

--     [FWD]
-- [L] [BCK] [R]
-- [ UP  ]  [ DN ]
DPadBtn(E.UP,   80, 18,  54, 40, "Forward")
DPadBtn(E.LEFT, 18, 62,  54, 40, "Left")
DPadBtn(E.DOWN, 80, 62,  54, 40, "Backward")
DPadBtn(E.RIGHT,138, 62, 54, 40, "Right")
DPadBtn(E.RISE, 18, 112, 88, 40, "Up")
DPadBtn(E.FALL, 112, 112, 88, 40, "Down")

-- ============================================================
--  SELECT FIRST TAB
-- ============================================================
MovBtn.BackgroundColor3 = Color3.fromRGB(30, 27, 18)
MovBtn.TextColor3       = T.Accent
MovPage.Visible         = true

-- ============================================================
--  PC KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.H then
        Main.Visible       = not Main.Visible
        RestoreBtn.Visible = not Main.Visible
    end
    if inp.KeyCode == Enum.KeyCode.F then flyToggle.Set(not flyToggle.Get())         end
    if inp.KeyCode == Enum.KeyCode.N then noclipToggle.Set(not noclipToggle.Get())   end
    if inp.KeyCode == Enum.KeyCode.G then godToggle.Set(not godToggle.Get())         end
    if inp.KeyCode == Enum.KeyCode.E then espToggle.Set(not espToggle.Get())         end
end)

-- ============================================================
--  STARTUP SLIDE-IN ANIMATION
-- ============================================================
Main.Position = UDim2.new(0.5, -GUI_W/2, -0.6, 0)
Tw(Main, {Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)}, TW_SL)

print("KaolinHub v1.2 loaded | " .. (IsMobile and "Mobile" or "PC") .. " mode")
