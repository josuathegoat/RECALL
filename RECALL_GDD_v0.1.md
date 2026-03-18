# RECALL — Game Design Document (GDD)

**Working Title:** RECALL
**Tagline:** "Every memory fights back."
**Genre:** FPS PVE Horde Survival / Roguelite Hybrid
**Platform:** Roblox
**Developer:** Samuel (Boshi.AI)
**Version:** 0.1 — Prototype Blueprint
**Date:** March 18, 2026

---

## 1. GAME OVERVIEW

### 1.1 Concept

RECALL is a first-person shooter set inside fragmented childhood memories. Players fight through endless waves of corrupted nostalgia, wielding toy weapons against nightmarish versions of childhood objects. The game combines Krunker.io's fluid FPS movement with Vampire Survivors' escalating PVE chaos, wrapped in a visual style that pushes Roblox's graphical limits toward semi-realism.

### 1.2 Core Fantasy

You are trapped inside your own childhood memories. Each map is a different memory — a giant bedroom where you're toy-sized, a schoolyard at dusk, a crayon world that's come alive. The monsters are corrupted fragments of those memories. Your weapons are the toys you grew up with, now weaponized. Survive long enough, and the memory stabilizes. Fail, and it's lost forever.

### 1.3 Unique Selling Points

- **Movement system that IS the gameplay.** Wall bouncing, sliding, dashing, grappling — every mechanic feels fun on its own. Players will stay in lobbies just moving around.
- **Nostalgia-as-world-building.** Every map, weapon, and enemy ties to a childhood memory. This creates instant emotional resonance and viral shareability ("this map is literally my grandma's house").
- **No wave counter.** Unlike traditional horde games, enemies escalate continuously. There's no "Wave 15 Complete" screen — just an ever-rising tide that tests how long you can last.
- **Hybrid progression.** Per-run skill trees keep each session fresh (roguelite), while permanent unlocks reward long-term grinders (RPG).
- **Four revenue streams.** Battle Pass, limited events, VIP passes, and mystery boxes running simultaneously.

### 1.4 Player Modes

- **Solo** — Pure survival, you against the horde
- **Duos / Trios / Squad (4)** — Cooperative PVE, shared XP pool, revive mechanics
- **1v1 Ranked** — Competitive PvP with ELO rating and seasonal leaderboards
- **PVE Ranked** — Leaderboard for longest survival time per map, per squad size

---

## 2. GAMEPLAY SYSTEMS

### 2.1 Movement

This is the #1 retention driver. Movement must feel incredible even with zero enemies on screen.

**Core Movement:**

- **Run** — Base speed, always available
- **Sprint** — Hold shift, 40% speed boost, drains stamina
- **Slide** — While sprinting, press crouch. Maintains momentum, can slide under obstacles. 1.5s duration, 2s cooldown.
- **Double Jump** — Tap jump twice. Second jump = 70% height of first.
- **Dash** — Quick burst in any direction (forward/back/sides). 0.3s duration, 3s cooldown. Can be used mid-air.
- **Crouch** — Standard crouch, reduces hitbox, slower movement
- **Lean** — Peek left/right around corners without exposing full body

**Advanced Movement:**

- **Wall Slide** — Touch a wall while airborne, character slides down slowly. Can aim and shoot during wall slide.
- **Wall Bounce** — During wall slide, jump to launch off the wall with boosted momentum. Chainable between parallel walls.
- **Grapple Hook** — Equipment item (found in-map or from skill tree). Point at grapple points, pull yourself toward them. Momentum-based — you can release mid-swing for trick jumps.
- **Ziplines** — Fixed map elements. Jump on, ride across. Can shoot while ziplining. Jump off anytime for momentum boost.

**Movement Philosophy:** Every mechanic should combo into every other mechanic. Slide > Jump > Dash > Wall Bounce > Grapple should flow seamlessly. Think Titanfall 2 / Karlson movement in Roblox.

### 2.2 Combat

**Weapon Categories (all childhood-themed):**

- **Pistol Class:** Water Pistol, Nerf Pistol, Cap Gun, Finger Gun
- **Rifle Class:** Super Soaker, Nerf Blaster, Rubber Band Rifle, Pea Shooter
- **Shotgun Class:** T-Shirt Cannon, Confetti Blaster, Marshmallow Launcher
- **Sniper Class:** Slingshot, Paper Airplane Launcher, Straw Blowgun
- **Melee Class:** Butter Knife, Foam Sword, Wooden Spoon, Ruler, Pillow
- **Heavy/Special:** Potato Cannon, Firework Launcher, Lego Brick Cannon, Bubble Wand (AoE)

