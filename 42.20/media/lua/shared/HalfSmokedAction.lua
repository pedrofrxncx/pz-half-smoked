require "TimedActions/ISBaseTimedAction"

HalfSmokedAction = ISBaseTimedAction:derive("HalfSmokedAction")

function HalfSmokedAction:isValid()
    return self.character:getInventory():contains(self.item)
       and HalfSmoked.left(self.item) >= self.puffs
end

function HalfSmokedAction:start()
    self:setActionAnim("Eat")
    self.item:setJobDelta(0.0)
end

function HalfSmokedAction:update()
    self.item:setJobDelta(self:getJobDelta())
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function HalfSmokedAction:stop()
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function HalfSmokedAction:perform()
    local item = self.item
    local frac = self.puffs / HalfSmoked.total(item)

    -- Apply this fraction of the item's mood effects.
    -- ponytail: stress is 0..1, boredom/unhappy are 0..100 -- these scales need
    -- an in-game sanity check; tune the divisors here if a drag feels off.
    local stats = self.character:getStats()
    local body  = self.character:getBodyDamage()
    stats:setStress(PZMath.clamp_01(stats:getStress() + (item:getStressChange() * frac) / 100))
    body:setBoredomLevel(PZMath.clamp(body:getBoredomLevel() + item:getBoredomChange() * frac, 0, 100))
    body:setUnhappynessLevel(PZMath.clamp(body:getUnhappynessLevel() + item:getUnhappynessChange() * frac, 0, 100))

    item:getModData().puffsLeft = HalfSmoked.left(item) - self.puffs
    -- ponytail: rename in place, cheapest way to see remaining drags at a glance
    local left = item:getModData().puffsLeft
    if left > 0 then
        item:setName(item:getDisplayName():gsub(" %(%d+ left%)$", "") .. " (" .. left .. " left)")
    end

    item:setJobDelta(0.0)
    ISBaseTimedAction.perform(self)
end

function HalfSmokedAction:new(character, item, puffs)
    local o = ISBaseTimedAction.new(self, character)
    o.item = item
    o.puffs = puffs
    -- vanilla Eattime is for the whole thing; scale it to the fraction smoked
    o.maxTime = (item:getEatTime() or 920) * (puffs / HalfSmoked.total(item))
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
