# Master Game Systems Specification: EVOLUTION: SURVIVE

> **Comprehensive Core Mechanics, Formulas, Vitals, Combat, Ecosystem & Progression Blueprint**

---

## 📋 1. Sprint & Movement System Specs

| Property / Parameter | Value & Formula | Description / Mechanic |
| :--- | :--- | :--- |
| **Input Keybind** | `Left Shift` (PC) / `Sprint Touch Button` (Mobile) / `L3 / Left Stick Click` (Gamepad) | Dynamic toggle or hold sprint state |
| **WalkSpeed Base (Tier 1 Ant)** | `14 Studs / second` | Base walking speed for starter species |
| **WalkSpeed Base (Tier 2 Spider)**| `18 Studs / second` | Agile arachnid walking speed |
| **WalkSpeed Base (Tier 3 Wolf)**  | `22 Studs / second` | Swift pack predator walking speed |
| **WalkSpeed Base (Tier 4 Bear)**  | `16 Studs / second` | Heavy apex mammal walking speed |
| **WalkSpeed Base (Tier 5 Dragon)**| `26 Studs / second` (Ground) / `40 Studs / second` (Flight) | Late-game flying apex speed |
| **Sprint Speed Multiplier** | `1.5x Base WalkSpeed` | Speed bonus applied while sprinting (`Humanoid.WalkSpeed = Base * 1.5`) |
| **Stamina Drain Rate** | `-15 Stamina / second` | Continuous stamina drain while sprinting |
| **Hunger Drain Multiplier** | `2.0x Normal Decay Rate` | Hunger drains every 2.5 seconds instead of 5.0 seconds while sprinting |
| **Sprint Interruption Conditions** | `Stamina == 0`, `Hunger == 0`, `Poison Tier >= 2`, `Web Snare Active` | Sprinting automatically cancels and locks until conditions clear |

---

## 🩸 2. Health (HP) & Damage System Specs

| Property / Parameter | Value & Formula | Description / Mechanic |
| :--- | :--- | :--- |
| **Base HP (Tier 1 Ant)** | `50 HP` | Low baseline health pool |
| **Base HP (Tier 2 Spider)** | `120 HP` | Moderate health pool |
| **Base HP (Tier 3 Wolf)** | `250 HP` | Balanced predator health pool |
| **Base HP (Tier 4 Bear)** | `600 HP` | High tank health pool |
| **Base HP (Tier 5 Dragon)** | `1,500 HP` | Boss-level apex health pool |
| **Idle HP Regeneration** | `+2 HP / second` | Active only when `Hunger > 50%` and out of combat for `> 5 seconds` |
| **Nest Zone HP Regeneration**| `+5 HP / second` | Passive healing stack inside 100-stud controlled Nest Territory |
| **Combat Invalidation Window**| `5.0 Seconds` | Any damage taken pauses passive HP regen for 5 seconds |
| **Damage Types Matrix** | `Physical` (Bite/Claw), `Bleeding` (DoT), `Poison` (DoT), `Fire/Burn` (DoT), `Environmental` (Freezing/Lava/Starvation) | Sanitized on server via `CombatService` |

---

## 🍖 3. Hunger & Consumption System Specs

| Property / Parameter | Value & Formula | Description / Mechanic |
| :--- | :--- | :--- |
| **Max Hunger Capacity** | `100 Units` | Standard hunger gauge across all species |
| **Normal Decay Rate** | `-1 Hunger / 5.0 seconds` | Base decay rate (12 Hunger lost per minute while walking/idle) |
| **Starvation State (Hunger = 0)**| `WalkSpeed * 0.6` (-40% penalty), `-2 HP / second` starvation damage | Screen vignette darkens, stamina regen reduced by 50% |
| **Food Source: Berry Bush** | `+15 Hunger`, `+5 HP`, `+5 Evolution DNA` | Scavenged from Grassland/Forest flora nodes |
| **Food Source: Rabbit Carcass**| `+35 Hunger`, `+15 HP`, `+25 Evolution DNA` | Harvested from herbivore AI fauna |
| **Food Source: Wolf Carcass**  | `+70 Hunger`, `+40 HP`, `+100 Evolution DNA` | Harvested from rival predators |
| **Food Source: Dragon Carcass**| `+100 Hunger`, `+100 HP`, `+500 Evolution DNA` | Harvested from apex dragons |

