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
    Toggle = 7, -- legacy checkbox (kept for compat)
    Switch = 11, -- 22px tall pill switch -> 11px radius
    Modal = 12,
    Track = 3, -- 6px tall track -> 3px radius
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
