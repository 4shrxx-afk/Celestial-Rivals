--[[
    Celestial Rivals UI Library
    Style: MAVISDMA / Past Owl reference (dark, rounded, purple accent #9496FF)
    Luau / Executor-ready (loadstring, gethui, no dependencies)

    Best-practices applied (from Roblox Creator Docs + DevForum research):
    ----------------------------------------------------------------------
    1. ROUNDED CORNERS: UICorner with Offset, never Scale (except circles).
       Scale distorts on different sizes and can force "pill" shapes:
         radius = min(min(w,h)/2, scale*min(w,h) + offset)
       We use: Main=14px, Modals=12px, Cards/Rows=8-10px, Toggles=7px,
       Slider track=4px tall -> 2px radius, Knobs/Wheel dots = Scale 1,0 (perfect circle).
       UICorner cannot go on ScrollingFrame -> we corner inner rows, not the scroller.
    2. BORDERS: UIStroke, not BorderColor3. Thickness=1, LineJoinMode=Round,
       ApplyStrokeMode=Border, Transparency ~0.90-0.94 white for subtle hairline.
       Unlimited strokes are live but keep <300 on screen for low-end perf.
       Never tween UIStroke.Thickness on text (glyph re-raster = flicker/lag).
    3. SHADOWS: native UIShadow (2026 live, faster than 9-slice). Blur 40-60,
       Transparency 0.5-0.7. pcall-wrapped for old clients. Keep <100 shadows.
       Shadows may look jagged on huge corner radius - we keep radius <=14.
    4. CLIPPING: UICorner does NOT clip descendants. CanvasGroup does but goes
       blurry/black on low memory. So we avoid CanvasGroup for main window and
       instead set ClipsDescendants=true on dropdown lists + corner every row.
    5. FONTS: Gotham family auto-maps to Montserrat (Gotham removed May 2024).
       BuilderSans is the new platform font. For executor compat we use
       Enum.Font.GothamMedium / GothamBold / Gotham (works everywhere).
       TextSize: Title 22, Tab 14, Row 13, Small 11-12. TextStrokeTransparency=1.
    6. SCALING: AnchorPoint 0.5,0.5 + centered UDim2 scale position so window is
       resolution independent. UIScale object drives "Interface scale" slider
       (50%-150%). Base size 860x600 designed at 1080p, shrinks on small screens.
    7. ANIMATION: TweenService TweenInfo(0.18, Quint, Out) for hover/toggle/slider.
       No UIGradient.Color tweening every frame (rebuilds sequence = expensive).
       Animate Offset/Rotation instead if you need gradient motion.
    8. PARENTING: gethui() -> CoreGui -> PlayerGui fallback. ScreenGui:
       ResetOnSpawn=false, ZIndexBehavior=Sibling (required for correct clipping),
       DisplayOrder=999, IgnoreGuiInset=true. Destroy duplicate on re-execute.
    9. DRAG: UIDragDetector (C-side, perf) if available, else classic
       InputBegan/InputChanged TopBar drag (mouse + touch). Drag handle = top bar only.
    10. COLOR WHEEL MATH (HSV cylinder):
        H = (pi - atan2(dY,dX)) / (2*pi)   -- angle around wheel
        S = dist(center,mouse) / radius    -- distance from center
        V = 1 - (mouseY - sliderY)/sliderH -- vertical slider
        Color3.fromHSV(H,S,V). Inverse for setting from Color3: ToHSV().
--]]

local Library = {}
Library.Flags = {} -- ["ToggleName"] = true/false, ["SliderName"] = number, etc.
Library._Accent = Color3.fromRGB(148, 150, 255) -- #9496FF default from reference
Library._ThemeName = "Dark"
Library._Scale = 1
Library._Windows = {}

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Themes (Background / Sidebar / Card / strokes / text)
local Themes = {
    Dark = {
        Main = Color3.fromRGB(18, 18, 22),      -- #121216 main window
        Sidebar = Color3.fromRGB(22, 22, 27),   -- #16161B left nav
        Card = Color3.fromRGB(28, 28, 34),      -- #1C1C22 rows / modals
        Row = Color3.fromRGB(24, 24, 30),       -- row bg
        RowHover = Color3.fromRGB(32, 32, 40),
        Track = Color3.fromRGB(42, 42, 51),     -- slider track
        Stroke = Color3.fromRGB(255, 255, 255), -- with transparency 0.93
        StrokeTrans = 0.93,
        Text = Color3.fromRGB(232, 232, 234),
        TextDim = Color3.fromRGB(138, 138, 149),
        TextDark = Color3.fromRGB(110, 110, 122),
        Search = Color3.fromRGB(30, 30, 36),
    },
    Black = {
        Main = Color3.fromRGB(8, 8, 10),
        Sidebar = Color3.fromRGB(12, 12, 14),
        Card = Color3.fromRGB(16, 16, 20),
        Row = Color3.fromRGB(14, 14, 18),
        RowHover = Color3.fromRGB(24, 24, 30),
        Track = Color3.fromRGB(30, 30, 38),
        Stroke = Color3.fromRGB(255, 255, 255),
        StrokeTrans = 0.94,
        Text = Color3.fromRGB(235, 235, 238),
        TextDim = Color3.fromRGB(130, 130, 142),
        TextDark = Color3.fromRGB(100, 100, 112),
        Search = Color3.fromRGB(18, 18, 22),
    },
    Light = {
        Main = Color3.fromRGB(242, 242, 245),
        Sidebar = Color3.fromRGB(235, 235, 240),
        Card = Color3.fromRGB(255, 255, 255),
        Row = Color3.fromRGB(248, 248, 251),
        RowHover = Color3.fromRGB(238, 238, 244),
        Track = Color3.fromRGB(220, 220, 228),
        Stroke = Color3.fromRGB(0, 0, 0),
        StrokeTrans = 0.9,
        Text = Color3.fromRGB(25, 25, 30),
        TextDim = Color3.fromRGB(120, 120, 132),
        TextDark = Color3.fromRGB(150, 150, 162),
        Search = Color3.fromRGB(228, 228, 234),
    },
}

local AccentPresets = {
    Color3.fromRGB(148, 150, 255), -- #9496FF default
    Color3.fromRGB(123, 124, 248), -- deeper purple
    Color3.fromRGB(142, 184, 255), -- blue
    Color3.fromRGB(142, 214, 255), -- cyan
    Color3.fromRGB(142, 255, 200), -- mint
}

-- Standard HSV wheel asset (Roblox-hosted, no external dependency)
local WHEEL_ASSET = "rbxassetid://6020299385"

--// Helpers ---------------------------------------------------------------

local function New(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        -- allow OnClick / events passed as functions is handled by caller
        local ok, _ = pcall(function()
            if k ~= "Parent" or typeof(v) == "Instance" then
                obj[k] = v
            end
        end)
        if not ok then
            warn("[CelestialUI] bad prop " .. tostring(k))
        end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Corner(parent, offset, scale)
    -- Offset-based rounding. Use scale only for perfect circles (1,0).
    local c = Instance.new("UICorner")
    if scale then
        c.CornerRadius = UDim.new(scale, offset or 0)
    else
        c.CornerRadius = UDim.new(0, offset or 8)
    end
    c.Parent = parent
    return c
end

local function Stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255, 255, 255)
    s.Transparency = transparency ~= nil and transparency or 0.93
    s.Thickness = thickness or 1
    s.LineJoinMode = Enum.LineJoinMode.Round
    pcall(function()
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end)
    s.Parent = parent
    return s
end

local function Shadow(parent, transparency, blur)
    -- UIShadow is live (2026). pcall for old clients / executors.
    local ok, sh = pcall(function()
        local x = Instance.new("UIShadow")
        x.Color = Color3.fromRGB(0, 0, 0)
        x.Transparency = transparency or 0.6
        pcall(function() x.BlurRadius = blur or 50 end)
        x.Parent = parent
        return x
    end)
    if ok then return sh end
    return nil
end

local function Pad(parent, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 10)
    p.PaddingTop = UDim.new(0, t or 8)
    p.PaddingRight = UDim.new(0, r or 10)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.Parent = parent
    return p
end

local function Tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    -- Prefer native UIDragDetector (C-side, smoother) when present
    pcall(function()
        local d = Instance.new("UIDragDetector")
        d.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
        d.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale
        d.Parent = handle
        -- If it parents fine, native drag handles it; keep Lua fallback too for touch edge cases
    end)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function GetParent()
    local ok, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)
    if ok and hui then return hui end
    local ok2, pg = pcall(function() return CoreGui end)
    if ok2 and pg then
        -- Some executors block CoreGui; try/catch at instance time
        local test = pcall(function()
            local g = Instance.new("ScreenGui")
            g.Parent = pg
            g:Destroy()
        end)
        if test then return pg end
    end
    return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
