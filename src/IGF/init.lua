--!strict

local ModuleManager = require(script.ModuleManager)
local DataManager = require(script.DataManager)
local InjectionManager = require(script.InjectionManager)
local NetworkManager = require(script.NetworkManager)

--INFO: This is the main Class that contains the entire framework
local IGF = {};
IGF.__index = IGF

do

    function IGF.new(): IGF
        local self = setmetatable({}, IGF) :: IGF

        self.NetworkManager = NetworkManager.new()
        self.ModuleManager = ModuleManager.new()
        self.DataManager = DataManager.new()
        self.InjectionManager = InjectionManager.new(NetworkManager, ModuleManager, DataManager)
        ModuleManager:GiveInjection(self.InjectionManager:GetInjector())

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

end

return IGF.new()