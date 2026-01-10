---@class Button : Entity
local Entity = require("Assets.Entities.entity")
local physics = require("physics")

local Button = Class("Button", Entity)

Button.width = 60
Button.height = 20

function Button:create(parent, params)
  Entity.create(self, parent, params.x, params.y)

  self.isFake = params.isFake or false
  self.color = params.color or {1, 0, 0}

  -- Visuals
  self.base = display.newRect(self.group, 0, 0, self.width, self.height)
  self.base:setFillColor(unpack(self.color))

  -- Interaction: Use a sensor to detect player overlap
  physics.addBody(self.group, "static", {
    isSensor = true,
    box = { halfWidth = self.width/2, halfHeight = self.height/2 }
  })

  self.group.collision = function(self, event)
    if event.phase == "began" then
      if event.other.object and event.other.object:isInstanceOf(require("Assets.Entities.Boxed.player")) then
        self.object:onPress()
      end
    end
  end
  self.group:addEventListener("collision")
end

function Button:onPress()
  if self.isPressed then return end

  local shortcuts = game.shortcuts

  if self.isFake then
    print("[Boxed] Fake button pressed!")
    -- SFX Hook
    game.music.playSFX("button_fail")
    -- Screen shake effect
    if shortcuts.environment then
      shortcuts.environment:shake()
    end
  else
    print("[Boxed] Real button pressed!")
    -- SFX Hook
    game.music.playSFX("button_press")
    self.isPressed = true
    self.base:setFillColor(0.5, 0.5, 0.5) -- Gray out when pressed

    if game.story and game.story.nextRoom then
      -- If true ending room, trigger special reveal
      if Game.state.roomIndex == 8 then
        if shortcuts.environment and shortcuts.environment.unbox then
          shortcuts.environment:unbox()
        end
      else
        game.story:nextRoom()
      end
    end
  end
end

return Button
