# IGF - INC Game Framework

An experimental asynchronous reactive OOP based framework that lets you design your state and effectors separately. Modules have fine grained hierarchichal limitations, forcing you to ensure your hierarchy is sound and the single responsibility principle is being applied efficiently.

# Timeline

This project will be completed by mid 2022.

# To-Do:

- Simplify ModuleManager
  - ~~Convert forest into a HashMap<Instance, MetaData>~~
  - Wire Forest into ModuleManager
- InjectionManager Additions
  - Create Clients catcher for the Server
  - Use Error module for assertions
  - Wire network calls into NetworkManager from both Data and Module catchers
- DataManager
  - Implement Observable State Tree
  - Add server client checks and store relevant OST
  - Link OST to listeners using NetworkManager
- NetworkManager


NetworkManager

ModuleManager <- NetworkManager

DataManager <- NetworkManager

InjectionManager <- ModuleManager, DataManager

ModuleManager <- InjectionManager.Injection
