-- Project: Simple device detection flags
--
-- File name: main.lua
--
-- Author: Corona Labs
--
-- Abstract: Sets up some simple boolean flags that lets us do various device tests.
--
--
-- Target devices: simulator, device
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2012 Corona Labs Inc. All Rights Reserved.
---------------------------------------------------------------------------------------

---@class device
---Device detection utility module
---Provides boolean flags for platform and device-specific detection
---Useful for conditional code based on platform (iOS/Android) or specific devices
---@field isApple boolean True if running on any iOS device
---@field isAndroid boolean True if running on any Android device
---@field isGoogle boolean True if running on Google Play-compatible Android device
---@field isKindleFire boolean True if running on Amazon Kindle Fire device
---@field isNook boolean True if running on Barnes & Noble Nook device
---@field is_iPad boolean True if running on iPad
---@field isTall boolean True if device has tall aspect ratio (>1.5:1)
---@field isSimulator boolean True if running in Solar2D simulator
local M = {}

--
-- Set up some defaults
--

M.isApple = false
M.isAndroid = false
M.isGoogle = false
M.isKindleFire = false
M.isNook = false
M.is_iPad = false
M.isTall = false
M.isSimulator = false

local model = system.getInfo("model")

-- Are we on the simulator?

if "simulator" == system.getInfo("environment") then
    M.isSimulator = true
end

-- lets see if we are a tall device

M.isTall = false
if (display.pixelHeight/display.pixelWidth) > 1.5 then
    M.isTall = true
end

-- first, look to see if we are on some Apple platform.
-- All models start with iP, so we can check that.

if string.sub(model,1,2) == "iP" then
     -- We are an iOS device of some sort
     M.isApple = true

     if string.sub(model, 1, 4) == "iPad" then
         M.is_iPad = true
     end
else
    -- Not Apple, then we must be one of the Android devices
    M.isAndroid = true

    -- lets assume we are Google for the moment
    M.isGoogle = true

    -- All the Kindles start with K, though Corona SDK before build 976's Kindle Fire 9 returned "WFJWI" instead of "KFJWI"

    if model == "Kindle Fire" or model == "WFJWI" or string.sub(model,1,2) == "KF" then
        M.isKindleFire = true
        M.isGoogle = false
    end

    -- Are we a nook?

    if string.sub(model,1,4) == "Nook" or string.sub(model,1,4) == "BNRV" then
        M.isNook = true
        M.isGoogle = false
    end
end

return M
