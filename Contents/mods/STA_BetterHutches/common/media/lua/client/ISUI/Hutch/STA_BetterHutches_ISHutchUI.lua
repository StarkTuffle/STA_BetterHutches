local _old_ISHutchRoostParentPanel_render = ISHutchRoostParentPanel.render
local _old_ISHutchRoostParentPanel_createChildren = ISHutchRoostParentPanel.createChildren
local _old_ISHutchNestBox_doNestStuff = ISHutchNestBox.doNestStuff
local _old_ISHutchNestBox_onRightMouseUp = ISHutchNestBox.onRightMouseUp

local Utils = require "STA_BetterHutches_Utils"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local UI_BORDER_SPACING = 10
local NEST_BOX_HEIGHT = 130
local PROGRESS_WIDTH = 200
local PADXY = 20

function ISHutchNestBox:onButtonGrabEggType(fertilized)
    local nest = self:getNest()
    if luautils.walkAdj(self.playerObj, self.hutchUI.hutch:getEntrySq()) then
        if self.playerObj:getPrimaryHandItem() then
            ISTimedActionQueue.add(ISUnequipAction:new(self.playerObj, self.playerObj:getPrimaryHandItem(), 50))
        end
        if self.playerObj:getSecondaryHandItem() and self.playerObj:getSecondaryHandItem() ~= self.playerObj:getPrimaryHandItem() then
            ISTimedActionQueue.add(ISUnequipAction:new(self.playerObj, self.playerObj:getSecondaryHandItem(), 50))
        end
        ISTimedActionQueue.add(STA_BetterHutches_ISHutchGrabEggType:new(self.playerObj, nest, self.hutchUI.hutch, fertilized))
    end
end

function ISHutchRoostParentPanel:onWoodchipSelect()
    if luautils.walkAdj(self.chr, self.hutch:getEntrySq()) then
        local item = self.chr:getInventory():getFirstTypeRecurse("STA_BetterHutches.WoodchipsBag")
        ISTimedActionQueue.add(STA_BetterHutches_ISAddWoodchipsToHutch:new(self.chr, self.hutch, item))
    end
end

function ISHutchRoostParentPanel:createChildren()
    self.addWoodchipsBtn = ISButton:new(0, 0, 60, BUTTON_HGT, "", self.hutchUI, ISHutchRoostParentPanel.onWoodchipSelect)
    self.addWoodchipsBtn:initialise()
    self.addWoodchipsBtn.anchorTop = false
    self.addWoodchipsBtn.anchorBottom = false
    self.addWoodchipsBtn.borderColor = self.hutchUI.btnBorder
    self:addChild(self.addWoodchipsBtn)

    _old_ISHutchRoostParentPanel_createChildren(self)
end

function ISHutchRoostParentPanel:render()
    _old_ISHutchRoostParentPanel_render(self)

    local rowX = PADXY
    local boxY = PADXY + 4 * NEST_BOX_HEIGHT + UI_BORDER_SPACING + 30
    local currentWoodChips = Utils.getObjectModData(self.hutchUI.hutch, "hasWoodChips") or 0
    local maxWoodChips = Utils.getSandboxInt("WoodchipsBagAmount")
    local percentWoodChips = currentWoodChips / maxWoodChips

    local playerInv = self.hutchUI.chr:getInventory()
    if not playerInv:containsTypeRecurse("STA_BetterHutches.WoodchipsBag") then
        self.addWoodchipsBtn.enable = false
        self.addWoodchipsBtn.tooltip = getText("IGUI_STA_BetterHutches_NeedWoodchips")
    else
        self.addWoodchipsBtn.enable = true
        self.addWoodchipsBtn.tooltip = nil
    end

    if not self.closedDoorPanel:isVisible() then
        self:drawProgressBar(rowX + PROGRESS_WIDTH + 10, boxY, PROGRESS_WIDTH, FONT_HGT_SMALL, percentWoodChips, self.hutchUI.fgBar)
        self:drawText(getText("IGUI_STA_BetterHutches_Woodchips", round(percentWoodChips * 100, 2)), rowX + PROGRESS_WIDTH + 17, boxY, 1,1,1,1, UIFont.NewSmall)

        self.addWoodchipsBtn:setX(rowX + 70)
        self.addWoodchipsBtn:setY(boxY + FONT_HGT_SMALL + 2)
        self.addWoodchipsBtn:setTitle(getText("IGUI_STA_BetterHutches_AddWoodchips"))
        self.addWoodchipsBtn:setVisible(currentWoodChips < maxWoodChips)
    end
end

function ISHutchNestBox:doNestStuff()
    _old_ISHutchNestBox_doNestStuff(self)

    if not self:getAnimal() and self.playerObj:getPerkLevel(Perks.Husbandry) >= Utils.getSandboxInt("FertilizedEggLevel") then
        local nest = self:getNest()
        for i, pos in ipairs(self.possibleEggPosition) do
            if nest:getEggsNb() >= i then
                if nest:getEgg(i-1):isFertilized() then
                    self:drawTexture(getTexture("Item_Egg"), pos.x, pos.y, 0.5, 1, 0.1, 0.1)
                end
            end
        end
    end
end

function ISHutchNestBox:onRightMouseUp(x, y)
    _old_ISHutchNestBox_onRightMouseUp(self, x, y)

    if self:getNest():getEggsNb() > 0 then
        if self.playerObj:getPerkLevel(Perks.Husbandry) >= Utils.getSandboxInt("FertilizedEggLevel") then
            local context = ISContextMenu.get(self.playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())

            context:addOption(getText("IGUI_Hutch_GrabEggs"), self, ISHutchNestBox.onButtonGrab)
            local unfertOption = context:addOption(getText("IGUI_STA_BetterHutches_GrabUnfertilizedEggs"), self, ISHutchNestBox.onButtonGrabEggType, false)
            local fertOption = context:addOption(getText("IGUI_STA_BetterHutches_GrabFertilizedEggs"), self, ISHutchNestBox.onButtonGrabEggType, true)
            local count = {0,0} -- {Fertilized, Unfertilized}
            for n = 0, self:getNest():getEggsNb() - 1 do
                if self:getNest():getEgg(n):isFertilized() then
                    count[1] = count[1] + 1
                else
                    count[2] = count[2] + 1
                end
            end
            if count[1] == 0 then
                fertOption.notAvailable = true
            end
            if count[2] == 0 then
                unfertOption.notAvailable = true
            end
            if AnimalContextMenu.cheat then
                context:addDebugOption("Remove Egg", self, ISHutchNestBox.onCheatRemoveEgg)
            end
        end
    end
end