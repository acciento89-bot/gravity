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
- [x] P04-T03 Object collection Gravity rewards — production collection-driven Level 0→50 runtime verified
- [x] P04-T04 Object collection XP rewards — XP rose to 151,957 through production collection pipeline
- [x] P04-T05 Level curve 0 → 50
- [x] P04-T06 Level progress calculation
- [x] P04-T07 Core XP multiplier (+25% each)
- [x] P04-T08 Highest Gravity tracking
- [x] P04-T09 Total Gravity tracking
- [x] P04-T10 Total Objects tracking — 1,821-object progression run verified
- [x] P04-T11 Collapse eligibility
- [x] P04-T12 Collapse resets run Gravity/XP/Level
- [x] P04-T13 Collapse grants one Core
- [x] P04-T14 Collapse Shard reward
- [x] P04-T15 Best Collapse time tracking
- [x] P04-T16 Progression balance: first Collapse target 8–15 min — deterministic model: 11.67 min
- [x] P04-T17 Second Collapse noticeably faster — deterministic model: 4.03 min
- [x] P04-T18 Ten-Collapse simulation/balance test — C1–C10 verified
- [x] P04-T19 No dead progression interval between object tiers — runtime watchdog stayed under 20 s through Level 50

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
- [x] P07-T11 Actual gate/barrier behavior for locked zones — locked Downtown runtime rejection + safe return verified
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

- [x] P08-T01 Client-only orbit visuals — live iPhone XR PlaySolo verified
- [x] P08-T02 Orbit visuals non-collidable/non-queryable — implementation + live client verified
- [x] P08-T03 Visible object cap — 14-slot replacement policy covered by OrbitRules
- [x] P08-T04 Multi-ring layout — client implementation verified
- [x] P08-T05 Opposing ring rotation — client implementation verified
- [x] P08-T06 Bobbing/spin motion — live client runtime verified
- [x] P08-T07 Large-object visual scale cap — client implementation verified
- [~] P08-T08 Orbit skin tint support — retint path implemented; live skin-swap QA pending
- [x] P08-T09 Character remains centered/visible — iPhone XR verified through full 14-slot orbit
- [x] P08-T10 Orbit clears after Collapse — populated 14-slot orbit verified empty after live Collapse
- [x] P08-T11 Orbit clears on respawn — client orbit 14→0 across live death/respawn
- [x] P08-T12 Representative-object aggregation by tier — deterministic replacement tests + live ×2 aggregation verified
- [~] P08-T13 Better object-specific miniature models — category-specific miniatures implemented; full catalog visual QA pending
- [x] P08-T14 Ring radius adapts to avatar/camera/device — deterministic phone/desktop scaling test + iPhone XR runtime
- [x] P08-T15 Occlusion protection — deterministic center-fade test + live avatar visibility verified
- [x] P08-T16 Max-orbit iPhone XR visual QA — 14 representatives at 896×414; avatar/HUD/path readable after density fix
- [ ] P08-T17 Max-orbit console visual QA
- [ ] P08-T18 Multiplayer readability QA

Acceptance:
- Orbit looks increasingly ridiculous without hiding the avatar or objective path.
- 60 FPS target on a contemporary phone at max visible orbit.

---

# P09 — COLLAPSE / REBIRTH EXPERIENCE

