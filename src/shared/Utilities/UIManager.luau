--!strict
-- shared/Utilities/UIManager.luau
-- Elite Framework Generic Contextual UI State & Cross-Platform Visibility Manager.
-- Completely Game-Agnostic: Manages HUD state machine visibility for ANY Roblox game genre (RPG, Survival, Simulator, Racing, Tycoon, Battle Royale, etc.)
-- and enforces device-specific rendering (PC vs Mobile Touch HUD layout guardrails).

local UserInputService = game:GetService("UserInputService")

export type GameState = string -- Generic Game State string (e.g. "Lobby", "InGame", "Combat", "Trading", "Spectate", "All")

local UIManager = {}
UIManager.RegisteredGuis = {} :: {[string]: {Gui: ScreenGui, AllowedStates: {GameState}}}
UIManager.CurrentState = "Lobby" :: GameState

-- 🎯 Detect Device Type
function UIManager.isMobile(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function UIManager.isPC(): boolean
	return UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
end

-- 📌 Register Any ScreenGui for Generic Contextual Game State Visibility
function UIManager.register(screenGui: ScreenGui, allowedStates: {GameState})
	UIManager.RegisteredGuis[screenGui.Name] = {
		Gui = screenGui,
		AllowedStates = allowedStates,
	}

	-- Apply initial state check
	UIManager.evaluateGuiVisibility(screenGui, allowedStates, UIManager.CurrentState)
end

-- 🔍 Evaluate Single Gui Visibility against Current Context
function UIManager.evaluateGuiVisibility(gui: ScreenGui, allowedStates: {GameState}, currentState: GameState)
	local shouldShow = false
	for _, state in ipairs(allowedStates) do
		if state == "All" or state == currentState then
			shouldShow = true
			break
		end
	end

	-- Generic Device Filtering Guardrail (Mobile-tagged HUDs hidden on PC)
	if string.find(string.lower(gui.Name), "mobile") and not UIManager.isMobile() then
		shouldShow = false
	end

	if gui.Enabled ~= shouldShow then
		gui.Enabled = shouldShow
	end
end

-- 🔄 Transition Entire UI System to Any Generic Game State (e.g. "Lobby", "InGame", "Combat", "Trading")
function UIManager.setState(newState: GameState)
	UIManager.CurrentState = newState

	for _, data in pairs(UIManager.RegisteredGuis) do
		UIManager.evaluateGuiVisibility(data.Gui, data.AllowedStates, newState)
	end
end

-- 📱 Setup Safe-Zone Mobile Action Arc (Avoiding Roblox Native Jump Button Collision)
function UIManager.positionMobileTouchArc(containerFrame: GuiObject)
	containerFrame.AnchorPoint = Vector2.new(1, 1)
	-- Offset 130px left and 120px up to guarantee zero collision with Roblox Native Jump Button
	containerFrame.Position = UDim2.new(1, -130, 1, -120)
end

return UIManager
