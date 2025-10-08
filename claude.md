# Claude Code Guidelines — Midnight Mall

This document provides guidelines for Claude Code when working on the Midnight Mall project.

---

## 🎯 Project Context

**What:** Co-op survival game set in an abandoned mall (Roblox)
**Goal:** Deliver MVP core loop in 3–4 weeks with high retention and polish
**Tech:** Luau + Rojo + server-authoritative architecture

**Key Documents:**
- [README.md](README.md) - Project overview and setup
- [docs/PRD.md](docs/PRD.md) - Product requirements
- [docs/Planning/Sprint_1_planning.md](docs/Planning/Sprint_1_planning.md) - Active sprint backlog

---

## 🧠 Development Principles

### Server-Authoritative Design
- All game logic runs on the server
- Client sends requests; server validates and broadcasts results
- Never trust client input for critical actions (placement, loot, damage)

### Signal-Based Events
- Use `ReplicatedStorage/Shared/Signals.lua` for cross-script communication
- Server fires signals for state changes (DayStarted, NightStarted, ItemLooted)
- Clients listen and update UI/visuals reactively

### Module Structure
```
src/
├── ServerScriptService/     # Server-only game logic
│   ├── Systems/             # Core systems (Clock, Loot, Barricade)
│   └── NPC/                 # AI and enemy logic
├── ReplicatedStorage/       # Shared modules (client + server)
│   ├── Items/               # Item definitions and registries
│   └── Shared/              # Utilities, signals, constants
├── StarterGui/              # UI elements
└── StarterPlayer/
    └── StarterPlayerScripts/ # Client-side scripts
```

---

## 📝 Code Conventions

### File Naming
- Server scripts: `*.server.lua`
- Client scripts: `*.client.lua`
- Modules: `*.lua` (PascalCase)

### Luau Style
- Use StyLua for formatting: `stylua .`
- Run Selene for linting: `selene .`
- Type annotations preferred for public APIs
- Descriptive variable names (no single letters except loops)

### Comments
- Document "why" not "what"
- Use `-- TODO:` for planned improvements
- Add context for non-obvious logic

---

## 🔄 Workflow

### Working on Stories

1. **Check Sprint Backlog:** Reference `docs/Planning/Sprint_1_planning.md` for current tasks
2. **Read Acceptance Criteria:** Each story has specific Definition of Done
3. **Implement:** Write code in `src/` following existing patterns
4. **Test:** Verify against Test Plan in story
5. **Update Checklist:** Mark story checklist items complete

### Commit Messages

Use conventional commits format:

```
<type>(<scope>): <subject>

Types: feat, fix, docs, refactor, test, chore
Scope: system name (lighting, loot, barricade, hud, etc.)

Examples:
feat(lighting): implement day/night cycle transitions
fix(loot): correct item weight distribution
docs(sprint): update Story 1 acceptance criteria
refactor(barricade): extract placement validation logic
```

### Testing

- Test in Roblox Studio with `rojo serve` running
- Verify all acceptance criteria before marking story complete
- Check both solo and multiplayer scenarios where applicable
- Test on mobile viewport for UI changes

---

## 🚫 Constraints

### Do Not:
- Modify `docs/` without explicit request (planning docs are source of truth)
- Add dependencies without discussing (keep it lean)
- Implement Robux/GamePass APIs in Sprint 1 (scaffolding only)
- Use client-side validation for game-critical logic
- Commit broken code (test first)

### Always:
- Follow server-authoritative pattern
- Use existing signal infrastructure
- Validate client inputs on server
- Update sprint checklists when completing work
- Write clear commit messages

---

## 🧩 System-Specific Guidance

### Lighting System
- Day/Night states managed by `Clock.server.lua`
- Presets stored in `ReplicatedStorage/Shared/LightingPresets.lua`
- Transition via signals: `DayStarted`, `NightStarted`

### Loot System
- Registry: `ReplicatedStorage/Items/LootRegistry.lua`
- Server script: `ServerScriptService/Systems/Loot.server.lua`
- Use CollectionService tags: `LootCrate`
- Weighted random selection, server-validated

### Barricade System
- Placement: `ServerScriptService/Systems/Barricade.server.lua`
- Use CollectionService tags: `BarricadeAnchor`
- Ghost preview client-side, server validates placement
- Durability tracked server-side with IntValue

### HUD System
- Client bootstrap: `StarterGui/HUD/Init.client.lua`
- Updates: `StarterPlayer/StarterPlayerScripts/ClientHUD.client.lua`
- Listen to server signals for state changes
- Update inventory/time displays reactively

---

## 📊 Analytics Integration (Future)

Sprint 1 scaffolds data collection points:
- Session start/end
- Day/Night transitions
- Loot interactions
- Barricade placements
- Player deaths/revives

DataStore/MemoryStore integration planned for Sprint 2.

---

## 🎯 Current Sprint Focus

**Sprint 1:** Core Loop MVP + Monetization Hooks

Priority order:
1. Day/Night cycle with lighting
2. Loot system with inventory
3. Barricade placement system
4. Basic enemy AI stub
5. HUD with time/inventory display
6. Currency scaffolding (non-functional)

See [docs/Planning/Sprint_1_planning.md](docs/Planning/Sprint_1_planning.md) for detailed stories.

---

## 🤝 Collaboration Notes

- Ask clarifying questions before implementing ambiguous requirements
- Suggest improvements to system design when appropriate
- Flag potential performance issues early
- Recommend testing strategies for complex features

---

## 📘 Required Reading Order

When starting work on this project, read in this order:

1. [README.md](README.md) → Project overview and setup
2. [docs/PRD.md](docs/PRD.md) → Product requirements and goals
3. [docs/Planning/Sprint_1_planning.md](docs/Planning/Sprint_1_planning.md) → Current tasks
4. [claude.md](claude.md) (this file) → Development guidelines
5. [docs/design_notes/](docs/design_notes/) → Visual and UX references

---

## 🧱 Error-Handling Policy

### When Encountering Missing Context
- Search repository docs (`/docs`, `README.md`) before making assumptions
- Ask for clarification rather than inventing values
- Check existing code patterns in similar systems first

### When Stuck
- Reference the sprint backlog acceptance criteria
- Look for similar implementations in existing systems
- Fail safely with clear TODO comments:

```lua
-- TODO: Missing reference to EnemySpawner module
-- Skipping integration until ServerScriptService/NPC/EnemySpawner.lua is defined
```

### What Never To Do
- Never delete or rewrite core documentation folders (`/docs`)
- Never modify files outside of `src/` without explicit request
- Never commit untested code that breaks existing functionality
- Never invent system behaviors not specified in sprint stories

---

## 🧰 Tools & Environment

- **IDE:** Roblox Studio
- **Language:** Luau (typed Lua dialect)
- **Tooling:** Rojo, Aftman, StyLua, Selene, Wally
- **VCS:** GitHub (main branch)
- **AI Assistant:** Claude Code

---

**Last Updated:** October 2025
**Maintained By:** Blake Hedlin
**For:** Claude Code development assistance