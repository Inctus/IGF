-- !strict
--[[    Types.lua | Copyright Notice

        IGF.lua | Full Copyright Notice

        MIT License

        Copyright (c) 2022 Haashim-Ali Hussain      ]]--

export type Array<T> = { [number]: T }

export type Dict<T> = { [string]: T }
export type NestedDict<T> = { [string]: Dict<T> }

export type HashMap<K,T> = { [K]: T }

export type Function<A,B> = (A) -> (B)
export type Closure = (...any?) -> (...any?)
export type Injection = (Instance, table, table) -> any

export type DataContext = "ServerPrivate" | "ServerPublic" | "ClientPrivate" | "ClientPublic"

return {}