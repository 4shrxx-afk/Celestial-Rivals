--[[
    CelestialUI.lua — single-file bundle (GENERATED, do not edit).
    Built by build.py from Ui lib/*.lua. Edit the modules, then rebuild.
    Loadstring:
      local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/CelestialUI.lua"))()
]]

-- Embedded module sources (dependency order, resolved by need()).
local __SRC = {}
__SRC["Theme"] = [==[
--[[
    Celestial Rivals UI — Theme.lua
    EDIT ME: colors, accents, sizes. Everything visual lives here.
    Research notes:
      - Main 14px, modals 12px, rows 8px, toggles 7px (Offset, not Scale)
      - Hairline borders: white @ 0.93 transparency (dark themes)
      - Accent default #9496FF sampled from reference hex box
]]

local Theme = {}

Theme.WHEEL_ASSET = "rbxassetid://6020299385" -- standard HSV wheel

Theme.Defaults = {
    ThemeName = "Dark",
    Accent = Color3.fromRGB(148, 150, 255),
    Size = UDim2.fromOffset(860, 600),
    User = "Guest",
}

Theme.AccentPresets = {
    Color3.fromRGB(148, 150, 255), -- #9496FF default (reference)
    Color3.fromRGB(123, 124, 248), -- deep purple
    Color3.fromRGB(142, 184, 255), -- blue
    Color3.fromRGB(142, 214, 255), -- cyan
    Color3.fromRGB(142, 255, 200), -- mint
}

Theme.Themes = {
    Dark = {
        Main = Color3.fromRGB(18, 18, 22),
        Sidebar = Color3.fromRGB(22, 22, 27),
        Card = Color3.fromRGB(28, 28, 34),
        Row = Color3.fromRGB(24, 24, 30),
        RowHover = Color3.fromRGB(32, 32, 40),
        Track = Color3.fromRGB(42, 42, 51),
        Stroke = Color3.fromRGB(255, 255, 255),
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
        StrokeTrans = 0.90,
        Text = Color3.fromRGB(25, 25, 30),
        TextDim = Color3.fromRGB(120, 120, 132),
        TextDark = Color3.fromRGB(150, 150, 162),
        Search = Color3.fromRGB(228, 228, 234),
    },
}

-- Corner radii (Offset px). Circles use Scale=1 separately.
Theme.Radius = {
    Main = 14,
    Sidebar = 10,
    Card = 10,
    Row = 8,
    Button = 8,
    Search = 8,
    Toggle = 7,
    Modal = 12,
    Track = 2, -- 4px tall track -> 2px radius
}

-- Fonts: Gotham* auto-maps to Montserrat on live clients (Gotham removed 2024).
-- BuilderSans also works on new clients. We use Gotham for max executor compat.
Theme.Fonts = {
    Title = Enum.Font.GothamBlack,
    Medium = Enum.Font.GothamMedium,
    Regular = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
}

Theme.Sizes = {
    Title = 20,
    Tab = 14,
    Row = 13,
    Small = 12,
    Micro = 11,
}

return Theme

]==]
__SRC["Utils"] = [==[
--[[
    Celestial Rivals UI — Utils.lua
    EDIT ME: low-level constructors. All best-practice rules live here.
    - Corner(): Offset only (Scale only for circles)
    - Stroke(): hairline UIStroke, Round joins, Border mode
    - Shadow(): pcall UIShadow (old clients skip gracefully)
    - MakeDraggable(): UIDragDetector + Lua fallback (mouse + touch)
    - GetParent(): gethui() -> CoreGui -> PlayerGui
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Utils = {}

function Utils.New(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k == "Parent" and v == nil then
            continue
        end
        local ok, err = pcall(function()
            obj[k] = v
        end)
        if not ok then
            warn("[CelestialUI.Utils] bad prop " .. tostring(k) .. ": " .. tostring(err))
        end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = obj
    end
    if props and props.Parent ~= nil then
        -- already assigned above via loop; ensure order for Instance parenting
        obj.Parent = props.Parent
    end
    return obj
end

function Utils.Corner(parent, offset, circleScale)
    local c = Instance.new("UICorner")
    if circleScale then
        c.CornerRadius = UDim.new(1, 0) -- perfect circle regardless of size
    else
        c.CornerRadius = UDim.new(0, offset or 8)
    end
    c.Parent = parent
    return c
end

function Utils.Stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255, 255, 255)
    s.Transparency = (transparency ~= nil) and transparency or 0.93
    s.Thickness = thickness or 1
    s.LineJoinMode = Enum.LineJoinMode.Round
    pcall(function()
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end)
    s.Parent = parent
    return s
end

-- Marks a stroke as a theme hairline so Window:SetTheme can recolor it.
function Utils.Hairline(stroke, theme)
    stroke:SetAttribute("Hairline", true)
    if theme then
        stroke.Color = theme.Stroke
        stroke.Transparency = theme.StrokeTrans
    end
    return stroke
end

function Utils.Shadow(parent, transparency, blur)
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

function Utils.Pad(parent, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 10)
    p.PaddingTop = UDim.new(0, t or 8)
    p.PaddingRight = UDim.new(0, r or 10)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.Parent = parent
    return p
end

function Utils.Tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    -- Native C-side drag when available (smoother, cheaper than Lua)
    pcall(function()
        local d = Instance.new("UIDragDetector")
        d.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
        pcall(function()
            d.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale
        end)
        d.Parent = handle
    end)
    -- Lua fallback (works on every executor, mouse + touch)
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

function Utils.GetParent()
    local ok, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)
    if ok and hui then return hui end
    -- Try CoreGui (verify we can actually parent there; some executors block it)
    local canCore = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Parent = CoreGui
        g:Destroy()
    end)
    if canCore then return CoreGui end
    local plr = Players.LocalPlayer
    if plr then
        return plr:WaitForChild("PlayerGui")
    end
    return CoreGui
end

function Utils.ToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end

function Utils.FromHex(h)
    h = tostring(h or ""):gsub("#", ""):gsub("%s+", "")
    if #h ~= 6 then return nil end
    local r = tonumber(h:sub(1, 2), 16)
    local g = tonumber(h:sub(3, 4), 16)
    local b = tonumber(h:sub(5, 6), 16)
    if r and g and b then
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

function Utils.Services()
    return {
        Players = Players,
        TweenService = TweenService,
        UserInputService = UserInputService,
        CoreGui = CoreGui,
    }
end

return Utils

]==]
__SRC["Icons"] = [==[
--[[
    Celestial Rivals UI — Icons.lua
    EDIT ME: add or override icon assets here.
    Real Lucide icons (https://lucide.dev). Asset IDs vendored from the
    Footagesus/Icons lucide pack (direct per-icon rbxassetid, no spritesheets,
    no runtime HTTP fetch). Lean: only the icons the lib actually uses.

    Usage:
      local img = Icons.New("search", 16, Theme.TextDim, { Parent = box })
      img:SetAttribute("IRole", "Dim") -- auto-recolored by Window:SetTheme
      Icons.Apply(existingLabel, "check", Color3.fromRGB(255,255,255))

    IRole values: "Primary" | "Dim" | "Dark" (same palette as text).
]]

local ContentProvider = game:GetService("ContentProvider")

local Icons = {}

Icons.IDS = {
    ["search"]             = "rbxassetid://121018724060431",
    ["crosshair"]          = "rbxassetid://134242818164054",
    ["target"]             = "rbxassetid://87563802520297",
    ["zap"]                = "rbxassetid://130551565616516",
    ["rotate-ccw"]         = "rbxassetid://110116685948665",
    ["users"]              = "rbxassetid://115398113982385",
    ["user"]               = "rbxassetid://81589895647169",
    ["user-round"]         = "rbxassetid://136485052187963",
    ["globe"]              = "rbxassetid://114238209622913",
    ["list"]               = "rbxassetid://113179976918783",
    ["archive"]            = "rbxassetid://122180020814574",
    ["save"]               = "rbxassetid://126116963775616",
    ["folder"]             = "rbxassetid://80846616596607",
    ["settings"]           = "rbxassetid://80758916183665",
    ["settings-2"]         = "rbxassetid://135684703553372",
    ["sliders-horizontal"] = "rbxassetid://85538382643347",
    ["cog"]                = "rbxassetid://116544501716299",
    ["sun"]                = "rbxassetid://110150589884127",
    ["moon"]               = "rbxassetid://83380517901735",
    ["moon-star"]          = "rbxassetid://82782200506348",
    ["check"]              = "rbxassetid://93898873302694",
    ["x"]                  = "rbxassetid://110786993356448",
    ["plus"]               = "rbxassetid://111774323017047",
    ["minus"]              = "rbxassetid://118026365011536",
    ["chevron-down"]       = "rbxassetid://134243273101015",
    ["chevron-up"]         = "rbxassetid://122444883127455",
    ["chevron-right"]      = "rbxassetid://92473583511724",
    ["ellipsis"]           = "rbxassetid://140019550645825",
    ["ellipsis-vertical"]  = "rbxassetid://117978708573781",
    ["info"]               = "rbxassetid://124560466474914",
    ["copy"]               = "rbxassetid://78979572434545",
    ["palette"]            = "rbxassetid://86350350950064",
    ["languages"]          = "rbxassetid://90816903776498",
    ["eye"]                = "rbxassetid://100033680381365",
    ["eye-off"]            = "rbxassetid://135928786788378",
    ["gauge"]              = "rbxassetid://110273524101447",
    ["trash-2"]            = "rbxassetid://109843431391323",
    ["download"]           = "rbxassetid://134814648082393",
    ["upload"]             = "rbxassetid://138212042425501",
    ["scaling"]            = "rbxassetid://122360365318466",
    ["circle-dot"]         = "rbxassetid://82947033619201",
    ["log-out"]            = "rbxassetid://84895399304975",
    ["power"]              = "rbxassetid://96479131758775",
}

function Icons.Get(name)
    local id = Icons.IDS[name]
    if not id then
        warn("[CelestialUI.Icons] unknown icon: " .. tostring(name))
        return ""
    end
    return id
end

function Icons.Add(name, assetId)
    Icons.IDS[name] = assetId
end

-- Retarget an existing ImageLabel/ImageButton at an icon.
function Icons.Apply(img, name, color)
    img.Image = Icons.Get(name)
    img.ScaleType = Enum.ScaleType.Fit
    if color then
        img.ImageColor3 = color
    end
    return img
end

-- Lean ImageLabel icon. Tint via ImageColor3 (sources are white).
function Icons.New(name, px, color, props)
    props = props or {}
    local img = Instance.new("ImageLabel")
    img.Name = "Icon_" .. tostring(name)
    img.BackgroundTransparency = 1
    img.BorderSizePixel = 0
    -- Decorative: never eats clicks/hover, input passes to the control below.
    -- (Also fixes icons on top of buttons swallowing their clicks.)
    img.Active = false
    img.Image = Icons.Get(name)
    img.ScaleType = Enum.ScaleType.Fit
    img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    local s = px or 16
    if props.Size == nil then
        img.Size = UDim2.fromOffset(s, s)
    end
    for k, v in pairs(props) do
        pcall(function() img[k] = v end)
    end
    return img
end

-- Clickable icon.
function Icons.Button(name, px, color, props)
    props = props or {}
    local b = Instance.new("ImageButton")
    b.Name = "IconBtn_" .. tostring(name)
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Image = Icons.Get(name)
    b.ScaleType = Enum.ScaleType.Fit
    b.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    b.AutoButtonColor = false
    local s = px or 16
    if props.Size == nil then
        b.Size = UDim2.fromOffset(s, s)
    end
    for k, v in pairs(props) do
        pcall(function() b[k] = v end)
    end
    return b
end

-- Preload every vendored icon so first open has no pop-in.
function Icons.Preload()
    local list = {}
    for _, id in pairs(Icons.IDS) do
        local ok, inst = pcall(function()
            local i = Instance.new("ImageLabel")
            i.Image = id
            return i
        end)
        if ok then table.insert(list, inst) end
    end
    pcall(function()
        ContentProvider:PreloadAsync(list)
    end)
    for _, i in ipairs(list) do
        pcall(function() i:Destroy() end)
    end
end

return Icons

]==]
__SRC["Config"] = [==[
--[[
    Celestial Rivals UI — Config.lua
    EDIT ME: change file naming / save format.
    Uses executor writefile/readfile/isfile when present, else returns JSON.
    Color3 values are serialized as hex strings.
]]

local HttpService = game:GetService("HttpService")

local Config = {}

local function encodeFlags(flags)
    local out = {}
    for k, v in pairs(flags or {}) do
        if typeof(v) == "Color3" then
            out[k] = { __type = "Color3", hex = string.format("#%02X%02X%02X",
                math.floor(v.R * 255 + 0.5),
                math.floor(v.G * 255 + 0.5),
                math.floor(v.B * 255 + 0.5)) }
        elseif typeof(v) == "table" and #v == 2
            and typeof(v[1]) == "number" and typeof(v[2]) == "number" then
            out[k] = { __type = "Range", a = v[1], b = v[2] }
        else
            out[k] = v
        end
    end
    return out
end

local function decodeFlags(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        if typeof(v) == "table" and v.__type == "Color3" and v.hex then
            local h = tostring(v.hex):gsub("#", "")
            local r = tonumber(h:sub(1, 2), 16) or 255
            local g = tonumber(h:sub(3, 4), 16) or 255
            local b = tonumber(h:sub(5, 6), 16) or 255
            out[k] = Color3.fromRGB(r, g, b)
        elseif typeof(v) == "table" and v.__type == "Range" then
            out[k] = { tonumber(v.a) or 0, tonumber(v.b) or 0 }
        else
            out[k] = v
        end
    end
    return out
end

function Config.Save(flags, name)
    name = name or "celestial_default"
    local ok, json = pcall(function()
        return HttpService:JSONEncode(encodeFlags(flags))
    end)
    if not ok then return false, "encode failed" end
    if typeof(writefile) == "function" then
        local wok, werr = pcall(writefile, name .. ".json", json)
        if wok then return true end
        return false, tostring(werr)
    end
    return false, json -- no filesystem: caller can print/store json
end

function Config.Load(flags, name)
    name = name or "celestial_default"
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local exists = false
        pcall(function() exists = isfile(name .. ".json") end)
        if not exists then return false, "no file" end
        local ok, data = pcall(readfile, name .. ".json")
        if not ok or not data then return false, "read failed" end
        local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
        if not ok2 or not tbl then return false, "json failed" end
        local decoded = decodeFlags(tbl)
        for k, v in pairs(decoded) do
            flags[k] = v
        end
        return true
    end
    return false, "no filesystem"
end

function Config.LoadJSON(flags, json)
    local ok, tbl = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or not tbl then return false end
    local decoded = decodeFlags(tbl)
    for k, v in pairs(decoded) do flags[k] = v end
    return true
end

return Config

]==]
__SRC["Settings"] = [==[
--[[
    Celestial Rivals UI — Settings.lua
    EDIT ME: theme buttons, accent dots, language row, scale slider.
    Reference: "App settings" + close icon, segmented Light/Dark/Black
    (Lucide sun / moon / moon-star), 5 accent dots + rainbow,
    "English" row, "Interface scale" + 100% slider.
]]

local UserInputService = game:GetService("UserInputService")

-- BuildSettings(Window, Utils, ThemeData) -> Frame (hidden by default)
return function(Window, Utils, ThemeData)
    local Theme = Window.Theme

    local set = Utils.New("Frame", {
        Name = "AppSettings",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -40, 0.5, 0),
        Size = UDim2.new(0, 300, 0, 250),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 40,
        Parent = Window.Main,
    })
    Utils.Corner(set, ThemeData.Radius.Modal)
    Utils.Hairline(Utils.Stroke(set, Theme.Stroke, 0.92, 1), Theme)
    Utils.Shadow(set, 0.5, 40)

    local title = Utils.New("TextLabel", {
        Text = "App settings",
        Font = ThemeData.Fonts.Medium,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -60, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 41,
        Parent = set,
    })
    title:SetAttribute("TRole", "Primary")

    local Icons = Window._Icons
    local x = Icons.Button("x", 14, Theme.TextDim, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 8),
        ZIndex = 41,
        Parent = set,
    })
    x:SetAttribute("IRole", "Dim")
    x.MouseButton1Click:Connect(function() set.Visible = false end)

    -- segmented Light / Dark / Black
    local seg = Utils.New("Frame", {
        Position = UDim2.new(0, 16, 0, 42),
        Size = UDim2.new(1, -32, 0, 34),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        ZIndex = 41,
        Parent = set,
    })
    Utils.Corner(seg, 17)

    local themeBtns = {}
    local themeIcons = {}
    local names = { "Light", "Dark", "Black" }
    local lucide = { Light = "sun", Dark = "moon", Black = "moon-star" }
    for i, n in ipairs(names) do
        local isActive = (n == Window.ThemeName)
        local b = Utils.New("TextButton", {
            Text = n,
            Font = ThemeData.Fonts.Medium,
            TextSize = ThemeData.Sizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.TextDim,
            BackgroundColor3 = Color3.fromRGB(60, 60, 72),
            BackgroundTransparency = isActive and 0 or 1,
            Size = UDim2.new(1 / 3, -3, 1, -6),
            Position = UDim2.new((i - 1) / 3, 3, 0, 3),
            ZIndex = 42,
            AutoButtonColor = false,
            Parent = seg,
        })
        Utils.Corner(b, 14)
        -- Lucide glyph left of the label (icon + text, like the reference)
        local bic = Icons.New(lucide[n], 13,
            isActive and Color3.fromRGB(255, 255, 255) or Theme.TextDim, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            ZIndex = 43,
            Parent = b,
        })
        if not isActive then bic:SetAttribute("IRole", "Dim") end
        themeIcons[n] = bic
        Utils.Pad(b, 30, 0, 6, 0)
        themeBtns[n] = b
        b.MouseButton1Click:Connect(function()
            Window:SetTheme(n)
            for nn, bb in pairs(themeBtns) do
                local on = (nn == n)
                bb.BackgroundTransparency = on and 0 or 1
                bb.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim
                local ic = themeIcons[nn]
                ic.ImageColor3 = on and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim
                if on then
                    ic:SetAttribute("IRole", "Active")
                else
                    ic:SetAttribute("IRole", "Dim")
                end
            end
        end)
    end

    -- accent dots
    local dotRow = Utils.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 86),
        Size = UDim2.new(1, -32, 0, 24),
        ZIndex = 41,
        Parent = set,
    })
    Utils.New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dotRow,
    })

    local function markSelected(btn)
        for _, ch in ipairs(dotRow:GetChildren()) do
            if ch:IsA("TextButton") then
                local st = ch:FindFirstChildOfClass("UIStroke")
                if st then st:Destroy() end
            end
        end
        Utils.Stroke(btn, Color3.fromRGB(255, 255, 255), 0.1, 2)
    end

    for _, c in ipairs(ThemeData.AccentPresets) do
        local d = Utils.New("TextButton", {
            Text = "",
            BackgroundColor3 = c,
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = 42,
            AutoButtonColor = false,
            Parent = dotRow,
        })
        Utils.Corner(d, 0, true)
        if c == Window.Accent then
            Utils.Stroke(d, Color3.fromRGB(255, 255, 255), 0.1, 2)
        end
        d.MouseButton1Click:Connect(function()
            Window:SetAccent(c)
            markSelected(d)
            if Window._ColorApi then Window._ColorApi.Refresh() end
        end)
    end

    local rainbow = Utils.New("TextButton", {
        Text = "",
        Size = UDim2.new(0, 18, 0, 18),
        ZIndex = 42,
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = dotRow,
    })
    Utils.Corner(rainbow, 0, true)
    Utils.New("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
        }),
        Parent = rainbow,
    })
    rainbow.MouseButton1Click:Connect(function()
        Window:OpenColorPicker(Window.Accent, function(c) Window:SetAccent(c) end)
    end)

    -- language row (visual only — wire to your localization later)
    local lang = Utils.New("Frame", {
        Position = UDim2.new(0, 16, 0, 118),
        Size = UDim2.new(1, -32, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 41,
        Parent = set,
    })
    local langIcon = Icons.New("languages", 14, Theme.Text, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        ZIndex = 42,
        Parent = lang,
    })
    langIcon:SetAttribute("IRole", "Primary")
    local langText = Utils.New("TextLabel", {
        Text = "English",
        Font = ThemeData.Fonts.Regular,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -52, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 42,
        Parent = lang,
    })
    langText:SetAttribute("TRole", "Primary")
    local langChev = Icons.New("chevron-down", 12, Theme.TextDim, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 42,
        Parent = lang,
    })
    langChev:SetAttribute("IRole", "Dim")

    -- interface scale
    local scaleTitle = Utils.New("TextLabel", {
        Text = "Interface scale",
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 156),
        Size = UDim2.new(0, 140, 0, 16),
        ZIndex = 42,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = set,
    })
    scaleTitle:SetAttribute("TRole", "Dim")

    local scaleVal = Utils.New("TextLabel", {
        Text = "100%",
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 156),
        Size = UDim2.new(0, 50, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 42,
        Parent = set,
    })
    scaleVal:SetAttribute("TRole", "Primary")

    local track = Utils.New("Frame", {
        Position = UDim2.new(0, 16, 0, 180),
        Size = UDim2.new(1, -32, 0, 4),
        BackgroundColor3 = Theme.Track,
        BorderSizePixel = 0,
        ZIndex = 42,
        Parent = set,
    })
    Utils.Corner(track, 2)

    local fill = Utils.New("Frame", {
        Size = UDim2.new(0.55, 0, 1, 0),
        BackgroundColor3 = Window.Accent,
        BorderSizePixel = 0,
        ZIndex = 43,
        Parent = track,
    })
    Utils.Corner(fill, 2)

    local knob = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.55, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(237, 237, 239),
        BorderSizePixel = 0,
        ZIndex = 44,
        Parent = track,
    })
    Utils.Corner(knob, 0, true)
    table.insert(Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)

    local draggingScale = false
    local function applyFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local pct = 50 + rel * 100
        scaleVal.Text = math.floor(pct + 0.5) .. "%"
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        Window:SetScale(pct / 100)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingScale = true
            applyFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingScale = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingScale and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            applyFromX(input.Position.X)
        end
    end)

    return set
end

]==]
__SRC["ColorPicker"] = [==[
--[[
    Celestial Rivals UI — ColorPicker.lua
    EDIT ME: wheel size, slider count, hex behavior.
    Reference look: 150px HSV wheel + white dot selector,
    3 thin sliders (H rainbow / S / V), hex box + copy, "Set color" button,
    floating tooltip card: [preview] "RGB: r g b" / "Save the selected color."

    Math (HSV cylinder):
      H = (pi - atan2(dY,dX)) / (2*pi)
      S = dist(center,mouse) / radius
      V from V-slider (0..1)
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- BuildColorPicker(Window, Utils, ThemeData) -> api
-- Window must provide: Main (Frame), Theme (table), Accent (Color3),
--   _AccentUpdaters (array), SetAccent(color)
return function(Window, Utils, ThemeData)
    local Theme = Window.Theme
    local WHEEL = ThemeData.WHEEL_ASSET

    local modal = Utils.New("Frame", {
        Name = "ColorPicker",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 120, 0.5, 0),
        Size = UDim2.new(0, 228, 0, 330),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 40,
        Parent = Window.Main,
    })
    Utils.Corner(modal, ThemeData.Radius.Modal)
    Utils.Hairline(Utils.Stroke(modal, Theme.Stroke, 0.92, 1), Theme)
    Utils.Shadow(modal, 0.5, 40)

    local wheel = Utils.New("ImageButton", {
        Image = WHEEL,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 16),
        Size = UDim2.new(0, 150, 0, 150),
        ZIndex = 41,
        AutoButtonColor = false,
        Parent = modal,
    })
    Utils.Corner(wheel, 0, true)

    local dot = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 42,
        Parent = wheel,
    })
    Utils.Corner(dot, 0, true)
    Utils.Stroke(dot, Color3.fromRGB(0, 0, 0), 0.4, 2)

    -- 3 sliders
    local sliders = {}
    local function makeSlider(idx, gradColor)
        local bar = Utils.New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 176 + (idx - 1) * 22),
            Size = UDim2.new(0, 180, 0, 6),
            BackgroundColor3 = Color3.fromRGB(40, 40, 48),
            BorderSizePixel = 0,
            ZIndex = 41,
            Parent = modal,
        })
        Utils.Corner(bar, 3)
        local grad = Utils.New("UIGradient", {
            Rotation = 0,
            Color = gradColor,
            Parent = bar,
        })
        local knob = Utils.New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = Color3.fromRGB(237, 237, 239),
            BorderSizePixel = 0,
            ZIndex = 42,
            Parent = bar,
        })
        Utils.Corner(knob, 0, true)
        return { Bar = bar, Knob = knob, Grad = grad }
    end

    sliders.H = makeSlider(1, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }))
    sliders.S = makeSlider(2, ColorSequence.new(Color3.fromRGB(255, 255, 255)))
    sliders.V = makeSlider(3, ColorSequence.new(Color3.fromRGB(255, 255, 255)))

    local hexBox = Utils.New("TextBox", {
        Text = "#9496FF",
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Row,
        Position = UDim2.new(0, 24, 0, 248),
        Size = UDim2.new(0, 140, 0, 28),
        ZIndex = 41,
        ClearTextOnFocus = false,
        Parent = modal,
    })
    Utils.Corner(hexBox, 7)

    local saveBtn = Utils.New("TextButton", {
        Text = "Set color",
        Font = ThemeData.Fonts.Medium,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Window.Accent,
        Position = UDim2.new(0, 24, 0, 284),
        Size = UDim2.new(0, 180, 0, 30),
        ZIndex = 41,
        AutoButtonColor = false,
        Parent = modal,
    })
    Utils.Corner(saveBtn, 8)

    -- Tooltip card
    local tip = Utils.New("Frame", {
        Name = "ColorTooltip",
        Size = UDim2.new(0, 260, 0, 72),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 45,
        Parent = Window.Main,
    })
    Utils.Corner(tip, ThemeData.Radius.Card)
    Utils.Hairline(Utils.Stroke(tip, Theme.Stroke, 0.92, 1), Theme)
    Utils.Shadow(tip, 0.5, 30)

    local preview = Utils.New("Frame", {
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 48, 0, 48),
        BackgroundColor3 = Window.Accent,
        BorderSizePixel = 0,
        ZIndex = 46,
        Parent = tip,
    })
    Utils.Corner(preview, 8)

    local rgbLbl = Utils.New("TextLabel", {
        Text = "RGB: 148 150 255",
        Font = ThemeData.Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 14),
        Size = UDim2.new(1, -84, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 46,
        Parent = tip,
    })
    rgbLbl:SetAttribute("TRole", "Primary")

    local subLbl = Utils.New("TextLabel", {
        Text = "Save the selected color.",
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 34),
        Size = UDim2.new(1, -84, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 46,
        Parent = tip,
    })
    subLbl:SetAttribute("TRole", "Dim")

    -- state
    local H, S, V = 0.66, 0.42, 1
    local callback = nil

    local function currentColor()
        return Color3.fromHSV(H, S, V)
    end

    local function refresh()
        local col = currentColor()
        if wheel.AbsoluteSize.X > 0 then
            local r = (wheel.AbsoluteSize.X / 2) * S
            local ang = H * math.pi * 2
            dot.Position = UDim2.new(0.5, math.cos(ang) * r, 0.5, -math.sin(ang) * r)
        end
        sliders.H.Knob.Position = UDim2.new(H, 0, 0.5, 0)
        sliders.S.Knob.Position = UDim2.new(S, 0, 0.5, 0)
        sliders.V.Knob.Position = UDim2.new(V, 0, 0.5, 0)
        sliders.S.Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 0, V)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(H, 1, V)),
        })
        sliders.V.Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(H, S, 1)),
        })
        hexBox.Text = Utils.ToHex(col)
        saveBtn.BackgroundColor3 = col
        preview.BackgroundColor3 = col
        local rr = math.floor(col.R * 255 + 0.5)
        local gg = math.floor(col.G * 255 + 0.5)
        local bb = math.floor(col.B * 255 + 0.5)
        rgbLbl.Text = string.format("RGB: %d %d %d", rr, gg, bb)
    end

    local draggingWheel = false
    local draggingSlider = nil

    wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingWheel = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingWheel = false
            draggingSlider = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not modal.Visible or not draggingWheel then return end
        local mouse = Players.LocalPlayer and Players.LocalPlayer:GetMouse()
        if not mouse then return end
        local c = wheel.AbsolutePosition + wheel.AbsoluteSize / 2
        local d = Vector2.new(mouse.X, mouse.Y) - c
        local radius = math.max(wheel.AbsoluteSize.X / 2, 1)
        local mag = math.clamp(d.Magnitude / radius, 0, 1)
        local h = (math.pi - math.atan2(d.Y, d.X)) / (math.pi * 2)
        H = (h % 1 + 1) % 1
        S = mag
        refresh()
    end)

    for key, s in pairs(sliders) do
        s.Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = key
                local rel = math.clamp((input.Position.X - s.Bar.AbsolutePosition.X)
                    / math.max(s.Bar.AbsoluteSize.X, 1), 0, 1)
                if key == "H" then H = rel elseif key == "S" then S = rel else V = rel end
                refresh()
            end
        end)
    end
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local s = sliders[draggingSlider]
            if s then
                local rel = math.clamp((input.Position.X - s.Bar.AbsolutePosition.X)
                    / math.max(s.Bar.AbsoluteSize.X, 1), 0, 1)
                if draggingSlider == "H" then H = rel
                elseif draggingSlider == "S" then S = rel
                else V = rel end
                refresh()
            end
        end
    end)

    hexBox.FocusLost:Connect(function(enter)
        if enter then
            local c = Utils.FromHex(hexBox.Text)
            if c then
                H, S, V = Color3.toHSV(c)
                refresh()
            end
        end
    end)

    saveBtn.MouseButton1Click:Connect(function()
        local col = currentColor()
        modal.Visible = false
        tip.Visible = false
        if callback then task.spawn(callback, col) end
        Window:SetAccent(col)
    end)

    local api = {}
    function api.Open(default, cb, anchorPos)
        if default then
            H, S, V = Color3.toHSV(default)
        end
        callback = cb
        refresh()
        modal.Position = anchorPos or UDim2.new(0.5, 120, 0.5, 0)
        modal.Visible = true
        tip.Position = UDim2.new(0, 40, 0, 210)
        tip.Visible = true
        modal.Size = UDim2.new(0, 210, 0, 310)
        Utils.Tween(modal, { Size = UDim2.new(0, 228, 0, 330) }, 0.18)
    end
    function api.Close()
        modal.Visible = false
        tip.Visible = false
    end
    function api.Refresh() refresh() end
    function api.Get() return currentColor() end
    api.Frame = modal
    api.Tooltip = tip

    refresh()
    return api
end

]==]
__SRC["Tab"] = [==[
--[[
    Celestial Rivals UI — Tab.lua
    EDIT ME: tab button look, row look, section headers.
    Provides: CreateTab(Window, Utils, ThemeData, opts)
      -> Tab with :Section() :Label() :Button() :_Row()
    Toggle/Slider/Dropdown/ColorPicker are attached by Init.lua
    (see Init.lua wiring) so this file stays small.
]]

-- Lucide icon names per tab (see Icons.lua). Custom tabs can pass
-- opts.Icon = "any-lucide-name".
local ICONS = {
    Aimbot = "crosshair",
    Triggerbot = "zap",
    Flickbot = "rotate-ccw",
    Players = "users",
    World = "globe",
    ["Player list"] = "list",
    Configs = "archive",
    Miscellaneous = "sliders-horizontal",
}

return function(Window, Utils, ThemeData, opts)
    opts = opts or {}
    local name = opts.Name or "Tab"
    local icon = opts.Icon or ICONS[name] or "circle-dot"
    local Icons = Window._Icons

    Window._TabOrder = (Window._TabOrder or 0) + 1
    local order = Window._TabOrder

    local T = Window.Theme

    local btn = Utils.New("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = Window._TabHolder,
    })
    Utils.Corner(btn, 8)

    local indicator = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -8, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 20),
        BackgroundColor3 = Window.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = btn,
    })
    Utils.Corner(indicator, 2)

    local tabIcon = Icons.New(icon, 16, T.TextDim, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Parent = btn,
    })
    tabIcon:SetAttribute("IRole", "Dim")

    local lbl = Utils.New("TextLabel", {
        Text = name,
        Font = ThemeData.Fonts.Medium,
        TextSize = ThemeData.Sizes.Tab,
        TextColor3 = T.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -66, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    lbl:SetAttribute("TRole", "Dim")

    local tabChev = Icons.New("chevron-down", 12, T.TextDark, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = btn,
    })
    tabChev:SetAttribute("IRole", "Dark")

    local page = Utils.New("ScrollingFrame", {
        Name = name .. "_Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Window._PageHolder,
    })
    Utils.New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = page,
    })
    Utils.Pad(page, 2, 2, 6, 10)

    -- NOTE: field names must not collide with Tab methods below
    -- (Tab:Button() and Tab:Label() would overwrite same-named fields).
    local Tab = {
        Name = name,
        Btn = btn,
        Page = page,
        Indicator = indicator,
        NameLabel = lbl,
        Icon = tabIcon,
        Active = false,
        _Order = 0,
        Window = Window,
    }

    local function activate()
        for _, t in pairs(Window.Tabs) do
            t.Active = false
            t.Page.Visible = false
            t.Indicator.Visible = false
            t.Btn.BackgroundTransparency = 1
            t.NameLabel.TextColor3 = Window.Theme.TextDim
            if t.Icon then
                t.Icon.ImageColor3 = Window.Theme.TextDim
                t.Icon:SetAttribute("IRole", "Dim")
            end
        end
        Tab.Active = true
        page.Visible = true
        indicator.Visible = true
        indicator.BackgroundColor3 = Window.Accent
        btn.BackgroundTransparency = 0.88
        btn.BackgroundColor3 = Window.Accent
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        tabIcon:SetAttribute("IRole", "Active")
        Window._ActiveTab = Tab
    end

    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function()
        if not Tab.Active then
            Utils.Tween(btn, { BackgroundTransparency = 0.92, BackgroundColor3 = Window.Theme.RowHover }, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not Tab.Active then
            Utils.Tween(btn, { BackgroundTransparency = 1 }, 0.15)
        end
    end)

    if order == 1 then
        task.defer(activate)
    end

    Window.Tabs[name] = Tab

    -- Shared row constructor. EDIT row height / padding here.
    function Tab:_Row(rowName, height)
        self._Order += 1
        local row = Utils.New("Frame", {
            Size = UDim2.new(1, -4, 0, height or 44),
            BackgroundColor3 = Window.Theme.Row,
            BorderSizePixel = 0,
            LayoutOrder = self._Order,
            ClipsDescendants = true,
            Parent = page,
        })
        Utils.Corner(row, ThemeData.Radius.Row)
        Utils.Hairline(Utils.Stroke(row, Window.Theme.Stroke, 0.95, 1), Window.Theme)

        local nameLbl = Utils.New("TextLabel", {
            Text = rowName or "",
            Font = ThemeData.Fonts.Regular,
            TextSize = ThemeData.Sizes.Row,
            TextColor3 = Window.Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -120, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        nameLbl:SetAttribute("TRole", "Primary")

        row.MouseEnter:Connect(function()
            Utils.Tween(row, { BackgroundColor3 = Window.Theme.RowHover }, 0.15)
        end)
        row.MouseLeave:Connect(function()
            if not row:GetAttribute("On") then
                Utils.Tween(row, { BackgroundColor3 = Window.Theme.Row }, 0.15)
            end
        end)

        table.insert(Window._Rows, { Frame = row, Name = rowName })
        return row, nameLbl
    end

    function Tab:Section(title)
        self._Order += 1
        local s = Utils.New("TextLabel", {
            Text = string.upper(title or "SECTION"),
            Font = ThemeData.Fonts.Medium,
            TextSize = ThemeData.Sizes.Micro,
            TextColor3 = Window.Theme.TextDark,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self._Order,
            Parent = page,
        })
        s:SetAttribute("TRole", "Dark")
        Utils.Pad(s, 6, 0, 0, 0)
        return s
    end

    function Tab:Label(text)
        self._Order += 1
        local l = Utils.New("TextLabel", {
            Text = text or "",
            Font = ThemeData.Fonts.Regular,
            TextSize = ThemeData.Sizes.Small,
            TextColor3 = Window.Theme.TextDim,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self._Order,
            Parent = page,
        })
        l:SetAttribute("TRole", "Dim")
        return l
    end

    function Tab:Button(t)
        t = t or {}
        local rowName = t.Name or "Button"
        self._Order += 1
        local b = Utils.New("TextButton", {
            Text = rowName,
            Font = ThemeData.Fonts.Medium,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Window.Accent,
            Size = UDim2.new(1, -4, 0, 36),
            LayoutOrder = self._Order,
            AutoButtonColor = false,
            Parent = page,
        })
        Utils.Corner(b, ThemeData.Radius.Button)
        table.insert(Window._AccentUpdaters, function(c) b.BackgroundColor3 = c end)
        b.MouseEnter:Connect(function() Utils.Tween(b, { BackgroundTransparency = 0.12 }, 0.15) end)
        b.MouseLeave:Connect(function() Utils.Tween(b, { BackgroundTransparency = 0 }, 0.15) end)
        b.MouseButton1Click:Connect(function()
            if t.Callback then task.spawn(t.Callback) end
        end)
        table.insert(Window._Rows, { Frame = b, Name = rowName })
        return b
    end

    return Tab
end

]==]
__SRC["Toggle"] = [==[
--[[
    Celestial Rivals UI — Toggle.lua
    EDIT ME: toggle box size, check icon, on/off colors.
    Usage: Tab:Toggle({ Name = "Penetrate walls", Default = true, More = true, Callback = fn })
    Reference: 26x26 rounded-7 square, accent when ON, Lucide check in white.
]]

-- CreateToggle(Tab, Utils, ThemeData, Library, opts)
return function(Tab, Utils, ThemeData, Library, t)
    t = t or {}
    local Window = Tab.Window
    local Icons = Window._Icons
    local rowName = t.Name or "Toggle"
    local state = t.Default or false
    Library.Flags[rowName] = state

    local row = Tab:_Row(rowName, 44)

    local OFF = Color3.fromRGB(36, 36, 44)
    local OFF_HOVER = Color3.fromRGB(52, 52, 64)
    local box = Utils.New("TextButton", {
        Text = "",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = state and Window.Accent or OFF,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    Utils.Corner(box, ThemeData.Radius.Toggle)
    Utils.Stroke(box, Color3.fromRGB(255, 255, 255), 0.94, 1)

    local check = Icons.New("check", 14, Color3.fromRGB(255, 255, 255), {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Visible = state,
        Parent = box,
    })
    if not state then
        check.Size = UDim2.new(0, 0, 0, 0) -- pops in with a tween on enable
    end

    if t.More then
        local dots = Icons.New("ellipsis", 16, Window.Theme.TextDark, {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -46, 0.5, 0),
            Parent = row,
        })
        dots:SetAttribute("IRole", "Dark")
    end

    local function apply(v, silent)
        state = v
        Library.Flags[rowName] = v
        row:SetAttribute("On", v and true or nil)
        Utils.Tween(box, { BackgroundColor3 = v and Window.Accent or OFF }, 0.18)
        Utils.Tween(box, { Size = UDim2.new(0, 26, 0, 26) }, 0.1)
        if v then
            check.Visible = true
            check.Size = UDim2.new(0, 0, 0, 0)
            Utils.Tween(check, { Size = UDim2.new(0, 14, 0, 14) }, 0.22, Enum.EasingStyle.Back)
        else
            check.Visible = false
        end
        if not silent and t.Callback then
            task.spawn(t.Callback, v)
        end
    end

    box.MouseButton1Click:Connect(function() apply(not state) end)
    box.MouseEnter:Connect(function()
        if not state then Utils.Tween(box, { BackgroundColor3 = OFF_HOVER }, 0.12) end
    end)
    box.MouseLeave:Connect(function()
        if not state then Utils.Tween(box, { BackgroundColor3 = OFF }, 0.12) end
    end)
    box.MouseButton1Down:Connect(function()
        Utils.Tween(box, { Size = UDim2.new(0, 23, 0, 23) }, 0.08)
    end)
    box.MouseButton1Up:Connect(function()
        Utils.Tween(box, { Size = UDim2.new(0, 26, 0, 26) }, 0.12)
    end)
    table.insert(Window._AccentUpdaters, function(c)
        if state then box.BackgroundColor3 = c end
    end)
    if state then row:SetAttribute("On", true) end

    return {
        Set = apply,
        Get = function() return state end,
        Row = row,
    }
end

]==]
__SRC["Slider"] = [==[
--[[
    Celestial Rivals UI — Slider.lua
    EDIT ME: track height, knob size, value formatting.
    Provides:
      CreateSlider(Tab, Utils, ThemeData, Library, opts)
        opts: { Name, Min, Max, Default, Decimals, Suffix, Callback }
        Reference: 4px track, accent fill, 14px white knob, value top-right.
      CreateRange(Tab, Utils, ThemeData, Library, opts)
        opts: { Name, Min, Max, DefaultMin, DefaultMax, Callback }
        Reference: "First bullet delay   200 <-> 700" dual-knob slider.
]]

local UserInputService = game:GetService("UserInputService")

local Slider = {}

function Slider.CreateSlider(Tab, Utils, ThemeData, Library, t)
    t = t or {}
    local Window = Tab.Window
    local rowName = t.Name or "Slider"
    local min, max = t.Min or 0, t.Max or 100
    local val = (t.Default ~= nil) and t.Default or ((min + max) / 2)
    local decimals = t.Decimals or ((max - min) < 20 and 1 or 0)
    local suffix = t.Suffix or ""
    Library.Flags[rowName] = val

    local row, title = Tab:_Row(rowName, 56)
    -- Lock the title to the top line so it never sinks toward the track.
    title.Position = UDim2.new(0, 14, 0, 8)
    title.Size = UDim2.new(1, -120, 0, 16)

    local valLbl = Utils.New("TextLabel", {
        Text = tostring(val),
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Window.Theme.TextDim,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.new(0, 90, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    valLbl:SetAttribute("TRole", "Dim")

    local function fmt(v)
        if decimals > 0 then
            return string.format("%." .. decimals .. "f", v) .. suffix
        else
            return tostring(math.floor(v + 0.5)) .. suffix
        end
    end
    valLbl.Text = fmt(val)

    local track = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -12),
        Size = UDim2.new(1, -28, 0, 4),
        BackgroundColor3 = Window.Theme.Track,
        BorderSizePixel = 0,
        Parent = row,
    })
    Utils.Corner(track, ThemeData.Radius.Track)

    local fill = Utils.New("Frame", {
        Size = UDim2.new((val - min) / math.max(max - min, 0.001), 0, 1, 0),
        BackgroundColor3 = Window.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    Utils.Corner(fill, ThemeData.Radius.Track)

    local knob = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((val - min) / math.max(max - min, 0.001), 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(237, 237, 239),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utils.Corner(knob, 0, true)
    -- Soft accent ring shown on hover/drag (modern slider feel).
    local ring = Utils.Stroke(knob, Window.Accent, 1, 2)
    table.insert(Window._AccentUpdaters, function(c)
        fill.BackgroundColor3 = c
        ring.Color = c
    end)
    valLbl:SetAttribute("TRole", "Dim")

    local dragging = false
    local function paintKnob()
        local target = dragging and 17 or 14
        Utils.Tween(knob, { Size = UDim2.new(0, target, 0, target) }, 0.12)
        ring.Transparency = dragging and 0.25 or 1
        valLbl.TextColor3 = dragging and Window.Accent or Window.Theme.TextDim
    end
    knob.MouseEnter:Connect(function()
        if dragging then return end
        Utils.Tween(knob, { Size = UDim2.new(0, 15, 0, 15) }, 0.1)
        ring.Transparency = 0.25
    end)
    knob.MouseLeave:Connect(function()
        if dragging then return end
        Utils.Tween(knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
        ring.Transparency = 1
    end)
    local function setFromX(x, animate)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        val = min + rel * (max - min)
        if decimals == 0 then val = math.floor(val + 0.5) end
        Library.Flags[rowName] = val
        valLbl.Text = fmt(val)
        if animate then
            Utils.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.1)
            Utils.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.1)
        else
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
        end
        if t.Callback then task.spawn(t.Callback, val) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            paintKnob()
            setFromX(input.Position.X, true)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            paintKnob()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            val = v
            Library.Flags[rowName] = v
            local rel = (v - min) / math.max(max - min, 0.001)
            valLbl.Text = fmt(v)
            Utils.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.12)
            Utils.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.12)
        end,
        Get = function() return val end,
        Row = row,
    }
end

-- Range value separator is plain ASCII (" - ") so rows need no font glyphs.
local function joinRange(x, y)
    return math.floor(x + 0.5) .. " - " .. math.floor(y + 0.5)
end

function Slider.CreateRange(Tab, Utils, ThemeData, Library, t)
    t = t or {}
    local Window = Tab.Window
    local rowName = t.Name or "Range"
    local min, max = t.Min or 0, t.Max or 1000
    local a, b = t.DefaultMin or 200, t.DefaultMax or 700
    Library.Flags[rowName] = { a, b }

    local row, title = Tab:_Row(rowName, 60)
    -- Lock the title to the top line so it never sinks toward the track.
    title.Position = UDim2.new(0, 14, 0, 8)
    title.Size = UDim2.new(1, -160, 0, 16)

    local valLbl = Utils.New("TextLabel", {
        Text = joinRange(a, b),
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Window.Theme.TextDim,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.new(0, 140, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    valLbl:SetAttribute("TRole", "Dim")

    local track = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -12),
        Size = UDim2.new(1, -28, 0, 4),
        BackgroundColor3 = Window.Theme.Track,
        BorderSizePixel = 0,
        Parent = row,
    })
    Utils.Corner(track, ThemeData.Radius.Track)

    local fill = Utils.New("Frame", {
        BackgroundColor3 = Window.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    Utils.Corner(fill, ThemeData.Radius.Track)

    local kA = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(200, 200, 208),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utils.Corner(kA, 0, true)

    local kB = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(237, 237, 239),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utils.Corner(kB, 0, true)
    table.insert(Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)
    valLbl:SetAttribute("TRole", "Dim")

    local dragWhich = nil
    local function paintRange()
        local s = dragWhich and 17 or 14
        kA.Size = UDim2.new(0, s, 0, s)
        kB.Size = UDim2.new(0, s, 0, s)
        valLbl.TextColor3 = dragWhich and Window.Accent or Window.Theme.TextDim
    end

    local function refresh(fire)
        local ra, rb = (a - min) / (max - min), (b - min) / (max - min)
        kA.Position = UDim2.new(ra, 0, 0.5, 0)
        kB.Position = UDim2.new(rb, 0, 0.5, 0)
        fill.Position = UDim2.new(ra, 0, 0, 0)
        fill.Size = UDim2.new(math.max(rb - ra, 0.01), 0, 1, 0)
        valLbl.Text = joinRange(a, b)
        Library.Flags[rowName] = { a, b }
        if fire ~= false and t.Callback then
            task.spawn(t.Callback, a, b)
        end
    end
    refresh(false)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local x = input.Position.X
            local pa = track.AbsolutePosition.X + ((a - min) / (max - min)) * track.AbsoluteSize.X
            local pb = track.AbsolutePosition.X + ((b - min) / (max - min)) * track.AbsoluteSize.X
                    dragWhich = (math.abs(x - pa) < math.abs(x - pb)) and "A" or "B"
                    paintRange()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragWhich = nil
            paintRange()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragWhich and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X)
                / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local v = min + rel * (max - min)
            if dragWhich == "A" then a = math.min(v, b - 1)
            else b = math.max(v, a + 1) end
            refresh(true)
        end
    end)

    return { Get = function() return a, b end, Row = row }
end

return Slider

]==]
__SRC["Dropdown"] = [==[
--[[
    Celestial Rivals UI — Dropdown.lua
    EDIT ME: option height, expanded animation.
    Usage: Tab:Dropdown({ Name = "Recoil control", Options = {...}, Default = ..., Callback = fn })
    Reference: 36px header + Lucide chevron, expands to N*30px list,
    ClipsDescendants for rounding.
]]

-- CreateDropdown(Tab, Utils, ThemeData, Library, opts)
return function(Tab, Utils, ThemeData, Library, t)
    t = t or {}
    local Window = Tab.Window
    local Icons = Window._Icons
    local rowName = t.Name or "Dropdown"
    local options = t.Options or { "Option 1", "Option 2" }
    local selected = t.Default or options[1]
    Library.Flags[rowName] = selected

    local row, title = Tab:_Row(rowName, 36)
    row.ClipsDescendants = true
    -- Lock the header text to the top 36px so it never drifts into the list.
    title.Position = UDim2.new(0, 14, 0, 0)
    title.Size = UDim2.new(1, -200, 0, 36)

    local chev = Icons.New("chevron-down", 14, Window.Theme.TextDim, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0, 18),
        Parent = row,
    })
    chev:SetAttribute("IRole", "Dim")

    local selLbl = Utils.New("TextLabel", {
        Text = tostring(selected),
        Font = ThemeData.Fonts.Regular,
        TextSize = ThemeData.Sizes.Small,
        TextColor3 = Window.Theme.TextDim,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -34, 0, 18),
        Size = UDim2.new(0, 150, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    selLbl:SetAttribute("TRole", "Dim")

    local open = false
    local listH = #options * 30

    local clickArea = Utils.New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = row,
    })

    local function setH(h)
        Utils.Tween(row, { Size = UDim2.new(1, -4, 0, h) }, 0.2)
    end

    local optBtns = {}
    local optTicks = {}
    for i, opt in ipairs(options) do
        local isSel = (opt == selected)
        local ob = Utils.New("TextButton", {
            Text = tostring(opt),
            Font = ThemeData.Fonts.Regular,
            TextSize = ThemeData.Sizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim,
            BackgroundColor3 = Window.Accent,
            BackgroundTransparency = isSel and 0.85 or 1,
            Position = UDim2.new(0, 6, 0, 36 + (i - 1) * 30),
            Size = UDim2.new(1, -12, 0, 28),
            AutoButtonColor = false,
            Parent = row,
        })
        Utils.Corner(ob, 6)
        Utils.Pad(ob, 12, 0, 0, 0)
        local tick = Icons.New("check", 12, Color3.fromRGB(255, 255, 255), {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Visible = isSel,
            Parent = ob,
        })
        optTicks[i] = tick
        ob.MouseEnter:Connect(function()
            if selected ~= opt then
                ob.BackgroundColor3 = Window.Theme.RowHover
                ob.BackgroundTransparency = 0
            end
        end)
        ob.MouseLeave:Connect(function()
            if selected ~= opt then
                ob.BackgroundTransparency = 1
            end
        end)
        ob.MouseButton1Click:Connect(function()
            selected = opt
            Library.Flags[rowName] = opt
            selLbl.Text = tostring(opt)
            for j, o2 in ipairs(optBtns) do
                local on = (options[j] == opt)
                o2.BackgroundTransparency = on and 0.85 or 1
                if on then o2.BackgroundColor3 = Window.Accent end
                o2.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim
                optTicks[j].Visible = on
            end
            open = false
            Utils.Tween(chev, { Rotation = 0 }, 0.2)
            setH(36)
            if t.Callback then task.spawn(t.Callback, opt) end
        end)
        table.insert(optBtns, ob)
    end

    clickArea.MouseButton1Click:Connect(function()
        open = not open
        Utils.Tween(chev, { Rotation = open and 180 or 0 }, 0.2)
        setH(open and (36 + listH + 8) or 36)
    end)

    return {
        Set = function(v)
            selected = v
            Library.Flags[rowName] = v
            selLbl.Text = tostring(v)
        end,
        Get = function() return selected end,
        Row = row,
    }
end

]==]
__SRC["Window"] = [==[
--[[
    Celestial Rivals UI — Window.lua
    EDIT ME: window size, sidebar width, topbar, backdrop glow.
    Shell only: ScreenGui + backdrop + Main + Sidebar + search + pages.
    Tabs/controls are injected via deps (see Init.lua) to avoid circular requires.
    deps = {
      ThemeData, Utils, Config,
      Icons (Icons.lua module),
      BuildSettings (fn(Window, Utils, ThemeData) -> Frame),
      BuildColorPicker (fn(Window, Utils, ThemeData) -> api),
      CreateTab (fn(Window, Utils, ThemeData, opts) -> Tab),
      Controls = { Toggle, SliderModule, Dropdown, } -- attached to each Tab
    }
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

return function(Library, deps)
    local ThemeData = deps.ThemeData
    local Utils = deps.Utils
    local Icons = deps.Icons
    assert(Icons, "[CelestialUI.Window] missing deps.Icons (add Icons.lua, see Init.lua)")
    local CreateTab = deps.CreateTab
    local Controls = deps.Controls
    local BuildSettings = deps.BuildSettings
    local BuildColorPicker = deps.BuildColorPicker

    local function CreateWindow(opts)
        opts = opts or {}
        local ThemeDefs = ThemeData.Themes
        local title1 = opts.Title or "CELESTIAL"
        local title2 = opts.AccentTitle or "RIVALS"
        local username = opts.User or (Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "Player"
        local themeName = opts.Theme or Library._ThemeName or ThemeData.Defaults.ThemeName
        local accent = opts.Accent or Library._Accent or ThemeData.Defaults.Accent
        local winSize = opts.Size or ThemeData.Defaults.Size
        local T = ThemeDefs[themeName] or ThemeDefs.Dark
        Library._Accent = accent

        local rootParent = Utils.GetParent()
        pcall(function()
            local old = rootParent:FindFirstChild("CelestialRivals")
            if old then old:Destroy() end
        end)

        local Gui = Utils.New("ScreenGui", {
            Name = "CelestialRivals",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
            IgnoreGuiInset = true,
        })
        pcall(function()
            Gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
            Gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        Gui.Parent = rootParent

        local Backdrop = Utils.New("Frame", {
            Name = "Backdrop",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(10, 8, 20),
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Parent = Gui,
        })
        -- Flat dim backdrop (no glow images): keeps full focus on the window.
        -- (Purple corner glows were removed: they fought the dark theme.)

        local Scale = Utils.New("UIScale", { Scale = Library._Scale or 1 })

        local Main = Utils.New("Frame", {
            Name = "Main",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0.5),
            Size = winSize,
            BackgroundColor3 = T.Main,
            BorderSizePixel = 0,
            Active = true,
            Parent = Gui,
        })
        Scale.Parent = Main
        Utils.Corner(Main, ThemeData.Radius.Main)
        Utils.Stroke(Main, T.Stroke, T.StrokeTrans, 1)
        Utils.Shadow(Main, 0.55, 60)

        local function FitScreen()
            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local s = math.clamp(math.min(vp.X / 1000, vp.Y / 700), 0.65, 1.1)
            -- Re-assert centering on every fit (cheap, idempotent): a centered
            -- AnchorPoint + scale Position keeps Main dead-center on any viewport.
            Main.AnchorPoint = Vector2.new(0.5, 0.5)
            Main.Position = UDim2.fromScale(0.5, 0.5)
            Main.Size = UDim2.fromOffset(winSize.X.Offset, winSize.Y.Offset)
            Scale.Scale = s * (Library._Scale or 1)
        end
        pcall(FitScreen)
        task.defer(function() pcall(FitScreen) end) -- re-center once layout settles
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(FitScreen)
        end

        local DragBar = Utils.New("Frame", {
            Name = "DragBar",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = Main,
        })
        Utils.MakeDraggable(Main, DragBar)

        -- Sidebar
        local Sidebar = Utils.New("Frame", {
            Name = "Sidebar",
            Position = UDim2.new(0, 12, 0, 44),
            Size = UDim2.new(0, 220, 1, -56),
            BackgroundColor3 = T.Sidebar,
            BorderSizePixel = 0,
            Parent = Main,
        })
        Utils.Corner(Sidebar, ThemeData.Radius.Sidebar)
        Utils.Stroke(Sidebar, T.Stroke, 0.95, 1)

        local SearchBox = Utils.New("Frame", {
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(1, -24, 0, 32),
            BackgroundColor3 = T.Search,
            BorderSizePixel = 0,
            Parent = Sidebar,
        })
        Utils.Corner(SearchBox, ThemeData.Radius.Search)
        Utils.Stroke(SearchBox, T.Stroke, 0.95, 1)

        local searchIcon = Icons.New("search", 14, T.TextDark, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 10, 0.5, 0),
            Parent = SearchBox,
        })
        searchIcon:SetAttribute("IRole", "Dark")

        local SearchInput = Utils.New("TextBox", {
            PlaceholderText = "Search function ...",
            PlaceholderColor3 = T.TextDark,
            Text = "",
            Font = ThemeData.Fonts.Regular,
            TextSize = 13,
            TextColor3 = T.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -38, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = SearchBox,
        })

        local Logo = Utils.New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 52),
            Size = UDim2.new(1, -24, 0, 34),
            Parent = Sidebar,
        })
        -- Single RichText label: a real space between halves, no TextBounds racing.
        local Wordmark = Utils.New("TextLabel", {
            Font = ThemeData.Fonts.Title,
            TextSize = ThemeData.Sizes.Title,
            TextColor3 = T.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            RichText = true,
            Parent = Logo,
        })

        local TabHolder = Utils.New("ScrollingFrame", {
            Position = UDim2.new(0, 8, 0, 94),
            Size = UDim2.new(1, -16, 1, -102),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = Sidebar,
        })
        Utils.New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = TabHolder,
        })

        -- Top-right user
        local TopRight = Utils.New("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 10),
            Size = UDim2.new(0, 220, 0, 28),
            Parent = Main,
        })
        local gear = Icons.Button("settings", 16, T.TextDim, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -142, 0.5, 0),
            Parent = TopRight,
        })
        gear:SetAttribute("IRole", "Dim")
        local infoIcon = Icons.New("info", 14, T.TextDark, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -116, 0.5, 0),
            Parent = TopRight,
        })
        infoIcon:SetAttribute("IRole", "Dark")
        Utils.New("TextLabel", {
            Text = username,
            Font = ThemeData.Fonts.Medium,
            TextSize = 13,
            TextColor3 = T.TextDim,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(1, -94, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TopRight,
        })
        local Avatar = Utils.New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Color3.fromRGB(200, 200, 205),
            BorderSizePixel = 0,
            Parent = TopRight,
        })
        Utils.Corner(Avatar, 0, true)
        Icons.New("user-round", 16, Color3.fromRGB(40, 40, 45), {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Parent = Avatar,
        })

        local PageHolder = Utils.New("Frame", {
            Position = UDim2.new(0, 244, 0, 44),
            Size = UDim2.new(1, -256, 1, -56),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = Main,
        })

        -- Window object
        local Window = {
            Gui = Gui,
            Main = Main,
            Sidebar = Sidebar,
            Tabs = {},
            Pages = {},
            _TabOrder = 0,
            _ActiveTab = nil,
            _Rows = {},
            _TabHolder = TabHolder,
            _PageHolder = PageHolder,
            Accent = accent,
            Theme = T,
            ThemeName = themeName,
            _AccentUpdaters = {},
            _ThemedCards = {},
            _Icons = Icons,
        }

        function Window:SetAccent(color)
            self.Accent = color
            Library._Accent = color
            self:_RefreshWordmark()
            for _, tab in pairs(self.Tabs) do
                if tab.Btn and tab.Active then
                    tab.Indicator.BackgroundColor3 = color
                end
            end
            for _, fn in ipairs(self._AccentUpdaters) do
                pcall(fn, color)
            end
        end

        function Window:SetTheme(name)
            local NT = ThemeDefs[name]
            if not NT then return end
            self.Theme = NT
            self.ThemeName = name
            Library._ThemeName = name
            Main.BackgroundColor3 = NT.Main
            Sidebar.BackgroundColor3 = NT.Sidebar
            SearchBox.BackgroundColor3 = NT.Search
            for _, e in ipairs(self._ThemedCards) do
                if e.Obj and e.Obj.Parent then
                    if e.Role == "Card" then e.Obj.BackgroundColor3 = NT.Card
                    elseif e.Role == "Row" and not e.Obj:GetAttribute("On") then
                        e.Obj.BackgroundColor3 = NT.Row
                    end
                end
            end
            for _, d in ipairs(Main:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    local role = d:GetAttribute("TRole")
                    if role == "Primary" then d.TextColor3 = NT.Text
                    elseif role == "Dim" then d.TextColor3 = NT.TextDim
                    elseif role == "Dark" then d.TextColor3 = NT.TextDark end
                elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                    local irole = d:GetAttribute("IRole")
                    if irole == "Primary" then d.ImageColor3 = NT.Text
                    elseif irole == "Dim" then d.ImageColor3 = NT.TextDim
                    elseif irole == "Dark" then d.ImageColor3 = NT.TextDark end
                elseif d:IsA("UIStroke") then
                    if d:GetAttribute("Hairline") then
                        d.Color = NT.Stroke
                        d.Transparency = NT.StrokeTrans
                    end
                end
            end
            -- active tab icon stays white regardless of theme
            if self._ActiveTab and self._ActiveTab.Icon then
                self._ActiveTab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            self:_RefreshWordmark()
        end

        function Window:_RefreshWordmark()
            if not self._Wordmark then return end
            local function rgb(c)
                return string.format("rgb(%d,%d,%d)",
                    math.floor(c.R * 255 + 0.5),
                    math.floor(c.G * 255 + 0.5),
                    math.floor(c.B * 255 + 0.5))
            end
            self._Wordmark.Text = string.format(
                '<font color="%s">%s</font> <font color="%s">%s</font>',
                rgb(self.Theme.Text), self._Title1,
                rgb(self.Accent), self._Title2)
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
            local toast = Utils.New("Frame", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -14, 1, -14),
                Size = UDim2.new(0, 250, 0, 56),
                BackgroundColor3 = self.Theme.Card,
                BorderSizePixel = 0,
                ZIndex = 50,
                Parent = Main,
            })
            Utils.Corner(toast, 10)
            Utils.Hairline(Utils.Stroke(toast, self.Theme.Stroke, 0.93, 1), self.Theme)
            Utils.New("TextLabel", {
                Text = text or "Saved",
                Font = ThemeData.Fonts.Medium,
                TextSize = 13,
                TextColor3 = self.Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toast,
            })
            Utils.New("TextLabel", {
                Text = sub or "",
                Font = ThemeData.Fonts.Regular,
                TextSize = 12,
                TextColor3 = self.Theme.TextDim,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 28),
                Size = UDim2.new(1, -24, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toast,
            })
            Utils.Tween(toast, { Position = UDim2.new(1, -14, 1, -70) }, 0.25)
            task.delay(2.2, function()
                local tw = Utils.Tween(toast, { Position = UDim2.new(1, -14, 1, -14) }, 0.25)
                tw.Completed:Wait()
                pcall(function() toast:Destroy() end)
            end)
        end

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(SearchInput.Text)
            for _, row in ipairs(Window._Rows) do
                if q == "" then
                    row.Frame.Visible = true
                else
                    row.Frame.Visible = (string.find(string.lower(row.Name or ""), q, 1, true) ~= nil)
                end
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
                Window:Toggle()
            end
        end)

        -- Modals (need Window.Main first, so build here)
        local colorApi = BuildColorPicker(Window, Utils, ThemeData)
        Window._ColorApi = colorApi
        function Window:OpenColorPicker(default, cb, anchor)
            colorApi.Open(default, cb, anchor)
        end

        local settingsFrame = BuildSettings(Window, Utils, ThemeData)
        Window._Settings = settingsFrame

        gear.MouseButton1Click:Connect(function()
            settingsFrame.Visible = not settingsFrame.Visible
        end)
        gear.MouseEnter:Connect(function()
            gear:SetAttribute("IRole", "Active")
            Utils.Tween(gear, { ImageColor3 = Window.Accent }, 0.15)
        end)
        gear.MouseLeave:Connect(function()
            gear:SetAttribute("IRole", "Dim")
            Utils.Tween(gear, { ImageColor3 = Window.Theme.TextDim }, 0.15)
        end)

        -- Tab factory + attach controls
        function Window:Tab(tabOpts)
            local Tab = CreateTab(self, Utils, ThemeData, tabOpts)
            -- attach control constructors (edit list here to add new controls)
            function Tab:Toggle(t) return Controls.Toggle(self, Utils, ThemeData, Library, t) end
            function Tab:Slider(t) return Controls.SliderModule.CreateSlider(self, Utils, ThemeData, Library, t) end
            function Tab:Range(t) return Controls.SliderModule.CreateRange(self, Utils, ThemeData, Library, t) end
            function Tab:Dropdown(t) return Controls.Dropdown(self, Utils, ThemeData, Library, t) end
            function Tab:Colorpicker(t)
                t = t or {}
                local rowName = t.Name or "Color"
                local col = t.Default or self.Window.Accent
                Library.Flags[rowName] = col
                local row = self:_Row(rowName, 44)
                local prev = Utils.New("TextButton", {
                    Text = "",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    BackgroundColor3 = col,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = row,
                })
                Utils.Corner(prev, 0, true)
                Utils.Stroke(prev, Color3.fromRGB(255, 255, 255), 0.85, 1)
                prev.MouseButton1Click:Connect(function()
                    self.Window:OpenColorPicker(col, function(c)
                        col = c
                        Library.Flags[rowName] = c
                        prev.BackgroundColor3 = c
                        if t.Callback then task.spawn(t.Callback, c) end
                    end)
                end)
                return {
                    Set = function(c) col = c prev.BackgroundColor3 = c Library.Flags[rowName] = c end,
                    Get = function() return col end,
                    Row = row,
                }
            end
            return Tab
        end

        Window._Wordmark = Wordmark
        Window._Title1 = title1
        Window._Title2 = title2
        Window:_RefreshWordmark()

        table.insert(Library._Windows, Window)
        return Window
    end

    return CreateWindow
end

]==]
local function need(name)
    local src = __SRC[name]
    assert(src, "[CelestialUI] missing embedded module: " .. tostring(name))
    local fn, err = (loadstring or load)(src, "@CelestialUI/" .. name)
    assert(fn, "[CelestialUI] load error in " .. tostring(name) .. ": " .. tostring(err))
    return fn()
end

local Library = {}
Library.Flags = {}
Library._Accent = Color3.fromRGB(148, 150, 255)
Library._ThemeName = "Dark"
Library._Scale = 1
Library._Windows = {}

-- Load order matters: leaves first, Window last (it needs builders injected)
local ThemeData = need("Theme")
local Utils = need("Utils")
local Icons = need("Icons")
local ConfigMod = need("Config")
local BuildSettings = need("Settings")
local BuildColorPicker = need("ColorPicker")
local CreateTab = need("Tab")
local CreateToggle = need("Toggle")
local SliderModule = need("Slider")
local CreateDropdown = need("Dropdown")
local CreateWindowFactory = need("Window")

Library._ThemeData = ThemeData
Library.Utils = Utils
Library.Icons = Icons

local Controls = {
    Toggle = CreateToggle,
    SliderModule = SliderModule,
    Dropdown = CreateDropdown,
}

local CreateWindow = CreateWindowFactory(Library, {
    ThemeData = ThemeData,
    Utils = Utils,
    Icons = Icons,
    Config = ConfigMod,
    BuildSettings = BuildSettings,
    BuildColorPicker = BuildColorPicker,
    CreateTab = CreateTab,
    Controls = Controls,
})

function Library:CreateWindow(opts)
    return CreateWindow(opts)
end

function Library:SaveConfig(name)
    return ConfigMod.Save(self.Flags, name)
end

function Library:LoadConfig(name)
    return ConfigMod.Load(self.Flags, name)
end

function Library:SetAccent(c)
    self._Accent = c
    for _, w in ipairs(self._Windows) do
        if w.SetAccent then w:SetAccent(c) end
    end
end

function Library:UnloadAll()
    for _, w in ipairs(self._Windows) do
        pcall(function() w:Unload() end)
    end
    table.clear(self._Windows)
end

return Library
