-- gametimer.lua - Game Timer with image-based display for BizHawk Lua scripts
local M = {}

-- Default properties
M.position = {x = 0, y = 0}
M.isRunning = false
M.startFrame = nil
M.elapsedFrames = 0
M.pausedFrames = 0
M.scale = 1.0  -- Scale factor (1.0 = original size)
M.digitSpacing = 0  -- Start with 0 spacing, we'll handle overlap differently

-- Get current time in seconds using BizHawk's frame count and FPS
local function getCurrentTime()
    local totalFrames = M.elapsedFrames
    if M.isRunning and M.startFrame then
        totalFrames = totalFrames + (emu.framecount() - M.startFrame)
    end
    return totalFrames / 60.0  -- Assume 60 FPS for NES
end

-- Image paths (assuming images are in ../images/ relative to challenges folder)
local function get_image_path()
    local script_dir = debug.getinfo(1, "S").source:sub(2):match("^(.*[\\/])") or ""
    return script_dir .. "../images/"
end

local IMAGE_PATH = get_image_path()
local DIGIT_IMAGES = {
    [0] = IMAGE_PATH .. "_sSmall0blue.png",
    [1] = IMAGE_PATH .. "_sSmall1blue.png",
    [2] = IMAGE_PATH .. "_sSmall2blue.png",
    [3] = IMAGE_PATH .. "_sSmall3blue.png",
    [4] = IMAGE_PATH .. "_sSmall4blue.png",
    [5] = IMAGE_PATH .. "_sSmall5blue.png",
    [6] = IMAGE_PATH .. "_sSmall6blue.png",
    [7] = IMAGE_PATH .. "_sSmall7blue.png",
    [8] = IMAGE_PATH .. "_sSmall8blue.png",
    [9] = IMAGE_PATH .. "_sSmall9blue.png"
}
local COLON_IMAGE = IMAGE_PATH .. "_sSmallSemiblue.png"

-- Helper function to check if file exists
local function file_exists(path)
    local f = io.open(path, "rb")
    if f then f:close(); return true end
    return false
end

-- Start the timer
function M.start()
    if not M.isRunning then
        if M.startFrame then
            -- Resume from paused state
            M.pausedFrames = M.pausedFrames + (emu.framecount() - M.startFrame)
        else
            -- Fresh start
            M.pausedFrames = 0
        end
        M.startFrame = emu.framecount()
        M.isRunning = true
    end
end

-- Stop/pause the timer
function M.stop()
    if M.isRunning then
        M.elapsedFrames = M:getCurrentFrames()
        M.startFrame = nil
        M.isRunning = false
    end
end

-- Reset the timer to zero
function M.reset()
    M.startFrame = nil
    M.elapsedFrames = 0
    M.pausedFrames = 0
    M.isRunning = false
end

-- Set scale factor
function M.setScale(scaleFactor)
    M.scale = scaleFactor or 1.0
end

-- Set digit spacing
function M.setDigitSpacing(spacing)
    M.digitSpacing = spacing or 0
end

-- Get current elapsed frames
function M:getCurrentFrames()
    if M.isRunning and M.startFrame then
        return M.elapsedFrames + (emu.framecount() - M.startFrame)
    else
        return M.elapsedFrames
    end
end

-- Format time as MM:SS.mm (minutes:seconds.milliseconds)
function M:getFormattedTime()
    local totalSeconds = getCurrentTime()
    local minutes = math.floor(totalSeconds / 60)
    local seconds = math.floor(totalSeconds % 60)
    local milliseconds = math.floor((totalSeconds * 100) % 100)
    
    return {
        minutes = minutes,
        seconds = seconds,
        milliseconds = milliseconds
    }
end

-- Simple draw function without advanced parameters
local function drawSimpleImage(path, x, y)
    if file_exists(path) then
        gui.drawImage(path, x, y)
    end
end

-- Draw the timer on screen using image digits with scale and spacing
function M:draw()
    local time = self:getFormattedTime()
    local x, y = self.position.x, self.position.y
    local scale = self.scale
    
    -- Format digits with leading zeros
    local minTens = math.floor(time.minutes / 10)
    local minOnes = time.minutes % 10
    local secTens = math.floor(time.seconds / 10)
    local secOnes = time.seconds % 10
    local msTens = math.floor(time.milliseconds / 10)
    local msOnes = time.milliseconds % 10
    
    -- Calculate scaled dimensions
    local scaledWidth = 64 * scale
    local scaledHeight = 72 * scale
    
    -- Draw minutes (MM)
    drawSimpleImage(DIGIT_IMAGES[minTens], x, y)
    x = x + scaledWidth + M.digitSpacing
    
    drawSimpleImage(DIGIT_IMAGES[minOnes], x, y)
    x = x + scaledWidth + M.digitSpacing
    
    -- Draw colon (:)
    drawSimpleImage(COLON_IMAGE, x, y)
    x = x + scaledWidth + M.digitSpacing
    
    -- Draw seconds (SS)
    drawSimpleImage(DIGIT_IMAGES[secTens], x, y)
    x = x + scaledWidth + M.digitSpacing
    
    drawSimpleImage(DIGIT_IMAGES[secOnes], x, y)
    x = x + scaledWidth + M.digitSpacing
    
    -- Draw decimal point (use colon image)
    drawSimpleImage(COLON_IMAGE, x, y)
    x = x + scaledWidth + M.digitSpacing
    
    -- Draw milliseconds (mm)
    drawSimpleImage(DIGIT_IMAGES[msTens], x, y)
    x = x + scaledWidth + M.digitSpacing
    
    drawSimpleImage(DIGIT_IMAGES[msOnes], x, y)
end

-- Get the total width of the timer display (for positioning)
function M:getWidth()
    local scaledDigitWidth = 64 * self.scale
    local totalDigits = 8  -- MM:SS.mm = 8 elements
    return (scaledDigitWidth * totalDigits) + (self.digitSpacing * (totalDigits - 1))
end

-- Get the height of the timer display
function M:getHeight()
    return 72 * self.scale
end

-- Get current time in seconds (for external use)
function M:getTime()
    return getCurrentTime()
end

-- Get current time in milliseconds (for external use)
function M:getTimeMS()
    return getCurrentTime() * 1000
end

return M