---

## ⚡ 4. Stamina & Exhaustion System Specs

| Property / Parameter | Value & Formula | Description / Mechanic |
| :--- | :--- | :--- |
| **Max Stamina Capacity** | `100 Units` (150 Units for Wolf species) | Standard stamina resource pool |
| **Standing Still Regen Rate**| `+10 Stamina / second` | Rapid recovery while completely stationary |
| **Walking Regen Rate** | `+4 Stamina / second` | Slow recovery while walking normally |
| **Nest Rest Mat Regen Rate**| `+20 Stamina / second` | Accelerated recovery inside Nest shelter |
| **Exhaustion State (Stamina = 0)**| `Sprint Disabled`, `RMB/Q Skills Locked`, `1.5s Regen Delay` | Red stamina bar flash overlay, UI warning audio prompt |

---

## 🌡️ 5. Body Temperature & Climate System Specs

| Zone / Biome | Ambient Temp | Mechanics & Debuffs | Recovery & Countermeasures |
| :--- | :--- | :--- | :--- |
| **Comfort Zone** | `15°C – 30°C` | Normal vitals drain, zero thermal damage | Standard survival |
| **Frostpeak Tundra** | `< 0°C` (Blizzard) | Body Temp drops `-2°C / sec`. At `-10°C`: Frostbite (`-5 HP/sec`, `-20% Attack Speed`) | Stand near Fire Wolf, enter Nest shelter, approach Lava rivers |
| **Sun-Scorched Dunes** | `> 40°C` (Heatwave) | Body Temp rises `+2°C / sec`. At `> 45°C`: Heatstroke (`-5 HP/sec`, `2x Stamina Drain`) | Drink from Oasis water pools, rest in Canopy Forest shade, apply Swamp mud |
| **Volcanic Caldera** | `> 60°C` (Magma) | Contact with Lava applies Burn status (`-10 HP/sec` for 5s) | Fire Dragon immunity trait |

---

## ☣️ 6. Status Effects & Debuffs Specs

| Status Effect | Trigger Source | Effect & Duration | Removal / Countermeasure |
| :--- | :--- | :--- | :--- |
| **Bleeding (Tier 1-3)** | Wolf Bite / Claw attacks | Tier 1: `-2 HP/s` (5s), Tier 2: `-5 HP/s` (8s), Tier 3: `-10 HP/s` (10s) | Rest at Nest, consume medicinal aloe flora |
| **Poison (Tier 1-3)** | Spider Bite / Swamp pools | Tier 1: `-3 HP/s` (6s), Tier 2: Disables Stamina Regen, Tier 3: `-30% WalkSpeed` | Consume antidote fungi nodes |
| **Stun / Knockback** | Bear Ground Slam / Pounce | `1.0s – 1.5s` total movement & skill lockout | Tenacity mutation trait (-50% duration) |
| **Burn** | Dragon Fire Breath / Lava | `-8 HP/s` for 5 seconds + persistent flame aura particle | Submerge in river / water pool |

---

## ⚔️ 7. Combat & Species Skill Matrix

