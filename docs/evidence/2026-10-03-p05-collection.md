# P05 attraction/collection evidence — 2026-10-03

## Scope

This evidence covers deterministic/static verification for the attraction and collection layer. It does not claim Roblox multiplayer or mobile runtime acceptance.

## Implementation

- 6c10287 — feat: polish collection feedback and contention safety
- 4d6effd — style: format collection claim lifecycle
- Added CollectionClaimRules with revision-based claim/respawn lifecycle.
- A collectible can be won by only one claimant per lifecycle; replay claims are rejected.
- Stale respawn callbacks cannot reactivate a newer claim lifecycle.
- Added deterministic 100-claimant contention coverage.
- Orbit collection payload now includes the source world position.
- Orbit visuals pull from the collected world position into the orbit instead of appearing abruptly.
- Added nearest locked-object feedback with explicit required-Gravity text, not color alone.
- Fixed an existing OrbitController runtime wiring defect where RemoteEvent connections were accidentally chained through a Workspace call.

## GitHub CI proof

Run: 37148413218
Head: 4d6effd59d8b28f67086ddeb72643a6f4525a0e8
Conclusion: success

Passed:
- StyLua
- Selene: 0 errors
- Pure-Luau suite: 9 test files
- Release-readiness
- Rojo build

## Intentionally still open

- Real two-player collection contention in Roblox runtime
- Max-density mobile performance
- Runtime visual QA of pull-in motion
- Runtime visual QA of locked-object feedback
- Full object/world quality pass
