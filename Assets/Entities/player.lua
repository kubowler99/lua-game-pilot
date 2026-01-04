local Entity = require("Assets.Entities.entity")
local physics = require("physics")
local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")

---@class player : Entity
local Player = Class("player", Entity)

function Player:create(parent, x, y)
  self.width = 40
  self.height = 60

  Entity.create(self, parent, x, y)

  -- Animation Configuration
  -- Note: These are placeholders. Real spritesheets would be loaded here.
  local sequenceData = {
    { name = "run", start = 1, count = 1, time = 400, loopCount = 0 },
    { name = "jump", start = 1, count = 1, time = 400, loopCount = 1 },
    { name = "fall", start = 1, count = 1, time = 400, loopCount = 1 },
    { name = "dead", start = 1, count = 1, time = 400, loopCount = 1 }
  }

  -- If we had a real image sheet, we'd use graphics.newImageSheet
  -- For now, we'll keep the placeholder body but prepare the animation class
  self._body = display.newRect(self.group, 0, 0, self.width, self.height)
  self._body:setFillColor(0, 0, 1) -- Blue player

  -- Initialize Animation
  -- self._animation = SpriteSheetAnimation:new(self.group)
  -- self._animation:playAnimation("run")

  -- Physics Integration
  physics.addBody(self.group, "dynamic", { bounce = 0, friction = 0.5 })
  self.group.isFixedRotation = true
  self.group.type = "player"

  -- Initial State
  _G.game.state:setValue("player.isGrounded", false)
  _G.game.state:setValue("player.jumpCount", 0)
  _G.game.state:setValue("player.isDead", false)

  -- Listen for collisions to handle grounding and death
  self.group.collision = function(s, e) self:onLocalCollision(e) end
  self.group:addEventListener("collision")

  self.__sfx["jump"] = {"jump"}
  self.__sfx["death"] = {"death"}

  -- Subscribe to time for future updates
  _G.game.time.subscribe(self)
end

function Player:enterFrame(dt)
  if not self.group or not self.group.x then return end

  if not _G.game.state:getValue("player.isDead") then
    -- Spawn dust while grounded
    if _G.game.state:getValue("player.isGrounded") then
      self._dustTimer = (self._dustTimer or 0) + dt
      if self._dustTimer > 100 then -- Spawn every 100ms
        self:spawnDust()
        self._dustTimer = 0
      end
    end

    local vx, vy = self.group:getLinearVelocity()
    if not _G.game.state:getValue("player.isGrounded") then
      if vy > 0 then
        -- self._animation:playAnimation("fall")
      end
    end
  end
end

function Player:tap()
  if _G.game.state:getValue("player.isDead") then return end

  local isGrounded = _G.game.state:getValue("player.isGrounded")
  local jumpCount = _G.game.state:getValue("player.jumpCount")

  -- Allow jump if grounded or if it's a double jump (jumpCount < 2)
  if isGrounded or jumpCount < 2 then
    -- Reset velocity before applying jump force for consistent jumps
    local vx, vy = self.group:getLinearVelocity()
    self.group:setLinearVelocity(vx, 0)

    -- Significantly reduced impulse to match very high gravity and keep jump height low.
    self.group:applyLinearImpulse(0, -2.0, self.group.x, self.group.y)

    self:playSound("jump")
    -- self._animation:playAnimation("jump")

    _G.game.state:setValue("player.isGrounded", false)
    _G.game.state:add("player.jumpCount", 1)
  end
end

function Player:spawnDust()
  if _G.game.state:getValue("player.isDead") then return end
  if not _G.game.state:getValue("player.isGrounded") then return end

  local dust = display.newCircle(self.group, -10, self.height * 0.5 - 5, math.random(2, 4))
  dust:setFillColor(0.8, 0.8, 0.8, 0.5)
  dust:toBack()

  transition.to(dust, {
    time = 500,
    x = dust.x - math.random(20, 40),
    y = dust.y - math.random(5, 10),
    alpha = 0,
    xScale = 0.1,
    yScale = 0.1,
    onComplete = function()
      display.remove(dust)
    end
  })
end

function Player:onLocalCollision(event)
  if event.phase == "began" then
    local other = event.other
    if other.type == "obstacle" then
      if not _G.game.state:getValue("player.isDead") then
        _G.game.state:setValue("player.isDead", true)
        print("[DEBUG_LOG] Player hit an obstacle! Game Over.")

        self:playSound("death")
        -- self._animation:playAnimation("dead")

        -- Trigger death sequence: pause physics and time
        _G.game.time.pause()
        -- Change color to indicate death
        self._body:setFillColor(1, 0, 0, 0.5)

        -- Handle High Score
        local currentScore = _G.game.state:getValue("score")
        local highScore = _G.game.state:getValue("highScore")
        if currentScore > highScore then
          _G.game.state:setValue("highScore", currentScore)
          _G.savedData.setValue("highScore", currentScore)
          _G.savedData.save()
          print("[DEBUG_LOG] New High Score: " .. math.floor(currentScore))
        end

        -- Show Game Over UI
        if _G.game.shortcuts.environment then
          if _G.game.shortcuts.environment.spawnerTimer then
            timer.cancel(_G.game.shortcuts.environment.spawnerTimer)
          end
          if _G.game.shortcuts.environment.showGameOver then
            _G.game.shortcuts.environment:showGameOver()
          end
        end
      end
    elseif other.type == "ground" then
      _G.game.state:setValue("player.isGrounded", true)
      _G.game.state:setValue("player.jumpCount", 0)
      -- if not _G.game.state:getValue("player.isDead") then
      --   self._animation:playAnimation("run")
      -- end
    end
  end
end

return Player
