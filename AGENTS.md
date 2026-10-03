# AGENTS.md

## Product
+1 Gravity is a small-scope but production-quality Roblox progression game.

## Execution rules
- Read README -> MASTER-PLAN -> ART-DIRECTION -> V1 LEDGER before implementation.
- Work only on main; do not create parallel QA places/build branches unless explicitly required.
- Use strict Luau.
- Server authority for Gravity, XP, Level, Cores, Shards, unlocks, daily progress, leaderboards, entitlements, and receipts.
- Client owns presentation only: orbit visuals, UI, VFX, camera polish.
- Run StyLua, Selene, Rojo build, pure-Luau tests, and release-readiness before marking tasks complete.
- Commit and push coherent verified work to main.
- Keep runtime/device-only acceptance as [~] until verified in Studio/device emulation.

## UX rules
- Mobile-first.
- Avatar always visible.
- At a glance the player must understand: current Gravity, current Level, next level progress, Cores, current zone, Collapse eligibility.
- First useful action in under 10 seconds.
- No modal purchase UI on spawn.
- Touch/controller focus must be deliberate.
- Orbit visuals must never obscure the avatar/camera.

## Artifact hygiene
- Temporary QA belongs under /tmp/plus1gravity-qa.
- Curated release evidence belongs under docs/evidence/.
- Never write QA artifacts to the user's Desktop.
