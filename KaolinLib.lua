-- ============================================================
--  KaolinLib v1.0
--  A lightweight Roblox Luau UI Library for Studio testing
--  Mobile + PC Compatible | "Like Bricks, Built Solid."
--  Usage: local KaolinLib = require(path) OR paste at top of script
-- ============================================================

local KaolinLib = {}
KaolinLib.__index = KaolinLib

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  MOBILE DETECTION
-- ============================================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  DEFAULT THEME
-- ============================================================
local DefaultTheme = {
    -- Backgrounds
    Background       = Color3.fromRGB(18,  18,  22),
    BackgroundDark   = Color3.fromRGB(12,  12,  16),
    Card             = Color3.fromRGB(28,  28,  36),
    ContentBg        = Color3.fromRGB(22,  22,  28),

    -- Accent & Text
    Accent           = Color3.fromRGB(200, 160, 80),
    AccentDark       = Color3.fromRGB(160, 120, 50),
    TextPrimary      = Color3.fromRGB(230, 230, 230),
    TextSecondary    = Color3.fromRGB(100, 100, 115),
    TextOnAccent     = Color3.fromRGB(18,  18,  22),

    -- States
    ToggleOff        = Color3.fromRGB(60,  60,  70),
    ToggleOn         = Color3.fromRGB(200, 160, 80),
    ButtonBg         = Color3.fromRGB(35,  35,  48),
    ButtonHover      = Color3.fromRGB(50,  45,  30),
    SliderTrack      = Color3.fromRGB(50,  50,  60),
    DropdownBg       = Color3.fromRGB(25,  25,  32),
    DropdownItem     = Color3.fromRGB(32,  32,  42),
    DropdownHover    = Color3.fromRGB(45,  40,  25),
    InputBg          = Color3.fromRGB(25,  25,  33),
    SeparatorColor   = Color3.fromRGB(50,  50,  65),
    ErrorColor       = Color3.fromRGB(220, 80,  80),
    SuccessColor     = Color3.fromRGB(80,  200, 120),

    -- Fonts
    FontBold         = Enum.Font.GothamBold,
    FontRegular      = Enum.Font.Gotham,
    FontMono         = Enum.Font.Code,

    -- Sizing
    CornerRadius     = UDim.new(0, 8),
    TabWidth         = IsMobile and 60  or 80,
    TitleHeight      = 32,
    ToggleHeight     = IsMobile and 42  or 36,
    SliderHeight     = 48,
    ButtonHeight     = IsMobile and 30  or 26,
    WindowW          = IsMobile and 340 or 440,
    WindowH          = IsMobile and 310 or 260,
    Padding          = 8,
    TextSizeSM       = IsMobile and 8  or 9,
    TextSizeMD       = IsMobile and 10 or 11,
    TextSizeLG       = IsMobile and 11 or 12,
}

-- ============================================================
--  INTERNAL HELPERS
-- ============================================================
local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or DefaultTheme.CornerRadius
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color     or DefaultTheme.Accent
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration   or 0.15,
        style      or Enum.EasingStyle.Quad,
        direction  or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function MakeFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do
        pcall(function() f[k] = v end)
    end
    return f
end

local function MakeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    for k,v in pairs(props) do
        pcall(function() l[k] = v end)
    end
    return l
end

