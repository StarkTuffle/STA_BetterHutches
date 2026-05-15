require "TimedActions/ISBaseTimedAction"
local Utils = require "STA_BetterHutches_Utils"

STA_BetterHutches_ISUninstallAutoDoor = ISBaseTimedAction:derive("STA_BetterHutches_ISUninstallAutoDoor")

function STA_BetterHutches_ISUninstallAutoDoor:isValid()
    return (self.character:getInventory():containsID(self.tool:getID())) and (Utils.getObjectModData(self.hutch, "automaticDoorInstalled"))
end

function STA_BetterHutches_ISUninstallAutoDoor:waitToStart()
    self.character:faceThisObject(self.hutch)
    return self.character:shouldBeTurning()
end

function STA_BetterHutches_ISUninstallAutoDoor:update()
    self.character:faceThisObject(self.hutch)
    self.tool:setJobDelta(self:getJobDelta())
end

function STA_BetterHutches_ISUninstallAutoDoor:start()
    self.tool:setJobType(getText("IGUI_STA_BetterHutches_JobType_UninstallAutoDoor"))
    self:setActionAnim("Making")
end

function STA_BetterHutches_ISUninstallAutoDoor:stop()
    self.tool:setJobDelta(0)
    ISBaseTimedAction.stop(self)
end

function STA_BetterHutches_ISUninstallAutoDoor:perform()
    self.tool:setJobDelta(0)
    ISBaseTimedAction.perform(self)
end

function STA_BetterHutches_ISUninstallAutoDoor:complete()
    Utils.setObjectModData(self.hutch, "automaticDoorInstalled", false)
    local item = self.character:getInventory():AddItem("STA_BetterHutches.AutomaticHutchDoor")
    sendAddItemToContainer(self.character:getInventory(), item)
end

function STA_BetterHutches_ISUninstallAutoDoor:getDuration()
    if self.character:isTimedActionInstant() then return 1 end
    return 200
end

function STA_BetterHutches_ISUninstallAutoDoor:new(character, hutch, tool)
    local o = ISBaseTimedAction.new(self, character)
    o.hutch = hutch
    o.tool = tool
    o.maxTime = o:getDuration()
    return o
end