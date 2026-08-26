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
    -- B42 keeps boredom/unhappiness on Stats via the CharacterStat enum --
    -- BodyDamage has no setters for them. Scale is 0..100, matching the script
    -- values (Cigar is UnhappyChange = -40, BoredomChange = -20).
    local stats = self.character:getStats()
    stats:add(CharacterStat.BOREDOM, item:getBoredomChange() * frac)
    stats:add(CharacterStat.UNHAPPINESS, item:getUnhappyChange() * frac)

    -- Stress lives on the same enum in B42; Stats has no get/setStress.
    -- ponytail: no item getter for StressChange, so this is a flat constant.
    stats:add(CharacterStat.STRESS, -HalfSmoked.stressRelief * frac)

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
