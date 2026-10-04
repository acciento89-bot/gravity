# +1 Gravity — World Layout / Landmark Hierarchy

## Global axis and progression

The canonical V1 world is a single readable west→east progression corridor approximately 975 studs across. `GravityBoulevard` is the continuous navigation spine; zone gates, signs and skyline silhouettes communicate progression without giant waypoint arrows.

## Spawn / Backyard

Center: `(0, 0, 0)`, footprint approximately `150 × 150` studs.

Landmark hierarchy:
1. eight invisible safe spawn slots on a 3-stud ring around origin;
2. deterministic first-five Soda Can route at x = 6 / 13 / 20 / 27 / 34;
3. early size escalation: Toy Block → Shoe → Garden Chair → Barbecue through x = 72;
4. Backyard dressing and readable ordinary-object scale;
5. cyan `DOWNTOWN AHEAD · 120 GRAVITY` exit beacon.

Every spawn slot remains within the 10-stud base attraction radius of the first Soda Can.

## Downtown

Center: `(190, 0, 0)`, approximately `170 × 160` studs. Unlock: 120 Gravity.

Landmark hierarchy: street/urban structures first, then clear vehicle escalation toward Compact Car. Cyan language differentiates the zone from Backyard while keeping the boulevard legible.

## Industrial

Center: `(390, 0, 0)`, approximately `180 × 170` studs. Unlock: 650 Gravity.

Landmark hierarchy: warehouses / industrial dressing, pallet/barrel/tool chest progression, then Forklift and Cargo Container as the primary mass escalation. Warm orange accent.

## Airport

Center: `(610, 0, 0)`, approximately `210 × 180` studs. Unlock: 2,200 Gravity + 1 Core.

Landmark hierarchy: terminal/control-tower language, runway markings, service/luggage carts, Airport Bus, Jet Stair, then Jet Engine. Violet accent.

## Megacity

Center: `(860, 0, 0)`, approximately `230 × 190` studs. Unlock: 7,000 Gravity + 3 Cores.

Landmark hierarchy: tall towers framing the path, skyline spire, sky rail, massive-object progression and a world-space Top Gravity board. Gold accent marks endgame status.

## Zone-gate language

Every gated zone exposes:
- zone number/name;
- exact Gravity requirement;
- exact Core requirement when applicable;
- a physical ForceField gate state plus HUD text feedback.

## Navigation rule

The player should be able to infer the next destination from boulevard direction, skyline/landmarks, physical gates and requirement signs. No progression-critical route depends on an arrow, menu, audio cue or color alone.

## Performance / multiplayer constraints

- 25 collectible classes × 6 copies = 150 collectible roots maximum.
- 8-player release target.
- Client orbit capped to 14 representatives.
- Attraction radius capped at 30 studs.
- Collection cap: 5 objects per 0.2-second server scan.
- Streaming remains optional for the current ~975-stud V1 and must be enabled only if device profiling justifies it.
