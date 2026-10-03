--[[
    Celestial Rivals UI — Example.lua
    Recreates the reference screenshot: Aimbot/Triggerbot/... sidebar,
    ACCURACY section, Recoil control, sliders, toggles, color picker.
    Run after loading the lib:

      Studio:
        local UI = require(script.Parent.Init)
        (paste the demo below)
      Executor:
        local UI = loadstring(readfile("Celestial Scripts/Celestial Rivals/Ui lib/Init.lua"))()
]]

-- local UI = require(script.Parent.Init) -- Studio
-- local UI = loadstring(readfile("Celestial Scripts/Celestial Rivals/Ui lib/Init.lua"))() -- executor

local UI = nil
pcall(function() UI = require(script.Parent.Init) end)
if not UI and typeof(readfile) == "function" then
    local ok, src = pcall(readfile, "Celestial Scripts/Celestial Rivals/Ui lib/Init.lua")
    if ok then UI = loadstring(src, "@Init")() end
end
assert(UI, "Load Init.lua first")

local Win = UI:CreateWindow({
    Title = "CELESTIAL",
    AccentTitle = "RIVALS",
    User = "Past Owl",
    Theme = "Dark",
    Accent = Color3.fromRGB(148, 150, 255),
})

-- Sidebar tabs (match reference order)
local aim = Win:Tab({ Name = "Aimbot" })
local trigger = Win:Tab({ Name = "Triggerbot" })
local flick = Win:Tab({ Name = "Flickbot" })
local players = Win:Tab({ Name = "Players" })
local world = Win:Tab({ Name = "World" })
local plist = Win:Tab({ Name = "Player list" })
local configs = Win:Tab({ Name = "Configs" })
local misc = Win:Tab({ Name = "Miscellaneous" })

-- Aimbot page (right side in reference)
aim:Section("ACCURACY")
aim:Dropdown({
    Name = "Recoil control",
    Options = { "Off", "Legit", "Rage", "Custom curve" },
    Default = "Legit",
    Callback = function(v) print("recoil:", v) end,
})
aim:Slider({ Name = "FOV size", Min = 0, Max = 30, Default = 10, Decimals = 1, Suffix = "", Callback = function(v) end })
aim:Toggle({ Name = "First bullet accuracy", Default = true })
aim:Dropdown({ Name = "Hitbox override", Options = { "Head", "Chest", "Pelvis", "Pistols" }, Default = "Pistols" })
aim:Toggle({ Name = "Penetrate walls", Default = true })
aim:Slider({ Name = "Kill delay", Min = 0, Max = 1000, Default = 500, Callback = function(v) end })
aim:Range({ Name = "First bullet delay", Min = 0, Max = 1000, DefaultMin = 200, DefaultMax = 700 })

-- Middle column rows from reference
aim:Section("ASSIST")
aim:Toggle({ Name = "Multibone", Default = false })
aim:Toggle({ Name = "Ignore flash", Default = false, More = true })
aim:Toggle({ Name = "Ignore smoke", Default = true, More = true })
aim:Toggle({ Name = "Burst mode", Default = false, More = true })
aim:Toggle({ Name = "Crouch on shot", Default = true })
aim:Colorpicker({
    Name = "Accent color",
    Default = Color3.fromRGB(148, 150, 255),
    Callback = function(c) print("accent picked:", c) end,
})

trigger:Section("TRIGGER")
trigger:Toggle({ Name = "Enabled", Default = false })
trigger:Slider({ Name = "Reaction time", Min = 0, Max = 500, Default = 120 })

configs:Section("CONFIGS")
configs:Button({ Name = "Save config", Callback = function()
    UI:SaveConfig("celestial_rivals")
    Win:Notify("Config saved", "celestial_rivals.json")
end })
configs:Button({ Name = "Load config", Callback = function()
    UI:LoadConfig("celestial_rivals")
    Win:Notify("Config loaded", "restart toggles to apply")
end })

misc:Section("APP")
misc:Label("RightShift toggles the UI. The gear button opens App settings.")
misc:Button({ Name = "Unload UI", Callback = function() Win:Unload() end })

print("Flags:", UI.Flags)
return Win
