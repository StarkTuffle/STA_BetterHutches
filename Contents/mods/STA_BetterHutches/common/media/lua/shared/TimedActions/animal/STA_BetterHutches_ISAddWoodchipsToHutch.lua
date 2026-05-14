require "TimedActions/ISBaseTimedAction"
local Utils = require "STA_BetterHutches_Utils"

STA_BetterHutches_ISAddWoodchipsToHutch = ISBaseTimedAction:derive("STA_BetterHutches_ISAddWoodchipsToHutch")

function STA_BetterHutches_ISAddWoodchipsToHutch:isValid()
    return (self.character:getInventory():containsType("STA_BetterHutches.WoodchipsBag") and (Utils.getObjectModData(self.hutch, "hasWoodChips") or 0) < Utils.getSandboxInt("WoodchipsBagAmount"))
end

function STA_BetterHutches_ISAddWoodchipsToHutch:waitToStart()
    self.character:faceThisObject(self.hutch)
    return self.character:shouldBeTurning()
end

function STA_BetterHutches_ISAddWoodchipsToHutch:update()
    self.character:faceThisObject(self.hutch)
    self.item:setJobDelta(self:getJobDelta())
end

function STA_BetterHutches_ISAddWoodchipsToHutch:start()
    self.item:setJobType(getText("IGUI_STA_BetterHutches_JobType_PouringWoodchips"))
    self:setActionAnim("Pour")
end

function STA_BetterHutches_ISAddWoodchipsToHutch:stop()
    self.item:setJobDelta(0)
    ISBaseTimedAction.stop(self)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:perform()
    self.item:setJobDelta(0)
    ISBaseTimedAction.perform(self)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:complete()
    local hutchChipCount = Utils.getObjectModData(self.hutch, "hasWoodChips") or 0
    Utils.setObjectModData(self.hutch, "hasWoodChips", hutchChipCount + 1)
    Utils.setObjectModData(self.hutch, "lastDirtLevel", self.hutch:getHutchDirt())
    -- Remove item and add empty sack
    sendRemoveItemFromContainer(self.character:getInventory(), self.item)
    self.character:getInventory():Remove(self.item)
    local emptySack = self.character:getInventory():AddItem("Base.EmptySandbag")
    sendAddItemToContainer(self.character:getInventory(), emptySack)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:getDuration()
    if self.character:isTimedActionInstant() then return 1 end
    return 100
end

function STA_BetterHutches_ISAddWoodchipsToHutch:new(character, hutch, item)
    local o = ISBaseTimedAction.new(self, character)
    o.hutch = hutch
    o.item = item
    o.maxTime = o:getDuration()
    return o
end