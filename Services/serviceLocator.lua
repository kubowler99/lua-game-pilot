-- Services/serviceLocator.lua
-- Tiny service registry for dependency injection and migration from _G singletons.
--
-- Usage:
--   ServiceLocator.register("time", require("Services.time"))
--   local timeService = ServiceLocator.get("time")

local ServiceLocator = {
    _services = {}
}

--- Registers a service by name.
-- @param name string - Unique identifier for the service
-- @param impl any - The service implementation (table, function, or any value)
-- @throws error if name is not a string or impl is nil
function ServiceLocator.register(name, impl)
    assert(type(name) == "string", "service name must be a string")
    assert(impl ~= nil, "service impl required")
    if ServiceLocator._services[name] ~= nil then
        error(("Service '%s' already registered"):format(name))
    end
    ServiceLocator._services[name] = impl
    return ServiceLocator
end

--- Retrieves a registered service by name.
-- @param name string - The service identifier
-- @return any - The registered service implementation
-- @throws error if the service is not registered
function ServiceLocator.get(name)
    local s = ServiceLocator._services[name]
    if not s then
        error(("Service '%s' not registered"):format(name))
    end
    return s
end

--- Checks if a service is registered.
-- @param name string - The service identifier
-- @return boolean - true if the service exists, false otherwise
function ServiceLocator.has(name)
    return ServiceLocator._services[name] ~= nil
end

--- Removes a service from the registry.
-- @param name string - The service identifier to remove
function ServiceLocator.unregister(name)
    ServiceLocator._services[name] = nil
end

function ServiceLocator.tryGet(name)
    return ServiceLocator._services[name]
end

function ServiceLocator.clear()
    ServiceLocator._services = {}
end

return ServiceLocator