**Weapon Rarities:**

- Common (White) — Base stats
- Uncommon (Green) — +15% damage, one perk slot
- Rare (Blue) — +30% damage, two perk slots
- Epic (Purple) — +50% damage, three perk slots, unique visual
- Legendary (Gold) — +75% damage, three perk slots, unique VFX/SFX, animated model

**Combat Feel:**

- Generous hitboxes (PVE should feel satisfying, not punishing)
- Screen shake on hit (adjustable in settings)
- Hit markers with damage numbers
- Enemies react to hits (stagger, knockback)
- Headshot multiplier: 1.5x
- Weak spots on bosses (glowing, pulsing)

### 2.3 Enemy System

**Enemy Philosophy:** Enemies match the map's memory theme. Every map has its own bestiary.

**Enemy Types (per map, examples):**

**Giant Bedroom Map:**
- **Dust Bunnies** (fodder) — Fast, low HP, swarm in packs of 10-20
- **Sock Puppet** (ranged) — Spits projectiles from a distance
- **Wind-Up Soldier** (tank) — Slow, armored, charges in straight lines
- **Shadow Under the Bed** (elite) — Teleports, attacks from blind spots
- **The Closet Monster** (BOSS) — Multi-phase, fills room with darkness

**Schoolyard Map:**
- **Paper Airplane Swarm** (fodder) — Fast, fragile, come in waves
- **Bully** (melee brute) — Charges, ground pounds
- **Teacher's Pet** (support) — Buffs nearby enemies
- **Lunch Lady** (tank) — Throws trays, blocks paths
- **The Principal** (BOSS) — Summons detention zones, controls map space

**Crayon World Map:**
- **Scribble** (fodder) — Erratic movement, splits when killed
- **Crayon Golem** (tank) — Slow, leaves color trails that damage
- **Eraser** (elite) — Deletes cover/platforms temporarily
- **The Blank Page** (BOSS) — White void attack, reality warping

**Enemy Scaling (continuous, no waves):**

- **0-3 min:** Fodder only, learning phase
- **3-7 min:** Ranged + fodder mix
- **7-12 min:** Tanks introduced, enemy density increases
- **12-18 min:** Elites appear, enemy speed/HP scaling accelerates
- **18-25 min:** First miniboss
- **25-35 min:** Full chaos, all types, faster spawns
- **35+ min:** Boss encounter every 10 minutes, scaling never stops
- **Difficulty multiplier:** Every minute, enemy HP +3%, damage +2%, spawn rate +1.5%

### 2.4 Progression — Hybrid System

**A) Per-Run (Resets Each Game):**

- **XP & Level** — Kill enemies > earn XP > level up > earn Skill Points
- **Skill Tree Machines** — Scattered across each map, 3-5 per map. Walk up, spend Skill Points.
- **In-Run Skill Tree Categories:**
  - **Offense** — Damage, fire rate, reload speed, crit chance
  - **Defense** — Max HP, armor, damage reduction, heal on kill
  - **Mobility** — Sprint speed, dash cooldown, extra jump, slide duration
  - **Utility** — XP gain, item drop rate, larger pickup radius, minimap range
- Each node costs increasing Skill Points. Max ~30 nodes per run.

**B) Permanent (Persists Forever):**

- **Player Level** — Earned from total XP across all runs
- **Weapon Mastery** — Using a weapon type earns mastery XP, unlocking permanent stat bonuses for that weapon class
- **Codex Entries** — Killing each enemy type fills a Codex. Completed entries grant permanent buffs.
- **Prestige System** — At Player Level 100, prestige for a permanent +5% XP bonus and exclusive cosmetic. Up to Prestige 10.
- **Title & Badge System** — "Shadow Slayer" (kill 10,000 shadows), "Speed Demon" (survive 30 min without stopping), etc.

### 2.5 Item & Powerup Drops

Enemies have a chance to drop on kill:

- **Health Pack** (15% drop rate on fodder) — Restores 25 HP
- **Ammo Crate** (10%) — Refills current weapon
- **Speed Boost** (3%) — 10 seconds of +50% move speed
- **Damage Boost** (2%) — 10 seconds of +50% damage
- **Shield Bubble** (1%) — Absorbs next 100 damage
- **Weapon Drop** (0.5%) — Random weapon of current difficulty tier
- **Skill Point Crystal** (0.3%) — Instant +1 Skill Point without leveling

