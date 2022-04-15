--!strict
--[[    IGF.lua | Full Copyright Notice

        MIT License

        Copyright (c) 2022 Haashim-Ali Hussain

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
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