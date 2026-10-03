local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = {}

function Util.New(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			local ok = pcall(function()
				o[k] = v
			end)
			if not ok then
				if k == "Corner" then
					local c = Instance.new("UICorner")
					c.CornerRadius = UDim.new(0, v)
					c.Parent = o
				end
			end
		end
	end
	if parent then
		o.Parent = parent
	end
	if props.Parent then
		o.Parent = props.Parent
	end
	return o
end

function Util.Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
	return c
end

function Util.Stroke(p, color, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(34, 34, 46)
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

function Util.Padding(p, t, l, b, r)
	local u = Instance.new("UIPadding")
	u.PaddingTop = UDim.new(0, t or 0)
	u.PaddingLeft = UDim.new(0, l or 0)
	u.PaddingBottom = UDim.new(0, b or 0)
	u.PaddingRight = UDim.new(0, r or 0)
	u.Parent = p
	return u
end

function Util.List(p, dir, pad, hAlign, vAlign)
	local l = Instance.new("UIListLayout")
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.Padding = UDim.new(0, pad or 0)
	l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = p
	return l
end

function Util.Tween(o, t, props, style)
	style = style or Enum.EasingStyle.Quad
	TweenService:Create(o, TweenInfo.new(t or 0.15, style, Enum.EasingDirection.Out), props):Play()
end

function Util.Drag(frame, handle)
	handle = handle or frame
	local dragging = false
	local startPos, startInput
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startPos = frame.Position
			startInput = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - startInput
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

function Util.Hover(btn, normal, hover)
	btn.MouseEnter:Connect(function()
		Util.Tween(btn, 0.12, { BackgroundColor3 = hover })
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, 0.12, { BackgroundColor3 = normal })
	end)
end

function Util.TextSize(text, size, font, width)
	local l = Instance.new("TextLabel")
	l.Text = text
	l.TextSize = size
	l.Font = font
	local b = l:GetTextBounds()
	l:Destroy()
	return b
end

return Util
