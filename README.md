# IGF - INC Game Framework

is a game framework that seamlessly joins server and client modules, with distinct data environments and networking fully abstracted. You never have to touch events. Everything is handled through the framework. From the ground up, built on two fundamental code patterns, the Catcher and the Promise, the framework completely abstracts the physical module hierarchy and allows for a completely imperative code flow. With entities with defined getters and setters, the data environments are fully encapsulated and shared seamlessly between server and client. With a functional aim to game development, the framework separates your State completely, leaving you to design both the State and Effectors distinctly.

# Timeline

This project will be completed by mid 2022.

```lua
local Example = {}

function func1(old, new, self)
	print(old + " changed to " + new)
end

function func2(old, new, self)
	print "I also see the change"
end

function Example:init()
	self.[variant].Data.Path.subscribe()
				 		  	.get()
				 		  	.set()
				 		  	.rawSet()
					   .initialisePublic() -- from SERVER -> SharedData from CLIENT -> SPECIFIC data
					   .initialisePrivate() -- from SERVER -> Server Private from CLIENT -> Client Private
			   	  .Modules.Path()
			   	  .Modules.Path.function()
			   	  .Modules.add()
			   	  .Modules.Shared.Path()
						         .Path.function()
						         .add()
	self.subscription = self.Data.Path.subscribe{func1, func2}
	self.subscription:unSubscribe()
					 :reSubscribe()
					 :bind()
end

function Example:main()
	self.subscription:unSubscribe()
	wait(10)
	self.subscription:reSubscribe()
end
```
