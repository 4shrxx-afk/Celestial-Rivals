--[[
    Celestial Rivals UI — Toggle.lua
    EDIT ME: switch size, knob, on/off colors.
    Usage: Tab:Toggle({ Name = "Penetrate walls", Default = true, More = true, Callback = fn })
    Modern pill switch: 40x22 track, sliding 16px knob, accent when ON.
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
    local pill = Utils.New("TextButton", {
        Text = "",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 22),
        BackgroundColor3 = state and Window.Accent or OFF,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    Utils.Corner(pill, ThemeData.Radius.Switch)
    Utils.Stroke(pill, Color3.fromRGB(255, 255, 255), 0.94, 1)

    local knob = Utils.New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, state and 21 or 3, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Color3.fromRGB(237, 237, 239),
        BorderSizePixel = 0,
        Parent = pill,
    })
    Utils.Corner(knob, 0, true)

    if t.More then
        local dots = Icons.New("ellipsis", 16, Window.Theme.TextDark, {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -64, 0.5, 0),
            Parent = row,
        })
        dots:SetAttribute("IRole", "Dark")
    end

    local function apply(v, silent)
        state = v
        Library.Flags[rowName] = v
        row:SetAttribute("On", v and true or nil)
        Utils.Tween(pill, { BackgroundColor3 = v and Window.Accent or OFF }, 0.18)
        Utils.Tween(knob, {
            Position = UDim2.new(0, v and 21 or 3, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
        }, 0.2)
        if not silent and t.Callback then
            task.spawn(t.Callback, v)
        end
    end

    pill.MouseButton1Click:Connect(function() apply(not state) end)
    pill.MouseEnter:Connect(function()
        if not state then Utils.Tween(pill, { BackgroundColor3 = OFF_HOVER }, 0.12) end
    end)
    pill.MouseLeave:Connect(function()
        if not state then Utils.Tween(pill, { BackgroundColor3 = OFF }, 0.12) end
    end)
    pill.MouseButton1Down:Connect(function()
        Utils.Tween(knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.08)
    end)
    pill.MouseButton1Up:Connect(function()
        Utils.Tween(knob, { Size = UDim2.new(0, 16, 0, 16) }, 0.12)
    end)
    table.insert(Window._AccentUpdaters, function(c)
        if state then pill.BackgroundColor3 = c end
    end)
    if state then row:SetAttribute("On", true) end

    return {
        Set = apply,
        Get = function() return state end,
        Row = row,
    }
end
