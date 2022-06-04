--!strict
--[[    Forest.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
            
        Full notice in IGF.lua      ]]--

local t = require(script.Parent.Parent.Types)

local Forest = {}
Forest.__index = Forest

function Forest.new(inject: t.Injection, globalForest: Forest?): Forest
    local self = setmetatable({}, Forest)

    self.HashMap = {} :: t.HashMap<Instance, Node>
    self.Inject = inject :: t.Injection

    self.GlobalForest = globalForest
    self.IsShared = (globalForest ~= nil) :: boolean

    return self
end

type Forest = typeof(Forest.new(print))

return Forest