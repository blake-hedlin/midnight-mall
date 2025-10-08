# Sprint 1 — Testing Plan
**Version:** 1.0
**Date:** October 2025
**Purpose:** Comprehensive testing checklist for all Sprint 1 MVP systems

---

## 🎯 Pre-Test Setup

### Required Tools
- [ ] Roblox Studio installed and updated
- [ ] Terminal/Command prompt open
- [ ] Project directory: `/Users/blake/Documents/Roblox/midnight-mall`

### Launch Procedure
1. Open terminal and navigate to project directory
2. Run: `rojo serve`
3. Wait for: `Server listening on port 34872`
4. Open Roblox Studio
5. Click "Connect" in Rojo plugin (or File → Rojo → Connect to localhost)
6. Verify connection: Console should show "Connected to Rojo"
7. Press **F5** or click **Play** button

---

## 📋 System Testing Checklist

---

### **Test 1: Environment Generation (Story 7)**
**Goal:** Verify mall structure generates correctly

#### Visual Inspection
- [ ] **Atrium exists** — Gray floor, 4 walls, open center
- [ ] **Toy Galaxy (West)** — Purple-tinted room connected to Atrium
- [ ] **Food Court (East)** — Red-tinted room connected to Atrium
- [ ] **Maintenance Corridor (South)** — Black narrow hallway below Atrium
- [ ] **Security Office (North)** — Gray room above Atrium

#### Tagged Objects Count
- [ ] **4 green spawn pads** in Atrium (semi-transparent)
- [ ] **6 orange crates** across zones (3 in Toy Galaxy, 2 in Food Court, 1 in Security)
- [ ] **3 red barricade anchors** at doorways (glowing transparent)
- [ ] **3 red enemy spawn pads** in Maintenance Corridor

#### Console Output Check
Open Output panel (`View → Output`) and verify:
```
[MallBuilder] Starting mall construction...
[MallBuilder] Mall construction complete!
[MallBuilder] - Atrium: 4 spawn points
[MallBuilder] - Toy Galaxy: 3 loot crates, 1 barricade anchor
[MallBuilder] - Food Court: 2 loot crates, 1 barricade anchor
[MallBuilder] - Maintenance Corridor: 3 enemy spawns
[MallBuilder] - Security Office: 1 loot crate, 1 barricade anchor
```

#### Expected Issues
- **If mall doesn't appear:** Check Workspace Explorer for "MallGreybox" folder
- **If spawns are missing:** Check for "AtriumSpawns" folder in Workspace root

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 2: Spawn & Respawn System (Story 6)**
**Goal:** Verify player spawning and death queue

#### Initial Spawn
- [ ] Player spawns at one of the 4 green spawn pads
- [ ] Spawn location is randomized (test by rejoining multiple times)
- [ ] Player spawns 3 studs above spawn pad (not clipping through)

#### Death & Respawn Queue
1. [ ] Walk to Maintenance Corridor
2. [ ] Type in command bar: `game.Players.LocalPlayer.Character.Humanoid.Health = 0`
3. [ ] Observe: Character dies and screen fades
4. [ ] **Check console:** Should print `[Spawn] Respawn queued for player`
5. [ ] Wait for day/night transition (or skip time — see Time Skip section)
6. [ ] **At dawn:** Player should respawn after 5 seconds
7. [ ] **Check console:** Should print `[Spawn] Day started, respawning X queued players in 5 seconds`
8. [ ] **Check console:** Should print `[Spawn] Respawned player: [YourUsername]`

#### Inventory Reset on Death
- [ ] Collect items before dying
- [ ] Die and respawn
- [ ] **Verify:** Inventory resets to 0 wood/snack/battery

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 3: Lighting System (Stories 1 & 8)**
**Goal:** Verify Day/Night lighting transitions

#### Day Phase (Initial)
- [ ] **Ambient lighting:** Bright and clear
- [ ] **Fog:** Minimal (can see far)
- [ ] **Color tone:** Warm white/yellow
- [ ] **Time display:** Shows "Day 1 — XXs left"
- [ ] **Time frame color:** Blue background

#### Console Output
```
[LightingController] Applying preset - Ambient: [200, 200, 200]
[LightingController] Lighting tween started
[LightingController] ColorCorrection tween started
```

#### Night Phase Transition
Wait ~2 minutes (or use time skip below), then observe:
- [ ] **Banner appears:** "🌙 NIGHT FALLS 🌙" fades in and out
- [ ] **Ambient darkens:** Heavy red fog appears
- [ ] **Visibility:** Fog End reduces to ~80 studs
- [ ] **Color tone:** Red/purple tint
- [ ] **Time display:** Shows "Night 1 — XXs left"
- [ ] **Time frame color:** Purple background

