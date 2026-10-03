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
    table.insert(Window._AccentUpdaters, function(c) fill.BackgroundColor3 = c end)

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        val = min + rel * (max - min)
        if decimals == 0 then val = math.floor(val + 0.5) end
        Library.Flags[rowName] = val
        valLbl.Text = fmt(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        if t.Callback then task.spawn(t.Callback, val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
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
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
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

    local dragWhich = nil
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local x = input.Position.X
            local pa = track.AbsolutePosition.X + ((a - min) / (max - min)) * track.AbsoluteSize.X
            local pb = track.AbsolutePosition.X + ((b - min) / (max - min)) * track.AbsoluteSize.X
            dragWhich = (math.abs(x - pa) < math.abs(x - pb)) and "A" or "B"
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragWhich = nil
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
