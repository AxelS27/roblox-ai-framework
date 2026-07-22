--!strict
-- shared/Utilities/UIAutoBinder.luau
-- Elite Automatic Recursive UI Decorator and Dynamic Sound Animator.
-- Automatically attaches Glassmorphism, UIAnimate hover/click scale bouncing, stroke highlights,
-- and distinct sensory audio feedback (Primary, Close, Shop, Skill, Tab) to any ScreenGui.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local UIAnimate = require(script.Parent.UIAnimate)
local ThemeManager = require(script.Parent.ThemeManager)

local UIAutoBinder = {}

-- 🔊 Play Dynamic Sound with Pitch Variance
local function playCategorySound(categoryName: string)
	local soundConfig = ThemeManager.Sounds[categoryName] or ThemeManager.Sounds.Primary
	local sound = Instance.new("Sound")
	sound.SoundId = soundConfig.SoundId
	sound.Volume = soundConfig.Volume
	
	-- Randomize pitch slightly for organic acoustic feedback
	local pMin = soundConfig.PitchMin or 0.95
	local pMax = soundConfig.PitchMax or 1.05
	sound.Pitch = pMin + math.random() * (pMax - pMin)
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- 🎨 Automatically Decorate and Animate a Single Button with Specific Sound Role
function UIAutoBinder.decorateButton(button: GuiButton, hoverScale: number?, clickScale: number?, soundRole: string?)
	local hScl = hoverScale or 1.08
	local cScl = clickScale or 0.92
	local role = soundRole or "Primary"

	-- Infer sound role from button name if not provided
	local btnName = string.lower(button.Name)
	if not soundRole then
		if string.find(btnName, "close") or string.find(btnName, "cancel") or string.find(btnName, "exit") then
			role = "Close"
		elseif string.find(btnName, "buy") or string.find(btnName, "shop") or string.find(btnName, "purchase") then
			role = "Purchase"
		elseif string.find(btnName, "skill") or string.find(btnName, "equip") or string.find(btnName, "upgrade") then
			role = "Skill"
		elseif string.find(btnName, "tab") or string.find(btnName, "nav") then
			role = "Secondary"
		end
	end

	-- 1. UICorner setup
	local corner = button:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
	end

	-- 2. UIStroke setup
	local stroke = button:FindFirstChildOfClass("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.8
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = button
	end

	-- 3. UIAnimate scale bouncing & stroke highlight
	UIAnimate.bindHoverScale(button, hScl, cScl)
	UIAnimate.bindStrokeScale(button, stroke :: UIStroke, 1.5)

	-- 4. Hover & Select sound bindings (Distinct per role!)
	button.MouseEnter:Connect(function()
		playCategorySound("Hover")
	end)

	button.MouseButton1Click:Connect(function()
		playCategorySound(role)
	end)
end

-- 🖼️ Automatically Decorate a Frame with Glassmorphism
function UIAutoBinder.decorateFrame(frame: GuiObject, paletteName: string?)
	if frame.BackgroundTransparency >= 1 then return end
	ThemeManager.applyGlassmorphism(frame, paletteName or "DarkGlass")
end

-- 🪄 Recursive UI Tree Decorator (Applies to ScreenGui or Root Container)
function UIAutoBinder.decorate(root: Instance, paletteName: string?)
	local palette = paletteName or "DarkGlass"

	local function processInstance(inst: Instance)
		if inst:IsA("GuiButton") then
			UIAutoBinder.decorateButton(inst :: GuiButton)
		elseif inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("CanvasGroup") then
			UIAutoBinder.decorateFrame(inst :: GuiObject, palette)
		end
	end

	-- Process root if applicable
	processInstance(root)

	-- Process all descendants recursively
	for _, child in ipairs(root:GetDescendants()) do
		processInstance(child)
	end

	-- Listen for dynamic child additions
	root.DescendantAdded:Connect(function(child)
		task.defer(function()
			processInstance(child)
		end)
	end)
end

-- 🔗 1-Line Button Binding Helper (Decoration + Dynamic Sound + Action Callback)
function UIAutoBinder.bindButton(button: GuiButton, onClick: () -> (), soundRole: string?, hoverScale: number?): () -> ()
	UIAutoBinder.decorateButton(button, hoverScale, nil, soundRole)

	local conn = button.MouseButton1Click:Connect(function()
		onClick()
	end)

	return function()
		conn:Disconnect()
	end
end

return UIAutoBinder
