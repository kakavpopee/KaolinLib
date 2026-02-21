-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- KaolinHub v1.1 | Mobile + PC | Educational Script | Roblox Studio Testing
-- "Like Bricks, Built Solid."

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

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

local Connections   = {}
local ESPHighlights = {}

-- Mobile fly direction state (driven by on-screen D-pad)
local MobileFlyDir = {
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
local function GetChar() return LocalPlayer.Character end
local function GetHRP()  local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()  local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid")  end

-- ============================================================
--  FEATURE: FLY
-- ============================================================
local BodyVelocity, BodyGyro

local function StartFly()
    local hrp = GetHRP()
    if not hrp then return end

    BodyVelocity            = Instance.new("BodyVelocity")
    BodyVelocity.Velocity   = Vector3.zero
    BodyVelocity.MaxForce   = Vector3.new(1e5,1e5,1e5)
    BodyVelocity.P          = 1e4
    BodyVelocity.Parent     = hrp

    BodyGyro                = Instance.new("BodyGyro")
    BodyGyro.MaxTorque      = Vector3.new(1e5,1e5,1e5)
    BodyGyro.D              = 100
    BodyGyro.P              = 1e4
    BodyGyro.CFrame         = hrp.CFrame
    BodyGyro.Parent         = hrp

    local conn = RunService.Heartbeat:Connect(function()
        if not State.FlyEnabled then return end
        local hrp2 = GetHRP()
        if not hrp2 then return end

        local cam   = workspace.CurrentCamera
        local dir   = Vector3.zero
        local speed = State.FlySpeed

        if IsMobile then
            if MobileFlyDir.Forward  then dir = dir + cam.CFrame.LookVector  end
            if MobileFlyDir.Backward then dir = dir - cam.CFrame.LookVector  end
            if MobileFlyDir.Left     then dir = dir - cam.CFrame.RightVector end
            if MobileFlyDir.Right    then dir = dir + cam.CFrame.RightVector end
            if MobileFlyDir.Up       then dir = dir + Vector3.new(0,1,0)     end
            if MobileFlyDir.Down     then dir = dir - Vector3.new(0,1,0)     end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0)     end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0)     end
        end

        BodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        BodyGyro.CFrame       = cam.CFrame
    end)
    table.insert(Connections, conn)
end

local function StopFly()
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro      then BodyGyro:Destroy()     BodyGyro     = nil end
end

local FlyPadRef  -- set later after FlyPad is created

local function ToggleFly()
    State.FlyEnabled = not State.FlyEnabled
    if State.FlyEnabled then
        StartFly()
    else
        StopFly()
        local hum = GetHum()
        if hum then hum.PlatformStand = false end
    end
    if FlyPadRef then FlyPadRef.Visible = State.FlyEnabled end
end

