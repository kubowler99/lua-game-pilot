local composer = require("composer")

local LoadingScreen = require("Plugins.loadingScreen")
local State         = require("Libs.State.state")

-- Use centralized config for stories
local stories = Config.Game.stories

---@alias Story chapterBasics

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --               - -- ---   My Game   --- -- -                  -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

---@class Game
---@field shortcuts table<string, any> Scene object references for quick access
---@field time Time Time controller system managing game speed and pausing
---@field music table Music manager for background audio
---@field state State Current game state object
---@field story Story Current active story/chapter
---@field layers table<string, any> Display layers for rendering organization
---@field currentScene table Reference to the current Composer scene
---@field pauseOnSuspend boolean? Whether to pause time when app suspends
---@field _currentScene string Internal tracker for current scene name
local Game = {}
_G.game = Game
_G.Game = Game

---Quick reference shortcuts to scene objects
---@type table<string, any>
Game.shortcuts = {}

---Time controller managing game speed, pausing, and frame timing
---@type Time
Game.time       = require("Plugins.time")

---Music manager for background audio
---@type table
Game.music      = require("Assets.Audio.music")

_G.transition2    = require("Libs.transition2")
_G.ObjectPool     = require("Libs.objectPoolManager")

---Initializes and starts the game
---Bootstrap sequence:
---1. Starts time system
---2. Loads game state from saved data
---3. Initializes sound player with state
---4. Sets default background color
---5. Loads basic object pools
---6. Starts main story or debug scene
---@return void
function Game.start()
  Game.time.start()

  Game.state = State:new(_G.savedData.getValue("state"), Game)

  require("Plugins.soundPlayer").setState(Game.state)

  display.setDefault("background", Config.Display.backgroundColor)

  Game.layers = {}
  ObjectPool.load("basic")
  if Config.Debug.MAIN_SCENE then
    Game.play(Config.Debug.MAIN_SCENE)
  else
    Game.play(Config.Game.defaultStory)
  end
end

---Loads and starts a story chapter
---@param story string Story identifier (e.g., "mainStory")
---@param params? table Optional parameters passed to story constructor
---@return Story story The initialized story object
function Game.play(story, params)
  Game.story = require(stories[story]):new(params)
  return Game.story
end

---Gets a reference to a Composer scene
---@param scene? string Scene name (without "Assets.Scenes." prefix). If nil, uses current scene
---@return table scene The Composer scene object
function Game.getScene(scene)
  return composer.getScene(Config.Game.scenePrefix..(scene or Game._currentScene))
end

---Shows loading screen and executes a loader function
---@param loader function Function to execute during loading (e.g., asset loading)
---@param onComplete? function Callback executed when loading completes
---@return void
function Game.load(loader, onComplete)
  LoadingScreen.show()
  timer.performWithDelay(1, function()
    loader()
    LoadingScreen.hide(1200, onComplete)
  end)
end

---Transitions to a new scene using Composer
---Clears all shortcuts and navigates to the specified scene
---@param scene string Scene name (without "Assets.Scenes." prefix)
---@param params? table Parameters to pass to the scene
---@return table<string, any> shortcuts Reference to the cleared shortcuts table
function Game.goTo(scene, params)
  local shortcuts = Game.shortcuts
  for k, _ in pairs(shortcuts) do
    shortcuts[k] = nil
  end
  Game._currentScene = scene
  composer.gotoScene(Config.Game.scenePrefix..scene, {params = params})
  Game.currentScene = composer.getScene(Config.Game.scenePrefix..scene)

  return shortcuts
end

---Saves the current game state to persistent storage
---Serializes Game.state and writes to savedData.json
---@return void
function Game.save()
  _G.savedData.setValue("state", Game.state:getData())
  _G.savedData.save()
end


-- System events -------------------------------------------------------------------------------------------------------

---Handles system events (suspend, resume, etc.)
---@param e table Event object containing event.type
---@return void
function Game.onSystemEvent(e)
  if e.type == "applicationSuspend" then
    Game.suspend()
  end
end
Runtime:addEventListener( "system", Game.onSystemEvent )

---Suspends game execution when app goes to background
---Optionally pauses time system if pauseOnSuspend flag is set
---@return void
function Game.suspend()
  if Config.Game.pauseOnSuspend then
    Game.time.pause()
  end
end


-- Button back/return --------------------------------------------------------------------------------------------------

---Handles hardware back button (Android)
---Shows exit confirmation dialog when back button is pressed
---@param event table Key event containing keyName
---@return boolean consumed True if event was handled (back button), false otherwise
local function onKeyEvent( event )
  if ( event.keyName == "back" ) then
    native.showAlert(
      "Game",
      "Do you want to exit game?",
      {"yes","no"}, function(promptEvent)
        if promptEvent.action == "clicked" and promptEvent.index == 1 then
          os.exit()
        end
    end )
    return true
  end
  return false
end
Runtime:addEventListener( "key", onKeyEvent )

return Game
