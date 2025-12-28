-- Load centralized configuration
local Config = require("Libs.config")

-- Load debug settings and merge into Config.Debug
local settings = require("Debug.settings")
for k, v in pairs(settings) do
  Config.Debug[k] = v
end

-- Maintain backward compatibility with _G.DEBUG
_G.DEBUG = Config.Debug

local composer = require("composer")
composer.isDebug = Config.Debug.COMPOSER

if Config.Debug.GAME_SCALE and Config.Debug.GAME_SCALE ~= 1 then
  local view = display.getCurrentStage()
  local s = Config.Debug.GAME_SCALE
  view.xScale, view.yScale = s, s
  view.x, view.y = screen.width*(1-s)/2, screen.edgeY*(1-s)*.5
end


if Config.Debug.PLAY_IN_SLOWMO then
  timer.performWithDelay(17000, function() _G.game.time.setTimeScale(0.1) end)
end


if Config.Debug.PROFILER then
  local profiler = require "Debug.profiler"
  profiler.startProfiler(Config.Debug.PROFILER)
end


if Config.Debug.SHOW_PERFORMANCE then
  timer.performWithDelay(1000, function()
    require("Debug.debugInfo")
  end)
end


if Config.Debug.SKIP_ERRORS then
  local function myUnhandledErrorListener( event )
     local errorMessage = "ERROR:  " ..
         event.errorMessage .. "\n" ..
         event.stackTrace .. "\n\n\n\n"..
         "**IMPORTANT**!!: Pressing continue may trigger more unexpected issues"

     native.showAlert( "Handling the unhandled error", errorMessage, {"CONTINUE", "QUIT GAME"}, function(alertEvent)
       if ( alertEvent.action == "clicked" ) then
         local i = alertEvent.index
         if i == 1 then
         -- DO NOTHING

         elseif i == 2 then
         os.exit(1)

         end
       end
     end)

     print("ERROR:  "..errorMessage)

     if _G.game then _G.game.suspend() end

     return true
   end

  Runtime:addEventListener( "unhandledError", myUnhandledErrorListener )
end
