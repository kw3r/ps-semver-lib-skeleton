local ExampleLib = {}
ExampleLib.__index = ExampleLib

function ExampleLib:new(caller)
    local instance = setmetatable({}, self)
    instance._name = "ExampleLib"
    instance._caller = caller
    return instance
end

function ExampleLib:_prefix()
    return "[" .. self._caller .. " > " .. self._name .. "] "
end

function ExampleLib:hello()
    core.log(self:_prefix() .. "Hello from version: " .. (self._version or "dev"))
end

function ExampleLib:get_version()
    return self._version or "dev"
end

return ExampleLib
