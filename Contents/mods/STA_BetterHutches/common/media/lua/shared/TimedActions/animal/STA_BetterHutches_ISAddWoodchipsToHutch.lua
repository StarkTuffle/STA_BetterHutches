require "TimedActions/ISBaseTimedAction"
local Utils = require "STA_BetterHutches_Utils"

STA_BetterHutches_ISAddWoodchipsToHutch = ISBaseTimedAction:derive("STA_BetterHutches_ISAddWoodchipsToHutch")

function STA_BetterHutches_ISAddWoodchipsToHutch:isValid()
    return self.hutch ~= nil and self.character:getInventory():containsType("STA_BetterHutches.WoodchipsBag") and (Utils.getObjectModData(self.hutch, "hasWoodChips") or 0) <= (100 - self.percentPerUse)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:waitToStart()
    self.character:faceThisObject(self.hutch)
    return self.character:shouldBeTurning()
end

function STA_BetterHutches_ISAddWoodchipsToHutch:addWoodchip()
    if not self.item or self.item:getCurrentUses() <= 0 then
        if isServer() then
            self.netAction:forceComplete()
        else
            self:forceStop()
        end
        return
    end

    if self.currentWoodchips >= 100 then
        if isServer() then
            self.netAction:forceComplete()
        else
            self:forceStop()
        end
    end

    self.currentWoodchips = self.currentWoodchips + self.percentPerUse
    Utils.setObjectModData(self.hutch, "hasWoodChips", self.currentWoodchips)
    self.item:UseAndSync()
end

function STA_BetterHutches_ISAddWoodchipsToHutch:update()
    self.character:faceThisObject(self.hutch)
    if not isClient() then
        self.timer = self.timer + getGameTime():getMultiplier()
        if math.floor(self.timer / self.timePerWoodchip) > self.lastTimer then
            self.lastTimer = math.floor(self.timer / self.timePerWoodchip)
            self:addWoodchip()
        end
    end
end

function STA_BetterHutches_ISAddWoodchipsToHutch:start()
    self:setActionAnim("Pour")
end

function STA_BetterHutches_ISAddWoodchipsToHutch:stop()
    ISBaseTimedAction.stop(self)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:perform()
    ISBaseTimedAction.perform(self)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:complete()
    self.hutch:sync()
    return true
end

function STA_BetterHutches_ISAddWoodchipsToHutch:animEvent(event, parameter)
    if isServer() then
        if event == "update" then
            self:addWoodchip()
        end
    end
end

function STA_BetterHutches_ISAddWoodchipsToHutch:serverStart()
    local period = self.timePerWoodchip * 20
    emulateAnimEvent(self.netAction, period, "update", nil)
end

function STA_BetterHutches_ISAddWoodchipsToHutch:getDuration()
    return -1
end

function STA_BetterHutches_ISAddWoodchipsToHutch:new(character, hutch, item)
    local o = ISBaseTimedAction.new(self, character)
    o.hutch = hutch
    o.item = item
    o.currentWoodchips = Utils.getObjectModData(hutch, "hasWoodChips") or 0
    o.timer = 0
    o.lastTimer = 0
    o.timePerWoodchip = 20
    o.bagsToFill = Utils.getSandboxInt("WoodchipsBagAmount")
    o.percentPerUse = 100 / (item:getMaxUses() * o.bagsToFill)
    o.maxTime = o:getDuration()
    return o
end