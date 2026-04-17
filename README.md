# Place1 Roblox Development Workspace

This folder started with a single binary place file: `Place1.rbxl`.

The workspace now includes a source-based Roblox setup so we can build game code in files, keep it in Git, and connect it back to Roblox Studio with Rojo.

It is also prepared for the newer Roblox Studio Assistant workflow, including Studio's built-in MCP server and prompt patterns for the beta playtest agent.

## What Was Added

- `src/` for server, client, and shared Luau code
- `default.project.json` for Rojo syncing
- `wally.toml` for package management
- `stylua.toml` and `selene.toml` for formatting and linting
- `.vscode/` tasks and extension recommendations
- `scripts/` for local development helpers
- `AGENTS.md` and `.codex/skills/` for AI-assisted collaboration
- `docs/STUDIO_ASSISTANT_MCP.md` for Studio Assistant MCP and playtest-agent usage

## Current Game Features

The project now has a simple playable progression loop implemented fully in source files.

- session tracking with `TimePlayed`, `Jumps`, and `Coins` leaderstats
- passive coin rewards over time
- a top-right HUD showing session stats
- milestone feedback in the HUD every 30 seconds
- a spendable speed boost button in the HUD
- server-validated speed boost purchase logic
- a world coin pickup object that rewards coins and respawns

## Gameplay Details

### Session Stats

- `TimePlayed` increases every second
- `Jumps` increases when the player jumps
- `Coins` increase from both passive rewards and world pickups

### Passive Rewards

- players earn `5` coins every `15` seconds

### Speed Boost

- cost: `20` coins
- duration: `12` seconds
- walk speed increases from `16` to `26`
- purchase is validated on the server
- active boost state survives respawn while the timer is still running

### Coin Pickup

- a glowing pickup spawns near `SpawnLocation` if one exists
- otherwise it spawns at `(0, 6, 0)`
- touching it gives `10` coins
- it respawns after `8` seconds

## Recommended Tooling

Install these tools on Windows before active development:

1. Roblox Studio
2. Rojo
3. Wally
4. StyLua
5. Selene
6. Git
7. VS Code

If you already use an installer like `aftman`, `scoop`, or manual binaries, that is fine. The project is set up to work with standard CLI commands like `rojo`, `wally`, `stylua`, and `selene`.

## Suggested Workflow

1. Open this folder in VS Code.
2. Install the recommended extensions.
3. Install Rojo, Wally, StyLua, and Selene.
4. Run `wally install` when you start adding dependencies.
5. Run `rojo serve`.
6. Open Roblox Studio and connect the Rojo plugin to the running server.
7. If you are using Roblox Studio Assistant, enable the built-in MCP workflow and use the playtest agent with scenario-driven prompts.
8. Keep gameplay code inside `src/` and treat `Place1.rbxl` as the legacy snapshot until you fully migrate.

## How To Test

1. Run `rojo serve default.project.json`.
2. Open `Place1.rbxl` in Roblox Studio.
3. Connect with the Rojo plugin.
4. Press Play.
5. Verify `leaderstats` appear for the player.
6. Wait to earn coins or collect the world pickup.
7. Buy the speed boost from the HUD once you have enough coins.

You can also open `build/Place1.rbxlx` directly in Studio after a `rojo build` if you want to test a built snapshot instead of live sync.

## Main Source Files

- `src/ReplicatedStorage/Shared/init.luau`: shared gameplay configuration and formatting helpers
- `src/ServerScriptService/main.server.luau`: leaderstats, passive rewards, pickups, and boost purchase logic
- `src/StarterPlayer/StarterPlayerScripts/main.client.luau`: HUD, boost button, and client-side status updates

## Project Layout

```text
src/
  ReplicatedStorage/
    Shared/
  ServerScriptService/
  StarterPlayer/
    StarterPlayerScripts/
scripts/
.vscode/
.codex/skills/
```

## Notes

- `Place1.rbxl` is preserved and not modified by this setup.
- The starter scripts are intentionally minimal so we can grow the architecture cleanly.
- Wally is configured but no gameplay dependencies are forced yet.
- Studio Assistant guidance is documented separately so AI playtests and source-based changes stay aligned.
