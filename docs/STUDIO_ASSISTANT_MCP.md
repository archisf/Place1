# Studio Assistant MCP

This project is set up to work well with Roblox Studio's newer Assistant workflow:

- Studio Assistant can act directly inside Roblox Studio
- Roblox has introduced a built-in MCP server flow for Studio Assistant integrations
- Roblox is also testing a playtest-oriented agent that can execute concrete gameplay scenarios and report findings

## How To Use It In This Project

1. Open `Place1.rbxl` in Roblox Studio.
2. Start `rojo serve` from this repository when you want source-backed scripts synced into Studio.
3. Use Studio Assistant for place-aware tasks such as editing objects, inserting scripts, or running targeted playtests.
4. Treat `src/` as the long-term source of truth for stable code.
5. After an Assistant-generated Studio change proves useful, move or reconcile it back into source files here.

## Recommended Prompt Style

Avoid:

- "test my game"
- "look for bugs"
- "fix everything"

Prefer prompts that include:

- a concrete gameplay goal
- where the test should happen
- what inputs or tools to use
- what success should look like
- how failures should be reported

## Example Playtest Prompts

### Basic traversal

```text
Playtest the obby start area as a new player.
Spawn at the default spawn point.
Attempt the first five jumps in order without using reset unless you fall.
Expected result: each platform is reachable with normal movement and the checkpoint updates after each successful section.
If anything fails, report the exact obstacle, what input you used, and what happened instead.
```

### Interaction validation

```text
Playtest the shop flow from spawn.
Walk to the shop, open the UI, attempt to buy the starter item, then equip it.
Expected result: the purchase succeeds once, currency updates correctly, and the equipped item appears for the player.
If the flow breaks, report the UI step, any visible error, and whether the server state changed.
```

### Regression pass

```text
Retest the round start flow after the latest spawn-system changes.
Join as a fresh player, wait for a round to start, and verify the player spawns in the arena with controls enabled.
Expected result: one spawn, no duplicate UI, no frozen character, and the round timer appears.
Report any regression with reproduction steps and whether it happens every time.
```

## Team Rules

- Use playtest agents for focused validation, not vague exploration.
- Keep bug reports reproducible and tied to player-facing outcomes.
- Reconcile useful Assistant-made code changes back into `src/` before treating them as complete.
