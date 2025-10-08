# 🕛 Midnight Mall — Co-Op Survival Game (Roblox)

**TL;DR:**
Midnight Mall is a fast-paced **co-op survival experience** set in a dark, abandoned shopping mall. Players scavenge supplies, build barricades, and outlast relentless night-time threats.
Designed for **core Roblox players, friend groups, and streamers**, the MVP focuses on tight co-op mechanics, satisfying progression, and watchable moments.

---

## 🎯 Project Goals

- Deliver a polished **MVP survival loop** in 3–4 weeks that is fun, replayable, and watchable.
- Support **2–6 player co-op sessions** with short, intense rounds (5–7 minutes per night).
- Build systems that are **modular, server-authoritative, and maintainable**.
- Reach **50K unique players** within 30 days of launch via Roblox Discovery + social.
- Achieve **25% D1 / 8% D7 retention** and **≥70% thumbs-up** rating.

📄 **Full PRD:** [docs/PRD.md](docs/PRD.md)

---

## 🧱 Core Gameplay Loop

| Phase              | Description                                      | Key Systems                        |
| ------------------ | ------------------------------------------------ | ---------------------------------- |
| **Day / Prep**     | Explore the mall, scavenge resources, barricade | Loot System, Inventory, Barricades |
| **Night / Survive** | Defend against AI enemies until dawn             | Enemy AI, Combat, Lighting Cycle   |
| **Extract / Reward** | Survive to dawn, earn XP and cosmetics           | Progression, Analytics             |

---

## 🗂️ Repo Structure

```
📦 midnight-mall/
├── README.md                    # Project overview (this file)
├── docs/
│   ├── PRD.md                   # Product requirements document
│   ├── Planning/
│   │   └── Sprint_1_planning.md # Current sprint backlog
│   └── design_notes/            # Visual & UX design guidelines
├── src/
│   ├── ReplicatedStorage/       # Shared modules (Items, Signals)
│   ├── ServerScriptService/     # Server systems (Clock, Loot, Barricade, NPC)
│   ├── StarterGui/              # HUD UI
│   └── StarterPlayer/           # Client scripts
├── default.project.json         # Rojo project configuration
├── aftman.toml                  # Dev tool versions
├── .stylua.toml                 # Code formatter config
└── selene.toml                  # Linter config
```

---

## ⚙️ Local Setup

### 🧰 Tech Stack
- **Language:** Luau (typed)
- **Tooling:** Rojo, Aftman, StyLua, Selene, Wally
- **Architecture:** Server-authoritative with signal-based events
- **Version Control:** GitHub (main/dev/feature branching)
- **AI Pairing:** Claude Code
- **Analytics:** DataStore + MemoryStore for session duration, deaths, and retention tracking

### Prerequisites
- **Roblox Studio** (latest version)
- **Rojo Plugin** installed in Studio
- **Homebrew** (macOS) or **Cargo** (cross-platform)

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/blake-hedlin/midnight-mall.git
   cd midnight-mall
   ```

2. **Install dev tools (macOS):**
   ```bash
   brew install aftman
   aftman trust rojo-rbx/rojo JohnnyMorganz/StyLua Kampfkarren/selene UpliftGames/wally
   aftman install
   ```

3. **Start Rojo server:**
   ```bash
   rojo serve
   ```
   Server runs at http://localhost:34872/

4. **Connect Roblox Studio:**
   - Open Roblox Studio
   - Click **Rojo → Connect** in the toolbar
   - Press **Play** to test

5. **Edit code in `src/` — Rojo syncs changes live.**

---

## 🧪 Scripts Overview

| File                                                  | Purpose                                         |
| ----------------------------------------------------- | ----------------------------------------------- |
| `ServerScriptService/Systems/Clock.server.lua`        | Day/Night state machine with signal events      |
| `ReplicatedStorage/Items/LootRegistry.lua`            | Weighted loot table for containers              |
| `ServerScriptService/Systems/Loot.server.lua`         | Loot spawn and proximity prompt logic           |
| `ServerScriptService/Systems/Barricade.server.lua`    | Barricade placement with durability & repair    |
| `ServerScriptService/NPC/Mannequin.server.lua`        | Basic enemy AI (stub for Sprint 1)              |
| `StarterGui/HUD/Init.client.lua`                      | HUD bootstrap for time & inventory display      |
| `StarterPlayer/StarterPlayerScripts/ClientHUD.client.lua` | Client-side HUD updates                         |

---

## 🛠️ Dev Commands

```bash
# Format code
stylua .

# Lint code
selene .

# Build standalone .rbxl file
rojo build --output build/MidnightMall.rbxl
```

---

## 🧩 Development

**Current Sprint:** Sprint 1 — Core Loop MVP + Monetization Hooks

📋 **Sprint Backlog:** [docs/Planning/Sprint_1_planning.md](docs/Planning/Sprint_1_planning.md)
📄 **Design Notes:** [docs/design_notes/](docs/design_notes/)

For detailed user stories, acceptance criteria, and task tracking, see the sprint planning docs.

---

## 🧠 Design Pillars

- **Tension & Teamwork:** Every night feels barely survivable
- **Visual Contrast:** Cozy daylight → oppressive darkness
- **Watchability:** Crisp feedback, camera-friendly chaos
- **Low Friction:** Fast rounds, minimal downtime
- **Accessibility:** Colorblind-safe cues, subtitles, cross-platform

---

## 🪙 Monetization (Post-MVP)

- **Cosmetic Skins:** Character outfits, flashlight colors
- **Revive Tokens:** Single-use mid-night respawn items
- **Mall Pass:** Optional season pass with new wings & challenges

Sprint 1 includes scaffolding only (no live Robux APIs).

---

## 🧭 Next Steps

1. ✅ ~~Install dev tools (Aftman → Rojo)~~
2. ✅ ~~Create GitHub repository~~
3. ✅ ~~Add PRD and Sprint 1 planning docs~~
4. 🔄 Implement Sprint 1 stories (Lighting, Loot, Barricade, HUD)
5. ⏳ Build greybox mall environment in Studio
6. ⏳ First playtest of core loop

---

## 📊 Success Metrics

| Metric                  | Target              |
| ----------------------- | ------------------- |
| D1 / D7 Retention       | 25% / 8%            |
| Avg Session Length      | 20+ minutes         |
| Thumbs-Up Rating        | ≥70%                |
| Crash-Free Sessions     | ≥99.5%              |
| Server FPS / Latency    | ≥55 FPS / <200ms    |

---

## 🤖 For AI Agents (Claude Code / Cursor)

**Development Workflow:**
- Use `docs/Planning/Sprint_1_planning.md` as the active task source
- All code changes live under `src/` following the existing module structure
- Server-authoritative pattern: game logic in `ServerScriptService/`, shared modules in `ReplicatedStorage/`

**Commit Format:**
```
feat(<system>): <short description>

Examples:
- feat(lighting): add day/night cycle transitions
- fix(loot): correct item spawn weights
- docs(prd): update success metrics
```

**Constraints:**
- Never overwrite `docs/` or existing documentation without explicit request
- Follow existing signal-based event patterns (see `ReplicatedStorage/Shared/Signals.lua`)
- Server validates all client actions (placement, loot, combat)
- Test changes against Sprint acceptance criteria before marking complete

---

**Maintainer:** Blake Hedlin ([@blake-hedlin](https://github.com/blake-hedlin))
**Repository:** [github.com/blake-hedlin/midnight-mall](https://github.com/blake-hedlin/midnight-mall)
**Engine:** Roblox Studio (Luau + Rojo)

---

> _"Scavenge • Build • Survive — Midnight Mall opens at dusk."_
