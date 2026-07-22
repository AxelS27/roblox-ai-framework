# Character & Ability Specification Blueprint: [Name/ID]

> **Unified Spec Sheet for Character Stats, Decoupled Abilities, Hitboxes, VFX/SFX, and Input Mapping**

---

## 🎭 User Stories (Target 10+ entries from diverse POVs, states & conditions)

### Story 1: Basic Interaction / Casual Player POV
* **AS A** [Casual Player]
* **I WANT TO** [Action or gameplay capability in normal situations]
* **SO THAT I CAN** [Gameplay outcome / core value loop]

### Story 2: Combat / Tactical Situation POV
* **AS A** [Competitive / Combat Player]
* **I WANT TO** [Tactical maneuver or active ability trigger under pressure/combat]
* **SO THAT I CAN** [Combat advantage / survival outcome]

### Story 3: Mobile / Touch Control POV
* **AS A** [Mobile / iPad Player]
* **I WANT TO** [Tap clear action buttons in the touch HUD arc]
* **SO THAT I CAN** [Cast abilities cleanly without misclicks]

### Story 4: Low Resource / Cooldown State Condition
* **AS A** [Player out of Resource/Stamina]
* **I WANT TO** [See a clear radial cooldown sweep and resource warning]
* **SO THAT I CAN** [Avoid wasting button presses while on cooldown]

### Story 5: Faction / Progression / Nest Scenario
* **AS A** [Species / Faction Leader]
* **I WANT TO** [Coordinate species buffs and nest progression]
* **SO THAT I CAN** [Achieve long-term territory dominance]

### Story 6: Environmental Hazard Condition
* **AS A** [Player in Extreme Biome/Weather]
* **I WANT TO** [Use character traits to resist environmental damage]
* **SO THAT I CAN** [Navigate hazardous zones safely]

### Story 7: Stealth / Ambush Tactical Scenario
* **AS A** [Stealth Predator]
* **I WANT TO** [Use low-noise movement and camouflage]
* **SO THAT I CAN** [Ambush unsuspecting prey]

### Story 8: Group Battle / Multi-Target Condition
* **AS A** [Frontline Defender]
* **I WANT TO** [Absorb incoming area attacks and shield allies]
* **SO THAT I CAN** [Protect vulnerable hatchlings/teammates]

### Story 9: Gamepass / Evolution Perk Buyer POV
* **AS A** [Gamepass / Evolution Buyer]
* **I WANT TO** [Access exclusive species skins or stat multipliers]
* **SO THAT I CAN** [Enjoy premium cosmetic and progression perks]

### Story 10: Developer / Debugging POV
* **AS A** [Developer / QA Tester]
* **I WANT TO** [Simulate character morphs and test ability hitboxes via mock bots]
* **SO THAT I CAN** [Ensure zero errors or desyncs during playtesting]

---

## 📈 Core Statistics (Optional - Fill if Character/Entity Mode)
*Use this section if the rig, model, and stats are bound together as a unified class/morph (e.g., Ant, Dragon, or fixed Heroes).*

| Attribute | Base Value | Scale Multiplier | Description |
| :--- | :--- | :--- | :--- |
| **Character Class/Tier** | [Class/Tier Name] | N/A | Character classification |
| **Base Health (HP)** | [Value] HP | [Multiplier]x | Maximum health capacity |
| **Movement Speed** | [Value] Studs/sec | [Multiplier]x | Base walking/running speed |
| **Resource Capacity** | [Value] Units | [Multiplier]x | Stamina, Mana, Energy, etc. |
| **Physical Scale** | [Value]x | N/A | Visual scale multiplier applied to Rig/Model |
| **Collision Size** | [Value] Studs | N/A | Hitbox dimensions (Radius/Height) |

---

## ⚙️ Core Parameters (Optional - Fill if Decoupled Ability Mode)
*Use this section if defining a modular skill/ability that can be equipped onto custom player avatars or various characters.*

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Ability ID** | [Unique ID] | Reference key used in code/scripts |
| **Equip Slot / Bind** | [Input Bind] | Keyboard Key, Mobile Button, or Controller Bind |
| **Cooldown Duration**| [Value] seconds | Time before ability can be cast again |
| **Resource Cost** | [Value] [Resource Type] | Cost to execute (Stamina, Mana, Energy) |
| **Base Damage / Heal**| [Value] HP | Immediate health modification value |
| **Max Targets** | [Value] | Target limit (Single, Chain, AoE max) |

---

## ⚔️ Combat Mechanics & Spatial Math (Fill for all attacks/skills)
*Details for active abilities (e.g. Primary LMB, Secondary RMB, Ultimate Q).*

### Ability Name: [e.g. Mandible Bite / Fire Breath]
* **Hitbox Type**: [Type: Front Cone, Cylinder, Sphere Projectile, Point Click]
* **Range / Radius**: [Value] studs (forward range) / [Value] studs (hitbox width/radius)
* **Status Effect Applied**: [Effect Name, Tier, Duration]
* **VFX Mesh/Particles**: [Swipe trail color, flash particles, hit sparks]
* **SFX Asset ID**: `rbxassetid://[ID]` (Activation & Impact sounds)
* **Animation Track ID**: `rbxassetid://[ID]` (Playback Speed: [Multiplier]x)
* **Keyframe Timing**:
  * **Frame [X] (Time: [Y]s)**: Trigger hitbox check & damage check.
  * **Frame [X] (Time: [Y]s)**: End vulnerability / recovery.

---

## 🧬 Passive Traits & Modifiers
* **Passive Name**: [Passive Name]
* **Trigger Condition**: [Trigger condition]
* **Effect Mechanics**: [Details on gameplay modifications, e.g., +20% damage when below 30% HP]
* **Visual FX / Aura**: [Aura/Particles used when active]
