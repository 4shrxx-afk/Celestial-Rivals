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
