--!strict

local Enums = require(script.Parent.Parent.Enums)

local Catcher = {}

function Catcher.strictEscape(context, escapes)
    return setmetatable({}, {
        __index = function(_, i)
            if escapes[i] then
                return escapes[i](context)
            else
                return nil
            end
        end
    })
end

function Catcher.strictIndexableEscape(context, escapes, fail)
    return setmetatable({}, {
        __index = function(_, i)
            if escapes[i] then
                return escapes[i](context)
            else
                return fail[i]
            end
        end
    })
end

function Catcher.escape(context, escapes)
    return setmetatable({}, {
        __index = function(_, i)
            if escapes[i] then
                return escapes[i](context)
            else
                return Catcher.escape(context:extend(i), escapes)
            end
        end
    })
end

function Catcher.tableWrapper(to_wrap, call_prefix, filter_type, filter)
    return setmetatable({}, {
        __index = function(_, i)
            local is_accessible_index = true

            if filter_type == Enums.StaticFilter.Whitelist then
                is_accessible_index = filter[i]
            elseif filter_type == Enums.StaticFilter.Blacklist then
                is_accessible_index = not filter[i]
            end

            if not is_accessible_index then
                return nil
            end

            local value = to_wrap[i]
            if value == nil then
                return nil
            elseif type(value) == "function" then
                return function(...)
                    value(call_prefix, ...)
                end
            elseif type(value) == "table" then
                return Catcher.tableWrapper(to_wrap, call_prefix, Enums.StaticFilter.All, {})
            else
                return value
            end
        end
    })
end

function Catcher.callableEscape(context, escapes, called)
    return setmetatable({}, {
        __index = function(_, i)
            if escapes[i] then
                return escapes[i](context)
            else
                return Catcher.callableEscape(context:extend(i), escapes, called)
            end
        end;
        __call = function(_, ...)
            return called(context, {...})
        end
    })
end

return Catcher