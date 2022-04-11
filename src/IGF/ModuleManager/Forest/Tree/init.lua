--!strict
--[[	Tree.lua | Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	   	 	
		Full notice in IGF.lua		]]--

local t = require(script.Parent.Parent.Parent.Types)
local Node = require(script.Node)
local Catcher = require(script.Parent.Parent.Parent.Catcher)

local Tree = {}; Tree.__index = Tree

function Tree.construct(root: ModuleScript, eager_array: t.Array<ModuleScript>): Tree
	local self = setmetatable({}, Tree) :: Tree
	
	local _d = {} :: t.HashMap<Instance, boolean>
	for _, m in pairs(eager_array) do
		_d[m] = true
	end
	
	self.Root = Node.new(root, _d[root]) :: Node
	self.NodeMap = {} :: t.HashMap<Instance, Node>
	self.Eager = _d
	
	return self
end

function Tree:Complete(node: Node, ignore: Instance?, replacement: Node?)
	self.NodeMap[node.I] = node

	for _, child in pairs(node.I:GetChildren()) do
		if child ~= ignore then
			local child_node = Node.new(child, self.Eager[child], node)
			node.Children[child.Name] = child_node
			self:Complete(child_node, ignore, replacement)
		elseif replacement and ignore then
			node.Children[ignore.Name] = replacement
			ignore = nil
			replacement = nil
		end
	end
end

function Tree.incorporate(root: ModuleScript, eager_array: t.Array<ModuleScript>, inject: t.Injection, old: Tree): Tree
	local self = Tree.construct(root, eager_array)

	for module, node in pairs(old.NodeMap) do
		self.NodeMap[module] = node
	end
	
	self:Complete(self.Root, old.I :: Instance?, old.Root :: Node?)
	self:Initialise(inject)

	return self
end

function Tree.new(root: ModuleScript, eager_array: t.Array<ModuleScript>, inject: t.Injection): Tree
	local self = Tree.construct(root, eager_array)
	
	self:Complete(self.Root)
	self:Initialise(inject)
	
	return self
end

function Tree:Initialise(inject)
	self.Root:Load(inject)
end

--<< TYPES >>

type Node = typeof(Node.new(script, false))
type Tree = typeof(Tree.construct(script, {}))
type Catcher = typeof(Catcher.new(print,print,print))

return Tree