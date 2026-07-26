# Tests

The Studio test place runs TestEZ specifications for shared rules and server services.

1. Install the pinned tools with `rokit install`.
2. Run `powershell -ExecutionPolicy Bypass -File scripts/check.ps1`.
3. Open `build/Place1Tests.rbxlx` in Roblox Studio.
4. Press **Play** so the server runner has a test player.
5. Confirm Studio Output reports zero TestEZ failures.

TestEZ 0.4.1 is intentionally isolated to `tests.project.json` and is not included in the regular
game build. The project is archived upstream, so a future migration should replace only the runner
and specs without changing gameplay modules.

See `PLAYTEST.md` for single-player and multiplayer acceptance scenarios.
