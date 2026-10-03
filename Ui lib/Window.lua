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
	local player = Players.LocalPlayer
	local user = opts.User or (player and player.DisplayName) or "Past Owl"
	local till = opts.Till or "1 Jan 2025"
	local avatarImage
	pcall(function()
		if player then
			local img, ready = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			if ready then
				avatarImage = img
			end
		end
	end)

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
	local trackedPopups = {}
	local function insideGui(g, p)
		local a = g.AbsolutePosition
		local s = g.AbsoluteSize
		return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
	end
	function ctx.TrackPopup(frame, closeFn, opener)
		for i = #trackedPopups, 1, -1 do
			local t = trackedPopups[i]
			table.remove(trackedPopups, i)
			if t.frame ~= frame and t.frame and t.frame.Parent then
				pcall(t.close)
			end
		end
		table.insert(trackedPopups, { frame = frame, close = closeFn, opener = opener })
	end
	function ctx.UntrackPopup(frame)
		for i = #trackedPopups, 1, -1 do
			local t = trackedPopups[i]
			if t.frame == frame or not t.frame or not t.frame.Parent then
				table.remove(trackedPopups, i)
			end
		end
	end
	local binds = {}
	local function keyNameOf(input)
		local t = tostring(input.UserInputType)
		if t == "Enum.UserInputType.Keyboard" then
			local k = tostring(input.KeyCode):gsub("Enum%.KeyCode%.", "")
			if k == "Unknown" or k == "" then
				return nil
			end
			return k
		end
		local mb = string.match(t, "MouseButton(%d+)")
		if mb then
			return "Mouse" .. mb
		end
		return nil
	end
	local function normKey(k)
		return (string.gsub(string.lower(tostring(k or "")), "%s+", ""))
	end
	function ctx.SetBind(api, data)
		for i = #binds, 1, -1 do
			if binds[i].api == api then
				table.remove(binds, i)
			end
		end
		if data and data.Key then
			table.insert(binds, { api = api, key = normKey(data.Key), mode = data.Mode or "Toggle" })
		end
	end
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		local k = keyNameOf(input)
		if not k then
			return
		end
		k = normKey(k)
		for _, b in ipairs(binds) do
			if b.key == k and b.api and b.api.Get and b.api.Set then
				if b.mode == "Hold" then
					b.api.Set(true)
				else
					b.api.Set(not b.api.Get())
				end
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		local k = keyNameOf(input)
		if not k then
			return
		end
		k = normKey(k)
		for _, b in ipairs(binds) do
			if b.key == k and b.mode == "Hold" and b.api and b.api.Set then
				b.api.Set(false)
			end
		end
	end)
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local p = input.Position
		for i = #trackedPopups, 1, -1 do
			local t = trackedPopups[i]
			if not t.frame or not t.frame.Parent then
				table.remove(trackedPopups, i)
			else
				local okIn, inPop = pcall(insideGui, t.frame, p)
				local inOp = false
				if t.opener and t.opener.Parent then
					local okOp, rOp = pcall(insideGui, t.opener, p)
					inOp = okOp and rOp
				end
				if (not okIn or not inPop) and not inOp then
					table.remove(trackedPopups, i)
					pcall(t.close)
				end
			end
		end
	end)

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
		Size = opts.Size or UDim2.new(0, 860, 0, 520),
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

	local logoIcon = Util.New("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		Size = UDim2.new(0, 28, 0, 28),
		Image = "rbxassetid://113584210603166",
		BorderSizePixel = 0,
	}, top)

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
		Size = UDim2.new(1, 0, 1, -110),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
	}, side)
	Util.List(nav, Enum.FillDirection.Vertical, 2)

	local profile = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
	}, side)
	Util.Corner(profile, 10)
	Util.Padding(profile, 0, 10, 0, 10)
	local pav = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, profile)
	Util.Corner(pav, 18)
	if avatarImage then
		local pavImg = Util.New("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = avatarImage,
			BorderSizePixel = 0,
		}, pav)
		Util.Corner(pavImg, 18)
	else
		local pavIco = Icons.Make(pav, "user", 20, Color3.fromRGB(10, 10, 14))
		pavIco.AnchorPoint = Vector2.new(0.5, 0.5)
		pavIco.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
	Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 44, 0, 8),
		Size = UDim2.new(1, -44, 0, 20),
		Text = user,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 44, 0, 28),
		Size = UDim2.new(1, -44, 0, 18),
		Text = (player and ("@" .. player.Name)) or ("Till:  " .. till),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 12,
		Font = Theme.FontReg,
		TextColor3 = Theme.TextMute,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)

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

	local winApi = {}

	function winApi.SetAccent(c)
		ctx.SetAccent(c)
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
			local n = 0
			local function beginRow(o)
				o = o or {}
				n = n + 1
				o.Order = n * 2
				return o
			end

			function sec.AddToggle(o)
				o = beginRow(o)
				local api = ToggleMod.Create(card, o, ctx)
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
					if api._kp and api._kp.Frame and api._kp.Frame.Parent then
						ctx.UntrackPopup(api._kp.Frame)
						api._kp.Close()
						api._kp = nil
						return
					end
					local mPos = UserInputService:GetMouseLocation()
					local cur = api._bind or {}
					local kp = KeybindMod.Popup(popups, {
						Key = cur.Key or "Mouse5",
						Mode = cur.Mode or "Toggle",
						Value = cur.Value,
						Show = cur.Show,
						Position = UDim2.new(0, mPos.X, 0, mPos.Y),
						Callback = function(data)
							api._bind = data
							ctx.SetBind(api, data)
						end,
					})
					api._kp = kp
					local f = kp.Frame
					ctx.TrackPopup(f, function()
						ctx.UntrackPopup(f)
						if api._kp and api._kp.Frame == f then
							api._kp = nil
						end
						kp.Close()
					end, chevBtn)
				end)
				return api
			end
			function sec.AddButton(o)
				o = beginRow(o)
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, (o.Height or 38) + 12),
					LayoutOrder = o.Order,
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
				o = beginRow(o)
				local api = SliderMod.Create(card, o, ctx)
				ctx.TrackElement(o.Name, api, "Slider")
				return api
			end
			function sec.AddDropdown(o)
				o = beginRow(o)
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 68),
					LayoutOrder = o.Order,
				}, card)
				local api = DropdownMod.Create(wrap, o, ctx)
				ctx.TrackElement(o.Name or o.Title, api, "Dropdown")
				return api
			end
			function sec.AddColorpicker(o)
				o = beginRow(o)
				o.Callback = o.Callback or function(c) ctx.SetAccent(c) end
				local api = ColorMod.Inline(card, o, ctx)
				ctx.TrackElement(o.Name, api, "Color")
				return api
			end
			function sec.AddCoords(o)
				o = beginRow(o or {})
				local api = InputMod.Coords(card, o, ctx)
				api.Instance.LayoutOrder = o.Order
				return api
			end
			function sec.AddInput(o)
				o = beginRow(o)
				local wrap = Util.New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
					LayoutOrder = o.Order,
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
				local txt = (type(o) == "string" and o) or ((type(o) == "table" and o.Text) or "Label")
				local ord = beginRow({})
				local t = Util.New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					LayoutOrder = ord.Order,
					Text = txt,
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

	local presetFrame
	local function closePreset()
		if presetFrame then
			ctx.UntrackPopup(presetFrame)
			presetFrame:Destroy() presetFrame = nil
		end
		local cf = popups:FindFirstChild("CreatePopup")
		if cf then
			ctx.UntrackPopup(cf)
			cf:Destroy()
		end
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
		ctx.TrackPopup(presetFrame, closePreset, cfgBtn)

		plus.MouseButton1Click:Connect(function()
			local cp = popups:FindFirstChild("CreatePopup")
			if cp then
				ctx.UntrackPopup(cp)
				cp:Destroy() return
			end
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
			ctx.TrackPopup(c2, function()
				ctx.UntrackPopup(c2)
				if c2 and c2.Parent then
					c2:Destroy()
				end
			end, plus)
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
					LayoutOrder = found,
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
				if found >= 20 then
					break
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
