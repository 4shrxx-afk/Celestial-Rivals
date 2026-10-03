local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))

local Keybind = {}

function Keybind.Popup(layer, opts)
	opts = opts or {}
	local currentKey = opts.Key or "Mouse5"
	local currentMode = opts.Mode or "Toggle"
	local currentVal = opts.Value == nil and true or opts.Value
	local currentShow = opts.Show == nil and false or opts.Show
	local done = opts.Callback or function() end

	local pop = Util.New("Frame", {
		Name = "KeybindPopup",
		BackgroundColor3 = Color3.fromRGB(22, 22, 30),
		Size = UDim2.new(0, 250, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		ZIndex = 80,
	}, layer)
	Util.Corner(pop, 12)
	Util.Stroke(pop, Theme.Stroke, 1)
	Util.Padding(pop, 12, 12, 12, 12)
	Util.List(pop, Enum.FillDirection.Vertical, 8)

	if opts.Position then
		pop.Position = opts.Position
	else
		pop.AnchorPoint = Vector2.new(0.5, 0.5)
		pop.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	local head = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
	}, pop)
	Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Text = "Keybind",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		Font = Theme.FontMed,
		TextColor3 = Theme.Text,
	}, head)
	local closeBtn = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, head)
	local closeIco = Icons.Make(closeBtn, "x", 14, Theme.TextMute)
	closeIco.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIco.Position = UDim2.new(0.5, 0, 0.5, 0)

	local keyBtn = Util.New("TextButton", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Input,
		Text = "",
		AutoButtonColor = false,
	}, pop)
	Util.Corner(keyBtn, 10)
	local keyLbl = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 6),
		Size = UDim2.new(1, 0, 0, 24),
		Text = currentKey,
		TextSize = 16,
		Font = Theme.FontBold,
		TextColor3 = Theme.Text,
	}, keyBtn)
	local hintLbl = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Click to change bind",
		TextSize = 11,
		Font = Theme.FontReg,
		TextColor3 = Theme.TextMute,
	}, keyBtn)

	local listening = false
	keyBtn.MouseButton1Click:Connect(function()
		if listening then
			return
		end
		listening = true
		keyLbl.Text = "..."
		keyLbl.TextColor3 = Theme.Accent
		hintLbl.Text = "Press any key or ESC"
	end)

	game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
		if not listening then
			return
		end
		local t = tostring(input.UserInputType)
		if t == "Enum.UserInputType.MouseButton1"
			or t == "Enum.UserInputType.MouseButton2"
			or t == "Enum.UserInputType.MouseButton3" then
			return
		end
		local name
		if t == "Enum.UserInputType.Keyboard" then
			name = tostring(input.KeyCode):gsub("Enum%.KeyCode%.", "")
			if name == "Unknown" or name == "" then
				return
			end
			if name == "Escape" then
				listening = false
				keyLbl.Text = currentKey
				keyLbl.TextColor3 = Theme.Text
				hintLbl.Text = "Click to change bind"
				return
			end
		else
			local mb = string.match(t, "MouseButton(%d+)")
			if mb then
				name = "Mouse" .. mb
			else
				return
			end
		end
		currentKey = name
		keyLbl.Text = currentKey
		keyLbl.TextColor3 = Theme.Text
		hintLbl.Text = "Click to change bind"
		listening = false
		pcall(done, { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow })
	end)

	local modeRow = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	}, pop)

	local tBtn = Util.New("TextButton", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = currentMode == "Toggle" and Theme.Accent or Theme.Input,
		Text = "Toggle",
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = currentMode == "Toggle" and Color3.fromRGB(20, 20, 30) or Theme.TextDim,
		AutoButtonColor = false,
	}, modeRow)
	Util.Corner(tBtn, 8)

	local hBtn = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = currentMode == "Hold" and Theme.Accent or Theme.Input,
		Text = "Hold",
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = currentMode == "Hold" and Color3.fromRGB(20, 20, 30) or Theme.TextDim,
		AutoButtonColor = false,
	}, modeRow)
	Util.Corner(hBtn, 8)

	local function refreshMode()
		tBtn.BackgroundColor3 = currentMode == "Toggle" and Theme.Accent or Theme.Input
		hBtn.BackgroundColor3 = currentMode == "Hold" and Theme.Accent or Theme.Input
		tBtn.TextColor3 = currentMode == "Toggle" and Color3.fromRGB(20, 20, 30) or Theme.TextDim
		hBtn.TextColor3 = currentMode == "Hold" and Color3.fromRGB(20, 20, 30) or Theme.TextDim
	end

	tBtn.MouseButton1Click:Connect(function() currentMode = "Toggle" refreshMode() pcall(done, { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow }) end)
	hBtn.MouseButton1Click:Connect(function() currentMode = "Hold" refreshMode() pcall(done, { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow }) end)

	local function checkRow(label, val, onFlip)
		local r = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
		}, pop)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Text = label,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontMed,
			TextColor3 = Theme.Text,
		}, r)
		local b = Util.New("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = val and Theme.Accent or Theme.CheckOff,
			Text = "",
			AutoButtonColor = false,
		}, r)
		Util.Corner(b, 5)
		local ck = Icons.Make(b, "check", 13, Color3.fromRGB(18, 18, 28))
		ck.AnchorPoint = Vector2.new(0.5, 0.5)
		ck.Position = UDim2.new(0.5, 0, 0.5, 0)
		ck.ImageTransparency = val and 0 or 1
		b.MouseButton1Click:Connect(function()
			val = not val
			b.BackgroundColor3 = val and Theme.Accent or Theme.CheckOff
			ck.ImageTransparency = val and 0 or 1
			onFlip(val)
		end)
		return r
	end

	checkRow("Value", currentVal, function(v) currentVal = v pcall(done, { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow }) end)
	checkRow("Show in binds", currentShow, function(v) currentShow = v pcall(done, { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow }) end)

	local api = {
		Frame = pop,
		Get = function() return { Key = currentKey, Mode = currentMode, Value = currentVal, Show = currentShow } end,
	}
	function api.Close()
		if pop and pop.Parent then
			pop:Destroy()
		end
	end
	closeBtn.MouseButton1Click:Connect(function()
		api.Close()
	end)

	return api
