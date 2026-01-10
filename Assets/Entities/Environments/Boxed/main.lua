---@class BoxedEnvironment : Entity
local Entity = require("Assets.Entities.entity")

local Environment = Class("BoxedEnvironment", Entity)

local Player = require("Assets.Entities.Boxed.player")
local Button = require("Assets.Entities.Boxed.button")
local roomDefinitions = require("Assets.Story.roomDefinitions")
local physics = require("physics")

function Environment:create(parent)
  Entity.create(self, parent)

  -- Group to hold all room-specific entities for easy cleanup
  self.roomGroup = display.newGroup()
  self.group:insert(self.roomGroup)

  -- Background and Floor
  self.bg = display.newRect(self.group, screen.centerX, screen.centerY, 1920, 1080)
  self.bg:setFillColor(0.1, 0.1, 0.1)
  self.bg:toBack()

  self.floor = display.newRect(self.group, screen.centerX, 1000, 1920, 160)
  self.floor:setFillColor(0.3, 0.3, 0.3)
  self.floor:toBack() -- Ensure floor is behind room entities
  physics.addBody(self.floor, "static", { friction = 0.5, bounce = 0 })

  self.bg:toBack() -- Background behind floor

  self:build()
end

---Builds the current room based on Game.state.roomIndex
function Environment:build()
  local roomIndex = Game.state.roomIndex or 1
  print("[Boxed] Building room: " .. roomIndex)

  local data = roomDefinitions[roomIndex] or roomDefinitions[1]

  -- Spawn Player
  self.player = Player:new(self.roomGroup, data.player.x, data.player.y)

  -- Spawn Buttons
  for _, bData in ipairs(data.buttons or {}) do
    Button:new(self.roomGroup, bData)
  end

  -- Spawn Obstacles (Bumps)
  for _, oData in ipairs(data.obstacles or {}) do
    local bump = display.newRect(self.roomGroup, oData.x, oData.y, oData.width, oData.height)
    bump:setFillColor(0.4, 0.4, 0.4)
    physics.addBody(bump, "static", { friction = 0.5, bounce = 0 })
  end

  -- Spawn Hazards (Lava)
  for _, hData in ipairs(data.hazards or {}) do
    local lava = display.newRect(self.roomGroup, hData.x, hData.y, hData.width, hData.height)
    lava:setFillColor(1, 0.2, 0)
    physics.addBody(lava, "static", { isSensor = true })

    lava.collision = function(self, event)
      if event.phase == "began" and event.other.object and event.other.object:isInstanceOf(Player) then
        -- SFX Hook
        game.music.playSFX("lava_sizzle")
        -- Non-lethal lava: Respawn player at starting position
        event.other.x, event.other.y = data.player.x, data.player.y
        event.other:setLinearVelocity(0, 0)
      end
    end
    lava:addEventListener("collision")
  end

  -- Update room label
  if self.label then self.label:removeSelf() end
  self.label = display.newText({
    parent   = self.group,
    text     = "Room " .. roomIndex .. ": " .. (data.name or ""),
    x        = screen.centerX,
    y        = 100,
    fontSize = 40
  })

  -- Handle Special Room Logic
  if data.special == "false_ending" then
    self:setupFalseEnding()
  elseif data.special == "true_ending" then
    self:setupTrueEnding()
  end
end

function Environment:setupFalseEnding()
  local winText = display.newText({
    parent   = self.roomGroup,
    text     = "YOU WIN",
    x        = screen.centerX,
    y        = screen.centerY,
    fontSize = 100
  })
  winText:setFillColor(1, 1, 0)

  -- False wall blocking the path to the real button
  local falseWall = display.newRect(self.roomGroup, 1600, 800, 100, 300)
  falseWall:setFillColor(0.35, 0.35, 0.35) -- Slightly different color than floor
  -- No physics body = player can walk through
end

function Environment:setupTrueEnding()
  -- Placeholder for unbox sequence
end

function Environment:unbox()
  print("[Boxed] UNBOXED!")
  -- SFX Hook
  game.music.playSFX("win_fanfare")

  -- 1. Remove walls/floor
  transition.to(self.floor, { time = 2000, y = 1500, transition = transition.inBack })

  -- 2. Reveal desert background
  self.bg:setFillColor(0.8, 0.6, 0.4) -- Sand color

  -- 3. Show final text
  local winText = display.newText({
    parent   = self.group,
    text     = "YOU BECAME UNBOXED",
    x        = screen.centerX,
    y        = screen.centerY - 100,
    fontSize = 80
  })

  -- 4. Show credits after a delay
  timer.performWithDelay(3000, function()
    local credits = display.newText({
      parent   = self.group,
      text     = "Created by EndarianDev\nEngine: Solar2D",
      x        = screen.centerX,
      y        = screen.centerY + 100,
      fontSize = 40
    })
  end)
end

function Environment:shake()
  local shakeCount = 0
  local function doShake()
    if shakeCount >= 6 then return end
    local intensity = 10
    local dx = math.random(-intensity, intensity)
    local dy = math.random(-intensity, intensity)
    self.group.x, self.group.y = dx, dy
    shakeCount = shakeCount + 1
    timer.performWithDelay(50, function()
      self.group.x, self.group.y = 0, 0
      timer.performWithDelay(50, doShake)
    end)
  end
  doShake()
end

---Clears the current room and rebuilds it
function Environment:refresh()
  -- Remove all children from roomGroup
  for i = self.roomGroup.numChildren, 1, -1 do
    local child = self.roomGroup[i]
    if child.object and child.object.remove then
      child.object:remove()
    else
      child:removeSelf()
    end
  end

  -- Rebuild the room
  self:build()
end

return Environment
