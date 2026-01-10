local Entity = require("Assets.Entities.entity")
local physics = require("physics")
local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")

---@class player : Entity
local Player = Class("player", Entity)

function Player:create(parent, x, y)
  self.width = 160  -- Quadrupled from original 40
  self.height = 240 -- Quadrupled from original 60

  Entity.create(self, parent, x, y)

  -- Animation Configuration
  local sequenceData = {
    { name = "death", start = 1, count = 8, time = 600, loopCount = 1 },
    { name = "jump", start = 9, count = 8, time = 400, loopCount = 1 },
    { name = "run", start = 17, count = 6, time = 400, loopCount = 0 },
    { name = "fall", start = 12, count = 1, time = 400, loopCount = 1 }, -- Using frame 12 from jump as fall
    { name = "dead", start = 8, count = 1, time = 400, loopCount = 1 }   -- Final frame of death
  }

  -- Visual Representation
  local sheetPath = "Assets/Textures/player.lua"
  local imagePath = "Assets/Textures/player.png"

  local sheetDataPath = system.pathForFile(sheetPath, system.ResourceDirectory)
  local imageFilePath = system.pathForFile(imagePath, system.ResourceDirectory)

  if sheetDataPath and imageFilePath then
    -- Load Sprite Sheet
    local sheetInfo = require("Assets.Textures.player")
    local imageSheet = graphics.newImageSheet(imagePath, sheetInfo:getSheet())

    self._animation = SpriteSheetAnimation:new(self.group, imageSheet, sequenceData)
    self._animation.group.xScale, self._animation.group.yScale = 4, 4 -- Quadruple animation size
    -- Shifting the sprite down to align feet with the bottom of the physics box
    self._animation.group.y = 56
    self._animation:playAnimation("run")
    self._body = self._animation.group
  elseif imageFilePath then
    -- Single Image
    self._body = display.newImageRect(self.group, imagePath, self.width, self.height)
  else
    -- Fallback to placeholder rectangle
    self._body = display.newRect(self.group, 0, 0, self.width, self.height)
    self._body:setFillColor(0, 0, 1) -- Blue player
  end


  -- Physics Integration
  -- Check for PhysicsEditor data
  local physicsDataPath = "Assets/Textures/dudeMonsterRun.lua"
  local physicsFile = system.pathForFile(physicsDataPath, system.ResourceDirectory)

  if physicsFile then
    local physicsData = require("Assets.Textures.dudeMonsterRun")
    -- Handle different PhysicsEditor export formats
    local fixtureData
    if type(physicsData) == "table" then
      if physicsData.get then
        fixtureData = physicsData:get("Dude_Monster_Run_6-0")
      else
        fixtureData = physicsData["Dude_Monster_Run_6-0"]
      end
    end

    if fixtureData then
      physics.addBody(self.group, "dynamic", fixtureData)
    else
      print("[DEBUG_LOG] Warning: Could not find fixture 'Dude_Monster_Run_6-0' in dudeMonsterRun.lua")
      physics.addBody(self.group, "dynamic", { bounce = 0, friction = 0.5, box = { halfWidth = 80, halfHeight = 120 } })
    end
  else
    -- Fallback to explicit box to match visual size (160x240)
    physics.addBody(self.group, "dynamic", { bounce = 0, friction = 0.5, box = { halfWidth = 80, halfHeight = 120 } })
  end

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
        if self._animation then
          self._animation:playAnimation("fall")
        end
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

    -- Increased impulse to -25.0 to help clear obstacles after size adjustments
    self.group:applyLinearImpulse(0, -25.0, self.group.x, self.group.y)

    self:playSound("jump")
    if self._animation then
      self._animation:playAnimation("jump")
    end

    _G.game.state:setValue("player.isGrounded", false)
    _G.game.state:add("player.jumpCount", 1)
  end
end

function Player:spawnDust()
  if _G.game.state:getValue("player.isDead") then return end
  if not _G.game.state:getValue("player.isGrounded") then return end

  local dust = display.newCircle(self.group, -40, self.height * 0.5 - 20, math.random(8, 16))
  dust:setFillColor(0.8, 0.8, 0.8, 0.5)
  dust:toBack()

  transition.to(dust, {
    time = 500,
    x = dust.x - math.random(80, 160),
    y = dust.y - math.random(20, 40),
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
        -- Handle High Score
        local currentScore = _G.game.state:getValue("score")
        local highScore = _G.game.state:getValue("highScore")
        if currentScore > highScore then
          _G.game.state:setValue("highScore", currentScore)
          _G.savedData.setValue("highScore", currentScore)
          _G.savedData.save()
          print("[DEBUG_LOG] New High Score: " .. math.floor(currentScore))
        end

        if _G.game.shortcuts.environment and _G.game.shortcuts.environment.spawnerTimer then
          timer.cancel(_G.game.shortcuts.environment.spawnerTimer)
        end

        -- Trigger death sequence: pause physics but keep time running briefly for animation
        require("physics").pause()

        if self._animation then
          self._animation:playAnimation("death", {
            onComplete = function()
              _G.game.time.pause()
              if _G.game.shortcuts.environment.showGameOver then
                _G.game.shortcuts.environment:showGameOver()
              end
            end
          })
        else
          _G.game.time.pause()
          if _G.game.shortcuts.environment.showGameOver then
            _G.game.shortcuts.environment:showGameOver()
          end
        end
      end
    elseif other.type == "ground" then
      _G.game.state:setValue("player.isGrounded", true)
      _G.game.state:setValue("player.jumpCount", 0)
      print("[DEBUG_LOG] Player landed on the ground.")
      if not _G.game.state:getValue("player.isDead") then
        if self._animation then
          self._animation:playAnimation("run")
        end
      end
    end
  end
end

return Player
