# +1 Gravity — V1 Production Ledger

Last updated: 2026-10-03

Status legend:
- [ ] OPEN — not implemented
- [~] IMPLEMENTED — code/content exists, but acceptance is not fully verified yet
- [x] VERIFIED — acceptance criteria have been checked and passed
- [!] EXTERNAL — blocked by Roblox/dashboard/external configuration
- [R] REWORK — implemented before, but must be redesigned/rebuilt before release

## Release rule

No phase is called "done" because files exist. A task becomes [x] only after its acceptance criteria are verified.

The canonical product is ONE Roblox experience/place on main. No parallel QA places/builds are created unless explicitly required.

---

# P00 — PRODUCT LOCK

- [x] P00-T01 Product name locked: **+1 Gravity**
- [x] P00-T02 Core fantasy locked: visible avatar gains Gravity and attracts increasingly massive objects into orbit
- [x] P00-T03 Rebirth identity locked: **Collapse**
- [x] P00-T04 Permanent progression locked: every Core grants **+25% XP**
- [x] P00-T05 Collapse target locked: Level 50 + minimum Gravity gate
- [x] P00-T06 V1 currencies locked: Gravity / Cores / Shards
- [x] P00-T07 V1 zones locked: Backyard / Downtown / Industrial / Airport / Megacity
- [x] P00-T08 No-pets direction locked; cosmetics are Orbit + Singularity skins
- [x] P00-T09 Avatar remains visible during core gameplay
- [x] P00-T10 Mobile-first / tablet / desktop / controller target locked
- [x] P00-T11 No purchase prompt on spawn
- [x] P00-T12 All-ages / minimal-content-maturity target locked

Acceptance:
- Product loop is understandable in one sentence.
- Rebirth is integrated into fiction, not a generic "Rebirth" button.
- Visual progression changes the player's silhouette continuously.

---

# P01 — PRODUCTION DESIGN / DOCUMENTATION

- [x] P01-T01 README product contract
- [x] P01-T02 V1 master plan
- [x] P01-T03 Art direction
- [x] P01-T04 Production ledger
- [x] P01-T05 Canonical execution order documented
- [x] P01-T06 Artifact hygiene documented
- [x] P01-T07 Server-authority rules documented
- [x] P01-T08 Mobile UX rules documented
- [ ] P01-T09 UX wireframe / screen-state specification
- [ ] P01-T10 World-layout specification with landmark hierarchy
- [x] P01-T11 Economy/balance table through first 10 Collapses — docs/BALANCE.md
- [ ] P01-T12 Release metadata copy + thumbnail/icon brief

---

# P02 — TECHNICAL FOUNDATION

- [x] P02-T01 Rojo project structure created
- [x] P02-T02 Strict Luau source structure created
- [x] P02-T03 StyLua config
- [x] P02-T04 Selene config
- [x] P02-T05 Rokit toolchain
- [x] P02-T06 Shared configuration layer
- [x] P02-T07 Shared rule modules
- [x] P02-T08 Remote definitions
- [~] P02-T09 Server service bootstrap
- [x] P02-T10 Client bootstrap
- [x] P02-T11 Pure-Luau test runner
- [x] P02-T12 Release-readiness script
- [x] P02-T13 CI workflow on GitHub — main green, run 37148094805
- [x] P02-T14 Static gate: StyLua
- [x] P02-T15 Static gate: Selene 0 errors / 0 warnings
- [x] P02-T16 Rojo build gate
- [x] P02-T17 Pure-Luau suite fully green — 10 test files

Acceptance:
- Fresh clone can format, lint, build and test without manual source edits.
- main remains the canonical implementation branch.

---

# P03 — PROFILE / PERSISTENCE

- [x] P03-T01 Profile schema v2
- [x] P03-T02 Safe defaults
- [x] P03-T03 Normalization/migration layer — malformed/legacy deterministic coverage
- [x] P03-T04 Gravity persistence fields
- [x] P03-T05 XP/Level persistence fields
- [x] P03-T06 Core/Shard persistence fields
- [x] P03-T07 Highest Gravity / run statistics
- [x] P03-T08 Collapse statistics
- [x] P03-T09 Daily state fields
- [x] P03-T10 Cosmetic ownership/equip fields
- [x] P03-T11 Receipt idempotency state
- [~] P03-T12 DataStore load
- [~] P03-T13 DataStore save
- [~] P03-T14 Autosave
- [~] P03-T15 BindToClose save
- [ ] P03-T16 Rejoin runtime proof
- [ ] P03-T17 Migration runtime proof
- [ ] P03-T18 Load/save failure recovery QA

