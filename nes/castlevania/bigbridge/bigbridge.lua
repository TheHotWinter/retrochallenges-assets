-- Castlevania Big Bridge Challenge Script
-- Loads savestate and monitors progress through the big bridge section

----------------------- 
-- ROOT + path helpers
-----------------------
local function script_dir()
  local s = debug.getinfo(1, "S").source
  local p = (s:sub(1,1)=="@" and s:sub(2) or s)
  return (p:match("^(.*[\\/])") or "")
end
-- Script is in: %roamingdata%\nes\castlevania\bigbridge\bigbridge.lua
-- Need to go up 3 levels to reach root: %roamingdata%
local ROOT = script_dir() .. "..\\..\\..\\"

local PATH = {
  roms   = ROOT .. "roms\\",
  images = ROOT .. "assets\\",        -- %roamingdata%\assets\
  audio  = ROOT .. "assets\\",        -- %roamingdata%\assets\
  utils  = ROOT .. "utils\\",         -- %roamingdata%\utils\
  savestates = "savestates\\"         -- Relative to script location
}

-- Memory addresses
local ADDR = {
    SYSTEM_STATE = 0x0018,
    USER_PAUSED = 0x0022,
    SCORE = 0x07FC, -- Score address (3 bytes)
    HEALTH_REAL = 0x0045,
    SIMON_STATE = 0x046C,
    STAGE = 0x0028,
}

-- Use safe memory read/write functions
local read_u8 = memory.read_u8 or memory.readbyte
local write_u8 = memory.write_u8 or memory.writebyte

-- Embedded TextGameTimer (to avoid require issues)
local TextGameTimer = {}
TextGameTimer.__index = TextGameTimer

function TextGameTimer:new()
    local o = {}
    setmetatable(o, TextGameTimer)
    
    o.startTime = nil
    o.elapsedTime = 0
    o.isRunning = false
    o.position = {x = 10, y = 10}
    o.fontHeight = 12
    o.fontForeground = "white"
    o.fontBackground = "black"
    o.format = "TIME: %02d:%02d.%02d"
    
    return o
end

function TextGameTimer:start()
    if not self.isRunning then
        self.startTime = os.clock()
        self.isRunning = true
    end
end

function TextGameTimer:stop()
    if self.isRunning then
        self.elapsedTime = self.elapsedTime + (os.clock() - self.startTime)
        self.isRunning = false
    end
end

function TextGameTimer:reset()
    self.startTime = nil
    self.elapsedTime = 0
    self.isRunning = false
end

function TextGameTimer:getElapsedTime()
    local currentElapsed = self.elapsedTime
    if self.isRunning then
        currentElapsed = currentElapsed + (os.clock() - self.startTime)
    end
    return currentElapsed
end

function TextGameTimer:formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    local wholeSeconds = math.floor(remainingSeconds)
    local milliseconds = math.floor((remainingSeconds - wholeSeconds) * 100)
    
    return string.format(self.format, minutes, wholeSeconds, milliseconds)
end

function TextGameTimer:draw()
    if not self.isRunning and self.elapsedTime == 0 then
        return
    end
    
    local elapsed = self:getElapsedTime()
    local timeText = self:formatTime(elapsed)
    
    gui.text(self.position.x, self.position.y, timeText)
end

function TextGameTimer:setPosition(x, y)
    self.position = {x = x, y = y}
end

function TextGameTimer:setFontHeight(height)
    self.fontHeight = height
end

function TextGameTimer:setFontColors(foreground, background)
    self.fontForeground = foreground or "white"
    self.fontBackground = background or "black"
end

function TextGameTimer:setTimeFormat(format)
    self.format = format or "TIME: %02d:%02d.%02d"
end

-- Try to load SoundPlayer, fallback to no-sound if not available
local SoundPlayer = nil
local soundAvailable = false