Bosses always drop: 1 guaranteed weapon (Rare+), 3 Skill Point Crystals, bonus XP orb.

---

## 3. MAPS

### 3.1 Map Philosophy

Each map = one childhood memory. Semi-realistic art style means real objects at slightly exaggerated proportions with dramatic lighting and atmospheric effects.

### 3.2 Launch Maps (Prototype Scope)

**Map 1: The Giant Bedroom** (MVP Priority — build this first)
- Scale: Player is toy-sized. Everything is enormous.
- Landmarks: Under the bed (dark zone), Bookshelf Tower (vertical zone), Desk (sniper perch), Toy Box (item cache), Window Sill (zipline to curtain)
- Lighting: Warm nightlight glow, shadows under furniture, moonlight through window
- Skill Machines: Under the desk, behind the toy box, on the bookshelf middle shelf
- Vibe: Cozy but eerie. The familiar made threatening.

**Map 2: The Schoolyard** (Post-MVP)
- Scale: Normal human scale, but desaturated/dreamy
- Landmarks: Playground (movement playground — monkey bars as ziplines, slide as... slide), Soccer field (open combat zone), Cafeteria (indoor close quarters), Rooftop (secret area with zipline network)
- Lighting: Perpetual golden hour, long shadows, slightly foggy
- Skill Machines: Behind the dumpsters, inside the janitor closet, under the bleachers

**Map 3: Crayon World** (Post-MVP)
- Scale: Abstract, shifting
- Landmarks: Drawn houses, crayon sun, notebook paper ground, eraser pits
- Lighting: Flat, colorful, with "drawn" shadows. Stark contrast to other maps.
- Skill Machines: Inside the crayon box, on top of the drawn house, behind the sun

### 3.3 Future Map Ideas (Post-Launch)

- **Grandma's House** — Oversized cookies, knitting needle hazards, TV static zones
- **The Treehouse** — Vertical map, fall damage enabled, rope bridges and tire swings
- **Toy Store** — Aisles of weaponizable toys, boss fights in display cases
- **The Pool** — Water mechanics, underwater zones, float-based platforms
- **Saturday Morning** — Cereal box forts, TV remote as weapon, couch cushion cover system

---

## 4. MONETIZATION — THE MONEY MACHINE

### 4.1 Revenue Stream #1: Battle Pass (Seasonal)

**Structure:**
- 100 tiers per season (8 weeks per season, ~6.5 seasons/year)
- Free track: Basic cosmetics, small XP boosts
- Premium track: 499 Robux (~$6 USD), exclusive skins, emotes, weapon skins, Skill Point bundles
- Every 10 tiers: Featured item (legendary skin, animated weapon skin, unique emote)
- Tier 100: Ultra-rare exclusive (limited, never returns)

**Revenue Estimate:**
- If 5% of DAU buys pass: 1,000 DAU × 50 buyers × 499R = 24,950 Robux/season
- At 10,000 DAU: 249,500 Robux/season
- At 50,000 DAU: 1,247,500 Robux/season (~$4,366 USD/season at 0.0035 USD/Robux DevEx rate)

### 4.2 Revenue Stream #2: Game Passes (Permanent)

- **VIP Pass** (799 Robux) — +25% XP gain, VIP server access, exclusive VIP skin, VIP lobby, name glow
- **Double XP Pass** (399 Robux) — Permanent 2x XP
- **Extra Loadout Slot** (199 Robux) — Carry 3 weapons instead of 2
- **Auto-Revive** (149 Robux) — 1 free self-revive per game (instead of paying per revive)

### 4.3 Revenue Stream #3: Limited-Time Events

- **Holiday Events** (Christmas, Halloween, Summer, Easter) — Themed maps, exclusive weapons, time-limited skins
- **Collaboration Events** — Partner with popular Roblox creators for exclusive content
- **Weekend Challenges** — Special game modes with exclusive reward skins

### 4.4 Revenue Stream #4: Mystery Boxes / Loot Crates

- **Weapon Skin Crate** (99 Robux) — Random weapon skin, weighted by rarity
- **Emote Crate** (49 Robux) — Random emote/celebration
- **Character Crate** (149 Robux) — Random character skin

**Important:** Display drop rates transparently. Some regions require this legally, and transparency builds trust.

### 4.5 Revenue Stream #5: Consumables

