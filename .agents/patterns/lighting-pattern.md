# Lighting & Post-Processing System Pattern

---

## 📌 Overview
The **LightingController** manages atmospheric technology, skyboxes, and post-processing effects (`Atmosphere`, `Sky`, `Bloom`, `DepthOfField`, `SunRays`, `ColorCorrectionEffect`) with smooth tween transitions when swapping maps or triggering dynamic environment events.

---

## 🛠️ Implementation Standard (`LightingController.luau`)

```lua
--!strict
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type LightingProfile = {
    ClockTime: number,
    Brightness: number,
    Ambient: Color3,
    OutdoorAmbient: Color3,
    Technology: Enum.Technology,
    ExposureCompensation: number?,
    Atmosphere: {
        Density: number,
        Offset: number,
        Color: Color3,
        Decay: Color3,
        Glare: number,
        Haze: number,
    }?,
    Bloom: {
        Intensity: number,
        Size: number,
        Threshold: number,
    }?,
    ColorCorrection: {
        Brightness: number,
        Contrast: number,
        Saturation: number,
        TintColor: Color3,
    }?,
}

local LightingController = {
    Name = "LightingController",
    CurrentProfile = nil :: string?,
}

-- Ensure child post-processing effect instances exist in Lighting
local function getOrMakeEffect<T>(className: string, name: string): T
    local found = Lighting:FindFirstChild(name)
    if not found then
        found = Instance.new(className)
        found.Name = name
        found.Parent = Lighting
    end
    return found :: T
end

function LightingController:ApplyProfile(profile: LightingProfile, tweenDuration: number?)
    local duration = tweenDuration or 1.5
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- 1. Set Engine Lighting Technology
    Lighting.Technology = profile.Technology or Enum.Technology.Future

    -- 2. Tween Root Lighting Properties
    TweenService:Create(Lighting, tweenInfo, {
        ClockTime = profile.ClockTime,
        Brightness = profile.Brightness,
        Ambient = profile.Ambient,
        OutdoorAmbient = profile.OutdoorAmbient,
        ExposureCompensation = profile.ExposureCompensation or 0,
    }):Play()

    -- 3. Apply & Tween Atmosphere Effect
    if profile.Atmosphere then
        local atmosphere = getOrMakeEffect("Atmosphere", "Atmosphere") :: Atmosphere
        TweenService:Create(atmosphere, tweenInfo, {
            Density = profile.Atmosphere.Density,
            Offset = profile.Atmosphere.Offset,
            Color = profile.Atmosphere.Color,
            Decay = profile.Atmosphere.Decay,
            Glare = profile.Atmosphere.Glare,
            Haze = profile.Atmosphere.Haze,
        }):Play()
    end

    -- 4. Apply & Tween Bloom Effect
    if profile.Bloom then
        local bloom = getOrMakeEffect("BloomEffect", "Bloom") :: BloomEffect
        TweenService:Create(bloom, tweenInfo, {
            Intensity = profile.Bloom.Intensity,
            Size = profile.Bloom.Size,
            Threshold = profile.Bloom.Threshold,
        }):Play()
    end

    -- 5. Apply & Tween ColorCorrection Effect
    if profile.ColorCorrection then
        local colorCorrection = getOrMakeEffect("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
        TweenService:Create(colorCorrection, tweenInfo, {
            Brightness = profile.ColorCorrection.Brightness,
            Contrast = profile.ColorCorrection.Contrast,
            Saturation = profile.ColorCorrection.Saturation,
            TintColor = profile.ColorCorrection.TintColor,
        }):Play()
    end
end

-- Swap Skybox Asset dynamically
function LightingController:SetSkybox(skyAssetId: string)
    local sky = getOrMakeEffect("Sky", "Sky") :: Sky
    sky.SkyboxBk = skyAssetId
    sky.SkyboxDn = skyAssetId
    sky.SkyboxFt = skyAssetId
    sky.SkyboxLf = skyAssetId
    sky.SkyboxRt = skyAssetId
    sky.SkyboxUp = skyAssetId
end

function LightingController:Init()
    -- Ensure baseline effects exist on startup
    getOrMakeEffect("Atmosphere", "Atmosphere")
    getOrMakeEffect("Sky", "Sky")
    getOrMakeEffect("BloomEffect", "Bloom")
    getOrMakeEffect("DepthOfFieldEffect", "DepthOfField")
    getOrMakeEffect("SunRaysEffect", "SunRays")
    getOrMakeEffect("ColorCorrectionEffect", "ColorCorrection")
    
    print("[Client] LightingController initialized.")
end

return LightingController
```
