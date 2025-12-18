------------------------------------------------------------------------------------------------------------------------
-- Loading Screen --
------------------------------------------------------------------------------------------------------------------------

---@class LoadingScreen
---Loading screen overlay management
---Shows "Loading..." text on black background to block user interaction
---Also handles splash screen with company logo
local LoadingScreen = {}

---Active loading screen display group
---@type table|nil
local loadingScreen

---Active splash screen display group
---@type table|nil
local splashScreen

---Shows the loading screen
---Creates black fullscreen overlay with "Loading..." text
---Blocks all touch/tap events while visible
---@return boolean success True if created, false if already showing
function LoadingScreen.show()
  if loadingScreen then return false end

  loadingScreen = display.newGroup()
  local background = display.newRect(loadingScreen, screen.centerX, screen.centerY, screen.edgeX-screen.originX, screen.edgeY-screen.originY)
  background:setFillColor(0)
  background.isHitTestable = true
  background:addEventListener( "touch", function() return true end )
  background:addEventListener( "tap", function() return true end )
  display.newText(loadingScreen, "Loading...", screen.centerX, screen.centerY-9, native.systemFontBold, 18)

  if splashScreen then splashScreen:toFront() end

  return true
end

---Shows the splash screen with company logo
---Creates fullscreen image that blocks touch/tap events
---@return boolean success True if created, false if already showing
function LoadingScreen.showSplashScreen()
  if splashScreen then return false end

  splashScreen = display.newGroup()

  local image = display.newImage(splashScreen, "singnCo_logo.png")
  local scale = math.max(screen.width/image.width, screen.height/image.height)*1.01
  image.xScale,image.yScale = scale, scale
  image.x, image.y = screen.centerX, screen.centerY
  splashScreen:addEventListener( "touch", function() return true end )
  splashScreen:addEventListener( "tap", function() return true end )

  return true
end

---Hides the loading screen with fade transition
---@param time? number Fade duration in milliseconds (default 0 = instant)
---@param onComplete? function Callback when fade completes
---@return void
function LoadingScreen.hide(time, onComplete)
  transition.to(loadingScreen, {
    time          = time or 0,
    alpha         = 0,
    onComplete    = onComplete,
    onCancel      = function()
      loadingScreen:removeSelf()
    end
  })
end

---Hides the splash screen with fade transition
---@param time? number Fade duration in milliseconds (default 0 = instant)
---@return void
function LoadingScreen.hideSplashScreen(time)
  transition.to(splashScreen, {
    time     = time or 0,
    alpha    = 0,
    onCancel = function()
      splashScreen:removeSelf()
    end
  })
end

---Brings loading screen to front of display hierarchy
---@return void
function LoadingScreen.toFront()
  loadingScreen:toFront()
end

---Brings splash screen to front of display hierarchy
---@return void
function LoadingScreen.splashScreenToFront()
  splashScreen:toFront()
end


return LoadingScreen
