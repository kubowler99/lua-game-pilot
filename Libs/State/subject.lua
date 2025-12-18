---@class Subject
---Observable subject implementing the Observer pattern
---Holds a value that observers can watch for changes
---When value changes, all subscribed observers are notified
---Used by State system for reactive state management
local deepcopy = pl.tablex.deepcopy

local Subject = Class("subject")

---Creates a new Subject
---@param state State Parent state object
---@param path string Dot-notation path to this value in state (e.g., "player.health")
---@param value any Initial value
---@return Subject
function Subject:initialize(state, path, value)
  self._state       = state
  self.path         = path
  self._value       = value
  self.inGameObject = state.inGameObject

  self.observers = {}
  self.count = 0
end

---Notifies all observers of a change event
---If observer returns true, it's automatically unsubscribed (one-time observer)
---@param event table Event data: {target, path, prev, value}
---@return void
function Subject:notify(event)
  for key,obs in pairs(pl.tablex.copy(self.observers)) do
    if obs(key, event) then
      self.observers[key] = nil
      self.count = self.count -1
    end
  end
end

---Sets the value and notifies observers if changed
---Deep copies table values to prevent reference issues
---@param value any New value to set
---@return boolean changed True if value changed and observers notified
function Subject:setValue(value)
  if value == self._value and type(value) ~= "table" then return false end

  if type(value) == "table" then
    value = deepcopy(value)
  end

  local prev = self._value
  self._value = value
  self:notify{
    target = self.inGameObject,
    path   = self.path,
    prev   = prev,
    value  = value
  }

  return true
end

---Gets the current value
---@param value any (parameter appears unused - delegates to state)
---@return any value The current value
function Subject:getValue(value)
  self._state:getValue(value, self.path)
end

---Subscribes an observer to value changes
---@param key any Unique key to identify this observer
---@param observer function Observer callback: (key, event) -> boolean (return true to unsubscribe)
---@param initCall? boolean If true, immediately calls observer with current value
---@return boolean success True if subscribed, false if key already exists
function Subject:subscribe(key, observer, initCall)
  if self.observers[key] then return false end
  self.observers[key] = observer

  if initCall then
    observer(key, {
      target = self.inGameObject,
      path   = self.path,
      prev   = self._value,
      value  = self._value
    })
  end

  self.count = self.count +1

  return true
end

---Unsubscribes an observer
---@param observer any Observer key to remove
---@return boolean success True if unsubscribed, false if not found
function Subject:unsubscribe(observer)
  if not self.observers[observer] then return false end
  self.observers[observer] = nil
  self.count = self.count -1
end


return Subject
