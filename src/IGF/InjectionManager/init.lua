--!strict

local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)
local Enums = require(script.Parent.Enums)
local Error = require(script.Parent.Error)

local Catcher = require(script.Catcher)
local Context = require(script.Context)

--INFO: Handles Injecting proxies into Modules
local InjectionManager = {}
InjectionManager.__index = InjectionManager

do

    --INFO: Constructs a new Injection Manager relying on network, module and data
    --PRE:  Network and Data are initialised
    --POST: InjectionManager is initialised
    function InjectionManager.new(NetworkManager, ModuleManager, DataManager)
        local self = setmetatable({}, InjectionManager)

        self.NetworkManager = NetworkManager
        self.ModuleManager = ModuleManager
        self.DataManager = DataManager

        self.IsServer = RunService:IsServer()
        self.IsClient = RunService:IsClient()

        return self
    end

    --INFO: Returns an injection function
    --POST: A Valid injector is returned
    function InjectionManager:GetInjector(): Types.Injection
        --INFO: Takes an Instance source, a Module content and gives back the Module Proxy for it,
        --      And the IGF proxy for it
        --PRE:  The Instance is the corresponding Module for ModuleContent
        --POST: The Proxies are returned
        return function(instance: Instance, module_content: table)
            local initialContext = Context.fromModule(instance)
            --TODO() Modify this to return a ModuleCatcher
            --RUN THE INIT HERE
            --CAPTURE THE ENUM AND BLACKLIST/WHITELIST
            --CONSTRUCT CATCHER WITH ALL THIS INFO
            --FINALLY CALL STATIC METHOD WITH THE PROXY GIVEN
            --old code:
            -- return if self.IsServer
            --     then self:GetServerInjection(initialContext)
            --     else self:GetClientInjection(initialContext)
        end
    end

    --INFO: Provides the Base injection without client/server specifics
    --PRE:  The Instance is non-nil
    --POST: The Injection for the Instance is created
    function InjectionManager:GetBaseInjection(instance: Instance)
        local injection = {}
        injection.Enums = Enums
        injection.Error = {}
        injection.printf = function(format: string)
            return Error.printf(format, instance.Name .. " Print: ")
        end
        injection.warnf = function(format: string)
            return Error.errorf(format, false, Error.USER_GENERATED)
        end
        injection.errorf = function(format: string, ...: any)
            return Error.errorf(format, true, Error.USER_GENERATED)
        end
        injection.assertf = function(format: string)
        return Error.assertf(format, true, Error.USER_GENERATED)
        end
        return injection
    end

    --INFO: Gets the Injection for Server context
    function InjectionManager:GetServerInjection(context)
        local injection = InjectionManager:GetBaseInjection(context.i)
        injection.Server = self:GetDataModuleCatcher(context:clone():addFlag("ServerTarget"))
        injection.Clients = self:GetClientsCatcher(context)
        return injection
    end

    --INFO: Gets the injection for Client context
    function InjectionManager:GetClientInjection(context)
        local injection = InjectionManager:GetBaseInjection(context.i)
        injection.Server = self:GetDataModuleCatcher(context:clone():addFlag("ServerTarget"))
        injection.Client = self:GetDataModuleCatcher(context:clone():addFlag("ClientTarget"))
        return injection
    end

    -- Need to implement Clients Catcher too!!
    function InjectionManager:GetClientsCatcher(context)
        --TODO()
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
        return Catcher.strictIndexableEscape(
            context, {
                Shared = function(oldContext)
                    return self:GetModuleAdditionCatcher(oldContext:clone():addFlag("Shared"))
                end;
            },
            self:GetModuleAdditionCatcher(context)
        )
    end

    function InjectionManager:GetModuleAdditionCatcher(context)
        return Catcher.strictIndexableEscape(context, {
                add = function(oldContext)
                    assert(self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget,
                        "Attempt to add Modules illegaly, across the client-server boundary.")
                    return function(...)
                        self.ModuleManager:Add(oldContext.Shared, ...)
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
                        self.ModuleManager:Retrieve(oldContext.i, table.clone(oldContext.path), oldContext.Shared)
                    end
                end;
            },
            function(...)
                self.ModuleManager:Run(context.i, table.clone(context.path), context.Shared, ...)
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

end

return InjectionManager