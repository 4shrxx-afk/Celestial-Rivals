local BASE = "https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/"
local Lib = loadstring(game:HttpGet(BASE .. "Evenesce.lua"))()
local Players = game:GetService("Players")
local ctx = {
	Lib = Lib,
	BASE = BASE,
	player = Players.LocalPlayer,
	config = {
		spoofer = { enabled = false, userId = "" },
	},
}
local function tabModule(name)
	local src = game:HttpGet(BASE .. "Modules/" .. name .. ".lua")
	local fn = assert(loadstring("local ctx = ...; " .. src, name))
	return fn(ctx)
end
local Win = Lib.CreateWindow({ Title = "Celestial Rivals", Till = "v1.0" })
ctx.Win = Win
local tabs = { "Home", "Spoofer", "Skinchanger", "Customize" }
for _, name in ipairs(tabs) do
	tabModule(name)(Win, ctx)
end
return Win
