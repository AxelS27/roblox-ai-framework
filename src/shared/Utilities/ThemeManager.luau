--!strict
-- shared/Utilities/ThemeManager.luau
-- Elite Theme & Design Tokens Engine for Roblox UI.
-- Provides centralized color palettes, HSL gradients, glassmorphism styling, typography scale, and sensory audio token categories.

local ThemeManager = {}

-- 🎨 Color Palettes (Curated Modern & Vibrant Dark Themes)
ThemeManager.Palettes = {
	DarkGlass = {
		Background = Color3.fromRGB(15, 17, 26),
		BackgroundTrans = 0.35,
		Surface = Color3.fromRGB(24, 28, 42),
		SurfaceTrans = 0.25,
		Border = Color3.fromRGB(255, 255, 255),
		BorderTrans = 0.85,
		TextPrimary = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 190, 210),
		TextMuted = Color3.fromRGB(110, 125, 150),
		Accent = Color3.fromRGB(99, 102, 241), -- Indigo
	},
	Cyberpunk = {
		Background = Color3.fromRGB(12, 10, 24),
		BackgroundTrans = 0.3,
		Surface = Color3.fromRGB(25, 18, 48),
		SurfaceTrans = 0.2,
		Border = Color3.fromRGB(244, 114, 182),
		BorderTrans = 0.75,
		TextPrimary = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(244, 211, 248),
		TextMuted = Color3.fromRGB(165, 130, 190),
		Accent = Color3.fromRGB(236, 72, 153), -- Neon Pink
	},
	EmeraldEcosystem = {
		Background = Color3.fromRGB(10, 22, 18),
		BackgroundTrans = 0.35,
		Surface = Color3.fromRGB(18, 38, 30),
		SurfaceTrans = 0.25,
		Border = Color3.fromRGB(52, 211, 153),
		BorderTrans = 0.8,
		TextPrimary = Color3.fromRGB(240, 253, 244),
		TextSecondary = Color3.fromRGB(167, 243, 208),
		TextMuted = Color3.fromRGB(110, 175, 145),
		Accent = Color3.fromRGB(16, 185, 129), -- Emerald
	},
}

-- 🌈 High-Contrast Progress Bar Gradients (Color3 Sequences)
ThemeManager.BarGradients = {
	Health = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 185, 129)), -- Lime Emerald
		ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 231, 183)),
	}),
	HealthDanger = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 29, 72)), -- Crimson Rose
		ColorSequenceKeypoint.new(1, Color3.fromRGB(253, 164, 175)),
	}),
	Stamina = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 165, 233)), -- Sky Electric Blue
		ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 211, 252)),
	}),
	Hunger = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 158, 11)), -- Amber Orange
		ColorSequenceKeypoint.new(1, Color3.fromRGB(253, 186, 116)),
	}),
	XP = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)), -- Amethyst Purple
		ColorSequenceKeypoint.new(1, Color3.fromRGB(216, 180, 254)),
	}),
	Gold = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(234, 179, 8)), -- Gold Yellow
		ColorSequenceKeypoint.new(1, Color3.fromRGB(254, 240, 138)),
	}),
}

-- 🎵 Sensory Audio Palette (Distinct Sound IDs per Button Category)
ThemeManager.Sounds = {
	Hover = { SoundId = "rbxassetid://6895079853", PitchMin = 0.95, PitchMax = 1.05, Volume = 0.25 },
	Primary = { SoundId = "rbxassetid://6895078956", PitchMin = 1.0, PitchMax = 1.05, Volume = 0.4 },
	Secondary = { SoundId = "rbxassetid://6895079853", PitchMin = 1.1, PitchMax = 1.15, Volume = 0.3 },
	Close = { SoundId = "rbxassetid://6895079361", PitchMin = 0.9, PitchMax = 0.95, Volume = 0.35 },
	Purchase = { SoundId = "rbxassetid://6895079604", PitchMin = 1.0, PitchMax = 1.05, Volume = 0.45 },
	Skill = { SoundId = "rbxassetid://6895080005", PitchMin = 1.05, PitchMax = 1.1, Volume = 0.4 },
}

-- 🔤 Typography Standards
ThemeManager.Fonts = {
	Title = Enum.Font.BuilderSans,
	Header = Enum.Font.Montserrat,
	Body = Enum.Font.GothamSSm,
	Numeric = Enum.Font.GothamBold,
}

-- 🖼️ Apply Frosted Glassmorphism Effect to a Frame
function ThemeManager.applyGlassmorphism(frame: GuiObject, paletteName: string?, cornerRadiusPixels: number?)
	local palette = ThemeManager.Palettes[paletteName or "DarkGlass"] or ThemeManager.Palettes.DarkGlass
	local radius = cornerRadiusPixels or 10

	frame.BackgroundColor3 = palette.Surface
	frame.BackgroundTransparency = palette.SurfaceTrans

	-- UICorner
	local corner = frame:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = frame
	end
	(corner :: UICorner).CornerRadius = UDim.new(0, radius)

	-- UIStroke (Glossy Glass Border)
	local stroke = frame:FindFirstChildOfClass("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = frame
	end
	local uiStroke = stroke :: UIStroke
	uiStroke.Color = palette.Border
	uiStroke.Transparency = palette.BorderTrans
	uiStroke.Thickness = 1
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Subtle Vertical Gradient
	local gradient = frame:FindFirstChildOfClass("UIGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Parent = frame
	end
	local uiGradient = gradient :: UIGradient
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
	})
end

-- 📊 Apply Gradient Progress Fill to a Bar Frame
function ThemeManager.applyBarGradient(fillFrame: GuiObject, gradientType: string)
	local seq = ThemeManager.BarGradients[gradientType] or ThemeManager.BarGradients.Health
	fillFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local gradient = fillFrame:FindFirstChildOfClass("UIGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Parent = fillFrame
	end
	local uiGradient = gradient :: UIGradient
	uiGradient.Rotation = 0
	uiGradient.Color = seq
end

return ThemeManager
