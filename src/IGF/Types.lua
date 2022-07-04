-- !strict

export type Array<T> = { [number]: T }

export type Dict<T> = { [string]: T }
export type NestedDict<T> = { [string]: Dict<T> }

export type HashMap<K,T> = { [K]: T }

export type Function<A,B> = (A) -> (B)
export type Closure = (...any?) -> (...any?)
export type Injection = (Instance, table, table) -> any

export type DataContext = "ServerPrivate" | "ServerPublic" | "ClientPrivate" | "ClientPublic"

return {}