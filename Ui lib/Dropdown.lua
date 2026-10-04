local Theme = require(script.Parent:WaitForChild("Theme"))
local Util = require(script.Parent:WaitForChild("Util"))
local Icons = require(script.Parent:WaitForChild("Icons"))

local Dropdown = {}

function Dropdown.Create(parent, opts, ctx)
	opts = opts or {}
	local name = opts.Name or opts.Title
	local options = opts.Options or opts.Items or {"Normal"}
	local default = opts.Default or options[1]
	local cb = opts.Callback or function() end
	local current = default

	local holder = Util.New("Frame", {
		Name = "Dropdown",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, name and 62 or 38),
		LayoutOrder = opts.Order or 0,
	}, parent)

	if name then
		Util.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 0, 20),
			Text = name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 13,
			Font = Theme.FontReg,
			TextColor3 = Theme.TextMute,
		}, holder)
	end

	local btn = Util.New("TextButton", {
		Position = UDim2.new(0, 14, 0, name and 22 or 0),
		Size = UDim2.new(1, -28, 0, 36),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	}, holder)
	Util.Corner(btn, 8)

	local txt = Util.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -36, 1, 0),
		Text = tostring(current),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		Font = Theme.FontMed,
		TextColor3 = Theme.TextDim,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, btn)

	local chev = Icons.Make(btn, "chevron-down", 16, Theme.TextMute)
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -10, 0.5, 0)

	local listFrame
	local open = false

	local function close()
		open = false
		chev.Image = Icons.Get("chevron-down")
		if listFrame then
			if ctx and ctx.UntrackPopup then
				ctx.UntrackPopup(listFrame)
			end
			listFrame:Destroy() listFrame = nil
		end
	end

	local function buildList()
		if listFrame then listFrame:Destroy() end
		local gui = btn:FindFirstAncestorOfClass("ScreenGui")
		local layer = gui and gui:FindFirstChild("EvenPopups") or parent
		listFrame = Util.New("Frame", {
			Name = "DDList",
			BackgroundColor3 = Color3.fromRGB(24, 24, 33),
			BorderSizePixel = 0,
			Size = UDim2.new(0, math.max(180, btn.AbsoluteSize.X), 0, math.min(#options, 5) * 36 + 8),
			ZIndex = 50,
		}, layer)
		Util.Corner(listFrame, 8)
		Util.Stroke(listFrame, Theme.Stroke, 1)
		Util.Padding(listFrame, 4, 4, 4, 4)
		Util.List(listFrame, Enum.FillDirection.Vertical, 2)

		local abs = btn.AbsolutePosition
		local guiAbs = gui and gui.AbsolutePosition or Vector2.new(0, 0)
		if gui then
			listFrame.Position = UDim2.new(0, abs.X - guiAbs.X, 0, abs.Y - guiAbs.Y + 40)
		else
			listFrame.Position = UDim2.new(0, 0, 0, 40)
		end

		for _, opt in ipairs(options) do
			local isSel = tostring(opt) == tostring(current)
			local r = Util.New("TextButton", {
				BackgroundColor3 = isSel and Color3.fromRGB(32, 32, 44) or Color3.fromRGB(24, 24, 33),
				Size = UDim2.new(1, 0, 0, 34),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 51,
			}, listFrame)
			Util.Corner(r, 6)
			if isSel then
				local ck = Icons.Make(r, "check", 14, Theme.Text)
				ck.Position = UDim2.new(0, 10, 0.5, 0)
				ck.AnchorPoint = Vector2.new(0, 0.5)
				ck.ZIndex = 52
			end
			Util.New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, isSel and 32 or 12, 0, 0),
				Size = UDim2.new(1, -40, 1, 0),
				Text = tostring(opt),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 13,
				Font = Theme.FontMed,
				TextColor3 = isSel and Theme.Text or Theme.TextDim,
				ZIndex = 52,
			}, r)
			r.MouseButton1Click:Connect(function()
				current = opt
				txt.Text = tostring(opt)
				close()
				pcall(cb, opt)
			end)
		end
		if ctx and ctx.TrackPopup then
			ctx.TrackPopup(listFrame, close, btn)
		end
	end

	btn.MouseButton1Click:Connect(function()
		open = not open
		if open then
			chev.Image = Icons.Get("chevron-up")
			buildList()
		else
			close()
		end
	end)

	game:GetService("UserInputService").InputBegan:Connect(function(input)
		if open and input.UserInputType == Enum.UserInputType.MouseButton1 and listFrame and listFrame.Parent then
			local p = input.Position
			local aPos = listFrame.AbsolutePosition
			local aSize = listFrame.AbsoluteSize
			local bPos = btn.AbsolutePosition
			local bSize = btn.AbsoluteSize
			local inList = p.X >= aPos.X and p.X <= aPos.X + aSize.X and p.Y >= aPos.Y and p.Y <= aPos.Y + aSize.Y
			local inBtn = p.X >= bPos.X and p.X <= bPos.X + bSize.X and p.Y >= bPos.Y and p.Y <= bPos.Y + bSize.Y
			if not inList and not inBtn then close() end
		end
	end)

	local api = { Instance = holder }
	function api.Set(v) current = v txt.Text = tostring(v) end
	function api.Get() return current end
	function api.SetOptions(o) options = o end
	return api
end

return Dropdown
