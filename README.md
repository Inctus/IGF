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
	self.IGF:AddModule()
			:AddSharedModule()
			:InitialiseServerData()
			:InitialiseLocalData()
			:InitialiseSharedData()
			:InitialiseClientSpecificData()
		.Data.Path.subscribe()
				  .get()
				  .set()
				  .rawSet()
		.Clients.[ClientName/All/Some(predicate)/Random].Data.Path.subscribe()
																  .get()
																  .set()
																  .rawSet()
													   	.Path.function()
		.Modules.Path()
		.Modules.Path.function()
	-- All of these return promises except GET (value) and SUBSCRIBE (subscription)
	self.subscription = self.Data.Path.subscribe{func1, func2}
	self.subscription:unSubscribe()
					 :reSubscribe()
					 :addBind()
end

function Example:main()
	self.subscription:unSubscribe()
	wait(10)
	self.subscription:reSubscribe()
end

--[[REPLICATEDFIRST LOCAL SCRIPT]]

require(game.IGF):AddModule(script.loadingModule)

--[[LOADING MODULE]]

local Loading = {}

function Loading:init()
	--[[PERFORM LOADING ASYNCHRONOUSLY]]
	self.IGF:AddModule(game.ReplicatedStorage.GameMain)
end

return Loading

--[[GAME MAIN]]

local GameMain = {}

function GameMain:init()
	self.IGF.InputHandler:require()
end

return GameMain

--[[InputHandler]]

local InputHandler = {}

function InputHandler:init()
	game.UserInputService:Connect(function()
		self.Data.Input:set(true)
	end)
end

--[[InputReactor]]

local InputReactor = {}

function inputDetected(_, new)
	if new == true then
		print("Input detected")
		self.Data.Input:rawSet(false)
	end
end

function InputReactor:init()
	self.Data.Input.subscribe(inputDetected)
end 
```
