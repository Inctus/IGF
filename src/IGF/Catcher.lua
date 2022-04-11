--!strict
--[[	Catcher.lua | Copyright Notice

		INC Game Framework - OS Game Framework for Roblox
	    Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
	   	 	
		Full notice in IGF.lua		]]--

function appendTo(t, v)
	local _t = table.create(#t+1)
	_t[#t+1] = v
	return table.move(t, 1, #t, 1, _t)
end

function catcher(called, set, got, path)
	return setmetatable({}, {
		__call = function(_, ...) return called(path, {...}) end; 
		__index = function(_, i) return catcher(called, set, got, appendTo(path, i)) end; 
		__unm = function(_) return got(path) end;
		__newindex = function(_, i, v) set(appendTo(path, i), v) end; 
	}) 
end

function new(called, set, got)
	return catcher(called, set, got, {})
end

return {new=new}
