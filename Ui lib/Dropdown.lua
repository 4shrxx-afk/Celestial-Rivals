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

    local row = Tab:_Row(rowName, 36)
    row.ClipsDescendants = true

    local chev = Icons.New("chevron-down", 14, Window.Theme.TextDim, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
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
        Position = UDim2.new(1, -34, 0.5, 0),
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
    for i, opt in ipairs(options) do
        local isSel = (opt == selected)
        local ob = Utils.New("TextButton", {
            Text = "  " .. tostring(opt),
            Font = ThemeData.Fonts.Regular,
            TextSize = ThemeData.Sizes.Small,
            TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim,
            BackgroundColor3 = Window.Accent,
            BackgroundTransparency = isSel and 0.85 or 1,
            Position = UDim2.new(0, 6, 0, 36 + (i - 1) * 30),
            Size = UDim2.new(1, -12, 0, 28),
            AutoButtonColor = false,
            Parent = row,
        })
        Utils.Corner(ob, 6)
        ob.MouseButton1Click:Connect(function()
            selected = opt
            Library.Flags[rowName] = opt
            selLbl.Text = tostring(opt)
            for _, o2 in ipairs(optBtns) do
                local on = (o2.Text:sub(3) == tostring(opt))
                o2.BackgroundTransparency = on and 0.85 or 1
                if on then o2.BackgroundColor3 = Window.Accent end
                o2.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Window.Theme.TextDim
            end
            open = false
            Icons.Apply(chev, "chevron-down")
            setH(36)
            if t.Callback then task.spawn(t.Callback, opt) end
        end)
        table.insert(optBtns, ob)
    end

    clickArea.MouseButton1Click:Connect(function()
        open = not open
        Icons.Apply(chev, open and "chevron-up" or "chevron-down")
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