Acceptance:
- Progress survives leave/rejoin.
- Duplicate receipts never double-grant.
- Old/malformed data normalizes safely.

---

# P04 — CORE PROGRESSION LOOP

- [~] P04-T01 Passive +1 Gravity/sec
- [x] P04-T02 Gravity boost multiplier support
- [~] P04-T03 Object collection Gravity rewards
- [~] P04-T04 Object collection XP rewards
- [x] P04-T05 Level curve 0 → 50
- [x] P04-T06 Level progress calculation
- [x] P04-T07 Core XP multiplier (+25% each)
- [x] P04-T08 Highest Gravity tracking
- [x] P04-T09 Total Gravity tracking
- [~] P04-T10 Total Objects tracking
- [x] P04-T11 Collapse eligibility
- [x] P04-T12 Collapse resets run Gravity/XP/Level
- [x] P04-T13 Collapse grants one Core
- [x] P04-T14 Collapse Shard reward
- [x] P04-T15 Best Collapse time tracking
- [x] P04-T16 Progression balance: first Collapse target 8–15 min — deterministic model: 11.67 min
- [x] P04-T17 Second Collapse noticeably faster — deterministic model: 4.03 min
- [x] P04-T18 Ten-Collapse simulation/balance test — C1–C10 verified
- [ ] P04-T19 No dead progression interval between object tiers

Acceptance:
- First 30 seconds always provide visible progression.
- Every Core materially accelerates the next run.
- No point requires waiting with no available meaningful action.

---

# P05 — ATTRACTION / COLLECTION SYSTEM

- [x] P05-T01 Gravity-based eligibility thresholds
- [x] P05-T02 Attraction radius scales with Gravity
- [x] P05-T03 Attraction radius capped for performance
- [~] P05-T04 Server-side distance validation
- [x] P05-T05 Server-side Gravity requirement validation — shared rule covered deterministically
- [~] P05-T06 Server-side collection authority
- [~] P05-T07 Per-scan collection cap
- [~] P05-T08 Collected object temporarily disappears
- [~] P05-T09 Object respawn timer
- [~] P05-T10 Collection event sent to client for orbit presentation
- [~] P05-T11 Collection magnet / pull-in tween before orbit — client pull-in implemented; runtime visual QA pending
- [~] P05-T12 Failed/locked attraction visual feedback — nearest locked-object requirement feedback implemented; runtime QA pending
- [~] P05-T13 High-density multiplayer collection contention test — deterministic 100-claimant claim layer green; Roblox two-player runtime pending
- [ ] P05-T14 Mobile performance test with max nearby collectibles

---

# P06 — OBJECT CATALOG / ESCALATION

Backyard:
- [~] P06-T01 Soda Can
- [~] P06-T02 Toy Block
- [~] P06-T03 Shoe
- [~] P06-T04 Garden Chair
- [~] P06-T05 Barbecue

Downtown:
- [~] P06-T06 Traffic Cone
- [~] P06-T07 Mailbox
- [~] P06-T08 Bicycle
- [~] P06-T09 Dumpster
- [~] P06-T10 Compact Car

Industrial:
- [~] P06-T11 Pallet
- [~] P06-T12 Steel Barrel
- [~] P06-T13 Tool Chest
- [~] P06-T14 Forklift
- [~] P06-T15 Cargo Container

Airport:
- [~] P06-T16 Luggage Cart
- [~] P06-T17 Service Cart
- [~] P06-T18 Airport Bus
- [~] P06-T19 Jet Stair
- [~] P06-T20 Jet Engine

Megacity:
- [~] P06-T21 Street Tree
- [~] P06-T22 City Bus
- [~] P06-T23 Billboard
- [~] P06-T24 Crane Section
- [~] P06-T25 Building Chunk

