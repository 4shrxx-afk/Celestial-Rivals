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

    local box = Utils.New("TextButton", {
        Text = "",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = state and Window.Accent or Color3.fromRGB(36, 36, 44),
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
        check.Visible = v
        Utils.Tween(box, { BackgroundColor3 = v and Window.Accent or Color3.fromRGB(36, 36, 44) }, 0.18)
        if not silent and t.Callback then
            task.spawn(t.Callback, v)
        end
    end

    box.MouseButton1Click:Connect(function() apply(not state) end)
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
