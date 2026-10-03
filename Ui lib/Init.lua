--[[
    Celestial Rivals UI — Init.lua
    ENTRY POINT. Require/load this file, everything else loads automatically.

    Studio setup (recommended for editing):
      UiLib (ModuleScript, paste this file)
      ├─ Theme (ModuleScript)
      ├─ Utils (ModuleScript)
      ├─ Icons (ModuleScript, real Lucide assets)
      ├─ Config (ModuleScript)
      ├─ Settings (ModuleScript)
      ├─ ColorPicker (ModuleScript)
      ├─ Window (ModuleScript)
      ├─ Tab (ModuleScript)
      ├─ Toggle (ModuleScript)
      ├─ Slider (ModuleScript)
      └─ Dropdown (ModuleScript)
      local UI = require(path.To.UiLib)

    Executor / single-file setup:
      local UI = loadstring(readfile("Celestial Scripts/Celestial Rivals/Ui lib/Init.lua"))()
      Init auto-loads siblings via readfile+loadstring. If that fails it errors
      with the exact missing file, or you can use CelestialUI.lua (legacy single-file).

    EDIT ME: add new controls in the Controls table below.
]]

local Library = {}
Library.Flags = {}
Library._Accent = Color3.fromRGB(148, 150, 255)
Library._ThemeName = "Dark"
Library._Scale = 1
Library._Windows = {}

-- Safe `script` access (loadstring has no `script` global)
local function getScript()
    local ok, s = pcall(function() return script end)
    if ok and typeof(s) == "Instance" then return s end
    return nil
end

local function tryRequireChild(scriptObj, name)
    if not scriptObj then return false end
    local child = scriptObj:FindFirstChild(name)
    if child then
        local ok, res = pcall(require, child)
        if ok then return true, res end
    end
    return false
end

local function tryLoadSiblingFile(name)
    -- Executor fallback: read sibling .lua next to Init.lua
    if typeof(readfile) ~= "function" or typeof(loadstring) ~= "function" then
        return false
    end
    local candidates = {
        "Celestial Scripts/Celestial Rivals/Ui lib/" .. name .. ".lua",
        "Celestial Rivals/Ui lib/" .. name .. ".lua",
        "Ui lib/" .. name .. ".lua",
        name .. ".lua",
    }
    -- also try relative to current workspace gravity: list common roots
    if typeof(listfiles) == "function" then
        pcall(function()
            for _, f in ipairs(listfiles("Celestial Scripts/Celestial Rivals/Ui lib")) do
                if f:lower():find(name:lower() .. "%.lua$") then
                    table.insert(candidates, 1, f)
                end
            end
        end)
    end
    for _, path in ipairs(candidates) do
        local ok, src = pcall(readfile, path)
        if ok and src and #src > 0 then
            local fn, err = loadstring(src, "@" .. name)
            if fn then
                local ok2, res = pcall(fn)
                if ok2 then return true, res end
            end
        end
    end
    return false
end

local function need(name)
    local s = getScript()
    local ok, res = tryRequireChild(s, name)
    if ok then return res end
    local ok2, res2 = tryLoadSiblingFile(name)
    if ok2 then return res2 end
    error("[CelestialUI.Init] missing module '" .. name
        .. "'. Studio: add it as a child ModuleScript. Executor: keep "
        .. name .. ".lua next to Init.lua (or use CelestialUI.lua single-file).")
end

-- Load order matters: leaves first, Window last (it needs builders injected)
local ThemeData = need("Theme")
local Utils = need("Utils")
local Icons = need("Icons")
local ConfigMod = need("Config")
local BuildSettings = need("Settings")
local BuildColorPicker = need("ColorPicker")
local CreateTab = need("Tab")
local CreateToggle = need("Toggle")
local SliderModule = need("Slider")
local CreateDropdown = need("Dropdown")
local CreateWindowFactory = need("Window")

Library._ThemeData = ThemeData
Library.Utils = Utils
Library.Icons = Icons

local Controls = {
    Toggle = CreateToggle,
    SliderModule = SliderModule,
    Dropdown = CreateDropdown,
}

local CreateWindow = CreateWindowFactory(Library, {
    ThemeData = ThemeData,
    Utils = Utils,
    Icons = Icons,
    Config = ConfigMod,
    BuildSettings = BuildSettings,
    BuildColorPicker = BuildColorPicker,
    CreateTab = CreateTab,
    Controls = Controls,
})

function Library:CreateWindow(opts)
    return CreateWindow(opts)
end

function Library:SaveConfig(name)
    return ConfigMod.Save(self.Flags, name)
end

function Library:LoadConfig(name)
    return ConfigMod.Load(self.Flags, name)
end

function Library:SetAccent(c)
    self._Accent = c
    for _, w in ipairs(self._Windows) do
        if w.SetAccent then w:SetAccent(c) end
    end
end

function Library:UnloadAll()
    for _, w in ipairs(self._Windows) do
        pcall(function() w:Unload() end)
    end
    table.clear(self._Windows)
end

return Library
