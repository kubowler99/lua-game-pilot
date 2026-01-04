local composer = require("composer")

local scene = composer.newScene()

function scene:create( event )
  local sceneGroup = self.view

  local title = display.newText({
    parent = sceneGroup,
    text = "PIXEL RUNNER",
    x = screen.centerX,
    y = screen.centerY - 100,
    fontSize = 60
  })

  local playButton = display.newText({
    parent = sceneGroup,
    text = "PLAY",
    x = screen.centerX,
    y = screen.centerY + 50,
    fontSize = 40
  })
  playButton:setFillColor(0, 1, 0)

  playButton:addEventListener("tap", function()
    _G.game.goTo("mainGame")
    return true
  end)
end

scene:addEventListener("create", scene)

return scene
