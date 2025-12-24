-- compat/_G_shim.lua
-- Compatibility shim mapping legacy _G.* singletons to Services.serviceLocator
-- Toggle via Debug/settings.lua USE_COMPAT_SHIM flag.

local serviceLocator = require("Services.serviceLocator")

local Shim = {}

function Shim.install()
    if _G.__SERVICES_SHIM_INSTALLED then return end
    _G.__SERVICES_SHIM_INSTALLED = true

    local function getter(name)
        return function()
            if serviceLocator.has(name) then
                return serviceLocator.get(name)
            else
                return nil
            end
        end
    end

    -- Map common names used in the template
    local mappings = {
        game = "Game",
        time = "Time",
        savedData = "Save",
        ObjectPool = "Pool",
        soundPlayer = "Sound",
        transition2 = "Transition2"
    }

    for gname, sname in pairs(mappings) do
        -- only set if not already present
        if _G[gname] == nil then
            local ok, svc = pcall(serviceLocator.get, sname)
            if ok and svc then
                _G[gname] = svc
            else
                -- leave nil; modules will fallback to serviceLocator.get when migrated
            end
        end
    end
end

return Shim