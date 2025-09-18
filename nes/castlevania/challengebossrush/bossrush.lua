----------------------------------------------------------------
-- BossRush.lua  — Castlevania 1 Boss Rush (BizHawk)
----------------------------------------------------------------

-----------------------
-- ROOT + path helpers
-----------------------
local function script_dir()
  local s = debug.getinfo(1, "S").source
  local p = (s:sub(1,1)=="@" and s:sub(2) or s)
  return (p:match("^(.*[\\/])") or "")
end
local ROOT = script_dir() .. "..\\"

local PATH = {
  roms   = ROOT .. "roms\\",
  images = ROOT .. "images\\",
  audio  = "audio\\",
  saves  = ROOT .. "cv1\\",
  chall  = ROOT .. "challenges\\",
}
local function img(f)  return PATH.images .. f end
local function sfx(f)  return PATH.audio  .. f end
local function save(f) return PATH.saves  .. f end

local function file_exists(p)
  local f = io.open(p,"rb"); if f then f:close(); return true end; return false
end

local GameTimer = require("gametimer")
GameTimer.position = {x = 0, y = 0}
GameTimer.setDigitSpacing(-51)

package.path = PATH.chall .. "?.lua;" .. ROOT .. "?.lua;" .. package.path

-----------------------
-- Open ROM
-----------------------
local ROM = PATH.roms .. "Castlevania.nes"
if file_exists(ROM) then
  client.openrom(ROM)
else
  console.log("ROM not found: "..ROM.." (edit BossRush.lua)")
end

-----------------------
-- Memory domain
-----------------------
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

local read_u8  = memory.read_u8  or memory.readbyte
local write_u8 = memory.write_u8 or memory.writebyte

-----------------------
-- Addresses
-----------------------
local ADDR = {
  SYSTEM_STATE=0x0018, USER_PAUSED=0x0022,
  HEALTH_DISP=0x0044,  HEALTH_REAL=0x0045,
  HEARTS=0x0071,       MULTIPLIER=0x0064,
  SUBWEAPON=0x015B,    SUB_LOCK=0x015C,
  BOSS_HP=0x01A9,      SIMON_STATE=0x046C,
}
local SUB  = { Dagger=0x08, Boomerang=0x09, HolyWater=0x0B, Axe=0x0D, Stopwatch=0x0F }
local MULT = { None=0x00, Double=0x01, Triple=0x02 }

-----------------------
-- Sound
-----------------------
local SoundPlayer = require("SoundPlayer")
if not SoundPlayer.available() then
  console.log("WARNING: SoundPlayer not available - sounds will be disabled")
  SoundPlayer.play = function() return false end
end

-----------------------
-- Watermark
-----------------------
local WATERMARK = img("BossRushWatermark.png")
local function drawWatermark()
  if file_exists(WATERMARK) then gui.drawImage(WATERMARK,0,0) end
end

-----------------------
-- Frame helper
-----------------------
local function frame()
  GameTimer:draw()
  drawWatermark()
  emu.frameadvance()
end

-----------------------
-- Input helpers
-----------------------
local function neutralizeP1()
  joypad.set({A=false,B=false,Start=false,Select=false,Up=false,Down=false,Left=false,Right=false},1)
end
local function forcePauseFrame() write_u8(ADDR.USER_PAUSED,1); neutralizeP1() end
local function releasePause()    write_u8(ADDR.USER_PAUSED,0) end

-----------------------
-- Player setup
-----------------------
local function applyPlayerSetup(subName, multName)
  local MAX_HP = 0x40
  write_u8(ADDR.HEALTH_REAL, MAX_HP)
  write_u8(ADDR.HEALTH_DISP, MAX_HP)
  write_u8(ADDR.HEARTS, 0x63)
  write_u8(ADDR.SUBWEAPON, SUB[subName] or SUB.Dagger)
  write_u8(ADDR.SUB_LOCK, 0x00)
  write_u8(ADDR.MULTIPLIER, MULT[multName or "None"] or MULT.None)
end

-----------------------
-- Countdown
-----------------------
local function countdown_hardpaused()
  gui.clearGraphics()
  local images = {
    { img("3.png"), 60 },
    { img("2.png"), 60 },
    { img("1.png"), 60 },
    { img("go.png"), 120 },
  }
  for i, item in ipairs(images) do
    if i < #images then SoundPlayer.play(sfx("tock.wav")) end
    local path, frames = item[1], item[2]
    for _=1,frames do
      forcePauseFrame()
      if file_exists(path) then gui.drawImage(path,0,0) end
      frame()
    end
  end
  gui.clearGraphics(); forcePauseFrame(); frame()
end

