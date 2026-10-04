# +1 Gravity platform layout foundation — 2026-10-04

## Change

The HUD no longer treats every viewport with a short edge >= 620 pixels as the same device class. A pure `ViewportRules` layer now distinguishes:

- compact touch phone;
- touch tablet;
- non-touch desktop;
- true ten-foot/console via `GuiService:IsTenFootInterface()`.

Each class has an explicit HUD budget for top bar, tutorial, daily card and Collapse action. Console receives deliberately larger typography and action targets; tablet stays between phone and desktop density.

## Verification

- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Pure-Luau suite includes platform classification/sizing regression coverage
- Release-readiness: only the existing six external Roblox configuration blockers remain
- Rojo canonical build: pass

Runtime screenshot acceptance remains intentionally open for P10-T13/P10-T14/P10-T15.
