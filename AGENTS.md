# AGENTS.md — AI Coding Agent Instructions

This file provides specific instructions for AI coding agents working on the Midnight Mall project.

---

## 🛠️ Dev Environment Tips

### Initial Setup
```bash
# Clone and navigate to project
git clone https://github.com/blake-hedlin/midnight-mall.git
cd midnight-mall

# Install development tools
brew install aftman
aftman trust rojo-rbx/rojo JohnnyMorganz/StyLua Kampfkarren/selene UpliftGames/wally
aftman install

# Verify installation
rojo --version
stylua --version
selene --version
wally --version
```

### Starting Development Server
```bash
# Start Rojo sync server (required for Roblox Studio connection)
rojo serve
# Server will run at http://localhost:34872/

# In a separate terminal, you can format/lint while developing:
stylua src/
selene src/
```

### Project Structure Navigation
- **Game Logic (Server):** `src/ServerScriptService/`
  - `Systems/` - Core game systems (Clock, Loot, Barricade)
  - `NPC/` - Enemy AI and spawning logic
- **Shared Modules:** `src/ReplicatedStorage/`
  - `Items/` - Item definitions and registries
  - `Shared/` - Utilities, signals, constants
- **Client Scripts:** `src/StarterPlayer/StarterPlayerScripts/`
- **UI:** `src/StarterGui/`
- **Documentation:** `docs/`
  - `PRD.md` - Product requirements
  - `Planning/Sprint_1_planning.md` - Current sprint backlog

### Configuration Files
- `default.project.json` - Rojo project structure
- `aftman.toml` - Tool version management
- `.stylua.toml` - Code formatting rules
- `selene.toml` - Linter configuration

---

## 🧪 Testing Instructions

### Code Quality Checks

**Format Code:**
```bash
# Format all Lua files
stylua .

# Format specific directory
stylua src/ServerScriptService/Systems/
```

**Lint Code:**
```bash
# Lint all files
selene .

# Lint specific file
selene src/ServerScriptService/Systems/Clock.server.lua
```

**Build Project:**
```bash
# Build standalone .rbxl file for testing
rojo build --output build/MidnightMall.rbxl
```

### Testing in Roblox Studio

1. Ensure `rojo serve` is running
2. Open Roblox Studio
3. Click **Rojo → Connect** in the toolbar
4. Press **Play** to test locally
5. Verify against acceptance criteria in sprint backlog

### Validation Checklist

Before marking a story complete, verify:
- [ ] Code passes `stylua .` with no changes needed
- [ ] Code passes `selene .` with no errors
- [ ] Rojo sync completes without errors
- [ ] All acceptance criteria from sprint story are met
- [ ] Tested in Roblox Studio (solo mode)
- [ ] Tested in multiplayer mode if applicable
- [ ] No console errors or warnings
- [ ] Mobile viewport tested for UI changes

### Common Issues & Fixes

**Rojo sync fails:**
```bash
# Check if Rojo server is running
# Kill any existing Rojo processes and restart
pkill rojo
rojo serve
```

**Linter errors:**
```bash
# See specific error details
selene --display-style=rich src/

# Common fixes:
# - Add type annotations for function parameters
# - Remove unused variables
# - Follow naming conventions (PascalCase for modules)
```

---

## 📝 Pull Request Instructions

### PR Title Format
```
<type>(<scope>): <short description>

Types: feat, fix, docs, refactor, test, chore
Scope: system name (lighting, loot, barricade, hud, npc, etc.)

Examples:
feat(lighting): implement day/night cycle transitions
fix(loot): correct weighted item distribution
docs(sprint): update Story 1 completion status
refactor(barricade): extract placement validation to separate function
```

### Pre-Commit Checks

Run these commands before creating a PR:

```bash
# 1. Format code
stylua .

# 2. Lint code
selene .

# 3. Verify Rojo project builds
rojo build --output build/MidnightMall.rbxl

# 4. Test in Roblox Studio
# - Start rojo serve
# - Connect Studio and test gameplay
# - Verify acceptance criteria
```

### PR Description Template

