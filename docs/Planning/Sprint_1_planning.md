# 🏗️ Midnight Mall — Sprint 1 Backlog (Core Loop MVP + Monetization Hooks)

**Version:** v0.3 (Oct 2025)
**Duration:** 7–10 days
**Goal:** Deliver a fully playable single-store prototype of the core loop **with monetization scaffolding in place**.
**Linked PRD:** [/docs/PRD.md](./PRD.md)
**Linked Design Notes:** [/docs/design_notes.md](./design_notes.md)

---

## 🎯 Sprint Objective

Build the vertical slice: **Day → Loot → Barricade → Night → Survive → Dawn**.
Add hooks for currency and shop systems to reduce refactoring later. Focus remains on stable systems and clean code structure — monetization is non-functional scaffolding only.

---

## 🔑 Sprint Deliverables

| Deliverable                         | Definition of Done                                                     |
| ----------------------------------- | ---------------------------------------------------------------------- |
| Day/Night Cycle                     | Lighting + time state machine triggers events and HUD banner updates.  |
| Loot System                         | Tagged containers spawn random items; inventory updates in HUD.        |
| Barricade System                    | Ghost preview + placement + durability tracking + repair logic.        |
| Enemy Stub                          | Simple "Mannequin" NPC pathfinds toward players and damages boards.    |
| HUD Prototype                       | Time counter, inventory icons, and Day/Night alerts visible to player. |
| Spawn System                        | Players spawn at Atrium spawns with clean reset between sessions.      |
| Greybox Environment                 | Basic mall layout (atrium + 2 stores + corridor).                      |
| Lighting Preset Module              | Color/fog presets for Day/Night linked to LightingController.          |
| HUD Wireframe                       | Mock UI layout for testing icon placement and safe zones.              |
| **Monetization Hooks (Foundation)** | Soft-currency variable + shop UI placeholder integrated.               |

---

## 🧠 Stories, Prompts & Tracking

### Story 1 — Lighting Cycle & Clock Controller

**Claude Prompt:**

```
Title: Add Lighting Transitions for Day/Night Cycle  
Context: Clock module already fires DayStarted/NightStarted signals.  
Goal: Change Lighting Ambient, FogEnd, ColorCorrection when state changes.  
Acceptance: Ambient 0.8 Day → 0.1 Night; Night adds red fog; banner text shows transition.  
Test Plan: Play for 2 minutes and verify lighting and HUD change twice.  
Files: `ServerScriptService/Systems/LightingController.server.lua`
```

**Checklist:**

-

---

### Story 2 — Loot System Pass 1

**Claude Prompt:**

```
Title: Implement Randomized Loot Containers  
Context: Tagged Parts (`LootCrate`) exist; LootRegistry provides weights.  
Goal: Spawn items on interaction and update inventory client-side.  
Acceptance: Loot 3 unique items per day; crate shows cooldown indicator.  
Test Plan: Spawn 5 crates and loot them; verify inventory updates and resets next day.  
Files: `ServerScriptService/Systems/Loot.server.lua` + `ReplicatedStorage/Shared/Inventory.lua`
```

**Checklist:**

-

---

### Story 3 — Barricade Placement & Durability

**Claude Prompt:**

```
Title: Add Ghost Preview and Board Durability  
Context: Anchor Parts tagged `BarricadeAnchor`.  
Goal: Players place board preview (Green = valid / Red = invalid), consume 1 wood, spawn Board model with Durability IntValue.  
Acceptance: Board breaks after 3–5 enemy hits; repair with plank restores durability.  
Test Plan: Place and repair 3 boards; verify Durability values print to output.  
Files: `ServerScriptService/Systems/Barricade.server.lua`
```

**Checklist:**

-

---

### Story 4 — Enemy Stub (Mannequin)

**Claude Prompt:**

```
Title: Create Basic Enemy AI for Testing Barricades  
Context: Placeholder NPC to validate combat loop.  
Goal: Pathfind toward nearest player or anchor, attack board, despawn at dawn.  
Acceptance: Enemy spawns NightStart, damages boards, plays SFX, despawns on DayStart.  
Test Plan: Observe enemy attack cycle; verify server log shows damage ticks.  
Files: `ServerScriptService/NPC/Mannequin.server.lua`
```

**Checklist:**

-

---

### Story 5 — HUD & Banner Integration

**Claude Prompt:**

```
Title: Enhance HUD for Inventory and Time  
Context: HUD prototype exists in StarterGui/HUD.  
Goal: Add icons for Wood/Snack/Battery, update counts on inventory signal, display banner for Day/Night transitions.  
Acceptance: HUD auto-updates inventory and time; no frame drops.  
Test Plan: Loot items and observe real-time updates; verify banner shows NightStart.  
Files: `StarterGui/HUD/Init.client.lua` + `ReplicatedStorage/Shared/Signals.lua`
```

