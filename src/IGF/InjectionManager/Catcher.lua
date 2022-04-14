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

-- function escapeCatcherPath(path, escapes)
--     return setmetatable({}, {
--         __index = function(_, i)
--             if escapes[i] then
--                 return escapes[i](path)
--             else
--                 return escapeCatcherPath(appendTo(path, i), escapes)
--             end
--         end
--     })
-- end

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


-- function callableEscapeCatcherPath(path, escapes, called)
--     return setmetatable({}, {
--         __index = function(_, i)
--             if escapes[i] then
--                 return escapes[i](path)
--             else
--                 return callableEscapeCatcherPath(appendTo(path, i), escapes, called)
--             end
--         end;
--         __call = function(_, ...)
--             return called(path, {...})
--         end
--     }
-- end

-- function appendTo(t, v)
--     local _t = table.create(#t+1)
--     _t[#t+1] = v
--     return table.move(t, 1, #t, 1, _t)
-- end

-- local Data2 = Catcher.escape({
--     extend = function(self, i)
--         local new = {}
--         new.path = appendTo(self.path, i)
--         for k, v in pairs(self) do
--             if k ~= "path" then
--                 new[k] = v
--             end
--         end
--         return new
--     end;
--     },
--     {
--         get = function(context)

--         end;
--         set = function(context)

--         end;
--         rawSet = function(context)

--         end;
--         initialise = function(context)

--         end;
--     }
-- )

return Catcher