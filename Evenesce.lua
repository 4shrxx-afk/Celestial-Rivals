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
local session = rawget(_G, "__EvenesceSession")
if type(session) ~= "table" or type(session.src) ~= "table" then
	session = { src = {} }
	_G.__EvenesceSession = session
end
if _G.CELESTIAL_NOCACHE then
	session.src = {}
end
local cache = {}
local function keyOf(name)
	for k in pairs(FILES) do
		if string.lower(k) == string.lower(tostring(name)) then
			return k
		end
	end
	return name
end
local function fetchSrc(name)
	local ok, src = pcall(function()
		return game:HttpGet(BASE .. FILES[name])
	end)
	if ok and type(src) == "string" and #src > 0 then
		session.src[name] = src
		return src
	end
	return nil
end
local pending = 0
for name in pairs(FILES) do
	if not session.src[name] then
		pending = pending + 1
		task.spawn(function()
			fetchSrc(name)
			pending = pending - 1
		end)
	end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 15 do
	task.wait()
end
local function need(name)
	name = keyOf(name)
	if cache[name] ~= nil then
		return cache[name]
	end
	local src = session.src[name]
	if not src then
		src = fetchSrc(name)
	end
	if not src then
		error("fetch failed: " .. tostring(name), 2)
	end
	src = string.gsub(src, "require%s*%(%s*script%s*%.%s*Parent%s*:%s*WaitForChild%s*%(%s*[\"']([^\"']+)[\"']%s*%)%s*%)", '__NEED("%1")')
	src = string.gsub(src, "require%s*%(%s*script%s*:%s*WaitForChild%s*%(%s*[\"']([^\"']+)[\"']%s*%)%s*%)", '__NEED("%1")')
	local fn, err = loadstring("local __NEED = ...; " .. src, name)
	if not fn then
		session.src[name] = nil
		error(name .. " compile: " .. tostring(err), 2)
	end
	cache[name] = true
	local ok, res = pcall(fn, need)
	if not ok then
		session.src[name] = nil
		error(res, 2)
	end
	cache[name] = res
	return res
end
return need("Main")