end

function Keybind.HotkeyTable(layer, rows)
	local pop = Util.New("Frame", {
		Name = "HotkeysTable",
		BackgroundColor3 = Color3.fromRGB(22, 22, 30),
		Size = UDim2.new(0, 480, 0, 32 + #rows * 38 + 8),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 120),
		ZIndex = 70,
	}, layer)
	Util.Corner(pop, 12)
	Util.Stroke(pop, Theme.Stroke, 1)
	Util.Padding(pop, 12, 14, 12, 14)

	local head = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
	}, pop)
	local function hcell(x, w, t)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, x, 0, 0),
			Size = UDim2.new(0, w, 1, 0),
			Text = t,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontMed,
			TextColor3 = Theme.Text,
		}, head)
	end
	hcell(0, 160, "Function")
	hcell(170, 120, "Hotkey")
	hcell(300, 100, "Status")

	for i, r in ipairs(rows) do
		local row = Util.New("Frame", {
			BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(26, 26, 36) or Color3.fromRGB(22, 22, 30),
			Size = UDim2.new(1, 0, 0, 36),
			BorderSizePixel = 0,
		}, pop)
		Util.Corner(row, 6)
		row.LayoutOrder = i
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0, 0),
			Size = UDim2.new(0, 160, 1, 0),
			Text = r[1],
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.Text,
		}, row)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 170, 0, 0),
			Size = UDim2.new(0, 120, 1, 0),
			Text = r[2],
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.Text,
		}, row)
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 300, 0, 0),
			Size = UDim2.new(0, 100, 1, 0),
			Text = r[3],
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.Text,
		}, row)
		local dots = Icons.Make(row, "more-horizontal", 16, Theme.Text)
		dots.AnchorPoint = Vector2.new(1, 0.5)
		dots.Position = UDim2.new(1, -8, 0.5, 0)
	end

	Util.List(pop, Enum.FillDirection.Vertical, 2)
	return { Frame = pop, Close = function() pop:Destroy() end }
end

return Keybind