- **Revive Token** (25 Robux) — Continue your run after dying
- **Skill Point Pack** (49 Robux for 5) — Instant Skill Points for current run
- **2x XP Booster** (29 Robux) — 1 hour of double XP (stacks with pass)

### 4.6 Revenue Projections (Conservative)

At 10,000 average DAU (reachable within 6-12 months with good execution + marketing):

| Stream | Monthly Estimate (Robux) | USD Equivalent |
|--------|--------------------------|----------------|
| Battle Pass | 125,000 | $437 |
| Game Passes | 200,000 | $700 |
| Events (avg/mo) | 80,000 | $280 |
| Mystery Boxes | 150,000 | $525 |
| Consumables | 100,000 | $350 |
| **TOTAL** | **655,000** | **~$2,292/month** |

At 50,000 DAU: ~$11,000/month
At 100,000 DAU: ~$25,000/month
Top Roblox FPS games hit 200K+ concurrent (not DAU) — the ceiling is very high.

---

## 5. UI/UX DESIGN

### 5.1 HUD (In-Game)

- **Top Left:** Minimap (toggle-able), shows enemy dots, Skill Machines, teammates
- **Top Center:** Survival timer (time survived this run)
- **Top Right:** Squad status (teammate HP bars, revive indicators)
- **Bottom Left:** Current weapon, ammo count, weapon swap indicator
- **Bottom Center:** HP bar, armor bar, stamina bar (for sprint/dash)
- **Bottom Right:** Active powerups with timers, Skill Points available
- **Center:** Crosshair (customizable), hit markers, damage numbers
- **Kill Feed:** Right side, scrolling, shows recent kills with weapon icons

### 5.2 Menus

- **Main Menu:** Animated 3D background of a rotating memory scene, character showcase
- **Lobby:** Social space where players can test movement before matchmaking
- **Skill Tree Screen:** Full-screen node graph, draggable, zoomable
- **Loadout Screen:** Weapon selection, skin preview, stats comparison
- **Shop:** Battle Pass tab, Crates tab, Game Passes tab, Featured items
- **Codex:** Enemy encyclopedia with 3D models, lore entries, completion percentage
- **Leaderboards:** PVE rankings (time survived), PVP rankings (ELO), seasonal rankings

### 5.3 UI Style

Semi-realistic game = clean, modern UI. Think Destiny 2 / Apex Legends style:
- Dark backgrounds with subtle gradients
- Thin borders, glassmorphism panels
- Weapon rarity colors as accent
- Smooth transitions and micro-animations
- Custom fonts (not default Roblox)

---

## 6. AUDIO DESIGN

### 6.1 Music

- **Menu:** Nostalgic, dreamy ambient (music box + soft synths)
- **Early Game (0-10 min):** Chill, atmospheric, builds slowly
- **Mid Game (10-25 min):** Intensity rises, drums and bass introduced
- **Late Game (25+ min):** Full intensity, aggressive, urgent
- **Boss Fights:** Unique boss themes, heavy and dramatic
- **Victory/Death:** Emotional piano callback to menu theme

### 6.2 SFX

- Weapon sounds should match the toy aesthetic but feel impactful (a Nerf gun should sound toy-like but punchy)
- Enemy death sounds: satisfying, cartoony exaggeration
- Movement sounds: distinct audio for slide, wall bounce, grapple
- UI sounds: crisp, modern (think Apple-level polish)
- Spatial audio: critical for FPS, enemies should be localizable by sound

---

## 7. TECHNICAL ARCHITECTURE

### 7.1 Networking

- **Server-authoritative** — All enemy spawning, damage calculation, and loot drops happen server-side. Never trust the client.
- **Client-side prediction** — Movement feels instant on client, server validates
- **Tick Rate:** Target 20Hz server tick (Roblox standard), with interpolation for smooth visuals
- **Max Players Per Server:** 16 (4 squads of 4, or 16 solo)
- **Separate servers** for PVE and PVP modes

### 7.2 Data Storage

- **ProfileService** (open-source Roblox module) — Handles player data saves, session locking, prevents data loss
- **DataStore2** as backup layer
- Saved per player: Level, XP, Weapon Mastery, Codex progress, Loadout, Owned skins, Battle Pass tier, Purchase history, Settings, ELO rating

### 7.3 Performance Targets

