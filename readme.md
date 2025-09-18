# RetroChallenges Assets

This repository contains all the assets for RetroChallenges challenges.

## 📁 Repository Structure

```
retrochallenges-assets/
├── assets/                  # Generic assets shared across all challenges
├── utils/                   # Pre-built Lua utility scripts
├── nes/                     # Nintendo Entertainment System challenges
│   └── [game-name]/         # Individual game folder
│       └── [challenge-name]/ # Individual challenge folder
│           ├── main.lua     # Main challenge script
│           ├── assets/      # Challenge-specific assets
│           └── savestates/   # Challenge-specific save states
├── snes/                    # Super Nintendo challenges (future)
└── challenges.json          # Auto-generated challenge configuration
```

## 🎯 How It Works

- **Platform folders** (`nes/`, `snes/`, etc.) organize challenges by console
- **Game folders** contain all challenges for that specific game
- **Challenge folders** contain the main script, assets, and save states
- **Generic assets** (`assets/`) are shared across all challenges
- **Utility scripts** (`utils/`) provide reusable Lua functions

## 📋 Required Files

Each challenge folder must contain:
- `main.lua` - The main challenge script
- `assets/icon.png` - Challenge icon (64x64 or 128x128 pixels)
- `assets/preview.jpg` - Preview image
- `savestates/start.sav` - Starting save state

## 🚀 Adding a New Challenge

1. Create folder: `[platform]/[game]/[challenge-name]/`
2. Add required files: `main.lua`, `assets/`, `savestates/`
3. Run build script to update `challenges.json`

## 🔧 Build Script

Generate `challenges.json` automatically:
```bash
# PowerShell
.\build-challenges.ps1

# Node.js
node build-challenges.js
```

## ⚖️ Legal Notice

This repository does not contain ROMs or copyrighted content. Users must provide their own legally obtained ROMs.

---

**Happy Challenge Creating!** 🎮