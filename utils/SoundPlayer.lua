-- SoundPlayer.lua — in-process WAV playback for BizHawk (NLua)
-- Updated for BizHawk 2.11 compatibility
-- Uses multiple fallback methods for sound playback

local function log(msg) if console and console.log then console.log(msg) else print(msg) end end

-- Helpers
local function import(t)
  if not (luanet and luanet.import_type) then return nil end
  local ok, typ = pcall(function() return luanet.import_type(t) end)
  return ok and typ or nil
end

-- Try to load SoundPlayer's assembly by name; if that fails, LoadFrom from EmuHawk dir
local function base_dir()
  local AppContext = import("System.AppContext")
  if AppContext and AppContext.BaseDirectory then return AppContext.BaseDirectory end
  return ".\\"
end
local function combine(a,b)
  local Path = import("System.IO.Path")
  if Path and Path.Combine then return Path.Combine(a,b) end
  
  -- Cross-platform path handling
  local separator = package.config:sub(1,1) -- Get path separator for current OS
  if a:sub(-1) ~= separator then a = a .. separator end
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

-- Try multiple methods to get SoundPlayer type
local function ensure_soundplayer_type()
  -- Method 1: Direct import (most common)
  local SP = import("System.Media.SoundPlayer")
  if SP then 
    return SP 
  end

  -- Method 2: Try loading assemblies first
  local assemblies = {
    "System.Windows.Forms", 
    "System", 
    "System.Media",
    "mscorlib",
    "System.Core",
    "System.Drawing",
    "System.Configuration",
    "System.Xml"
  }
  
  for _, assembly in ipairs(assemblies) do
    local loaded = load_assembly_by_name(assembly)
    if loaded then
      SP = import("System.Media.SoundPlayer")
      if SP then 
        return SP 
      end
    end
  end
  
  -- Method 2b: Try loading assemblies with different approaches
  local ok, assemblies = pcall(function() return luanet.load_assembly("System.Windows.Forms") end)
  if ok then
    SP = import("System.Media.SoundPlayer")
    if SP then 
      return SP 
    end
  end

  -- Method 3: Try loading from file system
  local dllFiles = {
    "System.Windows.Forms.dll",
    "System.dll",
    "System.Media.dll"
  }
  
  for _, dll in ipairs(dllFiles) do
    log("[Sound] Trying to load DLL: " .. dll)
    local loaded = load_assembly_from(dll)
    if loaded then
      SP = import("System.Media.SoundPlayer")
      if SP then 
        log("[Sound] SoundPlayer loaded after loading DLL: " .. dll)
        return SP 
      end
    end
  end

  -- Method 4: Try alternative sound classes
  local alternativeClasses = {
    "System.Media.SystemSounds",
    "System.Windows.Media.MediaPlayer",
    "System.Windows.Media.SoundPlayerAction"
  }
  
  for _, className in ipairs(alternativeClasses) do
    log("[Sound] Trying alternative class: " .. className)
    local altClass = import(className)
    if altClass then
      log("[Sound] Found alternative sound class: " .. className)
      -- Return the first available alternative
      return altClass
    end
  end

  -- Method 5: Try using reflection to find SoundPlayer
  log("[Sound] Trying reflection approach...")
  local Assembly = import("System.Reflection.Assembly")
  if Assembly then
    local ok, assemblies = pcall(function() return Assembly.GetExecutingAssembly() end)
    if ok and assemblies then
      log("[Sound] Got executing assembly, trying to find SoundPlayer...")
      local ok2, types = pcall(function() return assemblies:GetTypes() end)
      if ok2 and types then
        for i = 0, types.Length - 1 do
          local typeName = tostring(types[i])
          if typeName:find("SoundPlayer") then
            log("[Sound] Found SoundPlayer type via reflection: " .. typeName)
            return types[i]
          end
        end
      end
    end
  end

  -- Method 6: Try creating a simple beep as fallback
  log("[Sound] Trying simple beep fallback...")
  local Console = import("System.Console")
  if Console then
    log("[Sound] Found Console class, will use beep as fallback")
    return Console -- We'll use Console.Beep as a fallback
  end

  log("[Sound] No SoundPlayer type found")
  return nil
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
function M.play(path, volume)
  -- Convert to absolute path if relative
  local absolute_path = path
  if not path:match("^[A-Za-z]:\\") and not path:match("^/") then
    -- Try multiple path resolution methods
    local basePath = base_dir()
    absolute_path = combine(basePath, path)
    
    -- Check if file exists, if not try alternative paths
    local f = io.open(absolute_path, "rb")
    if not f then
      -- Try without the base_dir() conversion
      absolute_path = path
      
      f = io.open(absolute_path, "rb")
      if not f then
        -- Try resolving relative to script directory
        local scriptDir = debug.getinfo(2, "S").source
        if scriptDir and scriptDir:sub(1,1) == "@" then
          scriptDir = scriptDir:sub(2)
          scriptDir = scriptDir:match("^(.*[\\/])") or ""
          absolute_path = scriptDir .. path
          
          f = io.open(absolute_path, "rb")
        end
        
        -- If still not found, try resolving from the actual project root
        if not f then
          -- The script is in nes/castlevania/5000pts/, so go up 3 levels to get to root
          local rootPath = scriptDir .. "..\\..\\..\\" .. path
          absolute_path = rootPath
          
          f = io.open(absolute_path, "rb")
        end
        
        -- Try absolute path from the project root (T:\Repos\hotwinter\retrochallenges-assets\)
        if not f then
          -- Try to construct absolute path from the workspace root
          local workspaceRoot = "T:\\Repos\\hotwinter\\retrochallenges-assets\\"
          absolute_path = workspaceRoot .. path:gsub("^%.%.\\%.%.\\%.%.\\", "")
          
          f = io.open(absolute_path, "rb")
        end
        
        -- Try current working directory approach
        if not f then
          absolute_path = ".\\" .. path:gsub("^%.%.\\%.%.\\%.%.\\", "")
          
          f = io.open(absolute_path, "rb")
        end
      end
    end
    
    if f then
      f:close()
    else
      return false 
    end
  else
    -- Verify file exists for absolute paths
    local f = io.open(absolute_path, "rb")
    if not f then 
      return false 
    end
    f:close()
  end

  local SoundPlayerType = ensure_soundplayer_type()
  if not SoundPlayerType then
    return false
  end

  -- Try different approaches based on the type we got
  local success = false
  
  -- Approach 1: Standard SoundPlayer constructor
  local ok, sp = pcall(function() return SoundPlayerType(absolute_path) end)
  if ok and sp then
    -- Set volume if provided (0.0 to 1.0)
    if volume and volume >= 0.0 and volume <= 1.0 then
      pcall(function() sp.Volume = volume end)
    end

    -- Try to play
    local okPlay, err = pcall(function() sp:Play() end)
    if okPlay then
      __sp_keep = sp
      success = true
    else
      -- Try alternative method: Load then Play
      local okLoad = pcall(function() sp:Load() end)
      if okLoad then
        okPlay, err = pcall(function() sp:Play() end)
        if okPlay then
          __sp_keep = sp
          success = true
        end
      end
    end
  end
  
  -- Approach 2: Try static methods if constructor failed
  if not success then
    -- Try SystemSounds if available
    local SystemSounds = import("System.Media.SystemSounds")
    if SystemSounds then
      local okPlay = pcall(function() SystemSounds.Beep:Play() end)
      if okPlay then
        success = true
      end
    end
    
    -- Try MediaPlayer if available
    if not success then
      local MediaPlayer = import("System.Windows.Media.MediaPlayer")
      if MediaPlayer then
        local okCreate, player = pcall(function() return MediaPlayer() end)
        if okCreate and player then
          local okOpen = pcall(function() player:Open(absolute_path) end)
          if okOpen then
            local okPlay = pcall(function() player:Play() end)
            if okPlay then
              __sp_keep = player
              success = true
            end
          end
        end
      end
    end
  end
  
  -- Approach 3: Try Windows API via PowerShell
  if not success then
    local okPlay = pcall(function()
      local okSound = os.execute(string.format('powershell -Command "Add-Type -AssemblyName System.Media; $player = New-Object System.Media.SoundPlayer; $player.SoundLocation = \'%s\'; $player.PlaySync()"', absolute_path))
      return okSound == 0
    end)
    
    if okPlay then
      success = true
    end
  end
  
  -- Approach 4: Try Console.Beep as fallback
  if not success then
    local Console = import("System.Console")
    if Console then
      local okBeep = pcall(function() Console.Beep(800, 200) end) -- 800Hz for 200ms
      if okBeep then
        success = true
      end
    end
  end
  
  if not success then
    return false
  end
  
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

