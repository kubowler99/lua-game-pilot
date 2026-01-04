---@class GUI : Entity
local Entity = require("Assets.Entities.entity")

local ButtonPlayPause = require("Assets.Entities.GUI.Buttons.buttonPlayPause")

-- ---------------------------------------------------------------------------------------------------------------------
-- Game User Interface --
-- ---------------------------------------------------------------------------------------------------------------------

local GUI = Class("GUI", Entity)

function GUI:create(parent, environment)
  Entity.create(self, parent)

  self._lastActivePanels = List.new()

  self._panels = {}
  self._panels["btnPlayPause"]  = ButtonPlayPause:new(self.group, environment)

  -- Score Text Group
  self.scoreGroup = display.newGroup()
  self.group:insert(self.scoreGroup)
  self.scoreGroup.alpha = 0
  self.scoreText = display.newText(self.scoreGroup, "Score: 0", screen.originX + 20, screen.originY + 40, native.systemFontBold, 24)
  self.scoreText.anchorX = 0
  self.scoreText:setFillColor(1, 1, 1)

  -- Add score as a panel so it can be managed
  self._panels["score"] = {
    showUp = function(_, effect)
      if not effect then
        self.scoreGroup.alpha = 1
      else
        transition.to(self.scoreGroup, { alpha = 1, time = 300 })
      end
    end,
    hide = function(_, effect)
      if not effect then
        self.scoreGroup.alpha = 0
      else
        transition.to(self.scoreGroup, { alpha = 0, time = 300 })
      end
    end
  }

  -- Bind to score state
  _G.game.state:observe("score", self, function(_, event)
    self.scoreText.text = string.format("Score: %d", math.floor(event.value))
  end, true)
end


function GUI:get(panel)
  return self._panels[panel]
end


function GUI:showUp(panels, effect)
  if panels == true then
    panels = nil
    effect = true
  end

  local list = panels or self._lastActivePanels

  if panels then
    for i=1, #panels do
      local panel = panels[i]
      if not self._lastActivePanels:contains(panel) then
        self._lastActivePanels:append(panel)
      end
    end
  end

  for i=1, #list do
    local panel = list[i]
    if self._panels[panel] then
      self._panels[panel]:showUp(effect)
    end
  end
end


function GUI:hide(panels, effect)
  if panels == true then
    panels = nil
    effect = true
  end

  if panels then
    for i=1, #panels do
      local panel = panels[i]
      self._lastActivePanels:remove_value(panel)
    end
  end

  local list = panels or self._lastActivePanels
  for i=1, #list do
    local panel = list[i]
    if self._panels[panel] then
      self._panels[panel]:hide(effect)
    end
  end
end


function GUI:organize(params)
  self._lastActivePanels = List.new(params.show)
  for key,panel in pairs(self._panels) do
    if self._lastActivePanels:contains(key) then
      panel:showUp(params.showEffect)
    else
      panel:hide(params.hideEffect)
    end
  end
end


return GUI
