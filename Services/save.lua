-- Services/save.lua
-- Wrapper around existing Plugins/loadSave.lua to add schemaVersion, migration, and backup hooks.

local serviceLocator = require("Services.serviceLocator")

-- Try to require existing plugin; if not present, we create a minimal fallback.
local ok, loadSave = pcall(require, "Plugins.loadSave")
if not ok then
    loadSave = {
        load = function() return {} end,
        save = function() end,
        getValue = function() return nil end,
        setValue = function() end,
        nuke = function() end,
        nukeFull = function() end,
    }
end

local SaveService = {}
SaveService.schemaVersion = 1 -- bump when you change savedData shape

local migrations = {} -- will be populated from save_migrations/

-- Load migration modules if present
local function loadMigrations()
    local ok, lfs = pcall(require, "lfs")
    -- We avoid depending on lfs; instead try to require known migration modules.
    -- Add migration modules manually here if you create them.
    local success, m = pcall(require, "save_migrations.v1_to_v2")
    if success and type(m) == "function" then
        migrations[2] = m
    end
end

local function backupSavedData(savedData)
    -- create a backup file before migrating; delegate to loadSave if it supports it
    if loadSave.backup then
        pcall(loadSave.backup)
    else
        -- best-effort: write a .bak file next to savedData.json if possible
        local json = require("json")
        local path = system.pathForFile("savedData.json", system.DocumentsDirectory)
        if path then
            local f, err = io.open(path, "r")
            if f then
                local contents = f:read("*a")
                f:close()
                local bakPath = system.pathForFile("savedData.json.bak", system.DocumentsDirectory)
                local fb, ferr = io.open(bakPath, "w")
                if fb then
                    fb:write(contents)
                    fb:close()
                end
            end
        end
    end
end

function SaveService.load()
    local data = loadSave.load()
    if type(data) ~= "table" then data = {} end
    local current = data.schemaVersion or 0
    if current < SaveService.schemaVersion then
        backupSavedData(data)
        -- run migrations sequentially
        for v = current + 1, SaveService.schemaVersion do
            local m = migrations[v]
            if type(m) == "function" then
                data = m(data) or data
            end
        end
        -- persist migrated data
        if loadSave.save then
            loadSave.save(data)
        end
    end
    return data
end

function SaveService.save(data)
    if loadSave.save then
        loadSave.save(data)
    else
        error("Underlying save plugin missing save()")
    end
end

function SaveService.getValue(path, default)
    if loadSave.getValue then
        return loadSave.getValue(path, default)
    end
    -- fallback: load and traverse dot-path
    local data = SaveService.load()
    if not path or path == "" then return data end
    local cur = data
    for part in string.gmatch(path, "[^%.]+") do
        if type(cur) ~= "table" then return default end
        cur = cur[part]
        if cur == nil then return default end
    end
    return cur
end

function SaveService.setValue(path, value)
    if loadSave.setValue then
        return loadSave.setValue(path, value)
    end
    local data = SaveService.load()
    local cur = data
    local parts = {}
    for part in string.gmatch(path, "[^%.]+") do parts[#parts+1] = part end
    for i = 1, #parts - 1 do
        local p = parts[i]
        if type(cur[p]) ~= "table" then cur[p] = {} end
        cur = cur[p]
    end
    cur[parts[#parts]] = value
    SaveService.save(data)
end

-- Initialize migrations
loadMigrations()

return SaveService