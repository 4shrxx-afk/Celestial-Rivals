local BASE = "https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/Ui%20lib/"
local FILES = {
	Theme = "Theme.lua",
	Icons = "Icons.lua",
	Util = "Util.lua",
	Toggle = "Toggle.lua",
	Button = "Button.lua",
	Slider = "Slider.lua",
	Dropdown = "Dropdown.lua",
	Input = "Input.lua",
	Colorpicker = "ColorPicker.lua",
	Keybind = "Keybind.lua",
	Window = "Window.lua",
	Main = "Main.lua",
}

local cache = {}

local function keyOf(name)
	for k in pairs(FILES) do
		if string.lower(k) == string.lower(tostring(name)) then
			return k
		end
	end
	return name
end

local function need(name)
	name = keyOf(name)
	if cache[name] ~= nil then
		return cache[name]
	end
	local file = FILES[name]
	if not file then
		error("unknown module " .. tostring(name), 2)
	end
	local src = game:HttpGet(BASE .. file)
	src = string.gsub(src, "require%s*%(%s*script%s*%.%s*Parent%s*:%s*WaitForChild%s*%(%s*[\"']([^\"']+)[\"']%s*%)%s*%)", '__NEED("%1")')
	src = string.gsub(src, "require%s*%(%s*script%s*:%s*WaitForChild%s*%(%s*[\"']([^\"']+)[\"']%s*%)%s*%)", '__NEED("%1")')
	local wrapped = "local __NEED = ...; " .. src
	local fn, err = loadstring(wrapped, name)
	if not fn then
		error(name .. " compile: " .. tostring(err), 2)
	end
	cache[name] = true
	local res = fn(need)
	cache[name] = res
	return res
end

return need("Main")
