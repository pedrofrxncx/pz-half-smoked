require "ISUI/ISInventoryPaneContextMenu"

-- Mirrors the smokable branch of ISInventoryPaneContextMenu.eatItem so the menu
-- does not offer a drag you have no way to light.
local function canLight(playerObj)
    local vehicle = playerObj:getVehicle()
    if vehicle and vehicle:canLightSmoke(playerObj) then return true end
    return ISInventoryPaneContextMenu.hasOpenFlame(playerObj) and true or false
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
    if not canLight(playerObj) then return end

    local left, total = HalfSmoked.left(item), HalfSmoked.total(item)
    local sub = context:addOption(getText("ContextMenu_HalfSmoked"), nil, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(sub, menu)

    menu:addOption(getText("ContextMenu_HalfSmoked_Drag"), playerObj, drag, item, 1)
    if left >= 2 then
        menu:addOption(getText("ContextMenu_HalfSmoked_Half"), playerObj, drag, item, math.floor(left / 2))
    end
    menu:addOption(getText("ContextMenu_HalfSmoked_Finish"), playerObj, drag, item, left)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
