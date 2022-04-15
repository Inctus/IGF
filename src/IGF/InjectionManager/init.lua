local RunService = game:GetService("RunService")

local Catcher = require(script.Catcher)
local Context = require(script.Context)

local InjectionManager = {}
InjectionManager.__index = InjectionManager

function InjectionManager.new(IGF)
    local self = setmetatable({}, InjectionManager)

    self.IGF = IGF
    self.IsServer = RunService:IsServer()
    self.IsClient = RunService:IsClient()

    return self
end

function InjectionManager:GetInjector()
    return function(instance: Instance)
        local initialContext = Context.fromModule(instance)
        return if self.IsServer
            then self:GetServerInjection(initialContext)
            else self:GetClientInjection(initialContext)
    end
end

function InjectionManager:GetServerInjection(context)
    local injection = {}
    injection.Server = self:GetDataModuleCatcher(context:clone():addFlag("ServerTarget"))
    injection.Clients = self:GetClientsCatcher(context)
    return injection
end

function InjectionManager:GetClientInjection(context)
    local injection = {}
    injection.Server = self:GetDataModuleCatcher(context:clone():addFlag("ServerTarget"))
    injection.Clients = self:GetClientsCatcher(context)
    injection.Client = self:GetDataModuleCatcher(context:clone():addFlag("ClientTarget"))
    return injection
end

function InjectionManager:GetDataModuleCatcher(context)
    return Catcher.strictEscape(context, {
        Data = function(oldContext)
            return self:GetDataPublicPrivateCatcher(oldContext)
        end;
        Modules = function(oldContext)
            return self:GetModuleSharedCatcher(oldContext)
        end;
    })
end

function InjectionManager:GetModuleSharedCatcher(context)
    return Catcher.strictIndexableEscape(context, {
            Shared = function(oldContext)
                return self:GetModuleAdditionCatcher(oldContext:clone():addFlag("Shared"))
            end;
        }, self:GetModuleAdditionCatcher(context)
    )
end

function InjectionManager:GetModuleAdditionCatcher(context)
    return Catcher.strictIndexableEscape(context, {
            add = function(oldContext)
                assert(self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget,
                    "Attempt to add Modules illegaly, across the client-server boundary.")
                return function(module: ModuleScript)
                    -- ADD THIS MODULE TO THE MODULE THING
                end
            end;
        }, self:GetFinalModuleCatcher(context)
    )
end

function InjectionManager:GetFinalModuleCatcher(context)
    return Catcher.callableEscape(context, {
            require = function(oldContext)
                assert(self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget,
                    "Attempt to add Modules illegaly, across the client-server boundary.")
                return function()
                    -- RETURN THE MODULE FROM THE CURRENT PATH INDEXED
                end
            end;
        },
        function(...)
            -- CALL THE CURRENT PATH INDEXED MODULE WITH THE ARGS PASSED
        end
    )
end

function InjectionManager:GetDataPublicPrivateCatcher(context)
    return Catcher.strictEscape(context, {
            Public = function(oldContext)
                return self:GetDataInitialisationCatcher(oldContext:clone():addFlag("Public"))
            end;
            Private = function(oldContext)
                assert(self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget,
                    "Attempt to access private Data illegally, across the client-server boundary.")
                return self:GetDataInitialisationCatcher(oldContext:clone():addFlag("Private"))
            end;
        }
    )
end

function InjectionManager:GetDataInitialisationCatcher(context)
    return Catcher.strictIndexableEscape(context, {
            initialise = function(oldContext)
                assert(oldContext.ServerTarget and (oldContext.Public or oldContext.Private) and self.IsServer
                    or oldContext.ClientTarget and oldContext.Public and self.IsServer
                    or oldContext.ClientTarget and oldContext.Private and self.IsClient,
                    string.format(
                        "Attempt to define %s%s illegally from %s",
                        if oldContext.ClientTarget then "Client." else "Server",
                        if oldContext.Public then "Public" else "Private",
                        if self.IsClient then "Client" else "Server"
                    )
                )
                -- ADD A CHECK TO SEE IF ITS ALREADY DECLARED
                return function(initialiser)
                    initialiser(self:GetDataDeclarationCatcher(oldContext))
                end
            end
        },
        self:GetFinalDataCatcher(context)
    )
end

function InjectionManager:GetDataDeclarationCatcher(context)
    return Catcher.escape(context, {
        declare = function(oldContext)
            return function(entity)
                -- INITIALISE DATA ALONG PATH CURRENTLY INDEXED W ENTITY
            end
        end
    })
end

function InjectionManager:GetFinalDataCatcher(context)
    return Catcher.escape(context, {
        get = function(oldContext)
            -- RETURN FUNC
        end;
        set = function(oldContext)
            -- RETURN FUNC
        end;
        rawSet = function(oldContext)
            -- RETURN FUNC
        end;
        subscribe = function(oldContext)
            -- RETURN FUNC
        end;
    })
end

return InjectionManager