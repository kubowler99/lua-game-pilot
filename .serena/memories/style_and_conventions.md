# Style and Conventions for lua-game-pilot

## General Principles
- **Separation of Concerns**: Use the established directory structure (`Libs`, `Plugins`, `Assets`, `Debug`).
- **Global Registry**: The project uses `_G` for global singletons (e.g., `_G.game`, `_G.savedData`, `_G.device`).
- **Object Oriented Programming**: Use `middleclass` for classes (available as `Class` globally).
- **State Machines**: Use `stateful` for state-dependent behavior.

## Naming Conventions
- **Files**: Lowercase or camelCase (e.g., `main.lua`, `loadSave.lua`).
- **Variables/Functions**: camelCase is common (e.g., `remainingTime`, `calculateDistance`).
- **Classes**: PascalCase (e.g., `Entity`, `GUIEntity`).
- **Globals**: Prefix with `_G.` and usually descriptive (e.g., `_G.game`).

## Formatting
- **Indentation**: 2 spaces.
- **Line Endings**: LF (Unix-style).
- **Max Line Length**: 120 characters.
- **Trailing Whitespace**: None.
- **Final Newline**: Required.
- Follow `.editorconfig` settings.

## Documentation
- Use LuaDoc-style annotations for public APIs (parameters, return types, descriptions).
- Supported tags: `@param`, `@return`, `@type`, and custom ones like `@solar2d`, `@entity`, `@plugin`.

## Linting
- Follow `.luacheckrc` rules.
- Avoid unused variables (or prefix with `_`).
- Recognize Solar2D and project-specific globals.
