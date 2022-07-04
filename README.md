# IGF - INC Game Framework

An experimental asynchronous reactive OOP based framework that lets you design your state and effectors separately. Modules have fine grained hierarchichal limitations, forcing you to ensure your hierarchy is sound and the single responsibility principle is being applied efficiently.

# Timeline

This project will be completed by August 2022.

# To-Do:

- ~~Fix Utility names in code~~
- ~~Simplify ModuleManager~~
  - ~~Convert forest into a HashMap<Instance, MetaData>~~
  - ~~Wire Forest into ModuleManager~~
  - ~~Add Run method to Node~~
  - ~~Annotate ModuleManager~~
- ~~Create Enums~~
- InjectionManager Additions
  - ~~Create Clients catcher for the Server~~
  - ~~Create tableWrapperCatcher~~
  - ~~Add Init handling to when injecting, to return the proxy and content catcher~~
  - ~~Use Error module for assertions~~
  - Wire network calls into NetworkManager from both Data and Module catchers
  - ~~Inject Enums into the Proxy directly as a reference to the Enums table~~
  - ~~Add printf, assertf and errorf as functions to the proxy.~~
- DataManager
  - Implement Observable State Tree
  - Create Subscription with statically generated GUID + timestamp
  - Add server client checks and store relevant OST
  - Link OST to listeners using NetworkManager
- NetworkManager
  - Support for cross-boundary subscriptions
  - Support for cross-boundary state tree replication
- ~~Avoid cyclic dependency of top-level Modules by making `NetworkManager` then `ModuleManager` then `DataManager` and then `InjectionManager` with `NetworkManager`, `ModuleManager` and `DataManager`, and finally passing in `InjectionManager.Injection` into `ModuleManager`~~
