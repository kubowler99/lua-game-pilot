# Makefile for lua-game-pilot
# Solar2D Game Template Development Commands

.PHONY: help install install-hooks uninstall-hooks test test-verbose test-coverage test-watch docs docs-open lint format clean clean-all

# Default target - show help
help:
	@echo "lua-game-pilot Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Setup:"
	@echo "  make install          Install all dependencies via LuaRocks"
	@echo "  make install-dev      Install development dependencies only"
	@echo "  make install-hooks    Install pre-commit hooks"
	@echo "  make uninstall-hooks  Remove pre-commit hooks"
	@echo ""
	@echo "Testing:"
	@echo "  make test             Run all tests"
	@echo "  make test-verbose     Run tests with verbose output"
	@echo "  make test-coverage    Run tests with coverage report"
	@echo "  make test-file FILE=path/to/spec.lua  Run specific test file"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs             Generate API documentation"
	@echo "  make docs-open        Generate and open documentation in browser"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint             Run Lua linter (luacheck) if installed"
	@echo "  make format           Format Lua code (stylua) if installed"
	@echo "  make validate         Validate rockspec file"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci               Run all CI checks (validate, lint, test)"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            Remove generated files (coverage, docs)"
	@echo "  make clean-all        Remove all generated files including dependencies"
	@echo ""

# ============================================================================
# Setup Commands
# ============================================================================

install:
	@echo "Installing all dependencies..."
	luarocks install --only-deps lua-game-pilot-dev-1.rockspec
	@echo "✓ Dependencies installed successfully"

install-dev:
	@echo "Installing development dependencies..."
	luarocks install busted
	luarocks install luacov
	luarocks install ldoc
	luarocks install luacheck
	@echo "✓ Development dependencies installed"

install-hooks:
	@echo "Installing git hooks..."
	@if [ -d .git ]; then \
		cp hooks/pre-commit .git/hooks/pre-commit; \
		chmod +x .git/hooks/pre-commit; \
		echo "✓ Pre-commit hook installed"; \
		echo ""; \
		echo "To skip hooks temporarily:"; \
		echo "  SKIP_HOOK=1 git commit"; \
		echo "  SKIP_LINT=1 git commit  # Skip only linting"; \
		echo "  SKIP_TESTS=1 git commit # Skip only tests"; \
	else \
		echo "Error: Not a git repository"; \
		exit 1; \
	fi

uninstall-hooks:
	@echo "Removing git hooks..."
	@rm -f .git/hooks/pre-commit
	@echo "✓ Pre-commit hook removed"

# ============================================================================
# Testing Commands
# ============================================================================

test:
	@echo "Running tests..."
	busted

test-verbose:
	@echo "Running tests with verbose output..."
	busted --verbose

test-coverage:
	@echo "Running tests with coverage..."
	busted --coverage
	@echo ""
	@echo "Coverage report generated: luacov.report.out"
	@echo "To view: cat luacov.report.out"
	@echo ""
	@if [ -f luacov.report.out ]; then \
		echo "=== Coverage Summary ==="; \
		tail -20 luacov.report.out; \
	fi

test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: Please specify FILE=path/to/spec.lua"; \
		exit 1; \
	fi
	@echo "Running test file: $(FILE)"
	busted $(FILE)

test-watch:
	@echo "Watching for changes and running tests..."
	@echo "Note: Requires 'entr' to be installed (brew install entr)"
	@if command -v entr > /dev/null; then \
		find spec Libs Plugins Assets -name '*.lua' | entr -c make test; \
	else \
		echo "Error: 'entr' not found. Install with: brew install entr"; \
		exit 1; \
	fi

# ============================================================================
# Documentation Commands
# ============================================================================

docs:
	@echo "Generating documentation..."
	ldoc .
	@echo "✓ Documentation generated in docs/"

docs-open: docs
	@echo "Opening documentation..."
	@if [ -f docs/index.html ]; then \
		open docs/index.html || xdg-open docs/index.html || echo "Please open docs/index.html manually"; \
	else \
		echo "Error: docs/index.html not found"; \
		exit 1; \
	fi

# ============================================================================
# Code Quality Commands
# ============================================================================

lint:
	@echo "Running Lua linter..."
	@if command -v luacheck > /dev/null; then \
		luacheck Libs Plugins Assets main.lua config.lua; \
	else \
		echo "Warning: luacheck not installed. Install with: luarocks install luacheck"; \
		echo "Skipping lint..."; \
	fi

format:
	@echo "Formatting Lua code..."
	@if command -v stylua > /dev/null; then \
		stylua Libs Plugins Assets main.lua config.lua; \
		echo "✓ Code formatted successfully"; \
	else \
		echo "Warning: stylua not installed. Install from: https://github.com/JohnnyMorganz/StyLua"; \
		echo "Skipping format..."; \
	fi

# ============================================================================
# Validation Commands
# ============================================================================

validate:
	@echo "Validating rockspec..."
	luarocks lint lua-game-pilot-dev-1.rockspec
	@echo "✓ Rockspec is valid"

check: lint test
	@echo "✓ All checks passed"

# ============================================================================
# Cleanup Commands
# ============================================================================

clean:
	@echo "Cleaning generated files..."
	rm -rf docs/
	rm -f luacov.*.out
	rm -rf coverage/
	rm -f *.html
	@echo "✓ Cleaned generated files"

clean-all: clean
	@echo "Cleaning all generated files including dependencies..."
	rm -rf lua_modules/
	rm -rf .luarocks/
	rm -f luarocks.lock
	@echo "✓ Cleaned all generated files"

# ============================================================================
# Development Workflow Commands
# ============================================================================

dev-setup: install-dev install-hooks
	@echo "Development environment setup complete!"
	@echo ""
	@echo "Quick start:"
	@echo "  make test          - Run tests"
	@echo "  make docs          - Generate documentation"
	@echo "  make help          - Show all available commands"

dev-check: lint test-coverage
	@echo "✓ Development checks complete"

# ============================================================================
# CI/CD Commands
# ============================================================================

ci: validate lint test-coverage
	@echo "✓ CI checks passed"
	@echo ""
	@echo "This command runs:"
	@echo "  1. validate - Check rockspec"
	@echo "  2. lint     - Run luacheck"
	@echo "  3. test     - Run tests with coverage"
	@echo ""
	@echo "Use this before pushing or in CI/CD pipelines"

# Show dependency tree
deps:
	@echo "Project Dependencies:"
	@echo "===================="
	@luarocks show --deps lua-game-pilot 2>/dev/null || echo "Run 'make install' first"

# ============================================================================
# Status and Info
# ============================================================================

status:
	@echo "Project Status"
	@echo "=============="
	@echo ""
	@echo "Lua Version:"
	@lua -v
	@echo ""
	@echo "LuaRocks:"
	@luarocks --version | head -1
	@echo ""
	@echo "Busted:"
	@busted --version 2>/dev/null || echo "  Not installed (run: make install-dev)"
	@echo ""
	@echo "LDoc:"
	@ldoc --version 2>/dev/null || echo "  Not installed (run: make install-dev)"
	@echo ""
	@echo "LuaCov:"
	@luacov --version 2>/dev/null || echo "  Not installed (run: make install-dev)"
	@echo ""
	@echo "Test Files:"
	@find spec -name '*_spec.lua' | wc -l | xargs echo "  "
	@echo ""
	@echo "Source Files:"
	@find Libs Plugins Assets -name '*.lua' | wc -l | xargs echo "  "
