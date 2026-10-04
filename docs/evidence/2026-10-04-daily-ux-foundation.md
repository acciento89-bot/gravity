# +1 Gravity daily UX foundation — 2026-10-04

Implemented the missing P12 player-facing daily flow and streak escalation.

## Reward curve

- base: 15 Shards
- +5 Shards every 3 consecutive days
- bonus capped at +30 Shards
- maximum daily mission reward: 45 Shards

The reward is calculated on the server from persisted `DailyStreak`; the client cannot grant currency.

## UX

- Daily button and detail panel
- mission label and progress bar
- current streak
- today's authoritative reward
- UTC-day explanatory copy
- dedicated Daily Complete celebration driven by the authoritative `DailyComplete` state event
- responsive phone/tablet/desktop/ten-foot sizing

Date-boundary/rejoin runtime proof remains a canonical-place gate.
