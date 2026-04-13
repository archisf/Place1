# Agent Guide

This repository is a Roblox game workspace centered around Rojo and Luau source files.

## Ground Rules

- Do not overwrite or delete `Place1.rbxl` unless explicitly asked.
- Prefer editing source files under `src/` instead of making opaque binary-only changes.
- Keep shared modules in `src/ReplicatedStorage/Shared`.
- Keep server-only logic in `src/ServerScriptService`.
- Keep client-only logic in `src/StarterPlayer/StarterPlayerScripts`.
- Use `stylua` and `selene` when those tools are available locally.
- When using Roblox Studio Assistant, prefer Studio's built-in MCP server over custom ad hoc editor automation.
- For playtesting requests, give the agent a concrete scenario, expected outcome, and bug-report format instead of vague "test the game" prompts.

## Development Expectations

- Make small, composable Luau modules.
- Favor strict, readable code over large framework-heavy abstractions at the start.
- Document assumptions when introducing services, remotes, or state containers.
- If package dependencies are needed, add them to `wally.toml` intentionally.

## Verification

When local tools are installed, prefer this order:

1. `stylua src`
2. `selene src`
3. `rojo serve` or `rojo build default.project.json --output build/Place1.rbxlx`
4. Roblox Studio Assistant playtest pass using the guidance in `docs/STUDIO_ASSISTANT_MCP.md`
