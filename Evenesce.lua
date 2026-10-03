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
local placeholders = {}

local function keyOf(name)
	for k in pairs(FILES) do
		if string.lower(k) == string.lower(tostring(name)) then
			return k
		end
	end
	return name
end

local function placeholder(name)
	local key = keyOf(name)
	if not placeholders[key] then
		placeholders[key] = { Name = key, ClassName = "ModuleScript" }
	end
	return placeholders[key]
end

local folder = { Name = "Ui lib", ClassName = "Folder" }
function folder:WaitForChild(n)
	return placeholder(n)
end
function folder:FindFirstChild(n)
	return placeholder(n)
end

local function makeScript(name)
	local s = { Name = name, ClassName = "ModuleScript", Parent = folder }
	function s:WaitForChild(n)
		return placeholder(n)
	end
	function s:FindFirstChild(n)
		return placeholder(n)
	end
	return s
end

local function customRequire(inst)
	local name
	if type(inst) == "table" and inst.Name then
		name = keyOf(inst.Name)
	elseif type(inst) == "string" then
		name = keyOf(inst)
	else
		error("bad require", 2)
	end
	if cache[name] ~= nil then
		return cache[name]
	end
	local file = FILES[name]
	if not file then
		error("unknown module " .. tostring(name), 2)
	end
	local src = game:HttpGet(BASE .. file)
	local fn, err = loadstring(src, name)
	if not fn then
		error(name .. " compile: " .. tostring(err), 2)
	end
	cache[name] = true
	local fake = makeScript(name)
	local baseEnv = (getfenv and getfenv() or _G)
	local env = setmetatable({ script = fake, require = customRequire }, { __index = baseEnv })
	if setfenv then
		setfenv(fn, env)
	end
	local res = fn()
	cache[name] = res
	return res
end

return customRequire(placeholder("Main"))
