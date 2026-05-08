require "TimedActions/Animals/ISHutchCleanFloor"
local Utils = require "STA_BetterHutches_Utils"

local _old_ISHutchCleanFloor_complete = ISHutchCleanFloor.complete
local _old_ISHutchCleanFloor_stop = ISHutchCleanFloor.stop

function ISHutchCleanFloor:stop()
    Utils.setObjectModData(self.hutch, "hasWoodChips", 0)
    Utils.setObjectModData(self.hutch, "lastDirtLevel", 0)
    Utils.setObjectModData(self.hutch, "lastDirtAdded", 0)
    _old_ISHutchCleanFloor_stop(self)
end

function ISHutchCleanFloor:complete()
    Utils.setObjectModData(self.hutch, "hasWoodChips", 0)
    Utils.setObjectModData(self.hutch, "lastDirtLevel", 0)
    Utils.setObjectModData(self.hutch, "lastDirtAdded", 0)
    _old_ISHutchCleanFloor_complete(self)
end