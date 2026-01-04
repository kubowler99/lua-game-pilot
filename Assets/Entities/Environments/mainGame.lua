---@class mainGame-environment : Entity
local Entity = require("Assets.Entities.entity")

local Background = require("Assets.Entities.Environments.MainGame.background")

------------------------------------------------------------------------------------------------------------------------
-- Scene loader --
------------------------------------------------------------------------------------------------------------------------

local physics = require("physics")
local Player = require("Assets.Entities.player")

local Environment = Class("mainGame-environment", Entity)

function Environment:create(parent)
  Entity.create(self, parent)

  self.background = Background:new(self.group)

  -- Add ground
  self.ground = display.newRect(self.group, screen.centerX, screen.edgeY - 20, screen.width, 40)
  self.ground:setFillColor(0.3, 0.3, 0.3)
  physics.addBody(self.ground, "static", { bounce = 0, friction = 0.5 })
  self.ground.type = "ground"

  -- Add player
  self.player = Player:new(self.group, screen.originX + 100, screen.edgeY - 150)
  _G.game.shortcuts.player = self.player

  -- Tap to jump
  self.group:addEventListener("tap", function()
    self.player:tap()
    return true
  end)

  self.spawnInterval = 2000
  self:startSpawner()
  self.lastDifficultyUpdate = 0

  -- Load patterns
  local json = require("json")
  local path = system.pathForFile("data/patterns.json", system.ResourceDirectory)
  local file = io.open(path, "r")
  if file then
    local contents = file:read("*a")
    io.close(file)
    self.patterns = json.decode(contents).patterns
  end

  _G.game.time.subscribe(self)
end

function Environment:enterFrame(dt)
  if not self.group or not self.group.x then return end
  if _G.game.state:getValue("player.isDead") then return end

  -- Update Score
  local runSpeed = _G.game.state:getValue("runSpeed")
  local scoreIncrement = (runSpeed * (dt / 1000)) * 0.1 -- 10% of distance as score
  _G.game.state:add("score", scoreIncrement)

  -- Difficulty Progression
  self.lastDifficultyUpdate = self.lastDifficultyUpdate + dt
  if self.lastDifficultyUpdate > 5000 then -- Every 5 seconds
    self.lastDifficultyUpdate = 0

    -- Increase Speed
    local newSpeed = runSpeed + 20
    _G.game.state:setValue("runSpeed", newSpeed)

    -- Decrease Spawn Interval
    self.spawnInterval = math.max(600, self.spawnInterval - 100)
    timer.cancel(self.spawnerTimer)
    self:startSpawner()
  end
end

function Environment:startSpawner()
  self.spawnerTimer = timer.performWithDelay(self.spawnInterval, function()
    self:spawnObstacle()
  end, 0)
end


function Environment:spawnObstacle()
  if not self.patterns then
    local obs = _G.ObjectPool.get("obstacle")
    self.group:insert(obs.group)
    obs.group.x = screen.edgeX + 50
    obs.group.y = screen.edgeY - 60
    return
  end

  -- Pick a random pattern based on current difficulty
  local currentDifficulty = 1
  local runSpeed = _G.game.state:getValue("runSpeed") or 300
  if runSpeed > 350 then currentDifficulty = 2 end
  if runSpeed > 400 then currentDifficulty = 3 end
  if runSpeed > 450 then currentDifficulty = 4 end

  local eligiblePatterns = {}
  for _, p in ipairs(self.patterns) do
    if p.difficulty <= currentDifficulty then
      table.insert(eligiblePatterns, p)
    end
  end

  local pattern = eligiblePatterns[math.random(#eligiblePatterns)]
  for _, item in ipairs(pattern.sequence) do
    local obs = _G.ObjectPool.get("obstacle")
    self.group:insert(obs.group)
    obs.group.x = screen.edgeX + 50 + (item.offset or 0)

    if item.type == "high" then
      obs.group.y = screen.edgeY - 150 -- Floating obstacle
    else
      obs.group.y = screen.edgeY - 60 -- Ground obstacle
    end
  end
end

function Environment:showGameOver()
  -- Screen Shake Effect
  if self.group then
    transition.to(self.group, {
      time = 50,
      x = 10,
      y = 10,
      onComplete = function()
        transition.to(self.group, {
          time = 50,
          x = -10,
          y = -10,
          onComplete = function()
            transition.to(self.group, {
              time = 50,
              x = 0,
              y = 0
            })
          end
        })
      end
    })
  end

  local gameOverGroup = display.newGroup()
  self.group:insert(gameOverGroup)

  local bg = display.newRect(gameOverGroup, screen.centerX, screen.centerY, screen.width * 0.8, 300)
  bg:setFillColor(0, 0, 0, 0.8)

  local title = display.newText(gameOverGroup, "GAME OVER", screen.centerX, screen.centerY - 80, native.systemFontBold, 40)
  title:setFillColor(1, 0, 0)

  local score = math.floor(_G.game.state:getValue("score"))
  local highScore = math.floor(_G.game.state:getValue("highScore"))

  local scoreText = display.newText(gameOverGroup, "Score: " .. score, screen.centerX, screen.centerY - 20, native.systemFont, 24)
  local highScoreText = display.newText(gameOverGroup, "High Score: " .. highScore, screen.centerX, screen.centerY + 20, native.systemFont, 24)

  local retryBtn = display.newRect(gameOverGroup, screen.centerX, screen.centerY + 80, 200, 50)
  retryBtn:setFillColor(0.2, 0.6, 0.2)
  local retryText = display.newText(gameOverGroup, "RETRY", screen.centerX, screen.centerY + 80, native.systemFontBold, 24)

  retryBtn:addEventListener("tap", function()
    -- Reset state before retry
    _G.game.state:setValue("score", 0)
    _G.game.state:setValue("runSpeed", 300)
    _G.game.state:setValue("player.isDead", false)
    _G.game.state:setValue("player.jumpCount", 0)
    _G.game.state:setValue("player.isGrounded", false)

    -- Remove Game Over UI
    if gameOverGroup and gameOverGroup.removeSelf then
      gameOverGroup:removeSelf()
    end

    _G.game.time.resume()
    -- Go to mainMenu first then back to mainGame to ensure full scene reset
    -- OR better: use composer.removeScene then goTo
    local composer = require("composer")
    composer.removeScene("Assets.Scenes.mainGame")
    _G.game.goTo("mainGame")
    return true
  end)
end




return Environment
