--!strict
--[[
    This is the Module Forest. It is used to store Added modules in the Framework.
    Each Module is wrapped with metadata forming a Node. This allows for Lazy Loading
    of Modules, and safe, managed retrieval of Modules from other known Modules
]]

local Types = require(script.Parent.Parent.Types)
local Error = require(script.Parent.Parent.Error)
local Utility = require(script.Parent.Parent.Utility)
local Node = require(script.Node)

--INFO: Forest class to store Modules from the current context
local Forest = {}
Forest.__index = Forest

local SHARED = "Shared"
local PRIVATE = "Private"

do

    --INFO: Creates a new ModuleForest
    --PRE:  The Injection injects the correct items into each module
    --POST: THe new Forest is returned
    function Forest.new(inject: Types.Injection): Forest
        local self = setmetatable({}, Forest)

        self.Nodes = {} :: Types.HashMap<Instance, Node>
        self.Roots = {} :: Types.Dict<Instance>
        self.Inject = inject :: Types.Injection

        return self
    end

    --INFO: Adds a new Instance & its descendants to the forest
    --PRE:  The Instance is not already in the forest
    --POST: The Instance is added to the forest
    function Forest:Add(to_add: Instance, eager: Types.HashMap<Instance, boolean>, is_shared: boolean)
        Error.Forest.EmptyInsert(to_add, if is_shared then SHARED else PRIVATE)
        -- If we area already in the Forest, stop the recursion
        if self.Nodes[to_add] then
            -- If the pre-exisitng node was a Root, it can no longer be
            if self.Roots[to_add.Name] then
                self.Roots[to_add.Name] = nil
            end
            Error.Forest.PreexistingInsert(to_add.Name, if is_shared then SHARED else PRIVATE)
        end
        self.Nodes[to_add] = Node.new(to_add, eager[to_add], is_shared)
        if eager then
            self.Nodes[to_add]:Load(self.Inject, self.Nodes)
        end
        -- Recursively add all children too
        for _, child in to_add:GetChildren() do
            self:Add(child, eager, is_shared)
        end
    end

    --INFO: Adds a new descendant tree to the forest
    --PRE:  The root to be added isn'Types in the tree already. The eager_array only contains instances descendant from root
    --POST: The root to be added is added to the Forest
    function Forest:AddTree(root: Instance, eager_array: Types.Array<Instance>, is_shared: boolean)
        Error.Forest.EmptyInsert(root, if is_shared then SHARED else PRIVATE)
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
    function Forest:LocalLookup(source_node: Node, path: Types.Array<string>)
        Error.Forest.LostSource(source_node)
        local current: Node = source_node;
        -- Iterate through path, repeatedly indexing
        for depth, index in path do
            local next_child = current.I[index]
            Error.Forest.RetrievalFailure(next_child, Utility.prettifyPath(path, 1, depth), source_node.I.Name)
            current = self.Nodes[next_child]
            -- This error can be caused by modifying (then relying on) the added tree structure
            Error.Forest.UnknownTargetRetrieval(current, index, source_node.I.Name, Utility.prettifyPath(path, 1, depth))
        end
        return current
    end

    --INFO: Performs a global lookup along path of specific visibility
    --PRE:  There exists a path starting at a root of specified visibility leading from
    --      path[1] to path[#path] that ends with a Module
    --POST: The path is found and traversed
    function Forest:GlobalLookup(path: Types.Array<string>, is_shared: boolean)
        local current = self.Roots[path[1]]
        Error.Forest.RootRetrievalFailure(current, path[1], if is_shared then SHARED else PRIVATE)
        table.remove(path, 1)
        for depth, index in path do
            local next_child = current.I[index]
            Error.Forest.GlobalRetrievalFailure(next_child, Utility.prettifyPath(path, 1, depth), if is_shared then SHARED else PRIVATE)
            current = self.Nodes[next_child]
            -- This error can be caused by modifying (then relying on) the added tree structure
            Error.Forest.GlobalUnknownTargetRetrieval(current, index, if is_shared then SHARED else PRIVATE, Utility.prettifyPath(path, 1, depth))
        end
        return current
    end

    --INFO: Retrieves the contents of a module
    --PRE:  The Module is a proper module and is already within the module tree
    --POST: The Module's content is returned
    function Forest:Retrieve(source: ModuleScript, path: Types.Array<string>, target_shared: boolean): any?
        Error.Forest.NoPathRetrieve(#path > 0, if target_shared then SHARED else PRIVATE)
        Error.Forest.NoSourceRetrieval(source)
        local source_node: Node = self.Nodes[source]
        Error.Forest.UnknownSourceRetrieval(source_node, source.Name)
        local source_shared: boolean = source_node.Shared

        -- Source   Root
        --   sh      sh     -> Local followed by Global lookup
        --   pr      sh     -> Global
        --   pr      pr     -> Local
        --   sh      pr     -> Illegal

        -- sh pr case, Illegal, minterm for minimal canonical form
        Error.Forest.IllegalRetrievalFromSharedToPrivate(not source_shared or target_shared, Utility.prettifyPath(path), source.Name, Utility.prettifyPath(path))
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
            Error.Forest.SharedRetrievalFailure(target_node, Utility.prettifyPath(path), source.Name)
        else
            Error.Forest.UnknownRetrievalState()
        end
        Error.Forest.RetrievalFailure(target_node, Utility.prettifyPath(path), source.Name)

        return target_node
    end

    type Forest = typeof(Forest.new(print))
    type Node = typeof(Node.new(script, false, false))

end

return Forest