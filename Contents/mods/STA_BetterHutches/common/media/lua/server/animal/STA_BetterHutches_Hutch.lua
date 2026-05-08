local Hutch = STA_BetterHutches_Hutch or {}

local Utils = require "STA_BetterHutches_Utils"

---@return IsoHutch[]
local function getHutches()
    local allAnimalZones = DesignationZoneAnimal.getAllZones()
    if not allAnimalZones then return {} end

    local hutches = {}
    for idxz = 0, allAnimalZones:size() - 1 do
        local zoneHutches = allAnimalZones:get(idxz):getHutchs()
        if zoneHutches then
            for idxh = 0, zoneHutches:size() - 1 do
                table.insert(hutches, zoneHutches:get(idxh))
            end
        end
    end

    return hutches
end

---@param hutch IsoHutch
local function applyWoodChipModifier(hutch)
    local lastDirtLevel = Utils.getObjectModData(hutch, "lastDirtLevel") or 0 -- 10
    local lastDirtAdded = Utils.getObjectModData(hutch, "lastDirtAdded") or 0
    local dirtAdded = hutch:getHutchDirt() - lastDirtLevel
    local reduction = math.floor(Utils.getSandboxInt("DirtinessReduction") * (Utils.getObjectModData(hutch, "hasWoodChips") / Utils.getSandboxInt("WoodchipsBagAmount")))

    if dirtAdded < 0 then
        lastDirtLevel = 0
        lastDirtAdded = 0
    else
        lastDirtAdded = lastDirtAdded + dirtAdded
        if lastDirtAdded >= reduction then
            lastDirtAdded = lastDirtAdded - reduction
            lastDirtLevel = lastDirtLevel + 1
        end
    end

    hutch:setHutchDirt(lastDirtLevel)
    Utils.setObjectModData(hutch, "lastDirtLevel", lastDirtLevel)
    Utils.setObjectModData(hutch, "lastDirtAdded", lastDirtAdded)
end

---@param hutch IsoHutch
local function checkForWoodChips(hutch)
    local hasWoodChips = Utils.getObjectModData(hutch, "hasWoodChips")
    if hasWoodChips and hasWoodChips > 0 then
        applyWoodChipModifier(hutch)
    end
end

local function onEveryOneMinute()
    for _, hutch in ipairs(getHutches()) do
        checkForWoodChips(hutch)
    end
end

Events.EveryOneMinute.Add(onEveryOneMinute)

_G.STA_BetterHutches_Hutch = Hutch
return Hutch