#### Dawn Transition
Wait ~1 minute, then observe:
- [ ] **Banner appears:** "☀️ DAY BREAK ☀️" fades in and out
- [ ] **Lighting returns to day preset**
- [ ] **Time display:** Shows "Day 2 — XXs left"

#### Console Output
```
[Clock] State changed to: Night | Night count: 1
[Clock] NightStarted signal fired
[LightingController] NightStarted received, applying Night preset
[Mannequin] Night 1 - spawning enemies
```

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 4: Loot System (Story 2)**
**Goal:** Verify loot interaction and per-crate lockout

#### Loot Interaction
1. [ ] Walk to any orange crate
2. [ ] **ProximityPrompt appears:** "Loot (Hold E)"
3. [ ] Hold **E** for 0.5 seconds
4. [ ] **Feedback appears** in time label: "Found wood x1" (or snack/battery)
5. [ ] **HUD updates:** Inventory count increases (e.g., "🪵 Wood: 1")
6. [ ] **Crate changes:** Transparency increases to 0.7 (appears ghostly)
7. [ ] **Prompt disables:** Can no longer interact with crate

#### Weighted Randomness
- [ ] Loot 6 different crates (if available)
- [ ] **Expected distribution:** ~55% wood, ~27% snack, ~18% battery
- [ ] **Verify variety:** Not all crates give the same item

#### Per-Crate Lockout
- [ ] Try looting the same crate again
- [ ] **Verify:** Prompt is disabled (no interaction possible)
- [ ] Loot a different crate
- [ ] **Verify:** Second crate works fine

#### Day Reset
1. [ ] Loot all crates in Toy Galaxy
2. [ ] Wait for next day cycle (or skip time)
3. [ ] **Verify:** All crates reset (transparency back to 0, prompt re-enabled)
4. [ ] **Check console:** `[Loot] All crates reset for new day`

#### Console Output
```
[LootRegistry] Item: wood, Amount: 1, Player: [Username]
```

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 5: Barricade System (Story 3)**
**Goal:** Verify ghost preview, placement, and durability

#### Prerequisites
- [ ] Collect at least 3 wood from loot crates

#### Ghost Preview Mode
1. [ ] Press **B** key to toggle preview mode
2. [ ] **Check console:** `[BarricadePreview] Preview mode ON`
3. [ ] **Verify:** Semi-transparent board appears in front of you
4. [ ] Walk near a red barricade anchor
5. [ ] **Preview turns GREEN** when near anchor and placement is valid
6. [ ] Walk away from anchor
7. [ ] **Preview turns RED** or disappears when invalid
8. [ ] Press **B** again to toggle off
9. [ ] **Check console:** `[BarricadePreview] Preview mode OFF`

#### Placement
1. [ ] Press **B** to enter preview mode
2. [ ] Stand near a barricade anchor until preview is GREEN
3. [ ] Click **Left Mouse Button** to place
4. [ ] **Verify:** Wood count decreases by 1
5. [ ] **Verify:** Solid brown board appears at anchor location
6. [ ] **Verify:** Board has collision (try walking through it)
7. [ ] **Check console:** `[BarricadePreview] Placement requested`
8. [ ] **Check console:** `[Barricade] Board placed with durability: [3-5]`

#### Placement Validation
- [ ] Try placing at same anchor again
- [ ] **Verify:** Preview turns RED (already barricaded)
- [ ] **Verify:** Feedback: "Already barricaded"

#### Durability System
1. [ ] Place a barricade
2. [ ] **Note the durability** from console output (3, 4, or 5)
3. [ ] Wait for night and let an enemy attack it
4. [ ] **Check console:** Each attack prints `[Mannequin] Damaged board, durability remaining: X`
5. [ ] **Verify:** After 3-5 hits, board is destroyed
6. [ ] **Check console:** `[Barricade] Board destroyed at anchor`

#### Repair System
1. [ ] Place a barricade and let it take 1-2 hits
2. [ ] Collect wood if needed
3. [ ] Approach damaged board
4. [ ] **ProximityPrompt should still be on anchor**
5. [ ] Try interacting with anchor again
6. [ ] **Expected:** "Need 1 wood to repair" OR repair happens
7. [ ] **Check console:** `[Barricade] Board repaired to durability: X`

#### Fallback ProximityPrompt
- [ ] Some barricade anchors have ProximityPrompts as fallback
- [ ] **Verify:** Holding E near anchor places barricade (if not using B key mode)

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 6: Enemy AI (Story 4)**
**Goal:** Verify enemy spawn, pathfinding, and attack behavior

