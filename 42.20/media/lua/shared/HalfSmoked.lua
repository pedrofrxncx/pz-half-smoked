HalfSmoked = HalfSmoked or {}

-- How many drags each smokable is worth.
-- ponytail: plain table, promote to sandbox options only if people ask to tune it
HalfSmoked.puffs = {
    ["Base.Cigar"]            = 6,
    ["Base.Cigarillo"]        = 4,
    ["Base.CigaretteSingle"]  = 3,
    ["Base.CigaretteRolled"]  = 3,
}

-- Stress removed by smoking one whole item (stress is a 0..1 stat).
HalfSmoked.stressRelief = 0.10

function HalfSmoked.total(item)
    return HalfSmoked.puffs[item:getFullType()]
end

function HalfSmoked.isSmokable(item)
    return item and HalfSmoked.total(item) ~= nil
end

-- Lives in the item's ModData, so it persists across saves AND travels with the
-- item when you hand it to another player. That is the whole sharing feature.
function HalfSmoked.left(item)
    local md = item:getModData()
    if md.puffsLeft == nil then
        md.puffsLeft = HalfSmoked.total(item)
    end
    return md.puffsLeft
end

function HalfSmoked.isPartial(item)
    return HalfSmoked.isSmokable(item) and HalfSmoked.left(item) < HalfSmoked.total(item)
end
