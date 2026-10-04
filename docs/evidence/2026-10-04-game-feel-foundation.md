# +1 Gravity game-feel foundation — 2026-10-04

Implemented a bounded feedback hierarchy rather than a single repeated cue.

- Small collect: light/high cue
- Medium collect: stronger cue + cyan pulse
- Massive collect: low/strong cue + gold pulse + subtle camera FOV kick
- Level up: dedicated violet cue/pulse
- Zone unlock: dedicated green cue/pulse
- Collapse: charge then impact; 5-Core and 10-Core milestones alter the audio character
- reward events: separate lightweight cue

Performance safeguards cap transient sounds at 4, local pulse VFX at 8 and single transient volume at 0.28. Pure-Luau tests cover band thresholds and milestone classification. Physical speaker mix/comfort remains runtime QA.
