--!strict

local t = require(script.Parent.Parent.Parent.Types)
local e = require(script.Parent.Parent.Parent.Error)

--INFO: Node class encapsulates an Instance for use within the Forest
local Node = {}
Node.__index = Node

do
    --INFO: Wraps a new Node
    --PRE:  The Instance is non-null
    --POST: The Instance is wrapped in a Node containing all important metadata.
    function Node.new(instance: Instance, eager: boolean, is_shared: boolean): Node
        e.Node.EmptyInsert(instance, is_shared and "shared" or "")
        local self = setmetatable({}, Node)

        self.Content = nil :: any?
        self.Eager = eager :: boolean
        self.I = instance :: Instance
        self.Loaded = false :: boolean
        self.Shared = is_shared

        return self
    end

    --INFO: Loads a Node non-recursively
    --PRE:  The Node isn't loaded
    --POST: If the Node contains a modulescript it is loaded
    function Node:LazyLoad(inject: t.Injection)
        if not self.Loaded and self.I:IsA("ModuleScript") then
            self.Content = require(self.I :: ModuleScript) :: any?
            inject(self.I, self.Content)
        end

        self.Loaded = true
    end

    --INFO: Loads a node recursively
    --PRE:  The Node isn't already loaded
    --POST: Recursively loads all sub-nodes then this node
    function Node:EagerLoad(inject: t.Injection)
        for _, sub_child  in pairs(self.Children) do
            sub_child:EagerLoad(inject)
        end

        self:LazyLoad(inject)
    end

    --INFO: Loads a node
    --PRE: The node isn't loaded
    --POST: The node is loaded based off of its Lazy flag
    function Node:Load(inject: t.Injection)
        if self.Eager then
            self:EagerLoad(inject)
        else
            self:LazyLoad(inject)
        end
    end

    --INFO: Gets the contents of the node
    --PRE:  Injection injects the relevant information for Loading
    --POST: The content of the load is returned
    function Node:GetContent(inject: t.Injection)
        if not self.Loaded then
            self:Load(inject)
        end

        return self.Content
    end

    --INFO: Verifies whether a given ancestor is a ancestor of the current Node
    --PRE:  The ancestor is non-nil
    --POST: If the ancestor is an ancestor of the current node is returned
    function Node:CheckAncestry(ancestor: Instance): boolean
        return ancestor and ancestor:IsAncestorOf(self.I)
    end

end

type Node = typeof(Node.new(script, false))

return Node