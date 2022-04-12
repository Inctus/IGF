-- !strict
--[[    Subscription.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
        
        Full notice in IGF.lua      ]]--

local t = require(script.Parent.Parent.Types)
local DataElement = require(script.Parent.DataElement)

local Subscription = {}
Subscription.__index = Subscription

function Subscription.new(functions: t.Array<t.Closure>, dataElement: DataElement.DataElement): Subscription
    local self = setmetatable({}, Subscription) :: Subscription

    self.subscribedFunctions = functions or {} :: t.Array<t.Closure>
    self.boundElements = {dataElement} :: t.Array<DataElement.DataElement>
    self.subscribed = true :: boolean

    return self
end

function Subscription:_fire(...)
    if self.subscribed then
        for _, bind in pairs(self.subscribedFunctions) do
            bind(...)
        end
    end
end

function Subscription:unSubscribe()
    self.subscribed = false
end

function Subscription:reSubscribe()
    self.subscribed = true
end

function Subscription:merge(other: Subscription)
    for _, bind in pairs(self.subscribedFunctions) do
        if not table.find(bind, other.subscribedFunctions) then
            error("Attempt to merge two distinct subscriptions.")
        end
    end
    local _tElements = other.boundElements
    other.boundElements = {}
    for _, element in pairs(_tElements) do
        --TODO()
        -- remove the old subscription from the elements here
        table.insert(self.boundElements, element)
    end
end

export type Subscription = typeof(Subscription.new({}, {}))

return Subscription 