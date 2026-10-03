local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))
local UserInputService = game:GetService("UserInputService")

local Colorpicker = {}

local function hsvToRgb(h, s, v)
	return Color3.fromHSV(h, s, v)
end

function Colorpicker.Inline(parent, opts, ctx)
	opts = opts or {}
	local default = opts.Default or Theme.Accent
	local cb = opts.Callback or function() end
	local h, s, v = default:ToHSV()
	local alpha = 1

	local holder = Util.New("Frame", {
		Name = "Colorpicker",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 250),
		LayoutOrder = opts.Order or 0,
	}, parent)

	local head = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
	}, holder)
	Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Text = opts.Name or "Menu accent",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.Text,
	}, head)
	local preview = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = default,
		BorderSizePixel = 0,
	}, head)
	Util.Corner(preview, 8)

	local sv = Util.New("Frame", {
		Position = UDim2.new(0, 14, 0, 30),
		Size = UDim2.new(1, -46, 0, 150),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, holder)
	Util.Corner(sv, 8)

	local satGrad = Util.New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 0,
	}, sv)
	local valGradHolder = Util.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	}, sv)
	local valGrad = Util.New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Rotation = 90,
	}, valGradHolder)
	valGradHolder.BackgroundTransparency = 0

	local svDot = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, sv)
	local dotInner = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
	}, svDot)
	Util.Stroke(dotInner, Color3.fromRGB(255,255,255), 2)
	Util.Corner(dotInner, 6)

	local hue = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 30),
		Size = UDim2.new(0, 12, 0, 150),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255,255,255),
	}, holder)
	Util.Corner(hue, 6)
	local hueGrad = Util.New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
		}),
		Rotation = 90,
	}, hue)
	local hueDot = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, hue)
	Util.Corner(hueDot, 7)

	local alphaBar = Util.New("Frame", {
		Position = UDim2.new(0, 14, 0, 188),
		Size = UDim2.new(1, -28, 0, 8),
		BackgroundColor3 = Color3.fromRGB(220,220,230),
		BorderSizePixel = 0,
	}, holder)
	Util.Corner(alphaBar, 4)
	local alphaFill = Util.New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, alphaBar)
	Util.Corner(alphaFill, 4)
	local alphaKnob = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
	}, alphaBar)
	Util.Corner(alphaKnob, 7)

	local hexBox = Util.New("Frame", {
		Position = UDim2.new(0, 14, 0, 204),
		Size = UDim2.new(1, -28, 0, 32),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
	}, holder)
	Util.Corner(hexBox, 8)
	local hexTb = Util.New("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Text = "FF9C00FF",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.Text,
		ClearTextOnFocus = false,
	}, hexBox)
	local copyIco = Icons.Make(hexBox, "copy", 14, Theme.TextMute)
	copyIco.AnchorPoint = Vector2.new(1, 0.5)
	copyIco.Position = UDim2.new(1, -10, 0.5, 0)

	local function refresh()
		local c = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svDot.Position = UDim2.new(s, 0, 1 - v, 0)
		hueDot.Position = UDim2.new(0.5, 0, h, 0)
		preview.BackgroundColor3 = c
		alphaFill.BackgroundColor3 = c
		local r = math.floor(c.R * 255 + 0.5)
		local g = math.floor(c.G * 255 + 0.5)
		local b = math.floor(c.B * 255 + 0.5)
		hexTb.Text = string.format("%02X%02X%02XFF", r, g, b)
		pcall(cb, c)
		if ctx and ctx.SetAccent then
			ctx.SetAccent(c)
		end
	end

	local dragSv, dragHue, dragAlpha = false, false, false
	sv.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSv = true end
	end)
	hue.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true end
	end)
	alphaBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragAlpha = true end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragSv, dragHue, dragAlpha = false, false, false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		if dragSv then
			local p = Vector2.new(math.clamp((i.Position.X - sv.AbsolutePosition.X) / math.max(1, sv.AbsoluteSize.X), 0, 1),
				math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / math.max(1, sv.AbsoluteSize.Y), 0, 1))
			s, v = p.X, 1 - p.Y
			refresh()
		elseif dragHue then
			h = math.clamp((i.Position.Y - hue.AbsolutePosition.Y) / math.max(1, hue.AbsoluteSize.Y), 0, 0.999)
			refresh()
		elseif dragAlpha then
			local a = math.clamp((i.Position.X - alphaBar.AbsolutePosition.X) / math.max(1, alphaBar.AbsoluteSize.X), 0, 1)
			alphaKnob.Position = UDim2.new(a, 0, 0.5, 0)
		end
	end)

	refresh()
	return { Instance = holder, Get = function() return Color3.fromHSV(h, s, v) end }
end

return Colorpicker
