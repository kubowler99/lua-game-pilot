local composer = require("composer")

local gameShortcuts = _G.game.shortcuts
local Environment = require("Assets.Entities.Environments.mainGame")

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --                - -- --- Main Game --- -- -                   -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

local scene = composer.newScene()

function scene:create( event, params )
  self.environment = Environment:new(self.view)

  gameShortcuts.environment = self.environment

  -- Initialize GUI
  if _G.game.story and _G.game.story.setGUIClass then
    _G.game.story:setGUIClass("MainGame", self.view)
    _G.game.story:showUp({"btnPlayPause", "score"}, "displacement")
  end
end


function scene:show( event, params )
  if event.phase == "will" then

  elseif event.phase == "did" then

  end
end


function scene:hide(e)
  if e.phase == "will" then

  end
end


function scene:destroy()

end

scene:addEventListener( "create",  scene )
scene:addEventListener( "show",    scene )
scene:addEventListener( "hide",    scene )
scene:addEventListener( "destroy", scene )

return scene
