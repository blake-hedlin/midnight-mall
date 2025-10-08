# 🎨 Midnight Mall — Level & Visual Design Bible
**Version:** v0.1 (Oct 2025)  
**Owner:** Blake Hedlin  
**Linked Docs:** [PRD](./PRD.md) · [Sprint 1 Backlog](./sprint_backlog.md)

---

## 🧭 Design Philosophy
The player experience should balance **fear and agency** — giving players the tools to survive, but not enough to feel safe. Every lighting cue, sound, and hallway layout reinforces the *fight or flight* tension of surviving in an empty mall at midnight.

Key principles:
- **Readable, not realistic:** Simple geometry and contrast over detail noise.  
- **Tension through space:** Narrow hallways → small sightlines → increased anxiety.  
- **Reward discovery:** Bright safe zones, glowing loot cues, clear progression path.  
- **Cohesive palette:** Reuse light and signage tones for recognizability.

---

## 🏗️ Layout Overview (Greybox Plan)

### Zones
| Zone | Description | Tag Usage |
|:--|:--|:--|
| **Atrium** | Central hub with skylight and exits; spawn area. | `AtriumSpawn` (folder + SpawnLocations) |
| **Store 1: Toy Galaxy** | Loot-rich but exposed; lots of shelves and visibility. | `LootCrate`, `BarricadeAnchor` |
| **Store 2: Food Court** | Medium loot, tight corners, lighting variation. | `LootCrate`, `BarricadeAnchor` |
| **Maintenance Corridor** | High-risk shortcut connecting stores; darkness and sound design focus. | `EnemySpawn`, `PowerSwitch` |
| **Security Office** | Optional objective zone; key pickup spawns here. | `ObjectiveKey`, `LootCrate` |

### Suggested Greybox Dimensions
```
Top-Down Sketch (ASCII Layout)

       [Security Office]
              |
   [Toy Galaxy]---[Atrium]---[Food Court]
              \        |
            [Maintenance Corridor]
```
Each store: ~40x40 studs, 15–20 studs high.  
Atrium: ~60x60 studs, open ceiling (for lighting effects).

---

## 💡 Lighting & Mood

| Phase | Color Palette | Fog & Effects | Audio | Emotion |
|:--|:--|:--|:--|:--|
| **Day (Prep)** | Warm yellow (Ambient 0.8, OutdoorAmbient 0.6) | Clear, soft shadows | Mall hum, light music | Safety & readiness |
| **Transition (Dusk)** | Orange–purple tint | Fading lights, flicker script | Dim power-down sound | Unease |
| **Night (Threat)** | Blue–red contrast (Ambient 0.1, FogEnd 60, Density 0.6) | Red flashing emergency lights | Siren + growls | Fear & urgency |
| **Dawn (Relief)** | Pale sunlight (Ambient 0.7, OutdoorAmbient 0.5) | Clear fog, warm tone | Victory cue | Relief |

Preset module file: `ReplicatedStorage/Shared/LightingPresets.lua`

---

## 🧱 Prop & Asset Direction
- **Core Assets:** Mall signage, counters, shelves, flickering lights, barricade boards.  
- **Marketplace Packs:** Use modular low-poly sets for performance.  
- **Scale:** Slightly exaggerated (Roblox 1.1x standard size) to support visibility.  
- **Color Palette:** Muted blues/greys with bright accents (signs, vending machines).  
- **Interactive Props:**
  - LootCrate → glowing rim light + proximity prompt.
  - BarricadeAnchor → visible window/doorframe outlines.
  - PowerSwitch → yellow strobe with hum SFX.

---

## 🧩 UI/UX Visual Rules
- HUD contrast: white/teal icons on dark overlay.  
- Inventory icons: clear silhouettes, no clutter.  
- Enemy cues: edge flashes + sound proximity.  
- Mobile safe zones: 20% padding bottom/left for thumbs.  
- Console: radial menu + crosshair alignment.

---

## 🗺️ Lighting & Audio Sync System (Planned)
| Event | Visual | Audio |
|:--|:--|:--|
| DayStart | Fade in white | Morning hum |
| Dusk | Color tween orange → red | Power-down SFX |
| NightStart | Red fog on | Alarm siren |
| Dawn | White fade | Victory cue |

---

## ⚙️ Design Tasks for Sprint 1
| Task | Owner | Deliverable | Linked Story |
|:--|:--|:--|:--|
| Greybox environment | Design | `.rbxl` with tagged zones | Story 7 |
| Lighting preset module | Design + Eng | `LightingPresets.lua` | Story 8 |
| HUD wireframe | Design | Mock or Figma layout | Story 9 |
| Prop tagging pass | Design | Add `LootCrate` and `BarricadeAnchor` tags | Stories 2–3 |

---

## 📐 Future Design Expansions
- Add second floor balcony and escalator paths for Sprint 3.  
- Introduce emergency generator room with interactable objective.  
- Expand lighting cues per store for dynamic ambience.  
- Replace greybox walls with modular art kit post-MVP.

---

© 2025 Midnight Mall Project — Design Reference Document

