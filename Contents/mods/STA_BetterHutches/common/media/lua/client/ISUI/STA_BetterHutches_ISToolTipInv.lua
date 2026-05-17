local _old_ISToolTipInv_render = ISToolTipInv.render

local Utils = require "STA_BetterHutches_Utils"

function ISToolTipInv:render()
    if (
        true
        and self.item
        and instanceof(self.item, "InventoryItem")
        and self.item:isFood()
        and self.item:hasTag(ItemTag.EGG)
        and self.item:isFertilized()
        and self.tooltip
        and (self.tooltip:getCharacter():getPerkLevel(Perks.Husbandry) >= Utils.getSandboxInt("FertilizedEggLevel"))
    ) then
        local LINE_SPACING = self.tooltip:getLineSpacing()
        local extraH = LINE_SPACING

        local oldH = self:getHeight()

        local fontType = getCore():getOptionTooltipFont()
        local font
        if fontType == "Large" then
            font = UIFont.Large
        elseif fontType == "Medium" then
            font = UIFont.Medium
        else
            font = UIFont.Small
        end

        local charW = getTextManager():MeasureStringX(font, "0")
        local PAD_H = math.floor(charW / 2)

        self:setHeight(oldH + extraH + PAD_H)

        self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
        self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

        local oldBGA = self.backgroundColor.a
        local oldBA = self.borderColor.a
        self.backgroundColor.a = 0
        self.borderColor.a = 0

        _old_ISToolTipInv_render(self)

        self.backgroundColor.a = oldBGA
        self.borderColor.a = oldBA

        local heightOff = self.tooltip:getHeight()

        self.tooltip:DrawText(self.tooltip:getFont(), getText("Tooltip_food_fertilized"), 8, heightOff, 1, 1, 0.8, 1)
    else
        _old_ISToolTipInv_render(self)
    end
end