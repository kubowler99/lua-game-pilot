------------------------------------------------------------------------------------------------------------------------
-- LIBRARIES --
------------------------------------------------------------------------------------------------------------------------

require("Libs.utils") -- Load utils
require("Debug.main")

local serviceLocator = require("Services.serviceLocator")

timer.performWithDelay(50, function()
  ------------------------------------------------------------------------------------------------------------------------
  -- SERVICES --
  ------------------------------------------------------------------------------------------------------------------------

  -- Register core services
  local SaveService = require("Services.save")
  serviceLocator.register("Save", SaveService)

  local TimeService = require("Services.time")
  serviceLocator.register("Time", TimeService)

  -- Load save data
  local savedData = SaveService.load()

  -- Handle debug nukes
  if _G.DEBUG.NUKE_ON_RESTART then
    SaveService.save({})
  elseif _G.DEBUG.NUKE_FULL_ON_RESTART then
    if SaveService.nukeFull then SaveService.nukeFull() end
  end

  ------------------------------------------------------------------------------------------------------------------------
  -- SYSTEM EVENTS --
  ------------------------------------------------------------------------------------------------------------------------


  ------------------------------------------------------------------------------------------------------------------------
  -- RUN GAME --
  ------------------------------------------------------------------------------------------------------------------------

  local gameModule = require("Assets.game")
  serviceLocator.register("Game", gameModule)

  -- Install compatibility shim if needed
  local debugSettings = nil
  pcall(function() debugSettings = require("Debug.settings") end)
  if debugSettings and debugSettings.USE_COMPAT_SHIM then
    local shim = require("compat._G_shim")
    shim.install()
  end

  -- Start game
  gameModule.start()
end)