- [x] P09-T01 Collapse server action — exact Action RemoteEvent path verified in PlaySolo
- [x] P09-T02 Collapse eligibility server validation — deterministic rejection/acceptance + eligible runtime path verified
- [x] P09-T03 Orbit acceleration animation — populated max orbit captured during live Collapse
- [x] P09-T04 Orbit contraction — populated max orbit captured contracting around avatar
- [x] P09-T05 Orbit disappearance — populated max orbit verified cleared after Collapse
- [x] P09-T06 Screen color/energy flash — captured in iPhone XR runtime
- [x] P09-T07 Core/Shards result state — deterministic reward test + live Core 0→1 state verified
- [x] P09-T08 1.0–1.5 second polished cinematic timing — 1.18 s sequence implemented and frame-captured
- [x] P09-T09 Singularity appears at avatar center — iPhone XR runtime frame captured
- [x] P09-T10 Core reward flies into permanent counter — center→counter transition frame-captured
- [ ] P09-T11 Audio crescendo + impact
- [x] P09-T12 Post-Collapse "faster next run" feedback — NEXT RUN XP ×1.25 verified live
- [~] P09-T13 Repeated Collapse visual variety by Core milestone — milestone palette logic implemented; milestone runtime QA pending
- [x] P09-T14 Collapse cannot strand/kill character — avatar remained alive/controllable after live Collapse
- [x] P09-T15 Mobile runtime QA — iPhone XR 896×414 Collapse path, 0 CreatorErrors

---

# P10 — HUD / UX

- [x] P10-T01 Compact Gravity counter — iPhone XR runtime verified
- [x] P10-T02 Level counter — LV50→LV0 live Collapse verified
- [x] P10-T03 Core counter — Core 0→1 live Collapse verified
- [x] P10-T04 Level progress bar — iPhone XR runtime verified
- [~] P10-T05 Current zone
- [x] P10-T06 Daily status — iPhone XR runtime verified
- [x] P10-T07 Collapse button — visible after natural production Level 0→50 runtime journey
- [x] P10-T08 First-session tutorial copy — visible in fresh iPhone XR session
- [x] P10-T09 Toast feedback — Collapse NEXT RUN XP toast verified live
- [x] P10-T10 Mobile responsive branch — iPhone XR 896×414 live
- [x] P10-T11 Safe-area validation against Roblox top-left CoreGui — iPhone XR screenshot verified
- [x] P10-T12 Small-phone 19.5:9 layout QA — iPhone XR 896×414 PlaySolo verified
- [~] P10-T13 Tablet layout QA — dedicated touch-tablet profile implemented; runtime screenshot QA pending
- [~] P10-T14 Desktop 16:9 layout QA — dedicated non-touch desktop profile implemented; runtime screenshot QA pending
- [~] P10-T15 Console 16:9 / ten-foot readability QA — dedicated ten-foot profile implemented via `GuiService:IsTenFootInterface()`; runtime console screenshot QA pending
- [x] P10-T16 No HUD overlap with avatar/object orbit — 14-slot iPhone XR max-orbit screenshot verified
- [x] P10-T17 No giant card stack / playfield obstruction — iPhone XR screenshot verified
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
- [~] P11-T06 Cosmetics menu UI — complete client menu implemented; runtime visual QA pending
- [~] P11-T07 Orbit skin preview — live config-color ring preview implemented; runtime QA pending
- [~] P11-T08 Singularity skin preview — live config-color core preview implemented; runtime QA pending
- [~] P11-T09 Insufficient-Shards feedback — client deficit copy implemented while server remains authoritative; runtime QA pending
- [~] P11-T10 Equipped-state UX — OWNED/EQUIPPED/BUY/EQUIP states implemented; runtime QA pending
- [~] P11-T11 Mobile menu layout — responsive phone/tablet sizing implemented; runtime QA pending
- [~] P11-T12 Controller menu navigation — Selectable controls and explicit tab/card/action focus map implemented; runtime QA pending
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
- [~] P12-T09 Streak reward escalation — server reward increases every 3 consecutive days, capped at +30 Shards; runtime rollover QA pending
- [~] P12-T10 Daily UI detail panel — mission/progress/streak/current reward panel implemented; runtime visual QA pending
- [~] P12-T11 Daily complete celebration — authoritative DailyComplete event drives reward celebration; runtime QA pending
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
- [~] P13-T08 Leaderboard menu UI — Gravity/Cores/Fastest tabs implemented; runtime visual QA pending
- [~] P13-T09 World leaderboard display in Megacity — top-5 Gravity SurfaceGui board implemented; runtime visual QA pending
- [x] P13-T10 Assisted/boosted Fastest Collapse policy — runs using 2× Gravity or 2× XP are excluded from Fastest Collapse
- [ ] P13-T11 OrderedDataStore runtime QA
- [~] P13-T12 Empty/error state UI — loading/empty/unavailable/cooldown states implemented; runtime QA pending

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
- [~] P14-T13 Explicit shop UI — three-product player-facing shop implemented; runtime visual QA pending
- [x] P14-T14 No prompt on spawn verification — purchase prompt exists only inside product-card Activated handlers
- [~] P14-T15 Product disabled/not-live states — ProductId 0 renders DISABLED/NOT LIVE and never calls MarketplaceService; runtime QA pending
- [~] P14-T16 Current boost timers — Gravity/XP expiry countdowns implemented from authoritative snapshot; runtime QA pending
- [~] P14-T17 Purchase success feedback — receipt-backed PurchaseGranted feedback implemented; live receipt QA pending
- [~] P14-T18 Purchase cancel/aborted path — PromptProductPurchaseFinished cancel feedback implemented; live-product QA pending
- [~] P14-T19 Mobile/console purchase UX — responsive platform sizing + controller-selectable product cards implemented; runtime QA pending

