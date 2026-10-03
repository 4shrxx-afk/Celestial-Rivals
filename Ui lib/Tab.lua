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
        return row
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
