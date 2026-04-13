# Roblox Game Dev Skill

Use this skill when working in this repository on Roblox gameplay, tooling, or architecture tasks.

## Objectives

- Keep work source-first with Rojo where possible
- Protect the existing `Place1.rbxl` snapshot
- Organize code by shared, server, and client runtime boundaries
- Prefer small Luau modules over monolithic scripts

## Project Map

- `default.project.json`: Rojo mapping
- `src/ReplicatedStorage/Shared`: shared modules
- `src/ServerScriptService`: server logic
- `src/StarterPlayer/StarterPlayerScripts`: client logic
- `wally.toml`: dependency manifest
- `.vscode/tasks.json`: common dev commands

## Working Rules

1. Read `AGENTS.md` before substantial edits.
2. Add new gameplay systems under `src/` instead of embedding them only in Studio.
3. If a feature needs packages, update `wally.toml` deliberately and explain why.
4. Keep starter code minimal and readable.
5. When local CLIs are present, verify with formatting and linting before finishing.
