local Window = require(script:WaitForChild("Window"))
local Theme = require(script:WaitForChild("Theme"))
local Icons = require(script:WaitForChild("Icons"))
local Util = require(script:WaitForChild("Util"))

local Lib = {
	Theme = Theme,
	Icons = Icons,
	Util = Util,
}

function Lib.CreateWindow(opts)
	return Window.Create(opts or {})
end

function Lib.GetTheme()
	return Theme
end

return Lib
