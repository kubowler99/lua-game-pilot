---@class background : Entity
local Entity = require("Assets.Entities.entity")

------------------------------------------------------------------------------------------------------------------------
-- Hangar background
------------------------------------------------------------------------------------------------------------------------

local Background = Class("background", Entity)

function Background:create(parent)
  Entity.create(self, parent)

  self.layers = {}

  -- Layer definition: { color, speedMultiplier, heightMultiplier, yOffset }
  local layerConfigs = {
    { color = {0.05, 0.05, 0.1}, speed = 0.2, height = 0.6, y = screen.centerY - 50 }, -- Far
    { color = {0.1, 0.1, 0.15}, speed = 0.5, height = 0.4, y = screen.centerY + 50 }, -- Mid
    { color = {0.15, 0.15, 0.2}, speed = 0.8, height = 0.2, y = screen.centerY + 150 }, -- Near
  }

  for i, config in ipairs(layerConfigs) do
    local layerGroup = display.newGroup()
    self.group:insert(layerGroup)

    -- Create two rectangles for seamless looping
    local rect1 = display.newRect(layerGroup, screen.centerX, config.y, screen.width + 4, screen.height * config.height)
    rect1:setFillColor(unpack(config.color))
    rect1.anchorX = 0.5

    local rect2 = display.newRect(layerGroup, screen.centerX + screen.width, config.y, screen.width + 4, screen.height * config.height)
    rect2:setFillColor(unpack(config.color))
    rect2.anchorX = 0.5

    self.layers[i] = {
      group = layerGroup,
      speed = config.speed,
      rects = { rect1, rect2 }
    }
  end

  _G.game.time.subscribe(self)
end

function Background:enterFrame(dt)
  if not self.group or not self.group.x then return end
  local runSpeed = _G.game.state:getValue("runSpeed") or 300
  local deltaSec = dt / 1000

  for _, layer in ipairs(self.layers) do
    local moveAmount = runSpeed * layer.speed * deltaSec
    layer.group.x = layer.group.x - moveAmount

    -- Looping logic: if the group has moved by a full screen width, reset its position
    if layer.group.x <= -screen.width then
      layer.group.x = layer.group.x + screen.width
    end
  end
end

------------------------------------------------------------------------------------------------------------------------
-- Creation --
------------------------------------------------------------------------------------------------------------------------

return Background
