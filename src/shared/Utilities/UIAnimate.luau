--!strict
-- shared/Utilities/UIAnimate.luau
-- Elite UI Animation utility refactored and expanded from JakeDev's UI Animation Pack.
-- Provides reusable, performant, and clean TweenService bindings for buttons and frames.

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local UIAnimate = {}

local DEFAULT_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local DEFAULT_BOUNCE_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local DEFAULT_SHINE_INFO = TweenInfo.new(1.0, Enum.EasingStyle.Circular, Enum.EasingDirection.In, -1, false)

-- Helper to scale UDim2
local function scaleUDim2(orig: UDim2, scl: number): UDim2
	return UDim2.new(
		orig.X.Scale * scl,
		orig.X.Offset * scl,
		orig.Y.Scale * scl,
		orig.Y.Offset * scl
	)
end

-- Helper to offset UDim2 Position on Y axis
local function offsetYUDim2(orig: UDim2, offsetScale: number): UDim2
	return UDim2.new(
		orig.X.Scale,
		orig.X.Offset,
		orig.Y.Scale + offsetScale,
		orig.Y.Offset
	)
end

-- 1. Bind Hover & Click Scale (Bounce Effect)
function UIAnimate.bindHoverScale(button: GuiButton, hoverScl: number?, clickScl: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local hScl = hoverScl or 1.1
	local cScl = clickScl or 0.9
	local info = tInfo or DEFAULT_TWEEN_INFO

	local function playTween(scl: number)
		local newSize = scaleUDim2(origSize, scl)
		TweenService:Create(button, info, {Size = newSize}):Play()
	end

	local enterConn = button.MouseEnter:Connect(function()
		playTween(hScl)
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		playTween(1)
	end)

	local isClicking = false
	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true
		
		local shrink = TweenService:Create(button, info, {Size = scaleUDim2(origSize, cScl)})
		local reset = TweenService:Create(button, info, {Size = origSize})
		
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			reset:Play()
			local connReset
			connReset = reset.Completed:Connect(function()
				connReset:Disconnect()
				isClicking = false
			end)
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 2. Bind Color Shift on Hover (Supports Background, Image, and Text Colors)
function UIAnimate.bindHoverColor(button: GuiButton, hoverColor: Color3, originalColor: Color3, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	-- Determine target property
	local targetProperty = "BackgroundColor3"
	if button:IsA("ImageButton") then
		targetProperty = "ImageColor3"
	elseif button:IsA("TextButton") and not button.BackgroundTransparency == 1 then
		targetProperty = "BackgroundColor3"
	elseif button:IsA("TextButton") then
		targetProperty = "TextColor3"
	end

	local enterConn = button.MouseEnter:Connect(function()
		TweenService:Create(button, info, {[targetProperty] = hoverColor}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		TweenService:Create(button, info, {[targetProperty] = originalColor}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 3. Bind UIStroke Thickness Scale on Hover
function UIAnimate.bindStrokeScale(button: GuiButton, stroke: UIStroke, hoverThickOffset: number?, tInfo: TweenInfo?): () -> ()
	local origThick = stroke.Thickness
	local hoverThick = origThick + (hoverThickOffset or 2)
	local info = tInfo or DEFAULT_TWEEN_INFO

	local enterConn = button.MouseEnter:Connect(function()
		TweenService:Create(stroke, info, {Thickness = hoverThick}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		TweenService:Create(stroke, info, {Thickness = origThick}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 4. Bind UIStroke Visibility Toggle on Hover
function UIAnimate.bindStrokeVisibility(button: GuiButton, stroke: UIStroke, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	stroke.Enabled = false

	local enterConn = button.MouseEnter:Connect(function()
		stroke.Enabled = true
		stroke.Transparency = 1
		TweenService:Create(stroke, info, {Transparency = 0}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		local tween = TweenService:Create(stroke, info, {Transparency = 1})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			if not stroke.Enabled then return end
			stroke.Enabled = false
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 5. Bind Icon Wiggle Rotation on Hover
function UIAnimate.bindIconWiggle(button: GuiButton, icon: ImageLabel, wiggleRotOffset: number?, tInfo: TweenInfo?): () -> ()
	local origRot = icon.Rotation
	local wiggleRot = wiggleRotOffset or 10
	local info = tInfo or DEFAULT_TWEEN_INFO
	local isClicking = false

	local enterConn = button.MouseEnter:Connect(function()
		if isClicking then return end
		local tweens = {
			TweenService:Create(icon, info, {Rotation = wiggleRot}),
			TweenService:Create(icon, info, {Rotation = -wiggleRot}),
			TweenService:Create(icon, info, {Rotation = wiggleRot}),
			TweenService:Create(icon, info, {Rotation = origRot})
		}
		
		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		if isClicking then return end
		TweenService:Create(icon, info, {Rotation = origRot}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 6. Bind Rotate & Scale Hover (Simulator Button Effect)
function UIAnimate.bindRotateHoverScale(button: GuiButton, hoverScl: number?, hoverRot: number?, clickScl: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local hScl = hoverScl or 1.1
	local hRot = hoverRot or 10
	local cScl = clickScl or 0.9
	local info = tInfo or DEFAULT_TWEEN_INFO

	local function playTween(scl: number, rot: number)
		local newSize = scaleUDim2(origSize, scl)
		TweenService:Create(button, info, {Size = newSize, Rotation = rot}):Play()
	end

	local enterConn = button.MouseEnter:Connect(function()
		playTween(hScl, hRot)
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		playTween(1, 0)
	end)

	local isClicking = false
	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true
		
		local shrink = TweenService:Create(button, info, {Size = scaleUDim2(origSize, cScl), Rotation = 0})
		local reset = TweenService:Create(button, info, {Size = origSize, Rotation = 0})
		
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			reset:Play()
			local connReset
			connReset = reset.Completed:Connect(function()
				connReset:Disconnect()
				isClicking = false
			end)
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 7. Bind Position Bounce on Click
function UIAnimate.bindClickBouncePos(button: GuiButton, hoverScl: number?, bounceUpScale: number?, bounceDownScale: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local origPos = button.Position
	local hScl = hoverScl or 1.1
	local bUp = bounceUpScale or -0.02
	local bDown = bounceDownScale or 0.02
	local info = tInfo or DEFAULT_TWEEN_INFO
	local isClicking = false

	local function sizeTween(scl: number)
		return TweenService:Create(button, info, {Size = scaleUDim2(origSize, scl)})
	end

	local function posTween(offsetY: number)
		return TweenService:Create(button, info, {Position = offsetYUDim2(origPos, offsetY)})
	end

	local enterConn = button.MouseEnter:Connect(function()
		if not isClicking then
			sizeTween(hScl):Play()
		end
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		if not isClicking then
			sizeTween(1):Play()
		end
	end)

	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true

		local tweens = {
			sizeTween(1),
			posTween(bUp),
			posTween(bDown),
			posTween(0)
		}

		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end

		local connEnd
		connEnd = tweens[#tweens].Completed:Connect(function()
			connEnd:Disconnect()
			isClicking = false
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 8. Bind RileyBytes Shiny Button Effect
function UIAnimate.bindShineEffect(button: GuiButton, shineFrame: Frame, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_SHINE_INFO
	
	shineFrame.Position = UDim2.fromScale(-0.5, 0.5)
	local tween = TweenService:Create(shineFrame, info, {Position = UDim2.fromScale(1.5, 0.5)})
	tween:Play()

	return function()
		tween:Cancel()
	end
end

-- 9. Toggle Scale Pop Frame Transition (Using UIScale & EasingStyle.Back)
function UIAnimate.toggleScalePop(frame: GuiObject, isOpen: boolean, tInfoIn: TweenInfo?, tInfoOut: TweenInfo?): () -> ()
	local scale = frame:FindFirstChildOfClass("UIScale") :: UIScale?
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = frame
	end
	
	local uiScale = scale :: UIScale
	local infoIn = tInfoIn or TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local infoOut = tInfoOut or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	if isOpen then
		frame.Visible = true
		uiScale.Scale = 0
		TweenService:Create(uiScale, infoIn, {Scale = 1}):Play()
	else
		local shrink = TweenService:Create(uiScale, infoOut, {Scale = 0})
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			if uiScale.Scale == 0 then
				frame.Visible = false
			end
		end)
	end

	return function() end
end

-- 10. Standalone Popup Frame Transition (Size & Transparency)
function UIAnimate.popup(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	if isOpen then
		frame.Visible = true
		TweenService:Create(frame, info, {
			Size = origSize,
			BackgroundTransparency = 0
		}):Play()
	else
		local tween = TweenService:Create(frame, info, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 11. Standalone Bouncing Frame Transition (Elastic Bouncy Zoom)
function UIAnimate.bounce(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_BOUNCE_INFO

	local function makeSizeTween(scl: number, alpha: number)
		return TweenService:Create(frame, info, {
			Size = scaleUDim2(origSize, scl),
			BackgroundTransparency = alpha
		})
	end

	if isOpen then
		frame.Visible = true
		local tweens = {
			makeSizeTween(1.2, 0),
			makeSizeTween(0.8, 0),
			makeSizeTween(1.0, 0)
		}
		
		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end
	else
		local tween = makeSizeTween(0, 1)
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 12. Standalone Rotate In Frame Transition
function UIAnimate.rotateIn(frame: GuiObject, origSize: UDim2, startRot: number?, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO
	local rotVal = startRot or 15

	if isOpen then
		frame.Visible = true
		frame.Rotation = rotVal
		TweenService:Create(frame, info, {
			Size = origSize,
			BackgroundTransparency = 0,
			Rotation = 0
		}):Play()
	else
		local tween = TweenService:Create(frame, info, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Rotation = rotVal
		})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 13. Standalone FOV & Screen Blur Camera Transition
function UIAnimate.fovTransition(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO
	local camera = workspace.CurrentCamera
	
	local blur = Lighting:FindFirstChild("UIBlurEffect") :: BlurEffect?
	if not blur then
		local newBlur = Instance.new("BlurEffect")
		newBlur.Name = "UIBlurEffect"
		newBlur.Size = 0
		newBlur.Parent = Lighting
		blur = newBlur
	end

	if isOpen then
		frame.Visible = true
		TweenService:Create(frame, info, {Size = origSize, BackgroundTransparency = 0}):Play()
		TweenService:Create(camera, info, {FieldOfView = 80}):Play()
		TweenService:Create(blur, info, {Size = 20}):Play()
	else
		local frameTween = TweenService:Create(frame, info, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		frameTween:Play()
		TweenService:Create(camera, info, {FieldOfView = 70}):Play()
		TweenService:Create(blur, info, {Size = 0}):Play()
		
		local conn
		conn = frameTween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

return UIAnimate
