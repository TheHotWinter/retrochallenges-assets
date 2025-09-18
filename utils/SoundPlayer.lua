-- SoundPlayer.lua — in-process WAV playback for BizHawk (NLua)
-- Uses luanet.load_assembly + luanet.import_type, no Activator, no shell.

local function log(msg) if console and console.log then console.log(msg) else print(msg) end end

-- Helpers
local function import(t)
  if not (luanet and luanet.import_type) then return nil end
  local ok, typ = pcall(function() return luanet.import_type(t) end)
  return ok and typ or nil
end

-- Try to load SoundPlayer’s assembly by name; if that fails, LoadFrom from EmuHawk dir
local function base_dir()
  local AppContext = import("System.AppContext")
  if AppContext and AppContext.BaseDirectory then return AppContext.BaseDirectory end
  return ".\\"
end
local function combine(a,b)
  local Path = import("System.IO.Path")
  if Path and Path.Combine then return Path.Combine(a,b) end
  if a:sub(-1) ~= "\\" and a:sub(-1) ~= "/" then a = a .. "\\" end
  return a .. b
end
local function file_exists(p)
  local File = import("System.IO.File")
  return File and File.Exists and File.Exists(p)
end
local function load_assembly_by_name(name)
  if not (luanet and luanet.load_assembly) then return false end
  local ok = pcall(luanet.load_assembly, name); return ok
end
local function load_assembly_from(dllName)
  local Assembly = import("System.Reflection.Assembly")
  if not Assembly then return false end
  local p = combine(base_dir(), dllName)
  if not file_exists(p) then return false end
  local ok = pcall(function() Assembly.LoadFrom(p) end)
  return ok
end

-- Ensure SoundPlayer type is available
local function ensure_soundplayer_type()
  -- already available?
  local SP = import("System.Media.SoundPlayer")
  if SP then return SP end

  -- try different assemblies that might contain SoundPlayer
  local assemblies = {"System.Windows.Forms", "System", "System.Media"}
  for _, assembly in ipairs(assemblies) do
    load_assembly_by_name(assembly)
    SP = import("System.Media.SoundPlayer")
    if SP then return SP end
  end

  -- final: LoadFrom local dll then import again
  load_assembly_from("System.Windows.Forms.dll")
  SP = import("System.Media.SoundPlayer")
  return SP
end

-- Keep a reference so GC doesn't stop playback
local __sp_keep = nil

local M = {}

function M.available()
  local sp = ensure_soundplayer_type()
  log("[Sound] SoundPlayer available: " .. tostring(sp ~= nil))
  return sp and "SoundPlayer" or nil
end

-- Play WAV asynchronously. Pass absolute or relative path.
function M.play(path)
  log("[Sound] Attempting to play: " .. tostring(path))
  
  -- Convert to absolute path if relative
  local absolute_path = path
  if not path:match("^[A-Za-z]:\\") and not path:match("^/") then
    absolute_path = combine(base_dir(), path)
    log("[Sound] Converted to absolute path: " .. absolute_path)
  end

  -- Verify file exists
  local f = io.open(absolute_path, "rb")
  if not f then 
    log("[Sound] ERROR: File not found: " .. absolute_path)
    return false 
  end
  f:close()

  local SoundPlayer = ensure_soundplayer_type()
  if not SoundPlayer then
    log("[Sound] ERROR: SoundPlayer type not available")
    return false
  end
  log("[Sound] SoundPlayer type loaded successfully")

  -- Use the string constructor
  local ok, sp = pcall(function() return SoundPlayer(absolute_path) end)
  if not (ok and sp) then
    log("[Sound] ERROR: SoundPlayer constructor failed")
    return false
  end
  log("[Sound] SoundPlayer instance created")

  -- Try to play
  local okPlay, err = pcall(function() sp:Play() end)
  if not okPlay then
    log("[Sound] ERROR: Play() failed: " .. tostring(err))
    
    -- Try alternative method: Load then Play
    local okLoad = pcall(function() sp:Load() end)
    if okLoad then
      log("[Sound] Load() succeeded, trying Play() again")
      okPlay, err = pcall(function() sp:Play() end)
      if not okPlay then
        log("[Sound] ERROR: Second Play() attempt failed: " .. tostring(err))
        return false
      end
    else
      log("[Sound] ERROR: Load() also failed")
      return false
    end
  end

  __sp_keep = sp
  log("[Sound] Playback started successfully")
  return true
end

-- Stop any currently playing sound
function M.stop()
  if __sp_keep then
    local ok, err = pcall(function() __sp_keep:Stop() end)
    if not ok then
      log("[Sound] ERROR: Stop() failed: " .. tostring(err))
      return false
    end
    log("[Sound] Playback stopped")
    __sp_keep = nil
    return true
  end
  return false
end

-- Test function
function M.test()
  log("[Sound] Running availability test...")
  local available = M.available()
  if available then
    log("[Sound] SoundPlayer is available: " .. available)
    return true
  else
    log("[Sound] SoundPlayer is NOT available")
    return false
  end
end

return M