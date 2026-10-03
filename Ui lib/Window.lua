local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))
local ToggleMod = require(script.Parent:WaitForChild("Toggle"))
local ButtonMod = require(script.Parent:WaitForChild("Button"))
local SliderMod = require(script.Parent:WaitForChild("Slider"))
local DropdownMod = require(script.Parent:WaitForChild("Dropdown"))
local InputMod = require(script.Parent:WaitForChild("Input"))
local ColorMod = require(script.Parent:WaitForChild("Colorpicker"))
local KeybindMod = require(script.Parent:WaitForChild("Keybind"))
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Window = {}

function Window.Create(opts)
	opts = opts or {}
	local title = opts.Title or "Evenesce"
	local user = opts.User or "Past Owl"
	local till = opts.Till or "1 Jan 2025"

	local ctx = {
		accentCbs = {},
		all = {},
		tabs = {},
	}
	function ctx.BindAccent(cb)
		table.insert(ctx.accentCbs, cb)
	end
	function ctx.SetAccent(c)
		Theme.Accent = c
		for _, cb in ipairs(ctx.accentCbs) do
			pcall(cb, c)
		end
	end
	function ctx.OnToggleCreated(api, o)
		table.insert(ctx.all, { Name = o.Name or "", Api = api, Kind = "Toggle", Opts = o })
	end
	function ctx.TrackElement(name, api, kind)
		table.insert(ctx.all, { Name = name or "", Api = api, Kind = kind or "" })
	end

	local gui = Util.New("ScreenGui", {
		Name = "EvenesceGui",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	local parented = false
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then gui.Parent = h parented = true end
	end
	if not parented then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local popups = Util.New("Frame", {
		Name = "EvenPopups",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 60,
	}, gui)

	local dim = Util.New("TextButton", {
		Name = "Dim",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.55,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 59,
	}, gui)

	local root = Util.New("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 980, 0, 600),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, gui)
	Util.Corner(root, Theme.RadiusWin)
	Util.Stroke(root, Color3.fromRGB(28, 28, 38), 1)

	local scale = Util.New("UIScale", {}, root)
	Util.Drag(root, root)

	local top = Util.New("Frame", {
		Name = "Top",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 72),
	}, root)

	local logoIcon = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		Size = UDim2.new(0, 28, 0, 28),
	}, top)
	local b1 = Util.New("Frame", {
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(0, 24, 0, 8),
		BackgroundColor3 = Color3.fromRGB(95, 95, 150),
		BorderSizePixel = 0,
		Rotation = -8,
	}, logoIcon)
	Util.Corner(b1, 3)
	local b2 = Util.New("Frame", {
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(0, 24, 0, 8),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Rotation = -8,
	}, logoIcon)
	Util.Corner(b2, 3)
	ctx.BindAccent(function(a) b2.BackgroundColor3 = a end)

	Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 18),
		Size = UDim2.new(0, 200, 0, 32),
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 20,
		Font = Theme.FontBold,
		TextColor3 = Theme.Text,
	}, top)
	local spark = Icons.Make(top, "star", 11, Theme.Accent)
	spark.Position = UDim2.new(0, 196, 0, 20)
	ctx.BindAccent(function(a) spark.ImageColor3 = a end)

	local cfgBtn = Util.New("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.new(0, 280, 0, 44),
		BackgroundColor3 = Theme.Panel,
		Text = "",
		AutoButtonColor = false,
	}, top)
	Util.Corner(cfgBtn, 10)
	local cfgIco = Icons.Make(cfgBtn, "box", 17, Theme.TextDim)
	cfgIco.Position = UDim2.new(0, 12, 0.5, 0)
	cfgIco.AnchorPoint = Vector2.new(0, 0.5)
	local cfgLbl = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Text = "Player",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		Font = Theme.FontReg,
		TextColor3 = Theme.TextMute,
	}, cfgBtn)
	local cfgChev = Icons.Make(cfgBtn, "chevron-down", 17, Theme.Text)
	cfgChev.AnchorPoint = Vector2.new(1, 0.5)
	cfgChev.Position = UDim2.new(1, -12, 0.5, 0)

	local gear = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 14),
		Size = UDim2.new(0, 44, 0, 44),
		BackgroundColor3 = Theme.Panel,
		Text = "",
		AutoButtonColor = false,
	}, top)
	Util.Corner(gear, 10)
	local gearIco = Icons.Make(gear, "settings", 18, Theme.Text)
	gearIco.AnchorPoint = Vector2.new(0.5, 0.5)
	gearIco.Position = UDim2.new(0.5, 0, 0.5, 0)

	local body = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 72),
		Size = UDim2.new(1, 0, 1, -72),
	}, root)

	local side = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0, 228, 1, -12),
	}, body)

	local searchHolder = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
	}, side)
	local searchBox = InputMod.Search(searchHolder, { Placeholder = "Search" })

	local nav = Util.New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -46),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
	}, side)
	Util.List(nav, Enum.FillDirection.Vertical, 2)

	local crumb = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 252, 0, 0),
		Size = UDim2.new(1, -268, 0, 38),
	}, body)
	local crumbA = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 120, 1, 0),
		Text = "General",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		Font = Theme.FontMed,
		TextColor3 = Theme.TextDim,
	}, crumb)
	local crumbSep = Icons.Make(crumb, "chevron-right", 14, Theme.TextMute)
	crumbSep.Position = UDim2.new(0, 86, 0.5, 0)
	crumbSep.AnchorPoint = Vector2.new(0, 0.5)
	local crumbB = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 106, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Text = "Player",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		Font = Theme.FontReg,
		TextColor3 = Theme.TextMute,
	}, crumb)

	local contentArea = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 252, 0, 38),
		Size = UDim2.new(1, -264, 1, -50),
		ClipsDescendants = true,
	}, body)

	local searchPage = Util.New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		BorderSizePixel = 0,
	}, contentArea)
	Util.List(searchPage, Enum.FillDirection.Vertical, 8)
	Util.Padding(searchPage, 0, 0, 8, 12)
	ctx.BindAccent(function(a) searchPage.ScrollBarImageColor3 = a end)

	local pages = {}
	local currentTab

	local function addDivider(card)
		Util.New("Frame", {
			BackgroundColor3 = Theme.Divider,
			BackgroundTransparency = 0.4,
			Size = UDim2.new(1, -28, 0, 1),
			Position = UDim2.new(0, 14, 0, 0),
		}, card)
	end

	local winApi = {}

	function winApi.SetAccent(c)
		ctx.SetAccent(c)
	end

	local openSub = nil
	local subLang, subDpi, subStyle
	local settingsFrame
	local settingsOpen = false

	local function toggleSub(which)
		if subLang then subLang:Destroy() subLang = nil end
		if subDpi then subDpi:Destroy() subDpi = nil end
		if subStyle then subStyle:Destroy() subStyle = nil end
		if openSub == which then openSub = nil return end
		openSub = which
		if not settingsFrame then return end
		if which == "lang" then
			subLang = Util.New("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(0, -8, 0, 0),
				Size = UDim2.new(0, 220, 0, 86),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				ZIndex = 71,
			}, settingsFrame)
			Util.Corner(subLang, 10)
			Util.Stroke(subLang, Theme.Stroke, 1)
			Util.Padding(subLang, 6, 8, 6, 8)
			Util.List(subLang, Enum.FillDirection.Vertical, 4)
			local langs = { "Russian", "English" }
			local sel = "English"
			for _, l in ipairs(langs) do
				local b = Util.New("TextButton", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = l == sel and Color3.fromRGB(30, 30, 42) or Color3.fromRGB(22, 22, 30),
					Text = "",
					AutoButtonColor = false,
				}, subLang)
				Util.Corner(b, 6)
				if l == sel then
					local ck = Icons.Make(b, "check", 14, Theme.Text)
					ck.Position = UDim2.new(0, 10, 0.5, 0)
					ck.AnchorPoint = Vector2.new(0, 0.5)
				end
				Util.New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, l == sel and 32 or 12, 0, 0),
					Size = UDim2.new(1, -40, 1, 0),
					Text = l,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 13,
					Font = Theme.FontMed,
					TextColor3 = Theme.Text,
				}, b)
				b.MouseButton1Click:Connect(function()
					sel = l
					local cur = openSub
					openSub = nil
					toggleSub(cur)
					toggleSub(cur)
				end)
			end
		elseif which == "dpi" then
			subDpi = Util.New("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(0, -8, 0, 0),
				Size = UDim2.new(0, 240, 0, 108),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				ZIndex = 71,
			}, settingsFrame)
			Util.Corner(subDpi, 10)
			Util.Stroke(subDpi, Theme.Stroke, 1)
			Util.Padding(subDpi, 10, 12, 10, 12)
			local inner = Util.New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, subDpi)
			SliderMod.Create(inner, { Name = "DPI", Min = 50, Max = 150, Default = 100, Callback = function(v)
				scale.Scale = math.clamp(v / 100, 0.7, 1.4)
			end }, ctx)
			local ar = Util.New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
			}, inner)
			Util.New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -40, 1, 0),
				Text = "Auto scale",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 13,
				Font = Theme.FontMed,
				TextColor3 = Theme.Text,
			}, ar)
			local ab = Util.New("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundColor3 = Theme.Accent,
				Text = "",
				AutoButtonColor = false,
			}, ar)
			Util.Corner(ab, 5)
			local abCheck = Icons.Make(ab, "check", 13, Color3.fromRGB(18, 18, 28))
			abCheck.AnchorPoint = Vector2.new(0.5, 0.5)
			abCheck.Position = UDim2.new(0.5, 0, 0.5, 0)
			local on = true
			ab.MouseButton1Click:Connect(function()
				on = not on
				ab.BackgroundColor3 = on and Theme.Accent or Theme.CheckOff
				abCheck.ImageTransparency = on and 0 or 1
				if on then scale.Scale = 1 end
			end)
			ctx.BindAccent(function(a) if on then ab.BackgroundColor3 = a end end)
		elseif which == "style" then
			subStyle = Util.New("Frame", {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(1, 8, 0, 40),
				Size = UDim2.new(0, 250, 0, 300),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				ZIndex = 71,
			}, settingsFrame)
			Util.Corner(subStyle, 12)
			Util.Stroke(subStyle, Theme.Stroke, 1)
			Util.Padding(subStyle, 8, 8, 8, 8)
			local inner = Util.New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, subStyle)
			ColorMod.Inline(inner, { Name = "Menu accent", Default = Theme.Accent, Callback = function(c) ctx.SetAccent(c) end }, ctx)
		end
	end

	local function buildSettings()
		if settingsFrame then settingsFrame:Destroy() settingsFrame = nil end
		settingsFrame = Util.New("Frame", {
			Name = "Settings",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 64),
			Size = UDim2.new(0, 260, 0, 320),
			BackgroundColor3 = Color3.fromRGB(22, 22, 30),
			BorderSizePixel = 0,
			ZIndex = 70,
			Visible = settingsOpen,
		}, root)
		Util.Corner(settingsFrame, 12)
		Util.Stroke(settingsFrame, Theme.Stroke, 1)
		Util.Padding(settingsFrame, 12, 12, 12, 12)

		local prof = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 52),
		}, settingsFrame)
		local av = Util.New("Frame", {
			Size = UDim2.new(0, 44, 0, 44),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}, prof)
		Util.Corner(av, 22)
		local avIco = Icons.Make(av, "user", 26, Color3.fromRGB(10, 10, 14))
		avIco.AnchorPoint = Vector2.new(0.5, 0.5)
		avIco.Position = UDim2.new(0.5, 0, 0.5, 0)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 52, 0, 2),
			Size = UDim2.new(1, -52, 0, 22),
			Text = user,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme.FontMed,
			TextColor3 = Theme.Text,
		}, prof)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 52, 0, 24),
			Size = UDim2.new(1, -52, 0, 20),
			Text = "Till:  " .. till,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.TextMute,
		}, prof)

		Util.New("Frame", {
			BackgroundColor3 = Theme.Divider,
			BackgroundTransparency = 0.3,
			Size = UDim2.new(1, 0, 0, 1),
		}, settingsFrame)

		local rows = {
			{ Ico = "plus-circle", Name = "Installed hotkeys", Id = "hotkeys" },
			{ Ico = "languages", Name = "Menu language", Id = "lang" },
			{ Ico = "scaling", Name = "DPI Menu", Id = "dpi" },
			{ Ico = "palette", Name = "Styles", Id = "styles", Extra = true },
		}
		for _, r in ipairs(rows) do
			local b = Util.New("TextButton", {
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				Text = "",
				AutoButtonColor = false,
			}, settingsFrame)
			Util.Corner(b, 8)
			local ri = Icons.Make(b, r.Ico, 16, Theme.TextDim)
			ri.Position = UDim2.new(0, 8, 0.5, 0)
			ri.AnchorPoint = Vector2.new(0, 0.5)
			Util.New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 34, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				Text = r.Name,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 14,
				Font = Theme.FontMed,
				TextColor3 = Theme.Text,
			}, b)
			if r.Extra then
				local sunIco = Icons.Make(b, "sun", 15, Theme.TextDim)
				sunIco.AnchorPoint = Vector2.new(1, 0.5)
				sunIco.Position = UDim2.new(1, -28, 0.5, 0)
				local dot = Util.New("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.new(0, 14, 0, 14),
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
				}, b)
				Util.Corner(dot, 7)
				ctx.BindAccent(function(a) dot.BackgroundColor3 = a end)
			end
			local chv = Icons.Make(b, "chevron-right", 16, Theme.TextDim)
			chv.AnchorPoint = Vector2.new(1, 0.5)
			chv.Position = UDim2.new(1, -8, 0.5, 0)
			b.MouseButton1Click:Connect(function()
				if r.Id == "hotkeys" then
					winApi.ShowHotkeys()
				elseif r.Id == "lang" then
					toggleSub("lang")
				elseif r.Id == "dpi" then
					toggleSub("dpi")
				elseif r.Id == "styles" then
					toggleSub("style")
				end
			end)
		end
		Util.List(settingsFrame, Enum.FillDirection.Vertical, 4)
	end

	function winApi.AddTab(def)
		def = def or {}
		local tname = def.Name or "Tab"
		local ticon = def.Icon or tname

		local navBtn = Util.New("TextButton", {
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundColor3 = Theme.Bg,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
		}, nav)
		Util.Corner(navBtn, 8)

		local indicator = Util.New("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -12, 0.5, 0),
			Size = UDim2.new(0, 4, 0, 20),
			BackgroundColor3 = Theme.Accent,
			Visible = false,
			BorderSizePixel = 0,
		}, navBtn)
		Util.Corner(indicator, 2)
		ctx.BindAccent(function(a) indicator.BackgroundColor3 = a end)

		local ico = Icons.Make(navBtn, ticon, 18, Theme.TextMute)
		ico.Name = "Ico"
		ico.Position = UDim2.new(0, 14, 0.5, 0)
		ico.AnchorPoint = Vector2.new(0, 0.5)
		local nLbl = Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 44, 0, 0),
			Size = UDim2.new(1, -54, 1, 0),
			Text = tname,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
			Font = Theme.FontMed,
			TextColor3 = Theme.TextMute,
			Name = "Lbl",
		}, navBtn)

		local page = Util.New("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			BorderSizePixel = 0,
		}, contentArea)
		Util.Padding(page, 0, 0, 8, 8)
		ctx.BindAccent(function(a) page.ScrollBarImageColor3 = a end)

		local cols = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, page)
		Util.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, cols)
		local left = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, cols)
		Util.List(left, Enum.FillDirection.Vertical, 12)
		local right = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, cols)
		Util.List(right, Enum.FillDirection.Vertical, 12)

		local tab = { Name = tname, Page = page, Button = navBtn }

		local function select()
			if currentTab then
				currentTab.Page.Visible = false
				currentTab.Button.BackgroundTransparency = 1
				local li = currentTab.Button:FindFirstChild("Lbl")
				if li then li.TextColor3 = Theme.TextMute end
				local ii = currentTab.Button:FindFirstChild("Ico")
				if ii and ii:IsA("ImageLabel") then ii.ImageColor3 = Theme.TextMute end
				for _, ch in ipairs(currentTab.Button:GetChildren()) do
					if ch:IsA("Frame") then ch.Visible = false end
				end
			end
			currentTab = tab
			page.Visible = true
			searchPage.Visible = false
			if searchBox and searchBox.Box then searchBox.Box.Text = "" end
			navBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			navBtn.BackgroundTransparency = 0
			nLbl.TextColor3 = Theme.Text
			ico.ImageColor3 = Theme.Text
			indicator.Visible = true
			crumbA.Text = tname
			crumbB.Text = tname == "General" and "Player" or ""
		end

		navBtn.MouseButton1Click:Connect(select)
		pages[#pages + 1] = tab
		ctx.tabs[#ctx.tabs + 1] = tab
		if #pages == 1 then select() end

		function tab.AddSection(sdef)
			sdef = sdef or {}
			local stitle = sdef.Title or ""
			local sideSel = sdef.Side or sdef.Column or "Left"
			local host = (sideSel == "Right" or sideSel == 2 or sideSel == "right") and right or left

			local outer = Util.New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, host)

			if stitle ~= "" then
				Util.New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					Text = stitle,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					Font = Theme.FontMed,
					TextColor3 = Theme.TextMute,
				}, outer)
			end

			local card = Util.New("Frame", {
				BackgroundColor3 = Theme.Card,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
			}, outer)
			Util.Corner(card, Theme.RadiusCard)
			Util.List(card, Enum.FillDirection.Vertical, 0)
			Util.Padding(card, 4, 0, 4, 0)

			local sec = {}
			local order = 0
			local function bump()
				order = order + 1
				return order
			end
			local function sep()
				addDivider(card)
			end

			function sec.AddToggle(o)
				o.Order = bump()
				local api = ToggleMod.Create(card, o, ctx)
				sep()
				ctx.TrackElement(o.Name, api, "Toggle")
				local chevBtn = Util.New("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.new(0, 36, 0, 32),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 2,
				}, api.Row)
				chevBtn.MouseButton1Click:Connect(function()
					local mPos = UserInputService:GetMouseLocation()
					KeybindMod.Popup(popups, {
						Key = "Mouse 5",
						Mode = "Toggle",
						Position = UDim2.new(0, mPos.X, 0, mPos.Y),
						Callback = function() end,
					})
				end)
				return api
			end
			function sec.AddButton(o)
				o.Order = bump()
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, (o.Height or 38) + 12),
				}, card)
				Util.Padding(wrap, 6, 14, 6, 14)
				local bWrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, o.Height or 38),
				}, wrap)
				local api = ButtonMod.Create(bWrap, o)
				ctx.TrackElement(o.Name, api, "Button")
				return api
			end
			function sec.AddSlider(o)
				o.Order = bump()
				local api = SliderMod.Create(card, o, ctx)
				sep()
				ctx.TrackElement(o.Name, api, "Slider")
				return api
			end
			function sec.AddDropdown(o)
				o.Order = bump()
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 68),
				}, card)
				local api = DropdownMod.Create(wrap, o, ctx)
				ctx.TrackElement(o.Name or o.Title, api, "Dropdown")
				return api
			end
			function sec.AddColorpicker(o)
				o.Order = bump()
				o.Callback = o.Callback or function(c) ctx.SetAccent(c) end
				local api = ColorMod.Inline(card, o, ctx)
				ctx.TrackElement(o.Name, api, "Color")
				return api
			end
			function sec.AddCoords(o)
				return InputMod.Coords(card, o or {}, ctx)
			end
			function sec.AddInput(o)
				o.Order = bump()
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
				}, card)
				Util.Padding(wrap, 6, 14, 6, 14)
				local inner = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
				}, wrap)
				local api = InputMod.Textbox(inner, o)
				ctx.TrackElement(o.Name or o.Placeholder, api, "Input")
				return api
			end
			function sec.AddLabel(o)
				local t = Util.New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					Text = (type(o) == "string" and o) or o.Text or "Label",
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 13,
					Font = Theme.FontReg,
					TextColor3 = Theme.TextMute,
				}, card)
				Util.Padding(t, 0, 14, 0, 14)
				return t
			end
			return sec
		end

		return tab
	end

	gear.MouseButton1Click:Connect(function()
		settingsOpen = not settingsOpen
		if settingsOpen then
			buildSettings()
		else
			if settingsFrame then settingsFrame.Visible = false end
			if subLang then subLang:Destroy() subLang = nil end
			if subDpi then subDpi:Destroy() subDpi = nil end
			if subStyle then subStyle:Destroy() subStyle = nil end
			openSub = nil
		end
	end)

	local presetFrame
	local function closePreset()
		if presetFrame then presetFrame:Destroy() presetFrame = nil end
		local cf = popups:FindFirstChild("CreatePopup")
		if cf then cf:Destroy() end
	end

	cfgBtn.MouseButton1Click:Connect(function()
		if presetFrame then closePreset() return end
		presetFrame = Util.New("Frame", {
			Name = "PresetPopup",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 64),
			Size = UDim2.new(0, 280, 0, 300),
			BackgroundColor3 = Color3.fromRGB(22, 22, 30),
			ZIndex = 70,
		}, root)
		Util.Corner(presetFrame, 12)
		Util.Stroke(presetFrame, Theme.Stroke, 1)
		Util.Padding(presetFrame, 10, 10, 10, 10)

		local hr = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36) }, presetFrame)
		local pill = Util.New("Frame", {
			Size = UDim2.new(0, 110, 0, 32),
			BackgroundColor3 = Theme.Input,
			BorderSizePixel = 0,
		}, hr)
		Util.Corner(pill, 8)
		local pillIco = Icons.Make(pill, "cloud", 15, Theme.Text)
		pillIco.Position = UDim2.new(0, 10, 0.5, 0)
		pillIco.AnchorPoint = Vector2.new(0, 0.5)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 32, 0, 0),
			Size = UDim2.new(1, -36, 1, 0),
			Text = "Presets",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontMed,
			TextColor3 = Theme.Text,
		}, pill)
		local plus = Util.New("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 32, 0, 32),
			BackgroundColor3 = Theme.Input,
			Text = "",
		}, hr)
		Util.Corner(plus, 8)
		local plusIco = Icons.Make(plus, "plus", 16, Theme.Text)
		plusIco.AnchorPoint = Vector2.new(0.5, 0.5)
		plusIco.Position = UDim2.new(0.5, 0, 0.5, 0)

		local srow = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36) }, presetFrame)
		local sbox = Util.New("Frame", {
			BackgroundColor3 = Theme.Input,
			Size = UDim2.new(1, -36, 0, 32),
			BorderSizePixel = 0,
		}, srow)
		Util.Corner(sbox, 8)
		local sIco = Icons.Make(sbox, "search", 14, Theme.TextMute)
		sIco.Position = UDim2.new(0, 10, 0.5, 0)
		sIco.AnchorPoint = Vector2.new(0, 0.5)
		Util.New("TextBox", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 30, 0, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Text = "",
			PlaceholderText = "Search",
			PlaceholderColor3 = Theme.TextMute,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
		}, sbox)
		local sortIco = Icons.Make(srow, "arrow-up-down", 15, Theme.Text)
		sortIco.AnchorPoint = Vector2.new(1, 0.5)
		sortIco.Position = UDim2.new(1, -4, 0.5, 0)

		for i = 1, 3 do
			local r = Util.New("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = Theme.Input,
				Text = "",
				AutoButtonColor = false,
			}, presetFrame)
			Util.Corner(r, 8)
			if i == 1 then Util.Stroke(r, Theme.Accent, 1) end
			Util.New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -50, 1, 0),
				Text = "New config",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 13,
				Font = Theme.FontMed,
				TextColor3 = Theme.Text,
			}, r)
			local dIco = Icons.Make(r, "more-horizontal", 16, Theme.Text)
			dIco.AnchorPoint = Vector2.new(1, 0.5)
			dIco.Position = UDim2.new(1, -10, 0.5, 0)
		end
		Util.List(presetFrame, Enum.FillDirection.Vertical, 6)

		plus.MouseButton1Click:Connect(function()
			local cp = popups:FindFirstChild("CreatePopup")
			if cp then cp:Destroy() return end
			local c2 = Util.New("Frame", {
				Name = "CreatePopup",
				Size = UDim2.new(0, 260, 0, 130),
				Position = UDim2.new(0, 560, 0, 120),
				BackgroundColor3 = Color3.fromRGB(22, 22, 30),
				ZIndex = 72,
			}, popups)
			Util.Corner(c2, 12)
			Util.Stroke(c2, Theme.Stroke, 1)
			Util.Padding(c2, 10, 10, 10, 10)
			Util.List(c2, Enum.FillDirection.Vertical, 8)
			InputMod.Textbox(c2, { Placeholder = "Create a new", Icon = "plus-circle" })
			ButtonMod.Create(c2, { Name = "Create", Accent = true })
		end)
	end)

	function winApi.ShowHotkeys(rows)
		rows = rows or {
			{ "Enable NPS ESP", "Mouse5", "Toggle" },
			{ "Enable NPS ESP", "Mouse5", "Hold" },
			{ "Enable NPS ESP", "Mouse5", "Toggle" },
		}
		dim.Visible = true
		local h = KeybindMod.HotkeyTable(popups, rows)
		h.Frame.AnchorPoint = Vector2.new(0.5, 0)
		h.Frame.Position = UDim2.new(0.5, 0, 0, 90)
		local conn
		conn = dim.MouseButton1Click:Connect(function()
			h.Close() dim.Visible = false
			conn:Disconnect()
		end)
	end

	local function doSearch(q)
		q = string.lower(q or "")
		if q == "" then
			searchPage.Visible = false
			if currentTab then currentTab.Page.Visible = true end
			crumbA.Text = currentTab and currentTab.Name or "General"
			return
		end
		if currentTab then currentTab.Page.Visible = false end
		searchPage.Visible = true
		for _, ch in ipairs(searchPage:GetChildren()) do
			if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
		end
		crumbA.Text = "Search elements"

		local card = Util.New("Frame", {
			BackgroundColor3 = Theme.Card,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, searchPage)
		Util.Corner(card, 12)
		Util.List(card, Enum.FillDirection.Vertical, 0)
		Util.Padding(card, 4, 0, 4, 0)

		local found = 0
		for _, e in ipairs(ctx.all) do
			if string.find(string.lower(e.Name), q, 1, true) then
				found = found + 1
				local r = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
				}, card)
				local st = false
				if e.Api and e.Api.Get then
					local ok, v = pcall(function() return e.Api.Get() end)
					if ok and type(v) == "boolean" then st = v end
				end
				local bx = Util.New("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 14, 0.5, 0),
					Size = UDim2.new(0, 20, 0, 20),
					BackgroundColor3 = st and Theme.Accent or Theme.CheckOff,
					BorderSizePixel = 0,
				}, r)
				Util.Corner(bx, 6)
				local ck = Icons.Make(bx, "check", 13, st and Color3.fromRGB(18, 18, 28) or Color3.fromRGB(90, 90, 110))
				ck.AnchorPoint = Vector2.new(0.5, 0.5)
				ck.Position = UDim2.new(0.5, 0, 0.5, 0)
				ck.ImageTransparency = st and 0 or 0.4
				Util.New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 44, 0, 0),
					Size = UDim2.new(1, -80, 1, 0),
					Text = e.Name,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					Font = Theme.FontMed,
					TextColor3 = Theme.Text,
				}, r)
				local chv = Icons.Make(r, "chevron-right", 18, Theme.TextMute)
				chv.AnchorPoint = Vector2.new(1, 0.5)
				chv.Position = UDim2.new(1, -12, 0.5, 0)
				if found < 20 then
					addDivider(card)
				end
			end
		end
		if found == 0 then
			Util.New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 48),
				Text = "Nothing found",
				TextSize = 13,
				Font = Theme.FontReg,
				TextColor3 = Theme.TextMute,
			}, card)
		end
	end

	searchBox.Box:GetPropertyChangedSignal("Text"):Connect(function()
		doSearch(searchBox.Box.Text)
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			root.Visible = not root.Visible
		end
	end)

	winApi.Gui = gui
	winApi.Root = root
	winApi.Ctx = ctx

	return winApi
end

return Window
