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

## Story 1 — Lighting Cycle & Clock Controller
**Experience Beat**: Time shifts are cinematic beats. Players *feel* the world change (light, fog, banner, audio) without UI clutter.

```prompt
You are Claude Code implementing Story 1.
Context: Use LightingPresets (Day/Night/Dawn) from /docs/ux-context.md and module `ReplicatedStorage/Shared/LightingPresets.lua`. Clock already emits `Signals.DayStarted` / `Signals.NightStarted`.
Goal: Implement `LightingController` to tween Lighting between presets using `TWEEN_SCENE` and trigger `UI_Banner` + audio.
Acceptance:
- Day→Night and Night→Dawn transitions tween in 1.5 s; no frame hitching.
- Apply Fog, Ambient, Brightness, Exposure, ColorShift per preset.
- Fire `UI_Banner` (text: "Night Falling" / "Dawn Breaking").
- Start/stop heartbeat loop on night start/end.
Files: `ServerScriptService/Systems/LightingController.server.lua`.
Test: Play 2 minutes and verify two full transitions; confirm banner timing matches lighting.
Sequence: precedes Story 5 (HUD), Story 4 (Enemy).
Checklist: Lighting tokens, TWEEN_SCENE, UI_Banner, SFX_NightStart.
```

---

## Story 2 — Loot System Pass 1
**Experience Beat**: Calm scavenging with tactile feedback (lid nudge, dust puff) builds anticipation before night.

```prompt
Implement basic lootable containers.
Context: Parts tagged `LootCrate`; `LootRegistry` provides weighted items; `Inventory.lua` handles counts and `Signals.InventoryChanged`.
Goal: Interact (E) to roll loot; spawn item server‑side; update HUD.
Acceptance:
- Each crate: cooldown indicator; 3 unique loots per Day phase.
- Visuals: puff particle + `SFX_LootOpen`, HUD count increases with 0.15 s tick animation.
- Resets on `DayStarted`.
Files: `ServerScriptService/Systems/Loot.server.lua`, `ReplicatedStorage/Shared/Inventory.lua`.
Test: Place 5 crates, loot them, verify uniqueness and HUD updates.
Sequence: follows Story 1 (for day detection); precedes Story 5 (HUD icons).
Checklist: UI_IconPrimary, Signals.InventoryChanged, TWEEN_FEEDBACK.
```

---

## Story 3 — Barricade Placement & Durability
**Experience Beat**: Snappy, readable placement; boards feel weighty; repairs are quick but costly in time.

```prompt
Add barricade ghost/placement and durability.
Context: `BarricadeAnchor` tags mark slots; player needs 1 `wood` to place.
Goal: Green (valid)/Red (invalid) ghost preview; confirm places Board model with IntValue `Durability` (range 3–5).
Acceptance:
- Placement confirm animates snap in 0.2 s + `SFX_BoardPlace`.
- Enemies reduce `Durability`; when 0, board breaks with particle burst.
- Repair consumes `wood` and increases `Durability` by 1 up to max.
Files: `ServerScriptService/Systems/Barricade.server.lua`.
Test: Place and repair 3 boards; verify printed durability ticks align with hits.
Sequence: follows Story 2 (wood acquisition); precedes Story 4 (enemy validation).
Checklist: Ghost material = ForceField, TWEEN_FEEDBACK, SFX_BoardPlace.
```
---

## Story 4 — Enemy Stub (Mannequin)
**Experience Beat**: A simple pursuer that validates the defense loop; audible hits communicate danger.

```prompt
Create placeholder enemy to test barricades.
Context: Pathfind to nearest `BarricadeAnchor`/player at Night; despawn at Dawn.
Goal: Spawn on `NightStarted`, attack boards (damage per hit), play hit SFX, despawn on `DayStarted`.
Acceptance:
- Attack cadence 0.8 s; damage reduces board durability consistently.
- Server log shows damage ticks; client hears `SFX_EnemyHit`.
Files: `ServerScriptService/NPC/Mannequin.server.lua`.
Test: Observe enemy break at least one board per night if undefended.
Sequence: follows Story 3; precedes Story 6 (respawn validation).
Checklist: PathfindingService, Heartbeat loop volume 0.4→0 on Dawn.
```

---

## Story 5 — HUD & Banner Integration
**Experience Beat**: HUD stays subtle; banners mark phase shifts. Inventory changes feel alive but not noisy.

```prompt
Enhance HUD for inventory/time + banners.
Context: `StarterGui/HUD` prototype exists. Use `UI_IconPrimary` and `UI_Banner` from /docs/ux-context.md.
Goal: Icons for Wood/Snack/Battery; time counter; show banner for Day/Night.
Acceptance:
- Icons use consistent spacing/padding; counts update with 0.15 s tick.
- `UI_Banner` slide in 0.3 s, fade out 1.0 s with colorblind‑safe contrast.
- No frame drops (>55 fps) on update bursts.
Files: `StarterGui/HUD/Init.client.lua`, `ReplicatedStorage/Shared/Signals.lua`.
Test: Loot items; observe real‑time updates; verify banner on NightStart.
Sequence: follows Story 1 & 2; precedes Story 10 (Shop button placement).
Checklist: Font_Primary, FS_MD, UI_Banner, TWEEN_UI.
```

