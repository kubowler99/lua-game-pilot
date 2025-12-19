local TaskQueue = require("Libs.taskQueue")
local SoundPlayer = require("Plugins.soundPlayer")

---@class List : table
---@field new fun(): List
---@field append fun(self: List, value: any)
---@field remove_value fun(self: List, value: any)
---@field contains fun(self: List, value: any): boolean

------------------------------------------------------------------------------------------------------------------------
-- Time Controller --
------------------------------------------------------------------------------------------------------------------------

---@class Time
---@field scale number Time scale multiplier (1.0 = normal speed, 0.5 = half speed, 2.0 = double speed)
---@field isPaused boolean Whether time is currently paused
local Time = {
  scale = 1
}

---Previous frame timestamp for delta time calculation
---@type number
local _prevTime       = 0

---Total elapsed game time (in milliseconds, scaled by time.scale)
---@type number
local _timeElapsed    = 0

---Timestamp when pause started (for calculating pause duration)
---@type number|nil
local _startPauseTime

---Objects pending subscription to enterFrame events
---@type table<any, any>
local newSubscribers   = {}

---Objects pending unsubscription from enterFrame events
---@type table<any, any>
local newUnsubscribers = {}

---Objects receiving enterFrame callbacks every frame
---@type List
local _enterFrameObjects = List.new()

---Objects that should pause/resume with time system
---@type List
local _pausableObjects   = List.new()

---Objects that respond to time scale changes
---@type List
local _scalableObjects   = List.new()

---Previous scale value for change detection
---@type number
local prevScale = 1

---Task queue for delayed function execution
---@type TaskQueue
local _taskQueue         = TaskQueue.new()

local min = math.min
local getTimer = system.getTimer

---Gets the current scaled game time
---@return number timeElapsed Total elapsed game time in milliseconds
function Time.getTimer()
  return _timeElapsed-- + min(getTimer() - _prevTime, 20)*Time.scale
end

---Subscribes an object to receive enterFrame callbacks
---Object must implement enterFrame(deltaTime, totalTime) method
---@param v table Object to subscribe (must have enterFrame method)
---@return void
function Time.subscribe(v)
  if newUnsubscribers[v] then
    newUnsubscribers[v] = nil
  else
    assert(not _enterFrameObjects:contains(v) and not newSubscribers[v], tostring(v).. " does")
    newSubscribers[v] = v
  end
end

---Unsubscribes an object from enterFrame callbacks
---@param v table Object to unsubscribe
---@return void
function Time.unsubscribe(v)
  if newSubscribers[v] then
    newSubscribers[v] = nil
  elseif _enterFrameObjects:contains(v) then
    newUnsubscribers[v] = v
  end
end

---Adds an object to receive pause/resume notifications
---Object must implement pause() and resume() methods
---@param subscriber table Object to add (must have pause/resume methods)
---@return void
function Time.addPausable(subscriber)
  _pausableObjects:remove_value(subscriber)
  _pausableObjects:append(subscriber)
end

---Removes an object from pause/resume notifications
---@param subscriber table Object to remove
---@return void
function Time.removePausable(subscriber)
  _pausableObjects:remove_value(subscriber)
end

---Adds an object to receive time scale change notifications
---Object can either have setTimeScale(scale) method or timeScale field
---@param subscriber table Object to add (with setTimeScale method or timeScale field)
---@return void
function Time.addScalable(subscriber)
  _scalableObjects:remove_value(subscriber)
  _scalableObjects:append(subscriber)
  if subscriber.setTimeScale then subscriber:setTimeScale(Time.scale)
  else                            subscriber.timeScale = Time.scale
  end
end

---Removes an object from time scale change notifications
---@param subscriber table Object to remove
---@return void
function Time.removeScalable(subscriber)
  _scalableObjects:remove_value(subscriber)
end

---Schedules a task to execute after a delay (using scaled game time)
---@param delay number Delay in milliseconds (affected by time scale)
---@param task function Function to execute after delay
---@return table task Task reference for cancellation
function Time.performWithDelay(delay, task)
  return _taskQueue:addTask{ time = delay, toDo = task }
end

---Sets the time scale immediately or with transition animation
---@param scale number Target time scale (1.0 = normal, 0.5 = half speed, etc.)
---@param params? table Optional transition parameters {time, delay, transition, tag, onStart, onComplete}
---@return void
function Time.setTimeScale(scale, params)
  if params then
    transition.to(Time, {
      tag        = params.tag or "time",
      delay      = params.delay,
      onStart    = params.onStart,
      time       = params.time or 50,
      transition = params.transition,
      scale      = scale,
      onComplete = params.onComplete,
    })

  else
    Time.scale = scale
  end