-- ============================================================
--  FEATURE: NOCLIP
-- ============================================================
local function ToggleNoclip()
    State.NoclipEnabled = not State.NoclipEnabled
    if State.NoclipEnabled then
        local conn = RunService.Stepped:Connect(function()
            if not State.NoclipEnabled then return end
            local char = GetChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
        table.insert(Connections, conn)
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
local function ApplySpeed()
    local hum = GetHum()
    if hum then hum.WalkSpeed = State.WalkSpeed end
end

local function ToggleSpeed()
    State.SpeedEnabled = not State.SpeedEnabled
    if State.SpeedEnabled then ApplySpeed()
    else local hum=GetHum() if hum then hum.WalkSpeed=16 end end
end

-- ============================================================
--  FEATURE: INFINITE JUMP
-- ============================================================
local function ToggleInfJump()
    State.InfJumpEnabled = not State.InfJumpEnabled
    if State.InfJumpEnabled then
        local conn = UserInputService.JumpRequest:Connect(function()
            if not State.InfJumpEnabled then return end
            local hum = GetHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        table.insert(Connections, conn)
    end
end

-- ============================================================
--  FEATURE: GOD MODE
-- ============================================================
local function ToggleGodMode()
    State.GodModeEnabled = not State.GodModeEnabled
    local hum = GetHum()
    if not hum then return end
    if State.GodModeEnabled then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        local conn = RunService.Heartbeat:Connect(function()
            if not State.GodModeEnabled then return end
            local h = GetHum()
            if h then h.Health = math.huge end
        end)
        table.insert(Connections, conn)
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
    local function applyHL()
        local char = player.Character
        if not char then return end
        if ESPHighlights[player] then ESPHighlights[player]:Destroy() end
        local h = Instance.new("Highlight")
        h.FillColor           = Color3.fromRGB(255,80,80)
        h.OutlineColor        = Color3.fromRGB(255,255,255)
        h.FillTransparency    = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent    = char
        ESPHighlights[player] = h
    end
    applyHL()
    player.CharacterAdded:Connect(function() if State.ESPEnabled then applyHL() end end)
end

local function RemoveESP(player)
    if ESPHighlights[player] then ESPHighlights[player]:Destroy() ESPHighlights[player]=nil end
end

local function ToggleESP()
    State.ESPEnabled = not State.ESPEnabled
    if State.ESPEnabled then
        for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
        Players.PlayerAdded:Connect(function(p) if State.ESPEnabled then AddESP(p) end end)
    else
        for _,p in ipairs(Players:GetPlayers()) do RemoveESP(p) end
    end
end

-- ============================================================
--  FEATURE: ANTI-GRAVITY
-- ============================================================
local originalGravity = workspace.Gravity

local function ToggleAntiGrav()
    State.AntiGravEnabled = not State.AntiGravEnabled
    workspace.Gravity = State.AntiGravEnabled and 10 or originalGravity
end

-- ============================================================
--  FEATURE: TAP/CLICK TELEPORT
-- ============================================================
local TeleportActive = false

local function ToggleTeleport()
    TeleportActive = not TeleportActive
    if TeleportActive then
        if IsMobile then
            local conn = UserInputService.TouchTap:Connect(function(touches)
                if not TeleportActive then return end
                local hrp = GetHRP()
                if not hrp or not touches[1] then return end
                local ray    = workspace.CurrentCamera:ScreenPointToRay(touches[1].X, touches[1].Y)
                local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, RaycastParams.new())
                if result then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0,3,0)) end
            end)
            table.insert(Connections, conn)
        else
            local conn = Mouse.Button1Down:Connect(function()
                if not TeleportActive then return end
                local hrp = GetHRP()
                if hrp and Mouse.Target then
                    hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0))
                end
            end)
            table.insert(Connections, conn)
        end
    end
end

-- ============================================================
--  FEATURE: JUMP POWER
-- ============================================================
local function ApplyJumpPower()
    local hum = GetHum()
    if hum then hum.JumpPower = State.JumpPower end
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
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "KaolinHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LocalPlayer.PlayerGui

-- ============================================================
--  THEME CONSTANTS
-- ============================================================
local ACCENT   = Color3.fromRGB(200,160,80)
local BG_ROOT  = Color3.fromRGB(18, 18, 22)
local BG_DARK  = Color3.fromRGB(12, 12, 16)
local BG_CARD  = Color3.fromRGB(28, 28, 36)
local TEXT_COL = Color3.fromRGB(230,230,230)
local DIM_COL  = Color3.fromRGB(100,100,115)
local OFF_COL  = Color3.fromRGB(60, 60, 70)

-- Adaptive sizes
local GUI_W  = IsMobile and 400 or 520
local GUI_H  = IsMobile and 480 or 400
local TAB_W  = IsMobile and 80  or 110

-- ============================================================
--  MAIN FRAME
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size             = UDim2.new(0, GUI_W, 0, GUI_H)
MainFrame.Position         = UDim2.new(0.5,-GUI_W/2, 0.5,-GUI_H/2)
MainFrame.BackgroundColor3 = BG_ROOT
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent           = ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,10)
local mainStroke = Instance.new("UIStroke",MainFrame)
mainStroke.Color     = ACCENT
mainStroke.Thickness = 2

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1,0,0,45)
TitleBar.BackgroundColor3 = ACCENT
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,10)

