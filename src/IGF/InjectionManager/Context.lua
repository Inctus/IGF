function appendTo(t, v)
    local _t = table.create(#t+1)
    _t[#t+1] = v
    return table.move(t, 1, #t, 1, _t)
end

function extend(context, index)
    local _n = {}
    for k, v in pairs(context) do
        if k ~= "path" then
            _n[k] = v
        end
    end
    _n.path = appendTo(context.path, index)
    return _n
end

function clone(context)
    local _n = {}
    for k, v in pairs(context) do
        _n[k] = v
    end
    return _n
end

function addFlag(context, index, value)
    context[index] = if value ~= nil then value else true
    return context
end

local Context = {}

function Context.fromModule(instance: Instance)
    return {
        i = instance;
        path = {};
        extend = extend;
        addFlag = addFlag;
        clone = clone;
    }
end

return Context