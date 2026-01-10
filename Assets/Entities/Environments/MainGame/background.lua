---@class background : Entity
local Entity = require("Assets.Entities.entity")

------------------------------------------------------------------------------------------------------------------------
-- Hangar background
------------------------------------------------------------------------------------------------------------------------

local Background = Class("background", Entity)

function Background:create(parent)
  Entity.create(self, parent)

  -- Check if a custom background image exists
  local bgImage = "Assets/Textures/background.png"
  local path = system.pathForFile(bgImage, system.ResourceDirectory)
  local f = path and io.open(path, "r")

  if f then
    io.close(f)
    -- Use full-screen background image
    self.bg1 = display.newImageRect(self.group, bgImage, screen.width, screen.height)
    self.bg1.x, self.bg1.y = screen.centerX, screen.centerY

    self.bg2 = display.newImageRect(self.group, bgImage, screen.width, screen.height)
    self.bg2.x, self.bg2.y = screen.centerX + screen.width, screen.centerY

    self.isImageBg = true
  else
    -- Fallback to parallax rectangles
    self.layers = {}
    local layerConfigs = {
      { color = {0.05, 0.05, 0.1}, speed = 0.2, height = 0.6, y = screen.centerY - 50 }, -- Far
      { color = {0.1, 0.1, 0.15}, speed = 0.5, height = 0.4, y = screen.centerY + 50 }, -- Mid
      { color = {0.15, 0.15, 0.2}, speed = 0.8, height = 0.2, y = screen.centerY + 150 }, -- Near
    }

    for i, config in ipairs(layerConfigs) do
      local layerGroup = display.newGroup()
      self.group:insert(layerGroup)

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
  end

  _G.game.time.subscribe(self)
end

function Background:enterFrame(dt)
  if not self.group or not self.group.x then return end
  local runSpeed = _G.game.state:getValue("runSpeed") or 300
  local deltaSec = dt / 1000

  if self.isImageBg then
    local moveAmount = runSpeed * 0.5 * deltaSec -- Constant speed for single image
    self.bg1.x = self.bg1.x - moveAmount
    self.bg2.x = self.bg2.x - moveAmount

    if self.bg1.x <= -screen.width * 0.5 then
      self.bg1.x = self.bg2.x + screen.width
    end
    if self.bg2.x <= -screen.width * 0.5 then
      self.bg2.x = self.bg1.x + screen.width
    end
  elseif self.layers then
    for _, layer in ipairs(self.layers) do
      local moveAmount = runSpeed * layer.speed * deltaSec
      layer.group.x = layer.group.x - moveAmount

      if layer.group.x <= -screen.width then
        layer.group.x = layer.group.x + screen.width
      end
    end
  end
end

------------------------------------------------------------------------------------------------------------------------
-- Creation --
------------------------------------------------------------------------------------------------------------------------

return Background
