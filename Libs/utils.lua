------------------------------------------------------------------------------------------------------------------------
-- Constants and variables --
------------------------------------------------------------------------------------------------------------------------

_G.device = require "Libs.device"

------------------------------------------------------------------------------------------------------------------------
-- Libraries --
------------------------------------------------------------------------------------------------------------------------

require "pl.init"
_G.List = pl.List

_G.Class    = require("Libs.middleclass")
_G.screen   = require("Libs.screen")
_G.Stateful = require("Libs.stateful")

------------------------------------------------------------------------------------------------------------------------
-- Math Extensions --
------------------------------------------------------------------------------------------------------------------------

local math = math

---Checks if a number is valid (not NaN or infinite)
---@param n number Number to check
---@return boolean valid True if number is valid, false if NaN or infinite
math.isANumber = function(n)
  return not (n ~= n or n*n == math.huge)
end

---Generates a random decimal number between two values
---@param a number Minimum value
---@param b number Maximum value
---@return number result Random decimal between a and b
math.decimalRandom = function(a, b)
  return math.random()*(b-a)+a
end

---Returns the sign of a number
---@param a number Input number
---@return number sign 1 if positive, -1 if negative, 0 if zero
math.sign = function(a)
  return a > 0 and 1 or a < 0 and -1 or 0
end

---Returns a random sign (1 or -1)
---@param a? number Unused parameter (kept for compatibility)
---@param b? number Unused parameter (kept for compatibility)
---@return number sign Either 1 or -1
math.randomSign = function(a, b)
  return math.random(0, 1)*2-1
end

---Generates a random number in bidirectional range: either [-b, -a] or [a, b]
---Example: bidirRandom(10, 20) returns values in ranges -20 to -10 OR 10 to 20
---@param a number Minimum absolute value
---@param b number Maximum absolute value
---@return number result Random value in bidirectional range
math.bidirRandom = function(a, b)
  local r = b*(math.random()*2-1)
  return r >= 0 and r+a or r-a
end

---Calculates the x and y components (legs) from angle and hypotenuse
---@param angle number Angle in degrees
---@param hypotenuse number Length of hypotenuse
---@return number x X component (adjacent leg)
---@return number y Y component (opposite leg)
math.legs = function(angle, hypotenuse)
  return  math.cos(angle/180*math.pi)*hypotenuse,
          math.sin(angle/180*math.pi)*hypotenuse
end

---Calculates the hypotenuse (distance) from components
---@param dx number X component
---@param dy number Y component
---@param dz? number Optional Z component (defaults to 0)
---@return number distance The hypotenuse length (3D if dz provided)
math.hypotenuse = function(dx, dy, dz)
  dz = dz or 0
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

---Calculates angle in degrees from dx and dy components
---@param dx number X component (horizontal distance)
---@param dy number Y component (vertical distance)
---@return number angle Angle in degrees (0-360)
math.getAngle = function(dx, dy)
  return math.atan(dy/dx)*180/math.pi + (dx<0 and 180 or 0)
end

---Returns 1 or -1 based on whether number is even or odd
---@param number? number Input number (defaults to random 1 or 2 if nil)
---@return number result 1 if even, -1 if odd
math.pair = function(number)
  number = number or math.random(1, 2)
  return (number%2)*2-1
end

------------------------------------------------------------------------------------------------------------------------
-- Text Formatting --
------------------------------------------------------------------------------------------------------------------------

---Table containing text formatting utilities
---@type table
_G.textFormat = {}

---Formats time in seconds to human-readable format (HH:MM:SS or MM:SS or SS)
---@param remainingTime number Time in seconds
---@return string formatted Formatted time string (e.g., "1:23:45", "12:34", or "42")
_G.textFormat.time = function(remainingTime)
  local time = math.ceil(remainingTime)%60
  local t
  if remainingTime >= 59 then
    if time < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/60)%60)
    time = t..":"..time
  end
  if remainingTime >= 3599 then
    if t < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/3600)%24)
    time = t..":"..time
  end
  if remainingTime >= 86399 then
    if t < 10 then time = "0"..time end
    time = math.floor((remainingTime+1)/86400)..":"..time
  end

  return time
end

------------------------------------------------------------------------------------------------------------------------
-- Comparison Utilities --
------------------------------------------------------------------------------------------------------------------------

---Deep equality comparison for tables and primitives
---Recursively compares all keys and values in tables
---@param o1 any First object to compare
---@param o2 any Second object to compare
---@return boolean equal True if objects are deeply equal
local function equals(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end

  return true
end
_G.equals = equals

------------------------------------------------------------------------------------------------------------------------
-- Table Utilities --
------------------------------------------------------------------------------------------------------------------------

---Randomly shuffles array elements in-place (Fisher-Yates algorithm)
---@param table table Array to shuffle
---@return table shuffled The same table reference, shuffled
local function shuffle(table)
  for i = 1, #table do
    local ndx0 = math.random( 1, #table )
    table[ ndx0 ], table[ i ] = table[ i ], table[ ndx0 ]
  end
  return table
end
_G.shuffle = shuffle

---Calculates the maximum depth of a display group hierarchy
---@param group table Display group to measure
---@param c number Current depth level (internal parameter)
---@return number depth Maximum depth of the group hierarchy
local function getDepth(group, c)
  local depth = c
  if group.numChildren then
    for i = 1,group.numChildren do
      local d = getDepth(group[i], c+1)
      depth = depth < d and d or depth
    end
  end
  return depth
end
_G.getDepth = getDepth

------------------------------------------------------------------------------------------------------------------------
-- String Extensions --
------------------------------------------------------------------------------------------------------------------------

---Capitalizes the first letter of a string
---@return string capitalized String with first letter capitalized
function string:capitalize()
  if type(self) ~= "string" then error("String expected, got "..type(self)) end
  return (self:gsub("^%l", string.upper))
end

---Splits a string by separator into an array
---@param sep? string Separator character (defaults to ":")
---@return table fields Array of split string parts
function string:split(sep)
    sep = sep or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

------------------------------------------------------------------------------------------------------------------------
-- Advanced Table Operations --
------------------------------------------------------------------------------------------------------------------------

---Default comparison function for binary insertion (ascending order)
---@param a any First value
---@param b any Second value
---@return boolean less True if a < b
local fcomp_default = function( a,b ) return a < b end

---Inserts value into sorted array using binary search
---Maintains sort order after insertion
---@param t table Sorted array to insert into
---@param value any Value to insert
---@param fcomp? function Optional comparison function (defaults to < operator)
---@return number index Position where value was inserted
function table.bininsert(t, value, fcomp)
   -- Initialize compare function
   fcomp = fcomp or fcomp_default
   --  Initialize numbers
   local iStart,iEnd,iMid,iState = 1,#t,1,0
   -- Get insert position
   while iStart <= iEnd do
      -- calculate middle
      iMid = math.floor( (iStart+iEnd)/2 )
      -- compare
      if fcomp( value,t[iMid] ) then
         iEnd,iState = iMid - 1,0
      else
         iStart,iState = iMid + 1,1
      end
   end
   table.insert( t,(iMid+iState),value )
   return (iMid+iState)
end