--!strict
--[[    Catcher.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
                
        Full notice in IGF.lua      ]]--

local Catcher = {}

function Catcher.new(called, path)
    return setmetatable({}, {
        __call = function(_, ...) return called(path, {...}) end;
        __index = function(_, i) return Catcher.new(called, appendTo(path, i)) end;
    })
end

function Catcher.strictEscape(context, escapes)
    return setmetatable({}, {
        __index = function(_, i)
            if escapes[i] then
                return escapes[i](context)
            else
                error("Illegal index")
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