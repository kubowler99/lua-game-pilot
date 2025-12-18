---@class screen
---Screen dimension utilities for Solar2D
---Provides convenient access to screen boundaries, center points, and dimensions
---Accounts for letterboxing and device-specific screen sizes
---@field width number Actual screen width (including letterbox areas)
---@field height number Actual screen height (including letterbox areas)
---@field contentWidth number Content width from config.lua
---@field contentHeight number Content height from config.lua
---@field centerX number X coordinate of screen center
---@field centerY number Y coordinate of screen center
---@field originX number Left edge X coordinate (negative if letterboxed)
---@field originY number Top edge Y coordinate (negative if letterboxed)
---@field edgeX number Right edge X coordinate
---@field edgeY number Bottom edge Y coordinate
return {
    width         = display.actualContentWidth,
    height        = display.actualContentHeight,
    contentWidth  = display.contentWidth,
    contentHeight = display.contentHeight,
    centerX       = display.contentWidth*0.5,
    centerY       = display.contentHeight*0.5,
    originX       = display.screenOriginX,
    originY       = display.screenOriginY,
    edgeX         = display.screenOriginX+display.actualContentWidth,
    edgeY         = display.screenOriginY+display.actualContentHeight
}