-- Try different ways to load SoundPlayer
local function tryLoadSoundPlayer()
    print("Attempting to load SoundPlayer...")
    
    -- Method 1: Direct require (original case)
    local ok, sp, err = pcall(function() return require("SoundPlayer") end)
    if ok and sp then
        print("SoundPlayer loaded via direct require")
        return sp, true
    else
        print("Direct require failed: " .. tostring(err))
    end
    
    -- Method 2: Try with lowercase filename
    local ok2, sp2, err2 = pcall(function() return require("soundplayer") end)
    if ok2 and sp2 then
        print("SoundPlayer loaded via lowercase require")
        return sp2, true
    else
        print("Lowercase require failed: " .. tostring(err2))
    end
    
    -- Method 3: Try with utils path (original case)
    local ok3, sp3, err3 = pcall(function() return require("utils/SoundPlayer") end)
    if ok3 and sp3 then
        print("SoundPlayer loaded via utils/SoundPlayer")
        return sp3, true
    else
        print("utils/SoundPlayer failed: " .. tostring(err3))
    end
    
    -- Method 4: Try with utils path (lowercase)
    local ok4, sp4, err4 = pcall(function() return require("utils/soundplayer") end)
    if ok4 and sp4 then
        print("SoundPlayer loaded via utils/soundplayer")
        return sp4, true
    else
        print("utils/soundplayer failed: " .. tostring(err4))
    end
    
    -- Method 5: Try with relative path (original case)
    local ok5, sp5, err5 = pcall(function() return require("../../utils/SoundPlayer") end)
    if ok5 and sp5 then
        print("SoundPlayer loaded via relative path")
        return sp5, true
    else
        print("Relative path failed: " .. tostring(err5))
    end
    
    -- Method 6: Try with relative path (lowercase)
    local ok6, sp6, err6 = pcall(function() return require("../../utils/soundplayer") end)
    if ok6 and sp6 then
        print("SoundPlayer loaded via relative lowercase path")
        return sp6, true
    else
        print("Relative lowercase path failed: " .. tostring(err6))
    end
    
    -- Method 7: Try direct file loading as fallback
    print("Trying direct file loading...")
    local soundplayerPath = PATH.utils .. "soundplayer.lua"
    local file = io.open(soundplayerPath, "r")
    if file then
        file:close()
        print("SoundPlayer file found at: " .. soundplayerPath)
        
        -- Try to load and execute the file directly
        local ok7, sp7, err7 = pcall(function()
            local chunk = loadfile(soundplayerPath)
            if chunk then
                return chunk()
            else
                return nil, "Failed to load file"
            end
        end)
        
        if ok7 and sp7 then
            print("SoundPlayer loaded via direct file loading")
            return sp7, true
        else
            print("Direct file loading failed: " .. tostring(err7))
        end
    else
        print("SoundPlayer file not found at: " .. soundplayerPath)
    end
    
    print("All SoundPlayer load attempts failed")
    return nil, false
end

SoundPlayer, soundAvailable = tryLoadSoundPlayer()
if not soundAvailable then
    print("Warning: SoundPlayer not available - sound will be disabled")
    -- Create a dummy SoundPlayer
    SoundPlayer = {
        available = function() return false end,
        play = function() return false end,
        stop = function() return false end,
        diagnose = function() print("SoundPlayer not loaded - cannot run diagnostics") end
    }
else
    print("SoundPlayer loaded successfully")
end

-- Initialize timer
local timer = TextGameTimer:new()
timer:setPosition(10, 10)
timer:setFontHeight(14)
timer:setFontColors("yellow", "black")
timer:setTimeFormat("TIME: %02d:%02d.%02d")

-- Challenge-specific variables
local challengeStarted = false
local challengeCompleted = false
local savestateLoaded = false
local soundPlayed = false
local countdownCompleted = false
local countdownStarted = false
local timerStarted = false
local showingCompletionScreen = false
local completionImageShown = false

-- Helper function to check if file exists
local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Helper function to neutralize player input
local function neutralizeP1()
    joypad.set({A=false,B=false,Start=false,Select=false,Up=false,Down=false,Left=false,Right=false},1)
end

-- Helper function to force pause frame (freeze game state)
local function forcePauseFrame()
    write_u8(ADDR.USER_PAUSED, 1)
    neutralizeP1()
end

-- Helper function to unpause game (unfreeze game state)
local function releasePause()
    write_u8(ADDR.USER_PAUSED, 0)
end

-- Countdown images and sounds
local COUNTDOWN_IMAGES = {
    { PATH.images .. "3.png", 60 },
    { PATH.images .. "2.png", 60 },
    { PATH.images .. "1.png", 60 },
    { PATH.images .. "go.png", 120 },
}

-- Memory addresses for god mode
local GOD_MODE_ADDR = {
    HEALTH_REAL = 0x0045,        -- Simon Real Health (0x40 = 64 in decimal = full health)
    HEALTH_DISPLAY = 0x0044,     -- Simon Display Health
    HEALTH_COPY = 0x004B,        -- Health copy for UI updates
    HEARTS = 0x0071,             -- Hearts (12 hearts)
    SUBWEAPON = 0x015B,          -- Subweapon (0x0D = Axe)
    WHIP_LEVEL = 0x0070,         -- Whip Level (0x00 = Short)
    STUN_TIMER = 0x0047,         -- Stun Timer (when hit by enemies)
    WOUNDED_TIMER = 0x005B,      -- Wounded Timer (for iFrames)
}

