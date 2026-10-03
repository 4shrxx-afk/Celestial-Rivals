local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))

local Toggle = {}

function Toggle.Create(parent, opts, ctx)
	opts = opts or {}
	local name = opts.Name or "Toggle"
	local default = opts.Default or false
	local desc = opts.Desc or opts.Description
	local warn = opts.Warn or opts.Warning
	local cb = opts.Callback or function() end

	local state = default

	local row = Util.New("TextButton", {
		Name = "Toggle_" .. name,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Size = UDim2.new(1, 0, 0, desc and 62 or 48),
		LayoutOrder = opts.Order or 0,
	}, parent)

	local box = Util.New("Frame", {
		Name = "Box",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = state and Theme.Accent or Theme.CheckOff,
		BorderSizePixel = 0,
	}, row)
	Util.Corner(box, 6)

	local check = Icons.Make(box, "check", 14, state and Theme.TextDark or Color3.fromRGB(90, 90, 110))
	check.AnchorPoint = Vector2.new(0.5, 0.5)
	check.Position = UDim2.new(0.5, 0, 0.5, 0)
	check.ImageTransparency = state and 0 or 0.4

	local xOff = 44
	if warn then
		local wIco = Icons.Make(row, "alert-triangle", 15, Theme.Warn)
		wIco.Position = UDim2.new(0, xOff, 0, desc and 12 or 0)
		wIco.Size = UDim2.new(0, 15, 0, desc and 20 or 48)
		xOff = xOff + 20
	end

	local title = Util.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, xOff, 0, desc and 8 or 0),
		Size = UDim2.new(1, -110, 0, 22),
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextSize = 14,
		Font = Theme.FontMed,
		TextColor3 = state and Theme.Text or Theme.TextDim,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)

	if desc then
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, xOff, 0, 30),
			Size = UDim2.new(1, -110, 0, 24),
			Text = desc,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			Font = Theme.FontReg,
			TextColor3 = Theme.TextMute,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
	end

	local chev = Icons.Make(row, "chevron-right", 18, Theme.TextMute)
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -12, 0.5, 0)

	local function refresh(animate)
		if state then
			if animate then
				Util.Tween(box, 0.15, { BackgroundColor3 = Theme.Accent })
			else
				box.BackgroundColor3 = Theme.Accent
			end
			check.ImageTransparency = 0
			check.ImageColor3 = Color3.fromRGB(18, 18, 28)
			title.TextColor3 = Theme.Text
		else
			if animate then
				Util.Tween(box, 0.15, { BackgroundColor3 = Theme.CheckOff })
			else
				box.BackgroundColor3 = Theme.CheckOff
			end
			check.ImageTransparency = 0.4
			check.ImageColor3 = Color3.fromRGB(90, 90, 110)
			title.TextColor3 = Theme.TextDim
		end
	end

	local api = {}
	api.Row = row
	api.Value = state

	function api.Set(v, silent)
		state = not not v
		api.Value = state
		refresh(true)
		if not silent then
			pcall(cb, state)
		end
	end

	function api.Get()
		return state
	end

	function api.OnChanged(fn)
		cb = fn
	end

	row.MouseButton1Click:Connect(function()
		api.Set(not state)
	end)

	row.MouseEnter:Connect(function()
		chev.ImageColor3 = Theme.TextDim
	end)
	row.MouseLeave:Connect(function()
		chev.ImageColor3 = Theme.TextMute
	end)

	if ctx and ctx.OnToggleCreated then
		ctx.OnToggleCreated(api, opts)
	end

	refresh(false)

	api._Title = title
	api._Box = box
	api._SetAccent = function(accent)
		if state then
			box.BackgroundColor3 = accent
		end
	end
	if ctx and ctx.BindAccent then
		ctx.BindAccent(api._SetAccent)
	end

	return api
end

return Toggle
