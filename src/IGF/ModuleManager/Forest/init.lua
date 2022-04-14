--!strict
--[[    Forest.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
            
        Full notice in IGF.lua      ]]--

local t = require(script.Parent.Parent.Types)
local Tree = require(script.Tree)
local Node = require(script.Tree.Node)

local Forest = {}
Forest.__index = Forest

function Forest.new(inject: t.Injection, globalForest: Forest?): Forest
    local self = setmetatable({}, Forest)

    self.Trees = {} :: t.Dict<Tree>
    self.AggregatedHashMap = {} :: t.HashMap<Instance, Tree>
    self.Inject = inject :: t.Injection
    -- Acts as an indicator of this Forest being the Shared forest
    self.GlobalForest = globalForest
    self.Shared = (globalForest ~= nil) :: boolean

    return self
end

function Forest:AddTree(root: ModuleScript, eager_array: t.Array<ModuleScript>)
    assert(not self.AggregatedHashMap[root], "Attempt to add preexisting Module" ..
        root.Name .. " to Internal Module Hierarchy")
        
    local old_tree
    for _, tree: Tree in pairs(self.Trees) do
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

function Forest:Retrieve(source: ModuleScript, path: t.Array<string>): any?
    local source_tree: Tree? = self.AggregatedHashMap[source]
    assert(source_tree or (self.Shared and self.GlobalForest.AggregatedHashMap[source]),
        "Attempt to illegaly retrieve a module from an external module: " .. source.Name)
    assert(#path > 0, "Attempt to retrieve module with no path")
    
    local target: Node
    if (not self.Shared or source_tree) then 
        target = source_tree:Retrieve(path, source_tree.NodeMap[source]) 
    else 
        local target_name: string = table.remove(path, 1) or ""
        local target_tree = self.Trees[target_name]
        assert(target_tree, "Attempt to retrieve unknown module: " .. self.Shared and "Shared." or "" 
            .. target_name)
        assert(self.Shared or source_tree == target_tree, 
            "Attempt to access member of other hierarchy. Consider moving " .. target_name 
            .. " to Shared.")
        target_tree:Retrieve(path)
    end

    return target:GetContent(self.Inject)
end

function Forest:RecomputeAggregatedHashMap()
    self.AggregatedHashMap = {} :: t.HashMap<Instance, Tree>
    
    for _, tree in pairs(self.Trees :: t.Dict<Tree>) do
        for mod, _ in pairs(tree.NodeMap) do
            self.AggregatedHashMap[mod] = tree
        end
    end
end

type Tree = typeof(Tree.new(script, {}, print))
type Node = typeof(Node.new(script, false))
type Forest = typeof(Forest.new(print))

return Forest