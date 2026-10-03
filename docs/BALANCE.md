# +1 Gravity — V1 Balance Baseline

Last verified: 2026-10-03

This is the deterministic baseline used to catch economy regressions before Roblox runtime QA. It is not a substitute for spatial/mobile playtesting.

## Simulation assumptions

- Passive Gravity: +1/sec.
- One collection opportunity per second.
- The simulator selects the highest currently eligible object definition.
- Zone Gravity and Core requirements are enforced.
- Object Gravity and XP rewards come from the production ObjectConfig.
- Each Core adds +25% XP exactly as the production LevelRules do.
- Collapse requires Level 50 and at least 5,000 Gravity.
- No paid boosts are enabled.

## First 10 Collapse runs

| Run | Cores at start | XP multiplier | Simulated time | Collapse shard reward |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 0 | 1.00× | 11.67 min | 10 |
| 2 | 1 | 1.25× | 4.03 min | 10 |
| 3 | 2 | 1.50× | 3.52 min | 10 |
| 4 | 3 | 1.75× | 1.93 min | 10 |
| 5 | 4 | 2.00× | 1.83 min | 10 |
| 6 | 5 | 2.25× | 1.77 min | 12 |
| 7 | 6 | 2.50× | 1.70 min | 12 |
| 8 | 7 | 2.75× | 1.67 min | 12 |
| 9 | 8 | 3.00× | 1.62 min | 12 |
| 10 | 9 | 3.25× | 1.58 min | 12 |

## Verified conclusions

- First Collapse lands inside the 8–15 minute design target in the deterministic model.
- Collapse #2 is materially faster than Collapse #1.
- Every simulated run from C1 through C10 is faster than the previous run.
- All ten runs reach the production Collapse gate without paid boosts.

## Runtime acceptance still required

The final economy is not locked until Roblox runtime QA proves travel time, collectible contention, respawn timing, device performance, and real player routing do not materially break these targets.
