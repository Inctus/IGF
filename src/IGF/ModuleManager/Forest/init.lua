--!strict
--[[    Forest.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)

        Full notice in IGF.lua      ]]--

local t = require(script.Parent.Parent.Types)
local e = require(script.Parent.Parent.Error)
local u = require(script.Parent.Parent.Utility)
local Node = require(script.Parent.Node)

--INFO: Forest class to store Modules from the current context
local Forest = {}
Forest.__index = Forest

local SHARED = "Shared"
local PRIVATE = "Private"

do

    --INFO: Creates a new ModuleForest
    --PRE:  The Injection injects the correct items into each module
    --POST: THe new Forest is returned
    function Forest.new(inject: t.Injection): Forest
        local self = setmetatable({}, Forest)

        self.Nodes = {} :: t.HashMap<Instance, Node>
        self.Roots = {} :: t.Dict<Instance>
        self.Inject = inject :: t.Injection

        return self
    end

    --INFO: Adds a new Instance & its descendants to the forest
    --PRE:  The Instance is not already in the forest
    --POST: The Instance is added to the forest
    function Forest:Add(to_add: Instance, eager: t.HashMap<Instance, boolean>, is_shared: boolean)
        e.Forest.EmptyInsert(to_add, if is_shared then SHARED else PRIVATE)
        -- If we area already in the Forest, stop the recursion
        if self.Nodes[to_add] then
            -- If the pre-exisitng node was a Root, it can no longer be
            if self.Roots[to_add.Name] then
                self.Roots[to_add.Name] = nil
            end
            e.Forest.PreexistingInsert(to_add.Name, if is_shared then SHARED else PRIVATE)
        end
        self.Nodes[to_add] = Node.new(to_add, eager, is_shared)
        -- Recursively add all children too
        for _, child in to_add:GetChildren() do
            self:Add(child, eager, is_shared)
        end
    end

    --INFO: Adds a new descendant tree to the forest
    --PRE:  The root to be added isn't in the tree already. The eager_array only contains instances descendant from root
    --POST: The root to be added is added to the Forest
    function Forest:AddTree(root: Instance, eager_array: t.Array<Instance>, is_shared: boolean)
        e.Forest.EmptyInsert(root, if is_shared then "Shared" else "Private")
        -- Create a dictionary for easier lookup
        local eager_dictionary = {}
        for _, instance in eager_array do
            eager_dictionary[instance] = true
        end
        self:Add(root, eager_dictionary, is_shared)
        -- Set a new root, creating a new logical tree
        self.Roots[root.Name] = root
    end

    --INFO: Performs a local lookup from source along path
    --PRE:  Source and target have the same visisbility and target is along Path from Source
    --POST: The Node is found
    function Forest:LocalLookup(source_node: Node, path: t.Array<string>)
        e.Forest.LostSource(source_node)
        local current: Node = source_node;
        -- Iterate through path, repeatedly indexing
        for depth, index in path do
            local next_child = current.I[index]
            e.Forest.RetrievalFailure(next_child, u.prettifyPath(path, 1, depth), source_node.I.Name)
            current = self.Nodes[next_child]
            -- This error can be caused by modifying (then relying on) the added tree structure
            e.Forest.UnknownTargetRetrieval(current, index, source_node.I.Name, u.prettifyPath(path, 1, depth))
        end
        return current
    end

    --INFO: Performs a global lookup along path of specific visibility
    --PRE:  There exists a path starting at a root of specified visibility leading from
    --      path[1] to path[#path] that ends with a Module
    --POST: The path is found and traversed
    function Forest:GlobalLookup(path: t.Array<string>, is_shared: boolean)
        local current = self.Roots[path[1]]
        e.Forest.RootRetrievalFailure(current, path[1], if is_shared then SHARED else PRIVATE)
        table.remove(path, 1)
        for depth, index in path do
            local next_child = current.I[index]
            e.Forest.GlobalRetrievalFailure(next_child, u.prettifyPath(path, 1, depth), if is_shared then SHARED else PRIVATE)
            current = self.Nodes[next_child]
            -- This error can be caused by modifying (then relying on) the added tree structure
            e.Forest.GlobalUnknownTargetRetrieval(current, index, if is_shared then SHARED else PRIVATE, u.prettifyPath(path, 1, depth))
        end
        return current
    end

    --INFO: Retrieves the contents of a module
    --PRE:  The Module is a proper module and is already within the module tree
    --POST: The Module's content is returned
    function Forest:Retrieve(source: ModuleScript, path: t.Array<string>, target_shared: boolean): any?
        e.Forest.NoPathRetrieve(#path > 0, if target_shared then SHARED else PRIVATE)
        e.Forest.NoSourceRetrieval(source)
        local source_node: Node = self.Nodes[source]
        e.Forest.UnknownSourceRetrieval(source_node, source.Name)
        local source_shared: boolean = source_node.Shared

        -- Source   Root
        --   sh      sh     -> Local followed by Global lookup
        --   pr      sh     -> Global
        --   pr      pr     -> Local
        --   sh      pr     -> Illegal

        -- sh pr case, Illegal, minterm for minimal canonical form
        e.Forest.IllegalRetrievalFromSharedToPrivate(not source_shared or target_shared, u.prettifyPath(path), source.Name, u.prettifyPath(path))
        local target_node: Node;
        -- pr pr case
        if (not source_shared and not target_shared) then
             target_node = self:LocalLookup(source_node, path)
        -- pr sh case
        elseif (not source_shared and target_shared) then
            target_node = self:GlobalLookup(path, target_shared)
        -- sh sh case
        elseif (source_shared and target_shared) then
            local retrieval_success;
            -- Attempt local lookup
            retrieval_success, target_node = pcall(self:LocalLookup(source_node, path))
            -- Attempt global lookup
            target_node = if retrieval_success then target_node else self:GlobalLookup(path, target_shared)
            e.Forest.SharedRetrievalFailure(target_node, u.prettifyPath(path), source.Name)
        else
            e.Forest.UnknownRetrievalState()
        end
        e.Forest.RetrievalFailure(target_node, u.prettifyPath(path), source.Name)

        return target_node:GetContents(self.Inject)
    end

    type Forest = typeof(Forest.new(print))
    type Node = typeof(Node.new(script, false))

end

return Forest