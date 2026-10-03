# +1 Gravity — Execution Order

This file defines the implementation order. The ledger remains the source of truth for status.

## RULE
Work phase by phase. Do not jump ahead to Roblox publishing before the current production gate is green.

## 1. Foundation Gate
1. P02 technical foundation
2. P21 automated tests for current pure rules
3. Push initial verified production skeleton to main

Gate:
- StyLua pass
- Selene 0/0
- Rojo build pass
- Pure-Luau tests pass

## 2. Core Game Loop
1. P03 profile/persistence
2. P04 progression
3. P05 attraction/collection
4. P06 object catalog
5. P07 world

Gate:
- Fresh spawn works
- Passive Gravity works
- Object collection works
- Level 0→50 is reachable
- Collapse grants Core and resets run
- Rejoin restores progress

## 3. Visual Identity
1. P08 orbit system
2. P09 Collapse presentation
3. P16 game feel/audio
4. P07 zone art-quality pass

Gate:
- Orbit is visually impressive at five milestones
- Avatar remains visible
- Collapse feels rewarding
- No placeholder-cube presentation remains

## 4. UX / Platform
1. P10 HUD
2. P17 onboarding
3. P18 localization/accessibility/platform
4. P19 performance

Gate:
- iPhone-class layout clean
- tablet clean
- desktop clean
- controller/console clean
- no UI blocks gameplay
- max orbit remains performant

## 5. Meta Systems
1. P11 cosmetics
2. P12 dailies
3. P13 leaderboards
4. P14 monetization
5. P15 security

Gate:
- cosmetics buy/equip/rejoin
- daily rollover/rejoin
- leaderboard write/read
- duplicate receipt idempotency
- no security false positives

## 6. Full QA
Execute P21 runtime/device/visual matrix in order.

Mandatory release journeys:
1. New account → first collectible
2. First 10 minutes
3. Level 0 → 50
4. Collapse #1
5. Collapse #2
6. All five zones
7. Rejoin
8. Cosmetic unlock/equip/rejoin
9. Daily
10. Receipt
11. Multiplayer contention
12. Mobile
13. Controller/console

## 7. Roblox Release
1. Create/verify one canonical +1 Gravity experience
2. Configure Universe/Place IDs
3. Create developer products
4. Run release-readiness until no blockers
5. Complete content questionnaire
6. Configure supported devices
7. Create icon + thumbnails
8. Final main → canonical place
9. Final mobile + console smoke
10. Publish
11. Public visibility
12. Live join verification
13. Commit release evidence

## Current next task
P06/P07 — replace placeholder-like object/world presentation with production-quality object families, distinct zone art direction, real locked-zone gates and readable progression landmarks. After that, execute the Core Game Loop runtime gate including P03 rejoin/migration/failure proofs and P21 multiplayer/mobile journeys.