-- patch bottom corners of rounded title bar
local TitlePatch = Instance.new("Frame")
TitlePatch.Size             = UDim2.new(1,0,0,10)
TitlePatch.Position         = UDim2.new(0,0,1,-10)
TitlePatch.BackgroundColor3 = ACCENT
TitlePatch.BorderSizePixel  = 0
TitlePatch.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text           = "KaolinHub  v1.1"
TitleLabel.Size           = UDim2.new(1,-50,1,0)
TitleLabel.Position       = UDim2.new(0,14,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3     = BG_ROOT
TitleLabel.TextSize       = IsMobile and 15 or 18
TitleLabel.Font           = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent         = TitleBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Text     = IsMobile and "Mobile + PC Edition" or "Educational Testing Script"
SubLabel.Size     = UDim2.new(1,-15,0,14)
SubLabel.Position = UDim2.new(0,14,1,-16)
SubLabel.BackgroundTransparency = 1
SubLabel.TextColor3 = BG_ROOT
SubLabel.TextSize   = 9
SubLabel.Font       = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent   = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0,30,0,30)
CloseBtn.Position         = UDim2.new(1,-38,0,7)
CloseBtn.BackgroundColor3 = BG_ROOT
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = Color3.fromRGB(255,255,255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(1,0)

-- ============================================================
--  DRAGGING (Mouse + Touch unified)
-- ============================================================
do
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    local function begin(pos)
        dragging  = true
        dragStart = pos
        startPos  = MainFrame.Position
    end
    local function move(pos)
        if not dragging then return end
        local d = pos - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
    local function finish() dragging = false end

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            begin(Vector2.new(inp.Position.X, inp.Position.Y))
        end
    end)
    TitleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then finish() end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            move(Vector2.new(inp.Position.X, inp.Position.Y))
        end
    end)
end

-- ============================================================
--  TAB BAR
-- ============================================================
local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(0,TAB_W,1,-45)
TabBar.Position         = UDim2.new(0,0,0,45)
TabBar.BackgroundColor3 = BG_DARK
TabBar.BorderSizePixel  = 0
TabBar.Parent           = MainFrame

local TabLayout = Instance.new("UIListLayout",TabBar)
TabLayout.Padding   = UDim.new(0,4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TabPad = Instance.new("UIPadding",TabBar)
TabPad.PaddingTop   = UDim.new(0,8)
TabPad.PaddingLeft  = UDim.new(0,5)
TabPad.PaddingRight = UDim.new(0,5)

-- ============================================================
--  CONTENT AREA
-- ============================================================
local ContentArea = Instance.new("Frame")
ContentArea.Size             = UDim2.new(1,-TAB_W,1,-45)
ContentArea.Position         = UDim2.new(0,TAB_W,0,45)
ContentArea.BackgroundColor3 = Color3.fromRGB(22,22,28)
ContentArea.BorderSizePixel  = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent           = MainFrame

local Divider = Instance.new("Frame",ContentArea)
Divider.Size             = UDim2.new(0,1,1,0)
Divider.BackgroundColor3 = ACCENT
Divider.BorderSizePixel  = 0

-- ============================================================
--  COMPONENT BUILDERS
-- ============================================================
local TabButtons = {}
local TabPages   = {}

local function MakePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name                 = name
    page.Size                 = UDim2.new(1,-8,1,0)
    page.Position             = UDim2.new(0,8,0,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel      = 0
    page.ScrollBarThickness   = IsMobile and 5 or 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize           = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    page.Visible              = false
    page.Parent               = ContentArea

    local layout = Instance.new("UIListLayout",page)
    layout.Padding   = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding",page)
    pad.PaddingTop    = UDim.new(0,10)
    pad.PaddingBottom = UDim.new(0,10)
    pad.PaddingRight  = UDim.new(0,4)

    return page
end

local function MakeTabButton(label, emoji, page, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,0,IsMobile and 46 or 38)
    btn.BackgroundColor3 = BG_ROOT
    btn.Text             = label
    btn.TextColor3       = DIM_COL
    btn.TextSize         = IsMobile and 9 or 10
    btn.Font             = Enum.Font.GothamBold
    btn.TextWrapped      = true
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.Parent           = TabBar
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(TabButtons) do
            b.BackgroundColor3 = BG_ROOT
            b.TextColor3       = DIM_COL
        end
        for _,p in pairs(TabPages) do p.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(30,28,20)
        btn.TextColor3       = ACCENT
        page.Visible         = true
    end)

    table.insert(TabButtons, btn)
    table.insert(TabPages,   page)
    return btn
end

local function MakeSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text                  = "  "..text
    lbl.Size                  = UDim2.new(1,0,0,22)
    lbl.BackgroundColor3      = ACCENT
    lbl.BackgroundTransparency = 0.85
    lbl.TextColor3            = ACCENT
    lbl.TextSize              = 10
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.BorderSizePixel       = 0
    lbl.Parent                = parent
    Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,6)
