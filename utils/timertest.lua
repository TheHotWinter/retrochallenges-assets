-- SimpleTimerTest.lua - Test script for TextGameTimer
-- Place in: ...\NesChallenges\challenges\SimpleTimerTest.lua

-- Let require find modules in \challenges
package.path = package.path .. ";.\\challenges\\?.lua"

-- Load the TextGameTimer module
local TextGameTimer = require("TextGameTimer")

-- Create a timer instance
local timer = TextGameTimer:new()

-- Setup timer
timer:setPosition(8, 208) -- Top left with 8px margin
timer:setFontHeight(12)
timer:setFontColors("white", "black")

-- Start the timer immediately
timer:start()

console.log("Timer test started - Press ESC to exit")

-- Main loop
while true do
    -- Draw the timer
    timer:draw()
    
    -- Draw some info text
    gui.drawText(8, 30, "TextGameTimer Test", "white", "black", nil, 12)
    gui.drawText(8, 45, "Press ESC to exit", "white", "black", nil, 10)
    
    -- Check for ESC key to exit
    local keys = input.get()
    if keys["Escape"] then
        console.log("Exiting timer test")
        break
    end
    
    emu.frameadvance()
end