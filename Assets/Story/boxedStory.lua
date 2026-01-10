---@class boxedStory : chapterBasics
local ChapterBasics = require('Assets.Story.chapterBasics')

local game        = _G.game
local shortcuts   = _G.game.shortcuts

local Chapter = Class("boxedStory", ChapterBasics)

function Chapter:initialize()
  -- Ensure state exists
  if not Game.state.roomIndex then
    Game.state.roomIndex = 1
  end

  game.load(function()
    -- Load generic box/basic object pools if needed
    ObjectPool.load("basic")

    -- Go to the generic room scene
    self.scene = game.goTo("room")
  end)
end

---Advaces the player to the next room with a smooth transition
function Chapter:nextRoom()
  self:fadeOutIn({
    fadeOut = 250,
    fadeIn  = 500,
    onLoading = function()
      -- Increment progress
      Game.state.roomIndex = Game.state.roomIndex + 1
      Game.save()

      -- Refresh the environment to build the next room
      if shortcuts.environment and shortcuts.environment.refresh then
        shortcuts.environment:refresh()
      else
        -- Fallback: Reload the scene if environment isn't ready
        game.goTo("room")
      end
    end
  })
end

return Chapter
