Repository: retrochallenges-assets — guidance for automated coding agents

- Purpose: This repo stores shared assets, save states and Lua helper scripts used by RetroChallenges (BizHawk / NES scripts). Changes must preserve binary assets and Lua script conventions used by emulator scripts (paths, savestate names, image filenames).

- Big picture
  - Top-level layout: `assets/` (shared images/audio), `utils/` (Lua helpers), `nes/<game>/<challenge>/` (challenge scripts and savestates). See `readme.md` for structure.
  - Challenges are designed as BizHawk Lua scripts that open ROMs, load savestates and draw GUI overlays. Examples: `nes/castlevania/challengebossrush/bossrush.lua` and utility modules in `utils/`.

- What you can change safely
  - Edit or add Lua modules inside `utils/` and challenge scripts under `nes/` as long as you preserve required asset filenames (`images/` names used by `gametimer.lua` and `bossrush.lua`) and savestate names listed in `bosses` tables.
  - Update `challenges.json` only via the canonical build process (see Build section) — avoid hand-editing unless updating metadata only.

- What to avoid or be careful with
  - Do not modify or remove binary assets in `assets/` or files in `nes/*/savestates/` unless intentionally replacing them; these are referenced by exact filenames from Lua scripts.
  - Keep path helpers and package.path usage intact. Many scripts depend on script-relative paths (see `bossrush.lua` script_dir() + PATH table).

- Project-specific conventions & patterns
  - Script directory discovery: patterns use debug.getinfo(1, "S").source and expect `..\` relative roots. Preserve leading/trailing slashes and Windows path separators where present.
  - Memory domain helpers: scripts call memory.getmemorydomainlist/usememorydomain and fallback read/write names (read_u8/write_u8). Follow the same compatibility checks when adding memory reads/writes.
  - Image-driven HUD: `utils/gametimer.lua` reads specific image filenames from an `../images/` folder (e.g., `_sSmall0blue.png`). New timers or HUDs should reuse these images or add new ones under `assets/` and reference them by exact filename.
  - Sound use: `utils/SoundPlayer.lua` uses luanet and BizHawk host assemblies. Only attempt to play audio when SoundPlayer.available() returns truthy; otherwise, fallback/no-op.

- Build, test and run (developer workflows)
  - The repo README mentions a build script. Preferred methods to regenerate `challenges.json`:
    - PowerShell: `./build-challenges.ps1`
    - Node: `node build-challenges.js`
  - Local testing: run BizHawk and open Lua scripts (e.g., open `bossrush.lua`) from BizHawk's Lua console. Scripts assume ROMs are present in `roms/` relative to the challenge root; update `PATH.roms` in scripts or add ROMs locally.
  - Debugging: scripts write to `console.log(...)` and use `gui.drawImage`, `savestate.load`, and `emu.frameadvance()` loops. Use BizHawk's console and frame-stepping for troubleshooting.

- Integration points & external dependencies
  - BizHawk emulator environment (Lua + luanet). Scripts rely on BizHawk globals: `client`, `memory`, `gui`, `savestate`, `emu`, `input`, `console`.
  - Windows .NET assemblies may be loaded via `luanet` in `SoundPlayer.lua`. Changes that touch SoundPlayer should keep the defensive import/load logic.
  - `challenges.json` is the primary metadata file used by external tooling — prefer the build script to keep it consistent.

- Helpful quick references (examples)
  - Path helper + package.path pattern: see `nes/castlevania/challengebossrush/bossrush.lua` (script_dir(), PATH table, package.path concatenation).
  - Timer image filenames: `utils/gametimer.lua` expects `_sSmall0blue.png` .. `_sSmall9blue.png` and `_sSmallSemiblue.png` in `images/` relative to a challenge.
  - Boss list format: `bosses = { { name="Bat", state=save("Castlevania.Bat.Boss.state"), sub="Dagger", mult="Triple", intermission=45 }, ... }` — new challenge scripts may follow this pattern for entries referencing savestate files.

- When to ask the human
  - If a change will rename or remove any asset filename in `assets/` or `nes/*/savestates/`.
  - If you need to add CI, new build automation, or change how `challenges.json` is generated.
  - If a change touches `SoundPlayer.lua` or relies on loading .NET assemblies.

If anything here is unclear or you want the instructions expanded (CI commands, preferred editor/formatter, or examples for adding a new challenge), tell me which section to expand.