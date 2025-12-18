local jsonParser = require("json")

---@class LoadSave
---Persistent data management system using JSON file storage
---Supports dot-notation path access, sandbox mode for testing, and session tracking
local LoadSave = {}

------------------------------------------------------------------------------------------------------------------------
-- Save Data
------------------------------------------------------------------------------------------------------------------------

---The current saved data table (loaded from JSON)
---@type table|nil
local savedData     = nil

---Whether sandbox mode is active (prevents saving to disk)
---@type boolean
local isSandboxMode = false

---Loads saved data from savedData.json file
---If file doesn't exist, initializes with nuke()
---Updates session timestamps (prevSession, currentSession)
---@return void
function LoadSave.load()
	local path = system.pathForFile( "savedData.json", system.DocumentsDirectory )
  local file = io.open( path, "r" )
	if file then
    local settingsImport
		settingsImport = file:read( "*a")
		io.close( file )
    savedData = jsonParser.decode(settingsImport)
    savedData.prevSession = savedData.currentSession
    savedData.currentSession = os.time()
	else
		LoadSave.nuke()
	end
end

---Internal helper to reset saved data using a template file
---@param file string Path to template JSON file in ResourceDirectory
---@return table savedData The reset saved data table
function LoadSave._resetUsing(file)
	local settingsImport
	savedData = system.pathForFile( file, system.ResourceDirectory )
	local emptyFile = io.open( savedData, "r" )
	if emptyFile then
		settingsImport = emptyFile:read( "*a")
		io.close(emptyFile)
	end
	savedData = jsonParser.decode(settingsImport)

  local time = os.time()
  savedData.firstSession    = time
  savedData.prevSession     = time
  LoadSave.save()

	return savedData
end

---Resets saved data to default state using savedData.json template
---Performs a partial reset (preserves some data)
---@return void
function LoadSave.nuke()
  print("-- NUKING! --")
  LoadSave._resetUsing("savedData.json")
end

---Resets saved data to completely fresh state using savedDataFull.json template
---Performs a full reset (wipes all data)
---@return void
function LoadSave.nukeFull()
  print("-- NUKING FULL! --")
  LoadSave._resetUsing("savedDataFull.json")
end


---Starts sandbox mode for testing without affecting real save data
---Loads temporary data from savedData-{file}.json
---Changes are not persisted to disk while in sandbox mode
---@param file string Name identifier for sandbox file (e.g., "test" -> "savedData-test.json")
---@return table savedData The sandbox data table
function LoadSave.startSandboxMode(file)
  LoadSave._savedData = savedData

  local settingsImport
	local emptyData = system.pathForFile( "savedData-"..file..".json", system.ResourceDirectory )
	local emptyFile = io.open( emptyData, "r" )
	if emptyFile then
		settingsImport = emptyFile:read( "*a")
		io.close(emptyFile)
	end
	emptyData = jsonParser.decode(settingsImport)

	savedData = emptyData

  isSandboxMode = true

  print("Sandbox mode is on")

  return savedData
end

---Stops sandbox mode and restores original saved data
---Discards any changes made in sandbox mode
---@return table savedData The restored original data
function LoadSave.stopSandboxMode()
  savedData = LoadSave._savedData
  isSandboxMode = false

  print("Sandbox mode is off")

  return savedData
end

---Gets a value from saved data using dot-notation path
---Example: getValue("state.player.score") accesses savedData.state.player.score
---@param path string Dot-notation path (e.g., "state.player.name")
---@return any value The value at the specified path
function LoadSave.getValue(path)
  local value = savedData
  for _, key in ipairs(path:split(".")) do
    value = value[key]
  end
  return value
end

---Sets a value in saved data using dot-notation path
---Example: setValue("state.player.score", 100) sets savedData.state.player.score = 100
---@param path string Dot-notation path (e.g., "state.player.name")
---@param value any Value to set at the path
---@param save? boolean If true, immediately saves to disk (default false)
---@return void
function LoadSave.setValue(path, value, save)
  local t = savedData
  local pathTable = path:split(".")
  for i=1,#pathTable-1 do
    t = t[pathTable[i]]
  end
  t[pathTable[#pathTable]] = value
  if save then
    LoadSave.save()
  end
end

---Saves current data to savedData.json file
---Does nothing if sandbox mode is active
---@return void
function LoadSave.save()
  if isSandboxMode then print("Data wasn't saved due to Sandbox mode is on") return end
	print("saving...")

	local path = system.pathForFile( "savedData.json", system.DocumentsDirectory )
	local file = io.open( path, "w+" )

	file:write( jsonParser.encode(savedData))
	io.close( file )

  print("Done")
end

---Prints all saved data to console for debugging
---Uses pretty-printing for readable output
---@return void
function LoadSave.printAll()
  print("-------- SAVED DATA CONTENT --------")
  print(pl.pretty.write(savedData))
  print("------------------------------------")
end


return LoadSave
