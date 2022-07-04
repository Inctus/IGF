--!strict

local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)
local Enums = require(script.Parent.Enums)
local Error = require(script.Parent.Error)
local Utility = require(script.Parent.Utility)

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
        return function(instance: Instance, module_content: {any})
            local context = Context.fromModule(instance)
            local IGF_proxy = if self.IsServer then self:GetServerInjection(context) else self:GetClientInjection(context)
            local content_proxy

            if module_content.init then
                local static_filter_type, list = module_content.init(IGF_proxy)

                local _temp_list = {}
                for _, filter in list do
                    _temp_list[filter] = true
                end
                list = _temp_list

                if static_filter_type then
                    if static_filter_type == Enums.StaticFilter.All 
                        or static_filter_type == Enums.StaticFilter.Blacklist 
                            or static_filter_type == Enums.StaticFilter.Whitelist then
                        content_proxy = Catcher.tableWrapper(module_content, IGF_proxy, static_filter_type, list)
                    else
                        Error.InjectionManager.InvalidFilterType(static_filter_type, context.i)
                    end
                end
            end

            return IGF_proxy, content_proxy
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
        injection.Clients = self:GetClientsCatcher(context:clone():addFlag("ClientTarget"))
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
                    if not (self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget) then
                        Error.InjectionManager.AddFromServerToclient(self.IsServer and oldContext.ServerTarget, context.i, Utility.prettifyPath(context.path))
                        Error.InjectionManager.AddFromClientToServer(self.IsClient and oldContext.ClientTarget, context.i, Utility.prettifyPath(context.path))
                    end
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
                    if not (self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget) then
                        Error.InjectionManager.RequireFromServerToclient(self.IsServer and oldContext.ServerTarget, context.i, Utility.prettifyPath(context.path))
                        Error.InjectionManager.RequireFromClientToServer(self.IsClient and oldContext.ClientTarget, context.i, Utility.prettifyPath(context.path))
                    end
                    return function()
                        self.ModuleManager:Retrieve(oldContext.i, table.clone(oldContext.path), oldContext.Shared)
                    end
                end;
            },
            -- TODO()
            -- Possibly change this to allow Modules to be ran across the client-server boundary
            -- Requires significant refactoring
            function(...)
                if not (self.IsServer and context.ServerTarget or self.IsClient and context.ClientTarget) then
                    Error.InjectionManager.RunFromServerToClient(self.IsServer and context.ServerTarget, context.i, Utility.prettifyPath(context.path))
                    Error.InjectionManager.RunFromClientToServer(self.IsClient and context.ClientTarget, context.i, Utility.prettifyPath(context.path))
                end
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
                    if not (self.IsServer and oldContext.ServerTarget or self.IsClient and oldContext.ClientTarget) then
                        Error.InjectionManager.PrivateDataServerToClient(self.IsServer and context.ServerTarget, context.i)
                        Error.InjectionManager.PrivateDataClientToServer(self.IsClient and context.ClientTarget, context.i)
                    end
                    return self:GetDataInitialisationCatcher(oldContext:clone():addFlag("Private"))
                end;
            }
        )
    end

    function InjectionManager:GetDataInitialisationCatcher(context)
        return Catcher.strictIndexableEscape(context, {
                initialise = function(oldContext)
                    local valid = oldContext.ServerTarget and (oldContext.Public or oldContext.Private) and self.IsServer
                        or oldContext.ClientTarget and oldContext.Public and self.IsServer
                        or oldContext.ClientTarget and oldContext.Private and self.IsClient
                    Error.InjectionManager.IllegalDefinition(valid,
                        if oldContext.ClientTarget then "Client" else "Server",
                        if oldContext.Public then "Public" else "Private",
                        if self.IsClient then "Client" else "Server",
                        oldContext.i
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
            observe = function(oldContext)
                -- RETURN FUNC
            end;
        })
    end

end

return InjectionManager