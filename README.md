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
