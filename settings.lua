local newData = {}
local blockableGroups = require("blockable-groups")
for i, blockableType in pairs(blockableGroups) do
    table.insert(newData, {
        order = string.format("%3d", i),
        name = "BuildWithoutRhythm-block-" .. blockableType[1],
        type = "int-setting",
        setting_type = "runtime-global",
        default_value = blockableType[2],
        minimum_value = 0,
        localised_name = {"mod-setting-name.BuildWithoutRhythm-block-radius", {"BuildWithoutRhythm-blockable-type."..blockableType[1]}},
    })
end
data:extend(newData)