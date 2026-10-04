return function(Win, ctx)
	local Tab = Win.AddTab({ Name = "Customize", Icon = "sliders-horizontal" })
	local S = Tab.AddSection({ Title = "Menu", Side = "Left" })
	S.AddColorpicker({ Name = "Menu accent", Callback = function(c)
		Win.SetAccent(c)
	end })
end
