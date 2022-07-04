--!strict

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