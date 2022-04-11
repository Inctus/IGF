--!strict
--[[	Node.lua | Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	   	 	
		Full notice in IGF.lua		]]--

local t = require(script.Parent.Parent.Parent.Parent.Types)

local Node = {}
Node.__index = Node

function Node.new(instance: Instance, lazy: boolean, parent: Node?): Node
	local self = setmetatable({}, Node)
	
	self.Children = {} :: t.Dict<Node>;
	self.Content = nil :: any?
	self.Loaded = false :: boolean
	
	self.Lazy = lazy
	self.I = instance :: Instance
	self.Parent = parent
	
	self:CheckAncestry(workspace)
	
	return self
end

function Node:LazyLoad(inject: t.Injection)
	if not self.Loaded and self.I:IsA("ModuleScript") then
		self.Content = require(self.I :: ModuleScript) :: any?
		
		inject(self.I, self.Content)
	end
	self.Loaded = true
end

function Node:EagerLoad(inject: t.Injection)	
	for _, sub_child  in pairs(self.Children) do
		sub_child:EagerLoad(inject)
	end
	
	self:LazyLoad(inject)
end

function Node:Load(inject: t.Injection)
	if self.Lazy then
		self:LazyLoad(inject)
	else
		self:EagerLoad(inject)
	end
end

function Node:GetContent(inject: t.Injection)
	if not self.Loaded then
		self:Load(inject)
	end
	
	return self.Content
end

function Node:CheckAncestry(ancestor: Instance): boolean
	return self.I:IsDescendantOf(ancestor)
end

type Node = typeof(Node.new(script, false))

return Node