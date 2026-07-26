--!strict
-- selene: allow(deprecated)

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Server = ServerScriptService.Server
local BoostService = require(Server.BoostService)
local BoostState = require(Server.BoostState)
local Leaderstats = require(Server.Leaderstats)
local RemoteRegistry = require(Server.RemoteRegistry)
local StatsService = require(Server.StatsService)

return function()
    local environment = getfenv() :: any
    local describe = environment.describe
    local expect = environment.expect
    local it = environment.it

    describe("leaderstats", function()
        it("creates every expected value and remains idempotent", function()
            local container = Instance.new("Folder")
            local first = Leaderstats.ensure(container)
            local second = Leaderstats.ensure(container)

            expect(first).to.equal(second)
            expect((first:FindFirstChild("TimePlayed") :: Instance):IsA("IntValue")).to.equal(true)
            expect((first:FindFirstChild("Jumps") :: Instance):IsA("IntValue")).to.equal(true)
            expect((first:FindFirstChild("Coins") :: Instance):IsA("IntValue")).to.equal(true)

            container:Destroy()
        end)

        it("repairs a partial folder without replacing existing values", function()
            local container = Instance.new("Folder")
            local folder = Instance.new("Folder")
            folder.Name = "leaderstats"
            folder.Parent = container

            local coins = Instance.new("IntValue")
            coins.Name = "Coins"
            coins.Value = 17
            coins.Parent = folder

            local result = Leaderstats.ensure(container)
            local resultCoins = result:FindFirstChild("Coins") :: IntValue

            expect(resultCoins).to.equal(coins)
            expect(resultCoins.Value).to.equal(17)
            expect((result:FindFirstChild("TimePlayed") :: Instance):IsA("IntValue")).to.equal(true)
            expect((result:FindFirstChild("Jumps") :: Instance):IsA("IntValue")).to.equal(true)

            container:Destroy()
        end)

        it("fails clearly when an expected name has the wrong class", function()
            local container = Instance.new("Folder")
            local collision = Instance.new("StringValue")
            collision.Name = "leaderstats"
            collision.Parent = container

            expect(function()
                Leaderstats.ensure(container)
            end).to.throw()

            container:Destroy()
        end)
    end)

    describe("remote registry", function()
        it("creates one stable RemoteFunction", function()
            local container = Instance.new("Folder")
            local first = RemoteRegistry.getPurchaseSpeedBoost(container)
            local second = RemoteRegistry.getPurchaseSpeedBoost(container)

            expect(first).to.equal(second)
            expect(first:IsA("RemoteFunction")).to.equal(true)

            container:Destroy()
        end)

        it("rejects class collisions", function()
            local container = Instance.new("Folder")
            local collision = Instance.new("StringValue")
            collision.Name = "Remotes"
            collision.Parent = container

            expect(function()
                RemoteRegistry.getPurchaseSpeedBoost(container)
            end).to.throw()

            container:Destroy()
        end)
    end)

    describe("boost state", function()
        it("tracks active and expired states without negative remaining time", function()
            local state = BoostState.create(100, 12, 4)

            expect(state.expiresAt).to.equal(112)
            expect(state.token).to.equal(4)
            expect(BoostState.isActive(state, 111.9)).to.equal(true)
            expect(BoostState.isActive(state, 112)).to.equal(false)
            expect(BoostState.getRemaining(state, 120)).to.equal(0)
        end)
    end)

    describe("server player lifecycle", function()
        it("starts, purchases once, and cleans all tracked state", function()
            local player = Players:GetPlayers()[1]

            expect(player).never.to.equal(nil)
            player = player :: Player

            StatsService.stopPlayer(player)
            BoostService.stopPlayer(player)
            StatsService.startPlayer(player)
            BoostService.startPlayer(player)

            local coins = StatsService.getCoinsValue(player)
            coins.Value = 20

            local purchased = BoostService.purchase(player)

            expect(purchased).to.equal(true)
            expect(coins.Value).to.equal(0)
            expect(player:GetAttribute("SpeedBoostActive")).to.equal(true)
            expect(StatsService.isTracking(player)).to.equal(true)
            expect(BoostService.isTracking(player)).to.equal(true)

            BoostService.stopPlayer(player)
            StatsService.stopPlayer(player)

            expect(player:GetAttribute("SpeedBoostActive")).to.equal(false)
            expect(StatsService.isTracking(player)).to.equal(false)
            expect(BoostService.isTracking(player)).to.equal(false)
        end)
    end)
end