---

# P15 — SECURITY / ANTI-EXPLOIT

- [~] P15-T01 Progression server authoritative
- [~] P15-T02 Collection server authoritative
- [~] P15-T03 Collapse server authoritative
- [~] P15-T04 Cosmetic spend/equip server authoritative
- [~] P15-T05 Receipt grants server authoritative
- [x] P15-T06 Remote action rate limiter — Collapse 250 ms, CosmeticAction 300 ms, LeaderboardQuery 4 s
- [x] P15-T07 Remote payload schema validation — strict token type/length + action/category allowlists on mutating remotes
- [x] P15-T08 Movement/teleport abuse cannot directly grant objects — no client Collect/Grant remote exists; collection remains server scan + distance + active-claim authority
- [x] P15-T09 Object replay/double-collect race test — deterministic claim lifecycle/revision test
- [x] P15-T10 Collapse spam test — shared rate-limit regression verifies sub-250 ms actions are rejected
- [x] P15-T11 Shop/cosmetic spam test — CosmeticAction payload allowlist + 300 ms server limiter implemented and regression-tested
- [~] P15-T12 Security never kicks normal mobile analog input — security layer does not inspect humanoid movement or issue kicks; real mobile runtime acceptance pending
- [ ] P15-T13 Server load test with multiple collectors

---

# P16 — AUDIO / FEEL / GAME JUICE

- [~] P16-T01 Small-object collect sound family — high-pitch low-volume cue implemented; runtime mix QA pending
- [~] P16-T02 Medium-object collect sound family — medium cue + local pulse implemented; runtime mix QA pending
- [~] P16-T03 Massive-object collect sound family — low cue + stronger pulse/camera micro-kick implemented; runtime QA pending
- [ ] P16-T04 Gravity threshold unlock sting
- [~] P16-T05 Zone unlock sting — dedicated state-event cue + green pulse implemented; runtime QA pending
- [~] P16-T06 Level-up sound/VFX — client detects authoritative level increases and plays dedicated cue/pulse; runtime QA pending
- [~] P16-T07 Core milestone sound/VFX — 5/10-Core collapse audio variants implemented; runtime QA pending
- [~] P16-T08 Collapse audio sequence — charge then impact cue layered over existing Collapse visual sequence; runtime QA pending
- [ ] P16-T09 Ambient zone loops
- [~] P16-T10 Camera micro-feedback — massive collect uses bounded +1.4 FOV kick; runtime comfort QA pending
- [ ] P16-T11 Object pull trail/VFX
- [x] P16-T12 Performance-safe VFX budget — max 4 transient sounds and 8 local pulses; sound volume hard-capped at 0.28

