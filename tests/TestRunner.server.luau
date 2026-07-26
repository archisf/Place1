--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

if #Players:GetPlayers() == 0 then
    Players.PlayerAdded:Wait()
end

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)
local results = TestEZ.TestBootstrap:run({ ServerStorage.Tests }, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
    error(string.format("TestEZ finished with %d failing test(s)", results.failureCount))
end

print(string.format("[TestEZ] %d tests passed", results.successCount))
