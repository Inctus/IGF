--!strict

local Types = require(script.Parent.Types)
local Error = require(script.Parent.Error)

local Forest = require(script.Forest)
local Promise = require(script.Parent.Dependencies.Promise)

--INFO: Handles all Module interactions
local ModuleManager = {}
ModuleManager.__index = ModuleManager

do

    function ModuleManager.new(): ModuleManager
        local self = setmetatable({}, ModuleManager)
        self.Forest = nil :: Forest

        return self
    end

    --INFO: Passes the Injection into the ModuleManager
    --PRE:  The forest isn't initialised
    --POST: The forest is finally initialised
    function ModuleManager:GiveInjection(injection: Types.Injection)
        Error.ModuleManager.InjectedTwice(self.Forest)
        self.Forest = Forest.new(injection) :: Forest
    end

    --INFO: Adds a new Module to either the Private or Shared forests
    --PRE:  The instance to add is not already added
    --POST: The instance is inserted into the abstracted forest
    function ModuleManager:Add(is_shared: boolean, instance: Instance, eager_array: Types.Array<ModuleScript>): Promise
        return Promise.try(function()
            self.Forest:AddTree(instance, eager_array, is_shared)
        end)
    end

    --INFO: Retrieves a Module from the Shared or Private forests
    --PRE:  The path to retrieve is actually populated
    --POST: The Module to return is retrieved and its ModuleCatcher returned
    function ModuleManager:Retrieve(from: ModuleScript, path: Types.Array<string>, target_shared: boolean): Promise
        return Promise.try(function()
            return self.Forest:Retrieve(from, path, target_shared):GetContent()
        end)
    end

    --INFO: Runs a Module's main from the Shared or Private forests
    --PRE:  The path specified is populated
    --POST: The Module is ran
    function ModuleManager:Run(from: ModuleScript, path: Types.Array<string>, target_shared: boolean, ...): Promise
        local args = {...}
        return Promise.try(function()
            if #args > 0 then
                return self.Forest:Retrieve(from, path, target_shared):Run(table.unpack(args))
            else
                return self.Forest:Retrieve(from, path, target_shared):Run()
            end
        end)
    end

    type ModuleManager = typeof(ModuleManager.new())
    type Forest = typeof(Forest.new(print))
    type Promise = typeof(Promise.new())

end

return ModuleManager