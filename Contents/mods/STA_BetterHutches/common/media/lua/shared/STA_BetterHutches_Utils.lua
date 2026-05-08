local Utils = STA_BetterHutches_Utils or {}
Utils.modID = "STA_BetterHutches"

Utils.SandboxDefaults = {
    ["WoodchipsBagAmount"] = 4,
    ["DirtinessReduction"] = 10
}

---@param key String
---@return any
local function getSandboxValue(key)
    local moduleName = Utils.modID
    if SandboxVars and SandboxVars[moduleName] and SandboxVars[moduleName][key] then
        return SandboxVars[moduleName][key]
    end
    return nil
end

---@param key String
---@return number|nil
function Utils.getSandboxNum(key)
    local defaultVal = Utils.SandboxDefaults[key]
    local val = getSandboxValue(key)

    if val == nil then return type(defaultVal) == "number" and defaultVal or nil end
    if type(val) == "number" then return val end
    if type(val) == "boolean" then return val and 1 or 0 end
    if type(val) == "string" then
        local num = tonumber(val)
        if num then return num end
    end
    return type(defaultVal) == "number" and defaultVal or nil
end

---@param key String
---@return integer
function Utils.getSandboxInt(key)
    local num = Utils.getSandboxNum(key)
    return math.floor(num or 0)
end

---@param obj IsoObject
---@param key String
---@return any
function Utils.getObjectModData(obj, key)
    local data = obj:getModData()
    if not data then return end

    if not data[Utils.modID] then
        data[Utils.modID] = {}
    end

    if data[Utils.modID][key] then
        return data[Utils.modID][key]
    end
    return nil
end


---@param obj IsoObject
---@param key String
---@param value any
function Utils.setObjectModData(obj, key, value)
    local data = obj:getModData()
    if not data then return end

    if not data[Utils.modID] then
        data[Utils.modID] = {}
    end
    data[Utils.modID][key] = value
end

_G.STA_BetterHutches_Utils = Utils
return Utils