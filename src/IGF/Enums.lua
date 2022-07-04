--!strict

local Error = require(script.Parent.Error)

--INFO: Takes a reference to a table and recursively adds metatables to make it read-only at all depths
--PRE:  The table has no metatables set
--POST: The table is read only at all depths
function makeReadOnly(name: string, target: table)
    setmetatable(target, {
        __newindex = Error.Enums.AttemptedWrite,
        __tostring = function()
            return name
        end
    })
    for key, value in target do
        if type(value) == "table" then
            makeReadOnly(name .. "." .. key, value)
        end
    end
end

--INFO: Enums to be used by the front-facing user
local Enums = {}

Enums.StaticFilter = {}
Enums.StaticFilter.All = 1
Enums.StaticFilter.Whitelist = 2
Enums.StaticFilter.Blacklist = 3

makeReadOnly("Enums", Enums)

return Enums