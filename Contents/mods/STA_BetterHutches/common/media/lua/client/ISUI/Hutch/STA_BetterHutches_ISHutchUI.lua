local _old_ISHutchRoostParentPanel_render = ISHutchRoostParentPanel.render
local _old_ISHutchRoostParentPanel_createChildren = ISHutchRoostParentPanel.createChildren
local Utils = require "STA_BetterHutches_Utils"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local UI_BORDER_SPACING = 10
local NEST_BOX_HEIGHT = 130
local PROGRESS_WIDTH = 200
local PADXY = 20

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