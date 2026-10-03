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
