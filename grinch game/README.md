# Steal Christmas (working title) — Phase 1

A Roblox stealth heist game: a grumpy, holiday-hating creature sneaks into a
snowy town on Christmas Eve to steal presents. The character, dog, town
(**Tinselbrook**) and all buildings are original designs.

**Phase 1** builds the town, the menus and the music system. Stealing, NPCs,
security, the sleigh and the economy come in later phases.

---

## How to open it in Roblox Studio

### Option A: open the ready-made place file (easiest)
1. Download `StealChristmas.rbxlx` from this folder.
2. In Roblox Studio, go to **File → Open from File** and pick it.
3. Optional, for nicer lighting: select **Lighting** in the Explorer and set
   **Technology** to **Future**.
4. Press **Play**. The town is generated when the server starts. The Output
   window shows `[World] ... built in ...` for each area.
5. **File → Publish to Roblox** to save it as your own place.

If you change any `.luau` file, rebuild the place file:

```bash
python3 tools/build_place.py
```

### Option B: live sync with Rojo (for ongoing development)
1. Install Rojo (https://rojo.space) and its Studio plugin.
2. In this folder, run:

```bash
rojo serve
```

3. In Studio, open the Rojo plugin and click **Connect**.

`default.project.json` maps `src/` into the game.

---

## What's in Phase 1

| Area | Status |
|---|---|
| **A. Town center** | Plaza with a 64-stud decorated tree (ornaments, spiral lights, spinning star), 8 lit garlands, 8 shops with 4 roof styles, benches, lampposts, snowmen, street signs, light arches over every street |
| **B. Starter neighborhood (Holly Lane)** | 5 different houses: Holly Cottage, Crooked Spire, Gingerbread Lodge, Twin Domes, Curlicue Townhouse. Yards have fences, mailboxes, trees, driveways and decorations. Ends in a cul-de-sac |
| **Holly Cottage interior** | Living room (fireplace, stockings, sofa, Christmas tree with presents), hallway, kitchen (counters, stove, fridge, table and cookies), bedroom and den. The front door is open so you can walk in |
| **C. Gated community** | Gate with pillars, iron gate, name arch, guard booth, barrier arm and boundary walls. The gate is closed; lots inside are reserved for later |
| **D. Mansion district** | Ornate gilded gate, tree avenue and boundary walls. Closed; reserved for later |
| **E. Mountain hideout** | Switchback trail up the mountain to a cave workshop: workbench, tools, sleigh storage platform, dog bed, stove, loot pile, and a lookout deck with a telescope |
| **Main menu** | STEAL CHRISTMAS title, cinematic camera over the town, falling snow, animated candy buttons, fade and slide transitions, scales to desktop and mobile screens |
| **Mission select** | Cards for The First House ($500), Silent Night ($1,500), The Mansion Heist ($5,000) and Free Roam. Only **Free Roam** is playable; the others say "LOCKED / SOON" |
| **Party menu** | 4 slots, leader crown, Invite Friends (opens the real Roblox invite prompt), Ready toggle, privacy picker, Continue to Missions. Party sync is labeled as a preview |
| **Upgrades** | Preview cards (Reinforced Sleigh $2,500 and more), shown as locked |
| **Settings** | Music on/off, volume slider, snowfall quality (Off/Low/Medium/High), animated lights on/off |
| **Free Roam** | Spawns you in the plaza. A MENU button takes you back to the menu |

### Music: one step for you
Music needs audio you're allowed to use, so the track IDs start out empty.
1. In Studio, open **Toolbox → Audio** (or the Creator Store) and find
   instrumental Christmas tracks that are licensed for use. Roblox's own
   licensed music library works.
2. Paste the asset IDs into `src/shared/Config/Audio.luau`, for example
   `SoundId = "rbxassetid://123456789"`.
   - `Menu` and `Outside` are used now.
   - `Inside` (sneaky), `Detected` (chase) and `Victory` are already wired up
     for later phases. `Inside` plays automatically inside Holly Cottage once
     you give it a track.

Until you add tracks, the Settings screen says that no music is set up.

---

## Hooks for later phases

The map includes invisible markers (CollectionService tags) so later systems
can be added without rebuilding the map:

- `PresentSpot` (16, with a room name): where presents will spawn inside Holly Cottage
- `ChimneyEntry`: tops of chimneys, for sneaking in
- `FutureDoor`, `FutureGate`: doors and gates that will become interactive
- `CameraMount`: security camera positions on the gate pillars
- `FutureLot`: reserved house lots in the gated and mansion districts
- `SleighStorage`, `SleighLaunch`, `SleighPath` (attribute on roads): sleigh parking, take-off point and drivable surfaces. Roads are 30 studs wide for turning
- `UpgradeBench`, `LootDropZone`: hideout workshop and loot unloading spot
- `InteriorZone`: switches the music to "Inside"
- `FreeRoamHUD.SleighHUDSlot`: space kept at the bottom center for the speedometer and gift meter

---

## How it was tested

- All 32 Luau files compile with the official Luau compiler.
- The whole world builder ran headless against a mock Roblox engine:
  6,749 parts, 227 lights, 0 errors.
- Automated walk checks inside Holly Cottage: front door → hallway → living
  room, den, kitchen, fridge, bedroom. Every path is clear for a character.
- No house or shop overlaps a road or another building.

### Not tested yet (needs a real Roblox Studio run)
This was built without Studio access, so these need a check when you first
press Play:
- **How it looks**: colors, lighting, the giant tree, house details.
- **Gable roof ends** (triangles on the cottage, gingerbread house and some
  shops): if they appear upside down, flip the rotation in
  `Builder.gableRoof` (`src/server/World/Builder.luau`). This depends on
  which way Roblox wedges face, which couldn't be confirmed without Studio.
- Menu navigation on desktop and on Studio's phone emulator.
- Free Roam spawning and the walk up Summit Trail to the hideout.
- Frame rate on low-end and mobile devices. Snowfall and animated lights can
  be turned down in Settings.
- Settings reset each session. Saving them comes with the progression phase.

## Folder layout

```
src/
  shared/          Config (missions, economy, audio, layout) + Remotes
  server/
    Main.server    builds the world, starts services
    World/         Builder, Props, Environment (terrain/roads/lighting),
                   TownCenter, Houses, HouseParts, Interior, Districts, Hideout
    Services/      PlayerService (menu <-> Free Roam)
  client/
    Main.client    starts effects + menu
    UI/            Theme, MenuController, Screens/*
    Audio/         MusicController (states + crossfade), MusicZones
    Effects/       Snowfall, LightAnimator
    MenuCamera, Settings
tools/build_place.py   generates StealChristmas.rbxlx
```