| Species | Primary (LMB) | Secondary (RMB) | Ultimate (Q) | Special (F) | Passive Trait |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Wolf** | Bite (25 Dmg, Bleed 1, 0.8s CD) | Pounce Dash (40 Dmg, 1s Stun, 4.0s CD) | Pack Howl (+20% Pack Dmg, 15s CD) | N/A | **Pack Hunter** (+5% Dmg per nearby wolf, max +25%) |
| **Spider** | Poison Bite (15 Dmg, Poison 1, 0.6s CD) | Web Snare (Slow 50%, 5.0s CD) | Acid Spray (AOE Poison 40 Dmg, 12s CD) | N/A | **Web Weaver** (+30% speed on webs) |
| **Bear** | Heavy Claw (45 Dmg, Knockback, 1.2s CD) | Ground Slam (1.5s AOE Stun, 6.0s CD) | Threat Roar (-20% Enemy Dmg, 18s CD) | N/A | **Thick Fur** (-25% Physical Dmg Taken) |
| **Dragon** | Claw (60 Dmg, 1.0s CD) | Tail Swipe (75 Dmg, Knockback, 5.0s CD) | Fire Breath (AOE Burn 100 Dmg, 10s CD) | Flight Takeoff | **Terror Aura** (Slows enemies within 20 studs by 15%) |

---

## 🧬 8. Species Evolution & Mutation Scaling Specs

| Tier | Species Options | DNA Cost | Physical Scale | Unlocked Skill Slots | Base HP / WalkSpeed |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tier 1** | Ant, Mouse, Frog | `0 DNA` | `0.4x Scale` | LMB, Passive | 50 HP / 14 WalkSpeed |
| **Tier 2** | Spider, Fox, Snake | `150 DNA` | `0.8x Scale` | LMB, RMB, Passive | 120 HP / 18 WalkSpeed |
| **Tier 3** | Wolf, Tiger, Boar | `500 DNA` | `1.2x Scale` | LMB, RMB, Q, Passive | 250 HP / 22 WalkSpeed |
| **Tier 4** | Bear, Rhino, Shark | `1,500 DNA` | `2.0x Scale` | LMB, RMB, Q, Passive | 600 HP / 16 WalkSpeed |
| **Tier 5** | Dragon, Phoenix, Leviathan | `5,000 DNA` | `3.5x Scale` | LMB, RMB, Q, F, Terror Aura | 1,500 HP / 26 WalkSpeed |

### Mutation Variants (Branching Perks):
* **Dire Variant**: `+20% Size`, `+15% Base HP`, `-5% WalkSpeed`.
* **Fire Variant**: Burning aura (`-3 HP/s` to nearby enemies), red flame particle trail.
* **Shadow Variant**: `+30% WalkSpeed`, stealth opacity reduction when stationary.
* **Ice Variant**: Frost breath attack, immunity to Frostpeak Tundra freezing hazard.

---

## 🏰 9. Hunting Party, Nest & Territory Specs

* **Hunting Party Capacity**: Up to 5 players per squad. Friendly fire disabled between members.
* **Shared DNA Bonus**: Squad members gain `+15% Bonus DNA` when hunting together within a 50-stud radius.
* **Nest Construction**: Costs `50 Wood` resources gathered from Fallen Logs.
* **Nest Functions**: Custom respawn point on death, `+5 HP/sec` healing aura, `+20 Stamina/sec` rest mat, and `500 Units Max` food storage container.
* **Territory Radius**: `100 Studs` around active Nest. Grants `+10% WalkSpeed` and `+15% HP Regen` to pack members inside boundary.

---

## 🌋 10. Dynamic World Events & Ecosystem Boss Specs

* **Event Interval**: Every 20 minutes (5-minute duration).
* **Meteor Strike**: Sky turns dark purple, meteor shower spawns impact craters with `Model_DnaCrystal` (+100 DNA each).
* **Blood Moon**: Crimson skybox (`Color3.fromRGB(120, 10, 10)`), all predators gain `+30% Attack Damage`.
* **Flash Flood**: Water level in Swamp rises `+4 studs`, land creatures slowed by `30%`, aquatic species gained `+50% speed`.
* **Volcano Eruption**: Magma rocks rain down, expanding Volcanic Caldera lava hazard zone.
* **Alpha Wolf Titan Boss**: Spawns when server Wolf count `>= 8`. Health: `5,000 HP` / Armor: `50%`. Reward: `2,500 DNA`.
* **Ancient Titan Dragon Boss**: Spawns when server Dragon count `>= 4`. Health: `15,000 HP` / Armor: `70%`. Reward: `5,000 DNA`.
