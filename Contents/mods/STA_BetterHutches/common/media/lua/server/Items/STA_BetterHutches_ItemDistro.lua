require "Items/ProceduralDistributions"
require "Items/SuburbsDistributions"

table.insert(ProceduralDistributions.list["BarnTools"].items, "STA_BetterHutches.WoodchipsBag")
table.insert(ProceduralDistributions.list["BarnTools"].items, 3)
table.insert(ProceduralDistributions.list["CrateFarming"].items, "STA_BetterHutches.WoodchipsBag")
table.insert(ProceduralDistributions.list["CrateFarming"].items, 1)
table.insert(ProceduralDistributions.list["GigamartFarming"].items, "STA_BetterHutches.WoodchipsBag")
table.insert(ProceduralDistributions.list["GigamartFarming"].items, 2)
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, "STA_BetterHutches.WoodchipsBag")
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, 3)

ProceduralDistributions.list["CrateWoodchips"] = {
    rolls = 4,
    items = {
        "STA_BetterHutches.WoodchipsBag", 50,
        "STA_BetterHutches.WoodchipsBag", 20,
        "STA_BetterHutches.WoodchipsBag", 20,
        "STA_BetterHutches.WoodchipsBag", 10,
        "STA_BetterHutches.WoodchipsBag", 10,
        "EmptySandbag", 10,
    },
    junk = {
        rolls = 1,
        items = {

        }
    }
}

table.insert(SuburbsDistributions["barn"]["cardboardbox"]["procList"], {name="CrateWoodchips", min=0, max=99, weightChance=50})
table.insert(SuburbsDistributions["barn"]["crate"]["procList"], {name="CrateWoodchips", min=0, max=99, weightChance=50})
table.insert(SuburbsDistributions["barn"]["metal_shelves"]["procList"], {name="CrateWoodchips", min=0, max=99, weightChance=50})

table.insert(SuburbsDistributions["farmstorage"]["crate"]["procList"], {name="CrateWoodchips", min=0, max=1, weightChance=50})

table.insert(SuburbsDistributions["gardenstore"]["crate"]["procList"], {name="CrateWoodchips", min=0, max=99, weightChance=10})
table.insert(SuburbsDistributions["gardenstore"]["metal_shelves"]["procList"], {name="CrateWoodchips", min=0, max=2, weightChance=10})
table.insert(SuburbsDistributions["gardenstore"]["shelves"]["procList"], {name="CrateWoodchips", min=0, max=2, weightChance=10})

table.insert(SuburbsDistributions["shed"]["crate"]["procList"], {name="CrateWoodchips", min=0, max=1, weightChance=5})