local RunService = game:GetService("RunService")

local Catcher = require(script.Catcher)

local InjectionManager = {}
InjectionManager.__index = InjectionManager

function appendTo(t, v)
    local _t = table.create(#t+1)
    _t[#t+1] = v
    return table.move(t, 1, #t, 1, _t)
end

function extend(context, index)
    local _n = {}
    for k, v in pairs(context) do
        if k ~= "path" then
            _n[k] = v
        end
    end
    _n.path = appendTo(context.path, index)
    return _n
end

function InjectionManager.new(IGF)
    local self = setmetatable({}, InjectionManager)

    self.IGF = IGF

    return self
end

function InjectionManager:GetInjector()
    return self:GetInjectorNamed(if RunService:IsServer() then "Server" else "Client")
end

function InjectionManager:GetInjectorNamed(name: string)
    return function(instance: Instance, module: any?)
        local initialContext = {
            i = instance;
            path = {};
            extend = extend;
        }
        local injection = {}
        injection[name] = self:GetStartCatcher(initialContext)
        injection.Clients = self:GetClientsCatcher(initialContext)
    end
end

function InjectionManager:GetStartCatcher(context)
    return Catcher.strictEscape(context, {
        Data = function(oldContext)
            --TODO() eval oldContext
            local newContext = {}
            return self:GetDataCatcher(newContext)
        end;
        Modules = function(oldContext)
            --TODO() eval oldContext
            local newContext = {}
            return self:GetModuleCatcher(newContext)
        end;
    })
end

function InjectionManager:GetClientsCatcher(context)
    return Catcher.strictEscape(context, {
        All = function(oldContext)
            --TODO() eval context
            local newContext = {}
            return self:GetStartCatcher(newContext)
        end;
        Some = function(oldContext)
            --TODO() eval context
            local newContext = {}
            return function(filter)
                local clients = {}
                -- filter clients
                -- filter(clients)
                return self:GetStartCatcher(newContext)
            end
        end;
        Others = function(oldContext)
            --TODO() eval context
            local newContext = {}
            return self:GetStartCatcher(newContext)
        end;
    })
end

function InjectionManager:GetModuleCatcher(context)
    return Catcher.strictIndexableEscape(context, {
            Shared = function(oldContext)
                -- TODO() update oldContext
                local newContext = {}
                return self:GetSecondModuleCatcher(newContext)
            end
        },
        self:GetSecondModuleCatcher(context)
    )
end

function InjectionManager:GetSecondModuleCatcher(context)
    return Catcher.strictIndexableEscape(context, {
        add = function(oldContext)
            -- TODO() eval oldContext
            local newContext = {}
            return function(...)
                -- pipe it into module additions
            end
        end
        }, 
        self:GetThirdModuleCatcher(context)
    )
end

function InjectionManager:GetThirdModuleCatcher(context)
    return Catcher.callableEscape(context, {
            ["require"] = function(oldContext)
                --TODO() eval oldContext
                return function(...)
                    -- pipe it into module require
                end
            end;
        }, function(oldContext, args)
            --TODO() eval oldContext
            -- pipe it into module run :main
        end
    )
end

function InjectionManager:GetDataCatcher(context)
    return Catcher.strictEscape(context, {
            Public = function(oldContext)
                --TODO() eval oldContext
                local newContext = {}
                return self:GetSecondDataCatcher(newContext)
            end;
            Private = function(oldContext)
                --TODO() eval oldContext
                local newContext = {}
                return self:GetSecondDataCatcher(newContext)
            end;
        }
    )
end

function InjectionManager:GetSecondDataCatcher(context)
    return Catcher.strictIndexableEscape(context, {
        initialise = function(oldContext)
            --TODO() eval context
            -- CHECK if data is initialised and ERRORRR
            return function(initialiser)
                initialiser(self:GetDataInitialisationCatcher(oldContext))
            end
        end
        },
        self:GetThirdDataCatcher(context)
    )
end

function InjectionManager:GetThirdDataCatcher(context)
    return Catcher.escape(context, {
        get = function(oldContext)
            --TODO() eval context
            return function(...)
                -- pipe args into data get
            end
        end;
        set = function(oldContext)
            --TODO() eval context
            return function(...)
                -- pipe args into data set
            end
        end;
        rawSet = function(oldContext)
            --TODO() eval context
            return function(...)
                -- pipe args into data rawSet
            end
        end;
    })
end

function InjectionManager:GetDataInitialisationCatcher(context)
    return Catcher.escape(context, {
        declare = function(oldContext)
            --TODO() eval context
            return function(...)
                -- pipe args into declare data
            end
        end
    })
end

return InjectionManager