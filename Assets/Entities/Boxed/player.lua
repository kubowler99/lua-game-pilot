---@class Player : Entity
local Entity = require("Assets.Entities.entity")
local physics = require("physics")

local Player = Class("Player", Entity)

Player.width = 40
Player.height = 60
Player.moveSpeed = 300
Player.jumpForce = -500

function Player:create(parent, x, y)
  Entity.create(self, parent, x, y)

  -- Visuals: Simple blue box for the prototype
  self.rect = display.newRect(self.group, 0, 0, self.width, self.height)
  self.rect:setFillColor(0, 0.5, 1)

  -- Physics body
  physics.addBody(self.group, "dynamic", {
    friction = 0.3,
    bounce = 0,
    density = 1.0
  })
  self.group.isFixedRotation = true -- Prevent player from tumbling

  self._keys = {}
  self:addListeners()

  -- Subscribe to enterFrame via game.time
  game.time.subscribe(self)
end

function Player:enterFrame(dt)
  self:update(dt)
end

function Player:addListeners()
  self._onKey = function(event)
    local keyName = event.keyName
    if event.phase == "down" then
      self._keys[keyName] = true
      if keyName == "space" or keyName == "w" or keyName == "up" then
        self:jump()
      end
    elseif event.phase == "up" then
      self._keys[keyName] = false
    end
  end
  Runtime:addEventListener("key", self._onKey)
end

function Player:jump()
  if not self.group or not self.group.getLinearVelocity then return end

  -- Check if velocity is near zero to prevent infinite jumping (simple check for prototype)
  local vx, vy = self.group:getLinearVelocity()
  if math.abs(vy) < 5 then
    self.group:setLinearVelocity(vx, self.jumpForce)
    -- SFX Hook
    game.music.playSFX("jump")
  end
end

function Player:update()
  if not self.group or not self.group.getLinearVelocity then return end

  local vx, vy = self.group:getLinearVelocity()
  local targetVx = 0

  if self._keys["left"] or self._keys["a"] then
    targetVx = -self.moveSpeed
  elseif self._keys["right"] or self._keys["d"] then
    targetVx = self.moveSpeed
  end

  self.group:setLinearVelocity(targetVx, vy)
end

function Player:remove()
  game.time.unsubscribe(self)
  Runtime:removeEventListener("key", self._onKey)
  Entity.remove(self)
end

return Player