Quality:
- [~] P06-T26 Unique readable silhouette for every family — 25 custom procedural families implemented; runtime screenshot QA pending
- [~] P06-T27 No placeholder cube feeling — invisible hitbox roots + custom visual assemblies implemented; screenshot QA pending
- [~] P06-T28 Vehicle visuals upgraded beyond primitive boxes — wheels/cabins/windows/lights/forks/rails implemented; runtime visual QA pending
- [~] P06-T29 Largest objects visually feel absurd/powerful — jet engine/crane/building-chunk escalation implemented; runtime scale QA pending
- [~] P06-T30 Object LOD / visual simplification strategy — primitive-only procedural geometry + 6 copies/class cap; runtime device profiling pending
- [ ] P06-T31 Object escalation screenshot QA at 5 progression milestones

---

# P07 — WORLD / ZONES

- [~] P07-T01 Backyard zone generated
- [~] P07-T02 Downtown zone generated
- [~] P07-T03 Industrial zone generated
- [~] P07-T04 Airport zone generated
- [~] P07-T05 Megacity zone generated
- [~] P07-T06 Main boulevard/path
- [~] P07-T07 Spawn area
- [~] P07-T08 Zone signs
- [~] P07-T09 Zone requirement copy
- [~] P07-T10 Basic landmarks
- [~] P07-T11 Actual gate/barrier behavior for locked zones — server-authoritative rejection + safe return implemented; runtime traversal proof pending
- [~] P07-T12 Locked-zone feedback — per-player gate field OPEN/locked state + explicit HUD requirement implemented; runtime QA pending
- [~] P07-T13 Zone arrival celebration — ZoneUnlocked + ZoneEntered feedback implemented; runtime feel QA pending
- [~] P07-T14 Distinct art/material language per zone — five procedural zone identities implemented; screenshot QA pending
- [~] P07-T15 Skyline/background dressing — towers, warehouses, terminal/control tower and Megacity spire/skyrail implemented; screenshot QA pending
- [ ] P07-T16 Lighting/atmosphere final pass
- [~] P07-T17 Landmark quality pass — zone-specific landmark assemblies replace generic cube silhouettes; runtime visual QA pending
- [~] P07-T18 No dead empty expanses — structural dressing added across all five zones; runtime route QA pending
- [~] P07-T19 Navigation readable without giant arrows — boulevard + gate arches + requirement signs + landmarks implemented; runtime navigation QA pending
- [ ] P07-T20 Multiplayer spawn/path safety
- [ ] P07-T21 Mobile draw/performance QA

Acceptance:
- A screenshot without UI makes each zone recognizable.
- Player always knows which direction represents progression.

---

# P08 — ORBIT VISUAL SYSTEM

- [~] P08-T01 Client-only orbit visuals
- [~] P08-T02 Orbit visuals non-collidable/non-queryable
- [~] P08-T03 Visible object cap
- [~] P08-T04 Multi-ring layout
- [~] P08-T05 Opposing ring rotation
- [~] P08-T06 Bobbing/spin motion
- [~] P08-T07 Large-object visual scale cap
- [~] P08-T08 Orbit skin tint support
- [~] P08-T09 Character remains centered/visible
- [~] P08-T10 Orbit clears after Collapse
- [~] P08-T11 Orbit clears on respawn
- [ ] P08-T12 Representative-object aggregation by tier
- [ ] P08-T13 Better object-specific miniature models
- [ ] P08-T14 Ring radius adapts to avatar/camera/device
- [ ] P08-T15 Occlusion protection
- [ ] P08-T16 Max-orbit iPhone XR visual QA
- [ ] P08-T17 Max-orbit console visual QA
- [ ] P08-T18 Multiplayer readability QA

Acceptance:
- Orbit looks increasingly ridiculous without hiding the avatar or objective path.
- 60 FPS target on a contemporary phone at max visible orbit.

---

# P09 — COLLAPSE / REBIRTH EXPERIENCE

- [~] P09-T01 Collapse server action
- [~] P09-T02 Collapse eligibility server validation
- [~] P09-T03 Orbit acceleration animation
- [~] P09-T04 Orbit contraction
- [~] P09-T05 Orbit disappearance
- [~] P09-T06 Screen color/energy flash
- [~] P09-T07 Core/Shards result state
- [ ] P09-T08 1.0–1.5 second polished cinematic timing
- [ ] P09-T09 Singularity appears at avatar center
- [ ] P09-T10 Core reward flies into permanent counter
- [ ] P09-T11 Audio crescendo + impact
- [ ] P09-T12 Post-Collapse "faster next run" feedback
- [ ] P09-T13 Repeated Collapse visual variety by Core milestone
- [ ] P09-T14 Collapse cannot strand/kill character
- [ ] P09-T15 Mobile runtime QA

