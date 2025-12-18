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

### Configuration
1. Edit `Debug/settings.lua` to configure debug options
2. Modify `build.settings` for platform-specific settings
3. Adjust `config.lua` for screen resolution and scaling

### Adding Game Content
1. Create new entities in `Assets/Entities/`
2. Add scenes in `Assets/Scenes/`
3. Define stories/chapters in `Assets/Story/`
4. Register object pools in `Assets/Story/ObjectPool/`