---

## Story 6 — Spawn & Respawn Flow
**Experience Beat**: Death is a setback, not a stop; Dawn is the safe reset.

```prompt
Implement spawn points and dawn respawn.
Context: `workspace/AtriumSpawn` contains SpawnLocations.
Goal: Spawn at random on join; on death, queue respawn at next `DayStarted` (<=5 s).
Acceptance:
- Inventory resets on respawn; camera re‑centers with 1.0 s ease.
- No duplicate spawns at same exact frame; handle simultaneous joins.
Files: `ServerScriptService/Systems/Spawn.server.lua`.
Test: Die at night; verify respawn within 5 s of Dawn; inventory cleared.
Sequence: follows Story 4; precedes Story 7 (greybox traversal QA).
Checklist: TWEEN_SCENE camera, Signals.PlayerDied.
```

---

## Story 7 — Mall Greybox Environment (Design Integration)
**Experience Beat**: A readable layout: Atrium hub, two stores, maintenance corridor; traversal is frictionless.

```prompt
Build greybox map for traversal and tagging.
Context: Use `CollectionService` tags: `LootCrate`, `BarricadeAnchor`, `AtriumSpawn`.
Goal: `.rbxl` file with playtestable navmesh; no unintentional fall/clips.
Acceptance:
- Player can walk end‑to‑end; pathfinding works; anchors placed logically.
- Lighting volumes feel distinct by zone (Atrium brighter than stores).
Files: `workspace/MallGreybox.rbxm`.
Test: 5‑minute walk test; pathfinding from enemy spawns to barricades.
Sequence: precedes Story 2/3/4 as spatial foundation.
Checklist: Zone naming, tags audited, safe slopes < 30°.
```

---

## Story 8 — Lighting Preset Module (Authoritative)
**Experience Beat**: Consistency by code: every scene pulls from the same palette.

```prompt
Create shared LightingPresets module per /docs/ux-context.md.
Context: Used by LightingController and tests.
Goal: Export Day/Night/Dawn with exact tokens.
Acceptance:
- Values match context file; unit test verifies keys exist and types are correct.
Files: `ReplicatedStorage/Shared/LightingPresets.lua`.
Test: Manually apply presets; visual QA.
Sequence: precedes Story 1.
Checklist: Token parity with context.
```

---

## Story 9 — HUD Wireframe (Design)
**Experience Beat**: Establish spatial rules so later additions don’t drift.

```prompt
Create HUD wireframe as a reference.
Context: Define safe zones and anchor points for icons, timer, banner.
Goal: Build Studio frame with placeholders OR attach a static mock to `/docs/design_notes.md` (optional if Studio frame exists).
Acceptance:
- Readable on 1080p and mobile portrait; tap targets >=24 px.
- Uses `HUD_Root`, `UI_IconPrimary`, `UI_Banner` components.
Files: `StarterGui/HUD/Wireframe.mockup` or docs reference.
Test: Resize viewport; verify layout adherence.
Sequence: precedes Story 5.
Checklist: Font sizes, padding tokens, UIScale.
```

---

## Story 10 — Monetization Hooks (Foundation)
**Experience Beat**: A visible but inert shop entry — a reminder of progression without distracting the core loop.

```prompt
Stub soft currency and shop button.
Context: Economy real logic in Sprint 2.
Goal: Add `Coins` IntValue to player data; put `Shop` button in HUD; open/close mock panel.
Acceptance:
- Currency persists within session; button opens panel; no purchases.
- Panel uses `UI_Panel` component; respects UI scale rules.
Files: `ReplicatedStorage/Shared/Currency.lua`, `StarterGui/HUD/ShopButton.client.lua`.
Test: Increment coins manually; toggle panel; no errors.
Sequence: follows Story 5; precedes Sprint 2 economy.
Checklist: UI_Panel, Font_Primary, FS_MD.
```
## Global Build Order (for Agents)
1) Story 8 → 1 → 5 (visual spine)
2) Story 7 → 2 → 3 → 4 (core loop)
3) Story 6 (respawn) → 10 (shop stub) → 9 (wireframe if not already)

**Checklist:**
- [ ] Day/Night/Loot/Barricade/Enemy loop playable end‑to‑end.
- [ ] HUD shows icons/time; banners on phase changes.
- [ ] Coins variable and Shop panel exist (no monetization logic).
- [ ] All visuals/motion pull from `/docs/ux-context.md` tokens.
- [ ] Verified PC + mobile portrait performance.
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

