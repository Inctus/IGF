--!strict
--[[	ModuleManager.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)

        Full notice in IGF.lua		]]--

local t = require(script.Parent.Types)
local c = require(script.Parent.c)
local Catcher = require(script.Parent.Catcher)
local Forest = require(script.Forest)
local Promise = require(script.Parent.Promise)

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(inject: t.Injection): ModuleManager
    local self = setmetatable({}, ModuleManager)

    self.MainForest = Forest.new(inject) :: Forest
    self.SharedForest = Forest.new(inject, self.MainForest) :: Forest

    return self
end

function ModuleManager:GetCatcherHandler(from: ModuleScript)
    return function(path: t.Array<string>, args: {any}?)
        local shared;
        if path[1] == "Shared" then
            shared = true;
            table.remove(path, 1)
        end
        if path[1] == "add" then
            return Promise.try(function()
                assert(args and #args > 0, "Attempt to add module but none was provided.")
                assert(c.tuple(c.Instance, c.optional(c.table))(unpack(args)))
                if shared then
                    self.SharedForest:AddTree(args[1], args[2] or {})
                else
                    self.MainForest:AddTree(args[1], args[2] or {})
                end
            end)
        end
        if path[#path] == "require" then
            table.remove(path)
            Promise.try(function()
                return if shared then self.SharedForest:Retrieve(from, path)
                    else self.MainForest:Retrieve(from, path)
            end)
        end
        return Promise.try(function()
            return Promise.try(function()
                return if shared then self.SharedForest:Retrieve(from, path)
                    else self.MainForest:Retrieve(from, path)
            end):andThen(function(module)
                assert(c.table(module))
                assert(c["function"](module.main))
                return if args then module:main(unpack(args)) else module:main()
            end)
        end)
    end
end

type ModuleManager = typeof(ModuleManager.new(print))
type Forest = typeof(Forest.new(print))
export type Catcher = typeof(Catcher.new(print))

return ModuleManager