local function tryFont(name, fallback)
	local ok, val = pcall(function()
		return (Enum.Font :: any)[name]
	end)
	if ok and val ~= nil then
		return val
	end
	return fallback
end

local Theme = {
	Bg = Color3.fromRGB(15, 15, 20),
	Bg2 = Color3.fromRGB(18, 18, 25),
	Panel = Color3.fromRGB(21, 21, 29),
	Card = Color3.fromRGB(20, 20, 28),
	CardHover = Color3.fromRGB(27, 27, 37),
	Input = Color3.fromRGB(27, 27, 37),
	InputHover = Color3.fromRGB(33, 33, 46),
	Track = Color3.fromRGB(42, 42, 55),
	Stroke = Color3.fromRGB(33, 33, 45),
	Divider = Color3.fromRGB(29, 29, 39),
	Accent = Color3.fromRGB(139, 132, 255),
	AccentHover = Color3.fromRGB(150, 143, 255),
	AccentDark = Color3.fromRGB(108, 102, 220),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(178, 178, 190),
	TextMute = Color3.fromRGB(106, 106, 123),
	TextDark = Color3.fromRGB(20, 20, 28),
	CheckOff = Color3.fromRGB(35, 35, 47),
	Warn = Color3.fromRGB(225, 175, 60),
	Green = Color3.fromRGB(90, 200, 130),
	RadiusWin = 16,
	RadiusCard = 12,
	RadiusBtn = 8,
	RadiusSmall = 6,
	FontBlack = tryFont("BuilderSansExtraBold", Enum.Font.GothamBlack),
	FontBold = tryFont("BuilderSansBold", Enum.Font.GothamBold),
	FontMed = tryFont("BuilderSansMedium", Enum.Font.GothamMedium),
	FontReg = tryFont("BuilderSans", Enum.Font.Gotham),
	FontLight = tryFont("BuilderSansLight", Enum.Font.Gotham),
	Trans = 0,
}

function Theme:ApplyAccent(accent)
	self.Accent = accent
end

return Theme