---

# P10 — HUD / UX

- [~] P10-T01 Compact Gravity counter
- [~] P10-T02 Level counter
- [~] P10-T03 Core counter
- [~] P10-T04 Level progress bar
- [~] P10-T05 Current zone
- [~] P10-T06 Daily status
- [~] P10-T07 Collapse button
- [~] P10-T08 First-session tutorial copy
- [~] P10-T09 Toast feedback
- [~] P10-T10 Mobile responsive branch
- [ ] P10-T11 Safe-area validation against Roblox top-left CoreGui
- [ ] P10-T12 Small-phone 19.5:9 layout QA
- [ ] P10-T13 Tablet layout QA
- [ ] P10-T14 Desktop 16:9 layout QA
- [ ] P10-T15 Console 16:9 / ten-foot readability QA
- [ ] P10-T16 No HUD overlap with avatar/object orbit
- [ ] P10-T17 No giant card stack / playfield obstruction
- [ ] P10-T18 Controller selection/focus map
- [ ] P10-T19 Haptics for collect / unlock / Collapse
- [ ] P10-T20 Sound feedback hierarchy

---

# P11 — MENUS / COSMETICS

- [~] P11-T01 Cosmetic definitions
- [~] P11-T02 Orbit skin ownership fields
- [~] P11-T03 Singularity skin ownership fields
- [~] P11-T04 Server buy with Shards
- [~] P11-T05 Server equip validation
- [ ] P11-T06 Cosmetics menu UI
- [ ] P11-T07 Orbit skin preview
- [ ] P11-T08 Singularity skin preview
- [ ] P11-T09 Insufficient-Shards feedback
- [ ] P11-T10 Equipped-state UX
- [ ] P11-T11 Mobile menu layout
- [ ] P11-T12 Controller menu navigation
- [ ] P11-T13 Persistence runtime proof

Orbit skins V1:
- [~] P11-T14 Gravity Blue
- [~] P11-T15 Plasma Violet
- [~] P11-T16 Solar Ember
- [~] P11-T17 Toxic Pulse
- [~] P11-T18 Void
- [~] P11-T19 Galaxy

Singularity skins V1:
- [~] P11-T20 Blue Core
- [~] P11-T21 Inferno Core
- [~] P11-T22 Dark Core
- [~] P11-T23 Solar Core

---

# P12 — DAILY / RETENTION

- [~] P12-T01 Day-key rules
- [~] P12-T02 Login streak rules
- [~] P12-T03 Deterministic rotating daily mission
- [~] P12-T04 Object-collection mission
- [~] P12-T05 Gravity-reach mission
- [~] P12-T06 Collapse mission
- [~] P12-T07 Daily progress persistence fields
- [~] P12-T08 Daily Shard reward
- [ ] P12-T09 Streak reward escalation
- [ ] P12-T10 Daily UI detail panel
- [ ] P12-T11 Daily complete celebration
- [ ] P12-T12 Rejoin/date-boundary runtime tests
- [ ] P12-T13 Server-clock/time-zone safety test

---

# P13 — LEADERBOARDS

- [~] P13-T01 Highest Gravity OrderedDataStore
- [~] P13-T02 Total Cores OrderedDataStore
- [~] P13-T03 Fastest Collapse OrderedDataStore
- [~] P13-T04 Periodic server writes
- [~] P13-T05 Player-leave write
- [~] P13-T06 Username resolution/cache
- [~] P13-T07 Remote query rate limit
- [ ] P13-T08 Leaderboard menu UI
- [ ] P13-T09 World leaderboard display in Megacity
- [ ] P13-T10 Assisted/boosted Fastest Collapse policy
- [ ] P13-T11 OrderedDataStore runtime QA
- [ ] P13-T12 Empty/error state UI

---

# P14 — MONETIZATION

Product definitions:
- [~] P14-T01 2× Gravity · 15 min
- [~] P14-T02 2× XP · 15 min
- [~] P14-T03 100 Shards
- [!] P14-T04 Real Roblox Developer Product IDs

Receipt system:
- [~] P14-T05 Product allowlist
- [~] P14-T06 Receipt idempotency
- [~] P14-T07 Save-before-PurchaseGranted
- [~] P14-T08 Boost duration stacking
- [~] P14-T09 Shard-pack grant
- [ ] P14-T10 Receipt retry runtime test
- [ ] P14-T11 Duplicate receipt runtime test
- [ ] P14-T12 Rejoin-after-purchase runtime test

