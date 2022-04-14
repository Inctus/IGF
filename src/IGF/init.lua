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

local ModuleManager = require(script.ModuleManager)
local DataManager = require(script.DataManager)
local InjectionManager = require(script.InjectionManager)
local NetworkManager = require(script.NetworkManager)

--<< REPOSITORY METATABLE >>

local IGF = {};
IGF.__index = IGF

--<< CONSTRUCTOR >>

function IGF.new(): IGF
    local self = setmetatable({}, IGF) :: IGF

    self.InjectionManager = InjectionManager.new(IGF)
    self.DataManager = DataManager.new(IGF)
    self.ModuleManager = ModuleManager.new(IGF)
    self.NetworkManager = NetworkManager.new(IGF)

    -- DATA MANAGER HANDLES IMPLICIT DATA REPLICATION AND SUBSCRIPTIONS
    -- self.DataManager = DataManager.new()
    -- READ WRITE PERMISSIONS           |   Server  |   Client  |
    -- SERVER DATA                      |       rw  |       --  |
    -- CLIENT DATA                      |       --  |       rw  |
    -- SHARED DATA                      |       rw  |       r-  |
    --                                  |---------- |   Owner   |   Other   |
    -- CLIENT SPECIFIC SHARED DATA      |       rw  |       rw  |       r-  |

    return self
end

export type IGF = typeof(IGF.new())

return IGF.new()