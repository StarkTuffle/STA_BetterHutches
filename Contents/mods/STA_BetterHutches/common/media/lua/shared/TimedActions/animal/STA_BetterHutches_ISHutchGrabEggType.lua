require "TimedActions/ISBaseTimedAction"
local Utils = require "STA_BetterHutches_Utils"

STA_BetterHutches_ISHutchGrabEggType = ISBaseTimedAction:derive("STA_BetterHutches_ISHutchGrabEggType")

function STA_BetterHutches_ISHutchGrabEggType:isValid()
    return self.nestbox ~= nil and self.nestbox:getEggsNb() > self.idx and self.hutch ~= nil and self.character:getPerkLevel(Perks.Husbandry) >= Utils.getSandboxInt("FertilizedEggLevel")
end

function STA_BetterHutches_ISHutchGrabEggType:waitToStart()
    self.character:faceThisObject(self.tree)
    return self.character:shouldBeTurning()
end

function STA_BetterHutches_ISHutchGrabEggType:update()
    self.character:faceThisObject(self.hutch)

    if not isClient() then
        self.timer = self.timer + getGameTime():getMultiplier()
        if math.floor(self.timer / self.timePerEgg) > self.lastTimer then
            self.lastTimer = math.floor(self.timer / self.timePerEgg)

            for n = self.idx, self.nestbox:getEggsNb() - 1 do
                local egg = self.nestbox:getEgg(n)
                if egg and (egg:isFertilized() == self.fertilized) then
                    self.nestbox:removeEgg(n)
                    addXp(self.character, Perks.Husbandry, 1)
                    self.character:getInventory():AddItem(egg)
                    self.idx = n
                    break
                end
            end
            -- local egg = self.nestbox:getEgg(self.idx)
            -- if egg and (egg:isFertilized() == self.fertilized) then
            --     self.nestbox:removeEgg(self.idx)
            --     addXp(self.character, Perks.Husbandry, 1)
            --     self.character:getInventory():AddItem(egg)
            -- else
            --     self.idx = self.idx + 1
            -- end
        end
    end
end

function STA_BetterHutches_ISHutchGrabEggType:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Low")
    self.character:reportEvent("EventLootItem")
    self.sound = self.character:playSound("GrabEggs")
end

function STA_BetterHutches_ISHutchGrabEggType:stop()
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function STA_BetterHutches_ISHutchGrabEggType:perform()
    self:stopSound()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function STA_BetterHutches_ISHutchGrabEggType:serverStart()
    local period = self.timePerEgg * 20
    emulateAnimEvent(self.netAction, period, "update", nil)
end

function STA_BetterHutches_ISHutchGrabEggType:animEvent(event, parameter)
    if isServer() then
        if event == "update" then
            for n = self.idx,self.nestbox:getEggsNb() - 1 do
                local egg = self.nestbox:getEgg(n)
                if egg and (egg:isFertilized() == self.fertilized) then
                    self.nestbox:removeEgg(n)
                    self.hutch:sync()
                    addXp(self.character, Perks.Husbandry, 1)
                    self.character:getInventory():AddItem(egg)
                    sendAddItemToContainer(self.character:getInventory(), egg)
                    self.idx = n
                    break
                end
            end
        end
        --     local egg = self.nestbox:getEgg(self.idx)
        --     if egg and (egg:isFertilized() == self.fertilized) then
        --         self.nestbox:removeEgg(self.idx)
        --         self.hutch:sync()
        --         addXp(self.character, Perks.Husbandry, 1)
        --         self.character:getInventory():AddItem(egg)
        --         sendAddItemToContainer(self.character:getInventory(), egg)
        --     else
        --         self.idx = self.idx + 1
        --     end
    end
end

function STA_BetterHutches_ISHutchGrabEggType:complete()
    return true
end

function STA_BetterHutches_ISHutchGrabEggType:getDuration()
    if self.character:isTimedActionInstant() then
        self.timePerEgg = 1
    elseif isServer() then
        return -1
    end
    local numType = 0
    for n = 0, self.nestbox:getEggsNb() - 1 do
        if self.nestbox:getEgg(n):isFertilized() == self.fertilized then
            numType = numType + 1
        end
    end
    return (numType * self.timePerEgg) + 5
end

function STA_BetterHutches_ISHutchGrabEggType:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function STA_BetterHutches_ISHutchGrabEggType:new(character, nestbox, hutch, fertilized)
    local o = ISBaseTimedAction.new(self, character)
    if isServer() then
        o.nestbox = hutch:getNestBox(nestbox)
    else
        o.nestbox = nestbox
    end
    o.hutch = hutch
    o.fertilized = fertilized
    o.idx = 0
    o.timer = 0
    o.lastTimer = 0
    o.timePerEgg = 40
    o.maxTime = o:getDuration()
    return o
end
