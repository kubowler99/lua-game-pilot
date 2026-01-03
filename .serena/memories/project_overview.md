# lua-game-pilot Project Information

## Project Purpose
A professional and versatile template for Solar2D games (formerly Corona SDK), designed for landscape-oriented mobile games. It features a robust architecture with clear separation of concerns, entity-component systems, state management, and comprehensive debug tools.

## Tech Stack
- **Game Engine**: Solar2D (Corona SDK)
- **Language**: Lua 5.1
- **Testing**: Busted
- **Code Quality**: Luacheck (Linter), StyLua (Formatter)
- **Documentation**: LDoc
- **Coverage**: LuaCov
- **OOP Library**: MiddleClass
- **Utilities**: Penlight (pl)

## Architecture Overview
- **Entry Point**: `main.lua`
- **Core Libraries (`Libs/`)**: MiddleClass, Stateful, math/string utils, screen/device management, object pooling, task queue, transition extensions.
- **Plugin System (`Plugins/`)**: Save/load system, time controller (time scaling, pause/resume), sound player, loading screen.
- **Game Assets (`Assets/`)**: Entities, scenes, stories, audio.
- **Debug System (`Debug/`)**: Extensive debug settings and runtime features.

## Project Structure
- `Assets/`: Game content (Audio, Entities, Environments, GUI, Scenes, Story).
- `Debug/`: Debug configuration and runtime utilities.
- `Libs/`: Core libraries and utilities.
- `Plugins/`: Functional plugins like save/load and time management.
- `pl/`: Vendored Penlight library.
- `spec/`: Busted unit tests.
- `main.lua`: Application entry point.
- `config.lua` & `build.settings`: Solar2D project configuration.
- `Makefile`: Development command automation.
