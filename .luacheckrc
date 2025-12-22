-- Luacheck configuration for lua-game-pilot
-- See: https://luacheck.readthedocs.io/en/stable/config.html

-- Lua version (Solar2D uses Lua 5.1)
std = "lua51"

-- Treat these as read-only globals
read_globals = {
  -- Solar2D Core APIs
  "display",
  "timer",
  "transition",
  "system",
  "audio",
  "composer",
  "native",
  "physics",
  "network",
  "widget",
  "media",
  "crypto",
  "json",
  "lfs",
  "socket",
  "store",
  "gameNetwork",
  "licensing",

  -- Standard Lua globals (Lua 5.1)
  "io",
  "os",
  "math",
  "string",
  "table",
  "package",
  "require",
  "module",
  "coroutine",
  "debug",

  -- Solar2D Events
  "event",
  "Runtime",
}

-- Treat these as read-write globals (project-specific)
globals = {
  "_G",

  -- Project Core Libraries
  "Class",
  "List",
  "screen",
  "Stateful",
  "device",
  "textFormat",

  -- Project Utilities
  "equals",
  "shuffle",
  "getDepth",

  -- Project Systems
  "game",
  "savedData",
  "DEBUG",
  "transition2",
  "ObjectPool",
}

-- Files and directories to exclude
exclude_files = {
  -- Third-party libraries
  "pl/",
  "pl/**/*.lua",

  -- Vendored libraries
  "Libs/middleclass.lua",
  "Libs/stateful.lua",

  -- Build directories
  "lua_modules/",
  ".luarocks/",
  "build/",
  "Builds/",

  -- Generated files
  "docs/",
  ".git/",
}

-- Warnings to ignore
ignore = {
  "211",  -- Unused local variable (common in callbacks)
  "212",  -- Unused argument (common in event handlers)
  "213",  -- Unused loop variable
  "311",  -- Value assigned to variable is unused (common in Solar2D)
  "312",  -- Value assigned to variable is mutated but never read
  "411",  -- Variable was previously defined as a loop variable
  "412",  -- Variable was previously defined as an argument
  "421",  -- Shadowing definition of variable
  "422",  -- Shadowing definition of argument
  "431",  -- Shadowing upvalue
  "432",  -- Shadowing upvalue argument
}

-- Specific file/directory configurations
files["spec/"] = {
  -- Allow these additional globals in tests
  std = "+busted",
  globals = {
    "describe",
    "it",
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "pending",
    "assert",
    "spy",
    "stub",
    "mock",
  },
}

files["Debug/"] = {
  -- Debug files can be more lenient
  ignore = {
    "111",  -- Setting non-standard global variable
    "112",  -- Mutating non-standard global variable
    "113",  -- Accessing undefined variable
  },
}

files["main.lua"] = {
  -- Main entry point needs to set globals
  ignore = {
    "111",  -- Setting non-standard global variable
    "112",  -- Mutating non-standard global variable
  },
}

files["config.lua"] = {
  -- Config file is just a table return
  ignore = {
    "111",  -- Setting non-standard global variable
  },
}

-- Code style settings
max_line_length = 120
max_code_line_length = 120
max_string_line_length = false
max_comment_line_length = false

-- Allow unused function arguments starting with underscore
unused_args = false
unused = true
unused_secondaries = false

-- Ignore trailing whitespace
whitespace = false

-- Do not check cyclomatic complexity
max_cyclomatic_complexity = false

-- Allow self as first argument (OOP pattern)
self = true

-- Enable additional checks
inline = false

-- Format
codes = true
formatter = "default"
