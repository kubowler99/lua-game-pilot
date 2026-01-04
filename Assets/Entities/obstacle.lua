local Entity = require("Assets.Entities.entity")
local physics = require("physics")

---@class obstacle : Entity
local Obstacle = Class("obstacle", Entity)

function Obstacle:create(parent, x, y)
  self.width = 40
  self.height = 40

  Entity.create(self, parent, x, y)

  -- Placeholder visual for the obstacle
  self._body = display.newRect(self.group, 0, 0, self.width, self.height)
  self._body:setFillColor(1, 0, 0) -- Red for visibility

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
