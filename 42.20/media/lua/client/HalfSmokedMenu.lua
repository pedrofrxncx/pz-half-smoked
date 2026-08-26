require "ISUI/ISInventoryPaneContextMenu"

-- Mirrors the smokable branch of ISInventoryPaneContextMenu.eatItem so the menu
-- does not offer a drag you have no way to light. hasOpenFlame() alone is NOT
-- enough -- it only finds campfires/stoves/fireplaces, never a pocket lighter.
local function canLight(playerObj, item)
    local vehicle = playerObj:getVehicle()
    if vehicle and vehicle:canLightSmoke(playerObj) then return true end
    if ISInventoryPaneContextMenu.hasOpenFlame(playerObj) then return true end

    local types = item:getRequireInHandOrInventory()
    if not types then return true end
    -- ponytail: does not check that a lighter still has fuel; vanilla will
    -- refuse the action anyway if it is empty.
    local inv = playerObj:getInventory()
    for i = 1, types:size() do
        local fullType = moduleDotType(item:getModule(), types:get(i - 1))
        if inv:getFirstTypeRecurse(fullType) then return true end
    end
    return false
end

local function drag(playerObj, item, puffs)
    if puffs >= HalfSmoked.left(item) then
        -- Final drag: hand off to vanilla so nicotine withdrawal bookkeeping and
        -- item removal stay the engine's job, and fire exactly once per cigar.
        ISInventoryPaneContextMenu.eatItem(item, 1.0, playerObj:getPlayerNum())
    else
        ISTimedActionQueue.add(HalfSmokedAction:new(playerObj, item, puffs))
    end
end

local function onFillInventoryObjectContextMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    local item = items[1]
    if item and not instanceof(item, "InventoryItem") then item = item.items[1] end
    if not HalfSmoked.isSmokable(item) then return end
    if not canLight(playerObj, item) then return end

    local left = HalfSmoked.left(item)
    local sub = context:addOption(getText("ContextMenu_HalfSmoked"), nil, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(sub, menu)

    menu:addOption(getText("ContextMenu_HalfSmoked_Drag"), playerObj, drag, item, 1)
    local half = HalfSmoked.half(left)
    if half > 1 and half < left then
        menu:addOption(getText("ContextMenu_HalfSmoked_Half"), playerObj, drag, item, half)
    end
    menu:addOption(getText("ContextMenu_HalfSmoked_Finish"), playerObj, drag, item, left)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
