---@class State
---Reactive state management system with observer pattern
---Manages hierarchical data with dot-notation paths (e.g., "player.health")
---Notifies observers when values change
---Supports sub-states for scoped access
local Subject = require("Libs.State.subject")

local type     = type
local deepcopy = pl.tablex.deepcopy

local SH = Class("state")

---Creates a new State
---@param data table Initial state data
---@param inGameObject? any Game object associated with this state
---@param root? string Path prefix for nested states (internal use)
---@param subjects? table<string, Subject> Shared subjects table (internal use)
---@return State
function SH:initialize(data, inGameObject, root, subjects)
  self.root         = root or ""
  self._subjects    = subjects or {}
  self.inGameObject = inGameObject
  self:setState(data, root and subjects)
end

---Creates a sub-state scoped to a specific path
---Sub-state shares subjects with parent for unified observation
---@param path string Dot-notation path to scope to (e.g., "player")
---@param inGameObject? any Game object for this sub-state
---@return State subState Sub-state scoped to the path
function SH:getSubState(path, inGameObject)
  local data     = self:getValue(path)
  local root     = self.root..path.."."

  return SH:new(data, inGameObject, root, self._subjects)
end


---Sets a value at path and notifies observers
---Creates nested tables as needed
---@param path string Dot-notation path (e.g., "player.inventory.gold")
---@param value any Value to set
---@return void
function SH:setValue(path, value)
  local tablePath = path:split(".")
  local table     = self._data
  local root      = self.root
  local changes   = {}
  -- print("------------- "..tostring(self.inGameObject).." -------------")
  
  local newPath = tablePath[1]
  for i=1, #tablePath-1 do
    local key = tablePath[i]
    table[key] = table[key] or {}
    
    changes[root..newPath] = table[key]
    table = table[key]
    
    newPath = newPath.."."..tablePath[i+1]
  end
  

  local changed = false
  local f; f = function(o, d, dk, p)
    if type(o) == "table" then
      d[dk] = d[dk] or {}
      -- print(p  , d[dk])
      changes[p] = d[dk]
      for k,v in pairs(o) do
        f(v, d[dk], k, p.."."..dk)
      end
    elseif d[dk] ~= o then
      -- print(p, o)
      d[dk] = o
      changes[p] = o
      changed = true
    end
  end

  local key = tablePath[#tablePath]
  f(value, table, key, root..newPath)

  -- print("----------------------------------------\n\n")

  -- for k, v in pairs(changes) do
    -- print("changed: ", k, v)
  -- end
  if changed then
    for k,v in pairs(changes) do
      local subject = self._subjects[k]
      if subject then
        -- print("observing... ", k, v)
        subject:setValue(v)
      end
    end
  end
  
  -- print("----------------------------------------\n\n")
end


---Adds an increment to a numeric value at path
---@param path string Dot-notation path
---@param increment number Amount to add (can be negative)
---@return boolean|nil success False if increment is 0, otherwise void
function SH:add(path, increment)
  if increment == 0 then return false end

  self:setValue(path, self:getValue(path)+increment)
end

---Subtracts a value (clamped to available amount)
---@param path string Dot-notation path
---@param value number Amount to subtract
---@return number used Actual amount subtracted (clamped to current value)
function SH:use(path, value)
  if value <= 0 then return 0 end
  local currentValue = self:getValue(path)
  value = value > currentValue and currentValue or value

  self:setValue(path, currentValue-value)

  return value
end

---Subtracts from a numeric value at path
---@param path string Dot-notation path
---@param value number Amount to subtract
---@return boolean|nil success False if value is 0, otherwise void
function SH:subtract(path, value)
  if value == 0 then return false end

  self:setValue(path, self:getValue(path)-value)
end

---Gets value at path
---@param path string Dot-notation path (e.g., "player.name")
---@return any value The value at the path
function SH:getValue(path)
  local value = self._data
  for _,key in ipairs(path:split(".")) do
    assert( value, "Invalid request: Get "..path.." -  at "..key)
    value = value[key]
  end
  return value
end

---Observes a value at path for changes
---Creates a Subject if one doesn't exist
---@param path string Dot-notation path to observe
---@param key any Unique key for this observer
---@param observer function Observer callback: (key, event) -> boolean
---@param initCall? boolean If true, calls observer immediately with current value
---@return boolean success True if observer was added
function SH:observe(path, key, observer, initCall)
  assert(path and key and observer, "here")
  if not self._subjects[self.root..path] then
    self._subjects[self.root..path] = Subject:new(self, self.root..path, self:getValue(path))
  end
  return self._subjects[self.root..path]:subscribe(key, observer, initCall)
end

---Unobserve a value (removes observer)
---Cleans up subject if no observers remain
---@param path string Dot-notation path
---@param key any Observer key to remove
---@return void
function SH:unobserve(path, key)
  local subject = self._subjects[self.root..path]
  subject:unsubscribe(key)
  if subject.count == 0 then
    self._subjects[self.root..path] = nil
  end
end

---Replaces entire state data and notifies observers
---@param state table New state data
---@param doNotCopy? boolean If true, uses state directly without deep copy
---@return void
function SH:setState(state, doNotCopy)
  self._data = doNotCopy and state or deepcopy(state)

  for path,subject in pairs(self._subjects) do
    local sub, count = path:gsub(self.root, "")
    if self.root == "" or count == 1 then
      subject:setValue(self:getValue(sub))
    end
  end
end

---Gets a deep copy of the entire state data
---@return table data Deep copy of state data
function SH:getData()
  return deepcopy(self._data)
end


---Merges data into current state and notifies observers of changes
---@param data table Data to merge
---@param secondWins? boolean If true, data overwrites current; if false, current overwrites data
---@return void
function SH:merge(data, secondWins)
  local changes = {}

  -- print("------------- "..tostring(self.inGameObject).." -------------")

  local f; f = function(t1, t2, p)
    for k,v in pairs(t2) do
      local isATable = type(v) == "table"

      if isATable and t1[k] then
        changes[p..k] = v
        f(t1[k], v, p..k..".")
      else
        local f2; f2 = function(t, pathPrefix)
          for k2,v2 in pairs(t) do
            if type(v2) == 'table' then
              f2(v2[k2], pathPrefix..k2..".")
            else
              changes[pathPrefix..k2] = v2
            end
          end
          f2(v, pathPrefix)
        end

        if t1[k] ~= v then
          t1[k] = v
          changes[p..k] = v
          -- print("New Change!", p..k, v)

        end
      end
    end
  end

  if secondWins then
    f(self._data, data, self.root)
  else
    f(data, self._data, self.root)
    self._data = data
  end

  -- print("------------------")
  for path,subject in pairs(self._subjects) do
    local value = changes[path]
    -- print(path, value)
    if value then
      subject:setValue(value)
    end
  end
  -- print("----------------------------------------")

end


function SH:__tostring()
  local s = "-------- ".. (tostring(self.inGameObject) or self.id) .." - state --------\n"
  s = s .. pl.pretty.write(self._data) .. "\n"
  s = s .. "---------------------------------------------------"
  return s
end


return SH
