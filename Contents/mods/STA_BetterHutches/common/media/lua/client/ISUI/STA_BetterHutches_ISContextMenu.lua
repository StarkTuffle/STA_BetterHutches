local Utils = require "STA_BetterHutches_Utils"

local ContextMenu = STA_BetterHutches_ISContextMenu or {}

local function predicateNotBroken(item)
    return not item:isBroken()
end

---@param playerObj IsoPlayer
---@param hutch IsoHutch
function ContextMenu.onWoodchipSelect(playerObj, hutch)
    if luautils.walkAdj(playerObj, hutch:getEntrySq()) then
        local item = playerObj:getInventory():getFirstTypeRecurse("STA_BetterHutches.WoodchipsBag")
        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
        ISTimedActionQueue.add(STA_BetterHutches_ISAddWoodchipsToHutch:new(playerObj, hutch, item))
    end
end

---@param playerObj IsoPlayer
---@param hutch IsoHutch
function ContextMenu.onInstallAutoDoorSelect(playerObj, hutch)
    local item = playerObj:getInventory():getFirstTypeRecurse("STA_BetterHutches.AutomaticHutchDoor")
    local tool = playerObj:getInventory():getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
    ISTimedActionQueue.add(STA_BetterHutches_ISInstallAutoDoor:new(playerObj, hutch, tool, item))
end

---@param playerObj IsoPlayer
---@param hutch IsoHutch
function ContextMenu.onUninstallAutoDoorSelect(playerObj, hutch)
    local tool = playerObj:getInventory():getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
    ISTimedActionQueue.add(STA_BetterHutches_ISUninstallAutoDoor:new(playerObj, hutch, tool))
end

---@param playerIdx integer
---@param context ISContextMenu
---@param worldObjects ArrayList<IsoObject>
---@param test boolean
function ContextMenu.onFillWorldContext(playerIdx, context, worldObjects, test)
    local playerObj = getSpecificPlayer(playerIdx)
    if playerObj:getVehicle() then return false end
    local inv = playerObj:getInventory()

    local hutch = nil
    for i, v in ipairs(worldObjects) do
        if instanceof(v, "IsoHutch") then
            hutch = v:getHutch()
            break
        end
    end
    if not hutch then return end

    local hutchSubMenu = nil
    for i, v in ipairs(context.options) do
        if v.name == getText("ContextMenu_Hutch") then
            hutchSubMenu = context:getSubMenu(v.subOption)
        end
    end
    if not hutchSubMenu then return end

    if inv:containsTypeRecurse("STA_BetterHutches.WoodchipsBag") then
        local option
        local tooltip = ISToolTip:new()
        local label = getText("ContextMenu_STA_BetterHutches_AddWoodchips")

        option = hutchSubMenu:addOption(label, playerObj, ContextMenu.onWoodchipSelect, hutch)

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

    if Utils.getObjectModData(hutch, "automaticDoorInstalled") then
        -- Uninstall option
        local option
        local tooltip = ISToolTip:new()
        local label = getText("ContextMenu_STA_BetterHutches_UninstallAutoDoor")

        local screwdriver = playerObj:getInventory():containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)

        option = hutchSubMenu:addOption(label, playerObj, ContextMenu.onUninstallAutoDoorSelect, hutch)

        tooltip.description = getText("Tooltip_craft_Needs") .. " : <LINE>"
        if not screwdriver then
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. getItemDisplayName("Base.Screwdriver") .. " 0/1 <LINE>"
            option.notAvailable = true
        else
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. getItemDisplayName("Base.Screwdriver") .. " " .. playerObj:getInventory():getCountTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken) .. "/1 <LINE>"
        end

        option.toolTip = tooltip
    elseif inv:containsTypeRecurse("STA_BetterHutches.AutomaticHutchDoor") then
        -- Install option

        local option
        local tooltip = ISToolTip:new()
        local label = getText("ContextMenu_STA_BetterHutches_InstallAutoDoor")

        local screwdriver = playerObj:getInventory():containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)

        option = hutchSubMenu:addOption(label, playerObj, ContextMenu.onInstallAutoDoorSelect, hutch)

        tooltip.description = getText("Tooltip_craft_Needs") .. " : <LINE>"
        if not screwdriver then
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. getItemDisplayName("Base.Screwdriver") .. " 0/1 <LINE>"
            option.notAvailable = true
        else
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. getItemDisplayName("Base.Screwdriver") .. " " .. playerObj:getInventory():getCountTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken) .. "/1 <LINE>"
        end

        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. getItemDisplayName("STA_BetterHutches.AutomaticHutchDoor") .. " " .. playerObj:getInventory():getCountTypeRecurse("STA_BetterHutches.AutomaticHutchDoor") .. "/1 <LINE>"

        option.toolTip = tooltip
    end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu.onFillWorldContext)

_G.STA_BetterHutches_ISContextMenu = ContextMenu
return ContextMenu