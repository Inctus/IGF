local t = require(script.Parent.Types)

local PATH_SEPARATOR = " -> "

local Utility = {}

do

    function Utility.prettifyPath(path: t.Array<string>, i: number?, j: number?): string
        i = i or 1
        j = j or #path
        return table.concat(path, PATH_SEPARATOR, i, j)
    end

end

return Utility