end


------------------------------------------------------------------------------------------------------------------------
-- Event Listeners --
------------------------------------------------------------------------------------------------------------------------

--[[
---Performance tracking arrays (for debug/profiling)
---@type table
local avgArray = {}
---@type number
local average = 0
---@type number
local worst  = 0
---@type number
local better = 9999999
--]]

---Core enterFrame callback - processes time and updates all subscribers
---Called every frame by Runtime:addEventListener("enterFrame", Time)
---@return boolean success True if frame was processed, false if paused or initializing
function Time.enterFrame()
  if Time.isPaused then return false end

  if _prevTime == 0 then
    _prevTime    = getTimer()
    return false
  end


  local currentTime = getTimer()
  local timeElapsed = min(currentTime - _prevTime, 20) * Time.scale
  _timeElapsed = _timeElapsed + timeElapsed
  _prevTime    = currentTime


  _taskQueue:performTasks(timeElapsed)

  for i=1, #_enterFrameObjects do
    _enterFrameObjects[i]:enterFrame(timeElapsed, _timeElapsed)
  end

  if prevScale ~= Time.scale  then
    prevScale = Time.scale
    for i=1, #_scalableObjects do
      local o = _scalableObjects[i]
      if o.setTimeScale then o:setTimeScale(Time.scale)
      else                   o.timeScale = Time.scale
      end
    end
  end

  for _, v in pairs(newSubscribers) do
    _enterFrameObjects:append(v)
  end
  for _, v in pairs(newUnsubscribers) do
    _enterFrameObjects:remove_value(v)
  end
  newSubscribers   = {}
  newUnsubscribers = {}

  return true
end

------------------------------------------------------------------------------------------------------------------------
-- Effects --
------------------------------------------------------------------------------------------------------------------------

---Creates a "hit lag" effect - briefly slows time then recovers
---Useful for impact feedback in action games
---@param strength number Strength multiplier for effect duration (typically 0.5-2.0)
---@return void
function Time.hitLag(strength)
  transition.cancel("time")
  local timeScale = Time.scale

  transition.to(Time, {
    tag        = "time",
    time       = 40* strength,
    scale      = .05,
    transition = easing.outQuad,
    onCancel = function()
      Time.scale = timeScale
    end,
    onComplete = function()
      transition.to(Time, {
        tag        = "time",
        time       = 80* strength,
        scale      = timeScale,
        transition = easing.outQuad,
        onCancel = function()
          Time.scale = timeScale
        end
      })
    end
  })
end

------------------------------------------------------------------------------------------------------------------------
-- Flow methods --
------------------------------------------------------------------------------------------------------------------------

---Starts the time system by registering enterFrame listener
---Should be called once during game initialization
---@return void
function Time.start()
  Runtime:addEventListener("enterFrame", Time)
end

---Resumes the time system after being paused
---@param avoidPause? boolean If true, adjusts timestamps to skip pause duration
---@return void
function Time.resume(avoidPause)
  if not Time.isPaused then return end
  if avoidPause then
    local pauseTime = getTimer() - _startPauseTime
    _prevTime = _prevTime + pauseTime
  end
  Time.isPaused = false

  SoundPlayer.resume()

  for _,o in pairs(_pausableObjects) do
    o:resume()
  end

  transition.resume("time")
end

---Pauses the time system
---Notifies all pausable objects and pauses sound/transitions
---@return void
function Time.pause()
  if Time.isPaused then return end
  Time.isPaused = true
  _startPauseTime = getTimer()

  SoundPlayer.pause()

  for _,o in pairs(_pausableObjects) do
    o:pause()
  end

  transition.pause("time")
end

---Completely stops the time system and removes enterFrame listener
---Use pause() instead if you want to resume later
---@return void
function Time.stop()
  Time.isPaused = true
  Runtime:removeEventListener("enterFrame", Time)
end

------------------------------------------------------------------------------------------------------------------------
-- Clear --
------------------------------------------------------------------------------------------------------------------------

---Resets time system to initial state
---Clears task queue and all subscribed objects
---@return void
function Time.hardReset()
  _taskQueue:hardReset()
  _enterFrameObjects = {}
end

---Complete cleanup - destroys task queue and object references
---Called during shutdown
---@return void
function Time.clear()
  _taskQueue = nil
  _enterFrameObjects = nil
end


return Time
