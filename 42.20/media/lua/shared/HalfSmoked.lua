HalfSmoked = HalfSmoked or {}

-- How many drags each smokable is worth.
-- ponytail: plain table, promote to sandbox options only if people ask to tune it
HalfSmoked.puffs = {
    ["Base.Cigar"]            = 6,
    ["Base.Cigarillo"]        = 4,
    ["Base.CigaretteSingle"]  = 4,
    ["Base.CigaretteRolled"]  = 4,
}

-- Stress removed by smoking one whole item (stress is a 0..1 stat).
HalfSmoked.stressRelief = 0.10

-- Drags taken by "Smoke half". Never 1, or it duplicates "Take a drag".
function HalfSmoked.half(left)
    return math.ceil(left / 2)
end

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
