require "TimedActions/ISBaseTimedAction"
local Utils = require "STA_BetterHutches_Utils"

STA_BetterHutches_ISInstallAutoDoor = ISBaseTimedAction:derive("STA_BetterHutches_ISInstallAutoDoor")

function STA_BetterHutches_ISInstallAutoDoor:isValid()
    return (self.character:getInventory():containsTypeRecurse("STA_BetterHutches.AutomaticHutchDoor") and (not Utils.getObjectModData(self.hutch, "automaticDoorInstalled")))
end

function STA_BetterHutches_ISInstallAutoDoor:waitToStart()
    self.character:faceThisObject(self.hutch)
    return self.character:shouldBeTurning()
end

function STA_BetterHutches_ISInstallAutoDoor:update()
    self.character:faceThisObject(self.hutch)
    self.item:setJobDelta(self:getJobDelta())
    self.tool:setJobDelta(self:getJobDelta())
end

function STA_BetterHutches_ISInstallAutoDoor:start()
    self.item:setJobType(getText("IGUI_STA_BetterHutches_JobType_InstallAutoDoor"))
    self.tool:setJobType(getText("IGUI_STA_BetterHutches_JobType_InstallAutoDoor"))
    self:setActionAnim("Making")
end

function STA_BetterHutches_ISInstallAutoDoor:stop()
    self.item:setJobDelta(0)
    self.tool:setJobDelta(0)
    ISBaseTimedAction.stop(self)
end

function STA_BetterHutches_ISInstallAutoDoor:perform()
    self.item:setJobDelta(0)
    self.tool:setJobDelta(0)
    ISBaseTimedAction.perform(self)
end

function STA_BetterHutches_ISInstallAutoDoor:complete()
    Utils.setObjectModData(self.hutch, "automaticDoorInstalled", true)
    sendRemoveItemFromContainer(self.character:getInventory(), self.item)
    self.character:getInventory():Remove(self.item)
end

function STA_BetterHutches_ISInstallAutoDoor:getDuration()
    if self.character:isTimedActionInstant() then return 1 end
    return 200
end

function STA_BetterHutches_ISInstallAutoDoor:new(character, hutch, tool, item)
    local o = ISBaseTimedAction.new(self, character)
    o.hutch = hutch
    o.tool = tool
    o.item = item
    o.maxTime = o:getDuration()
    return o
end