Shop:
- [ ] P14-T13 Explicit shop UI
- [ ] P14-T14 No prompt on spawn verification
- [ ] P14-T15 Product disabled/not-live states
- [ ] P14-T16 Current boost timers
- [ ] P14-T17 Purchase success feedback
- [ ] P14-T18 Purchase cancel/aborted path
- [ ] P14-T19 Mobile/console purchase UX

---

# P15 — SECURITY / ANTI-EXPLOIT

- [~] P15-T01 Progression server authoritative
- [~] P15-T02 Collection server authoritative
- [~] P15-T03 Collapse server authoritative
- [~] P15-T04 Cosmetic spend/equip server authoritative
- [~] P15-T05 Receipt grants server authoritative
- [ ] P15-T06 Remote action rate limiter
- [ ] P15-T07 Remote payload schema validation
- [ ] P15-T08 Movement/teleport abuse cannot directly grant objects
- [x] P15-T09 Object replay/double-collect race test — deterministic claim lifecycle/revision test
- [ ] P15-T10 Collapse spam test
- [ ] P15-T11 Shop/cosmetic spam test
- [ ] P15-T12 Security never kicks normal mobile analog input
- [ ] P15-T13 Server load test with multiple collectors

---

# P16 — AUDIO / FEEL / GAME JUICE

- [ ] P16-T01 Small-object collect sound family
- [ ] P16-T02 Medium-object collect sound family
- [ ] P16-T03 Massive-object collect sound family
- [ ] P16-T04 Gravity threshold unlock sting
- [ ] P16-T05 Zone unlock sting
- [ ] P16-T06 Level-up sound/VFX
- [ ] P16-T07 Core milestone sound/VFX
- [ ] P16-T08 Collapse audio sequence
- [ ] P16-T09 Ambient zone loops
- [ ] P16-T10 Camera micro-feedback
- [ ] P16-T11 Object pull trail/VFX
- [ ] P16-T12 Performance-safe VFX budget

---

# P17 — ONBOARDING / FIRST SESSION

- [~] P17-T01 Initial instructional HUD copy
- [ ] P17-T02 First collectible guaranteed within spawn radius
- [ ] P17-T03 First five collectibles form readable path
- [ ] P17-T04 First visible object-size escalation in under 60 sec
- [ ] P17-T05 Downtown tease visible from Backyard
- [ ] P17-T06 Locked Downtown requirement visible
- [ ] P17-T07 Collapse explained before Level 50
- [ ] P17-T08 First Collapse celebration
- [ ] P17-T09 Fresh-player 10-minute runtime journey
- [ ] P17-T10 No point requires menu knowledge to progress

---

# P18 — ACCESSIBILITY / LOCALIZATION / PLATFORM

- [ ] P18-T01 English V1 copy complete
- [ ] P18-T02 German V1 localization
- [ ] P18-T03 No critical information encoded by color alone
- [ ] P18-T04 Readable text at compact phone resolution
- [ ] P18-T05 Controller input and selection
- [ ] P18-T06 Keyboard/mouse
- [ ] P18-T07 Touch
- [ ] P18-T08 Tablet
- [ ] P18-T09 Console
- [ ] P18-T10 Reduced-motion option for Collapse/orbit
- [ ] P18-T11 Audio-independent objective readability

---

# P19 — PERFORMANCE

- [~] P19-T01 Client-only orbit reduces server physics cost
- [~] P19-T02 Orbit visual count capped
- [~] P19-T03 Attraction radius capped
- [~] P19-T04 Collections per scan capped
- [ ] P19-T05 Max collectible count budget
- [ ] P19-T06 StreamingEnabled evaluation
- [ ] P19-T07 Mobile GPU/frame-rate profiling
- [ ] P19-T08 Server heartbeat profiling
- [ ] P19-T09 8-player server soak
- [ ] P19-T10 Memory leak test across 10 Collapses
- [ ] P19-T11 Respawn/rejoin cleanup test

---

# P20 — CONTENT MATURITY / ALL-AGES TARGET

