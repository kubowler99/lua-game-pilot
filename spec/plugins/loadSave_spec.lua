-- Use lunajson for JSON encoding/decoding in tests
local json = require("lunajson")

-- Save original io before mocking
local originalIo = io

-- Mock system module for file paths
_G.system = _G.system or {}
_G.system.pathForFile = function(filename, directory)
  return "/mock/path/" .. filename
end
_G.system.DocumentsDirectory = "DocumentsDirectory"
_G.system.ResourceDirectory = "ResourceDirectory"

-- Mock io operations
local mockFileSystem = {}
local mockIo = {}

function mockIo.open(path, mode)
  if mockFileSystem[path] then
    return {
      read = function(self, format)
        return mockFileSystem[path]
      end,
      write = function(self, content)
        mockFileSystem[path] = content
      end,
      close = function(self)
        -- No-op
      end,
    }
  end
  return nil
end

function mockIo.close(file)
  -- No-op
end

describe("LoadSave", function()
  local LoadSave
  local originalPrint

  before_each(function()
    -- Reset mock filesystem
    mockFileSystem = {}

    -- Suppress print output during tests
    originalPrint = print
    _G.print = function() end

    -- Apply io mock BEFORE loading the module
    _G.io = mockIo

    -- Reset the module by removing it from package.loaded
    package.loaded["Plugins.loadSave"] = nil

    -- Set up test data file
    mockFileSystem["/mock/path/savedData.json"] = json.encode({
      state = {
        player = {
          name = "TestPlayer",
          score = 100,
          inventory = {
            coins = 50,
            gems = 10
          }
        },
        level = 5
      },
      settings = {
        sound = true,
        music = false
      },
      currentSession = 1000000,
      firstSession = 900000
    })
  end)

  after_each(function()
    -- Restore print and io
    _G.print = originalPrint
    _G.io = originalIo
  end)

  describe("getValue", function()
    before_each(function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()
    end)

    it("should get top-level values", function()
      local state = LoadSave.getValue("state")
      assert.is_not_nil(state)
      assert.equals("table", type(state))
    end)

    it("should get nested values using dot notation", function()
      local playerName = LoadSave.getValue("state.player.name")
      assert.equals("TestPlayer", playerName)

      local score = LoadSave.getValue("state.player.score")
      assert.equals(100, score)
    end)

    it("should get deeply nested values", function()
      local coins = LoadSave.getValue("state.player.inventory.coins")
      assert.equals(50, coins)

      local gems = LoadSave.getValue("state.player.inventory.gems")
      assert.equals(10, gems)
    end)

    it("should get boolean values", function()
      local sound = LoadSave.getValue("settings.sound")
      assert.is_true(sound)

      local music = LoadSave.getValue("settings.music")
      assert.is_false(music)
    end)

    it("should get number values", function()
      local level = LoadSave.getValue("state.level")
      assert.equals(5, level)
    end)
  end)

  describe("setValue", function()
    before_each(function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()
    end)

    it("should set top-level values", function()
      LoadSave.setValue("newKey", "newValue")
      local value = LoadSave.getValue("newKey")
      assert.equals("newValue", value)
    end)

    it("should set nested values using dot notation", function()
      LoadSave.setValue("state.player.name", "NewName")
      local name = LoadSave.getValue("state.player.name")
      assert.equals("NewName", name)

      LoadSave.setValue("state.player.score", 200)
      local score = LoadSave.getValue("state.player.score")
      assert.equals(200, score)
    end)

    it("should set deeply nested values", function()
      LoadSave.setValue("state.player.inventory.coins", 100)
      local coins = LoadSave.getValue("state.player.inventory.coins")
      assert.equals(100, coins)
    end)

    it("should set boolean values", function()
      LoadSave.setValue("settings.sound", false)
      local sound = LoadSave.getValue("settings.sound")
      assert.is_false(sound)
    end)

    it("should overwrite existing values", function()
      local originalScore = LoadSave.getValue("state.player.score")
      assert.equals(100, originalScore)

      LoadSave.setValue("state.player.score", 999)
      local newScore = LoadSave.getValue("state.player.score")
      assert.equals(999, newScore)
    end)

    it("should handle table values", function()
      LoadSave.setValue("state.player.newData", {a = 1, b = 2})
      local newData = LoadSave.getValue("state.player.newData")
      assert.equals(1, newData.a)
      assert.equals(2, newData.b)
    end)
  end)

  describe("save", function()
    before_each(function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()
    end)

    it("should persist changes to file system", function()
      LoadSave.setValue("state.player.score", 500)
      LoadSave.save()

      -- Verify the file was written
      local savedContent = mockFileSystem["/mock/path/savedData.json"]
      assert.is_not_nil(savedContent)

      local decoded = json.decode(savedContent)
      assert.equals(500, decoded.state.player.score)
    end)

    it("should save all current data", function()
      LoadSave.setValue("state.level", 10)
      LoadSave.setValue("settings.sound", false)
      LoadSave.save()

      local savedContent = mockFileSystem["/mock/path/savedData.json"]
      local decoded = json.decode(savedContent)

      assert.equals(10, decoded.state.level)
      assert.is_false(decoded.settings.sound)
    end)
  end)

  describe("load", function()
    it("should load data from file system", function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()

      local playerName = LoadSave.getValue("state.player.name")
      assert.equals("TestPlayer", playerName)
    end)

    it("should update session timestamps", function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()

      local currentSession = LoadSave.getValue("currentSession")
      local prevSession = LoadSave.getValue("prevSession")

      -- prevSession should be set to the old currentSession value
      assert.equals(1000000, prevSession)
      -- currentSession should be updated to current time
      assert.is_not_nil(currentSession)
    end)
  end)

  describe("sandbox mode", function()
    before_each(function()
      -- Set up sandbox test file
      mockFileSystem["/mock/path/savedData-test.json"] = json.encode({
        state = {
          test = true,
          value = 42
        }
      })

      LoadSave = require("Plugins.loadSave")
      LoadSave.load()
    end)

    it("should switch to sandbox data", function()
      local originalName = LoadSave.getValue("state.player.name")
      assert.equals("TestPlayer", originalName)

      LoadSave.startSandboxMode("test")

      local testValue = LoadSave.getValue("state.value")
      assert.equals(42, testValue)
    end)

    it("should prevent saves in sandbox mode", function()
      LoadSave.startSandboxMode("test")
      LoadSave.setValue("state.value", 100)

      local originalFileContent = mockFileSystem["/mock/path/savedData.json"]
      LoadSave.save()
      local afterSaveContent = mockFileSystem["/mock/path/savedData.json"]

      -- File should not be modified
      assert.equals(originalFileContent, afterSaveContent)
    end)

    it("should restore original data after stopping sandbox", function()
      local originalName = LoadSave.getValue("state.player.name")

      LoadSave.startSandboxMode("test")
      LoadSave.setValue("state.value", 999)

      LoadSave.stopSandboxMode()

      local restoredName = LoadSave.getValue("state.player.name")
      assert.equals(originalName, restoredName)
    end)

    it("should discard sandbox changes", function()
      LoadSave.startSandboxMode("test")
      LoadSave.setValue("state.value", 999)

      local sandboxValue = LoadSave.getValue("state.value")
      assert.equals(999, sandboxValue)

      LoadSave.stopSandboxMode()

      -- Original data should not have the sandbox changes
      local originalScore = LoadSave.getValue("state.player.score")
      assert.equals(100, originalScore)
    end)
  end)

  describe("edge cases", function()
    before_each(function()
      LoadSave = require("Plugins.loadSave")
      LoadSave.load()
    end)

    it("should handle single-level paths", function()
      LoadSave.setValue("topLevel", "value")
      local value = LoadSave.getValue("topLevel")
      assert.equals("value", value)
    end)

    it("should handle numeric values", function()
      LoadSave.setValue("state.player.score", 0)
      local score = LoadSave.getValue("state.player.score")
      assert.equals(0, score)

      LoadSave.setValue("state.player.score", -100)
      score = LoadSave.getValue("state.player.score")
      assert.equals(-100, score)
    end)

    it("should handle nil values", function()
      LoadSave.setValue("state.player.tempData", nil)
      local value = LoadSave.getValue("state.player.tempData")
      assert.is_nil(value)
    end)

    it("should handle empty string values", function()
      LoadSave.setValue("state.player.name", "")
      local name = LoadSave.getValue("state.player.name")
      assert.equals("", name)
    end)
  end)
end)
