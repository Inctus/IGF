--!strict
--[[    IGF.lua | Full Copyright Notice

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
local Catcher = require(script.Catcher)
local Promise = require(script.Promise)

--<< REPOSITORY METATABLE >>

local IGF = {};
IGF.__index = IGF

--<< CONSTRUCTOR >>

function IGF.new(): IGF
    local self = setmetatable({}, IGF) :: IGF

    self.DataManager = DataManager.new()
    self.ModuleManager = ModuleManager.new(self:GetInjection())

    -- DATA MANAGER HANDLES IMPLICIT DATA REPLICATION AND SUBSCRIPTIONS
    -- self.DataManager = DataManager.new()
    -- READ WRITE PERMISSIONS           |   Server  |   Client  |
    -- SERVER DATA                      |       rw  |       --  |
    -- CLIENT DATA                      |       --  |       rw  |
    -- SHARED DATA                      |       rw  |       r-  |
    --                                  |---------- |   Owner   |   Other   |
    -- CLIENT SPECIFIC SHARED DATA      |       rw  |       rw  |       --  |

    return self
end

function IGF:GetInjection()
    return RunService:IsClient() and self:GetClientInjection()
        or RunService:IsServer() and self:GetServerInjection()
end

function IGF:GetServerInjection()
    local server = {
        Modules = ModuleCatcher;
        Data = DataCatcher;
    }
    local clientsCatcher = Catcher.new(function(path: t.Array<string>, args: {any}?)

    end)
end

function IGF:GetClientInjection()
    local client = {
        Modules = ModuleCatcher;
        Data = DataCatcher;
    }
    local clientsCatcher = Catcher.new(function(path: t.Array<string>, args: {any}?)

    end)
end

export type IGF = typeof(IGF.new())

return IGF.new()