local items = {"STA_BetterHutches.WoodchipsBag"}

local function identifyInput(input, loadedItems)
    if loadedItems:contains("Base.Dirtbag") then return true end
    return false
end

local function getJavaField(object, field)
    local offset = string.len(field)
    for i = 0, getNumClassFields(object) - 1 do
        local m = getClassField(object, i)
        if string.sub(tostring(m), -offset) == field then
            return getClassFieldVal(object, m)
        end
    end
    return nil
end

local function patchRecipe(recipeID, testInput, itemsToAdd)
    local craftRecipe = getScriptManager():getCraftRecipe(recipeID)
    local inputs = craftRecipe:getInputs()

    for i = 0, inputs:size() - 1 do
        local input = inputs:get(i)
        local loadedItems = getJavaField(input, "loadedItems")

        if testInput(input, loadedItems) then
            for j = 1, #itemsToAdd do
                local itemToAdd = itemsToAdd[j]
                if not loadedItems:contains(itemToAdd) then
                    loadedItems:add(itemsToAdd[j])
                end
            end
            return
        end
    end
end

-- Events.OnGameStart.Add(patchRecipe("Base.EmptySack", identifyInput, items)) 