-- Constants for god mode
local FULL_HEALTH = 0x40         -- 64 in decimal = full health
local START_HEARTS = 12          -- 12 hearts
local AXE_WEAPON = 0x0D          -- Axe subweapon
local LONG_WHIP = 0x02           -- Long whip level (max whip)

-- Function to read score from memory (BCD format)
function getScore()
    -- Check if memory access is available
    if not read_u8 then
        print("Memory access not available - make sure ROM is loaded")
        return 0
    end
    
    local ok, score = pcall(function()
        -- Read 3 bytes from the score address (BCD format)
        local byte1 = read_u8(ADDR.SCORE)      -- Most significant byte
        local byte2 = read_u8(ADDR.SCORE + 1)  -- Middle byte
        local byte3 = read_u8(ADDR.SCORE + 2)  -- Least significant byte
        
        -- Convert each byte from BCD to decimal
        local digit1 = math.floor(byte1 / 16)  -- Ten thousands
        local digit2 = byte1 % 16              -- Thousands
        local digit3 = math.floor(byte2 / 16)  -- Hundreds
        local digit4 = byte2 % 16              -- Tens
        local digit5 = math.floor(byte3 / 16)  -- Ones
        local digit6 = byte3 % 16              -- Tenths (not displayed)
        
        -- Combine digits to form the score
        local score = digit1 * 10000 + digit2 * 1000 + digit3 * 100 + digit4 * 10 + digit5
        
        return score
    end)
    
    if not ok then
        return 0
    end
    
    return score
end

-- Function to get current stage
function getStage()
    if not read_u8 then
        return 0
    end
    
    local ok, stage = pcall(function()
        return read_u8(ADDR.STAGE)
    end)
    
    if not ok then
        return 0
    end
    
    return stage
end

-- Function to check if mummy boss is defeated (HP = 0)
function isMummyBossPresent()
    if not read_u8 then
        return false
    end
    
    -- Check boss health
    local ok, bossHealth = pcall(function()
        return read_u8(0x01A9) -- Boss Real Health
    end)
    
    if ok then
        -- End challenge when boss HP reaches 0 (boss defeated)
        return bossHealth == 0
    end
    
    return false
end

-- Function to initialize weapon setup (call once after savestate loads)
local function initializeWeaponSetup()
    print("Setting up Simon's equipment...")
    
    -- Set 12 hearts (try different approach for HUD update)
    write_u8(GOD_MODE_ADDR.HEARTS, START_HEARTS)
    write_u8(0x0071, START_HEARTS)  -- Hearts address
    
    -- Try to trigger HUD refresh by temporarily changing and restoring
    local originalHearts = read_u8(0x0071)
    write_u8(0x0071, 0)  -- Set to 0
    emu.frameadvance()   -- Wait one frame
    write_u8(0x0071, START_HEARTS)  -- Set to desired value
    emu.frameadvance()   -- Wait one frame
    
    print("Hearts set to: " .. START_HEARTS)
    
    -- Set axe subweapon (both real and display copies)
    write_u8(GOD_MODE_ADDR.SUBWEAPON, AXE_WEAPON)
    write_u8(0x015B, AXE_WEAPON)  -- Force HUD subweapon display update
    print("Subweapon set to: Axe (0x" .. string.format("%02X", AXE_WEAPON) .. ")")
    
    -- Set long whip level (both real and display copies)
    write_u8(GOD_MODE_ADDR.WHIP_LEVEL, LONG_WHIP)
    write_u8(0x0070, LONG_WHIP)  -- Force HUD whip level display update
    print("Whip level set to: Long (0x" .. string.format("%02X", LONG_WHIP) .. ")")
end

-- Function removed - no more god mode, Simon can take damage normally