end

local TOGGLE_H = IsMobile and 62 or 54

local function MakeToggle(parent, label, desc, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,TOGGLE_H)
    row.BackgroundColor3 = BG_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Text           = label
    lbl.Size           = UDim2.new(1,-70,0,22)
    lbl.Position       = UDim2.new(0,12,0,8)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3     = TEXT_COL
    lbl.TextSize       = IsMobile and 12 or 13
    lbl.Font           = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent         = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Text       = desc
    descLbl.Size       = UDim2.new(1,-70,0,14)
    descLbl.Position   = UDim2.new(0,12,0,30)
    descLbl.BackgroundTransparency = 1
    descLbl.TextColor3 = DIM_COL
    descLbl.TextSize   = 9
    descLbl.Font       = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent     = row

    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0,44,0,24)
    pill.Position         = UDim2.new(1,-56,0.5,-12)
    pill.BackgroundColor3 = OFF_COL
    pill.BorderSizePixel  = 0
    pill.Parent           = row
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0,18,0,18)
    dot.Position         = UDim2.new(0,3,0.5,-9)
    dot.BackgroundColor3 = Color3.fromRGB(200,200,200)
    dot.BorderSizePixel  = 0
    dot.Parent           = pill
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local enabled   = false
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local btn = Instance.new("TextButton")
    btn.Size   = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text   = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(dot, tweenInfo, {
            Position = enabled and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        }):Play()
        TweenService:Create(pill, tweenInfo, {
            BackgroundColor3 = enabled and ACCENT or OFF_COL
        }):Play()
        callback(enabled)
    end)
end

