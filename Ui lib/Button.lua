local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))

local Button = {}

function Button.Create(parent, opts)
	opts = opts or {}
	local name = opts.Name or "Button"
	local accent = opts.Accent or false
	local cb = opts.Callback or function() end

	local bg = accent and Theme.Accent or Theme.Input
	local tc = accent and Color3.fromRGB(255,255,255) or Theme.TextDim

	local b = Util.New("TextButton", {
		Name = "Btn_" .. name,
		BackgroundColor3 = bg,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = name,
		TextSize = 14,
		Font = Theme.FontMed,
		TextColor3 = tc,
		Size = UDim2.new(1, 0, 0, opts.Height or 38),
		LayoutOrder = opts.Order or 0,
	}, parent)
	Util.Corner(b, Theme.RadiusBtn)

	Util.Hover(b, bg, accent and Theme.AccentHover or Theme.InputHover)

	b.MouseButton1Click:Connect(function()
		Util.Tween(b, 0.08, { Size = UDim2.new(1, 0, 0, (opts.Height or 38) - 2) })
		task.delay(0.08, function()
			Util.Tween(b, 0.08, { Size = UDim2.new(1, 0, 0, opts.Height or 38) })
		end)
		pcall(cb)
	end)

	local api = { Instance = b }
	function api.SetText(t) b.Text = t end
	if accent then
		api._SetAccent = function(a)
			b.BackgroundColor3 = a
		end
	end
	return api
end

return Button