**Checklist:**

-

---

### Story 6 — Spawn & Respawn Flow

**Claude Prompt:**

```
Title: Implement Atrium Spawn Logic  
Context: Folder `workspace/AtriumSpawn` contains SpawnLocations.  
Goal: Spawn players at random spawn; on death queue respawn at next DayStart.  
Acceptance: Player respawns within 5 seconds of dawn.  
Test Plan: Die during night; verify respawn location and reset inventory.  
Files: `ServerScriptService/Systems/Spawn.server.lua`
```

**Checklist:**

-

---

### Story 7 — Mall Greybox Environment (Design Integration)

**Claude Prompt:**

```
Title: Build Greybox Mall Layout  
Context: Design Notes outline Atrium + 2 stores + maintenance corridor.  
Goal: Create `.rbxl` file with parts for each zone and apply CollectionService tags (LootCrate, BarricadeAnchor, AtriumSpawn).  
Acceptance: All tagged zones load in Studio; navigation paths are playable.  
Test Plan: Load in Studio, walk end-to-end without falling or clipping.  
Files: `workspace/MallGreybox.rbxm`
```

**Checklist:**

-

---

### Story 8 — Lighting Preset Module

**Claude Prompt:**

```
Title: Create LightingPresets Module  
Context: Define visual tone for Day/Night phases.  
Goal: Store color, fog, ambient, and contrast values in a shared module to be used by LightingController.  
Acceptance: Presets match Design Notes lighting table.  
Test Plan: Call LightingPresets.Day and LightingPresets.Night manually; verify visuals.  
Files: `ReplicatedStorage/Shared/LightingPresets.lua`
```

**Checklist:**

-

---

### Story 9 — HUD Wireframe (Design)

**Claude Prompt:**

```
Title: Create Mock HUD Wireframe  
Context: Establish layout for inventory icons and alerts per Design Notes.  
Goal: Build Figma frame or Studio frame with placeholder icons in safe zones.  
Acceptance: Layout readable on 1080p desktop and mobile.  
Test Plan: Resize Studio viewport; verify responsive positioning.  
Files: `StarterGui/HUD/Wireframe.mockup` or `/docs/design_notes.md` reference.
```

**Checklist:**

-

---

### Story 10 — Monetization Hooks (Foundation)

**Claude Prompt:**

```
Title: Stub Currency & Shop Entry Points
Context: Economy design planned for Sprint 2. Need placeholders in current systems.
Goal: Add a soft-currency IntValue ("Coins") and a placeholder "Shop" button in HUD.
Acceptance: Currency variable saves per player session; Shop button opens a mock panel (no purchases).
Test Plan: Verify variable increments manually; ensure UI element toggles without errors.
Files: `ReplicatedStorage/Shared/Currency.lua`, `StarterGui/HUD/ShopButton.client.lua`
```

**Checklist:**

* [ ] Add `Coins` variable to player data model
* [ ] Create "Shop" button in HUD (visible, non-functional)
* [ ] Link button to open/close a blank frame
* [ ] Save/load currency variable between sessions

---

## 🧩 Stretch Goals (P1)

| Feature                 | Description                             | Notes               |
| ----------------------- | --------------------------------------- | ------------------- |
| DBNO/Revive System      | Prototype Down-But-Not-Out revive flow. | If time permits.    |
| Ambient SFX Manager     | Cycle audio themes Day/Night.           | Optional immersion. |
| Basic Credits Reward    | Grant soft currency on round end.       | Prep for Phase 1.   |
| **Shop UI Placeholder** | Non-functional store frame for UX test. | Monetization prep.  |

---

## 🧾 Acceptance Checklist

* [ ] All core loop systems function end-to-end (Day/Night/Loot/Barricade/Enemy).
* [ ] Player data model includes `Coins` soft-currency and Shop UI placeholder.
* [ ] No Robux API or live monetization logic used this sprint.

---

## 🪄 Next Sprint Preview

**Sprint 2 — Threat & Tension**

- Mannequin AI tier 1 (chase & line-of-sight).
- DBNO revive loop.
- Objective items (Security Key, Power Switch).
- Ambient lighting/audio system.
- **Economy Foundations:** Soft currency rewards, shop UI wireframe, Robux integration plan.

---

## ⚠️ Dev Note

> Monetization this sprint is *scaffolding only*. Do not include any Robux, GamePass, or Dev Product APIs yet. The goal is to structure UI and data so economy systems can slot in during Sprint 2 without refactor.

---

© 2025 Midnight Mall Project — Internal Development Backlog

