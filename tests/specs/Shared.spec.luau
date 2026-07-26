--!strict
-- selene: allow(deprecated)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Shared)

return function()
    local environment = getfenv() :: any
    local describe = environment.describe
    local expect = environment.expect
    local it = environment.it

    describe("shared formatting", function()
        it("formats clocks and clamps negative input", function()
            expect(Shared.formatClock(65.9)).to.equal("01:05")
            expect(Shared.formatClock(-4)).to.equal("00:00")
        end)

        it("formats integer coins and decimal durations", function()
            expect(Shared.formatCoins(12.9)).to.equal("12")
            expect(Shared.formatCoins(-2)).to.equal("0")
            expect(Shared.formatDuration(1.26)).to.equal("1.3s")
            expect(Shared.formatDuration(-1)).to.equal("0.0s")
        end)
    end)

    describe("economy rules", function()
        it("rewards only positive configured intervals", function()
            expect(Shared.EconomyRules.getPassiveCoinReward(-1)).to.equal(0)
            expect(Shared.EconomyRules.getPassiveCoinReward(0)).to.equal(0)
            expect(Shared.EconomyRules.getPassiveCoinReward(14)).to.equal(0)
            expect(Shared.EconomyRules.getPassiveCoinReward(15)).to.equal(5)
            expect(Shared.EconomyRules.getPassiveCoinReward(30)).to.equal(5)
        end)

        it("rejects an active boost without spending coins", function()
            local decision = Shared.EconomyRules.evaluateSpeedBoostPurchase(100, true)

            expect(decision.succeeded).to.equal(false)
            expect(decision.remainingCoins).to.equal(100)
            expect(decision.message).to.equal("Speed boost already active.")
        end)

        it("rejects insufficient funds without spending coins", function()
            local decision = Shared.EconomyRules.evaluateSpeedBoostPurchase(19, false)

            expect(decision.succeeded).to.equal(false)
            expect(decision.remainingCoins).to.equal(19)
            expect(decision.message).to.equal("Need 20 coins for boost.")
        end)

        it("deducts the cost exactly once for a valid purchase", function()
            local firstDecision = Shared.EconomyRules.evaluateSpeedBoostPurchase(20, false)
            local secondDecision =
                Shared.EconomyRules.evaluateSpeedBoostPurchase(firstDecision.remainingCoins, true)

            expect(firstDecision.succeeded).to.equal(true)
            expect(firstDecision.remainingCoins).to.equal(0)
            expect(secondDecision.succeeded).to.equal(false)
            expect(secondDecision.remainingCoins).to.equal(0)
        end)

        it("applies request and pickup debounce boundaries", function()
            expect(Shared.EconomyRules.canProcessBoostRequest(nil, 10)).to.equal(true)
            expect(Shared.EconomyRules.canProcessBoostRequest(10, 10.24)).to.equal(false)
            expect(Shared.EconomyRules.canProcessBoostRequest(10, 10.25)).to.equal(true)
            expect(Shared.EconomyRules.canCollectPickup(10, 10.74)).to.equal(false)
            expect(Shared.EconomyRules.canCollectPickup(10, 10.75)).to.equal(true)
        end)
    end)

    describe("HUD view model", function()
        it("builds idle, in-flight, active, and failed states", function()
            local idle = Shared.HudViewModel.getBoostUi(false, nil, 100, false)
            local inFlight = Shared.HudViewModel.getBoostUi(false, nil, 100, true)
            local active = Shared.HudViewModel.getBoostUi(true, 105, 100, false)

            expect(idle.buttonText).to.equal("Use Speed Boost")
            expect(idle.buttonActive).to.equal(true)
            expect(inFlight.buttonText).to.equal("Buying...")
            expect(inFlight.buttonActive).to.equal(false)
            expect(active.buttonText).to.equal("Boost Active")
            expect(active.statusText).to.equal("Boost active: +10 speed for 5.0s")
            expect(Shared.HudViewModel.getPurchaseFeedback(false, nil, nil)).to.equal(
                "Boost purchase failed. Try again."
            )
        end)
    end)
end
