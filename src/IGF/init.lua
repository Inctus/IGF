--!strict
--[[	IGF.lua | Full Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	    Contact -> business@inctus.com / business@haash.im
	    Source -> https://github.com/Inctus/IGF

	    This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU Affero General Public License as published
	    by the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.

	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	    GNU Affero General Public License for more details.

	    You should have received a copy of the GNU Affero General Public License
	    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local RunService = game:GetService("RunService")

local t = require(script.Types)
local ModuleManager = require(script.ModuleManager)
local DataManager = require(script.DataManager)
local Promise = require(script.Promise)
local Catcher = require(script.Catcher)

--<< REPOSITORY METATABLE >>

local Repository = {}; 
Repository.__index = Repository

--<< CONSTRUCTOR >>

function Repository.new(): Repository
	local self = setmetatable({}, Repository) :: Repository
	
	-- MODULE MANAGER HANDLES THE INTERNAL MODULE FOREST
	self.ModuleManager = ModuleManager.new(function(instance, module)
		--[[
		inject will inject a catcher which is specific to a given module
		this catcher will catch for
		Data -> Data manager
		Clients -> Data manager / network
		anything else -> ModuleManager
		]]
	end)
	
	-- DATA MANAGER HANDLES IMPLICIT DATA REPLICATION AND SUBSCRIPTIONS
	-- self.DataManager = DataManager.new()
	-- READ WRITE PERMISSIONS 			| 	Server 	|	Client 	|
	-- SERVER DATA						|		rw 	| 		--	|
	-- CLIENT DATA						|   	--	|		rw	|
	-- SHARED DATA						|		rw	|		r-	|
	--									|----------	|	Owner	|	Other 	|
	-- CLIENT SPECIFIC SHARED DATA 	|   	rw	|		rw	|		--	|
	
	return self
end

--<< MODULE MANAGEMENT >>

function Repository:AddModuleTo(module: ModuleScript, eager_loaded: t.Array<ModuleScript>, is_shared: boolean)
	
	-- pass in injector function
	
	-- construct proxy when a module is loaded, construct connection and inject it into it
	-- both the connection and the proxy for the repository
	-- need to therefore give ModuleManager a proxy_table for repository, alongside
	-- references to the Data and Module catcher, so that it can reconstruct a metatable
	-- for each node that gets loaded
end

function Repository:AddModule(module: ModuleScript, eager_loaded: t.Array<ModuleScript>)
	self:AddModuleTo(module, eager_loaded, false)
	-- Get ModuleManager to index modules, add them, into a tree structure.
	-- When ModuleManager attempts to retrieve a module, index the tree to find the module
	-- Initialise module, alongside dependencies (bottom-up) (using preserved hierarchy)
	-- Remove initialised modules from the uninitiailised tree
	-- Retrieve module; give it back
	-- Make it illegal for a module to require a module higher than it in the hierarchy?? what madness
end

function Repository:AddSharedModule(module: ModuleScript, eager_loaded: t.Array<ModuleScript>)
	self:AddModuleTo(module, eager_loaded, true)
end

--<< DATA MANAGEMENT >>

function Repository:InitialiseServerData()
	
end

function Repository:InitialiseSharedData()
	
end

function Repository:InitialiseClientSpecificData()
	
end

function Repository:InitialiseLocalData()

end

export type Repository = typeof(Repository.new())
export type Catcher = typeof(Catcher.new(print, print, print)) 

return Repository.new()