#### Prerequisites
- [ ] Place at least 1 barricade before night
- [ ] Wait for night cycle

#### Spawn Behavior
1. [ ] Wait for "🌙 NIGHT FALLS 🌙" banner
2. [ ] **Check console:** `[Mannequin] Night X - spawning enemies`
3. [ ] **Check console:** `[Mannequin] Spawned enemy #1`, `#2`, etc.
4. [ ] **Verify:** 2-3 mannequin models appear in Maintenance Corridor
5. [ ] **Visual check:** Each has gray torso + white ball head

#### Pathfinding
- [ ] Enemies walk toward your position
- [ ] **Verify:** They navigate around walls (not clipping)
- [ ] **Verify:** Humanoid moves smoothly (WalkSpeed ~8)

#### Attack Behavior
1. [ ] Let an enemy reach your barricade
2. [ ] **Verify:** Enemy stops near board
3. [ ] **Check console:** `[Mannequin] Damaged board, durability remaining: X`
4. [ ] **Verify:** Attacks happen every ~2 seconds
5. [ ] **Verify:** After 3-5 hits, board is destroyed

#### Despawn at Dawn
1. [ ] Wait for day transition
2. [ ] **Check console:** `[Mannequin] Day started - despawning enemies`
3. [ ] **Verify:** All mannequins disappear instantly
4. [ ] **Check console:** `[Mannequin] All enemies despawned for day`

#### Edge Cases
- [ ] **No spawn points:** If no `EnemySpawn` tags exist, console should warn
- [ ] **Enemy death:** Manually kill a mannequin (set Health = 0), verify it despawns

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 7: HUD System (Story 5)**
**Goal:** Verify HUD elements and real-time updates

#### Initial Display
- [ ] **Top-left time frame:** "Day 1 — 120s left" (blue background)
- [ ] **Inventory frame below:** Shows 4 items with emoji icons
  - 🪵 Wood: 0
  - 🍫 Snack: 0
  - 🔋 Battery: 0
  - 🪙 Coins: 0

#### Inventory Updates
1. [ ] Loot a crate
2. [ ] **Verify:** Inventory count updates instantly (no delay)
3. [ ] **Verify:** Correct item increments
4. [ ] Place a barricade (consumes wood)
5. [ ] **Verify:** Wood count decreases by 1

#### Time Display
- [ ] **During day:** Shows countdown from 120s to 0s
- [ ] **During night:** Shows countdown from 60s to 0s
- [ ] **Night counter increments:** "Night 1" → "Night 2" → etc.

#### Transition Banners
- [ ] **At night start:** "🌙 NIGHT FALLS 🌙" appears in center
- [ ] **Animation:** Fades in (0.5s) → stays (2s) → fades out (0.5s)
- [ ] **Color:** Purple/white text
- [ ] **At day start:** "☀️ DAY BREAK ☀️" appears
- [ ] **Color:** Yellow/orange text

#### Dynamic Frame Colors
- [ ] **Day:** Time frame background is blue (RGB 100, 150, 255)
- [ ] **Night:** Time frame background is purple (RGB 40, 20, 60)

#### Feedback Messages
- [ ] Loot a crate
- [ ] **Verify:** Time label briefly shows "Found wood x1"
- [ ] **Verify:** Reverts to time display after 1.5 seconds
- [ ] Try placing barricade with no wood
- [ ] **Verify:** Shows "Need 1 wood to barricade"

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

### **Test 8: Currency System (Story 10)**
**Goal:** Verify coins tracking and shop UI

#### Coins Display
- [ ] **Check HUD:** Shows "🪙 Coins: 0" initially
- [ ] **Check PlayerGui:** Coins IntValue should exist under player

#### Manual Coin Award (Testing Only)
1. [ ] Open command bar (View → Command Bar)
2. [ ] Type: `_G.CurrencySystem.awardCoins(game.Players.LocalPlayer, 10)`
3. [ ] Press Enter
4. [ ] **Verify:** HUD shows "🪙 Coins: 10"
5. [ ] **Check console:** `[Currency] Player [Username] coins updated to 10`

#### Shop Button
- [ ] **Top-right corner:** "🛒 Shop" button exists
- [ ] Click the button
- [ ] **Verify:** Shop panel opens in center of screen
- [ ] **Panel shows:** "🛒 Shop (Coming Soon)"
- [ ] **Panel shows:** Placeholder text: "Shop items will be available in Sprint 2..."
- [ ] Click the **✕** button
- [ ] **Verify:** Panel closes

#### Shop Panel Toggle
- [ ] Click shop button again
- [ ] **Verify:** Panel opens
- [ ] Click shop button while open
- [ ] **Verify:** Panel closes (toggle behavior)

