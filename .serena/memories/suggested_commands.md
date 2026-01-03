# Suggested Commands for lua-game-pilot

The project uses a `Makefile` to automate development tasks. Note: Some tools (like `busted`, `luacheck`) might need to be installed via `luarocks` or available in the path.

## Setup
- `make install`: Install all dependencies via LuaRocks.
- `make install-dev`: Install only development dependencies (busted, luacov, ldoc, luacheck).
- `make install-hooks`: Install pre-commit hooks.
- `make dev-setup`: Complete development environment setup (install-dev + install-hooks).

## Testing
- `make test`: Run all tests using Busted.
- `make test-verbose`: Run tests with verbose output.
- `make test-coverage`: Run tests with coverage report (LuaCov).
- `make test-file FILE=<path>`: Run a specific test file.

## Code Quality
- `make lint`: Run Luacheck on project files.
- `make format`: Format code using StyLua.
- `make check`: Run linting and tests.
- `make dev-check`: Run linting and coverage tests.

## Documentation
- `make docs`: Generate API documentation using LDoc.
- `make docs-open`: Generate and open documentation in browser.

## Cleanup
- `make clean`: Remove generated files (coverage, docs).
- `make clean-all`: Remove all generated files including dependencies (`lua_modules`, `.luarocks`).

## Utility Commands (Windows PowerShell)
- `ls` or `dir`: List directory contents.
- `cat`: Display file content (or use `Get-Content`).
- `rm -rf`: In PowerShell, use `Remove-Item -Recurse -Force`.
- `grep`: Use `Select-String`.
