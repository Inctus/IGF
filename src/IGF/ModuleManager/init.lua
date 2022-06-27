--!strict

local t = require(script.Parent.Types)
local c = require(script.Parent.Dependencies.c)

local Forest = require(script.Forest)
local Node = require(script.Forest.Node)
local Promise = require(script.Parent.Dependencies.Promise)

--INFO: Handles all Module interactions
local ModuleManager = {}
ModuleManager.__index = ModuleManager

do

    function ModuleManager.new(IGF): ModuleManager
        local self = setmetatable({}, ModuleManager)

        local inject = IGF.InjectionManager:GetInjector()
        self.Forest = Forest.new(inject) :: Forest

        return self
    end

    function ModuleManager:Add(is_shared: boolean, instance: Instance, eager_array: t.Array<ModuleScript>): Promise
        return Promise.try(function()
            self.Forest:AddTree(instance, eager_array, is_shared)
        end)
    end

    function ModuleManager:Retrieve(from: ModuleScript, path: t.Array<string>, target_shared: boolean): Promise
        return Promise.try(function()
            self.Forest:Retrieve(from, path, target_shared):GetContent()
        end)
    end

    function ModuleManager:Run(from: ModuleScript, path: t.Array<string>, target_shared: boolean, ...): Promise
        local args = {...}
        return Promise.try(function()
            if #args > 0 then
                self.Forest:Retrieve(from, path, target_shared):Run(table.unpack(args))
            else
                self.Forest:Retrieve(from, path, target_shared):Run()
            end
        end)
    end

    type ModuleManager = typeof(ModuleManager.new(print))
    type Forest = typeof(Forest.new(print))

end

export type Promise = typeof(Promise.new())

return ModuleManager