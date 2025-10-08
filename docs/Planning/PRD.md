# Midnight Mall — PRD-Lite (Roblox Survival Game)
**Version:** v0.1 (Draft – Oct 2025)
**Owner:** Blake Hedlin
**Repo:** `midnight-mall`
**Next Update:** Sprint 1 Backlog + Claude Story Tickets

---

## 🎮 TL;DR
Midnight Mall is a fast-paced co-op survival experience where players scavenge a dark, abandoned shopping mall, build barricades, and outlast relentless night-time threats.
The core loop rewards exploration, teamwork, and quick decision-making across short, replayable nights.
Designed for core Roblox players, friend groups, and streamers, the MVP focuses on tight co-op mechanics, satisfying progression, and watchable moments.

---

## 📊 Goals

### Business
- Reach **50 K unique players** within 30 days of launch via Roblox Discovery + social.
- Achieve **25 % D1 / 8 % D7 retention** by optimizing early flow.
- Sustain **20 + min** avg session length through pacing & rewards.
- Deliver MVP in **3–4 weeks** with measurable analytics.
- Maintain **≥ 70 % thumbs-up** via polish and live balance.

### User
- Fun, tense, social survival sessions that are easy to start, hard to master.
- Meaningful teamwork: scouts, builders, medics under pressure.
- High replayability via varied loot and dynamic threats.
- Clear rewards: XP + cosmetics celebrating skill & cooperation.
- Smooth cross-platform play (mobile / console / PC) with readable UI.

### Non-Goals
- No pay-to-win or power boosts (cosmetics only).
- No deep meta systems (seasons, clans) in MVP.
- No procedural maps — one handcrafted mall for 1.0.

---

## 🧍 User Stories
(see in-game personas)

| Persona | Example User Stories |
|:--|:--|
| **Core Player** | Quick matchmaking • clear enemy cues • cosmetics from challenges • fair solo/duo scaling |
| **Group Player** | Fast party join • simple roles (scout/build/medic) • pings/quick chat • shared win conditions |
| **Streamer** | Spectator-friendly HUD • streamer-mode anonymity • high-intensity "clip" moments |

---

## ⚙️ Functional Requirements

### Exploration (P0)
Flashlight & battery management • lootable containers • distinct POIs • basic stealth • audio cues.

### Barricading (P0)
Gather resources • snap-to placement with preview • durability & repair • anti-grief build budget.

### Survival (P0)
Night rounds 5–7 min • enemy AI (patrol/chase/breach) • DBNO revives • optional objectives • rewards.

### UI/UX (P0)
Lobby + matchmaking • HUD (timer, compass, inventory) • ping/quick chat • tutorial tips • settings.

---

## 🎮 User Experience Highlights
- **FTUE:** one-click Play, short "How it Works" card, contextual tooltips.
- **Core Loop:** Prep → Night → Survive → Extract → Reward.
- **Accessibility:** colorblind-safe cues, subtitles, haptics.
- **Performance Mode:** simplified lighting/effects for mobile.

---

## 🧩 Feature Prioritization

| Feature | Priority | Status | Owner |
|:--|:--|:--|:--|
| Day/Night Cycle | P0 | Planned | Engineering |
| Loot & Inventory | P0 | In Progress | Engineering |
| Barricade System | P0 | In Progress | Engineering |
| DBNO/Revive | P1 | Planned | Engineering |
| Cosmetics Shop | P2 | Future | Design |
| Analytics Events | P1 | Planned | Engineering |

---

## 🧠 Narrative Snapshot
Nova, Kai, and Mira scavenge an eerie mall as lights flicker and alarms wail.
They build, hold, fall, revive, and finally escape at dawn — battered but grinning, ready for another run.

---

## 📈 Success Metrics

| Category | Metric | Target |
|:--|:--|:--|
| **User** | D1 25 % / D7 8 % Retention | Cohort via Roblox Analytics |
| | Avg Session Length 20 min + | Join → Exit |
| **Business** | Thumbs-Up ≥ 70 % | In-game prompt after 2 nights |
| | Revenue / DAU $0.03–$0.05 | Cosmetics only |
| **Technical** | Crash-Free ≥ 99.5 % | Across platforms |
| | Server FPS ≥ 55 / Latency < 200 ms | Under target load |

---

## 🧰 Technical Overview
- **Toolchain:** Roblox Studio + Rojo + Aftman (Luau modules, server-authoritative).
- **Systems:** AI pathfinding • barricade placement grid • loot tables • DBNO revive • round manager.
- **Data:** PlayerProfile, MatchState, Inventory, Cosmetics.
- **Services:** DataStoreService, MemoryStore, BadgeService, Analytics.
- **Performance:** StreamingEnabled assets, pooled AI actors, LOD, rate-limited remotes.
- **Security:** Server-validated placements and inventory; anti-grief rules.

---

## 🪜 Milestones & Sequencing

| Phase | Duration | Key Deliverables |
|:--|:--|:--|
| **Phase 0 – Prototype Loop** | ~1 wk | Round manager • basic AI • barricade placement • greybox mall |
| **Phase 1 – MVP Beta** | 1–2 wk | DBNO • revive • XP • analytics • anti-grief • UI polish |
| **Phase 2 – Soft Launch & Polish** | ~1 wk | Cosmetics shop • performance mode • streamer mode • balancing pass |

Team Size: 2 (core) + optional contractor for audio/art.
Estimated Total: 2–4 weeks to ship MVP.

---

## ⚠️ Key Risks & Mitigations
- **AI Pathfinding Perf** → use pre-baked waypoints + region triggers.
- **Cross-Platform Controls** → device-specific layouts + auto detect.
- **DataStore Throttling** → queued writes + retry logic.
- **Exploit Attempts** → server authority + sanity checks on client remotes.

---

## 🪄 Next Steps
1. Create `/docs/sprint_backlog.md` with Sprint 1 stories (loot, barricade, HUD, lighting).
2. Generate Claude Code prompts for each P0 system.
3. Link this PRD from `README.md` for new contributors.
4. Schedule first playtest once core loop runs end-to-end.

---

© 2025 Midnight Mall Project — Internal Design Document
