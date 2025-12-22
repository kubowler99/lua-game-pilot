package = "lua-game-pilot"
version = "dev-1"

source = {
   url = "git+https://github.com/kubowler99/lua-game-pilot.git",
   branch = "develop"
}

description = {
   summary = "A well-structured Solar2D game template with professional patterns",
   detailed = [[
      This is a versatile Solar2D (Corona SDK) game template featuring:
      - Professional game development architecture
      - Entity system with lifecycle management
      - State management and observer patterns
      - Object pooling for performance
      - Save/load system with sandboxing
      - Time scaling and custom time control
      - Debug tools and performance monitoring
   ]],
   homepage = "https://github.com/kubowler99/lua-game-pilot",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1",
   "penlight >= 1.13.0",  -- Comprehensive Lua utilities (pl/ directory)
   "busted >= 2.0.0",     -- Testing framework
   "middleclass >= 4.1.0", -- OOP class system
   "ldoc >= 1.4.6"        -- Documentation generator
}

build = {
   type = "builtin",
   modules = {
      -- Core Libraries
      ["Libs.utils"] = "Libs/utils.lua",
      ["Libs.screen"] = "Libs/screen.lua",
      ["Libs.device"] = "Libs/device.lua",
      ["Libs.middleclass"] = "Libs/middleclass.lua",
      ["Libs.stateful"] = "Libs/stateful.lua",
      ["Libs.objectPoolManager"] = "Libs/objectPoolManager.lua",
      ["Libs.taskQueue"] = "Libs/taskQueue.lua",
      ["Libs.transition2"] = "Libs/transition2.lua",
      ["Libs.State.state"] = "Libs/State/state.lua",
      ["Libs.State.subject"] = "Libs/State/subject.lua",

      -- Plugins
      ["Plugins.loadSave"] = "Plugins/loadSave.lua",
      ["Plugins.time"] = "Plugins/time.lua",
      ["Plugins.soundPlayer"] = "Plugins/soundPlayer.lua",
      ["Plugins.loadingScreen"] = "Plugins/loadingScreen.lua",
      ["Plugins.objectPool"] = "Plugins/objectPool.lua",

      -- Assets
      ["Assets.game"] = "Assets/game.lua",
      ["Assets.Entities.entity"] = "Assets/Entities/entity.lua",
      ["Assets.Entities.GUI.GUIEntity"] = "Assets/Entities/GUI/GUIEntity.lua",
      ["Assets.Entities.GUI.MainGame"] = "Assets/Entities/GUI/MainGame.lua",
      ["Assets.Entities.GUI.Buttons.buttonPlayPause"] = "Assets/Entities/GUI/Buttons/buttonPlayPause.lua",
      ["Assets.Entities.Animated.animated"] = "Assets/Entities/Animated/animated.lua",
      ["Assets.Entities.Animated.spriteSheetAnimation"] = "Assets/Entities/Animated/spriteSheetAnimation.lua",
      ["Assets.Entities.Environments.mainGame"] = "Assets/Entities/Environments/mainGame.lua",
      ["Assets.Entities.Environments.MainGame.background"] = "Assets/Entities/Environments/MainGame/background.lua",
      ["Assets.Scenes.mainGame"] = "Assets/Scenes/mainGame.lua",
      ["Assets.Story.chapterBasics"] = "Assets/Story/chapterBasics.lua",
      ["Assets.Story.mainStory"] = "Assets/Story/mainStory.lua",
      ["Assets.Story.ObjectPool.basic"] = "Assets/Story/ObjectPool/basic.lua",
      ["Assets.Audio.music"] = "Assets/Audio/music.lua",
      ["Assets.Audio.loader"] = "Assets/Audio/loader.lua",

      -- Debug
      ["Debug.main"] = "Debug/main.lua",
      ["Debug.settings"] = "Debug/settings.lua"
   },
   copy_directories = {
      "spec"  -- Include test specs
   }
}