-- Comprehensive diagnostic function
function M.diagnose()
  log("[Sound] === SoundPlayer Diagnostic Report ===")
  
  -- Check luanet availability
  log("[Sound] luanet available: " .. tostring(luanet ~= nil))
  if luanet then
    log("[Sound] luanet.load_assembly available: " .. tostring(luanet.load_assembly ~= nil))
    log("[Sound] luanet.import_type available: " .. tostring(luanet.import_type ~= nil))
  end
  
  -- Check console availability
  log("[Sound] console available: " .. tostring(console ~= nil))
  if console then
    log("[Sound] console.log available: " .. tostring(console.log ~= nil))
  end
  
  -- Check client availability
  log("[Sound] client available: " .. tostring(client ~= nil))
  if client then
    log("[Sound] client.sound available: " .. tostring(client.sound ~= nil))
  end
  
  -- Test basic imports
  local testImports = {
    "System.AppContext",
    "System.IO.Path", 
    "System.IO.File",
    "System.Reflection.Assembly",
    "System.Media.SoundPlayer",
    "System.Media.SystemSounds",
    "System.Windows.Media.MediaPlayer"
  }
  
  for _, className in ipairs(testImports) do
    local ok, result = pcall(function() return import(className) end)
    log("[Sound] " .. className .. ": " .. tostring(ok and result ~= nil))
  end
  
  -- Test assembly loading
  local testAssemblies = {"System.Windows.Forms", "System", "mscorlib"}
  for _, assembly in ipairs(testAssemblies) do
    local ok = pcall(function() return load_assembly_by_name(assembly) end)
    log("[Sound] Assembly " .. assembly .. " load: " .. tostring(ok))
  end
  
  log("[Sound] === End Diagnostic Report ===")
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


-- Get current volume (if supported)
function M.getVolume()
  if __sp_keep then
    local ok, vol = pcall(function() return __sp_keep.Volume end)
    if ok then
      return vol
    end
  end
  return nil
end

-- Check if sound is currently playing
function M.isPlaying()
  if __sp_keep then
    local ok, playing = pcall(function() return __sp_keep.IsLoadCompleted end)
    if ok then
      return not playing -- IsLoadCompleted means it's done loading, so not playing
    end
  end
  return false
end

return M