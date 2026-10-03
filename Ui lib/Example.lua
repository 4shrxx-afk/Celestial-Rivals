local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/Evenesce.lua"))()

local Win = Lib.CreateWindow({
	Title = "Evenesce",
	User = "Past Owl",
	Till = "1 Jan 2025",
})

local General = Win.AddTab({ Name = "General", Icon = "crosshair" })
local Visuals = Win.AddTab({ Name = "Visuals", Icon = "eye" })
local Weapon = Win.AddTab({ Name = "Weapon", Icon = "sword" })
local Vehicle = Win.AddTab({ Name = "Vehicle", Icon = "car" })
local Server = Win.AddTab({ Name = "Server", Icon = "server" })
local Player = Win.AddTab({ Name = "Player", Icon = "user" })
local Misc = Win.AddTab({ Name = "Misc", Icon = "sliders-horizontal" })
local LuaSys = Win.AddTab({ Name = "Lua system", Icon = "code" })
local Exec = Win.AddTab({ Name = "Executor", Icon = "cpu" })

local P1 = General.AddSection({ Title = "Player options", Side = "Left" })
P1.AddToggle({ Name = "God mode", Default = true })
P1.AddToggle({ Name = "Solo session", Default = false })
P1.AddToggle({ Name = "Anti headshot", Default = false })
P1.AddToggle({ Name = "Heal behind cover", Default = true })
P1.AddToggle({ Name = "Invisibility", Default = false })
P1.AddToggle({ Name = "Server invisible", Default = true, Warn = true, Desc = "The feature may not be working properly, it is in beta testing." })
P1.AddToggle({ Name = "Infinite stamina", Default = true })
P1.AddToggle({ Name = "Infinite combat roll", Default = true })
P1.AddToggle({ Name = "No combat stance", Default = false })

local P2 = General.AddSection({ Title = "Movement options", Side = "Right" })
P2.AddToggle({ Name = "Enable freecam", Default = true })
P2.AddToggle({ Name = "Enable no-clip", Default = true })
P2.AddLabel("Coordinates")
P2.AddCoords({})
P2.AddButton({ Name = "Teleport to coordinates" })
P2.AddButton({ Name = "Set waypoint at coordinates" })
P2.AddToggle({ Name = "TP to waypoint", Default = true })
P2.AddDropdown({ Name = "Walking style", Options = { "Normal", "Sneak", "Drunk", "Injured" }, Default = "Normal" })

local G2 = General.AddSection({ Title = "General", Side = "Left" })
G2.AddToggle({ Name = "Suicide" , Default = true })
G2.AddToggle({ Name = "Self revive", Default = true })
G2.AddToggle({ Name = "Force crush", Default = true })

return Win
