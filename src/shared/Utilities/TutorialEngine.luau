--!strict
-- shared/Utilities/TutorialEngine.luau
-- Elite Declarative Interactive Tutorial Engine for Roblox.
-- Manages step-by-step player onboarding, UI highlight focus, 3D world objective waypoint beacons,
-- animated 3D directional arrows, colorful HUD cards, and progress tracking.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIAnimate = require(script.Parent.UIAnimate)
local ThemeManager = require(script.Parent.ThemeManager)

export type TutorialStep = {
	Id: string,
	Title: string,
	Instruction: string,
	TargetPart: BasePart?,
	TargetUI: GuiObject?,
	AccentColor: Color3?,
	ActionSignal: RBXScriptSignal?,
	CheckCompletion: (() -> boolean)?,
}

local TutorialEngine = {}
TutorialEngine.__index = TutorialEngine

function TutorialEngine.new(steps: {TutorialStep})
	local self = setmetatable({}, TutorialEngine)
	self.Steps = steps
	self.CurrentIndex = 1
	self.IsActive = false
	self.HighlightInstance = nil :: Highlight?
	self.ArrowBillboard = nil :: BillboardGui?
	self.UIWidget = nil :: ScreenGui?
	return self
end

-- 🌟 Create & Mount Top-Center Colorful HUD Tutorial Widget
function TutorialEngine:mountWidget()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	local existing = playerGui:FindFirstChild("TutorialGui")
	if existing then existing:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TutorialGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 90

	local card = Instance.new("Frame")
	card.Name = "CardFrame"
	card.Size = UDim2.new(0, 380, 0, 85)
	card.Position = UDim2.new(0.5, 0, 0.08, 0)
	card.AnchorPoint = Vector2.new(0.5, 0)
	card.Parent = screenGui

	ThemeManager.applyGlassmorphism(card, "DarkGlass", 12)

	-- Accent Color Bar Left Border
	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(0, 6, 1, -16)
	accentBar.Position = UDim2.new(0, 8, 0, 8)
	accentBar.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
	accentBar.Parent = card

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 3)
	accentCorner.Parent = accentBar

	-- Step Counter Badge
	local badge = Instance.new("TextLabel")
	badge.Name = "BadgeLabel"
	badge.Size = UDim2.new(0, 150, 0, 18)
	badge.Position = UDim2.new(0, 22, 0, 10)
	badge.BackgroundTransparency = 1
	badge.Font = ThemeManager.Fonts.Header
	badge.TextSize = 12
	badge.TextColor3 = Color3.fromRGB(244, 114, 182)
	badge.TextXAlignment = Enum.TextXAlignment.Left
	badge.Text = "STEP 1 OF 3"
	badge.Parent = card

	-- Instruction Title
	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, -35, 0, 22)
	title.Position = UDim2.new(0, 22, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = ThemeManager.Fonts.Title
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Objective Title"
	title.Parent = card

	-- Instruction Details
	local details = Instance.new("TextLabel")
	details.Name = "DetailsLabel"
	details.Size = UDim2.new(1, -35, 0, 20)
	details.Position = UDim2.new(0, 22, 0, 52)
	details.BackgroundTransparency = 1
	details.Font = ThemeManager.Fonts.Body
	details.TextSize = 13
	details.TextColor3 = ThemeManager.Palettes.DarkGlass.TextSecondary
	details.TextXAlignment = Enum.TextXAlignment.Left
	details.Text = "Instruction details text"
	details.Parent = card

	screenGui.Parent = playerGui
	self.UIWidget = screenGui
end

-- 🎯 Attach 3D Waypoint Highlight & Floating Directional Arrow
function TutorialEngine:highlightPart(part: BasePart?, accentColor: Color3?)
	if self.HighlightInstance then
		self.HighlightInstance:Destroy()
		self.HighlightInstance = nil
	end
	if self.ArrowBillboard then
		self.ArrowBillboard:Destroy()
		self.ArrowBillboard = nil
	end

	if not part then return end

	local color = accentColor or Color3.fromRGB(244, 114, 182)

	-- 1. 3D Glowing Highlight
	local highlight = Instance.new("Highlight")
	highlight.Name = "Tutorial3DHighlight"
	highlight.Adornee = part
	highlight.FillColor = color
	highlight.FillTransparency = 0.4
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.Parent = part
	self.HighlightInstance = highlight

	-- 2. Floating 3D Direction Arrow (BillboardGui hover above part)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TutorialDirectionArrow"
	billboard.Adornee = part
	billboard.Size = UDim2.new(0, 60, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true

	local arrowLabel = Instance.new("TextLabel")
	arrowLabel.Size = UDim2.new(1, 0, 1, 0)
	arrowLabel.BackgroundTransparency = 1
	arrowLabel.Text = "⬇"
	arrowLabel.TextSize = 36
	arrowLabel.TextColor3 = color
	arrowLabel.Font = Enum.Font.GothamBold
	arrowLabel.Parent = billboard

	billboard.Parent = part
	self.ArrowBillboard = billboard

	-- Bobbing Arrow Tween
	local origOffset = billboard.StudsOffset
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(billboard, tweenInfo, {StudsOffset = origOffset + Vector3.new(0, 1.2, 0)}):Play()
end

-- 🚀 Start Tutorial Sequence
function TutorialEngine:start(onComplete: () -> ())
	if self.IsActive then return end
	self.IsActive = true
	self:mountWidget()
	self:renderCurrentStep(onComplete)
end

-- 📌 Render Current Step
function TutorialEngine:renderCurrentStep(onComplete: () -> ())
	local step = self.Steps[self.CurrentIndex]
	if not step then
		self:finish(onComplete)
		return
	end

	local color = step.AccentColor or Color3.fromRGB(59, 130, 246)

	if self.UIWidget then
		local card = self.UIWidget:FindFirstChild("CardFrame") :: Frame?
		if card then
			local accentBar = card:FindFirstChild("AccentBar") :: Frame
			local badge = card:FindFirstChild("BadgeLabel") :: TextLabel
			local title = card:FindFirstChild("TitleLabel") :: TextLabel
			local details = card:FindFirstChild("DetailsLabel") :: TextLabel

			accentBar.BackgroundColor3 = color
			badge.Text = string.format("STEP %d OF %d", self.CurrentIndex, #self.Steps)
			badge.TextColor3 = color
			title.Text = step.Title
			details.Text = step.Instruction

			UIAnimate.bounce(card, card.Size, true)
		end
	end

	self:highlightPart(step.TargetPart, color)

	-- Wait for completion trigger
	local conn: RBXScriptConnection?
	local function checkAndAdvance()
		if conn then conn:Disconnect() end
		self.CurrentIndex += 1
		self:renderCurrentStep(onComplete)
	end

	if step.ActionSignal then
		conn = step.ActionSignal:Connect(function()
			checkAndAdvance()
		end)
	else
		-- Fallback auto-advance after 5 seconds if no signal
		task.delay(5, checkAndAdvance)
	end
end

-- 🏁 Complete Tutorial
function TutorialEngine:finish(onComplete: () -> ())
	self.IsActive = false
	if self.HighlightInstance then
		self.HighlightInstance:Destroy()
	end
	if self.ArrowBillboard then
		self.ArrowBillboard:Destroy()
	end
	if self.UIWidget then
		self.UIWidget:Destroy()
	end
	onComplete()
end

return TutorialEngine
