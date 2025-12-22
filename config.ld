-- LDoc configuration file for lua-game-pilot
-- See: https://github.com/lunarmodules/LDoc

project = 'lua-game-pilot'
title = 'Solar2D Game Template'
description = 'A professional Solar2D game template with entity systems, state management, and performance optimization'

-- Output directory for generated documentation
dir = 'docs'

-- Files and directories to process
file = {
  'Libs',
  'Plugins',
  'Assets',
  'main.lua',
  'config.lua'
}

-- Exclude certain files/patterns
exclude = {
  'pl',  -- External Penlight library (already documented)
  'spec',  -- Test files
  'Debug/debugInfo.lua'
}

-- Format options
format = 'markdown'  -- Can be 'discount', 'markdown', or 'plain'
backtick_references = true
merge = false
wrap = true
style = true
template = false

-- Sort modules alphabetically
sort = true
sort_modules = true

-- Documentation style
readme = 'README.md'
topics = {
  'README.md'
}

-- Show private/internal functions (prefix with _)
all = false

-- Custom tags for Solar2D-specific documentation
custom_tags = {
  { 'solar2d', title='Solar2D API', format=nil },
  { 'entity', title='Entity Type', format=nil },
  { 'plugin', title='Plugin', format=nil },
  { 'global', title='Global Variable', format=nil },
  { 'scene', title='Scene', format=nil }
}

-- Ignore certain warnings
no_return_or_parms = true
no_summary = true

-- Module/file alias mappings
alias = {
  ['Libs.utils'] = 'utils',
  ['Libs.screen'] = 'screen',
  ['Libs.device'] = 'device',
  ['Libs.middleclass'] = 'middleclass',
  ['Libs.stateful'] = 'stateful',
  ['Libs.objectPoolManager'] = 'objectPoolManager',
  ['Libs.taskQueue'] = 'taskQueue',
  ['Libs.transition2'] = 'transition2',
  ['Libs.State.state'] = 'state',
  ['Libs.State.subject'] = 'subject',
  ['Plugins.loadSave'] = 'loadSave',
  ['Plugins.time'] = 'time',
  ['Plugins.soundPlayer'] = 'soundPlayer',
  ['Plugins.loadingScreen'] = 'loadingScreen',
  ['Plugins.objectPool'] = 'objectPool',
  ['Assets.game'] = 'game',
  ['Assets.Entities.entity'] = 'entity'
}

-- Pretty print for better formatting
pretty = 'lua'

-- Use markdown for all descriptions
plain = false

-- Show function bodies (set to false for cleaner docs)
body = false
