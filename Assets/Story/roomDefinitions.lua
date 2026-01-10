--- Room Definitions for Boxed
-- Defines the layout, entities, and logic for each of the 8 rooms.

local roomDefinitions = {
  -- ACT 1: INTRODUCTION
  [1] = {
    name = "The Beginning",
    player = { x = 100, y = 800 },
    buttons = {
      { x = 960, y = 910, isFake = false, color = {0, 0.8, 0} }
    }
  },
  [2] = {
    name = "The Choice",
    player = { x = 100, y = 800 },
    buttons = {
      { x = 800, y = 910, isFake = true,  color = {0.8, 0, 0} },
      { x = 1120, y = 910, isFake = false, color = {0, 0.8, 0} }
    }
  },
  [3] = {
    name = "The Color",
    player = { x = 100, y = 800 },
    buttons = {
      { x = 800, y = 910, isFake = false, color = {0, 0, 0.8} }, -- Blue is correct here
      { x = 1120, y = 910, isFake = true,  color = {0.8, 0, 0} }
    }
  },

  -- ACT 2: TRICKERY
  [4] = {
    name = "Perspective",
    player = { x = 960, y = 800 },
    buttons = {
      { x = 1800, y = 910, isFake = true,  color = {0.8, 0, 0} },
      { x = 100, y = 910, isFake = false, color = {0, 0.8, 0} } -- Button is behind where player starts
    }
  },
  [5] = {
    name = "The Leap",
    player = { x = 100, y = 800 },
    obstacles = {
      { type = "bump", x = 960, y = 850, width = 100, height = 200 }
    },
    buttons = {
      { x = 1800, y = 910, isFake = true,  color = {0.8, 0, 0} },
      { x = 500, y = 910, isFake = false, color = {0, 0.8, 0} }
    }
  },
  [6] = {
    name = "The Heat",
    player = { x = 100, y = 800 },
    hazards = {
      { type = "lava", x = 960, y = 950, width = 1000, height = 50 }
    },
    buttons = {
      { x = 1800, y = 910, isFake = false, color = {1, 0.5, 0} }
    }
  },

  -- ACT 3: THE END
  [7] = {
    name = "Success?",
    player = { x = 100, y = 800 },
    special = "false_ending",
    buttons = {
      { x = 1800, y = 910, isFake = false, color = {1, 1, 1} } -- Leads to room 8
    }
  },
  [8] = {
    name = "Unboxed",
    player = { x = 100, y = 800 },
    special = "true_ending",
    buttons = {
      { x = 960, y = 910, isFake = false, color = {1, 1, 0} } -- Triggers win sequence
    }
  }
}

return roomDefinitions
