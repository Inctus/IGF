--!strict
--[[	ModuleManager.lua | Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	   	 	
		Full notice in IGF.lua		]]--

local t = require(script.Parent.Types)
local Forest = require(script.Forest)

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(inject: t.Injection): ModuleManager
	local self = setmetatable({}, ModuleManager)
	
	self.MainForest = Forest.new(inject) :: Forest
	self.SharedForest = Forest.new(inject, self.MainForest) :: Forest
	
	return self
end

function ModuleManager:AddModule(module: ModuleScript, eager_array: t.Array<ModuleScript>?)
	self.MainForest:AddTree(module, eager_array or {})
end

function ModuleManager:AddSharedModule(module: ModuleScript, eager_array: t.Array<ModuleScript>?)
	self.SharedForest:AddTree(module, eager_array or {})
end

function ModuleManager:GetModule(from: ModuleScript, path: t.Array<string>, isShared: boolean)
	--[[
	check that the desired forest contains the module
	
	then call retrieve
	
	need to rework retrieve to allow for global modules to retrieve shared moudles
	
	]]
end

function ModuleManager:CallModule(from: ModuleScript, path: t.Array<string>, args: t.Array<any>)
	--[[
	a) 	if the module passed isn't an instance then perform a lookup in the aggregated hashmap
		using the string name passed
	b) 	if no such module exists then error
	c)	if there is one, then perform an ancestry check on the caller module's node and the desired
		node and error if it is true
	d) 	check for a matching module in the sub-tree of the calling node using the aggregated hashmap
		and an ancestry check on the node
		i. load it if its not loaded, passing in the necessary info
		ii. return contents
	e) 	check for a matching module in the shared trees using the aggregated hashmap and then return
		that
	f) 	look for a matching module in the global hashmap and if it exists then return it, but warn the
		user that this is malpractice and that they should consider moving the module required to
		shared
		]]
end

function ModuleManager:SetModule(from: ModuleScript, path: t.Array<string>, value: any?)
	error([[Attempt to directly manipulate the module hierarchy.
		If you want to add a module, use Repo:AddModule(xxx)
		If you want to manipulate a module, use path.to.module.require() to get the contents.]])
end

function ModuleManager:GetCatcherHandlers(from: ModuleScript)
	local function call(path, args)
		
	end
	
	local function set(path, value)
		
	end
	
	local function get(path)
		
	end
	
	return call, set, get
end

type ModuleManager = typeof(ModuleManager.new(print))
type Forest = typeof(Forest.new(print))

return ModuleManager