```markdown
## Story Reference
Closes #[story-number] or references [docs/Planning/Sprint_1_planning.md](Story X)

## Changes
- Brief bullet points of what changed

## Testing
- [ ] Tested in Studio (solo)
- [ ] Tested in Studio (multiplayer if applicable)
- [ ] All acceptance criteria met
- [ ] No console errors

## Screenshots/Videos
[Optional: Add screenshots or video of feature working]
```

### Required PR Checks

- ✅ Code formatted with StyLua
- ✅ No Selene linter errors
- ✅ Rojo build succeeds
- ✅ All sprint story acceptance criteria met
- ✅ Updated sprint checklist if applicable
- ✅ No breaking changes to existing systems
- ✅ Server-authoritative validation in place for game-critical logic

### Review Guidelines

When reviewing your own changes:
1. Does this follow the server-authoritative pattern?
2. Are client actions validated on the server?
3. Does this use existing signal infrastructure?
4. Is the code documented with comments explaining "why" not "what"?
5. Would this work correctly in a multiplayer scenario?

---

## 🎯 Workflow Summary

```bash
# 1. Pick a story from sprint backlog
# Read: docs/Planning/Sprint_1_planning.md

# 2. Create feature branch
git checkout -b feat/story-name

# 3. Develop & test iteratively
rojo serve &
# Edit files in src/
# Test in Studio
# Verify acceptance criteria

# 4. Quality checks
stylua .
selene .
rojo build --output build/MidnightMall.rbxl

# 5. Commit with conventional format
git add .
git commit -m "feat(system): description"

# 6. Push and create PR
git push origin feat/story-name
# Create PR on GitHub with proper template

# 7. Update sprint checklist
# Mark completed items in docs/Planning/Sprint_1_planning.md
```

---

## 📚 Additional Resources

- [README.md](README.md) - Project overview and goals
- [claude.md](claude.md) - Claude-specific development guidelines
- [docs/PRD.md](docs/PRD.md) - Product requirements document
- [docs/Planning/Sprint_1_planning.md](docs/Planning/Sprint_1_planning.md) - Active sprint tasks

## 🎯 Acceptance Criteria (How to Decide "Done")

When implementing a story, it is complete when:
- Implementation matches the story's acceptance list verbatim
- No Studio errors/warnings during a 60-second play test
- New code documented inline with comments explaining "why" not "what"
- Backlog story checklist updated in `docs/Planning/Sprint_1_planning.md`
- Cross-system hooks (events/listeners) wired correctly
- Server-authoritative validation in place for game-critical logic
- Mobile viewport tested for UI changes (if applicable)

---

## 🚫 Safe Failure Policy

### When Context is Missing
- **Don't invent values or behaviors** - Leave clear TODO comments instead
- Search existing code for similar patterns first
- Check documentation in `/docs` before making assumptions

### Example Safe Failure
```lua
-- TODO: Missing reference to EnemySpawner module
-- Skipping enemy damage integration until ServerScriptService/NPC/EnemySpawner.lua is defined
-- Story requires: enemies deal damage to barricades on collision
```

### Never Do
- Never delete `/docs` or `/assets` folders
- Never modify unrelated files outside the story scope
- Never hard-code player state (use shared data models)
- Never commit code that breaks existing functionality

### Prefer
- Adding small, reversible modules over editing large existing ones
- Failing safely with clear comments over guessing behavior
- Asking for clarification over implementing assumptions

---

## 📝 Coding Rules

### Module Structure
- Keep files under 200 lines when possible; split into submodules for clarity
- Module naming: `PascalCase` files; functions `camelCase`; constants `SCREAMING_SNAKE_CASE`
- Emit debug logs with module prefix: `print("[LightingController] Day started")`

### Architecture Principles
- No hard-coded player state; use shared data models in `ReplicatedStorage/`
- Server validates all game-critical actions (placement, loot, damage)
- Client sends requests; server authorizes and broadcasts results
- Use signal-based events from `ReplicatedStorage/Shared/Signals.lua`

### Code Quality
- Prefer dependency injection over global requires where practical
- Document "why" not "what" in comments
- Use type annotations for function parameters where helpful
- Follow existing patterns in similar systems

---

**Last Updated:** October 2025
**For:** AI coding agents (Claude Code, GitHub Copilot, Cursor, etc.)
