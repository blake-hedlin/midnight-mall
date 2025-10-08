# Midnight Mall — Starter

A vibe-coding Roblox project scaffold for the **Midnight Mall** concept.

## Quick start
1. Install Roblox Studio and the Rojo plugin.
2. macOS:
   ```bash
   brew install aftman/tap/aftman
   aftman install
   rojo serve
   ```
3. In Roblox Studio: Rojo → Connect.
4. Press Play. You should spawn and see HUD + logs.
5. Edit code in `src/**`. Rojo syncs changes live.

## Scripts overview
- `Systems/Clock.server.lua`: Day/Night state machine with simple signals.
- `Items/LootRegistry.lua`: Weighted loot table and proximity prompt hookup.
- `Systems/Barricade.server.lua`: Place a basic board on anchors during day.
- `NPC/Mannequin.server.lua`: Stubbed AI hooks for Sprint 2.
- `StarterPlayer/StarterPlayerScripts/ClientHUD.client.lua`: HUD for time + inventory.
- `StarterGui/HUD/Init.client.lua`: Bootstraps HUD elements.

## Dev commands
```bash
stylua .
selene .
rojo build --output build/MidnightMall.rbxl
```

## Next
- Fill in store shells and anchors in Studio.
- Implement enemy AI and spawner in Sprint 2.
- Add a tutorial overlay in HUD.
