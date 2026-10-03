local Assets = {
	["crosshair"] = "rbxassetid://10709818534",
	["target"] = "rbxassetid://10734977012",
	["circle-dot"] = "rbxassetid://10709797837",
	["eye"] = "rbxassetid://10723346959",
	["eye-off"] = "rbxassetid://10723346871",
	["sword"] = "rbxassetid://10734975486",
	["swords"] = "rbxassetid://10734975692",
	["axe"] = "rbxassetid://10709769508",
	["car"] = "rbxassetid://10709789810",
	["gauge"] = "rbxassetid://10723395708",
	["server"] = "rbxassetid://10734949856",
	["globe"] = "rbxassetid://10723404337",
	["user"] = "rbxassetid://10747373176",
	["users"] = "rbxassetid://10747373426",
	["sliders-horizontal"] = "rbxassetid://10734963191",
	["sliders"] = "rbxassetid://10734963400",
	["code"] = "rbxassetid://10709810463",
	["terminal"] = "rbxassetid://10734982144",
	["file-code"] = "rbxassetid://10723356507",
	["cpu"] = "rbxassetid://10709813383",
	["zap"] = "rbxassetid://10709790202",
	["search"] = "rbxassetid://10734943674",
	["settings"] = "rbxassetid://10734950309",
	["settings-2"] = "rbxassetid://10734950020",
	["chevron-down"] = "rbxassetid://10709790948",
	["chevron-left"] = "rbxassetid://10709791281",
	["chevron-right"] = "rbxassetid://10709791437",
	["chevron-up"] = "rbxassetid://10709791523",
	["chevrons-up-down"] = "rbxassetid://10709797508",
	["check"] = "rbxassetid://10709790644",
	["check-circle"] = "rbxassetid://10709790387",
	["plus"] = "rbxassetid://10734924532",
	["plus-circle"] = "rbxassetid://10734923868",
	["more-horizontal"] = "rbxassetid://10734897250",
	["more-vertical"] = "rbxassetid://10734897387",
	["alert-triangle"] = "rbxassetid://10709753149",
	["info"] = "rbxassetid://10723415903",
	["cloud"] = "rbxassetid://10709806740",
	["box"] = "rbxassetid://10709782497",
	["package"] = "rbxassetid://10734909540",
	["sun"] = "rbxassetid://10734974297",
	["moon"] = "rbxassetid://10734897102",
	["languages"] = "rbxassetid://10723417703",
	["scaling"] = "rbxassetid://10734942072",
	["maximize-2"] = "rbxassetid://10734886496",
	["palette"] = "rbxassetid://10734910430",
	["copy"] = "rbxassetid://10709812159",
	["key"] = "rbxassetid://10723416652",
	["star"] = "rbxassetid://10734966248",
	["sparkles"] = "rbxassetid://10734966248",
	["menu"] = "rbxassetid://10734887784",
	["list"] = "rbxassetid://10723433811",
	["x"] = "rbxassetid://10747384394",
	["arrow-up-down"] = "rbxassetid://10709768538",
	["move"] = "rbxassetid://10734900011",
	["shield"] = "rbxassetid://10734951847",
	["shield-check"] = "rbxassetid://10734951367",
	["ghost"] = "rbxassetid://10723396107",
	["heart-pulse"] = "rbxassetid://10723406795",
	["map-pin"] = "rbxassetid://10734886004",
	["navigation"] = "rbxassetid://10734906744",
	["locate"] = "rbxassetid://10723434557",
	["keyboard"] = "rbxassetid://10723416765",
	["monitor"] = "rbxassetid://10734896881",
	["history"] = "rbxassetid://10723407335",
	["layers"] = "rbxassetid://10723424505",
	["layout-grid"] = "rbxassetid://10723424838",
}

local Aliases = {
	General = "crosshair",
	Visuals = "eye",
	Weapon = "sword",
	Vehicle = "car",
	Server = "server",
	Player = "user",
	Misc = "sliders-horizontal",
	Lua = "code",
	Executor = "cpu",
	Search = "search",
	Gear = "settings",
	ChevronR = "chevron-right",
	ChevronD = "chevron-down",
	ChevronL = "chevron-left",
	ChevronU = "chevron-up",
	Check = "check",
	Plus = "plus",
	Dots = "more-horizontal",
	Warn = "alert-triangle",
	Cloud = "cloud",
	Sort = "arrow-up-down",
	Box = "box",
	Target = "target",
	Eye = "eye",
	Globe = "globe",
	Users = "users",
	Sliders = "sliders-horizontal",
	Code = "code",
	Cpu = "cpu",
	Sun = "sun",
	Lang = "languages",
	Dpi = "scaling",
	Style = "palette",
	Key = "plus-circle",
	Spark = "star",
	Copy = "copy",
	Close = "x",
}

local Icons = {}
Icons.Assets = Assets
Icons.Aliases = Aliases

function Icons.Get(name)
	if not name then
		return Assets["circle-dot"]
	end
	if Assets[name] then
		return Assets[name]
	end
	local alias = Aliases[name]
	if alias and Assets[alias] then
		return Assets[alias]
	end
	local lower = string.lower(tostring(name))
	if Assets[lower] then
		return Assets[lower]
	end
	local stripped = lower:gsub("^lucide%-", "")
	if Assets[stripped] then
		return Assets[stripped]
	end
	return Assets["circle-dot"]
end

function Icons.Apply(imgLabel, name)
	if typeof(imgLabel) == "Instance" and imgLabel:IsA("ImageLabel") then
		imgLabel.Image = Icons.Get(name)
	end
	return imgLabel
end

function Icons.Make(parent, name, size, color)
	local img = Instance.new("ImageLabel")
	img.Name = "Icon_" .. tostring(name)
	img.BackgroundTransparency = 1
	img.BorderSizePixel = 0
	img.Image = Icons.Get(name)
	img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
	img.ScaleType = Enum.ScaleType.Fit
	img.ResampleMode = Enum.ResamplerMode.Pixelated
	if typeof(size) == "number" then
		img.Size = UDim2.new(0, size, 0, size)
	elseif typeof(size) == "UDim2" then
		img.Size = size
	else
		img.Size = UDim2.new(0, 18, 0, 18)
	end
	img.ZIndex = 2
	if parent then
		img.Parent = parent
	end
	return img
end

return Icons
