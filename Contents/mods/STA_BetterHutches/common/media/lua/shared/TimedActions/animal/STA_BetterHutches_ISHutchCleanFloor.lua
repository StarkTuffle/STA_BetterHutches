require "TimedActions/Animals/ISHutchCleanFloor"
local Utils = require "STA_BetterHutches_Utils"

local _old_ISHutchCleanFloor_clean = ISHutchCleanFloor.clean

function ISHutchCleanFloor:clean()
    _old_ISHutchCleanFloor_clean(self)
    local cleanForce = 1
    if self.bleach and not self.bleach:getFluidContainer():isEmpty() then
        cleanForce = 2
    end

    local woodchips = Utils.getObjectModData(self.hutch, "hasWoodChips") - cleanForce
    if woodchips < 0 then
        woodchips = 0
    end
    Utils.setObjectModData(self.hutch, "hasWoodChips", woodchips)
    Utils.setObjectModData(self.hutch, "lastDirtLevel", self.hutch:getHutchDirt())
end