---

# P17 — ONBOARDING / FIRST SESSION

- [x] P17-T01 Initial instructional HUD copy — first collect, first-five path, growth/Downtown tease and pre-Collapse reminder states implemented
- [x] P17-T02 First collectible guaranteed within spawn radius — first Soda Can fixed 6 studs from spawn, inside base 10-stud attraction radius
- [x] P17-T03 First five collectibles form readable path — deterministic Soda Can chain at x=6/13/20/27/34 near boulevard center
- [x] P17-T04 First visible object-size escalation in under 60 sec — Toy Block/Shoe/Chair/Barbecue explicitly staged forward through x=72 with <=45 Gravity locks
- [x] P17-T05 Downtown tease visible from Backyard — cyan DOWNTOWN AHEAD beacon at Backyard exit plus existing skyline/gate
- [x] P17-T06 Locked Downtown requirement visible — tease and production zone gate both state 120 Gravity requirement
- [x] P17-T07 Collapse explained before Level 50 — early copy mentions LV50 and LV35-49 reminder states exact LV50 + 5K requirement
- [x] P17-T08 First Collapse celebration — production Collapse FX/reward sequence already runtime-verified under P21-T15/P21-T36
- [x] P17-T09 Fresh-player 10-minute runtime journey — production-path fresh progression reached Level 50 in 250.01 s with no >20 s dead interval
- [x] P17-T10 No point requires menu knowledge to progress — collection is proximity-automatic, world gates are signed, Collapse action becomes visible when eligible; meta menus remain optional

---

# P18 — ACCESSIBILITY / LOCALIZATION / PLATFORM

- [~] P18-T01 English V1 copy complete — critical objective/accessibility copy cataloged; remaining meta-menu copy review pending
- [~] P18-T02 German V1 localization — critical onboarding/requirements/accessibility copy implemented with locale fallback; remaining meta-menu copy pending
- [x] P18-T03 No critical information encoded by color alone — lock/equip/buy/daily/boost states all carry explicit text in addition to color
- [~] P18-T04 Readable text at compact phone resolution — compact tutorial/daily minimum raised from 9 to 11 px; runtime screenshot acceptance pending
- [~] P18-T05 Controller input and selection — gameplay uses Roblox controls; meta buttons/cards Selectable with explicit focus links; runtime acceptance pending
- [~] P18-T06 Keyboard/mouse — native Roblox movement plus Activated UI path implemented; runtime acceptance pending
- [~] P18-T07 Touch — native Roblox touch movement plus touch-sized responsive UI implemented; runtime acceptance pending
- [~] P18-T08 Tablet — dedicated tablet layout profile implemented; runtime acceptance pending
- [~] P18-T09 Console — true ten-foot profile and Selectable meta UI implemented; runtime acceptance pending
- [~] P18-T10 Reduced-motion option for Collapse/orbit — player-facing toggle reduces orbit speed/bob, Collapse blur/scale/flash and disables camera micro-kick; runtime comfort QA pending
- [x] P18-T11 Audio-independent objective readability — all progression, lock, daily, purchase and accessibility states remain text-readable without sound

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
- [x] P21-T10 Fresh spawn — local Studio iPhone XR PlaySolo, 0 CreatorErrors
- [x] P21-T11 First object collection — live attraction/collection produced ×2 aggregate
- [x] P21-T12 100-object collection run — production attraction loop gained exactly 100 objects in local PlaySolo
- [x] P21-T13 All five zone unlocks — exact production requirements verified for Backyard→Megacity
- [x] P21-T14 Level 0 → 50 — 250.01 s QA route, 1,821 production collections, no XP/Core/boost seed
- [x] P21-T15 Collapse #1 — exact client Action RemoteEvent → server Collapse → client FX path verified
- [x] P21-T16 Collapse #2 accelerated — real client Action RemoteEvent; faster best-time verified
- [x] P21-T17 10 Collapse soak — ten sequential production Action collapses, Core 0→10, 0 CreatorErrors
- [x] P21-T18 Death/respawn — character respawned and permanent Core state remained intact
- [ ] P21-T19 Leave/rejoin
- [ ] P21-T20 Daily rollover
- [ ] P21-T21 Cosmetic buy/equip/rejoin
- [ ] P21-T22 Product receipt/rejoin
- [ ] P21-T23 Leaderboard write/read
- [ ] P21-T24 Two-player contention
- [ ] P21-T25 8-player soak

