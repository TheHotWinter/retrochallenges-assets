-- Castlevania God Mode Script
-- Gives Simon infinite health and the triple cross weapon
-- Always enabled - perfect for challenge creation

-- Memory addresses from castlevania_raminfo.md
local ADDR = {
    HEALTH_REAL = 0x0045,        -- Simon Real Health (0x40 = 64 in decimal = full health)
    HEALTH_DISPLAY = 0x0044,     -- Simon Display Health
    SUBWEAPON = 0x015B,          -- Subweapon (0x08 = Dagger, 0x09 = Boomerang, 0x0A = Rosary, 0x0B = Holy Water, 0x0D = Axe, 0x0F = Stopwatch)
    HEARTS = 0x0071,             -- Hearts (for subweapon usage)
    WHIP_LEVEL = 0x0070,         -- Whip Level (0x00 = Short, 0x01 = Long, 0x02 = Long+Chain)
    LIVES = 0x002A,              -- Lives
    SCORE = 0x07FC,              -- Score (3 bytes)
    TIMER = 0x0042,              -- Timer (2 bytes)
    STUN_TIMER = 0x0047,         -- Stun Timer (when hit by enemies)
    WOUNDED_TIMER = 0x005B,       -- Wounded Timer (for iFrames)
    HEALTH_COPY = 0x004B,         -- Health copy for UI updates (from raminfo.md)
}

-- Constants
local FULL_HEALTH = 0x40         -- 64 in decimal = full health
local MAX_HEARTS = 99            -- 99 hearts (reasonable amount)
local TRIPLE_CROSS = 0x0B        -- Holy Water (triple cross) subweapon
local MAX_WHIP_LEVEL = 0x02      -- Long whip with chain
local MAX_LIVES = 0xFF           -- 255 lives (displays as 99)
local TIMER_900 = 900            -- Timer set to 900 (0x0384 in hex)

-- Use safe memory read/write functions
local read_u8 = memory.read_u8 or memory.readbyte
local write_u8 = memory.write_u8 or memory.writebyte
local read_u16 = memory.read_u16_le or memory.readword
local write_u16 = memory.write_u16_le or memory.writeword

-- Check if ROM is loaded
if not memory or not memory.readbyte then
    print("ERROR: No ROM loaded!")
    print("Please load Castlevania ROM first, then run this script.")
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

set_best_domain()

-- Function to initialize god mode
local function initializeGodMode()
    -- Set full health (both real and display values)
    write_u8(ADDR.HEALTH_REAL, FULL_HEALTH)
    write_u8(ADDR.HEALTH_DISPLAY, FULL_HEALTH)
    write_u8(ADDR.HEALTH_COPY, FULL_HEALTH)  -- Health copy for UI updates
    
    -- Give infinite hearts for subweapon usage
    write_u8(ADDR.HEARTS, MAX_HEARTS)
    
    -- Give triple cross (holy water) subweapon
    write_u8(ADDR.SUBWEAPON, TRIPLE_CROSS)
    
    -- Give max whip level (long whip with chain)
    write_u8(ADDR.WHIP_LEVEL, MAX_WHIP_LEVEL)
    
    -- Give max lives
    write_u8(ADDR.LIVES, MAX_LIVES)
    
    -- Set timer to 900
    write_u16(ADDR.TIMER, TIMER_900)
    
    -- Clear stun and wounded timers
    write_u8(ADDR.STUN_TIMER, 0)
    write_u8(ADDR.WOUNDED_TIMER, 0)
    
    -- Reset score to 000000 (3 bytes)
    write_u8(ADDR.SCORE, 0)
    write_u8(ADDR.SCORE + 1, 0)
    write_u8(ADDR.SCORE + 2, 0)
end

print("Castlevania God Mode Script Loaded!")
print("God mode is ALWAYS ENABLED - perfect for challenge creation!")
print("Simon has:")
print("- Infinite health (64 HP)")
print("- Triple cross (holy water) subweapon")
print("- 99 hearts")
print("- Max whip level")
print("- Max lives")
print("- Timer locked at 900")
print("- Score locked at 000000")
print("")

-- Initialize god mode
initializeGodMode()

-- Main loop
while true do
    -- Maintain god mode every frame
    -- Force full health every frame (prevents any damage)
    write_u8(ADDR.HEALTH_REAL, FULL_HEALTH)
    write_u8(ADDR.HEALTH_DISPLAY, FULL_HEALTH)
    write_u8(ADDR.HEALTH_COPY, FULL_HEALTH)  -- Keep UI health bar updated
    
    -- Maintain infinite hearts
    write_u8(ADDR.HEARTS, MAX_HEARTS)
    
    -- Maintain triple cross subweapon
    write_u8(ADDR.SUBWEAPON, TRIPLE_CROSS)
    
    -- Maintain max whip level
    write_u8(ADDR.WHIP_LEVEL, MAX_WHIP_LEVEL)
    
    -- Keep timer at 900
    write_u16(ADDR.TIMER, TIMER_900)
    
    -- Clear any stun or wounded states
    write_u8(ADDR.STUN_TIMER, 0)
    write_u8(ADDR.WOUNDED_TIMER, 0)
    
    -- Keep score at 000000 (3 bytes)
    write_u8(ADDR.SCORE, 0)
    write_u8(ADDR.SCORE + 1, 0)
    write_u8(ADDR.SCORE + 2, 0)
    
    emu.frameadvance()
end