-- Countdown function (exactly like 5000pts challenge)
local function countdown_hardpaused()
    gui.clearGraphics()
    
    for i, item in ipairs(COUNTDOWN_IMAGES) do
        local path, frames = item[1], item[2]
        
        -- Play tick sound for 3, 2, 1 (not for GO)
        if i < #COUNTDOWN_IMAGES and soundAvailable then
            local tickPath = PATH.audio .. "tock.wav"
            if file_exists(tickPath) then
                SoundPlayer.play(tickPath)
            end
        end
        
        -- Display countdown image
        for frame = 1, frames do
            forcePauseFrame() -- This freezes game state, NOT emulation
            
            if file_exists(path) then
                gui.drawImage(path, 0, 0)
            end
            
            emu.frameadvance() -- This advances the emulation frame
        end
    end
    
    -- Clear graphics and final frame
    gui.clearGraphics()
    forcePauseFrame()
    emu.frameadvance()
    
    -- Initialize weapon setup after countdown completes
    initializeWeaponSetup()
    
    -- Unpause the game after countdown completes
    releasePause()
    countdownCompleted = true
end


-- Function to reset the challenge
local function resetChallenge()
    print("Resetting challenge...")
    
    -- Reset all state variables
    challengeStarted = false
    challengeCompleted = false
    savestateLoaded = false
    soundPlayed = false
    countdownCompleted = false
    countdownStarted = false
    timerStarted = false
    showingCompletionScreen = false
    completionImageShown = false
    
    -- Reset timer
    timer:reset()
    
    -- Reload savestate
    if loadSavestate() then
        countdownStarted = true
        print("Challenge reset - countdown will restart")
    else
        print("Failed to reload savestate during reset")
    end
end

-- Function to save results to JSON
local function saveResults(finalTime, finalScore, finalStage)
    local results = {
        challengeName = "Castlevania Big Bridge Challenge",
        username = "Player", -- Placeholder for now
        completionTime = finalTime,
        finalScore = finalScore,
        finalStage = finalStage,
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        otherInfo = {
            challengeType = "Speed Run",
            platform = "NES",
            game = "Castlevania",
            section = "Big Bridge"
        }
    }
    
    -- Convert to JSON string (simple implementation)
    local jsonStr = string.format([[
{
    "challengeName": "%s",
    "username": "%s",
    "completionTime": "%s",
    "finalScore": %d,
    "finalStage": %d,
    "timestamp": "%s",
    "otherInfo": {
        "challengeType": "%s",
        "platform": "%s",
        "game": "%s",
        "section": "%s"
    }
}]], 
        results.challengeName,
        results.username,
        results.completionTime,
        results.finalScore,
        results.finalStage,
        results.timestamp,
        results.otherInfo.challengeType,
        results.otherInfo.platform,
        results.otherInfo.game,
        results.otherInfo.section
    )
    
    -- Save to file
    local filename = "result_castlevania_bigbridge.json"
    local file = io.open(filename, "w")
    if file then
        file:write(jsonStr)
        file:close()
        print("Results saved to: " .. filename)
        return true
    else
        print("Failed to save results file")
        return false
    end
end

-- Function to show completion screen
local function showCompletionScreen(finalTime, finalScore, finalStage)
    if showingCompletionScreen then
        return -- Already showing
    end
    
    showingCompletionScreen = true
    print("Showing completion screen...")
    
    -- Save results
    saveResults(finalTime, finalScore, finalStage)
    
    -- Show completion image
    local completionImagePath = PATH.audio .. "completed.png"
    if file_exists(completionImagePath) then
        completionImageShown = true
        print("Completion image found: " .. completionImagePath)
    else
        print("Completion image not found: " .. completionImagePath)
    end
end

-- Function to load savestate
function loadSavestate()
    local savestatePath = PATH.savestates .. "bigbridge.state"
    
    -- Check if savestate file exists
    local file = io.open(savestatePath, "r")
    if file then
        file:close()
        
        -- Try to load the savestate
        local ok, err = pcall(function() savestate.load(savestatePath) end)
        if ok then
            savestateLoaded = true
            print("Savestate loaded: " .. savestatePath)
            return true
        else
            print("Error loading savestate: " .. tostring(err))
            return false
        end
    else
        print("Warning: Savestate file not found: " .. savestatePath)
        return false
    end
end

-- Check if ROM is loaded before starting
if not memory or not memory.readbyte then
    print("ERROR: No ROM loaded!")
    print("Please load Castlevania ROM first, then run this script.")
    print("Script will exit.")
    return
end

-- Set best memory domain
local function set_best_domain()
    if not (memory.getmemorydomainlist and memory.usememorydomain) then return end
    local ok, list = pcall(memory.getmemorydomainlist)
    if not ok or not list then return end
    local prefer = { "System Bus", "RAM" }
    for _, want in ipairs(prefer) do
        for _, d in ipairs(list) do
            if d == want then pcall(memory.usememorydomain, d); return end
        end
    end
    if #list > 0 then pcall(memory.usememorydomain, list[1]) end