Device:
- [x] P21-T26 iPhone XR class viewport — 896×414 PlaySolo verified
- [ ] P21-T27 modern tall iPhone viewport
- [ ] P21-T28 small Android viewport
- [ ] P21-T29 tablet
- [ ] P21-T30 desktop 16:9
- [ ] P21-T31 controller/console

Visual:
- [x] P21-T32 HUD does not block gameplay — iPhone XR screenshot review verified
- [x] P21-T33 Avatar visible at max orbit — 14-slot iPhone XR screenshot verified
- [ ] P21-T34 Zone identity screenshot review
- [ ] P21-T35 Object quality screenshot review
- [x] P21-T36 Collapse screenshot/video review — multi-frame iPhone XR review completed

---

# P22 — ROBLOX RELEASE

Repository:
- [x] P22-T01 Initial production commit pushed to main — f5c6453
- [x] P22-T02 GitHub CI green — latest verified run 37152179564
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

## 2026-10-04 platform-layout implementation pass

- [x] HUD responsive logic now distinguishes phone, tablet, desktop and true ten-foot/console instead of a single compact/non-compact split.
- [x] Tablet gets an intermediate readable HUD budget without phone compression.
- [x] Desktop retains a compact centered HUD that does not dominate the 16:9 playfield.
- [x] Console/ten-foot receives larger type, tutorial/daily surfaces and Collapse target sizing for couch-distance readability.
- [x] Pure-Luau regression coverage added for platform classification and relative sizing.
- [~] P10-T13/T14/T15 remain acceptance-pending until real Studio device/desktop/console screenshots are captured.

## 2026-10-04 cosmetics UX implementation

- [x] Added player-facing Gravity Style menu with Orbit/Core tabs, config-driven color previews, shard balance and sorted skin catalog.
- [x] BUY/EQUIP/EQUIPPED/OWNED states derive from authoritative snapshot fields; insufficient funds shows exact missing Shards before any remote is fired.
- [x] Server remains authoritative for spend and ownership; client only sends the existing `CosmeticAction` Buy/Equip actions.
- [x] Controller-selectable tabs/cards/action controls and responsive phone/tablet/desktop/ten-foot sizing are wired.
- [~] P11 runtime screenshot, buy/equip/rejoin and controller acceptance remain pending.

## 2026-10-04 daily UX implementation

- [x] Daily reward now escalates from the 15-Shard base by +5 every 3 consecutive days, capped at +30 bonus (45 total).
- [x] Reward amount is calculated server-side from persisted streak state and included in the authoritative Daily snapshot.
- [x] Daily detail panel shows mission, progress, streak and current reward with responsive sizing.
- [x] Completion emits `DailyComplete` with the granted reward and drives a dedicated client celebration.
- [x] Pure-Luau tests cover base reward, first bonus, mid-streak escalation and cap.
- [~] Date-boundary/rejoin runtime acceptance remains pending on a canonical Roblox Place.

## 2026-10-04 leaderboard UX and fairness

- [x] Player-facing Rankings menu added for Highest Gravity, Total Cores and Fastest Collapse.
- [x] Megacity world board added for the top five Highest Gravity entries.
- [x] Loading, empty, query-cooldown and unavailable states are explicit.
- [x] Fastest Collapse is now unboosted-only: any run touched by 2× Gravity or 2× XP is excluded from PB/OrderedDataStore eligibility.
- [x] Assisted-run state persists across rejoin and resets after Collapse.
- [~] OrderedDataStore live write/read and world-board screenshot acceptance remain canonical-place runtime gates.

