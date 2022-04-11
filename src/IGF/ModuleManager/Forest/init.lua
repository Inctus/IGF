--!strict
--[[	Forest.lua | Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	   	 	
		Full notice in IGF.lua		]]--

local t = require(script.Parent.Parent.Types)
local Tree = require(script.Tree)
local Node = require(script.Tree.Node)

local Forest = {}
Forest.__index = Forest

function Forest.new(inject: t.Injection): Forest
	local self = setmetatable({}, Forest)

	self.Trees = {} :: t.Dict<Tree>
	self.AggregatedHashMap = {} :: t.HashMap<Instance, Tree>
	self.Inject = inject :: t.Injection

	return self
end

function Forest:AddTree(root: ModuleScript, eager_array: t.Array<ModuleScript>)
	assert(not self.AggregatedHashMap[root], "Attempt to add preexisting Module" ..
		root.Name .. " to Internal Module Hierarchy")
	
	--[[
	Here account for new one being higher, but not being lower
	Check for new one being lower and error!
	]]
	local old_tree
	for _, tree in pairs(self.Trees) do
		if (tree.Root :: Node):CheckAncestry(root) then
			warn("Attempt to add a module that is an ancestor of a previously added module. " .. 
				"Attempting conflict resolution.")
			old_tree = tree
			break
		end
	end
	
	if old_tree then
		self.Trees[old_tree.I.Name] = nil
		self.Trees[root.Name] = Tree.incorporate(root, eager_array, self.Inject, old_tree)
	else
		self.Trees[root.Name] = Tree.new(root, eager_array, self.Inject)
	end
	
	self:RecomputeAggregatedHashMap()
end

function Forest:Retrieve(source: ModuleScript, path: t.Array<string>): (boolean, any?)
	--[[
	This doesn't work for shared from global!

	Shared can't require a global module which makes sense.
	But a global module should be able to require a shared module!
	Possibly add a flag to the forest to make it a shared forest.
	Then here, rework this so that source_tree is compared to target_tree
	only if source tree exists, i.e. when there is a module in shared requiring
	another module in shared.
	
	Need to add an aggregated check to make sure that the module isn't external within
	the modulemanager.
	]]
	local source_tree: Tree? = self.AggregatedHashMap[source]
	assert(source_tree, "Attempt to illegaly retrieve a module from an external module: " 
		.. source.Name)
	
	local target_name: string? = table.remove(path, 1);
	assert(target_name, "Attempt to retrieve module with no path")
	
	local target_tree = self.Trees[target_name]
	assert(target_tree, "Attempt to retrieve uninitialised module" .. target_name)
	
	if not source_tree == target_tree then
		warn("Attempt to access member of other hierarchy. Consider moving "
			.. target_name .. " to Shared.")
	end
	
	local target: Node
	for _, v in ipairs(path) do
		local success, message = pcall(function()
			target = target_tree[v]
		end)
		assert(success, "Attempt to retrieve non-loaded module")
	end
	assert(target, "Attempt to retrieve non-loaded module")
	
	return true, target:GetContent(self.Inject)
end

function Forest:RecomputeAggregatedHashMap()
	self.AggregatedHashMap = {} :: t.HashMap<Instance, Tree>
	
	for _, tree in pairs(self.Trees :: t.Dict<Tree>) do
		for mod, node in pairs(tree.NodeMap) do
			self.AggregatedHashMap[mod] = tree
		end
	end
end

type Tree = typeof(Tree.new(script, {}, print))
type Node = typeof(Node.new(script, false))
type Forest = typeof(Forest.new(print))

return Forest