- [x] P20-T01 No blood/gore
- [x] P20-T02 No weapons/combat
- [x] P20-T03 No horror/fear dependency
- [x] P20-T04 No gambling/paid random items
- [x] P20-T05 No alcohol/drug references
- [x] P20-T06 No sexual content
- [ ] P20-T07 Roblox content questionnaire completed
- [ ] P20-T08 Minimal content maturity confirmed in dashboard
- [ ] P20-T09 Kids/Select eligibility settings reviewed
- [ ] P20-T10 Audience reach configuration completed

---

# P21 — QA MATRIX

Automated:
- [x] P21-T01 Full static gate — StyLua + Selene 0/0 + Rojo build
- [x] P21-T02 Level curve deterministic tests
- [x] P21-T03 Collapse deterministic tests
- [x] P21-T04 Attraction deterministic tests
- [x] P21-T05 Zone gate tests
- [x] P21-T06 Daily rules tests
- [x] P21-T07 Profile normalization tests
- [x] P21-T08 Receipt idempotency tests
- [x] P21-T09 Release-readiness tests — six expected external blockers surfaced

Runtime:
- [ ] P21-T10 Fresh spawn
- [ ] P21-T11 First object collection
- [ ] P21-T12 100-object collection run
- [ ] P21-T13 All five zone unlocks
- [ ] P21-T14 Level 0 → 50
- [ ] P21-T15 Collapse #1
- [ ] P21-T16 Collapse #2 accelerated
- [ ] P21-T17 10 Collapse soak
- [ ] P21-T18 Death/respawn
- [ ] P21-T19 Leave/rejoin
- [ ] P21-T20 Daily rollover
- [ ] P21-T21 Cosmetic buy/equip/rejoin
- [ ] P21-T22 Product receipt/rejoin
- [ ] P21-T23 Leaderboard write/read
- [ ] P21-T24 Two-player contention
- [ ] P21-T25 8-player soak

Device:
- [ ] P21-T26 iPhone XR class viewport
- [ ] P21-T27 modern tall iPhone viewport
- [ ] P21-T28 small Android viewport
- [ ] P21-T29 tablet
- [ ] P21-T30 desktop 16:9
- [ ] P21-T31 controller/console

Visual:
- [ ] P21-T32 HUD does not block gameplay
- [ ] P21-T33 Avatar visible at max orbit
- [ ] P21-T34 Zone identity screenshot review
- [ ] P21-T35 Object quality screenshot review
- [ ] P21-T36 Collapse screenshot/video review

---

# P22 — ROBLOX RELEASE

Repository:
- [x] P22-T01 Initial production commit pushed to main — f5c6453
- [x] P22-T02 GitHub CI green — latest verified run 37149063716
- [x] P22-T03 Ledger synchronized with verified state — 2026-10-03

Roblox configuration:
- [!] P22-T04 Universe ID
- [!] P22-T05 Canonical Place ID
- [!] P22-T06 Developer Product IDs
- [ ] P22-T07 Experience name: +1 Gravity
- [ ] P22-T08 Description
- [ ] P22-T09 Genre/category
- [ ] P22-T10 Supported devices: desktop/mobile/tablet/console; VR off unless tested
- [ ] P22-T11 Content questionnaire
- [ ] P22-T12 Audience reach
- [ ] P22-T13 Icon
- [ ] P22-T14 Thumbnails

Publish:
- [ ] P22-T15 Final main → canonical place sync
- [ ] P22-T16 Final mobile smoke
- [ ] P22-T17 Final console smoke
- [ ] P22-T18 PublishSuccessful verified
- [ ] P22-T19 Public visibility enabled
- [ ] P22-T20 Live join verification
- [ ] P22-T21 Release evidence committed

---

# DEFINITION OF DONE

V1 is finished only when all of the following are true:

- Core progression is fun and readable from Level 0 to first Collapse.
- Rebirth visibly accelerates the next run.
- Five zones are visually distinct and progressively spectacular.
- Orbit escalation is the visual identity of the game and never obscures the avatar.
- Collapse is a polished reward moment, not a plain reset.
- Persistence, dailies, cosmetics and leaderboards survive rejoin.
- Purchase receipts are idempotent and live-tested.
- No normal touch/controller input can trigger security kicks.
- iPhone-class mobile, tablet, desktop and console journeys are verified.
- Content questionnaire matches the intended minimal/all-ages content.
- Canonical main is published to exactly one production place.
- Roblox live join matches the tested release candidate.
- Ledger and release evidence reflect the real shipped state.
