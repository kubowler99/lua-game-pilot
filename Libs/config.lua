--- Centralized configuration module for lua-game-pilot
--- Consolidates scattered settings into organized namespaces
--- @module Config

local Config = {}

-- =====================================================================================================================
-- DEBUG CONFIGURATION
-- =====================================================================================================================
--- Debug and development settings
--- @class Config.Debug
Config.Debug = {
  --- Main scene to load (bypasses story system)
  --- @type string?
  MAIN_SCENE = nil,

  --- Game display scale multiplier
  --- @type number
  GAME_SCALE = 1,

  --- Enable Composer debug mode
  --- @type boolean
  COMPOSER = false,

  --- Skip error handling (show continue dialog on errors)
  --- @type boolean
  SKIP_ERRORS = false,

  --- Enable performance profiler
  --- @type boolean|table False or {time = duration_ms, delay = delay_ms}
  PROFILER = false, -- {time = 10000, delay = 20000}

  --- Show performance stats overlay
  --- @type boolean
  SHOW_PERFORMANCE = false,

  --- Display object pool statistics
  --- @type boolean
  OBJECT_POOL_DATA = false,

  --- Enable object pooling system
  --- @type boolean
  OBJECT_POOL = false,

  --- Clear saved data on restart
  --- @type boolean
  NUKE_ON_RESTART = true,

  --- Full wipe of all saved data on restart
  --- @type boolean
  NUKE_FULL_ON_RESTART = false,

  --- Mute all music
  --- @type boolean
  MUTE_MUSIC = false,

  --- Mute all sound effects
  --- @type boolean
  MUTE_SOUND = false,

  --- Enable slow motion mode
  --- @type boolean
  PLAY_IN_SLOWMO = false,

  --- Show entity group boundaries for debugging
  --- @type boolean
  ENTITY_GROUPS = false,
}

-- =====================================================================================================================
-- DISPLAY CONFIGURATION
-- =====================================================================================================================
--- Display and rendering settings
--- @class Config.Display
Config.Display = {
  --- Content width in pixels
  --- @type number
  width = 1920,

  --- Content height in pixels
  --- @type number
  height = 1080,

  --- Scaling mode: "letterbox", "zoomEven", "adaptive", etc.
  --- @type string
  scale = "letterbox",

  --- Target frames per second
  --- @type number
  fps = 60,

  --- Image suffix scaling for high-DPI displays
  --- @type table<string, number>
  imageSuffix = {
    ["@2x"] = 1.5, -- Retina scaling
  },

  --- Default background color (0-1 RGB values)
  --- @type number
  backgroundColor = 0,
}

-- =====================================================================================================================
-- GAME CONFIGURATION
-- =====================================================================================================================
--- Game-specific settings
--- @class Config.Game
Config.Game = {
  --- Pause time system when app suspends
  --- @type boolean
  pauseOnSuspend = false,

  --- Available story modules
  --- @type table<string, string>
  stories = {
    mainStory = "Assets.Story.mainStory",
    boxedStory = "Assets.Story.boxedStory",
  },

  --- Default story to start
  --- @type string
  defaultStory = "boxedStory",

  --- Scene path prefix
  --- @type string
  scenePrefix = "Assets.Scenes.",
}

-- =====================================================================================================================
-- PATHS CONFIGURATION
-- =====================================================================================================================
--- File and module paths
--- @class Config.Paths
Config.Paths = {
  --- Assets directory
  --- @type string
  assets = "Assets",

  --- Scenes directory
  --- @type string
  scenes = "Assets.Scenes.",

  --- Entities directory
  --- @type string
  entities = "Assets.Entities.",

  --- Audio directory
  --- @type string
  audio = "Assets.Audio.",

  --- Story directory
  --- @type string
  story = "Assets.Story.",
}

-- =====================================================================================================================
-- MODULE EXPORTS
-- =====================================================================================================================

-- Set as global for easy access throughout codebase
_G.Config = Config

return Config
