-- Services/time.lua
-- Thin wrapper around Plugins/time.lua to expose a stable service API.

local ok, timePlugin = pcall(require, "Plugins.time")
if not ok then
    -- Minimal fallback implementation
    timePlugin = {
        start = function() end,
        pause = function() end,
        resume = function() end,
        scale = function() end,
        subscribe = function() end,
        unsubscribe = function() end,
        now = function() return system.getTimer() end,
    }
end

local TimeService = {}

function TimeService.start(...) if timePlugin.start then return timePlugin.start(...) end end
function TimeService.pause(...) if timePlugin.pause then return timePlugin.pause(...) end end
function TimeService.resume(...) if timePlugin.resume then return timePlugin.resume(...) end end
function TimeService.scale(f) if timePlugin.scale then return timePlugin.scale(f) end end
function TimeService.subscribe(...) if timePlugin.subscribe then return timePlugin.subscribe(...) end end
function TimeService.unsubscribe(...) if timePlugin.unsubscribe then return timePlugin.unsubscribe(...) end end
function TimeService.now(...) if timePlugin.now then return timePlugin.now(...) end return system.getTimer() end

return TimeService