local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))
local UserInputService = game:GetService("UserInputService")

local Slider = {}

function Slider.Create(parent, opts, ctx)
	opts = opts or {}
	local name = opts.Name or "Slider"
	local min = opts.Min or 0
	local max = opts.Max or 100
	local default = opts.Default or ((min + max) / 2)
	local suffix = opts.Suffix or ""
	local cb = opts.Callback or function() end
	local val = math.clamp(default, min, max)

	local holder = Util.New("Frame", {
		Name = "Slider_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = opts.Order or 0,
	}, parent)

	local lbl = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 6),
		Size = UDim2.new(0.5, 0, 0, 18),
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontReg,
		TextColor3 = Theme.TextMute,
	}, holder)

	local vallbl = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 6),
		Size = UDim2.new(0.5, 0, 0, 18),
		Text = tostring(math.floor(val * 100) / 100) .. suffix,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.TextDim,
	}, holder)

	local track = Util.New("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 30),
		Size = UDim2.new(1, -28, 0, 6),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
	}, holder)
	Util.Corner(track, 3)

	local fill = Util.New("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	}, track)
	Util.Corner(fill, 3)

	local knob = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		Visible = false,
	}, track)
	Util.Corner(knob, 6)

	local function pct()
		return (val - min) / math.max(0.0001, (max - min))
	end

	local function refresh()
		local p = pct()
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, 0, 0.5, 0)
		vallbl.Text = tostring(math.floor(val * 100) / 100) .. suffix
	end

	local dragging = false
	local function setFromX(x)
		local absPos = track.AbsolutePosition.X
		local absSize = math.max(1, track.AbsoluteSize.X)
		local a = math.clamp((x - absPos) / absSize, 0, 1)
		val = min + (max - min) * a
		if opts.Step then
			val = math.floor(val / opts.Step + 0.5) * opts.Step
		end
		if opts.Decimals then
			local m = 10 ^ opts.Decimals
			val = math.floor(val * m + 0.5) / m
		end
		refresh()
		pcall(cb, val)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			knob.Visible = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			knob.Visible = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	holder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			knob.Visible = true
		end
	end)

	refresh()

	local api = { Instance = holder }
	function api.Set(v, silent)
		val = math.clamp(v, min, max)
		refresh()
		if not silent then pcall(cb, val) end
	end
	function api.Get() return val end
	api._SetAccent = function(a) fill.BackgroundColor3 = a end
	if ctx and ctx.BindAccent then ctx.BindAccent(api._SetAccent) end
	return api
end

return Slider
