# +1 Gravity leaderboard UX foundation — 2026-10-04

Implemented the missing P13 presentation and fairness layer.

- Rankings menu: Highest Gravity / Total Cores / Fastest Collapse
- explicit loading / empty / unavailable / cooldown states
- Megacity top-5 Highest Gravity world board fed by the same authoritative query
- four-second client/server refresh discipline remains intact
- Fastest Collapse policy is unboosted-only; runs touched by either paid 2x boost cannot replace the stored personal best and therefore cannot enter the OrderedDataStore fastest ranking
- `RunWasBoosted` persists across a disconnect and resets only after Collapse

Live OrderedDataStore write/read remains a canonical-place QA gate.
