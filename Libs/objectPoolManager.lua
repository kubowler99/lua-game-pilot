---@class ObjectPoolManager
---High-level manager for object pool configurations
---Provides lazy loading of object factories and setup management
---Wraps low-level ObjectPool with convenient factory registration
local ObjectPoolManager = {}

------------------------------------------------------------------------------------------------------------------------
-- Configuration --
------------------------------------------------------------------------------------------------------------------------

---Registered setup configurations mapping names to pool definitions
---@type table<string, table<string, number>>
local setups = {
  basic      = require("Assets.Story.ObjectPool.basic"),
}

local ObjectPool = require("Plugins.objectPool")

---Factory definitions: maps object names to either module paths (string) or factory functions
---Examples:
---  myObject = "Assets.Entities.Animated.myObject" (lazy-loaded module)
---  myOtherObject = function() return display.newImageRect("path.png", 3, 3) end (function factory)
---@type table<string, string|function>
local factory = {

  -- myObject      = "Assets.Entities.Animated.myObject",
  -- myOtherObject = function() return display.newImageRect("Assets/Entities/Effects/Particles/small_chunk.png", 3, 3) end,

}

------------------------------------------------------------------------------------------------------------------------
-- Internal State --
------------------------------------------------------------------------------------------------------------------------

---Tracks which objects have been registered to avoid duplicate registration
---@type table<string, boolean>
local registeredObjects = {}

local type    = type
local require = require

---Resolves a factory for an object
---If factory is string (module path), requires it; otherwise returns function
---@param obj string Object name
---@return function factory Factory function that creates object instances
local function getFactory(obj)
  local f = factory[obj]
  if type(f) == "string" then
    f = require(f)
  end

  return f
end

------------------------------------------------------------------------------------------------------------------------
-- Public API --
------------------------------------------------------------------------------------------------------------------------

---Loads a predefined setup configuration
---Registers all objects defined in the setup with their counts
---@param setup string Setup name (e.g., "basic")
---@return void
function ObjectPoolManager.load(setup)
  local time = system.getTimer()
  print("----------------- LOADING SETUP -----------------")
  ObjectPoolManager.objectPool(setups[setup])
  print("-------------- BUFFER SETUP LOADED --------------")
  print("setup: "..setup)
  print("time: "..system.getTimer()-time)
  print("-------------------------------------------------")
end

---Registers multiple object pools from a configuration table
---@param objects table<string, number> Map of object names to pool counts
---@return void
function ObjectPoolManager.objectPool(objects)
  for obj,count in pairs(objects) do
    ObjectPool.registerWithFactory(obj, count, getFactory(obj), true)
    registeredObjects[obj] = true
  end
end

---Gets an object from pool, registering it lazily if not yet registered
---Automatically registers with count=1 if object hasn't been set up
---@param object string Object name
---@return table instance The pooled object instance
function ObjectPoolManager.getObject(object)
  if not registeredObjects[object] then
    -- print("obj", object)
    ObjectPool.registerWithFactory(object, 1, getFactory(object), true)
    registeredObjects[object] = true
  end
  return ObjectPool.getObject(object)
end


return ObjectPoolManager
