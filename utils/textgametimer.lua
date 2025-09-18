-- TextGameTimer.lua - A customizable text-based timer for game challenges
-- Usage:
--   local TextGameTimer = require("TextGameTimer")
--   local timer = TextGameTimer:new()
--   timer:start()
--   timer:draw()

local TextGameTimer = {}
TextGameTimer.__index = TextGameTimer

-- Create a new timer instance
function TextGameTimer:new()
    local o = {}
    setmetatable(o, TextGameTimer)
    
    -- Default properties
    o.startTime = nil
    o.elapsedTime = 0
    o.isRunning = false
    o.position = {x = 10, y = 10}
    o.fontHeight = 12
    o.fontForeground = "white"
    o.fontBackground = "black"
    o.format = "TIME: %02d:%02d.%02d"  -- Format: MM:SS:MS
    
    return o
end

-- Start the timer
function TextGameTimer:start()
    if not self.isRunning then
        self.startTime = os.clock()
        self.isRunning = true
    end
end

-- Stop the timer
function TextGameTimer:stop()
    if self.isRunning then
        self.elapsedTime = self.elapsedTime + (os.clock() - self.startTime)
        self.isRunning = false
    end
end

-- Reset the timer
function TextGameTimer:reset()
    self.startTime = nil
    self.elapsedTime = 0
    self.isRunning = false
end

-- Get the current elapsed time in seconds
function TextGameTimer:getElapsedTime()
    local currentElapsed = self.elapsedTime
    if self.isRunning then
        currentElapsed = currentElapsed + (os.clock() - self.startTime)
    end
    return currentElapsed
end

-- Format time as MM:SS:MS
function TextGameTimer:formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    local wholeSeconds = math.floor(remainingSeconds)
    local milliseconds = math.floor((remainingSeconds - wholeSeconds) * 100)
    
    return string.format(self.format, minutes, wholeSeconds, milliseconds)
end

-- Draw the timer on screen
function TextGameTimer:draw()
    if not self.isRunning and self.elapsedTime == 0 then
        return -- Don't draw if timer hasn't been started
    end
    
    local elapsed = self:getElapsedTime()
    local timeText = self:formatTime(elapsed)
    
    gui.drawText(
        self.position.x, 
        self.position.y, 
        timeText, 
        self.fontForeground, 
        self.fontBackground,
        self.fontHeight
    )
end

-- Set timer position
function TextGameTimer:setPosition(x, y)
    self.position = {x = x, y = y}
end

-- Set font height
function TextGameTimer:setFontHeight(height)
    self.fontHeight = height
end

-- Set font colors
function TextGameTimer:setFontColors(foreground, background)
    self.fontForeground = foreground or "white"
    self.fontBackground = background or "black"
end

-- Set time format
function TextGameTimer:setTimeFormat(format)
    self.format = format or "TIME: %02d:%02d.%02d"
end

return TextGameTimer