-- Touch-friendly slider (large handle on mobile)
local function MakeSlider(parent, label, minVal, maxVal, default, callback)
    local TRACK_H  = IsMobile and 8  or 6
    local HANDLE_S = IsMobile and 20 or 14
    local ROW_H    = 64

    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,ROW_H)
    row.BackgroundColor3 = BG_CARD
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Text           = label
    lbl.Size           = UDim2.new(0.7,0,0,20)
    lbl.Position       = UDim2.new(0,12,0,8)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3     = TEXT_COL
    lbl.TextSize       = IsMobile and 11 or 12
    lbl.Font           = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent         = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Text        = tostring(default)
    valLbl.Size        = UDim2.new(0.3,-12,0,20)
    valLbl.Position    = UDim2.new(0.7,0,0,8)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3  = ACCENT
    valLbl.TextSize    = IsMobile and 11 or 12
    valLbl.Font        = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent      = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1,-24,0,TRACK_H)
    track.Position         = UDim2.new(0,12,0,40)
    track.BackgroundColor3 = Color3.fromRGB(50,50,60)
    track.BorderSizePixel  = 0
    track.Parent           = row
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((default-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local handle = Instance.new("Frame")
    handle.Size             = UDim2.new(0,HANDLE_S,0,HANDLE_S)
    handle.AnchorPoint      = Vector2.new(0.5,0.5)
    handle.Position         = UDim2.new((default-minVal)/(maxVal-minVal),0,0.5,0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.BorderSizePixel  = 0
    handle.Parent           = track
    Instance.new("UICorner",handle).CornerRadius = UDim.new(1,0)

    local dragging = false

    local function updateFromX(screenX)
        local abs = track.AbsolutePosition
        local sz  = track.AbsoluteSize
        local rel = math.clamp((screenX - abs.X) / sz.X, 0, 1)
        local val = math.floor(minVal + rel * (maxVal - minVal))
        valLbl.Text       = tostring(val)
        fill.Size         = UDim2.new(rel,0,1,0)
        handle.Position   = UDim2.new(rel,0,0.5,0)
        callback(val)
    end

    -- Larger invisible hit area for touch
    local hitArea = Instance.new("TextButton")
    hitArea.Size   = UDim2.new(1,0,0,44)
    hitArea.Position = UDim2.new(0,0,0,28)
    hitArea.BackgroundTransparency = 1
    hitArea.Text   = ""
    hitArea.Parent = row

    hitArea.InputBegan:Connect(function(inp)
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
end

-- ============================================================
--  BUILD TABS
-- ============================================================

-- -- MOVEMENT --------------------------------------------------
local MovePage = MakePage("Movement")
local MoveTab  = MakeTabButton("Move", "", , MovePage, 1)

MakeSectionHeader(MovePage, "LOCOMOTION")
MakeToggle(MovePage, "Fly", IsMobile and "Use the D-pad (auto-appears)" or "WASD + Space/Shift", function(on)
    State.FlyEnabled = not on
    ToggleFly()
end)
MakeToggle(MovePage, "Noclip", "Walk through walls & objects", function(on)
    State.NoclipEnabled = not on
    ToggleNoclip()
end)
MakeToggle(MovePage, "Infinite Jump", "Jump repeatedly in mid-air", function(on)
    State.InfJumpEnabled = not on
    ToggleInfJump()
end)
MakeToggle(MovePage, "Anti-Gravity", "Reduces gravity to 10", function(on)
    State.AntiGravEnabled = not on
    ToggleAntiGrav()
end)
MakeToggle(MovePage, "Tap Teleport", IsMobile and "Tap ground to teleport there" or "Click ground to teleport", function(_)
    ToggleTeleport()
end)

MakeSectionHeader(MovePage, "STATS")
MakeSlider(MovePage, "Walk Speed",  16, 200, 50, function(v) State.WalkSpeed=v if State.SpeedEnabled then ApplySpeed() end end)
MakeToggle(MovePage, "Speed Boost", "Apply custom walk speed above", function(on)
    State.SpeedEnabled = not on
    ToggleSpeed()
end)
MakeSlider(MovePage, "Jump Power", 50,  300, 100, function(v) State.JumpPower=v ApplyJumpPower() end)
MakeSlider(MovePage, "Fly Speed",  10,  200, 50,  function(v) State.FlySpeed=v  end)

-- -- PLAYER ----------------------------------------------------
local PlrPage = MakePage("Player")
local PlrTab  = MakeTabButton("Player","", , PlrPage, 2)

MakeSectionHeader(PlrPage, "HEALTH")
MakeToggle(PlrPage, "God Mode", "Sets health to infinite (Studio)", function(on)
    State.GodModeEnabled = not on
    ToggleGodMode()
end)

MakeSectionHeader(PlrPage, "VISUALS")
MakeToggle(PlrPage, "ESP Highlights", "Red outline on all players", function(on)
    State.ESPEnabled = not on
    ToggleESP()
end)

MakeSectionHeader(PlrPage, "CHARACTER SIZE")
MakeSlider(PlrPage, "Head Size",   0.5, 4, 1, function(v)
    local char = GetChar()
    if char and char:FindFirstChild("Head") then char.Head.Size = Vector3.new(v,v,v) end
end)
MakeSlider(PlrPage, "Body Scale",  0.5, 3, 1, function(v)
    local hum = GetHum()
    if hum then
        for _, c in ipairs(hum:GetChildren()) do
            if c:IsA("NumberValue") and c.Name:find("Scale") then c.Value = v end
        end
    end
end)

-- -- WORLD -----------------------------------------------------
local WorldPage = MakePage("World")
local WorldTab  = MakeTabButton("World","", , WorldPage, 3)

MakeSectionHeader(WorldPage, "LIGHTING")
MakeSlider(WorldPage, "Time of Day (Hour)", 0,  24,    14,    function(v) Lighting.ClockTime = v end)
MakeSlider(WorldPage, "Brightness",         0,  5,     1,     function(v) Lighting.Brightness = v end)
MakeSlider(WorldPage, "Fog End",            100,10000, 10000, function(v) Lighting.FogEnd = v end)

MakeSectionHeader(WorldPage, "PHYSICS")
MakeSlider(WorldPage, "Gravity", 5, 200, 196, function(v) workspace.Gravity = v end)

MakeSectionHeader(WorldPage, "FX")
MakeToggle(WorldPage, "Rainbow Ambient", "Cycles sky ambient color", function(on)
    if on then
        local hue = 0
        local conn = RunService.Heartbeat:Connect(function(dt)
            if not on then return end
            hue = (hue + dt*0.05) % 1
            Lighting.Ambient        = Color3.fromHSV(hue, 0.6, 0.9)
            Lighting.OutdoorAmbient = Color3.fromHSV((hue+0.3)%1, 0.5, 0.8)
        end)
        table.insert(Connections, conn)
    else
        Lighting.Ambient        = Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
    end
end)

-- -- MISC ------------------------------------------------------
local MiscPage = MakePage("Misc")
local MiscTab  = MakeTabButton("Misc","", , MiscPage, 4)

MakeSectionHeader(MiscPage, "UI")
MakeToggle(MiscPage, "Hide HUD", "Toggle Roblox UI elements", function(on)
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not on)
    end)
end)

MakeSectionHeader(MiscPage, IsMobile and "TIPS (MOBILE)" or "KEYBINDS (PC)")
local kbFrame = Instance.new("Frame")
kbFrame.Size             = UDim2.new(1,0,0,IsMobile and 90 or 80)
kbFrame.BackgroundColor3 = BG_CARD
kbFrame.BorderSizePixel  = 0
kbFrame.Parent           = MiscPage
Instance.new("UICorner",kbFrame).CornerRadius = UDim.new(0,8)

local kbLabel = Instance.new("TextLabel")
kbLabel.Size   = UDim2.new(1,-20,1,0)
kbLabel.Position = UDim2.new(0,10,0,0)
kbLabel.BackgroundTransparency = 1
kbLabel.TextColor3 = Color3.fromRGB(180,180,180)
kbLabel.TextSize   = IsMobile and 10 or 11
kbLabel.Font       = Enum.Font.Code
kbLabel.TextWrapped = true
kbLabel.TextXAlignment = Enum.TextXAlignment.Left
kbLabel.TextYAlignment = Enum.TextYAlignment.Center
kbLabel.Text = IsMobile and
    "- Toggle Fly to show the D-pad\n- Tap Teleport: tap any floor surface\n- Drag GUI by the gold title bar\n- HUB button restores hidden GUI" or
    "[F] Fly  |  [N] Noclip  |  [G] God Mode\n[E] ESP  |  [H] Show/Hide Hub\nFly: WASD + Space (up) + Shift (down)"
kbLabel.Parent = kbFrame

MakeSectionHeader(MiscPage, "ABOUT")
local aboutFrame = Instance.new("Frame")
aboutFrame.Size             = UDim2.new(1,0,0,58)
aboutFrame.BackgroundColor3 = BG_CARD
aboutFrame.BorderSizePixel  = 0
aboutFrame.Parent           = MiscPage
Instance.new("UICorner",aboutFrame).CornerRadius = UDim.new(0,8)

local aboutLabel = Instance.new("TextLabel")
aboutLabel.Size   = UDim2.new(1,-20,1,0)
aboutLabel.Position = UDim2.new(0,10,0,0)
aboutLabel.BackgroundTransparency = 1
aboutLabel.TextColor3 = Color3.fromRGB(180,180,180)
aboutLabel.TextSize   = IsMobile and 10 or 11
aboutLabel.Font       = Enum.Font.Gotham
aboutLabel.TextWrapped = true
aboutLabel.Text = "KaolinHub v1.1  |  Mobile + PC\n\"Like Bricks, Built Solid.\" \nFor Roblox Studio testing & education."
aboutLabel.Parent = aboutFrame

-- ============================================================
--  FLOATING SHOW BUTTON (visible when GUI hidden)
-- ============================================================
local ShowBtn = Instance.new("TextButton")
ShowBtn.Size             = UDim2.new(0,44,0,44)
ShowBtn.Position         = UDim2.new(0,10,0.5,-22)
ShowBtn.BackgroundColor3 = ACCENT
ShowBtn.Text             = "HUB"
ShowBtn.TextSize         = 22
ShowBtn.BorderSizePixel  = 0
ShowBtn.Visible          = false
ShowBtn.ZIndex           = 10
ShowBtn.Parent           = ScreenGui
Instance.new("UICorner",ShowBtn).CornerRadius = UDim.new(0,10)

ShowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ShowBtn.Visible   = false
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowBtn.Visible   = true
end)

-- ============================================================
--  MOBILE FLY D-PAD
-- ============================================================
local FlyPad = Instance.new("Frame")
FlyPad.Name             = "FlyPad"
FlyPad.Size             = UDim2.new(0,210,0,165)
FlyPad.Position         = UDim2.new(0,10,1,-180)
FlyPad.BackgroundColor3 = Color3.fromRGB(0,0,0)
FlyPad.BackgroundTransparency = 0.45
FlyPad.BorderSizePixel  = 0
FlyPad.Visible          = false
FlyPad.ZIndex           = 5
FlyPad.Parent           = ScreenGui
Instance.new("UICorner",FlyPad).CornerRadius = UDim.new(0,14)

FlyPadRef = FlyPad  -- assign ref so ToggleFly can find it

local padTitle = Instance.new("TextLabel")
padTitle.Text             = "FLY PAD"
padTitle.Size             = UDim2.new(1,0,0,14)
padTitle.Position         = UDim2.new(0,0,0,2)
padTitle.BackgroundTransparency = 1
padTitle.TextColor3       = ACCENT
padTitle.TextSize         = 9
padTitle.Font             = Enum.Font.GothamBold
padTitle.TextXAlignment   = Enum.TextXAlignment.Center
padTitle.ZIndex           = 6
padTitle.Parent           = FlyPad

local function MakeDBtn(label, posX, posY, w, h, dirKey)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0,w,0,h)
    btn.Position         = UDim2.new(0,posX,0,posY)
    btn.BackgroundColor3 = ACCENT
    btn.BackgroundTransparency = 0.25
    btn.Text             = label
    btn.TextSize         = 18
    btn.Font             = Enum.Font.GothamBold
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 6
    btn.Parent           = FlyPad
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            MobileFlyDir[dirKey] = true
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            MobileFlyDir[dirKey] = false
        end
    end)