- 60 FPS on mid-range PC
- 30 FPS on mobile (if targeting mobile later)
- Max 200 active enemies on screen (LOD system for distant enemies)
- Particle effects budget per frame
- Asset streaming for maps (don't load everything at once)

### 7.4 Anti-Cheat

- Server-side hit validation
- Speed checks (flag players moving faster than max possible speed)
- Damage output monitoring (flag impossible DPS)
- Report system with replay capability

---

## 8. TOOLS & SOFTWARE STACK

### 8.1 Essential (Free)

| Tool | Purpose |
|------|---------|
| **Roblox Studio** | The engine. Everything is built here. |
| **Visual Studio Code** | Code editor (with Roblox LSP extension for Luau autocomplete) |
| **Rojo** | Sync code between VS Code and Roblox Studio (professional workflow) |
| **Wally** | Package manager for Roblox (install libraries like Knit, ProfileService) |
| **Git + GitHub** | Version control. Non-negotiable for solo dev. |
| **Blender** | 3D modeling, rigging, animation (weapons, enemies, map props) |
| **GIMP / Photopea** | 2D textures, UI mockups |
| **Audacity** | Sound editing |
| **Figma (free tier)** | UI/UX mockups before implementing |

### 8.2 Recommended (Paid, but worth it)

| Tool | Cost | Purpose |
|------|------|---------|
| **Substance Painter** | ~$20/mo (Adobe) | Texturing 3D models to semi-realistic quality |
| **Blender Market assets** | Varies | Pre-made models to speed up development |
| **Epidemic Sound** | ~$15/mo | Royalty-free music and SFX |
| **Adobe Photoshop** | ~$10/mo (Photography plan) | Professional texture/UI work |
| **GitHub Copilot** | ~$10/mo | AI code completion for Luau scripting |

### 8.3 Roblox-Specific Libraries (Free, install via Wally)

| Library | Purpose |
|---------|---------|
| **Knit** | Framework for organizing game code (Services + Controllers) |
| **ProfileService** | Robust player data saving |
| **TopbarPlus** | Custom topbar icons |
| **Iris** | UI debugging |
| **FastCast** | Projectile/bullet simulation (critical for FPS) |
| **GoodSignal** | Optimized event system |
| **Promise** | Async handling |
| **ZonePlus** | Spatial zone detection (for Skill Machine areas) |

### 8.4 Asset Sources

| Source | What to get |
|--------|-------------|
| **Roblox Creator Marketplace** | Free models, plugins, VFX (be selective, quality varies) |
| **Sketchfab** | High-quality 3D models (many free under CC license) |
| **Turbosquid** | Professional 3D models (paid) |
| **CGTrader** | Professional 3D models (paid) |
| **Mixamo** | Free character animations (by Adobe) |
| **Poly Haven** | Free HDRIs, textures, 3D models (CC0) |
| **Freesound.org** | Free sound effects (CC license) |
| **Kenney.nl** | Free game assets (CC0, great for prototyping) |

### 8.5 Roblox Plugins (install in Studio)

| Plugin | Purpose |
|--------|---------|
| **Tag Editor** | Manage CollectionService tags |
| **Reclass** | Change Instance class |
| **InCommand** | In-game developer console |
| **DataStore Editor** | Edit saved data during development |
| **Moon Animator** | In-Studio animation (alternative to Blender for simple anims) |
| **SBS (Studio Build Suite)** | Building tools for map creation |
| **Atmos** | Lighting/atmosphere presets |

---

## 9. DEVELOPMENT ROADMAP

### Phase 0: Foundation (Week 1-2) — CURRENT PRIORITY

- [ ] Set up Rojo + VS Code + Git workflow
- [ ] Install Wally, add Knit + ProfileService + FastCast
- [ ] Create basic FPS framework (first-person camera, mouse aim, shoot raycast)
- [ ] Implement basic movement (run, sprint, jump, crouch)
- [ ] Build greybox version of Giant Bedroom map

### Phase 1: Core Loop (Week 3-5)

- [ ] Advanced movement (slide, dash, double jump, wall slide, wall bounce)
- [ ] Weapon system (pickup, swap, ammo, reload, multiple weapon types)
- [ ] Enemy AI (basic pathfinding, attack, spawn system)
- [ ] Enemy scaling system (continuous difficulty increase)
- [ ] XP + Level system
- [ ] Skill Tree (basic version, 3-4 nodes per category)
- [ ] Skill Machines placed on map

### Phase 2: Polish & Content (Week 6-9)

- [ ] 3-5 enemy types for Giant Bedroom
- [ ] First boss: The Closet Monster
- [ ] Item/Powerup drop system
- [ ] HUD implementation (HP, ammo, minimap, timer)
- [ ] Data persistence (ProfileService integration)
- [ ] Squad system (Duos/Trios/Squad matchmaking)
- [ ] Revive mechanic in co-op
- [ ] Art pass: Replace greybox with semi-realistic assets

### Phase 3: Monetization & PVP (Week 10-13)

- [ ] 1v1 PVP mode (separate map, ranked ELO system)
- [ ] PVE Leaderboards
- [ ] Shop system (Game Passes, Robux products)
- [ ] Battle Pass framework (tier progression, rewards)
- [ ] Weapon skin system
- [ ] Mystery box / crate system
- [ ] VIP Pass implementation

### Phase 4: Launch & Growth (Week 14+)

- [ ] Playtesting (invite 50-100 players, collect feedback)
- [ ] Bug fixing and balancing
- [ ] Thumbnail, icon, and store page creation
- [ ] Social media push (TikTok clips of movement system, Roblox groups)
- [ ] Soft launch
- [ ] Monitor analytics, iterate
- [ ] Begin Map 2 development (The Schoolyard)

---

## 10. MARKETING STRATEGY (for a solo dev)

### 10.1 Pre-Launch

- **TikTok / YouTube Shorts:** Clip the movement system. Wallbounce combos, grapple tricks, speed runs. Movement clips go viral on Roblox TikTok.
- **Roblox Groups:** Join FPS-related groups, post dev updates
- **DevForum:** Post development logs, build a following
- **Discord Server:** Start early, build community during development

### 10.2 Launch

- **Sponsor system:** Use Roblox's ad/sponsor system to boost visibility (budget: minimum 10,000 Robux for initial push)
- **Creator codes:** Partner with Roblox YouTubers for first-look content
- **Limited-time launch event:** Exclusive weapon skin for first 48 hours

### 10.3 Retention

- **Daily login rewards** — Escalating rewards for consecutive days
- **Weekly challenges** — "Kill 500 enemies with melee" for bonus XP
- **Seasonal updates** — New map + Battle Pass every 8 weeks
- **Community events** — Speedrun competitions, fan art contests

---

## 11. REALISTIC SOLO DEV EXPECTATIONS

### What to build first (MVP):
1. Movement system (this alone will attract players)
2. One map (Giant Bedroom)
3. 3 enemy types + 1 boss
4. 5 weapons (one per class)
5. Basic XP + Skill Tree
6. Solo mode only

### What to add after player validation:
1. Co-op modes
2. More enemies and bosses
3. Monetization systems
4. Additional maps
5. PVP mode
6. Battle Pass

### Honest Timeline:
- **Playable prototype (movement + shooting + enemies):** 4-6 weeks
- **Content-complete MVP:** 10-14 weeks
- **Full launch with monetization:** 16-20 weeks
- **This assumes 15-20 hours/week of focused development**

### Skills You Need to Build or Outsource:
- **Luau scripting** — You must learn this. It's the Roblox language. (Similar to Lua)
- **3D modeling** — Learn Blender basics, or buy assets + modify them
- **UI design** — Figma mockups first, then implement in Roblox
- **Game design** — This document is your starting point, iterate based on playtesting
- **Sound design** — Use free libraries (Freesound, Epidemic Sound) until you can afford custom audio

---

## APPENDIX A: NAME IDEAS

| Name | Vibe |
|------|------|
| **RECALL** | Memory theme, punchy, one word |
| **Naptime** | Childhood + threat undertone |
| **Remnants** | Fragmented memory feel |
| **Backyard** | Nostalgic, could be a brand |
| **RECESS** | School nostalgia, also means "break" |
| **Blanket Fort** | Cozy + defensive gameplay |

## APPENDIX B: COMPETITOR ANALYSIS

| Game | What to learn | What to beat |
|------|---------------|--------------|
| **Arsenal (Roblox)** | FPS controls, gun game mode | Repetitive, no PVE depth |
| **Tower Defense Simulator** | Monetization, co-op PVE | Slow gameplay, no FPS element |
| **Blox Fruits** | Progression systems, retention | Not an FPS |
| **Vampire Survivors (Steam)** | Endless escalation, powerup design | Not multiplayer FPS, 2D |
| **Krunker.io** | Movement feel, FPS snappiness | Browser-based, limited content depth |
| **PUBG / Fortnite (Roblox clones)** | Battle royale audience exists on Roblox | PVE > PVP for retention |
