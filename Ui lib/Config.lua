--[[
    Celestial Rivals UI — Config.lua
    EDIT ME: change file naming / save format.
    Uses executor writefile/readfile/isfile when present, else returns JSON.
    Color3 values are serialized as hex strings.
]]

local HttpService = game:GetService("HttpService")

local Config = {}

local function encodeFlags(flags)
    local out = {}
    for k, v in pairs(flags or {}) do
        if typeof(v) == "Color3" then
            out[k] = { __type = "Color3", hex = string.format("#%02X%02X%02X",
                math.floor(v.R * 255 + 0.5),
                math.floor(v.G * 255 + 0.5),
                math.floor(v.B * 255 + 0.5)) }
        elseif typeof(v) == "table" and #v == 2
            and typeof(v[1]) == "number" and typeof(v[2]) == "number" then
            out[k] = { __type = "Range", a = v[1], b = v[2] }
        else
            out[k] = v
        end
    end
    return out
end

local function decodeFlags(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        if typeof(v) == "table" and v.__type == "Color3" and v.hex then
            local h = tostring(v.hex):gsub("#", "")
            local r = tonumber(h:sub(1, 2), 16) or 255
            local g = tonumber(h:sub(3, 4), 16) or 255
            local b = tonumber(h:sub(5, 6), 16) or 255
            out[k] = Color3.fromRGB(r, g, b)
        elseif typeof(v) == "table" and v.__type == "Range" then
            out[k] = { tonumber(v.a) or 0, tonumber(v.b) or 0 }
        else
            out[k] = v
        end
    end
    return out
end

function Config.Save(flags, name)
    name = name or "celestial_default"
    local ok, json = pcall(function()
        return HttpService:JSONEncode(encodeFlags(flags))
    end)
    if not ok then return false, "encode failed" end
    if typeof(writefile) == "function" then
        local wok, werr = pcall(writefile, name .. ".json", json)
        if wok then return true end
        return false, tostring(werr)
    end
    return false, json -- no filesystem: caller can print/store json
end

function Config.Load(flags, name)
    name = name or "celestial_default"
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local exists = false
        pcall(function() exists = isfile(name .. ".json") end)
        if not exists then return false, "no file" end
        local ok, data = pcall(readfile, name .. ".json")
        if not ok or not data then return false, "read failed" end
        local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
        if not ok2 or not tbl then return false, "json failed" end
        local decoded = decodeFlags(tbl)
        for k, v in pairs(decoded) do
            flags[k] = v
        end
        return true
    end
    return false, "no filesystem"
end

function Config.LoadJSON(flags, json)
    local ok, tbl = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or not tbl then return false end
    local decoded = decodeFlags(tbl)
    for k, v in pairs(decoded) do flags[k] = v end
    return true
end

return Config
