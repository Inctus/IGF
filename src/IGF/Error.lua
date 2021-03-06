local Error = {}

Error.FATAL = "[Fatal] "
Error.NON_FATAL = "[Warning] "

Error.SYNTAX = "Syntax Error: "
Error.LOGICAL = "Logical Error: "
Error.INTERNAL = "Internal Error: "
Error.USER_GENERATED = "User Error: "

function handleAssertion(is_fatal: boolean, format: string, kind: string)
	return function(assertion, ...)
		if not assertion then
			local to_print = string.format(if is_fatal then Error.FATAL else Error.NON_FATAL .. kind or "" .. format, ...)
			if is_fatal then
				error(to_print, 2)
			else
				warn(to_print)
			end
		end
	end
end

function handleError(is_fatal: boolean, format: string, kind: string)
	return function(...)
		local to_print = string.format(if is_fatal then Error.FATAL else Error.NON_FATAL .. kind or "" .. format, ...)
		if is_fatal then
			error(to_print, 2)
		else
			warn(to_print)
		end
	end
end

function handlePrint(format: string, kind: string)
	return function(...)
		print(kind .. string.format(format, ...))
	end
end

--INFO: Prints the formatted string to output nicely
--PRE:  The format string and arguments are aligned
--POST: The message is formatted and output
function Error.printf(format: string, kind: string?)
	return handlePrint(format, kind or "")
end

--INFO: Errors in the caller frame with the format string and arguments
--PRE:  The format string and arguments are aligned
--POST: Execution halts
function Error.errorf(format: string, is_fatal: boolean, kind: string?)
	return handleError(is_fatal, format, kind or "")
end

--INFO: Asserts in the caller frame with the assertion, format string and arguments
--PRE:  The format string and arguments are aligned
--POST: If the assertion fails, execution halts
function Error.assertf(format: string, is_fatal: boolean, kind: string?)
	return handleAssertion(is_fatal, format or "", kind or "")
end

-- Node Errors
Error.Node = {}
-- Node Creation
Error.Node.EmptyInsert = Error.assertf("Attempt to construct empty %s Node", true, Error.LOGICAL)
Error.Node.NonModuleRun = Error.assertf("Attempt to run non-table ModuleScript '%s'", true, Error.LOGICAL)

-- Forest Errors
Error.Forest = {}
-- Forest Insertion
Error.Forest.PreexistingInsert = Error.errorf("Attempt to add pre-existing Node '%s' to the %s Module Forest", false, Error.LOGICAL)
Error.Forest.EmptyInsert = Error.assertf("Attempt to construct empty %s Tree", true, Error.LOGICAL)
-- Forest Retrieval
Error.Forest.NoPathRetrieve = Error.assertf("Attempt to retrieve from the %s Module Forest with empty path'", true, Error.LOGICAL)
Error.Forest.NoSourceRetrieval = Error.assertf("Source node was nil from retrieval", true, Error.INTERNAL)
Error.Forest.UnknownSourceRetrieval = Error.assertf("Source %s for retrieval was unknown. Remember to add all Modules.", true, Error.LOGICAL)
Error.Forest.IllegalRetrievalFromSharedToPrivate = Error.assertf(
	"Attempt to retrieve Private Module %s from Shared Module %s. Consider moving %s to Shared.",
	true, 
	Error.FATAL
)
Error.Forest.UnknownRetrievalState = Error.errorf("Unknown retrieval state obtained", true, Error.INTERNAL)
Error.Forest.SharedRetrievalFailure = Error.assertf("Unable to retrieve Shared Module '%s' from Source '%s'", true, Error.LOGICAL)
Error.Forest.LostSource = Error.assertf("Lost the source of retrieval", true, Error.INTERNAL)
Error.Forest.UnknownTargetRetrieval = Error.assertf("Unknown Module '%s' encountered during retrieval from Source '%s' along '%'", true, Error.INTERNAL)
Error.Forest.RootRetrievalFailure = Error.assertf("Unable to retrieve Root '%s' from Global Lookup of %s Module Forest", true, Error.LOGICAL)
Error.Forest.GlobalRetrievalFailure = Error.assertf("Unable to retrieve Module '%s' from Global Lookup of %s Module Forest", true, Error.LOGICAL)
Error.Forest.GlobalUnknownTargetRetrieval = Error.assertf(
	"Unknown Module '%s' encountered during retrieval from the %s Module Forest along '%s'",
	true,
	Error.INTERNAL
)
Error.Forest.RetrievalFailure = Error.assertf("Unknown issue with retrieving along '%s' from '%s'", true, Error.INTERNAL)

-- Enum Errors
Error.Enums = {}
Error.Enums.AttemptedWrite = Error.errorf("Attempt to overwrite Enum '%s.%s' with Value '%s'", true, Error.LOGICAL)

-- ModuleManager Errors
Error.ModuleManager = {}
Error.ModuleManager.InjectedTwice = Error.assertf("Attempt to reinitialise Forest", true, Error.INTERNAL)

--InjectionManager Errors
Error.InjectionManager = {}
Error.InjectionManager.AddFromServerToclient = Error.assertf("Attempt to add Module from Server Source '%s' along path 'Client -> %s'", true, Error.LOGICAL)
Error.InjectionManager.AddFromClientToServer = Error.assertf("Attempt to add Module from Client Source '%s' along path 'Server -> %s'", true, Error.LOGICAL)
Error.InjectionManager.RequireFromServerToclient = Error.assertf("Attempt to require Module from Server Source '%s' along path 'Client -> %s'",
	true,
	Error.LOGICAL
)
Error.InjectionManager.RequireFromClientToServer = Error.assertf("Attempt to require Module from Client Source '%s' along path 'Server -> %s'",
	true,
	Error.LOGICAL
)
Error.InjectionManager.RunFromServerToclient = Error.assertf("Attempt to run Module from Server Source '%s' along path 'Client -> %s'", true, Error.LOGICAL)
Error.InjectionManager.RunFromClientToServer = Error.assertf("Attempt to run Module from Client Source '%s' along path 'Server -> %s'", true, Error.LOGICAL)
Error.InjectionManager.PrivateDataServerToClient = Error.assertf("Attempt to access Private Client data from Server Source '%s'", true, Error.LOGICAL)
Error.InjectionManager.PrivateDataClientToServer = Error.assertf("Attempt to access Private Client data from Server Source '%s'", true, Error.LOGICAL)
Error.InjectionManager.IllegalDefinition = Error.assertf("Illegaly defining %s.%s from %s Source '%s'", true, Error.LOGICAL)

Error.InjectionManager.InvalidFilterType = Error.errorf("Illegal Enums.StaticFilter provided '%d' from %s.init", true, Error.LOGICAL)

return Error