-----------------------
-- HUD refresh
-----------------------
local function forceHudRefresh(desiredSubName)
  local desired = SUB[desiredSubName] or SUB.Dagger
  local alt = (desired ~= SUB.Dagger) and SUB.Dagger or SUB.Boomerang

  neutralizeP1(); write_u8(ADDR.HEARTS,0x62); frame()
  neutralizeP1(); write_u8(ADDR.HEARTS,0x63); write_u8(ADDR.HEALTH_DISP,read_u8(ADDR.HEALTH_REAL)); frame()
  neutralizeP1(); write_u8(ADDR.SUBWEAPON,alt); frame()
  neutralizeP1(); write_u8(ADDR.SUBWEAPON,desired); write_u8(ADDR.HEALTH_DISP,read_u8(ADDR.HEALTH_REAL)); frame()
end

-----------------------
-- Overlays
-----------------------
local function showOK(sec)
  SoundPlayer.play(sfx("golfclap.wav"))
  local frames=math.floor((sec or 2)*60)
  for _=1,frames do if file_exists(img("ok.png")) then gui.drawImage(img("ok.png"),0,0) end; frame() end
  gui.clearGraphics(); frame()
end

local function showFail(sec)
  SoundPlayer.play(sfx("aww.wav")) -- play fail sound
  local frames=math.floor((sec or 3)*60)
  for _=1,frames do if file_exists(img("failed.png")) then gui.drawImage(img("failed.png"),0,0) end; frame() end
  gui.clearGraphics(); frame()
end

-----------------------
-- Retry or Quit screen
-----------------------
local function showRetryOrQuit()
  while true do
    if file_exists(img("retryorquit.png")) then
      gui.drawImage(img("retryorquit.png"), 0, 0)
    end
    GameTimer:draw()
    drawWatermark()

    local keys = input.get()
    if keys["R"] then
      return "retry"
    elseif keys["Escape"] then
      error("User quit the challenge")
    end
    emu.frameadvance()
  end
end

-----------------------
-- Outcome checks
-----------------------
local function bossDefeated() return read_u8(ADDR.BOSS_HP)==0 end
local function playerDied()
  local hp=read_u8(ADDR.HEALTH_REAL); local s=read_u8(ADDR.SIMON_STATE); local g=read_u8(ADDR.SYSTEM_STATE)
  return hp==0 or s==0x08 or g==0x07 or g==0x06
end
local function waitForFightOutcome()
  while true do
    if bossDefeated() then
      GameTimer.stop()
      return "success"
    end
    if playerDied() then
      GameTimer.stop()
      return "death"
    end
    frame()
  end
end

-----------------------
-- Run one boss
-----------------------
local function runBoss(entry)
  local attempt=0
  while true do    
    attempt=attempt+1   

    if not file_exists(entry.state) then console.log("State missing: "..entry.state); return end
    savestate.load(entry.state)
    set_best_domain()
    frame()

    countdown_hardpaused()
    applyPlayerSetup(entry.sub or "Dagger", entry.mult or "None")
    releasePause()
    forceHudRefresh(entry.sub or "Dagger")

    GameTimer.start()

    local outcome=waitForFightOutcome()
    if outcome=="success" then
      showOK(2)
      for _=1,(entry.intermission or 0) do frame() end
      return
    else
      showFail(3)
    end
  end
end

-----------------------
-- Completion sequence
-----------------------
local function showCompletion()
  forcePauseFrame()
  SoundPlayer.play(sfx("challengecompleted.wav"))
  local frames = math.floor(4 * 60)
  for _ = 1, frames do
    if file_exists(img("completed.png")) then gui.drawImage(img("completed.png"), 0, 0) end
    frame()
  end
  gui.clearGraphics(); frame()
end

-----------------------
-- Boss list
-----------------------
bosses = {
  { name="Bat",     state=save("Castlevania.Bat.Boss.state"),     sub="Dagger", mult="Triple", intermission=45 },
  { name="Medusa",  state=save("Castlevania.Medusa.Boss.state"),  sub="Axe",    mult="Double", intermission=45 },
  { name="Mummy",   state=save("Castlevania.Mummy.Boss.state"),   sub="Axe",    mult="Double", intermission=45 },
  { name="Frank",   state=save("Castlevania.Frank.Boss.state"),   sub="Axe",    mult="Double", intermission=45 },
  { name="Death",   state=save("Castlevania.Death.Boss.state"),   sub="Axe",    mult="Double", intermission=45 },
  { name="Dracula", state=save("Castlevania.Dracula.Boss.state"), sub="Axe",    mult="Double", intermission=45 },
  { name="Cookie",  state=save("Castlevania.Cookie.Boss.state"),  sub="Dagger", mult="Triple", intermission=45 },
}

function runBossRush(list)  
  GameTimer.reset() -- reset once at start
  for _, b in ipairs(list) do runBoss(b) end
  console.log("Boss Rush complete.")
  showCompletion()

  local choice = showRetryOrQuit()
  if choice == "retry" then
    console.log("Restarting Boss Rush...")
    runBossRush(list)
  end
end

-- Kick it off:
runBossRush(bosses)
