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

    -- Click-catcher: clicking anywhere outside the modal closes it.
    local zone = Utils.New("TextButton", {
        Name = "SettingsCloseZone",
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 39,
        AutoButtonColor = false,
        Parent = Window.Main,
    })
    Window._SettingsZone = zone
    zone.MouseButton1Click:Connect(function()
        set.Visible = false
        zone.Visible = false
    end)

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
    x.MouseButton1Click:Connect(function()
        set.Visible = false
        zone.Visible = false
    end)

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
        Size = UDim2.new(1, -32, 0, 6),
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
    Utils.Corner(fill, ThemeData.Radius.Track)

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
