local Players = game:GetService("Players")
return function(Win, ctx)
	local player = ctx.player
	local cfg = ctx.config.spoofer
	local function targetId()
		local n = tonumber(cfg.userId)
		if n and n > 0 then
			return math.floor(n)
		end
		return nil
	end
	local function applyTo(char)
		local id = targetId()
		if not id then
			return false
		end
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then
			return false
		end
		local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		if not ok or not desc then
			return false
		end
		local applied = pcall(hum.ApplyDescription, hum, desc)
		return applied
	end
	local function applyNow()
		local char = player.Character
		if char then
			applyTo(char)
		end
	end
	player.CharacterAdded:Connect(function(char)
		if cfg.enabled then
			char:WaitForChild("Humanoid", 10)
			task.wait(0.5)
			applyTo(char)
		end
	end)
	local Tab = Win.AddTab({ Name = "Spoofer", Icon = "ghost" })
	local S = Tab.AddSection({ Title = "Avatar", Side = "Left" })
	local status = S.AddLabel("Status: Off")
	S.AddToggle({ Name = "Avatar spoofer", Default = false, Callback = function(v)
		cfg.enabled = v
		if v then
			applyNow()
			status.Text = "Status: On (" .. (cfg.userId ~= "" and cfg.userId or "no id") .. ")"
		else
			status.Text = "Status: Off"
		end
	end })
	S.AddInput({ Placeholder = "Target UserId", Callback = function(text)
		cfg.userId = string.gsub(text, "%s+", "")
	end })
	S.AddButton({ Name = "Apply", Callback = function()
		applyNow()
		local id = targetId()
		if id then
			status.Text = "Status: Applied (" .. id .. ")"
		else
			status.Text = "Status: Invalid UserId"
		end
	end })
end
