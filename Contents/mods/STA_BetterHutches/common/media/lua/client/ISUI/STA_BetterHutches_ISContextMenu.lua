local Utils = require "STA_BetterHutches_Utils"

ContextMenu = STA_BetterHutches_ISContextMenu or {}

---@param playerObj IsoPlayer
---@param hutch IsoHutch
function ContextMenu.onWoodchipSelect(playerObj, hutch)
    local item = playerObj:getInventory():getFirstTypeRecurse("STA_BetterHutches.WoodchipsBag")
    if luautils.walkAdj(playerObj, hutch:getEntrySq()) then
        ISTimedActionQueue.add(STA_BetterHutches_ISAddWoodchipsToHutch:new(playerObj, hutch, item))
    end
end

---@param playerIdx integer
---@param context ISContextMenu
---@param worldObjects ArrayList<IsoObject>
---@param test boolean
function ContextMenu.onFillWorldContext(playerIdx, context, worldObjects, test)
    local playerObj = getSpecificPlayer(playerIdx)
    if playerObj:getVehicle() then return false end
    local inv = playerObj:getInventory()

    if inv:containsTypeRecurse("STA_BetterHutches.WoodchipsBag") then
        local hutch = nil
        for i, v in ipairs(worldObjects) do
            if instanceof(v, "IsoHutch") then
                hutch = v:getHutch()
                break
            end
        end
        if not hutch then return end

        local option
        local tooltip = ISToolTip:new()
        local label = getText("ContextMenu_STA_BetterHutches_AddWoodchips")
        for i, v in ipairs(context.options) do
            if v.name == getText("ContextMenu_Hutch") then
                local hutchSubMenu = context:getSubMenu(v.subOption)
                option = hutchSubMenu:addOption(label, playerObj, ContextMenu.onWoodchipSelect, hutch)
            end
        end

        local woodchipsPresent = Utils.getObjectModData(hutch, "hasWoodChips") or 0
        if woodchipsPresent >= Utils.getSandboxInt("WoodchipsBagAmount") then
            tooltip.description = getText("Tooltip_STA_BetterHutches_AlreadyHasWoodchips")
            option.toolTip = tooltip
            option.notAvailable = true
        else
            tooltip.description = getText("Tooltip_STA_BetterHutches_WoodchipsTooltip")
            option.toolTip = tooltip
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu.onFillWorldContext)

_G.STA_BetterHutches_ISContextMenu = ContextMenu
return ContextMenu