end

local function ToHex(c)
    return string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
end

local function FromHex(h)
    h = h:gsub("#", "")
    if #h ~= 6 then return nil end
    local r = tonumber(h:sub(1,2), 16)
    local g = tonumber(h:sub(3,4), 16)
    local b = tonumber(h:sub(5,6), 16)
    if r and g and b then
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

--// Window ---------------------------------------------------------------

function Library:CreateWindow(opts)
    opts = opts or {}
    local title1 = opts.Title or "CELESTIAL"
    local title2 = opts.AccentTitle or "RIVALS"
    local username = opts.User or LocalPlayer and LocalPlayer.DisplayName or "Player"
    local themeName = opts.Theme or self._ThemeName or "Dark"
    local accent = opts.Accent or self._Accent
    local winSize = opts.Size or UDim2.fromOffset(860, 600)

    local T = Themes[themeName] or Themes.Dark
    self._Accent = accent

    -- kill duplicate
    local rootParent = GetParent()
    pcall(function()
        local old = rootParent:FindFirstChild("CelestialRivals")
        if old then old:Destroy() end
    end)

    local Gui = New("ScreenGui", {
        Name = "CelestialRivals",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        IgnoreGuiInset = true,
    }, nil)
    pcall(function()
        Gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
        Gui.ScreenInsets = Enum.ScreenInsets.None
    end)
    Gui.Parent = rootParent

    -- dim backdrop (very subtle, like reference purple glow)
    local Backdrop = New("Frame", {
        Name = "Backdrop",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(10, 8, 20),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
    }, nil)
    Backdrop.Parent = Gui

    local glowA = New("Frame", {
        AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(0.35, 0.5), BackgroundColor3 = Color3.fromRGB(90, 70, 160),
        BackgroundTransparency = 0.85, BorderSizePixel = 0,
    }, nil)
    glowA.Parent = Backdrop
    Corner(glowA, 0, 1)

    local glowB = glowA:Clone()
    glowB.AnchorPoint = Vector2.new(1, 1)
    glowB.Position = UDim2.fromScale(1, 1)
    glowB.Parent = Backdrop

    -- main window (UIScale drives Interface scale slider)
    local Scale = New("UIScale", { Scale = self._Scale or 1 }, nil)

    local Main = New("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = winSize,
        BackgroundColor3 = T.Main,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Active = true,
    }, nil)
    Scale.Parent = Main
    Main.Parent = Gui
    Corner(Main, 14)
    Stroke(Main, T.Stroke, T.StrokeTrans, 1)
    Shadow(Main, 0.55, 60)

    -- shrink on tiny screens
    local function FitScreen()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local s = math.clamp(math.min(vp.X / 1000, vp.Y / 700), 0.65, 1.1)
        -- multiply with user scale slider value
        Main.Size = UDim2.fromOffset(winSize.X.Offset, winSize.Y.Offset)
        Scale.Scale = s * (Library._Scale or 1)
    end
    pcall(FitScreen)
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(FitScreen)
    end

    --// Top drag bar (invisible hit area at very top for dragging)
    local DragBar = New("Frame", {
        Name = "DragBar",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, nil)
    DragBar.Parent = Main
    MakeDraggable(Main, DragBar)

    --// Sidebar -----------------------------------------------------------
    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(0, 220, 1, -56),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
    }, nil)
    Sidebar.Parent = Main
    Corner(Sidebar, 10)
    Stroke(Sidebar, T.Stroke, 0.95, 1)

    -- search
    local SearchBox = New("Frame", {
        Name = "Search",
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 0, 32),
        BackgroundColor3 = T.Search,
        BorderSizePixel = 0,
    }, nil)
    SearchBox.Parent = Sidebar
    Corner(SearchBox, 8)
    Stroke(SearchBox, T.Stroke, 0.95, 1)

    New("TextLabel", {
        Text = "○",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = T.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
    }, nil).Parent = SearchBox

    local SearchInput = New("TextBox", {
        PlaceholderText = "Search function ...",
        PlaceholderColor3 = T.TextDark,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = T.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, nil)
    SearchInput.Parent = SearchBox

    -- logo MAVISDMA-style: "CELESTIAL" white + "RIVALS" accent
    local Logo = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 34),
    }, nil)
    Logo.Parent = Sidebar

    local L1 = New("TextLabel", {
        Text = title1,
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        TextColor3 = T.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, nil)
    L1.Parent = Logo
    local L2 = New("TextLabel", {
        Text = title2,
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        TextColor3 = accent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, L1.TextBounds.X + 4, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, nil)
    L2.Parent = Logo
    -- keep L2 next to L1 after text sizes resolve
    L1:GetPropertyChangedSignal("TextBounds"):Connect(function()
        L2.Position = UDim2.new(0, L1.TextBounds.X + 4, 0, 0)
    end)

    local TabHolder = New("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.new(0, 8, 0, 82),
        Size = UDim2.new(1, -16, 1, -90),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, nil)
    TabHolder.Parent = Sidebar
    local TabLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }, nil)
    TabLayout.Parent = TabHolder

    --// Content area ------------------------------------------------------
    local TopRight = New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 10),
        Size = UDim2.new(0, 220, 0, 28),
    }, nil)
    TopRight.Parent = Main

    New("TextLabel", {
        Text = "ⓘ",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = T.TextDark,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 22, 1, 0),
        Position = UDim2.new(1, -116, 0, 0),
    }, nil).Parent = TopRight

    local UserLabel = New("TextLabel", {
        Text = username,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -94, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, nil)
    UserLabel.Parent = TopRight

    local Avatar = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(200, 200, 205),
        BorderSizePixel = 0,
    }, nil)
    Avatar.Parent = TopRight
    Corner(Avatar, 0, 1)
    local AvatarIcon = New("TextLabel", {
        Text = "◉",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(40, 40, 45),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, nil)
    AvatarIcon.Parent = Avatar

    local CloseBtn = New("TextButton", {
        Text = "✕",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = T.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 244, 0, 10),
        AutoButtonColor = false,
    }, nil)
    -- actually place settings/close inside content header; hide default, use custom below
    CloseBtn.Visible = false
    CloseBtn.Parent = Main

    local PageHolder = New("Frame", {
        Name = "Pages",
        Position = UDim2.new(0, 244, 0, 44),
        Size = UDim2.new(1, -256, 1, -56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, nil)
    PageHolder.Parent = Main

    --// Window object ------------------------------------------------------
    local Window = {
        Gui = Gui, Main = Main, Sidebar = Sidebar,
        Tabs = {}, Pages = {}, _TabOrder = 0,
        _ActiveTab = nil, _Rows = {}, -- for search
        Accent = accent, Theme = T, ThemeName = themeName,
    }

    -- theming helpers
    local Themed = {} -- {obj, role}
    local function RegisterTheme(obj, role)
        table.insert(Themed, {Obj = obj, Role = role})
    end
    RegisterTheme(Main, "Main")
    RegisterTheme(Sidebar, "Sidebar")
    RegisterTheme(SearchBox, "Search")
    SearchInput.PlaceholderColor3 = T.TextDark

    function Window:SetAccent(color)
        self.Accent = color
        Library._Accent = color
        L2.TextColor3 = color
        -- recolor active tab bar, toggles on, slider fills
        for _, tab in pairs(self.Tabs) do
            if tab.Button and tab.Active then
                tab.Indicator.BackgroundColor3 = color
            end
        end
        for _, fn in ipairs(self._AccentUpdaters or {}) do
            pcall(fn, color)
        end
    end
    Window._AccentUpdaters = {}

    function Window:SetTheme(name)
        local NT = Themes[name]
        if not NT then return end
        self.Theme = NT
        self.ThemeName = name
        Library._ThemeName = name
        Main.BackgroundColor3 = NT.Main
        Sidebar.BackgroundColor3 = NT.Sidebar
        SearchBox.BackgroundColor3 = NT.Search
        for _, e in ipairs(Themed) do
            if e.Role == "Card" and e.Obj and e.Obj.Parent then
                e.Obj.BackgroundColor3 = NT.Card
            elseif e.Role == "Row" and e.Obj and e.Obj.Parent then
                if not e.Obj:GetAttribute("On") then
                    e.Obj.BackgroundColor3 = NT.Row
                end
            end
        end
        -- update all text
        for _, d in ipairs(Main:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                local role = d:GetAttribute("TRole")
                if role == "Primary" then d.TextColor3 = NT.Text
                elseif role == "Dim" then d.TextColor3 = NT.TextDim
                elseif role == "Dark" then d.TextColor3 = NT.TextDark end
            elseif d:IsA("UIStroke") then
                if d:GetAttribute("Hairline") then
                    d.Color = NT.Stroke
                    d.Transparency = NT.StrokeTrans
                end
            end
        end
    end

    function Window:SetScale(s)
        Library._Scale = math.clamp(s, 0.5, 1.5)
        FitScreen()
    end

    function Window:Toggle(visible)
        if visible == nil then visible = not Main.Visible end
        Main.Visible = visible
        Backdrop.Visible = visible
    end

    function Window:Unload()
        Gui:Destroy()
    end

    function Window:Notify(text, sub)
        -- small toast bottom-right of Main
        local toast = New("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -14, 1, -14),
            Size = UDim2.new(0, 250, 0, 56),
            BackgroundColor3 = self.Theme.Card,
            BorderSizePixel = 0,
            ZIndex = 50,
        }, nil)
        toast.Parent = Main
        Corner(toast, 10)
        local st = Stroke(toast, self.Theme.Stroke, 0.93, 1)
        st:SetAttribute("Hairline", true)
        RegisterTheme(toast, "Card")
        New("TextLabel", {
            Text = text or "Saved",
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = self.Theme.Text, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, nil).Parent = toast
        New("TextLabel", {
            Text = sub or "",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = self.Theme.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, nil).Parent = toast
        toast.GroupTransparency = 1
        -- fade in via BackgroundTransparency tween on children is complex; simple pop
        Tween(toast, {Position = UDim2.new(1, -14, 1, -70)}, 0.25)
        task.delay(2.2, function()
            local tw = Tween(toast, {Position = UDim2.new(1, -14, 1, -14)}, 0.25)
            tw.Completed:Wait()
            pcall(function() toast:Destroy() end)
        end)
    end

    -- Search filtering
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(SearchInput.Text)
        for _, row in ipairs(Window._Rows) do
            if q == "" then
                row.Frame.Visible = true
            else
                local n = string.lower(row.Name or "")
                row.Frame.Visible = (string.find(n, q, 1, true) ~= nil)
            end
        end
    end)

    -- Toggle UI keybind (RightShift + Insert)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
            Window:Toggle()
        end
    end)

    -- Settings + ColorPicker modals are built lazily below (shared)
    -- Forward declare
    local SettingsModal, ColorModal, ColorState, Tooltip

    --// Color picker popup (matches reference: wheel + 3 sliders + hex) ------
    local function BuildColorModal()
        local modal = New("Frame", {
            Name = "ColorPicker",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 120, 0.5, 0),
            Size = UDim2.new(0, 228, 0, 330),
            BackgroundColor3 = Window.Theme.Card,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 40,
        }, nil)
        modal.Parent = Main
        Corner(modal, 12)
        local mst = Stroke(modal, Window.Theme.Stroke, 0.92, 1)
        mst:SetAttribute("Hairline", true)
        Shadow(modal, 0.5, 40)
        RegisterTheme(modal, "Card")

        local wheel = New("ImageButton", {
            Image = WHEEL_ASSET,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 16),
            Size = UDim2.new(0, 150, 0, 150),
            ZIndex = 41,
            AutoButtonColor = false,
        }, nil)
        wheel.Parent = modal
        -- fallback if asset fails: conical UIGradient circle
        local wheelCorner = Corner(wheel, 0, 1)

        local dot = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 42,
        }, nil)
        dot.Parent = wheel
        Corner(dot, 0, 1)
        Stroke(dot, Color3.fromRGB(0, 0, 0), 0.4, 2)

        -- 3 thin sliders under wheel (Hue rainbow / Sat / Val) like reference
        local sliders = {}
        local defs = {
            {Name = "H", Grad = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
            })},
            {Name = "S", Grad = nil}, -- set dynamically
            {Name = "V", Grad = nil},
        }
        for i, d in ipairs(defs) do
            local bar = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 176 + (i-1)*22),
                Size = UDim2.new(0, 180, 0, 6),
                BackgroundColor3 = Color3.fromRGB(40, 40, 48),
                BorderSizePixel = 0,
                ZIndex = 41,
            }, nil)
            bar.Parent = modal
            Corner(bar, 3)
            local grad = New("UIGradient", { Rotation = 0, Color = d.Grad or ColorSequence.new(Color3.fromRGB(255,255,255)) }, nil)
            grad.Parent = bar
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
                BackgroundColor3 = Color3.fromRGB(237, 237, 239),
                BorderSizePixel = 0,
                ZIndex = 42,
            }, nil)
            knob.Parent = bar
            Corner(knob, 0, 1)
            sliders[d.Name] = {Bar = bar, Knob = knob, Grad = grad}
        end

        local hexBox = New("TextBox", {
            Text = "#9496FF",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Window.Theme.Text,
            BackgroundColor3 = Window.Theme.Row,
            Position = UDim2.new(0, 24, 0, 248),
            Size = UDim2.new(0, 140, 0, 28),
            ZIndex = 41,
            ClearTextOnFocus = false,
        }, nil)
        hexBox.Parent = modal
        Corner(hexBox, 7)
        RegisterTheme(hexBox, "Row")

        local copyBtn = New("TextButton", {
            Text = "⧉",
            Font = Enum.Font.Gotham, TextSize = 14,
            TextColor3 = Window.Theme.TextDim,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 170, 0, 248),
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 41,
            AutoButtonColor = false,
        }, nil)
        copyBtn.Parent = modal

        local saveBtn = New("TextButton", {
            Text = "Set color",
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = accent,
            Position = UDim2.new(0, 24, 0, 284),
            Size = UDim2.new(0, 180, 0, 30),
            ZIndex = 41,
            AutoButtonColor = false,
        }, nil)
        saveBtn.Parent = modal
        Corner(saveBtn, 8)

        return {
            Frame = modal, Wheel = wheel, Dot = dot,
            Sliders = sliders, Hex = hexBox, Save = saveBtn,
        }
    end
    ColorModal = BuildColorModal()

    -- HSV state + math (see header note 10)
    local H, S, V = 0.66, 0.42, 1
    local colorCallback = nil
    local colorPreviewObjs = {}

    local function RefreshColorUI()
        local col = Color3.fromHSV(H, S, V)
        -- wheel dot position
        local r = (ColorModal.Wheel.AbsoluteSize.X / 2) * S
        local ang = H * math.pi * 2
        ColorModal.Dot.Position = UDim2.new(0.5, math.cos(ang) * r, 0.5, -math.sin(ang) * r)
        -- slider knobs
        ColorModal.Sliders.H.Knob.Position = UDim2.new(H, 0, 0.5, 0)
        ColorModal.Sliders.S.Knob.Position = UDim2.new(S, 0, 0.5, 0)
        ColorModal.Sliders.V.Knob.Position = UDim2.new(V, 0, 0.5, 0)
        -- dynamic gradients for S/V bars
        ColorModal.Sliders.S.Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 0, V)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(H, 1, V)),
        })
        ColorModal.Sliders.V.Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(H, S, 1)),
        })
        ColorModal.Hex.Text = ToHex(col)
        ColorModal.Save.BackgroundColor3 = col
        for _, o in ipairs(colorPreviewObjs) do
            pcall(function() o.BackgroundColor3 = col end)
        end
        if Tooltip and Tooltip.Visible then
            Tooltip.ColorPreview.BackgroundColor3 = col
            local rr, gg, bb = math.floor(col.R*255+0.5), math.floor(col.G*255+0.5), math.floor(col.B*255+0.5)
            Tooltip.RGB.Text = string.format("RGB: %d %d %d", rr, gg, bb)
        end
    end

    local draggingWheel, draggingSlider = false, nil
    ColorModal.Wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingWheel = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingWheel = false
            draggingSlider = nil
        end
    end)
    -- sample wheel each frame while held (cheap, only when picker open)
    RunService.RenderStepped:Connect(function()
        if not ColorModal.Frame.Visible then return end
        local mouse = LocalPlayer and LocalPlayer:GetMouse()
        if draggingWheel and mouse then
            local c = ColorModal.Wheel.AbsolutePosition + ColorModal.Wheel.AbsoluteSize / 2
            local d = Vector2.new(mouse.X, mouse.Y) - c
            local radius = ColorModal.Wheel.AbsoluteSize.X / 2
            local mag = math.clamp(d.Magnitude / radius, 0, 1)
            local h = (math.pi - math.atan2(d.Y, d.X)) / (math.pi * 2)
            if h < 0 then h += 1 end
            H, S = h % 1, mag
            RefreshColorUI()
        end
    end)
    for key, s in pairs(ColorModal.Sliders) do
        s.Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = key
                -- jump to click
                local rel = math.clamp((input.Position.X - s.Bar.AbsolutePosition.X) / math.max(s.Bar.AbsoluteSize.X, 1), 0, 1)
                if key == "H" then H = rel elseif key == "S" then S = rel else V = rel end
                RefreshColorUI()
            end
        end)
    end
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local s = ColorModal.Sliders[draggingSlider]
            if s then
                local rel = math.clamp((input.Position.X - s.Bar.AbsolutePosition.X) / math.max(s.Bar.AbsoluteSize.X, 1), 0, 1)
                if draggingSlider == "H" then H = rel elseif draggingSlider == "S" then S = rel else V = rel end
                RefreshColorUI()
            end
        end
    end)
    ColorModal.Hex.FocusLost:Connect(function(enter)
        if enter then
            local c = FromHex(ColorModal.Hex.Text)
            if c then
                H, S, V = Color3.toHSV(c)
                RefreshColorUI()
            end
        end
    end)
    ColorModal.Save.MouseButton1Click:Connect(function()
        local col = Color3.fromHSV(H, S, V)
        ColorModal.Frame.Visible = false
        if Tooltip then Tooltip.Visible = false end
        if colorCallback then
            task.spawn(colorCallback, col)
        end
        Window:SetAccent(col)
    end)

    -- Tooltip card (reference: color square + "RGB: ..." + "Save the selected color.")
    do
        local tip = New("Frame", {
            Name = "Tooltip",
            Size = UDim2.new(0, 260, 0, 72),
            BackgroundColor3 = Window.Theme.Card,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 45,
        }, nil)
        tip.Parent = Main
        Corner(tip, 10)
        local tst = Stroke(tip, Window.Theme.Stroke, 0.92, 1)
        tst:SetAttribute("Hairline", true)
        Shadow(tip, 0.5, 30)
        RegisterTheme(tip, "Card")
        local prev = New("Frame", {
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(0, 48, 0, 48),
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            ZIndex = 46,
        }, nil)
        prev.Parent = tip
        Corner(prev, 8)
        local rgb = New("TextLabel", {
            Text = "RGB: 255 87 90",
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = Window.Theme.Text, BackgroundTransparency = 1,
            Position = UDim2.new(0, 72, 0, 14), Size = UDim2.new(1, -84, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 46,
        }, nil)
        rgb.Parent = tip
        rgb:SetAttribute("TRole", "Primary")
        local sub = New("TextLabel", {
            Text = "Save the selected color.",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Window.Theme.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 72, 0, 34), Size = UDim2.new(1, -84, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 46,
        }, nil)
        sub.Parent = tip
        sub:SetAttribute("TRole", "Dim")
        Tooltip = { Frame = tip, ColorPreview = prev, RGB = rgb }
        Tooltip.Visible = false
        setmetatable(Tooltip, { __index = function(t, k)
            if k == "Visible" then return tip.Visible end
            return rawget(t, k)
        end, __newindex = function(t, k, v)
            if k == "Visible" then tip.Visible = v else rawset(t, k, v) end
        end})
    end

    function Window:OpenColorPicker(default, callback, anchorPos)
        local h, s, v = Color3.toHSV(default or self.Accent)
        H, S, V = h, s, v
        colorCallback = callback
        table.clear(colorPreviewObjs)
        RefreshColorUI()
        ColorModal.Frame.Position = anchorPos or UDim2.new(0.5, 120, 0.5, 0)
        ColorModal.Frame.Visible = true
        -- pop animation
        ColorModal.Frame.Size = UDim2.new(0, 210, 0, 310)
        Tween(ColorModal.Frame, {Size = UDim2.new(0, 228, 0, 330)}, 0.18)
        -- tooltip follows (like reference floating card)
        if Tooltip then
            Tooltip.Frame.Position = UDim2.new(0, 40, 0, 210)
            Tooltip.Visible = true
        end
    end

    --// App settings modal (reference: Light/Dark/Black + accent dots + English + scale)
    do
        local set = New("Frame", {
            Name = "AppSettings",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, -40, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 250),
            BackgroundColor3 = Window.Theme.Card,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 40,
        }, nil)
        set.Parent = Main
        Corner(set, 12)
        local sst = Stroke(set, Window.Theme.Stroke, 0.92, 1)
        sst:SetAttribute("Hairline", true)
        Shadow(set, 0.5, 40)
        RegisterTheme(set, "Card")

        local title = New("TextLabel", {
            Text = "App settings",
            Font = Enum.Font.GothamMedium, TextSize = 14,
            TextColor3 = Window.Theme.Text, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 12), Size = UDim2.new(1, -60, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41,
        }, nil)
        title.Parent = set
        title:SetAttribute("TRole", "Primary")

        local x = New("TextButton", {
            Text = "✕", Font = Enum.Font.Gotham, TextSize = 14,
            TextColor3 = Window.Theme.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(1, -34, 0, 8), Size = UDim2.new(0, 26, 0, 26),
            ZIndex = 41, AutoButtonColor = false,
        }, nil)
        x.Parent = set
        x.MouseButton1Click:Connect(function() set.Visible = false end)

        -- segmented Light / Dark / Black
        local seg = New("Frame", {
            Position = UDim2.new(0, 16, 0, 42), Size = UDim2.new(1, -32, 0, 34),
            BackgroundColor3 = Window.Theme.Row, BorderSizePixel = 0, ZIndex = 41,
        }, nil)
        seg.Parent = set
        Corner(seg, 17)
        RegisterTheme(seg, "Row")

        local themeBtns = {}
        local names = {"Light", "Dark", "Black"}
        local icons = {Light = "☀", Dark = "☾", Black = "💤"}
        for i, n in ipairs(names) do
            local b = New("TextButton", {
                Text = icons[n] .. "  " .. n,
                Font = Enum.Font.GothamMedium, TextSize = 12,
                TextColor3 = (n == themeName) and Color3.fromRGB(255,255,255) or Window.Theme.TextDim,
                BackgroundColor3 = (n == themeName) and Color3.fromRGB(60, 60, 72) or Color3.fromRGB(255,255,255),
                BackgroundTransparency = (n == themeName) and 0 or 1,
                Size = UDim2.new(1/3, -3, 1, -6),
                Position = UDim2.new((i-1)/3, 3, 0, 3),
                ZIndex = 42, AutoButtonColor = false,
            }, nil)
            b.Parent = seg
            Corner(b, 14)
            b:SetAttribute("TRole", "Dim")
            themeBtns[n] = b
            b.MouseButton1Click:Connect(function()
                Window:SetTheme(n)
                for nn, bb in pairs(themeBtns) do
                    local on = (nn == n)
                    bb.BackgroundTransparency = on and 0 or 1
                    if on then bb.BackgroundColor3 = Color3.fromRGB(60, 60, 72) end
                    bb.TextColor3 = on and Color3.fromRGB(255,255,255) or Window.Theme.TextDim
                end
            end)
        end

        -- accent dots
        local dotRow = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 86), Size = UDim2.new(1, -32, 0, 24),
            ZIndex = 41,
        }, nil)
        dotRow.Parent = set
        local dotLayout = New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, nil)
        dotLayout.Parent = dotRow
        for _, c in ipairs(AccentPresets) do
            local d = New("TextButton", {
                Text = "",
                BackgroundColor3 = c,
                Size = UDim2.new(0, 18, 0, 18),
                ZIndex = 42, AutoButtonColor = false,
            }, nil)
            d.Parent = dotRow
            Corner(d, 0, 1)
            if (c == accent) then Stroke(d, Color3.fromRGB(255,255,255), 0.1, 2) end
            d.MouseButton1Click:Connect(function()
                Window:SetAccent(c)
                for _, ch in ipairs(dotRow:GetChildren()) do
                    if ch:IsA("TextButton") then
                        local st = ch:FindFirstChildOfClass("UIStroke")
                        if st then st:Destroy() end
                    end
                end
                Stroke(d, Color3.fromRGB(255,255,255), 0.1, 2)
                RefreshColorUI()
            end)
        end
        -- rainbow custom dot
        local rainbow = New("TextButton", {
            Text = "", Size = UDim2.new(0, 18, 0, 18), ZIndex = 42, AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
        }, nil)
        rainbow.Parent = dotRow
        Corner(rainbow, 0, 1)
        New("UIGradient", { Rotation = 45, Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
        })}, nil).Parent = rainbow
        rainbow.MouseButton1Click:Connect(function()
            Window:OpenColorPicker(Window.Accent, function(c) Window:SetAccent(c) end)
        end)

        -- language row (visual)
        local lang = New("Frame", {
            Position = UDim2.new(0, 16, 0, 118), Size = UDim2.new(1, -32, 0, 32),
            BackgroundTransparency = 1, ZIndex = 41,
        }, nil)
        lang.Parent = set
        New("TextLabel", {
            Text = "🌐   English", Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = Window.Theme.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 42,
        }, nil).Parent = lang
        New("TextLabel", {
            Text = "∨", Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = Window.Theme.TextDim, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20), ZIndex = 42,
        }, nil).Parent = lang

        -- interface scale slider
        local scaleTitle = New("TextLabel", {
            Text = "Interface scale", Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Window.Theme.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 156), Size = UDim2.new(0, 140, 0, 16), ZIndex = 42,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, nil)
        scaleTitle.Parent = set
        scaleTitle:SetAttribute("TRole", "Dim")
        local scaleVal = New("TextLabel", {
            Text = "100%", Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Window.Theme.Text, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 156),
            Size = UDim2.new(0, 50, 0, 16), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 42,
        }, nil)
        scaleVal.Parent = set
        scaleVal:SetAttribute("TRole", "Primary")

        local track = New("Frame", {
            Position = UDim2.new(0, 16, 0, 180), Size = UDim2.new(1, -32, 0, 4),
            BackgroundColor3 = Window.Theme.Track, BorderSizePixel = 0, ZIndex = 42,
        }, nil)
        track.Parent = set
        Corner(track, 2)
        local fill = New("Frame", {
            Size = UDim2.new(0.55, 0, 1, 0),
            BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 43,
        }, nil)
        fill.Parent = track
        Corner(fill, 2)
        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.55, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.fromRGB(237,237,239),
            BorderSizePixel = 0, ZIndex = 44,
        }, nil)
        knob.Parent = track
        Corner(knob, 0, 1)
        table.insert(Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)

        local draggingScale = false
        local function ApplyScaleFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local pct = 50 + rel * 100 -- 50%..150%
            scaleVal.Text = math.floor(pct + 0.5) .. "%"
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            Library._Scale = pct / 100
            FitScreen()
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingScale = true
                ApplyScaleFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingScale = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingScale and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                ApplyScaleFromX(input.Position.X)
            end
        end)

        SettingsModal = set
    end

    -- gear button to open settings (top of content)
    do
        local gear = New("TextButton", {
            Text = "⚙",
            Font = Enum.Font.Gotham, TextSize = 15,
            TextColor3 = T.TextDim,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 244, 0, 10),
            Size = UDim2.new(0, 28, 0, 28),
            AutoButtonColor = false,
            ZIndex = 6,
        }, nil)
        gear.Parent = Main
        gear.MouseButton1Click:Connect(function()
            SettingsModal.Visible = not SettingsModal.Visible
        end)
        gear.MouseEnter:Connect(function() Tween(gear, {TextColor3 = Window.Accent}, 0.15) end)
        gear.MouseLeave:Connect(function() Tween(gear, {TextColor3 = Window.Theme.TextDim}, 0.15) end)
    end

    --// Tabs ---------------------------------------------------------------
    local ICONS = {
        Aimbot = "◎", Triggerbot = "⚡", Flickbot = "↻",
        Players = "⛉", World = "◍", ["Player list"] = "☰",
        Configs = "⧉", Miscellaneous = "⚙",
    }

    function Window:Tab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or ("Tab" .. (#self.Tabs + 1))
        local icon = tabOpts.Icon or ICONS[name] or "•"
        self._TabOrder += 1
        local order = self._TabOrder

        local btn = New("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
        }, nil)
        btn.Parent = TabHolder
        Corner(btn, 8)

        local indicator = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, -8, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 20),
            BackgroundColor3 = self.Accent,
            BorderSizePixel = 0,
            Visible = false,
        }, nil)
        indicator.Parent = btn
        Corner(indicator, 2)

        New("TextLabel", {
            Text = icon,
            Font = Enum.Font.Gotham, TextSize = 15,
            TextColor3 = T.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 22, 1, 0),
        }, nil).Parent = btn

        local lbl = New("TextLabel", {
            Text = name,
            Font = Enum.Font.GothamMedium, TextSize = 14,
            TextColor3 = T.TextDim, BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -66, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, nil)
        lbl.Parent = btn
        lbl:SetAttribute("TRole", "Dim")

        New("TextLabel", {
            Text = "∨",
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = T.TextDark, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
        }, nil).Parent = btn

        -- page (scrolling, two-column feel via full-width rows)
        local page = New("ScrollingFrame", {
            Name = name .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, nil)
        page.Parent = PageHolder
        local layout = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }, nil)
        layout.Parent = page
        Pad(page, 2, 2, 6, 10)

        local Tab = {
            Name = name, Button = btn, Page = page,
            Indicator = indicator, Label = lbl,
            Active = false, _Order = 0, Window = self,
        }

        local function Activate()
            for _, t in pairs(self.Tabs) do
                t.Active = false
                t.Page.Visible = false
                t.Indicator.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
                t.Label.TextColor3 = self.Theme.TextDim
            end
            Tab.Active = true
            page.Visible = true
            indicator.Visible = true
            indicator.BackgroundColor3 = self.Accent
            btn.BackgroundTransparency = 0.88
            btn.BackgroundColor3 = self.Accent
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            self._ActiveTab = Tab
            Tween(page, {}, 0.01) -- yield to layout
        end
        btn.MouseButton1Click:Connect(Activate)
        btn.MouseEnter:Connect(function()
            if not Tab.Active then Tween(btn, {BackgroundTransparency = 0.92, BackgroundColor3 = self.Theme.RowHover}, 0.15) end
        end)
        btn.MouseLeave:Connect(function()
            if not Tab.Active then Tween(btn, {BackgroundTransparency = 1}, 0.15) end
        end)

        if self._TabOrder == 1 then
            task.defer(Activate)
        end

        self.Tabs[name] = Tab

        --// Row builders ---------------------------------------------------
        local function BaseRow(rowName, height)
            Tab._Order += 1
            local row = New("Frame", {
                Size = UDim2.new(1, -4, 0, height or 44),
                BackgroundColor3 = self.Theme.Row,
                BorderSizePixel = 0,
                LayoutOrder = Tab._Order,
                ClipsDescendants = true,
            }, nil)
            row.Parent = page
            Corner(row, 8)
            local st = Stroke(row, self.Theme.Stroke, 0.95, 1)
            st:SetAttribute("Hairline", true)
            RegisterTheme(row, "Row")
            local nameLbl = New("TextLabel", {
                Text = rowName or "",
                Font = Enum.Font.Gotham, TextSize = 13,
                TextColor3 = self.Theme.Text, BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -120, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, nil)
            nameLbl.Parent = row
            nameLbl:SetAttribute("TRole", "Primary")
            row.MouseEnter:Connect(function()
                Tween(row, {BackgroundColor3 = self.Theme.RowHover}, 0.15)
            end)
            row.MouseLeave:Connect(function()
                if not row:GetAttribute("On") then
                    Tween(row, {BackgroundColor3 = self.Theme.Row}, 0.15)
                end
            end)
            table.insert(self._Rows, {Frame = row, Name = rowName})
            return row
        end

        function Tab:Section(title)
            Tab._Order += 1
            local s = New("TextLabel", {
                Text = string.upper(title or "SECTION"),
                Font = Enum.Font.GothamMedium, TextSize = 11,
                TextColor3 = self.Window.Theme.TextDark, BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = Tab._Order,
            }, nil)
            s.Parent = page
            s:SetAttribute("TRole", "Dark")
            Pad(s, 6, 0, 0, 0)
            return s
        end

        function Tab:Toggle(t)
            t = t or {}
            local rowName = t.Name or "Toggle"
            local state = t.Default or false
            Library.Flags[rowName] = state
            local row = BaseRow(rowName, 44)

            local box = New("TextButton", {
                Text = "",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 26, 0, 26),
                BackgroundColor3 = state and self.Window.Accent or Color3.fromRGB(36, 36, 44),
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, nil)
            box.Parent = row
            Corner(box, 7)
            Stroke(box, Color3.fromRGB(255,255,255), 0.94, 1)
            local check = New("TextLabel", {
                Text = "✓", Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                Visible = state,
            }, nil)
            check.Parent = box

            local dots = nil
            if t.More then
                dots = New("TextLabel", {
                    Text = "•••", Font = Enum.Font.GothamBold, TextSize = 13,
                    TextColor3 = self.Window.Theme.TextDark, BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -46, 0.5, 0),
                    Size = UDim2.new(0, 26, 0, 20),
                }, nil)
                dots.Parent = row
                dots:SetAttribute("TRole", "Dark")
            end

            local function Apply(v, silent)
                state = v
                Library.Flags[rowName] = v
                row:SetAttribute("On", v and true or nil)
                check.Visible = v
                Tween(box, {BackgroundColor3 = v and self.Window.Accent or Color3.fromRGB(36, 36, 44)}, 0.18)
                if not silent and t.Callback then task.spawn(t.Callback, v) end
            end
            box.MouseButton1Click:Connect(function() Apply(not state) end)
            row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- click anywhere on row toggles (except dots area handled same)
                end
            end)
            table.insert(self.Window._AccentUpdaters, function(c)
                if state then box.BackgroundColor3 = c end
            end)
            if state then row:SetAttribute("On", true) end
            return { Set = Apply, Get = function() return state end }
        end

        function Tab:Slider(t)
            t = t or {}
            local rowName = t.Name or "Slider"
            local min, max = t.Min or 0, t.Max or 100
            local val = t.Default ~= nil and t.Default or ((min + max) / 2)
            local decimals = t.Decimals or ((max - min) < 20 and 1 or 0)
            local suffix = t.Suffix or ""
            Library.Flags[rowName] = val
            local row = BaseRow(rowName, 56)

            local valLbl = New("TextLabel", {
                Text = tostring(val),
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = self.Window.Theme.TextDim, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8),
                Size = UDim2.new(0, 70, 0, 16), TextXAlignment = Enum.TextXAlignment.Right,
            }, nil)
            valLbl.Parent = row
            valLbl:SetAttribute("TRole", "Dim")

            local function Fmt(v)
                if decimals > 0 then return string.format("%." .. decimals .. "f", v) .. suffix
                else return tostring(math.floor(v + 0.5)) .. suffix end
            end
            valLbl.Text = Fmt(val)

            local track = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 14, 1, -12),
                Size = UDim2.new(1, -28, 0, 4),
                BackgroundColor3 = self.Window.Theme.Track,
                BorderSizePixel = 0,
            }, nil)
            track.Parent = row
            Corner(track, 2)
            local fill = New("Frame", {
                Size = UDim2.new((val - min) / math.max(max - min, 0.001), 0, 1, 0),
                BackgroundColor3 = self.Window.Accent, BorderSizePixel = 0,
            }, nil)
            fill.Parent = track
            Corner(fill, 2)
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((val - min) / math.max(max - min, 0.001), 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.fromRGB(237, 237, 239),
                BorderSizePixel = 0,
            }, nil)
            knob.Parent = track
            Corner(knob, 0, 1)
            table.insert(self.Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)

            local dragging = false
            local function SetFromX(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                val = min + rel * (max - min)
                if decimals == 0 then val = math.floor(val + 0.5) end
                Library.Flags[rowName] = val
                valLbl.Text = Fmt(val)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                if t.Callback then task.spawn(t.Callback, val) end
            end
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    SetFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    SetFromX(input.Position.X)
                end
            end)
            return { Set = function(v)
                v = math.clamp(v, min, max)
                val = v
                Library.Flags[rowName] = v
                local rel = (v - min) / math.max(max - min, 0.001)
                valLbl.Text = Fmt(v)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
            end, Get = function() return val end }
        end

        function Tab:Range(t) -- dual slider like "200 <-> 700" in reference
            t = t or {}
            local rowName = t.Name or "Range"
            local min, max = t.Min or 0, t.Max or 1000
            local a, b = t.DefaultMin or 200, t.DefaultMax or 700
            Library.Flags[rowName] = {a, b}
            local row = BaseRow(rowName, 60)

            local valLbl = New("TextLabel", {
                Text = a .. "   ↔   " .. b,
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = self.Window.Theme.TextDim, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8),
                Size = UDim2.new(0, 130, 0, 16), TextXAlignment = Enum.TextXAlignment.Right,
            }, nil)
            valLbl.Parent = row
            valLbl:SetAttribute("TRole", "Dim")

            local track = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 14, 1, -12),
                Size = UDim2.new(1, -28, 0, 4),
                BackgroundColor3 = self.Window.Theme.Track, BorderSizePixel = 0,
            }, nil)
            track.Parent = row
            Corner(track, 2)
            local fill = New("Frame", {
                BackgroundColor3 = self.Window.Accent, BorderSizePixel = 0,
            }, nil)
            fill.Parent = track
            Corner(fill, 2)
            local kA = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.fromRGB(200, 200, 208), BorderSizePixel = 0,
            }, nil)
            kA.Parent = track
            Corner(kA, 0, 1)
            local kB = kA:Clone()
            kB.BackgroundColor3 = Color3.fromRGB(237, 237, 239)
            kB.Parent = track
            table.insert(self.Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)

            local function Refresh()
                local ra, rb = (a - min)/(max-min), (b - min)/(max-min)
                kA.Position = UDim2.new(ra, 0, 0.5, 0)
                kB.Position = UDim2.new(rb, 0, 0.5, 0)
                fill.Position = UDim2.new(ra, 0, 0, 0)
                fill.Size = UDim2.new(math.max(rb - ra, 0.01), 0, 1, 0)
                valLbl.Text = math.floor(a+0.5) .. "   ↔   " .. math.floor(b+0.5)
                Library.Flags[rowName] = {a, b}
                if t.Callback then task.spawn(t.Callback, a, b) end
            end
            Refresh()
            local dragWhich = nil
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local x = input.Position.X
                    local pa = track.AbsolutePosition.X + ((a-min)/(max-min)) * track.AbsoluteSize.X
                    local pb = track.AbsolutePosition.X + ((b-min)/(max-min)) * track.AbsoluteSize.X
                    dragWhich = (math.abs(x - pa) < math.abs(x - pb)) and "A" or "B"
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragWhich = nil
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragWhich and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    local v = min + rel * (max - min)
                    if dragWhich == "A" then a = math.min(v, b - 1) else b = math.max(v, a + 1) end
                    Refresh()
                end
            end)
            return { Get = function() return a, b end }
        end

        function Tab:Dropdown(t)
            t = t or {}
            local rowName = t.Name or "Dropdown"
            local options = t.Options or {"Option 1", "Option 2"}
            local selected = t.Default or options[1]
            Library.Flags[rowName] = selected
            local row = BaseRow(rowName, 36)
            row.ClipsDescendants = true

            local chev = New("TextLabel", {
                Text = "∨", Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = self.Window.Theme.TextDim, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 18, 0, 18),
            }, nil)
            chev.Parent = row

            local selLbl = New("TextLabel", {
                Text = tostring(selected), Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = self.Window.Theme.TextDim, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0),
                Size = UDim2.new(0, 150, 0, 18), TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, nil)
            selLbl.Parent = row
            selLbl:SetAttribute("TRole", "Dim")

            local open = false
            local listH = #options * 30
            local clickArea = New("TextButton", {
                Text = "", BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
            }, nil)
            clickArea.Parent = row

            local function SetH(h)
                Tween(row, {Size = UDim2.new(1, -4, 0, h)}, 0.2)
            end
            local optBtns = {}
            for i, opt in ipairs(options) do
                local ob = New("TextButton", {
                    Text = "  " .. tostring(opt),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = (opt == selected) and Color3.fromRGB(255,255,255) or self.Window.Theme.TextDim,
                    BackgroundColor3 = (opt == selected) and self.Window.Accent or Color3.fromRGB(255,255,255),
                    BackgroundTransparency = (opt == selected) and 0.85 or 1,
                    Position = UDim2.new(0, 6, 0, 36 + (i-1)*30),
                    Size = UDim2.new(1, -12, 0, 28),
                    AutoButtonColor = false,
                }, nil)
                ob.Parent = row
                Corner(ob, 6)
                ob:SetAttribute("TRole", "Dim")
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    Library.Flags[rowName] = opt
                    selLbl.Text = tostring(opt)
                    for _, o2 in ipairs(optBtns) do
                        local isSel = (o2.Text:sub(3) == tostring(opt))
                        o2.BackgroundTransparency = isSel and 0.85 or 1
                        if isSel then o2.BackgroundColor3 = self.Window.Accent end
                        o2.TextColor3 = isSel and Color3.fromRGB(255,255,255) or self.Window.Theme.TextDim
                    end
                    open = false
                    chev.Text = "∨"
                    SetH(36)
                    if t.Callback then task.spawn(t.Callback, opt) end
                end)
                table.insert(optBtns, ob)
            end
            clickArea.MouseButton1Click:Connect(function()
                open = not open
                chev.Text = open and "∧" or "∨"
                SetH(open and (36 + listH + 8) or 36)
            end)
            -- start collapsed; expand pushes following rows via AutomaticCanvasSize
            Tab._Order += 0
            return { Set = function(v) selected = v Library.Flags[rowName] = v selLbl.Text = tostring(v) end, Get = function() return selected end }
        end

        function Tab:Colorpicker(t)
            t = t or {}
            local rowName = t.Name or "Color"
            local col = t.Default or self.Window.Accent
            Library.Flags[rowName] = col
            local row = BaseRow(rowName, 44)

            local prev = New("TextButton", {
                Text = "",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 22, 0, 22),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, nil)
            prev.Parent = row
            Corner(prev, 0, 1) -- perfect circle
            Stroke(prev, Color3.fromRGB(255,255,255), 0.85, 1)

            local function Open()
                self.Window:OpenColorPicker(col, function(c)
                    col = c
                    Library.Flags[rowName] = c
                    prev.BackgroundColor3 = c
                    if t.Callback then task.spawn(t.Callback, c) end
                end)
            end
            prev.MouseButton1Click:Connect(Open)
            return { Set = function(c) col = c prev.BackgroundColor3 = c Library.Flags[rowName] = c end, Get = function() return col end }
        end

        function Tab:Button(t)
            t = t or {}
            local rowName = t.Name or "Button"
            Tab._Order += 1
            local b = New("TextButton", {
                Text = rowName,
                Font = Enum.Font.GothamMedium, TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = self.Window.Accent,
                Size = UDim2.new(1, -4, 0, 36),
                LayoutOrder = Tab._Order,
                AutoButtonColor = false,
            }, nil)
            b.Parent = page
            Corner(b, 8)
            table.insert(self.Window._AccentUpdaters, function(c) b.BackgroundColor3 = c end)
            b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.12}, 0.15) end)
            b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0}, 0.15) end)
            b.MouseButton1Click:Connect(function()
                Tween(b, {Size = UDim2.new(1, -8, 0, 34)}, 0.08)
                task.delay(0.08, function() Tween(b, {Size = UDim2.new(1, -4, 0, 36)}, 0.12) end)
                if t.Callback then task.spawn(t.Callback) end
            end)
            table.insert(self._Rows, {Frame = b, Name = rowName})
            return b
        end

        function Tab:Label(text)
            Tab._Order += 1
            local l = New("TextLabel", {
                Text = text or "",
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = self.Window.Theme.TextDim, BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = Tab._Order,
            }, nil)
            l.Parent = page
            l:SetAttribute("TRole", "Dim")
            return l
        end

        return Tab
    end

    table.insert(Library._Windows, Window)
    RefreshColorUI()
    return Window
end

--// Config save/load (executor writefile when available) -------------------
function Library:SaveConfig(name)
    name = name or "celestial_default"
    local ok, json = pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if not ok then return false end
    if typeof(writefile) == "function" then
        pcall(writefile, name .. ".json", json)
        return true
    end
    return false, json
end

function Library:LoadConfig(name)
    name = name or "celestial_default"
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local exists = false
        pcall(function() exists = isfile(name .. ".json") end)
        if exists then
            local ok, data = pcall(readfile, name .. ".json")
            if ok and data then
                local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
                if ok2 and tbl then
                    for k, v in pairs(tbl) do self.Flags[k] = v end
                    return true
                end
            end
        end
    end
    return false
end

return Library
