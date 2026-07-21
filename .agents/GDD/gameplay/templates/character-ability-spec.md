# Character & Ability Specification Blueprint: [Name/ID]

> **Unified Spec Sheet for Character Stats, Decoupled Abilities, Hitboxes, VFX/SFX, and Input Mapping**

---

## 🎭 User Story
* **AS A** [Role / Class / Player Type]
* **I WANT TO** [Action or gameplay capability]
* **SO THAT I CAN** [Gameplay outcome / tactical advantage]

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
