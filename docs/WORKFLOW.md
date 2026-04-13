# Roblox Workflow

## Current State

The original project content is stored in `Place1.rbxl`.

The source-first workflow added here lets you move code into `src/` over time instead of keeping everything trapped inside a binary place file.

## Migration Strategy

1. Keep using `Place1.rbxl` as the playable baseline.
2. Start `rojo serve`.
3. Open the place in Roblox Studio.
4. Use the Rojo plugin to sync the file tree into Studio.
5. Move scripts gradually from the place into `src/`.
6. Once the project is largely file-based, prefer building and syncing from source.
7. Use Studio Assistant and the beta playtest agent as validation layers on top of the source workflow, not as a replacement for source control.

## Coding Conventions

- Shared modules live in `ReplicatedStorage/Shared`.
- Server code lives in `ServerScriptService`.
- Local player code lives in `StarterPlayerScripts`.
- Avoid circular dependencies between shared modules and gameplay scripts.
- Keep remote events and remote functions organized and named intentionally.

## Assistant Workflow

- Use Studio Assistant for scene edits, quick code generation, and playtest tasks that benefit from direct Studio context.
- Keep file-backed code authoritative in this repository even when Assistant edits scripts in Studio.
- After Assistant-generated changes, move stable logic back into `src/` so it stays reviewable and versioned.
- For playtest runs, define the map area, player goal, win or fail condition, and any special controls the agent should use.
