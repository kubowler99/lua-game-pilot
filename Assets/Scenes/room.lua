local composer = require("composer")

local shortcuts = _G.game.shortcuts
local Environment = require("Assets.Entities.Environments.Boxed.main")
local physics = require("physics")

local scene = composer.newScene()

function scene:create( event )
  physics.start()
  physics.setGravity(0, 30) -- Adjusted gravity for platformer feel

  -- Initialize the Boxed environment
  self.environment = Environment:new(self.view)
  shortcuts.environment = self.environment
end

function scene:show( event )
  if event.phase == "did" then
    -- Any logic after room is shown
  end
end

function scene:hide( event )
  if event.phase == "will" then
    -- Cleanup if needed
  end
end

function scene:destroy()
  if self.environment then
    self.environment:remove()
  end
  if shortcuts.environment == self.environment then
    shortcuts.environment = nil
  end
  self.environment = nil
end

scene:addEventListener( "create",  scene )
scene:addEventListener( "show",    scene )
scene:addEventListener( "hide",    scene )
scene:addEventListener( "destroy", scene )

return scene
