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

-- One live tween per object: starting a new one cancels the old.
-- (Kills fighting hover tweens, the main source of slow/smeary UI.)
local _liveTweens = setmetatable({}, { __mode = "k" })
function Utils.Tween(obj, props, dur, style, dir)
    local old = _liveTweens[obj]
    if old then pcall(function() old:Cancel() end) end
    local info = TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    _liveTweens[obj] = tw
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
