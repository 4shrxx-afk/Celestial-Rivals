local Players = game:GetService("Players")
local function sharedConns()
	local l = rawget(_G, "__CelestialConns")
	if type(l) ~= "table" then
		l = {}
		_G.__CelestialConns = l
	end
	return l
end
return function(Win, ctx)
	local player = ctx.player
	local cfg = ctx.config.spoofer
	cfg.enabled = false
	cfg.descOk = false
	cfg.targetName = nil
	local gen = _G.__CelestialGen or 0
	local conns = sharedConns()
	local Tab = Win.AddTab({ Name = "Spoofer", Icon = "ghost" })
	local S = Tab.AddSection({ Title = "Avatar", Side = "Left" })
	local status = S.AddLabel("Status: Off")
	local lastApply = 0
	local function targetId()
		local n = tonumber(cfg.userId)
		if n and n > 0 then
			return math.floor(n)
		end
		return nil
	end
	local function fetchDesc(id)
		local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		if ok and typeof(desc) == "Instance" then
			return desc
		end
		return nil
	end
	local function applyViewmodels(desc)
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		for _, m in ipairs(cam:GetChildren()) do
			if m:IsA("Model") then
				local h = m:FindFirstChildOfClass("Humanoid")
				if h then
					pcall(h.ApplyDescription, h, desc)
				else
					for _, p in ipairs(m:GetDescendants()) do
						if p:IsA("BasePart") then
							local n = p.Name
							if string.find(n, "Arm") or string.find(n, "Hand") then
								pcall(function()
									p.Color = desc.LeftArmColor
								end)
							end
						end
					end
				end
			end
		end
	end
	local function applyName()
		local id = targetId()
		if not id then
			return
		end
		local ok, nm = pcall(Players.GetNameFromUserIdAsync, Players, id)
		if ok and nm and nm ~= "" then
			cfg.targetName = nm
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum.DisplayName = nm
				end)
			end
		end
	end
	local function applyAll(silent)
		local id = targetId()
		if not id then
			cfg.descOk = false
			if not silent then
				status.Text = "Status: Invalid UserId"
			end
			return false
		end
		local desc = fetchDesc(id)
		if not desc then
			cfg.descOk = false
			if not silent then
				status.Text = "Status: Bad avatar"
			end
			return false
		end
		cfg.descOk = true
		lastApply = os.clock()
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(hum.ApplyDescription, hum, desc)
		end
		applyViewmodels(desc)
		applyName()
		if not silent then
			status.Text = "Status: On (" .. (cfg.targetName or id) .. ")"
		end
		return true
	end
	local function restoreSelf()
		cfg.descOk = false
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, player.UserId)
		if ok and desc and hum then
			pcall(hum.ApplyDescription, hum, desc)
		end
		if hum then
			pcall(function()
				hum.DisplayName = player.DisplayName
			end)
		end
	end
	local hookOn = false
	local function installHook()
		if hookOn then
			return true
		end
		local myGen = gen
		local ok = pcall(function()
			local mt = getrawmetatable(game)
			local old = mt.__namecall
			setreadonly(mt, false)
			mt.__namecall = newcclosure(function(self, ...)
				local m = getnamecallmethod()
				if myGen == _G.__CelestialGen and cfg.enabled and cfg.descOk then
					local a = { ... }
					if typeof(self) == "Instance" and self.ClassName == "Players" then
						local tid = targetId()
						if tid then
							if (m == "GetHumanoidDescriptionFromUserId" or m == "GetCharacterAppearanceAsync") and a[1] == player.UserId then
								return old(self, tid)
							end
							if m == "GetUserThumbnailAsync" and a[1] == player.UserId then
								return old(self, tid, a[2], a[3])
							end
							if m == "GetNameFromUserIdAsync" and a[1] == player.UserId then
								return old(self, tid)
							end
							if m == "GetUserIdFromNameAsync" and a[1] == player.Name and cfg.targetName then
								return old(self, cfg.targetName)
							end
						end
					end
				end
				return old(self, ...)
			end)
			setreadonly(mt, true)
		end)
		hookOn = ok
		return ok
	end
	local function scheduleReapply()
		if not cfg.enabled or gen ~= _G.__CelestialGen then
			return
		end
		if os.clock() - lastApply < 1 then
			return
		end
		task.delay(0.5, function()
			if cfg.enabled and gen == _G.__CelestialGen then
				applyAll(true)
			end
		end)
	end
	local watchConn = nil
	local function watchChar(char)
		if watchConn then
			pcall(function()
				watchConn:Disconnect()
			end)
		end
		watchConn = char.DescendantAdded:Connect(function(d)
			if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("Accessory") or d:IsA("BodyColors") then
				scheduleReapply()
			end
		end)
		table.insert(conns, watchConn)
	end
	table.insert(conns, player.CharacterAdded:Connect(function(char)
		if gen ~= _G.__CelestialGen then
			return
		end
		char:WaitForChild("Humanoid", 10)
		watchChar(char)
		if cfg.enabled then
			task.wait(0.5)
			if cfg.enabled and gen == _G.__CelestialGen then
				applyAll(true)
			end
		end
	end))
	if player.Character then
		watchChar(player.Character)
	end
	S.AddToggle({ Name = "Avatar spoofer", Default = false, Callback = function(v)
		cfg.enabled = v
		if v then
			installHook()
			applyAll(false)
		else
			restoreSelf()
			status.Text = "Status: Off"
		end
	end })
	S.AddInput({ Placeholder = "Target UserId", Callback = function(text)
		cfg.userId = string.gsub(text, "%s+", "")
	end })
	S.AddButton({ Name = "Apply", Callback = function()
		applyAll(false)
	end })
end
