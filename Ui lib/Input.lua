local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))

local Input = {}

function Input.Textbox(parent, opts)
	opts = opts or {}
	local ph = opts.Placeholder or ""
	local default = opts.Default or ""
	local cb = opts.Callback or function() end

	local box = Util.New("Frame", {
		BackgroundColor3 = Theme.Input,
		Size = UDim2.new(1, 0, 0, opts.Height or 36),
		BorderSizePixel = 0,
		LayoutOrder = opts.Order or 0,
	}, parent)
	Util.Corner(box, 8)
	if opts.Selected then
		Util.Stroke(box, Theme.Accent, 1)
	end

	local hasIcon = opts.Icon ~= nil and opts.Icon ~= false
	local iconName = type(opts.Icon) == "string" and opts.Icon or "plus-circle"
	if hasIcon then
		local ico = Icons.Make(box, iconName, 16, Theme.TextDim)
		ico.Position = UDim2.new(0, 10, 0.5, 0)
		ico.AnchorPoint = Vector2.new(0, 0.5)
	end

	local tb = Util.New("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, hasIcon and 32 or 12, 0, 0),
		Size = UDim2.new(1, hasIcon and -44 or -24, 1, 0),
		Text = default,
		PlaceholderText = ph,
		PlaceholderColor3 = Theme.TextMute,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.Text,
		ClearTextOnFocus = false,
	}, box)

	tb.FocusLost:Connect(function(enter)
		pcall(cb, tb.Text, enter)
	end)

	return { Instance = box, Box = tb, Get = function() return tb.Text end, Set = function(_, v) tb.Text = v end }
end

function Input.Coords(parent, opts, ctx)
	opts = opts or {}
	local holder = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = opts.Order or 0,
	}, parent)

	Util.New("UIGridLayout", {
		CellPadding = UDim2.new(0, 8, 0, 0),
		CellSize = UDim2.new(0.3333, -10, 0, 34),
		FillDirectionMaxCells = 3,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, holder)
	Util.Padding(holder, 0, 14, 0, 14)

	for i = 1, 3 do
		local f = Util.New("TextBox", {
			BackgroundColor3 = Theme.Input,
			BorderSizePixel = 0,
			Text = "0.00",
			PlaceholderText = "0.00",
			PlaceholderColor3 = Theme.TextMute,
			TextSize = 13,
			Font = Theme.FontMed,
			TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = i,
		}, holder)
		Util.Corner(f, 8)
	end

	return { Instance = holder }
end

function Input.Search(parent, opts)
	opts = opts or {}
	local cb = opts.Callback or function() end
	local box = Util.New("Frame", {
		BackgroundColor3 = Theme.Input,
		Size = UDim2.new(1, 0, 0, 38),
		BorderSizePixel = 0,
	}, parent)
	Util.Corner(box, 8)
	local ico = Icons.Make(box, "search", 16, Theme.TextMute)
	ico.Position = UDim2.new(0, 10, 0.5, 0)
	ico.AnchorPoint = Vector2.new(0, 0.5)
	local tb = Util.New("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 34, 0, 0),
		Size = UDim2.new(1, -44, 1, 0),
		Text = "",
		PlaceholderText = opts.Placeholder or "Search",
		PlaceholderColor3 = Theme.TextMute,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		Font = Theme.FontReg,
		TextColor3 = Theme.Text,
		ClearTextOnFocus = false,
	}, box)
	tb:GetPropertyChangedSignal("Text"):Connect(function()
		pcall(cb, tb.Text)
	end)
	return { Instance = box, Box = tb }
end

return Input
