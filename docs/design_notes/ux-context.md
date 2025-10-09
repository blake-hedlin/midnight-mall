# /docs/ux-context.md — Midnight Mall (Roblox‑specific UX Context)

> **Purpose**: A single source of truth for Claude/Cursor to keep visuals, motion, and interaction patterns consistent across stories. **All stories must reference this file.**

## 1) Visual Tone & Theme
- **Mood arc**: Calm blue **Day** → ominous red‑tinted **Night** → cold, washed **Dawn** relief.
- **Aesthetic**: Cinematic survival; soft neon accents; minimal HUD.

## 2) Color & Lighting Tokens (Roblox)
Use these tokens, never hardcode values in stories. Access via `LightingPresets` module.

```lua
-- ReplicatedStorage/Shared/LightingPresets.lua (authoritative reference)
return {
  Day = {
    Ambient = Color3.fromRGB(180, 190, 210),
    OutdoorAmbient = Color3.fromRGB(180, 190, 210),
    FogColor = Color3.fromRGB(190, 210, 230),
    FogStart = 80,
    FogEnd = 800,
    ColorShift_Top = Color3.fromRGB(180, 190, 210),
    ColorShift_Bottom = Color3.fromRGB(160, 170, 190),
    Brightness = 2.0,
    ExposureCompensation = 0,
  },
  Night = {
    Ambient = Color3.fromRGB(25, 20, 30),
    OutdoorAmbient = Color3.fromRGB(25, 20, 30),
    FogColor = Color3.fromRGB(120, 20, 20), -- subtle red fog
    FogStart = 40,
    FogEnd = 260,
    ColorShift_Top = Color3.fromRGB(120, 110, 140),
    ColorShift_Bottom = Color3.fromRGB(80, 70, 90),
    Brightness = 1.3,
    ExposureCompensation = -0.35,
  },
  Dawn = {
    Ambient = Color3.fromRGB(120, 130, 160),
    OutdoorAmbient = Color3.fromRGB(120, 130, 160),
    FogColor = Color3.fromRGB(170, 180, 200),
    FogStart = 60,
    FogEnd = 600,
    ColorShift_Top = Color3.fromRGB(150, 160, 180),
    ColorShift_Bottom = Color3.fromRGB(120, 130, 160),
    Brightness = 1.8,
    ExposureCompensation = -0.1,
  }
}
```

**Lighting transition durations** (used by `TweenService`):
- `TRANSITION_SHORT = 0.3` (UI banners)
- `TRANSITION_MED = 1.0` (HUD element fades)
- `TRANSITION_LONG = 1.5` (scene Day↔Night)

## 3) Typography & UI Scale
- **Font tokens (Enum.Font)**: `Font_Primary = GothamSemibold`, `Font_Body = Gotham`, `Font_Mono = Code`.
- **Sizes**: `FS_SM = 14`, `FS_MD = 18`, `FS_LG = 24`, `FS_XL = 32`.
- **Mobile safe**: UIScale bound to min(viewport.x, viewport.y). Maintain 24 px tap targets.

## 4) Motion Tokens (TweenService)
- **Easing**: `Enum.EasingStyle.Quad`, `Enum.EasingDirection.InOut`.
- **Use**: `TWEEN_UI = 0.3`, `TWEEN_FEEDBACK = 0.15`, `TWEEN_SCENE = 1.5`.
- **Rules**: Never animate opacity and position with different timings on the same element.

## 5) UI Components & Naming
Use prefab components; do not invent new names.
- `UI_ButtonPrimary` — rounded 8 px, padding 12/16, shadow level 2.
- `UI_Banner` — full‑width top banner for state changes.
- `UI_IconPrimary` — 32×32 container, label below (FS_SM), 4 px gap.
- `UI_Panel` — 8 px padding, shadow level 1, auto layout vertical.
- `HUD_Root` — anchors icons bottom‑left, timer top‑right.

## 6) Audio Tokens
- `SFX_NightStart` (‑6 dB), `SFX_LootOpen` (‑10 dB), `SFX_BoardPlace` (‑8 dB), `SFX_EnemyHit` (‑8 dB).
- **Heartbeat loop** starts at NightStart, volume ramps from 0→0.4 over 3 s.

## 7) Camera Tokens
- 3rd person, `FOV = 70`, shoulder offset `(X=1.5, Y=1.2, Z=0)`; transitions with `TWEEN_SCENE`.

## 8) Accessibility
- Minimum text contrast 4.5:1; subtitles toggle; colorblind‑safe banner colors.
- Motion‑sensitive mode: reduce banner slide to fade‑only.

## 9) Interaction Templates
- **Loot Open**: E‑press → 0.15 s lid nudge, puff particle, `SFX_LootOpen`, HUD icon count increments with 0.15 s count‑up.
- **Barricade Place**: Ghost green/red; confirm → 0.2 s snap, `SFX_BoardPlace`.
- **Night Start**: `UI_Banner` slide 0.3 s + fade 1.0 s; heartbeat fade‑in 3 s; apply `LightingPresets.Night` over 1.5 s.

## 10) Signals & Data (Authoritative Names)
- `Signals.DayStarted`, `Signals.NightStarted`, `Signals.InventoryChanged`, `Signals.PlayerDied`.
- `Inventory.lua` API: `GetCount(player, itemId)`, `Add(player, itemId, amount)`.
- `Currency.lua` API: `GetCoins(player)`, `AddCoins(player, n)`.

## 11) Definition of Done (Visual)
- Verified on PC 1080p and mobile portrait.
- All colors/motion pull from tokens; no ad‑hoc timings.

---

# /docs/sprint1_ux_refactor.md — Sprint 1 (Claude‑ready)

> **Read me first**: Every story below begins with an **Experience Beat** (narrative), then a **Claude Prompt** that includes concrete acceptance criteria, sequence links, and a UX element checklist. All prompts assume `/docs/ux-context.md` is loaded in context.

## UX Anchor — Core Loop
**Arc**: Day → Loot → Barricade → Night → Survive → Dawn.
- Day is exploration and prep; Night is urgent defense; Dawn is release.
- Maintain consistent palettes, motion, and sounds per `/docs/ux-context.md`.
