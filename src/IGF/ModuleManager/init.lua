--!strict

local t = require(script.Parent.Types)
local c = require(script.Parent.Dependencies.c)
local Forest = require(script.Forest)
local Promise = require(script.Parent.Dependencies.Promise)

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(IGF): ModuleManager
    local self = setmetatable({}, ModuleManager)

    local inject = IGF.InjectionManager:GetInjector()
    self.MainForest = Forest.new(inject) :: Forest

    return self
end

function ModuleManager:Add(is_shared: boolean, module: ModuleScript, eager_array: t.Array<ModuleScript>): Promise
    return Promise.try(function()

    end)
end

function ModuleManager:Retrieve(from: ModuleScript, path: t.Array<string>, is_shared: boolean): Promise
    return Promise.try(function()

    end)
end

function ModuleManager:Run(from: ModuleScript, path: t.Array<string>, is_shared: boolean, ...): Promise
    return Promise.try(function()

    end)
end

type ModuleManager = typeof(ModuleManager.new(print))
type Forest = typeof(Forest.new(print))
export type Promise = typeof(Promise.new())

return ModuleManager