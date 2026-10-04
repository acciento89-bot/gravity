# +1 Gravity monetization UX foundation — 2026-10-04

Implemented the player-facing P14 shop around the existing server receipt pipeline.

- explicit shop; no prompt-on-spawn path
- 2x Gravity / 15 min
- 2x XP / 15 min
- 100 Shards
- hard NOT LIVE/DISABLED state while ProductId == 0
- active boost countdown timers
- purchase prompt submitted feedback
- cancel/aborted feedback
- server `PurchaseGranted` success/saved feedback
- responsive mobile/tablet/desktop/ten-foot layout and controller-selectable cards

The client never grants products. Currency/boost grant and save-before-PurchaseGranted remain in the existing server receipt path. Real product IDs and live purchase/rejoin acceptance remain external gates.