end

-- Arrows: Forward=top, Left, Backward=bottom, Right + Up/Down side by side
MakeDBtn("FWD",  78, 18, 52, 40, "Forward")
MakeDBtn(" L ",  18, 62, 52, 40, "Left")
MakeDBtn("BCK",  78, 62, 52, 40, "Backward")
MakeDBtn(" R ", 138, 62, 52, 40, "Right")
MakeDBtn(" UP", 18, 112, 88, 40, "Up")
MakeDBtn(" DN", 112, 112, 88, 40, "Down")

-- ============================================================
--  PC KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F then ToggleFly()     end
    if inp.KeyCode == Enum.KeyCode.N then ToggleNoclip()  end
    if inp.KeyCode == Enum.KeyCode.G then ToggleGodMode() end
    if inp.KeyCode == Enum.KeyCode.E then ToggleESP()     end
    if inp.KeyCode == Enum.KeyCode.H then
        MainFrame.Visible = not MainFrame.Visible
        ShowBtn.Visible   = not MainFrame.Visible
    end
end)

-- ============================================================
--  DEFAULT TAB: Movement
-- ============================================================
do
    for _,b in pairs(TabButtons) do b.BackgroundColor3=BG_ROOT b.TextColor3=DIM_COL end
    for _,p in pairs(TabPages)   do p.Visible=false end
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(30,28,20)
    TabButtons[1].TextColor3       = ACCENT
    TabPages[1].Visible            = true
end

-- ============================================================
--  STARTUP SLIDE-IN
-- ============================================================
MainFrame.Position = UDim2.new(0.5,-GUI_W/2,-0.5,-GUI_H/2)
TweenService:Create(MainFrame,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5,-GUI_W/2, 0.5,-GUI_H/2) }
):Play()

print("KaolinHub v1.1 loaded!")
print("   Mode:", IsMobile and "Mobile" or "PC")
print("   PC shortcuts: [H] toggle  [F] fly  [N] noclip  [G] god  [E] ESP")