**Status:** ✅ Pass / ❌ Fail
**Notes:**

---

## 🔧 Debugging Tools

### Time Skip (For Fast Testing)
To skip to night immediately:
```lua
-- In Command Bar
local Clock = require(game.ReplicatedStorage.Shared.Clock)
Clock.time = Clock.dayLength - 1
```

To force night transition:
```lua
-- In Command Bar
game.ReplicatedStorage.Signals.NightStarted:Fire(1)
```

### Give Yourself Items
```lua
-- In Command Bar
local player = game.Players.LocalPlayer
local inv = player:FindFirstChild("Inventory") or Instance.new("Folder", player)
inv.Name = "Inventory"
local wood = inv:FindFirstChild("wood") or Instance.new("IntValue", inv)
wood.Name = "wood"
wood.Value = 10
```

### Teleport to Zones
```lua
-- Atrium
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)

-- Toy Galaxy
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-70, 5, 0)

-- Food Court
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(70, 5, 0)

-- Maintenance Corridor
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, -50)
```

### Kill All Enemies
```lua
-- In Command Bar
for _, enemy in ipairs(workspace:GetChildren()) do
  if enemy.Name == "Mannequin" then
    enemy:Destroy()
  end
end
```

### Check Tags on Objects
```lua
-- In Command Bar (checks LootCrate tags)
local CollectionService = game:GetService("CollectionService")
print("LootCrates:", #CollectionService:GetTagged("LootCrate"))
print("BarricadeAnchors:", #CollectionService:GetTagged("BarricadeAnchor"))
print("EnemySpawns:", #CollectionService:GetTagged("EnemySpawn"))
```

---

## 🐛 Common Issues & Solutions

### Issue: Mall doesn't spawn
**Solution:**
- Check Output for errors in MallBuilder.server.lua
- Verify Workspace hierarchy in Explorer
- Restart Rojo connection and reload place

### Issue: No ProximityPrompts on crates
**Solution:**
- Check CollectionService tags (see debugging command above)
- Verify Loot.server.lua is running (check Output)
- Manually add tag via command: `game:GetService("CollectionService"):AddTag(workspace.MallGreybox.ToyGalaxy.LootCrate, "LootCrate")`

### Issue: Barricade preview doesn't appear
**Solution:**
- Check console for errors when pressing B
- Verify BarricadePreview.client.lua is in StarterPlayerScripts
- Check that Signals module exists in ReplicatedStorage

### Issue: Enemies don't spawn at night
**Solution:**
- Verify EnemySpawn tags exist (see debugging command)
- Check console for: `[Mannequin] No spawn points tagged with 'EnemySpawn'`
- Check NightStarted signal is firing (Output shows `[Clock] NightStarted signal fired`)

### Issue: HUD doesn't update
**Solution:**
- Check PlayerGui for "HUD" ScreenGui
- Verify Signals module is accessible
- Check console for InventoryChanged signal errors

### Issue: Player spawns at (0, 0, 0)
**Solution:**
- Verify "AtriumSpawns" folder exists in Workspace root
- Check folder contains SpawnLocation instances
- Verify Spawn.server.lua console output

---

## ✅ Final Validation

### All Systems Integration Test
**Complete in one playthrough:**

1. [ ] Join game → Spawn in Atrium
2. [ ] Loot 3 crates → Collect wood/snacks/battery
3. [ ] Press B → Place 1 barricade at doorway
4. [ ] Wait for night → Banner appears, enemies spawn
5. [ ] Watch enemy attack barricade → Board durability decreases
6. [ ] Wait for day → Enemies despawn, crates reset
7. [ ] Open shop → View placeholder panel
8. [ ] Die → Respawn after 5 seconds at dawn

**If all steps pass, Sprint 1 MVP is complete!** 🎉

---

## 📊 Test Results Summary

| System | Status | Issues Found | Notes |
|:-------|:-------|:-------------|:------|
| Environment (Story 7) | ⬜ | | |
| Spawn/Respawn (Story 6) | ⬜ | | |
| Lighting (Stories 1 & 8) | ⬜ | | |
| Loot (Story 2) | ⬜ | | |
| Barricade (Story 3) | ⬜ | | |
| Enemy AI (Story 4) | ⬜ | | |
| HUD (Story 5) | ⬜ | | |
| Currency (Story 10) | ⬜ | | |

**Overall Status:** ⬜ Pass / ⬜ Pass with Issues / ⬜ Fail

---

## 📝 Notes & Observations

(Use this section to document any bugs, performance issues, or improvements needed)

---

**Tester:** ________________
**Date:** ________________
**Roblox Studio Version:** ________________
**Rojo Version:** ________________
