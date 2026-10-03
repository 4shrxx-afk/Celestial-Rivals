--[[
    Celestial Rivals UI — Window.lua
    EDIT ME: window size, sidebar width, topbar, backdrop glow.
    Shell only: ScreenGui + backdrop + Main + Sidebar + search + pages.
    Tabs/controls are injected via deps (see Init.lua) to avoid circular requires.
    deps = {
      ThemeData, Utils, Config,
      Icons (Icons.lua module),
      BuildSettings (fn(Window, Utils, ThemeData) -> Frame),
      BuildColorPicker (fn(Window, Utils, ThemeData) -> api),
      CreateTab (fn(Window, Utils, ThemeData, opts) -> Tab),
      Controls = { Toggle, SliderModule, Dropdown, } -- attached to each Tab
    }
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

return function(Library, deps)
    local ThemeData = deps.ThemeData
    local Utils = deps.Utils
    local Icons = deps.Icons
    assert(Icons, "[CelestialUI.Window] missing deps.Icons (add Icons.lua, see Init.lua)")
    local CreateTab = deps.CreateTab
    local Controls = deps.Controls
    local BuildSettings = deps.BuildSettings
    local BuildColorPicker = deps.BuildColorPicker

    local function CreateWindow(opts)
        opts = opts or {}
        local ThemeDefs = ThemeData.Themes
        local title1 = opts.Title or "CELESTIAL"
        local title2 = opts.AccentTitle or "RIVALS"
        local username = opts.User or (Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "Player"
        local themeName = opts.Theme or Library._ThemeName or ThemeData.Defaults.ThemeName
        local accent = opts.Accent or Library._Accent or ThemeData.Defaults.Accent
        local winSize = opts.Size or ThemeData.Defaults.Size
        local T = ThemeDefs[themeName] or ThemeDefs.Dark
        Library._Accent = accent

        local rootParent = Utils.GetParent()
        pcall(function()
            local old = rootParent:FindFirstChild("CelestialRivals")
            if old then old:Destroy() end
        end)

        local Gui = Utils.New("ScreenGui", {
            Name = "CelestialRivals",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
            IgnoreGuiInset = true,
        })
        pcall(function()
            Gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
            Gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        Gui.Parent = rootParent

        local Backdrop = Utils.New("Frame", {
            Name = "Backdrop",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(10, 8, 20),
            BackgroundTransparency = 1, -- no dim: the game stays fully visible
            BorderSizePixel = 0,
            Parent = Gui,
        })
        -- Flat dim backdrop (no glow images): keeps full focus on the window.
        -- (Purple corner glows were removed: they fought the dark theme.)

        local Scale = Utils.New("UIScale", { Scale = Library._Scale or 1 })

        local Main = Utils.New("Frame", {
            Name = "Main",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0.5),
            Size = winSize,
            BackgroundColor3 = T.Main,
            BorderSizePixel = 0,
            Active = true,
            Parent = Gui,
        })
        Scale.Parent = Main
        Utils.Corner(Main, ThemeData.Radius.Main)
        Utils.Stroke(Main, T.Stroke, T.StrokeTrans, 1)
        Utils.Shadow(Main, 0.55, 60)

        local function FitScreen()
            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local s = math.clamp(math.min(vp.X / 1000, vp.Y / 700), 0.65, 1.1)
            -- Re-assert centering on every fit (cheap, idempotent): a centered
            -- AnchorPoint + scale Position keeps Main dead-center on any viewport.
            Main.AnchorPoint = Vector2.new(0.5, 0.5)
            Main.Position = UDim2.fromScale(0.5, 0.5)
            Main.Size = UDim2.fromOffset(winSize.X.Offset, winSize.Y.Offset)
            Scale.Scale = s * (Library._Scale or 1)
        end
        pcall(FitScreen)
        task.defer(function() pcall(FitScreen) end) -- re-center once layout settles
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(FitScreen)
        end

        local DragBar = Utils.New("Frame", {
            Name = "DragBar",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = Main,
        })
        Utils.MakeDraggable(Main, DragBar)

        -- Sidebar
        local Sidebar = Utils.New("Frame", {
            Name = "Sidebar",
            Position = UDim2.new(0, 12, 0, 44),
            Size = UDim2.new(0, 220, 1, -56),
            BackgroundColor3 = T.Sidebar,
            BorderSizePixel = 0,
            Parent = Main,
        })
        Utils.Corner(Sidebar, ThemeData.Radius.Sidebar)
        Utils.Stroke(Sidebar, T.Stroke, 0.95, 1)

        local SearchBox = Utils.New("Frame", {
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(1, -24, 0, 32),
            BackgroundColor3 = T.Search,
            BorderSizePixel = 0,
            Parent = Sidebar,
        })
        Utils.Corner(SearchBox, ThemeData.Radius.Search)
        Utils.Stroke(SearchBox, T.Stroke, 0.95, 1)

        local searchIcon = Icons.New("search", 14, T.TextDark, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 10, 0.5, 0),
            Parent = SearchBox,
        })
        searchIcon:SetAttribute("IRole", "Dark")

        local SearchInput = Utils.New("TextBox", {
            PlaceholderText = "Search function ...",
            PlaceholderColor3 = T.TextDark,
            Text = "",
            Font = ThemeData.Fonts.Regular,
            TextSize = 13,
            TextColor3 = T.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -38, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = SearchBox,
        })

        local Logo = Utils.New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 52),
            Size = UDim2.new(1, -24, 0, 34),
            Parent = Sidebar,
        })
        -- Single RichText label: a real space between halves, no TextBounds racing.
        local Wordmark = Utils.New("TextLabel", {
            Font = ThemeData.Fonts.Title,
            TextSize = ThemeData.Sizes.Title,
            TextColor3 = T.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            RichText = true,
            Parent = Logo,
        })

        local TabHolder = Utils.New("ScrollingFrame", {
            Position = UDim2.new(0, 8, 0, 94),
            Size = UDim2.new(1, -16, 1, -102),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = Sidebar,
        })
        Utils.New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = TabHolder,
        })

        -- Top-right user
        local TopRight = Utils.New("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 10),
            Size = UDim2.new(0, 220, 0, 28),
            Parent = Main,
        })
        -- 28px invisible hitbox around the 16px icon (easy to hit).
        local gearHit = Utils.New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -120, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 28),
            AutoButtonColor = false,
            Parent = TopRight,
        })
        local gear = Icons.Button("settings", 16, T.TextDim, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Parent = gearHit,
        })
        gear:SetAttribute("IRole", "Dim")
        local infoIcon = Icons.New("info", 14, T.TextDark, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -116, 0.5, 0),
            Parent = TopRight,
        })
        infoIcon:SetAttribute("IRole", "Dark")
        Utils.New("TextLabel", {
            Text = username,
            Font = ThemeData.Fonts.Medium,
            TextSize = 13,
            TextColor3 = T.TextDim,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(1, -94, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TopRight,
        })
        local Avatar = Utils.New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Color3.fromRGB(200, 200, 205),
            BorderSizePixel = 0,
            Parent = TopRight,
        })
        Utils.Corner(Avatar, 0, true)
        local avatarImg = Icons.New("user-round", 16, Color3.fromRGB(40, 40, 45), {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Parent = Avatar,
        })
        Utils.Corner(avatarImg, 0, true) -- circular mask for the headshot below
        -- Real headshot of the person running the script (non-blocking).
        task.spawn(function()
            local ok, lp = pcall(function() return Players.LocalPlayer end)
            if ok and lp then
                local ok2, content, ready = pcall(function()
                    return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                end)
                if ok2 and ready and typeof(content) == "string" and #content > 0 then
                    avatarImg.Image = content
                    avatarImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end)

        local PageHolder = Utils.New("Frame", {
            Position = UDim2.new(0, 244, 0, 44),
            Size = UDim2.new(1, -256, 1, -56),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = Main,
        })

        -- Window object
        local Window = {
            Gui = Gui,
            Main = Main,
            Sidebar = Sidebar,
            Tabs = {},
            Pages = {},
            _TabOrder = 0,
            _ActiveTab = nil,
            _Rows = {},
            _TabHolder = TabHolder,
            _PageHolder = PageHolder,
            Accent = accent,
            Theme = T,
            ThemeName = themeName,
            _AccentUpdaters = {},
            _ThemedCards = {},
            _Icons = Icons,
        }

        function Window:SetAccent(color)
            self.Accent = color
            Library._Accent = color
            self:_RefreshWordmark()
            for _, tab in pairs(self.Tabs) do
                if tab.Btn and tab.Active then
                    tab.Indicator.BackgroundColor3 = color
                end
            end
            for _, fn in ipairs(self._AccentUpdaters) do
                pcall(fn, color)
            end
        end

        function Window:SetTheme(name)
            local NT = ThemeDefs[name]
            if not NT then return end
            self.Theme = NT
            self.ThemeName = name
            Library._ThemeName = name
            Main.BackgroundColor3 = NT.Main
            Sidebar.BackgroundColor3 = NT.Sidebar
            SearchBox.BackgroundColor3 = NT.Search
            for _, e in ipairs(self._ThemedCards) do
                if e.Obj and e.Obj.Parent then
                    if e.Role == "Card" then e.Obj.BackgroundColor3 = NT.Card
                    elseif e.Role == "Row" and not e.Obj:GetAttribute("On") then
                        e.Obj.BackgroundColor3 = NT.Row
                    end
                end
            end
            for _, d in ipairs(Main:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    local role = d:GetAttribute("TRole")
                    if role == "Primary" then d.TextColor3 = NT.Text
                    elseif role == "Dim" then d.TextColor3 = NT.TextDim
                    elseif role == "Dark" then d.TextColor3 = NT.TextDark end
                elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                    local irole = d:GetAttribute("IRole")
                    if irole == "Primary" then d.ImageColor3 = NT.Text
                    elseif irole == "Dim" then d.ImageColor3 = NT.TextDim
                    elseif irole == "Dark" then d.ImageColor3 = NT.TextDark end
                elseif d:IsA("UIStroke") then
                    if d:GetAttribute("Hairline") then
                        d.Color = NT.Stroke
                        d.Transparency = NT.StrokeTrans
                    end
                end
            end
            -- active tab icon stays white regardless of theme
            if self._ActiveTab and self._ActiveTab.Icon then
                self._ActiveTab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            self:_RefreshWordmark()
        end

        function Window:_RefreshWordmark()
            if not self._Wordmark then return end
            local function rgb(c)
                return string.format("rgb(%d,%d,%d)",
                    math.floor(c.R * 255 + 0.5),
                    math.floor(c.G * 255 + 0.5),
                    math.floor(c.B * 255 + 0.5))
            end
            self._Wordmark.Text = string.format(
                '<font color="%s">%s</font> <font color="%s">%s</font>',
                rgb(self.Theme.Text), self._Title1,
                rgb(self.Accent), self._Title2)
        end

        function Window:SetScale(s)
            Library._Scale = math.clamp(s, 0.5, 1.5)
            FitScreen()
        end

        function Window:Toggle(visible)
            if visible == nil then visible = not Main.Visible end
            Main.Visible = visible
            Backdrop.Visible = visible
        end

        function Window:Unload()
            Gui:Destroy()
        end

        function Window:Notify(text, sub)
            local toast = Utils.New("Frame", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -14, 1, -14),
                Size = UDim2.new(0, 250, 0, 56),
                BackgroundColor3 = self.Theme.Card,
                BorderSizePixel = 0,
                ZIndex = 50,
                Parent = Main,
            })
            Utils.Corner(toast, 10)
            Utils.Hairline(Utils.Stroke(toast, self.Theme.Stroke, 0.93, 1), self.Theme)
            Utils.New("TextLabel", {
                Text = text or "Saved",
                Font = ThemeData.Fonts.Medium,
                TextSize = 13,
                TextColor3 = self.Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toast,
            })
            Utils.New("TextLabel", {
                Text = sub or "",
                Font = ThemeData.Fonts.Regular,
                TextSize = 12,
                TextColor3 = self.Theme.TextDim,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 28),
                Size = UDim2.new(1, -24, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toast,
            })
            Utils.Tween(toast, { Position = UDim2.new(1, -14, 1, -70) }, 0.25)
            task.delay(2.2, function()
                local tw = Utils.Tween(toast, { Position = UDim2.new(1, -14, 1, -14) }, 0.25)
                tw.Completed:Wait()
                pcall(function() toast:Destroy() end)
            end)
        end

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(SearchInput.Text)
            for _, row in ipairs(Window._Rows) do
                if q == "" then
                    row.Frame.Visible = true
                else
                    row.Frame.Visible = (string.find(string.lower(row.Name or ""), q, 1, true) ~= nil)
                end
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
                Window:Toggle()
            end
        end)

        -- Modals (need Window.Main first, so build here)
        local colorApi = BuildColorPicker(Window, Utils, ThemeData)
        Window._ColorApi = colorApi
        function Window:OpenColorPicker(default, cb, anchor)
            colorApi.Open(default, cb, anchor)
        end

        local settingsFrame = BuildSettings(Window, Utils, ThemeData)
        Window._Settings = settingsFrame

        gearHit.MouseButton1Click:Connect(function()
            local isOpen = not settingsFrame.Visible
            settingsFrame.Visible = isOpen
            if Window._SettingsZone then
                Window._SettingsZone.Visible = isOpen
            end
        end)
        gearHit.MouseEnter:Connect(function()
            gear:SetAttribute("IRole", "Active")
            Utils.Tween(gear, { ImageColor3 = Window.Accent }, 0.15)
        end)
        gearHit.MouseLeave:Connect(function()
            gear:SetAttribute("IRole", "Dim")
            Utils.Tween(gear, { ImageColor3 = Window.Theme.TextDim }, 0.15)
        end)

        -- Tab factory + attach controls
        function Window:Tab(tabOpts)
            local Tab = CreateTab(self, Utils, ThemeData, tabOpts)
            -- attach control constructors (edit list here to add new controls)
            function Tab:Toggle(t) return Controls.Toggle(self, Utils, ThemeData, Library, t) end
            function Tab:Slider(t) return Controls.SliderModule.CreateSlider(self, Utils, ThemeData, Library, t) end
            function Tab:Range(t) return Controls.SliderModule.CreateRange(self, Utils, ThemeData, Library, t) end
            function Tab:Dropdown(t) return Controls.Dropdown(self, Utils, ThemeData, Library, t) end
            function Tab:Colorpicker(t)
                t = t or {}
                local rowName = t.Name or "Color"
                local col = t.Default or self.Window.Accent
                Library.Flags[rowName] = col
                local row = self:_Row(rowName, 44)
                local prev = Utils.New("TextButton", {
                    Text = "",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    BackgroundColor3 = col,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = row,
                })
                Utils.Corner(prev, 0, true)
                Utils.Stroke(prev, Color3.fromRGB(255, 255, 255), 0.85, 1)
                prev.MouseButton1Click:Connect(function()
                    self.Window:OpenColorPicker(col, function(c)
                        col = c
                        Library.Flags[rowName] = c
                        prev.BackgroundColor3 = c
                        if t.Callback then task.spawn(t.Callback, c) end
                    end)
                end)
                return {
                    Set = function(c) col = c prev.BackgroundColor3 = c Library.Flags[rowName] = c end,
                    Get = function() return col end,
                    Row = row,
                }
            end
            return Tab
        end

        Window._Wordmark = Wordmark
        Window._Title1 = title1
        Window._Title2 = title2
        Window:_RefreshWordmark()

        table.insert(Library._Windows, Window)
        return Window
    end

    return CreateWindow
end
