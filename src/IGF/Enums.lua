-- !strict
--[[    Enums.lua | Copyright Notice

        INC Game Framework - OS Game Framework for Roblox
        Copyright (C) 2022 Inctus (Haashim-Ali Hussain)
        
        Full notice in IGF.lua      ]]--

local t = require(script.Parent.Types)

return {
    DataContext = {
        ServerPublic = "ServerPublic";
        ClientPublic = "ClientPublic";
        ServerPrivate = "ServerPrivate";
        ClientPrivate = "ClientPrivate";
    } :: t.Dict<t.DataContext>
} :: t.Dict<t.Dict<string>>