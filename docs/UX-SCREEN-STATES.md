# +1 Gravity — UX / Screen-State Specification

## Product surface

The avatar and the 3D world remain the dominant visual layer. Permanent HUD occupies the top/status region and small right-side entry buttons; large modal surfaces appear only after explicit player input.

## Persistent gameplay HUD

### Top status bar
- Gravity value: primary metric.
- Level: current 0–50 progression state.
- Cores: permanent Collapse count/progression.
- Current zone: visible outside compact-phone mode.
- Level progress track: thin non-blocking strip.

### Context tutorial
The tutorial surface is state-driven and never blocks controls:
1. `TotalObjects == 0`: walk forward / proximity collection explanation.
2. `TotalObjects < 5`: follow the road and collect the guided first-five path.
3. `Cores == 0 && Level < 10`: larger Gravity → larger objects; Downtown at 120 Gravity.
4. `Cores == 0 && Level 35–49`: exact Collapse requirement: Level 50 + 5K Gravity.
5. otherwise hidden.

### Daily summary
A compact bottom-left status surface shows mission/progress or completed streak state. Full details are optional and available from the Daily menu.

### Collapse action
Bottom-right action appears only when the authoritative server snapshot reports `CanCollapse == true`. No hidden menu knowledge is required to progress.

## Right-side root navigation

Ordered controller focus chain:
1. Style
2. Daily
3. Rankings
4. Shop
5. Accessibility

Each root button is explicit opt-in. No shop/product prompt is allowed on spawn.

## Modal states

### Style
Tabs: Orbit / Core.
States per cosmetic: price, insufficient Shards, owned, equipped, equip action. Preview color comes from the same cosmetic definition used by gameplay.

### Daily
Mission name, progress bar, streak, current authoritative Shard reward. Completion triggers a dedicated celebration.

### Rankings
Tabs: Highest Gravity / Total Cores / Fastest Collapse. Fastest is explicitly unboosted-only. Loading, empty, cooldown and unavailable states have text labels.

### Shop
Three V1 products: 2× Gravity 15m, 2× XP 15m, 100 Shards. Product ID `0` renders NOT LIVE / disabled and cannot call the purchase prompt. Active boost countdowns remain visible in the shop.

### Accessibility
Reduced Motion toggle. It reduces orbit speed/bob, Collapse scale/blur/flash and disables collection camera kick. Critical objectives do not depend on sound or color.

## Responsive profiles

- Phone: compressed top bar, zone name hidden, 11px minimum compact tutorial/daily text, smaller action target while preserving Roblox movement controls.
- Tablet: intermediate 600px content budget and larger touch targets.
- Desktop: centered compact 16:9 HUD.
- Console / ten-foot: larger type, larger Collapse target, larger supporting panels and Selectable controller focus.

## Event feedback hierarchy

- Small / Medium / Massive collect: distinct sound hierarchy; Medium/Massive add local pulse VFX.
- Object Gravity threshold crossed: dedicated unlock sting.
- Level up: dedicated sound + pulse.
- Zone unlocked / entered / locked: distinct text and cue states.
- Daily complete: explicit reward celebration.
- Collapse: charge → impact sequence → +1 Core reward → reset.

All critical text is available in English and German with English fallback for unsupported locales.
