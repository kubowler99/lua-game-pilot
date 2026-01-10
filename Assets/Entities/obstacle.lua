local Entity = require("Assets.Entities.entity")
local physics = require("physics")

---@class obstacle : Entity
local Obstacle = Class("obstacle", Entity)

function Obstacle:create(parent, x, y)
  self.width = 80 -- Doubled from 40
  self.height = 80 -- Doubled from 40

  Entity.create(self, parent, x, y)

  -- Visual Representation
  local sheetPath = "Assets/Textures/obstacle.lua"
  local imagePath = "Assets/Textures/obstacle.png"

  local sheetDataPath = system.pathForFile(sheetPath, system.ResourceDirectory)
  local imageFilePath = system.pathForFile(imagePath, system.ResourceDirectory)

  if sheetDataPath and imageFilePath then
    -- Load Sprite Sheet
    local sheetInfo = require("Assets.Textures.obstacle")
    local imageSheet = graphics.newImageSheet(imagePath, sheetInfo:getSheet())

    local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")
    local obstacleSequences = {
      { name = "idle", start = 1, count = 1, time = 1000, loopCount = 0 }
    }
    self._animation = SpriteSheetAnimation:new(self.group, imageSheet, obstacleSequences)
    self._animation.group.xScale, self._animation.group.yScale = 2, 2 -- Double animation size
    self._animation:playAnimation("idle")
    self._body = self._animation.group
  elseif imageFilePath then
    -- Single Image
    self._body = display.newImageRect(self.group, imagePath, self.width, self.height)
  else
    -- Fallback to placeholder rectangle
    self._body = display.newRect(self.group, 0, 0, self.width, self.height)
    self._body:setFillColor(1, 0, 0) -- Red for visibility
  end

  -- Physics body as kinematic and sensor
  -- Sensor is used so the player isn't physically pushed by the obstacle
  -- but we can still detect the overlap/collision.
  physics.addBody(self.group, "kinematic", { isSensor = true })
  self.group.type = "obstacle"

  -- Add to time subscribers for movement
  _G.game.time.subscribe(self)
end

function Obstacle:enterFrame(dt)
  -- Move left based on the game's runSpeed
  if not self.group or not self.group.x then return end
  local runSpeed = _G.game.state:getValue("runSpeed") or 300
  self.group.x = self.group.x - runSpeed * (dt / 1000)

  -- Recycling: Implement off-screen detection
  if self.group.x < screen.originX - 100 then
    self:recycle()
  end
end

function Obstacle:recycle()
  -- Return to pool
  _G.ObjectPool.recycle(self)
end

-- Map recycle to dispose if needed by the pool system
function Obstacle:dispose()
  _G.game.time.unsubscribe(self)
  -- The pool system handles the group visibility/positioning
end

return Obstacle
