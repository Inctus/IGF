local t = require(script.Parent.Types)

return {
    DataContext = {
        ServerPublic = "ServerPublic";
        ClientPublic = "ClientPublic";
        ServerPrivate = "ServerPrivate";
        ClientPrivate = "ClientPrivate";
    } :: t.Dict<t.DataContext>
} :: t.Dict<t.Dict<string>>