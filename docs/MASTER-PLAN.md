# +1 Gravity — V1 Master Plan

## Product thesis
Use the familiar +1/rebirth loop, but make progression visually unique: the avatar accumulates an expanding orbit of objects rather than growing, aging, or changing body size.

## Session loop
- Passive +1 Gravity/sec.
- Move through a zone and automatically attract eligible nearby objects.
- Eligible objects grant Gravity bonus + XP.
- XP raises Level.
- Gravity unlocks larger object classes and later zones.
- Level 50 unlocks Collapse.
- Collapse converts the run into one permanent Gravity Core, resets Level/XP/Gravity, grants Shards, and permanently accelerates future XP.

## Permanent progression
- Gravity Cores: +25% XP each.
- Shards: cosmetic currency.
- Orbit skins and Singularity skins.
- Highest Gravity and fastest Collapse records persist.

## V1 world
1. Backyard
2. Downtown
3. Industrial
4. Airport
5. Megacity

## Retention
- Daily challenge.
- Daily login streak.
- Three global leaderboards: Highest Gravity, Total Cores, Fastest Collapse.
- Cosmetic progression driven by Shards and milestone unlocks.

## Monetization direction
Optional acceleration/cosmetics only:
- 2x Gravity 15m
- 2x XP 15m
- Shard pack
- VIP cosmetics/gamepass later

Purchases must not buy leaderboard positions directly. Assisted/boosted fastest-collapse records can be separated if needed.

## Technical direction
- Rojo project.
- Strict Luau.
- DataStore-backed profile.
- OrderedDataStore leaderboards.
- Server-side attraction validation.
- Client-only orbit rendering capped to a small number of parts.
- Deterministic pure-Luau rules for level curve, collapse, zones, dailies and economy.
