# Studio Playtest Scenarios

Run `powershell -ExecutionPolicy Bypass -File scripts/check.ps1`, then open
`build/Place1.rbxlx` in Roblox Studio.

## Single-player progression

1. Join as a fresh player and confirm exactly one `SessionStatsGui` appears.
2. Jump once and confirm `Jumps` increases once.
3. Wait 15 seconds and confirm `Coins` increases by 5.
4. Collect the world pickup and confirm another 10 coins are awarded.
5. Reach 20 coins and purchase the speed boost.
6. Confirm coins decrease by exactly 20, `WalkSpeed` becomes 26, and the HUD counts down.
7. Reset the character while the boost is active and confirm the remaining boost is reapplied.
8. Change `WalkSpeed` to 30 from the server during the boost and confirm expiry does not overwrite it.

Report failures with the step number, expected result, actual result, Studio Output, and whether the
problem reproduces after rejoining.

## Two-player isolation

1. Start a local server with two players.
2. Give both players enough coins and buy a boost for only player one.
3. Confirm player two's coins, attributes, and `WalkSpeed` do not change.
4. Collect the shared pickup with player two.
5. Confirm only player two receives coins and the pickup disappears for both players.
6. Wait 8 seconds and confirm exactly one pickup reappears.

Report failures with the affected player, expected result, actual result, and reproduction frequency.
