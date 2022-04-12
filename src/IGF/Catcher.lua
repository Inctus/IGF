--!strict
--[[    Catcher.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
                
        Full notice in IGF.lua      ]]--

function appendTo(t, v)
    local _t = table.create(#t+1)
    _t[#t+1] = v
    return table.move(t, 1, #t, 1, _t)
end

function catcher(called, set, path)
    return setmetatable({}, {
        __call = function(_, ...) return called(path, {...}) end;
        __index = function(_, i) return catcher(called, set, appendTo(path, i)) end;
    })
end

function new(called)
    return catcher(called, {})
end

return {new=new}