local function MakeButton(props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    for k,v in pairs(props) do
        pcall(function() b[k] = v end)
    end
    return b
end

local function MakeInput(props)
    local i = Instance.new("TextBox")
    i.BorderSizePixel = 0
    for k,v in pairs(props) do
        pcall(function() i[k] = v end)
    end
    return i
end

local function ListLayout(parent, padding, sortOrder)
    local l = Instance.new("UIListLayout")
    l.Padding   = UDim.new(0, padding   or DefaultTheme.Padding)
    l.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    l.Parent    = parent
    return l
end

local function Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent        = parent
    return p
end

-- Universal drag (mouse + touch)
local function MakeDraggable(handle, target)
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(inp.Position.X, inp.Position.Y)
            startPos  = target.Position
        end
    end)
    handle.InputEnded:Connect(function(inp)
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
            local d = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
--[[
    Usage:
    local Window = KaolinLib:CreateWindow({
        Title    = "My Hub",
        SubTitle = "v1.0",
        Theme    = {},   -- optional overrides (see DefaultTheme keys)
    })
]]
function KaolinLib:CreateWindow(config)
    config = config or {}

    -- Merge theme overrides
    local T = {}
    for k,v in pairs(DefaultTheme) do T[k] = v end
    if config.Theme then
        for k,v in pairs(config.Theme) do T[k] = v end
    end

    local title    = config.Title    or "KaolinLib"
    local subtitle = config.SubTitle or "v1.0"
    local W        = T.WindowW
    local H        = T.WindowH
    local TABW     = T.TabWidth

    -- Clean up old GUI
    if LocalPlayer.PlayerGui:FindFirstChild("KaolinLib_" .. title) then
        LocalPlayer.PlayerGui:FindFirstChild("KaolinLib_" .. title):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "KaolinLib_" .. title
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent         = LocalPlayer.PlayerGui

    -- Main frame
    local MainFrame = MakeFrame({
        Size             = UDim2.new(0,W,0,H),
        Position         = UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3 = T.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = ScreenGui,
    })
    Corner(MainFrame, UDim.new(0,10))
    Stroke(MainFrame, T.Accent, 2)

    -- Title bar
    local TitleBar = MakeFrame({
        Size             = UDim2.new(1,0,0,T.TitleHeight),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })
    Corner(TitleBar, UDim.new(0,10))

    local TitlePatch = MakeFrame({
        Size             = UDim2.new(1,0,0,10),
        Position         = UDim2.new(0,0,1,-10),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = TitleBar,
    })

    MakeLabel({
        Text           = "\240\159\167\177  " .. title,
        Size           = UDim2.new(1,-80,1,0),
        Position       = UDim2.new(0,12,0,0),
        TextColor3     = T.TextOnAccent,
        TextSize       = T.TextSizeLG + 1,
        Font           = T.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = TitleBar,
    })
    MakeLabel({
        Text           = subtitle,
        Size           = UDim2.new(0.5,0,1,0),
        Position       = UDim2.new(0.3,0,0,0),
        TextColor3     = T.TextOnAccent,
        TextSize       = 8,
        TextTransparency = 0.3,
        Font           = T.FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = TitleBar,
    })

    -- Close button
    local CloseBtn = MakeButton({
        Size             = UDim2.new(0,20,0,20),
        Position         = UDim2.new(1,-26,0,6),
        BackgroundColor3 = T.Background,
        Text             = "X",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 11,
        Font             = T.FontBold,
        Parent           = TitleBar,
    })
    Corner(CloseBtn, UDim.new(1,0))

    -- Minimise button
    local MinBtn = MakeButton({
        Size             = UDim2.new(0,20,0,20),
        Position         = UDim2.new(1,-50,0,6),
        BackgroundColor3 = T.Background,
        Text             = "-",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 11,
        Font             = T.FontBold,
        Parent           = TitleBar,
    })
    Corner(MinBtn, UDim.new(1,0))

    -- Tab bar
    local TabBar = MakeFrame({
        Size             = UDim2.new(0,TABW,1,-T.TitleHeight),
        Position         = UDim2.new(0,0,0,T.TitleHeight),
        BackgroundColor3 = T.BackgroundDark,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })
    ListLayout(TabBar, 2)
    Padding(TabBar, 5, 5, 3, 3)

    -- Content area
    local ContentArea = MakeFrame({
        Size             = UDim2.new(1,-TABW,1,-T.TitleHeight),
        Position         = UDim2.new(0,TABW,0,T.TitleHeight),
        BackgroundColor3 = T.ContentBg,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = MainFrame,
    })
    -- Divider line
    MakeFrame({
        Size             = UDim2.new(0,1,1,0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = ContentArea,
    })

    -- Floating show button (when GUI is hidden)
    local ShowBtn = MakeButton({
        Size             = UDim2.new(0,42,0,42),
        Position         = UDim2.new(0,10,0.5,-21),
        BackgroundColor3 = T.Accent,
        Text             = "\240\159\167\177",
        TextSize         = 20,
        Visible          = false,
        ZIndex           = 10,
        Parent           = ScreenGui,
    })
    Corner(ShowBtn, UDim.new(0,10))

    ShowBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        ShowBtn.Visible   = false
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        ShowBtn.Visible   = true
    end)

    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Tween(MainFrame, {
            Size = minimised
                and UDim2.new(0,W,0,T.TitleHeight)
                or  UDim2.new(0,W,0,H)
        }, 0.25, Enum.EasingStyle.Quad)
        MinBtn.Text = minimised and "[]" or "-"
    end)

    -- Dragging
    MakeDraggable(TitleBar, MainFrame)

    -- Slide-in animation
    MainFrame.Position = UDim2.new(0.5,-W/2,-0.5,-H/2)
    Tween(MainFrame, {Position = UDim2.new(0.5,-W/2,0.5,-H/2)}, 0.4, Enum.EasingStyle.Back)

    -- -- WINDOW OBJECT ----------------------------------------
    local Window      = {}
    Window._theme     = T
    Window._tabBar    = TabBar
    Window._content   = ContentArea
    Window._tabBtns   = {}
    Window._tabPages  = {}
    Window._gui       = ScreenGui
    Window._frame     = MainFrame
    Window._notifications = {}

    -- -- NOTIFICATION SYSTEM ----------------------------------
    local NotifHolder = MakeFrame({
        Size             = UDim2.new(0,260,1,0),
        Position         = UDim2.new(1,-265,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Parent           = ScreenGui,
    })
    ListLayout(NotifHolder, 6)
    Padding(NotifHolder, 10, 10, 0, 0)

    --[[
        Window:Notify({
            Title   = "Success",
            Message = "Fly enabled!",
            Duration = 3,         -- seconds (default 3)
            Type    = "success",  -- "success" | "error" | "info" (default)
        })
    ]]
    function Window:Notify(config)
        config = config or {}
        local notifT    = config.Type     or "info"
        local duration  = config.Duration or 3
        local accentCol = notifT == "success" and T.SuccessColor
                       or notifT == "error"   and T.ErrorColor
                       or T.Accent

        local notif = MakeFrame({
            Size             = UDim2.new(1,0,0,58),
            BackgroundColor3 = T.Card,
            BorderSizePixel  = 0,
            Parent           = NotifHolder,
        })
        Corner(notif)
        Stroke(notif, accentCol, 1)

        -- Accent bar
        MakeFrame({
            Size             = UDim2.new(0,3,1,0),
            BackgroundColor3 = accentCol,
            BorderSizePixel  = 0,
            Parent           = notif,
        })

        MakeLabel({
            Text           = config.Title or "Notification",
            Size           = UDim2.new(1,-16,0,20),
            Position       = UDim2.new(0,12,0,8),
            TextColor3     = accentCol,
            TextSize       = T.TextSizeMD,
            Font           = T.FontBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent         = notif,
        })
        MakeLabel({
            Text           = config.Message or "",
            Size           = UDim2.new(1,-16,0,18),
            Position       = UDim2.new(0,12,0,30),
            TextColor3     = T.TextPrimary,
            TextSize       = T.TextSizeSM + 1,
            Font           = T.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped    = true,
            Parent         = notif,
        })

        -- Slide in
        notif.Position = UDim2.new(1,10,0,0)
        Tween(notif, {Position = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back)

        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1,10,0,0)}, 0.3)
            task.delay(0.35, function()
                notif:Destroy()
            end)
        end)
    end

    -- -- CREATE TAB -------------------------------------------
    --[[
        Usage:
        local Tab = Window:CreateTab("Movement", ">>")
    ]]
    function Window:CreateTab(name, icon)
        local T      = self._theme
        local page   = Instance.new("ScrollingFrame")
        page.Name                 = name
        page.Size                 = UDim2.new(1,-8,1,0)
        page.Position             = UDim2.new(0,8,0,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel      = 0
        page.ScrollBarThickness   = IsMobile and 5 or 3
        page.ScrollBarImageColor3 = T.Accent
        page.CanvasSize           = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
        page.Visible              = false
        page.Parent               = self._content

        ListLayout(page, 4)
        Padding(page, 6, 6, 0, 3)

        -- Tab button
        local icon_str = icon and (icon .. "\n") or ""
        local btn = MakeButton({
            Size             = UDim2.new(1,0,0,IsMobile and 34 or 28),
            BackgroundColor3 = T.Background,
            Text             = icon_str .. name,
            TextColor3       = T.TextSecondary,
            TextSize         = T.TextSizeSM + 1,
            Font             = T.FontBold,
            TextWrapped      = true,
            Parent           = self._tabBar,
        })
        Corner(btn, UDim.new(0,6))

        local isFirst = #self._tabBtns == 0

        btn.MouseButton1Click:Connect(function()
            for _,b in pairs(self._tabBtns) do
                b.BackgroundColor3 = T.Background
                b.TextColor3       = T.TextSecondary
            end
            for _,p in pairs(self._tabPages) do p.Visible = false end
            btn.BackgroundColor3 = Color3.fromRGB(30,28,20)
            btn.TextColor3       = T.Accent
            page.Visible         = true
        end)

        table.insert(self._tabBtns,  btn)
        table.insert(self._tabPages, page)

        if isFirst then
            btn.BackgroundColor3 = Color3.fromRGB(30,28,20)
            btn.TextColor3       = T.Accent
            page.Visible         = true
        end

        -- -- TAB OBJECT ---------------------------------------
        local Tab   = {}
        Tab._page   = page
        Tab._theme  = T
        Tab._order  = 0

        local function nextOrder()
            Tab._order = Tab._order + 1
            return Tab._order
        end

        -- -- Section Header ------------------------------------
        --[[
            Tab:CreateSection("Section Name")
        ]]
        function Tab:CreateSection(text)
            local T   = self._theme
            local lbl = MakeLabel({
                Text                  = "  " .. text,
                Size                  = UDim2.new(1,0,0,22),
                BackgroundColor3      = T.Accent,
                BackgroundTransparency = 0.85,
                TextColor3            = T.Accent,
                TextSize              = 10,
                Font                  = T.FontBold,
                TextXAlignment        = Enum.TextXAlignment.Left,
                BorderSizePixel       = 0,
                LayoutOrder           = nextOrder(),
                Parent                = self._page,
            })
            Corner(lbl, UDim.new(0,6))
        end

        -- -- Separator -----------------------------------------
        --[[
            Tab:CreateSeparator()
        ]]
        function Tab:CreateSeparator()
            local T = self._theme
            local f = MakeFrame({
                Size             = UDim2.new(1,0,0,1),
                BackgroundColor3 = T.SeparatorColor,
                BorderSizePixel  = 0,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
        end

        -- -- Label ---------------------------------------------
        --[[
            local lbl = Tab:CreateLabel("Hello World")
            lbl:Set("New Text")
        ]]
        function Tab:CreateLabel(text)
            local T = self._theme
            local frame = MakeFrame({
                Size             = UDim2.new(1,0,0,28),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(frame)

            local lbl = MakeLabel({
                Text           = text or "",
                Size           = UDim2.new(1,-24,1,0),
                Position       = UDim2.new(0,12,0,0),
                TextColor3     = T.TextSecondary,
                TextSize       = T.TextSizeMD,
                Font           = T.FontRegular,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped    = true,
                Parent         = frame,
            })

            local LabelObj = {}
            function LabelObj:Set(newText)
                lbl.Text = newText
            end
            return LabelObj
        end

        -- -- Toggle --------------------------------------------
        --[[
            local toggle = Tab:CreateToggle({
                Name     = "Fly",
                Desc     = "Optional description",
                Default  = false,
                Callback = function(Value) end
            })
            toggle:Set(true)
        ]]
        function Tab:CreateToggle(config)
            config = config or {}
            local T        = self._theme
            local enabled  = config.Default or false
            local callback = config.Callback or function() end

            local row = MakeFrame({
                Size             = UDim2.new(1,0,0,T.ToggleHeight),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(row)

            MakeLabel({
                Text           = config.Name or "Toggle",
                Size           = UDim2.new(1,-70,0,20),
                Position       = UDim2.new(0,10,0,5),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = row,
            })

            if config.Desc then
                MakeLabel({
                    Text           = config.Desc,
                    Size           = UDim2.new(1,-60,0,12),
                    Position       = UDim2.new(0,10,0,21),
                    TextColor3     = T.TextSecondary,
                    TextSize       = 8,
                    Font           = T.FontRegular,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent         = row,
                })
            end

            local pill = MakeFrame({
                Size             = UDim2.new(0,34,0,18),
                Position         = UDim2.new(1,-44,0.5,-9),
                BackgroundColor3 = enabled and T.ToggleOn or T.ToggleOff,
                BorderSizePixel  = 0,
                Parent           = row,
            })
            Corner(pill, UDim.new(1,0))

            local dot = MakeFrame({
                Size             = UDim2.new(0,12,0,12),
                Position         = enabled and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent           = pill,
            })
            Corner(dot, UDim.new(1,0))

            local hitBtn = MakeButton({
                Size   = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text   = "",
                Parent = row,
            })

            local function SetToggle(val, silent)
                enabled = val
                Tween(dot,  {Position = enabled and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
                Tween(pill, {BackgroundColor3 = enabled and T.ToggleOn or T.ToggleOff})
                if not silent then callback(enabled) end
            end

            hitBtn.MouseButton1Click:Connect(function()
                SetToggle(not enabled)
            end)

            -- Hover
            hitBtn.MouseEnter:Connect(function()
                Tween(row, {BackgroundColor3 = Color3.fromRGB(34,34,44)})
            end)
            hitBtn.MouseLeave:Connect(function()
                Tween(row, {BackgroundColor3 = T.Card})
            end)

            local ToggleObj = {}
            function ToggleObj:Set(val)
                SetToggle(val, false)
            end
            function ToggleObj:Get()
                return enabled
            end
            return ToggleObj
        end

        -- -- Slider --------------------------------------------
        --[[
            local slider = Tab:CreateSlider({
                Name     = "Walk Speed",
                Min      = 16,
                Max      = 200,
                Default  = 50,
                Suffix   = "",       -- optional e.g. " studs/s"
                Callback = function(Value) end
            })
            slider:Set(100)
        ]]
        function Tab:CreateSlider(config)
            config = config or {}
            local T        = self._theme
            local minVal   = config.Min     or 0
            local maxVal   = config.Max     or 100
            local curVal   = config.Default or minVal
            local suffix   = config.Suffix  or ""
            local callback = config.Callback or function() end

            local TRACK_H  = IsMobile and 8  or 6
            local HANDLE_S = IsMobile and 20 or 14

            local row = MakeFrame({
                Size             = UDim2.new(1,0,0,T.SliderHeight),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(row)

            MakeLabel({
                Text           = config.Name or "Slider",
                Size           = UDim2.new(0.65,0,0,20),
                Position       = UDim2.new(0,12,0,8),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = row,
            })

            local valLbl = MakeLabel({
                Text           = tostring(curVal) .. suffix,
                Size           = UDim2.new(0.35,-12,0,20),
                Position       = UDim2.new(0.65,0,0,8),
                TextColor3     = T.Accent,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent         = row,
            })

            local track = MakeFrame({
                Size             = UDim2.new(1,-24,0,TRACK_H),
                Position         = UDim2.new(0,12,0,28),
                BackgroundColor3 = T.SliderTrack,
                BorderSizePixel  = 0,
                Parent           = row,
            })
            Corner(track, UDim.new(1,0))

            local initPct = (curVal - minVal) / (maxVal - minVal)
            local fill = MakeFrame({
                Size             = UDim2.new(initPct,0,1,0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(fill, UDim.new(1,0))

            local handle = MakeFrame({
                Size             = UDim2.new(0,HANDLE_S,0,HANDLE_S),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(initPct,0,0.5,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(handle, UDim.new(1,0))

            -- Hit area (larger for mobile)
            local hitArea = MakeButton({
                Size   = UDim2.new(1,0,0,30),
                Position = UDim2.new(0,0,0,18),
                BackgroundTransparency = 1,
                Text   = "",
                Parent = row,
            })

            local dragging = false

            local function updateFromX(screenX)
                local abs = track.AbsolutePosition
                local sz  = track.AbsoluteSize
                local rel = math.clamp((screenX - abs.X) / sz.X, 0, 1)
                curVal    = math.floor(minVal + rel * (maxVal - minVal))
                valLbl.Text     = tostring(curVal) .. suffix
                fill.Size       = UDim2.new(rel,0,1,0)
                handle.Position = UDim2.new(rel,0,0.5,0)
                callback(curVal)
            end

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

            local SliderObj = {}
            function SliderObj:Set(val)
                curVal = math.clamp(val, minVal, maxVal)
                local rel = (curVal - minVal) / (maxVal - minVal)
                valLbl.Text     = tostring(curVal) .. suffix
                fill.Size       = UDim2.new(rel,0,1,0)
                handle.Position = UDim2.new(rel,0,0.5,0)
                callback(curVal)
            end
            function SliderObj:Get()
                return curVal
            end
            return SliderObj
        end

        -- -- Button --------------------------------------------
        --[[
            Tab:CreateButton({
                Name     = "Click Me",
                Desc     = "Optional description",
                Callback = function() end
            })
        ]]
        function Tab:CreateButton(config)
            config = config or {}
            local T        = self._theme
            local callback = config.Callback or function() end

            local row = MakeButton({
                Size             = UDim2.new(1,0,0,T.ButtonHeight + (config.Desc and 18 or 0)),
                BackgroundColor3 = T.ButtonBg,
                Text             = "",
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(row)
            Stroke(row, T.Accent, 1)

            MakeLabel({
                Text           = config.Name or "Button",
                Size           = UDim2.new(1,-16,0,18),
                Position       = UDim2.new(0,12,0.5,config.Desc and -12 or -9),
                TextColor3     = T.Accent,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = row,
            })

            if config.Desc then
                MakeLabel({
                    Text           = config.Desc,
                    Size           = UDim2.new(1,-16,0,12),
                    Position       = UDim2.new(0,12,0.5,6),
                    TextColor3     = T.TextSecondary,
                    TextSize       = 8,
                    Font           = T.FontRegular,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent         = row,
                })
            end

            MakeLabel({
                Text       = ">",
                Size       = UDim2.new(0,20,1,0),
                Position   = UDim2.new(1,-28,0,0),
                TextColor3 = T.Accent,
                TextSize   = 12,
                Font       = T.FontBold,
                Parent     = row,
            })

            row.MouseEnter:Connect(function()
                Tween(row, {BackgroundColor3 = T.ButtonHover})
            end)
            row.MouseLeave:Connect(function()
                Tween(row, {BackgroundColor3 = T.ButtonBg})
            end)
            row.MouseButton1Click:Connect(function()
                Tween(row, {BackgroundColor3 = T.Accent}, 0.1)
                task.delay(0.1, function()
                    Tween(row, {BackgroundColor3 = T.ButtonBg})
                end)
                callback()
            end)
        end

        -- -- TextBox -------------------------------------------
        --[[
            local box = Tab:CreateTextBox({
                Name         = "Enter Name",
                Default      = "Type here...",
                ClearOnFocus = true,
                Numeric      = false,   -- only allow numbers
                Callback     = function(Value) end  -- fires on Enter / focus lost
            })
            box:Set("Hello")
        ]]
        function Tab:CreateTextBox(config)
            config = config or {}
            local T        = self._theme
            local callback = config.Callback or function() end

            local row = MakeFrame({
                Size             = UDim2.new(1,0,0,44),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(row)

            MakeLabel({
                Text           = config.Name or "TextBox",
                Size           = UDim2.new(1,-16,0,20),
                Position       = UDim2.new(0,12,0,8),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = row,
            })

            local inputFrame = MakeFrame({
                Size             = UDim2.new(1,-24,0,26),
                Position         = UDim2.new(0,12,0,20),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Parent           = row,
            })
            Corner(inputFrame, UDim.new(0,6))
            Stroke(inputFrame, T.SliderTrack, 1)

            local input = MakeInput({
                Size             = UDim2.new(1,-16,1,0),
                Position         = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1,
                Text             = config.Default or "",
                PlaceholderText  = config.Default or "Enter text...",
                TextColor3       = T.TextPrimary,
                PlaceholderColor3 = T.TextSecondary,
                TextSize         = T.TextSizeMD,
                Font             = T.FontRegular,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = config.ClearOnFocus or false,
                Parent           = inputFrame,
            })

            -- Focus highlight
            input.Focused:Connect(function()
                Tween(inputFrame, {BackgroundColor3 = Color3.fromRGB(32,30,20)})
                local s = inputFrame:FindFirstChildOfClass("UIStroke")
                if s then Tween(s, {Color = T.Accent}) end
            end)
            input.FocusLost:Connect(function(enterPressed)
                Tween(inputFrame, {BackgroundColor3 = T.InputBg})
                local s = inputFrame:FindFirstChildOfClass("UIStroke")
                if s then Tween(s, {Color = T.SliderTrack}) end

                -- Filter numeric
                if config.Numeric then
                    local num = tonumber(input.Text)
                    if not num then input.Text = config.Default or "0" end
                end
                callback(input.Text)
            end)

            local BoxObj = {}
            function BoxObj:Set(val)
                input.Text = tostring(val)
            end
            function BoxObj:Get()
                return input.Text
            end
            return BoxObj
        end

        -- -- Dropdown ------------------------------------------
        --[[
            local dd = Tab:CreateDropdown({
                Name     = "Team",
                Options  = {"Red", "Blue", "Green"},
                Default  = "Red",
                Callback = function(Value) end
            })
            dd:Set("Blue")
            dd:Refresh({"Orange", "Purple"})
        ]]
        function Tab:CreateDropdown(config)
            config = config or {}
            local T        = self._theme
            local options  = config.Options  or {}
            local selected = config.Default  or (options[1] or "None")
            local callback = config.Callback or function() end
            local isOpen   = false
            local ITEM_H   = IsMobile and 36 or 30

            local container = MakeFrame({
                Size             = UDim2.new(1,0,0,44),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(container)

            MakeLabel({
                Text           = config.Name or "Dropdown",
                Size           = UDim2.new(1,-16,0,20),
                Position       = UDim2.new(0,12,0,8),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = container,
            })

            -- Header button (selected value)
            local header = MakeButton({
                Size             = UDim2.new(1,-24,0,26),
                Position         = UDim2.new(0,12,0,20),
                BackgroundColor3 = T.InputBg,
                Text             = "",
                Parent           = container,
            })
            Corner(header, UDim.new(0,6))
            Stroke(header, T.SliderTrack, 1)

            local selectedLbl = MakeLabel({
                Text           = selected,
                Size           = UDim2.new(1,-28,1,0),
                Position       = UDim2.new(0,8,0,0),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeMD,
                Font           = T.FontRegular,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = header,
            })

            local arrow = MakeLabel({
                Text       = "v",
                Size       = UDim2.new(0,20,1,0),
                Position   = UDim2.new(1,-22,0,0),
                TextColor3 = T.Accent,
                TextSize   = 14,
                Font       = T.FontBold,
                Parent     = header,
            })

            -- Dropdown list
            local dropFrame = MakeFrame({
                Size             = UDim2.new(1,-24,0,0),
                Position         = UDim2.new(0,12,0,44),
                BackgroundColor3 = T.DropdownBg,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                Parent           = container,
            })
            Corner(dropFrame, UDim.new(0,6))
            Stroke(dropFrame, T.SliderTrack, 1)
            ListLayout(dropFrame, 2)
            Padding(dropFrame, 4, 4, 4, 4)

            local function BuildItems()
                for _, c in ipairs(dropFrame:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local item = MakeButton({
                        Size             = UDim2.new(1,0,0,ITEM_H),
                        BackgroundColor3 = T.DropdownItem,
                        Text             = "  " .. opt,
                        TextColor3       = opt == selected and T.Accent or T.TextPrimary,
                        TextSize         = T.TextSizeMD,
                        Font             = opt == selected and T.FontBold or T.FontRegular,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        Parent           = dropFrame,
                    })
                    Corner(item, UDim.new(0,4))
                    item.MouseEnter:Connect(function()
                        Tween(item, {BackgroundColor3 = T.DropdownHover})
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item, {BackgroundColor3 = T.DropdownItem})
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        selectedLbl.Text = opt
                        callback(opt)
                        BuildItems()
                        -- Close
                        isOpen = false
                        arrow.Text = "v"
                        Tween(container, {Size = UDim2.new(1,0,0,44)})
                        Tween(dropFrame,  {Size = UDim2.new(1,-24,0,0)})
                    end)
                end
            end

            BuildItems()

            local function OpenClose()
                isOpen = not isOpen
                arrow.Text = isOpen and "^" or "v"
                local listH = math.min(#options, 5) * (ITEM_H + 2) + 8
                if isOpen then
                    Tween(container, {Size = UDim2.new(1,0,0,44 + listH + 6)}, 0.2)
                    Tween(dropFrame,  {Size = UDim2.new(1,-24,0,listH)},         0.2)
                else
                    Tween(container, {Size = UDim2.new(1,0,0,44)},   0.2)
                    Tween(dropFrame,  {Size = UDim2.new(1,-24,0,0)},  0.2)
                end
            end

            header.MouseButton1Click:Connect(OpenClose)

            local DDObj = {}
            function DDObj:Set(val)
                selected         = val
                selectedLbl.Text = val
                BuildItems()
            end
            function DDObj:Refresh(newOptions)
                options = newOptions
                BuildItems()
            end
            function DDObj:Get()
                return selected
            end
            return DDObj
        end

        -- -- Color Picker --------------------------------------
        --[[
            local picker = Tab:CreateColorPicker({
                Name     = "Highlight Color",
                Default  = Color3.fromRGB(255, 0, 0),
                Callback = function(Color3Value) end
            })
            picker:Set(Color3.fromRGB(0,255,0))
        ]]
        function Tab:CreateColorPicker(config)
            config = config or {}
            local T        = self._theme
            local curColor = config.Default or Color3.fromRGB(255,0,0)
            local callback = config.Callback or function() end
            local isOpen   = false

            local container = MakeFrame({
                Size             = UDim2.new(1,0,0,40),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                LayoutOrder      = nextOrder(),
                Parent           = self._page,
            })
            Corner(container)

            MakeLabel({
                Text           = config.Name or "Color Picker",
                Size           = UDim2.new(1,-70,0,22),
                Position       = UDim2.new(0,12,0,8),
                TextColor3     = T.TextPrimary,
                TextSize       = T.TextSizeLG,
                Font           = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent         = container,
            })

            local swatch = MakeButton({
                Size             = UDim2.new(0,40,0,24),
                Position         = UDim2.new(1,-52,0.5,-12),
                BackgroundColor3 = curColor,
                Text             = "",
                Parent           = container,
            })
            Corner(swatch, UDim.new(0,6))
            Stroke(swatch, T.SliderTrack, 1)

            -- Simple hue slider + preview (lightweight colour picker)
            local pickerFrame = MakeFrame({
                Size             = UDim2.new(1,-24,0,0),
                Position         = UDim2.new(0,12,0,42),
                BackgroundColor3 = T.DropdownBg,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                Parent           = container,
            })
            Corner(pickerFrame, UDim.new(0,6))

            -- Hue label
            MakeLabel({
                Text       = "Hue",
                Size       = UDim2.new(0,30,0,20),
                Position   = UDim2.new(0,8,0,8),
                TextColor3 = T.TextSecondary,
                TextSize   = T.TextSizeSM + 1,
                Font       = T.FontBold,
                Parent     = pickerFrame,
            })

            -- Hue track
            local hueTrack = MakeFrame({
                Size             = UDim2.new(1,-50,0,10),
                Position         = UDim2.new(0,42,0,13),
                BackgroundColor3 = Color3.fromRGB(40,40,50),
                BorderSizePixel  = 0,
                Parent           = pickerFrame,
            })
            Corner(hueTrack, UDim.new(1,0))

            -- Rainbow gradient on hue track
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,1,1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,1,1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
            })
            gradient.Parent = hueTrack

            local h,s,v = Color3.toHSV(curColor)
            local hueHandle = MakeFrame({
                Size             = UDim2.new(0,14,0,14),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(h,0,0.5,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent           = hueTrack,
            })
            Corner(hueHandle, UDim.new(1,0))

            -- Sat/Val sliders
            MakeLabel({
                Text       = "Sat",
                Size       = UDim2.new(0,30,0,20),
                Position   = UDim2.new(0,8,0,30),
                TextColor3 = T.TextSecondary,
                TextSize   = T.TextSizeSM + 1,
                Font       = T.FontBold,
                Parent     = pickerFrame,
            })
            local satTrack = MakeFrame({
                Size             = UDim2.new(1,-50,0,10),
                Position         = UDim2.new(0,42,0,35),
                BackgroundColor3 = Color3.fromRGB(40,40,50),
                BorderSizePixel  = 0,
                Parent           = pickerFrame,
            })
            Corner(satTrack, UDim.new(1,0))
            local satHandle = MakeFrame({
                Size             = UDim2.new(0,14,0,14),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(s,0,0.5,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent           = satTrack,
            })
            Corner(satHandle, UDim.new(1,0))

            MakeLabel({
                Text       = "Val",
                Size       = UDim2.new(0,30,0,20),
                Position   = UDim2.new(0,8,0,52),
                TextColor3 = T.TextSecondary,
                TextSize   = T.TextSizeSM + 1,
                Font       = T.FontBold,
                Parent     = pickerFrame,
            })
            local valTrack = MakeFrame({
                Size             = UDim2.new(1,-50,0,10),
                Position         = UDim2.new(0,42,0,57),
                BackgroundColor3 = Color3.fromRGB(40,40,50),
                BorderSizePixel  = 0,
                Parent           = pickerFrame,
            })
            Corner(valTrack, UDim.new(1,0))
            local valHandle = MakeFrame({
                Size             = UDim2.new(0,14,0,14),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(v,0,0.5,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent           = pickerFrame,
            })
            Corner(valHandle, UDim.new(1,0))

            local PICKER_H = 80

            local function UpdateColor()
                curColor         = Color3.fromHSV(h,s,v)
                swatch.BackgroundColor3 = curColor
                callback(curColor)
            end

            local function SliderDrag(track, handleRef, onUpdate)
                local dragging = false
                local hitArea  = MakeButton({Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,-10),BackgroundTransparency=1,Text="",Parent=track})
                hitArea.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                        dragging=true updateFromTrack(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                        updateFromTrack(inp.Position.X)
                    end
                end)
                function updateFromTrack(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                    handleRef.Position = UDim2.new(rel,0,0.5,0)
                    onUpdate(rel)
                    UpdateColor()
                end
            end

            -- Hook up hue drag
            local hDragging=false
            local function hUpdate(x) local r=math.clamp((x-hueTrack.AbsolutePosition.X)/hueTrack.AbsoluteSize.X,0,1) hueHandle.Position=UDim2.new(r,0,0.5,0) h=r UpdateColor() end
            local hHit=MakeButton({Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,-10),BackgroundTransparency=1,Text="",Parent=hueTrack})
            hHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hDragging=true hUpdate(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hDragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if hDragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then hUpdate(i.Position.X) end end)

            local sDragging=false
            local function sUpdate(x) local r=math.clamp((x-satTrack.AbsolutePosition.X)/satTrack.AbsoluteSize.X,0,1) satHandle.Position=UDim2.new(r,0,0.5,0) s=r UpdateColor() end
            local sHit=MakeButton({Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,-10),BackgroundTransparency=1,Text="",Parent=satTrack})
            sHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sDragging=true sUpdate(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sDragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if sDragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then sUpdate(i.Position.X) end end)

            local vDragging=false
            local function vUpdate(x) local r=math.clamp((x-valTrack.AbsolutePosition.X)/valTrack.AbsoluteSize.X,0,1) valHandle.Position=UDim2.new(r,0,0.5,0) v=r UpdateColor() end
            local vHit=MakeButton({Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,-10),BackgroundTransparency=1,Text="",Parent=valTrack})
            vHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then vDragging=true vUpdate(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then vDragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if vDragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then vUpdate(i.Position.X) end end)

            -- Toggle open/close
            swatch.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Tween(container,    {Size=UDim2.new(1,0,0,40+PICKER_H+10)},0.2)
                    Tween(pickerFrame,  {Size=UDim2.new(1,-24,0,PICKER_H)},    0.2)
                else
                    Tween(container,    {Size=UDim2.new(1,0,0,40)},           0.2)
                    Tween(pickerFrame,  {Size=UDim2.new(1,-24,0,0)},          0.2)
                end
            end)

            local PickerObj = {}
            function PickerObj:Set(color)
                curColor = color
                h,s,v    = Color3.toHSV(color)
                swatch.BackgroundColor3 = color
                hueHandle.Position = UDim2.new(h,0,0.5,0)
                satHandle.Position = UDim2.new(s,0,0.5,0)
                valHandle.Position = UDim2.new(v,0,0.5,0)
                callback(color)
            end
            function PickerObj:Get()
                return curColor
            end
            return PickerObj
        end

        return Tab
    end -- CreateTab

    return Window
end -- CreateWindow

-- ============================================================
--  UTILITY: Keybind helper (PC only)
-- ============================================================
function KaolinLib:BindKey(keyCode, callback)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == keyCode then callback() end
    end)
end

-- ============================================================
--  UTILITY: Toggle GUI visibility via key
-- ============================================================
function KaolinLib:BindToggleKey(keyCode, window)
    self:BindKey(keyCode, function()
        local frame   = window._frame
        local showBtn = window._gui and window._gui:FindFirstChildOfClass("TextButton")
        frame.Visible = not frame.Visible
        if showBtn then showBtn.Visible = not frame.Visible end
    end)
end

print("[K] KaolinLib v1.0 loaded! | Mobile:", IsMobile)
return KaolinLib
