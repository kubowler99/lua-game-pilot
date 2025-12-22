-- Spec Helper
-- This file sets up the test environment

-- Mock Solar2D/Corona SDK functions that don't exist in standard Lua
_G.display = _G.display or {}
_G.timer = _G.timer or {}
_G.transition = _G.transition or {}
_G.audio = _G.audio or {}
_G.system = _G.system or {}
_G.composer = _G.composer or {}
_G.native = _G.native or {}
_G.Runtime = _G.Runtime or {addEventListener = function() end}

-- Mock Solar2D's json module (uses dkjson or similar)
package.preload["json"] = function()
  -- Try to load a Lua JSON library, or provide a basic implementation
  local status, dkjson = pcall(require, "dkjson")
  if status then
    return dkjson
  end

  -- Fallback: basic JSON encode/decode
  local json = {}

  function json.encode(tbl)
    local function serialize(val)
      local t = type(val)
      if t == "table" then
        local result = {"{"}
        local first = true
        for k, v in pairs(val) do
          if not first then table.insert(result, ",") end
          first = false
          table.insert(result, string.format('["%s"]=%s', tostring(k), serialize(v)))
        end
        table.insert(result, "}")
        return table.concat(result)
      elseif t == "string" then
        return string.format('"%s"', val)
      elseif t == "number" or t == "boolean" then
        return tostring(val)
      elseif t == "nil" then
        return "null"
      end
    end
    return serialize(tbl)
  end

  function json.decode(str)
    -- Use Lua's load function for simple deserialization
    local func = load("return " .. str:gsub("null", "nil"))
    if func then
      return func()
    end
    return nil
  end

  return json
end

-- Add path for requiring project files
package.path = package.path .. ";./Libs/?.lua;./Plugins/?.lua;./Assets/?.lua;./pl/?.lua"

-- Mock device module to avoid file system dependencies
_G.device = {
  isApple = false,
  isAndroid = false,
  isSimulator = true,
}

-- Mock screen module
_G.screen = {
  width = 640,
  height = 960,
  centerX = 320,
  centerY = 480,
}

-- Load penlight (if available)
local status, result = pcall(function()
  require "pl.init"
  return pl
end)
if status and result then
  _G.List = result.List
end

-- Load class system (optional for now since tests don't require it)
local class_status, class = pcall(require, "Libs.middleclass")
if class_status then
  _G.Class = class
end

local stateful_status, stateful = pcall(require, "Libs.stateful")
if stateful_status then
  _G.Stateful = stateful
end

-- Now load utilities which will add math/string/table extensions
local math = math
local string = string
local table = table

-- Math Extensions
math.isANumber = function(n)
  return not (n ~= n or n*n == math.huge)
end

math.decimalRandom = function(a, b)
  return math.random()*(b-a)+a
end

math.sign = function(a)
  return a > 0 and 1 or a < 0 and -1 or 0
end

math.randomSign = function(a, b)
  return math.random(0, 1)*2-1
end

math.bidirRandom = function(a, b)
  local r = b*(math.random()*2-1)
  return r >= 0 and r+a or r-a
end

math.legs = function(angle, hypotenuse)
  return  math.cos(angle/180*math.pi)*hypotenuse,
          math.sin(angle/180*math.pi)*hypotenuse
end

math.hypotenuse = function(dx, dy, dz)
  dz = dz or 0
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

math.getAngle = function(dx, dy)
  return math.atan(dy/dx)*180/math.pi + (dx<0 and 180 or 0)
end

math.pair = function(number)
  number = number or math.random(1, 2)
  return (number%2)*2-1
end

-- Text Formatting
_G.textFormat = {}

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

-- Comparison Utilities
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

-- Table Utilities
local function shuffle(table)
  for i = 1, #table do
    local ndx0 = math.random( 1, #table )
    table[ ndx0 ], table[ i ] = table[ i ], table[ ndx0 ]
  end
  return table
end
_G.shuffle = shuffle

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

-- String Extensions
function string:capitalize()
  if type(self) ~= "string" then error("String expected, got "..type(self)) end
  return (self:gsub("^%l", string.upper))
end

function string:split(sep)
    sep = sep or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

-- Advanced Table Operations
local fcomp_default = function( a,b ) return a < b end

function table.bininsert(t, value, fcomp)
   fcomp = fcomp or fcomp_default
   local iStart,iEnd,iMid,iState = 1,#t,1,0
   while iStart <= iEnd do
      iMid = math.floor( (iStart+iEnd)/2 )
      if fcomp( value,t[iMid] ) then
         iEnd,iState = iMid - 1,0
      else
         iStart,iState = iMid + 1,1
      end
   end
   table.insert( t,(iMid+iState),value )
   return (iMid+iState)
end
