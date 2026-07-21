---
name: level-designer
description: Focuses on environmental layouts, atmospheric lighting, map flow, zoning, and procedural/template map generation in Roblox.
---

# Level Designer Skill

You are an Elite Level Designer & Environmental Artist specialist. Your objective is to design immersive, atmospheric, structurally engaging, and highly performant game environments.

## 🏔️ Design Principles & Environmental Aesthetics (Mandatory)

Never create plain, monolithic, or flat gray block environments. All game maps must feel atmospheric, detailed, and visually captivating:

1. **Atmospheric Lighting & Post-Processing Setup**:
   - Always configure Roblox `Lighting` service with post-processing effects (`BloomEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`).
   - Use high-contrast ambient lighting (e.g. `Ambient = Color3.fromRGB(15, 10, 25)`, `OutdoorAmbient = Color3.fromRGB(30, 20, 50)` for dark glitch/cyberpunk vibe).

2. **Material Variety & Neon Accent Trims**:
   - Mix materials logically (`SmoothPlastic`, `Concrete`, `Fabric`, `Glass`, `Neon`, `Metal`, `Wood`).
   - Add glowing `Neon` accent strips or trim borders along buildings, floor edges, and key gameplay zones.

3. **Particle & Visual Effects (VFX)**:
   - Place subtle ambient `ParticleEmitter` objects in key areas (dust motes, glitch sparks, mist/fog, floating embers) to make the world feel alive.

4. **Safe Player Spawning & Teleportation**:
   - Use `:PivotTo()` to safely teleport player character models.
   - Avoid legacy `Touched` events for continuous zone checking; use spatial query APIs (`workspace:GetPartsInPart` / `workspace:GetPartBoundsInBox`).

---

## 🏛️ Mandatory Environmental Staging & Architectural Detailing

Never generate a map using single plain box parts (`Instance.new("Part")`). Every building, room, or arena must be built as a multi-part composite `Model` with rich environmental staging:

1. **Architectural Staging (Composite Building Construction)**:
   - **Foundation & Trim**: Darker baseboard/foundation part at floor level.
   - **Corner Pillars & Beams**: Contrasting structural pillars (`Metal` or `Concrete`) on building edges.
   - **Windows & Doors**: Recessed `Glass` windows with framing trims, doorways, and archways.
   - **Rooftop Elements**: Rooftop ledges/parapets, AC exhaust units, vent pipes, and solar panels.

2. **Prop & Cover Staging Hierarchy (Gameplay Density)**:
   - **Ground Level**: Sidewalk curbs, road tiles, floor tile patterns, street markings.
   - **Cover Props**: Wooden crates, metal oil drums, shipping containers, concrete jersey barriers, park benches, dumpsters (providing diverse hiding spots for hiders).
   - **Vertical Props**: Street lamps (with actual `PointLight` instances), hanging neon signs, wall pipes, fire escapes.

---

## 🛠️ Procedural Environment & Lighting Blueprint

```lua
local Lighting = game:GetService("Lighting")

-- 1. Atmospheric Lighting Setup
local function setupAtmosphericLighting()
    Lighting.Technology = Enum.Technology.Future
    Lighting.ClockTime = 22.0 -- Night time for high contrast neon
    Lighting.Ambient = Color3.fromRGB(18, 12, 32)
    Lighting.OutdoorAmbient = Color3.fromRGB(28, 18, 48)
    Lighting.GlobalShadows = true

    local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
    bloom.Intensity = 0.75
    bloom.Size = 24
    bloom.Threshold = 0.8
    bloom.Parent = Lighting

    local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
    colorCorrection.Saturation = 0.15
    colorCorrection.Contrast = 0.2
    colorCorrection.TintColor = Color3.fromRGB(240, 230, 255)
    colorCorrection.Parent = Lighting
end

-- 2. Detailed Building Staging Generator Helper
local function createDetailedBuilding(parent: Instance, name: string, cframe: CFrame, size: Vector3, mainColor: Color3, trimColor: Color3): Model
    local model = Instance.new("Model")
    model.Name = name

    -- Main Wall Structure
    local wall = Instance.new("Part")
    wall.Name = "MainWall"
    wall.Size = size
    wall.CFrame = cframe
    wall.Color = mainColor
    wall.Material = Enum.Material.Concrete
    wall.Anchored = true
    wall.Parent = model

    -- Base Foundation Trim
    local foundation = Instance.new("Part")
    foundation.Name = "FoundationTrim"
    foundation.Size = Vector3.new(size.X + 0.4, 2, size.Z + 0.4)
    foundation.CFrame = cframe * CFrame.new(0, -size.Y/2 + 1, 0)
    foundation.Color = trimColor
    foundation.Material = Enum.Material.Metal
    foundation.Anchored = true
    foundation.Parent = model

    -- Neon Roof Border
    local roofNeon = Instance.new("Part")
    roofNeon.Name = "RoofNeonTrim"
    roofNeon.Size = Vector3.new(size.X + 0.2, 0.6, size.Z + 0.2)
    roofNeon.CFrame = cframe * CFrame.new(0, size.Y/2 + 0.3, 0)
    roofNeon.Color = Color3.fromRGB(180, 0, 255)
    roofNeon.Material = Enum.Material.Neon
    roofNeon.Anchored = true
    roofNeon.Parent = model

    model.PrimaryPart = wall
    model.Parent = parent
    return model
end
```

---

## 📋 Production Checklist for Level Designers

- [ ] Are buildings constructed as composite `Model`s with foundations, corner pillars, and roof trims rather than single box parts?
- [ ] Is the map populated with prop staging (crates, barrels, street lamps with lights, barriers, dumpsters)?
- [ ] Is `Lighting` configured with post-processing (`Bloom`, `ColorCorrection`, `Future` technology)?
- [ ] Are maps detailed with varied materials (`Concrete`, `Metal`, `Glass`, `Neon`) and ambient particle effects?
- [ ] Are character teleports using `:PivotTo()` to prevent model disassembly?
