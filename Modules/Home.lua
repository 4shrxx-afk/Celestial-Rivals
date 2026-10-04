local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local function copy(s)
	if setclipboard then
		pcall(setclipboard, s)
	end
end
local function ping()
	local ok, v = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and v then
		return math.floor(v + 0.5) .. " ms"
	end
	return "n/a"
end
local function executor()
	if identifyexecutor then
		local ok, name = pcall(identifyexecutor)
		if ok and name then
			return tostring(name)
		end
	end
	return "Unknown"
end
return function(Win, ctx)
	local player = ctx.player
	local Tab = Win.AddTab({ Name = "Home", Icon = "layout-grid" })
	local A = Tab.AddSection({ Title = "Account", Side = "Left" })
	A.AddLabel("Name: " .. player.DisplayName .. " (@" .. player.Name .. ")")
	A.AddLabel("UserId: " .. player.UserId)
	A.AddLabel("Account age: " .. player.AccountAge .. " days")
	A.AddLabel("Executor: " .. executor())
	A.AddButton({ Name = "Copy UserId", Callback = function()
		copy(tostring(player.UserId))
	end })
	local S = Tab.AddSection({ Title = "Session", Side = "Right" })
	S.AddLabel("Session: " .. string.sub(game.JobId, 1, 8))
	local playersLbl = S.AddLabel("Players: " .. #Players:GetPlayers())
	local pingLbl = S.AddLabel("Ping: " .. ping())
	S.AddLabel("Place: " .. game.PlaceId)
	S.AddButton({ Name = "Refresh", Callback = function()
		playersLbl.Text = "Players: " .. #Players:GetPlayers()
		pingLbl.Text = "Ping: " .. ping()
	end })
	S.AddButton({ Name = "Copy JobId", Callback = function()
		copy(game.JobId)
	end })
	S.AddButton({ Name = "Rejoin", Callback = function()
		TeleportService:Teleport(game.PlaceId)
	end })
end
