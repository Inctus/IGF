# IGF - INC Game Framework

An experimental asynchronous reactive OOP based framework that lets you design your state and effectors separately. Modules have fine grained hierarchichal limitations, forcing you to ensure your hierarchy is sound and the single responsibility principle is being applied efficiently.

# Timeline

This project will be completed by mid 2022.

# To-Do:

- Simplify ModuleManager
  - ~~Convert forest into a HashMap<Instance, MetaData>~~
  - Wire network calls into NetworkManager
- DataManager
  - Implement OST
  - Add server client checks and store relevant OST
  - Link OST to listeners using NetworkManager
  - Wire network calls to NetworkManager
- InjectionManager wired into DataManager, ModuleManager
- NetworkManager

NetworkManager

ModuleManager <- NetworkManager

DataManager <- NetworkManager

InjectionManager <- ModuleManager, DataManager

ModuleManager <- InjectionManager.Injection
