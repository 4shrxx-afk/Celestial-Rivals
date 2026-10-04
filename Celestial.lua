if _G.__CelestialCleanup then
	pcall(_G.__CelestialCleanup)
end
_G.__CelestialGen = (_G.__CelestialGen or 0) + 1
_G.__CelestialConns = {}
local BASE = "https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/"
local session = rawget(_G, "__CelestialSession")
if type(session) ~= "table" or type(session.src) ~= "table" then
	session = { src = {} }
	_G.__CelestialSession = session
end
if _G.CELESTIAL_NOCACHE then
	session.src = {}
end
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
local names = { "Home", "Spoofer", "Skinchanger", "Customize" }
local pending = 0
for _, name in ipairs(names) do
	if not session.src[name] then
		pending = pending + 1
		task.spawn(function()
			local ok, src = pcall(function()
				return game:HttpGet(BASE .. "Modules/" .. name .. ".lua")
			end)
			if ok and type(src) == "string" and #src > 0 then
				session.src[name] = src
			end
			pending = pending - 1
		end)
	end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 15 do
	task.wait()
end
local Win = Lib.CreateWindow({ Title = "Celestial Rivals", Till = "v1.0" })
ctx.Win = Win
for _, name in ipairs(names) do
	local src = session.src[name]
	if not src then
		src = game:HttpGet(BASE .. "Modules/" .. name .. ".lua")
	end
	local fn = assert(loadstring("local ctx = ...; " .. src, name))
	fn(ctx)(Win, ctx)
end
_G.__CelestialCleanup = function()
	for _, c in ipairs(_G.__CelestialConns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	_G.__CelestialConns = {}
	if Win and Win.Gui then
		pcall(function()
			Win.Gui:Destroy()
		end)
	end
end
return Win
