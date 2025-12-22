# Solar2D-template

This is a very useful and versatile template for Solar2D games

## Project Overview

This is a well-structured **Solar2D (formerly Corona SDK)** game template with professional game development patterns, designed for landscape-oriented mobile games. The architecture demonstrates mature engineering practices with clear separation of concerns.

---

## Core Architecture

### Application Configuration
- **config.lua** - Resolution: 640×960 (portrait base, letterboxed), 60 FPS, Retina support (@2x)
- **build.settings** - Landscape-only orientation, custom splash screen, cross-platform support (iOS/Android)

### Entry Point Flow
**main.lua** - Bootstrap sequence:
1. Load utilities and debug configuration
2. 50ms initialization delay
3. Initialize save/load system
4. Optional data wiping (debug modes)
5. Start game via `_G.game.start()`

---

## System Architecture Layers

### 1. Core Libraries (`Libs/`)
- **middleclass.lua** - OOP class system (MiddleClass library)
- **stateful.lua** - State machine implementation
- **utils.lua** - Extended math utilities, text formatting, table operations
  - Custom math: `decimalRandom`, `bidirRandom`, `hypotenuse`, `getAngle`
  - String extensions: `capitalize()`, `split()`
  - Table operations: binary insertion, shuffling
- **screen.lua** - Screen dimension management
- **device.lua** - Device detection
- **objectPoolManager.lua** - Object pooling for performance optimization
- **taskQueue.lua** - Async task management
- **transition2.lua** - Enhanced transition system
- **State/** - Observer pattern implementation (subject.lua, state.lua)

### 2. Third-Party Library
- **pl/** (Penlight) - Comprehensive Lua utilities library
  - Data structures: List, Map, Set, OrderedMap, MultiMap
  - File operations, path handling, XML/URL parsing
  - Date handling, comprehensions, templates

### 3. Plugin System (`Plugins/`)

**loadSave.lua** - Persistent data management:
- JSON-based save system (`savedData.json`)
- Dot-notation path access (`getValue("state.player.score")`)
- Sandbox mode for testing without affecting real saves
- Session tracking (first/previous/current)
- Full/partial data reset (`nuke`/`nukeFull`)

**time.lua** - Custom time controller:
- Time scaling/slow-motion effects
- Pause/resume functionality
- Frame-independent timing (`enterFrame` loop)
- Task queue integration
- "Hit lag" effect for game feel
- Subscriber system for time-aware objects

**soundPlayer.lua** - Audio management

**loadingScreen.lua** - Loading screen transitions

**objectPool.lua** - Base object pool implementation

### 4. Debug System (`Debug/`)

**settings.lua** - Debug configuration:
- Scene override (`MAIN_SCENE`)
- Game scaling for testing
- Error handling (`SKIP_ERRORS`)
- Performance profiling
- Data wiping options
- Audio muting

**main.lua** - Debug runtime features:
- Composer debug mode
- Game view scaling
- Slow-motion mode (0.1x speed after 17s)
- Performance monitor
- Profiler integration
- Global error handler with UI alerts

---

## Game Systems

### Game Manager (`Assets/game.lua`)
Central game controller with:

**Lifecycle Management:**
- `start()` - Initialize time system, state, audio, display
- `play(story)` - Load story chapters
- `goTo(scene)` - Scene transitions via Composer
- `save()` - Persist game state
- `suspend()` - Handle application suspension

**System Events:**
- Application suspend/resume handling
- Android back button with exit confirmation

**Features:**
- Shortcuts system for scene object references
- Loading screen integration
- State persistence via save system
- Story-based progression system

### Entity System (`Assets/Entities/entity.lua`)
Base class for all game objects with:

**Positioning & Transforms:**
- World/local/content coordinate conversion
- Anchor point management with directional flipping
- Scale/rotation with parent hierarchy support
- Distance calculations

**Visual Management:**
- Visibility controls (alpha/isVisible)
- Direction facing (left/right)
- Z-ordering (toFront/toBack)
- Group-based composition

**Animation & Effects:**
- Transition support (normal + time-scaled)
- Sound playback with variants
- Vanish effects

**Lifecycle:**
- `initialize()` → `create()` → `hardReset()`
- `pause()`/`resume()` - Suspends transitions/timers
- `interrupt()` - Cancels all activities
- `stop()` - Complete shutdown
- `reset()`/`hardReset()` - State restoration
- `clear()`/`remove()` - Cleanup

**Event System:**
- Event dispatch/listener management
- Focus handling for touch input

**Timer Management:**
- Separate game-time and real-time timers
- Automatic cleanup on removal

### Scene System

**Composer Integration:**
- **mainGame.lua** - Main game scene
  - Creates environment from `Environments/mainGame`
  - Standard Composer lifecycle (create/show/hide/destroy)
  - Shortcuts integration

**Story System:**
- **mainStory.lua** - Story progression controller
  - Extends `ChapterBasics`
  - Loads object pools
  - Transitions to main game scene
- Chapter-based game flow

---

## Key Design Patterns

1. **Global Registry** - Extensive use of `_G` for cross-module access (`_G.game`, `_G.DEBUG`, `_G.savedData`)
2. **Object Pooling** - Pre-instantiated objects for performance
3. **Observer Pattern** - State management and time subscribers
4. **Entity-Component** - Base Entity class with composition via groups
5. **Scene Graph** - Solar2D's display groups for hierarchical rendering
6. **Singleton Services** - Time, SaveData, Game as global singletons
7. **Factory Pattern** - ObjectPoolManager with lazy factory loading

---

## Project Statistics
- **Total Lua Files:** 73+ files
- **Custom Code:** ~40 files
- **Third-party (Penlight):** ~33 files
- **Architecture Layers:** 5 (Config, Core, Libs, Plugins, Assets)

---

## Development Features

**Debug Capabilities:**
- Live game scaling
- Scene overrides
- Error recovery system
- Performance monitoring
- Profiling tools
- Data reset commands

**Performance Optimizations:**
- Object pooling system
- Frame-independent timing
- Efficient coordinate transformations
- Binary insertion for sorted tables

**Code Quality:**
- Clear separation of concerns
- Extensive utility library
- Lifecycle management patterns
- Resource cleanup systems

---

## Target Platforms
- iOS (landscape, status bar hidden)
- Android (landscape, back button handling)
- Configurable Google Play Games integration

---

## Strengths
✅ Professional architecture with clear layers
✅ Comprehensive debug/development tools
✅ Performance-conscious (object pooling, time scaling)
✅ Extensible plugin system
✅ Robust entity lifecycle management
✅ Save/load with sandboxing for testing

## Considerations
⚠️ Heavy reliance on global namespace (`_G.*`)
⚠️ Limited documentation in code
⚠️ Some incomplete implementations (entity.lua hardReset commented out)
⚠️ Template nature means game-specific logic needs to be added

---

## Getting Started

This is a production-ready template suitable for 2D games requiring state management, entity systems, and cross-platform mobile deployment.

### Prerequisites
- [Solar2D](https://solar2d.com/) - Game engine
- [Lua](https://www.lua.org/) 5.1 or higher
- [LuaRocks](https://luarocks.org/) - Lua package manager (optional but recommended)
- [Busted](https://olivinelabs.com/busted/) - Testing framework (for development)

### Installation

#### Quick Start with Make (Recommended)

The project includes a Makefile for convenient development:

```bash
# Install all dependencies
make install

# Or install only development tools
make install-dev

# Check installation status
make status

# Show all available commands
make help
```

#### Using LuaRocks Directly

Install project dependencies using LuaRocks:

```bash
# Install all dependencies
luarocks install --only-deps lua-game-pilot-dev-1.rockspec

# Or install individually
luarocks install penlight
luarocks install busted
luarocks install middleclass
luarocks install ldoc
luarocks install luacov
```

#### Manual Installation

If not using LuaRocks, the project includes vendored dependencies:
- **Penlight** - Already included in `pl/` directory
- **MiddleClass** - Already included in `Libs/middleclass.lua`

For testing, you'll need to install Busted manually:
```bash
luarocks install busted
```

### Configuration
1. Edit `Debug/settings.lua` to configure debug options
2. Modify `build.settings` for platform-specific settings
3. Adjust `config.lua` for screen resolution and scaling

### Adding Game Content
1. Create new entities in `Assets/Entities/`
2. Add scenes in `Assets/Scenes/`
3. Define stories/chapters in `Assets/Story/`
4. Register object pools in `Assets/Story/ObjectPool/`

---

## Development Workflow

This project includes a **Makefile** with convenient commands for common development tasks.

### Available Commands

#### Setup Commands
```bash
make install        # Install all dependencies via LuaRocks
make install-dev    # Install only development dependencies
make status         # Show project and dependencies status
```

#### Testing Commands
```bash
make test                    # Run all tests
make test-verbose            # Run tests with verbose output
make test-coverage           # Run tests with coverage report
make test-file FILE=<path>   # Run specific test file
make test-watch              # Watch files and auto-run tests (requires entr)
```

#### Documentation Commands
```bash
make docs          # Generate API documentation
make docs-open     # Generate and open documentation in browser
```

#### Code Quality Commands
```bash
make lint          # Run Lua linter (luacheck)
make format        # Format code (stylua)
make validate      # Validate rockspec file
make check         # Run lint + tests
```

#### Cleanup Commands
```bash
make clean         # Remove generated files (coverage, docs)
make clean-all     # Remove all generated files including dependencies
```

#### Development Workflow
```bash
make dev-setup     # Complete development environment setup
make dev-check     # Run lint + coverage tests
make ci            # Run all CI checks (install, test, lint, validate)
```

### Quick Development Workflow

```bash
# Initial setup
make install

# During development
make test-watch    # Auto-run tests on file changes

# Before committing
make dev-check     # Ensure code quality and tests pass

# Generate documentation
make docs-open     # View API docs in browser
```

### Example Usage

```bash
# Run tests for a specific module
make test-file FILE=spec/libs/utils_spec.lua

# Check coverage and generate report
make test-coverage
cat luacov.report.out

# Clean up before switching branches
make clean
```

---

## Code Quality

### Linting

This project uses **[Luacheck](https://github.com/lunarmodules/luacheck)** for static code analysis.

#### Running the Linter

Using Make (recommended):
```bash
# Run linter on all project files
make lint

# Run linter as part of quality checks
make check  # Runs lint + tests
```

Or using Luacheck directly:
```bash
# Install luacheck if not already installed
luarocks install luacheck

# Run linter
luacheck Libs Plugins Assets main.lua config.lua

# Check specific file
luacheck Libs/utils.lua

# Show only errors (no warnings)
luacheck --no-warnings Libs/
```

#### Linter Configuration

Linting is configured in `.luacheckrc`:
- **Lua Version**: 5.1 (Solar2D compatibility)
- **Solar2D Globals**: All Solar2D APIs recognized (`display`, `timer`, `transition`, etc.)
- **Project Globals**: Custom globals defined (`_G.game`, `_G.savedData`, `Class`, etc.)
- **Excludes**: Third-party libraries (`pl/`, `middleclass`, `stateful`)
- **Max Line Length**: 120 characters
- **Test Files**: Busted globals automatically recognized

#### Common Linter Warnings

Luacheck is configured to ignore common Solar2D patterns:
- Unused callback parameters (211/212)
- Unused loop variables (213)
- Variable shadowing in nested scopes (421/422)
- Values assigned but unused (311/312)

#### Fixing Linter Issues

```bash
# Run linter to see issues
make lint

# Common fixes:
# - Remove unused variables
# - Add underscore prefix for intentionally unused: `local _unused = value`
# - Use variables or remove assignments
# - Fix line length by breaking long lines
```

#### IDE Integration

Most IDEs support luacheck integration:
- **VS Code**: Install [vscode-lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) extension
- **IntelliJ**: Built-in Lua plugin supports luacheck
- **Neovim**: Use [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) or [nvim-lint](https://github.com/mfussenegger/nvim-lint)

The `.luacheckrc` file will be automatically detected by these tools.

---

## Documentation

This project uses **[LDoc](https://github.com/lunarmodules/LDoc)** for generating API documentation and **Lua Language Server** for IDE support.

### Generating Documentation

Using Make (recommended):
```bash
# Generate documentation
make docs

# Generate and open in browser
make docs-open
```

Or using LDoc directly:
```bash
# Install LDoc if not already installed
luarocks install ldoc

# Generate documentation
ldoc .

# Documentation will be created in docs/ directory
# Open docs/index.html in your browser
```

### IDE Support (Lua Language Server)

The project includes `.luarc.json` configuration for Lua Language Server, providing:
- **Autocomplete** - Intelligent code completion for all modules
- **Hover Documentation** - View function signatures and documentation on hover
- **Diagnostics** - Real-time error detection and warnings
- **Go to Definition** - Jump to function/variable definitions
- **Type Checking** - Basic type inference and validation

#### Setup for VS Code

1. Install the [Lua Language Server extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
2. The `.luarc.json` file will be automatically detected
3. Enjoy enhanced Lua development experience!

#### Setup for Other IDEs

Most modern editors support Lua Language Server:
- **IntelliJ/IDEA**: Install [EmmyLua plugin](https://plugins.jetbrains.com/plugin/9768-emmylua)
- **Neovim**: Use [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- **Sublime Text**: Install [LSP package](https://packagecontrol.io/packages/LSP)

### Documentation Style

The project uses LuaDoc-style annotations for all public APIs:

```lua
---Calculates the distance between two points
---@param x1 number First point X coordinate
---@param y1 number First point Y coordinate
---@param x2 number Second point X coordinate
---@param y2 number Second point Y coordinate
---@return number distance The calculated distance
function calculateDistance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx*dx + dy*dy)
end
```

### Custom Documentation Tags

The project supports Solar2D-specific tags in `config.ld`:
- `@solar2d` - Marks Solar2D API usage
- `@entity` - Identifies entity types
- `@plugin` - Marks plugin modules
- `@global` - Documents global variables
- `@scene` - Identifies scene modules

### Current Documentation Coverage

- ✅ `Libs/utils.lua` - Fully documented with type annotations
- ✅ `Plugins/loadSave.lua` - Complete API documentation
- ✅ `Assets/Entities/entity.lua` - Entity class with all methods documented
- ⚠️ Additional documentation needed for GUI entities and game systems

---

## Testing

This project uses **[Busted](https://olivinelabs.com/busted/)** for unit testing.

### Running Tests

Using Make (recommended):
```bash
# Run all tests
make test

# Run with verbose output
make test-verbose

# Run with coverage report
make test-coverage

# Run specific test file
make test-file FILE=spec/libs/utils_spec.lua

# Watch files and auto-run tests (requires entr)
make test-watch
```

Or using Busted directly:
```bash
# Run all tests
busted

# Run specific test file
busted spec/libs/utils_spec.lua

# Run with verbose output
busted --verbose

# Run tests with coverage
busted --coverage
```

### Test Coverage

This project uses **[LuaCov](https://keplerproject.github.io/luacov/)** for code coverage analysis.

#### Generating Coverage Reports

```bash
# Install luacov if not already installed
luarocks install luacov

# Run tests with coverage
busted --coverage

# View coverage report
cat luacov.report.out

# Or generate detailed coverage stats
luacov

# Clean up coverage files
rm luacov.*.out
```

#### Coverage Configuration

Coverage is configured in `.luacov`:
- **Includes**: `Libs/`, `Plugins/`, `Assets/`, `main.lua`, `config.lua`
- **Excludes**: Third-party libraries (`pl/`, `middleclass`), test files, debug files
- **Threshold**: 80% coverage target
- **Reports**: Generates `luacov.report.out` and `luacov.stats.out`

#### Coverage Targets

| Module Type | Current | Target |
|-------------|---------|--------|
| Core Libs   | ~60%    | 85%    |
| Plugins     | ~70%    | 90%    |
| Entities    | ~20%    | 75%    |
| Game Systems| ~10%    | 70%    |

### Test Configuration

Test configuration is defined in `.busted`:
- **Lua Paths**: Automatically includes `Libs/`, `Plugins/`, `Assets/`, and `pl/` directories
- **Helper File**: `spec/spec_helper.lua` loads common test utilities
- **Pattern**: Test files must end with `_spec.lua`
- **Output**: UTF-8 terminal output for readable test results
- **Coverage**: Enabled by default for all test runs
- **Seed**: Fixed at 12345 for reproducible test ordering

### Writing Tests

Tests are located in the `spec/` directory, mirroring the project structure:

```
spec/
├── libs/          # Tests for core libraries
│   └── utils_spec.lua
├── plugins/       # Tests for plugins
│   └── loadSave_spec.lua
├── entities/      # Tests for entity classes
├── assets/        # Tests for game assets and systems
└── spec_helper.lua
```

Example test structure:

```lua
describe("MyModule", function()
  local MyModule

  before_each(function()
    MyModule = require("Libs.myModule")
  end)

  describe("myFunction", function()
    it("should return expected value", function()
      assert.equals(42, MyModule.myFunction())
    end)
  end)
end)
```

### Current Test Coverage

- ✅ `Libs/utils.lua` - Math extensions, string utilities, table operations
- ✅ `Plugins/loadSave.lua` - Save/load system functionality
- ⚠️ Additional test coverage needed for entities and game systems

### Adding New Tests

1. Create a new test file in `spec/` matching the module path:
   ```bash
   # For Libs/myModule.lua, create:
   spec/libs/myModule_spec.lua
   ```

2. Follow the naming convention: `<module_name>_spec.lua`

3. Use Busted's BDD-style syntax (`describe`, `it`, `before_each`, etc.)

4. Run tests to verify:
   ```bash
   busted spec/libs/myModule_spec.lua
   ```

---
