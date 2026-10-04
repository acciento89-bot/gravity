# +1 Gravity remote security hardening — 2026-10-04

Mutating client remotes are now bounded by shared pure-Luau validation/rate rules.

- `Action`: exact `Collapse` allowlist; 250 ms server cooldown
- `CosmeticAction`: Buy/Equip only; Orbit/Singularity only; bounded token lengths; 300 ms server cooldown
- `LeaderboardQuery`: existing 4-second query cooldown retained
- no Collect/GrantObject remote exists; objects are awarded only by server-side attraction scan, distance validation, active state and atomic claim
- security code does not inspect Humanoid movement and never kicks for analog movement

Regression tests cover valid/invalid tokens, oversized payloads, forbidden Grant action and rate-limit boundaries.