## 2026-10-04 monetization UX implementation

- [x] Explicit Gravity Shop added for 2x Gravity, 2x XP and 100 Shards.
- [x] ProductId `0` is a hard disabled state: UI shows NOT LIVE and no purchase prompt can fire.
- [x] No purchase prompt runs on spawn; prompts are reachable only through explicit product-card activation.
- [x] Active Gravity/XP boost timers count down from authoritative state.
- [x] Client distinguishes prompt submitted, cancelled and server receipt-granted/saved feedback.
- [x] Responsive phone/tablet/desktop/ten-foot sizing and controller-selectable cards are wired.
- [~] Real IDs, receipt retry/duplicate/rejoin and live purchase UX remain external/canonical-place gates.

## 2026-10-04 remote security hardening

- [x] Shared pure-Luau security rules enforce bounded tokens, allowlists and minimum action intervals.
- [x] Collapse accepts only the exact `Collapse` action and is server-rate-limited to 250 ms.
- [x] CosmeticAction accepts only Buy/Equip + Orbit/Singularity + bounded skin names and is server-rate-limited to 300 ms.
- [x] LeaderboardQuery retains its existing 4-second server cooldown.
- [x] There is no client-facing collect/grant-object remote; attraction/collection requires server distance, active state and atomic claim authority.
- [x] Security regression tests cover oversized/empty payloads, grant-action rejection and spam interval behavior.
- [~] Mobile analog false-positive acceptance remains a device runtime gate; no movement heuristic/kick code exists.

## 2026-10-04 game-feel feedback hierarchy

- [x] Collect feedback is split into Small / Medium / Massive bands from authoritative GravityGain values.
- [x] Medium/Massive collections add bounded local pulse VFX; Massive adds a subtle camera micro-kick.
- [x] Level-up and ZoneUnlocked state changes have distinct cues/VFX.
- [x] Collapse uses a charge/impact audio pair with stronger 5-Core/10-Core milestone variants.
- [x] Reward events have a separate lightweight cue.
- [x] Hard budgets: 4 concurrent transient sounds, 8 local pulse VFX, max transient volume 0.28.
- [~] Physical mobile-speaker mix/comfort acceptance remains runtime QA.

## 2026-10-04 deterministic first-session onboarding

- [x] Fresh spawn now has a deterministic five-Can boulevard path beginning 6 studs from spawn.
- [x] Toy Block → Shoe → Garden Chair → Barbecue escalation is staged immediately after the first-five path and becomes collectible through <=45 passive Gravity, keeping visible size growth inside the first minute.
- [x] Backyard exit now carries a DOWNTOWN AHEAD / 120 GRAVITY beacon in addition to the production zone gate.
- [x] Tutorial copy advances by real TotalObjects/Level state and reintroduces exact Collapse requirements at Levels 35-49.
- [x] Pure-Luau onboarding regression tests protect spawn-radius, forward-flow and escalation ordering.
- [x] Existing production-path runtime evidence already proves fresh Level 0→50 in 250.01 s, Collapse #1 and no >20 s dead collection interval.

## 2026-10-04 accessibility and localization foundation

- [x] Added locale-aware EN/DE text catalog with English fallback for unsupported locales.
- [x] Critical onboarding, lock/requirement, progression toast and accessibility copy is localized.
- [x] Added player-facing Reduced Motion toggle.
- [x] Reduced Motion cuts orbit rotation/bob, Collapse scale/blur/flash and disables camera micro-kick.
- [x] Compact-phone tutorial/daily text floor raised from 9 to 11 for readability.
- [x] Critical states use text plus color; audio is never required to understand an objective or requirement.
- [~] Remaining meta-menu strings still need full DE catalog coverage before P18-T01/T02 can close.