end

-- Set memory domain after ROM is loaded
set_best_domain()

print("Castlevania Big Bridge Challenge Script Starting...")
print("Make sure Castlevania ROM is loaded and running!")
print("Challenge: Defeat the Mummy Boss as fast as possible!")
print("Simon starts with: 12 hearts, Axe weapon, Long whip")
print("Normal gameplay: Simon can take damage and die!")
print("Controls: R = Reset Challenge, ESC = Quit (on completion screen)")

-- Input handling function
local function handleInput()
    -- Try different input methods
    local inputHandled = false
    
    -- Method 1: Try client input (check for R without modifiers)
    local ok1, inputState = pcall(function() return client.getInput() end)
    if ok1 and inputState then
        -- Check for R key without Ctrl modifier
        if inputState.R and not inputState.Ctrl then
            resetChallenge()
            inputHandled = true
        elseif showingCompletionScreen and inputState.Escape then
            client.exit()
            inputHandled = true
        end
    else
        -- Method 2: Try joypad input (fallback)
        local ok2, joypadState = pcall(function() return joypad.get()[1] end)
        if ok2 and joypadState then
            if joypadState.R then
                resetChallenge()
                inputHandled = true
            elseif showingCompletionScreen and joypadState.Start then
                client.exit()
                inputHandled = true
            end
        end
    end
    
    return inputHandled
end

-- Main loop
while true do
    -- Handle input (R for reset, ESC for quit on completion screen)
    if handleInput() then
        -- Input was handled (reset or quit), continue to next frame
        emu.frameadvance()
        goto continue
    end
    
    -- Load savestate on first run
    if not savestateLoaded then
        if loadSavestate() then
            -- Start countdown after savestate is loaded
            countdownStarted = true
        end
        -- Mark as attempted to prevent repeated attempts
        savestateLoaded = true
    end
    
    -- Run countdown if it hasn't been completed yet
    if countdownStarted and not countdownCompleted then
        countdown_hardpaused()
        challengeStarted = true
    end
    
    -- Start timer after countdown completes
    if challengeStarted and not timerStarted then
        timer:start()
        timerStarted = true
    end
    
    -- No more god mode - Simon can take damage normally
    
    -- Get current score and stage
    local currentScore = getScore()
    local currentStage = getStage()
    
    -- Check if challenge is completed (mummy boss fight detected)
    if challengeStarted and not challengeCompleted and isMummyBossPresent() then
        timer:stop()
        challengeCompleted = true
        
        -- Play completion sound
        if not soundPlayed then
            local soundPath = PATH.audio .. "challengecompleted.wav"
            
            -- Try to play completion sound
            if soundAvailable then
                if file_exists(soundPath) then
                    local ok = pcall(function()
                        return SoundPlayer.play(soundPath)
                    end)
                    if ok then
                        print("Challenge completed! Mummy boss reached - Sound played!")
                    else
                        print("Challenge completed! Mummy boss reached - Sound failed to play")
                    end
                else
                    print("Challenge completed! Mummy boss reached - Sound file not found: " .. soundPath)
                end
            else
                print("Challenge completed! Mummy boss reached - SoundPlayer not available")
            end
            soundPlayed = true
        else
            print("Challenge completed! Mummy boss reached")
        end
        
        -- Show completion screen
        local finalTime = timer:formatTime(timer:getElapsedTime())
        showCompletionScreen(finalTime, currentScore, currentStage)
    end
    
    -- Display completion screen if challenge is completed
    if showingCompletionScreen then
        -- Show completion image
        if completionImageShown then
            local completionImagePath = PATH.audio .. "completed.png"
            gui.drawImage(completionImagePath, 0, 0)
        else
            -- Fallback text if image not found
            gui.text(150, 100, "CHALLENGE COMPLETED!")
        end
        
        -- Show completion info
        gui.text(10, 200, "Final Time: " .. timer:formatTime(timer:getElapsedTime()))
        gui.text(10, 220, "Score (Time): " .. timer:formatTime(timer:getElapsedTime()))
        gui.text(10, 240, "Final Stage: " .. currentStage)
        gui.text(10, 260, "Press R to Reset Challenge")
        gui.text(10, 280, "Press ESC to Quit BizHawk")
        
        -- Skip normal display
        emu.frameadvance()
        goto continue
    end
    
    -- Display timer only when challenge is running
    if challengeStarted and not challengeCompleted then
        timer:draw()
        
    end
    
    emu.frameadvance()
    
    ::continue::
end
