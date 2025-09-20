# Castlevania RAM Information

This document contains detailed RAM mapping information for the original Castlevania game on the Nintendo Entertainment System (NES).

## Attribution

**Data Source**: This RAM information was originally compiled and documented by [datacrystal](https://datacrystal.romhacking.net/). We encourage you to visit their website for comprehensive ROM hacking resources, documentation, and tools for classic games.

Visit datacrystal at: https://datacrystal.romhacking.net/

---

## RAM Address Reference

| Address | Size | Description |
|---------|------|-------------|
| $0012 | 02 | Various<br/>CHR Data Pointer<br/>&nbsp;&nbsp;&nbsp;&nbsp;Points to CHR data, stored as follows:<br/>&nbsp;&nbsp;&nbsp;&nbsp;byte 0 = value for $0027; byte 1-2 = CHR data RAM address;<br/>&nbsp;&nbsp;&nbsp;&nbsp;byte 3-4 = PPU write address; byte 5-6 = data size |
| $0018 | | System State<br/>&nbsp;&nbsp;&nbsp;&nbsp;00 = Booting; 01 = Title Screen; 02 = Demo Mode; 03 = Start Game;<br/>&nbsp;&nbsp;&nbsp;&nbsp;04 = Introduction; 05 = Gameplay; 06 = Respawning; 07 = Game Over;<br/>&nbsp;&nbsp;&nbsp;&nbsp;08 = Door Transition; 09 = Autowalk; 0a = Entering Castle; 0b = Autoclimb;<br/>&nbsp;&nbsp;&nbsp;&nbsp;0c = Scoring & Map; 0d = Continue; 0e = Falling; 0f = Ending |
| $0019 | | System Substate |
| $001A | | Frame Counter (resets to 01 when changing rooms) |
| $001B | | Graphics Enabled |
| $001D | | Transition Timer (used for autowalk sequences, death animation, and loading rooms) |
| $001E | | Title Screen Bat State |
| $001F | | Fade-in Timer |
| $0020 | | Tile Data Pointer |
| $0022 | | User Paused |
| $0024 | | Current ROM Bank |
| $0027 | | Previous ROM Bank |
| $0028 | | Stage |
| $0029 | | Previous Stage |
| $002A | | Lives (01 = last life, can be set to #ff but displays as 99 max) |
| $002B | | Difficulty |
| $002C | | Score Target (grants 1Up when equal to $07FE, then increments by 3) |
| $002D | | View Position Subpixel |
| $002E | 02 | View Position |
| $0035 | | Rightmost Tile Section |
| $0036 | | Leftmost Tile Section |
| $0037 | 02 | Tile Map 1 Address |
| $0039 | 02 | Tile Map 2 Address |
| $003B | | Tile Refresh Cutoff (toggles #20 every 32 pixels view moves) |
| $003C | | Scroll State<br/>&nbsp;&nbsp;&nbsp;&nbsp;bit 0 = scroll right; bit 1 = scroll left; bit 2 = at room edge |
| $003D | | Scroll Speed Subpixel |
| $003E | | Off Stairs (always 00 at start of frame) |
| $003F | | Simon Real Y-Coordinate |
| $0040 | 02 | Simon X-Coordinate Copy (for solid collisions) |
| $0042 | 02 | Timer |
| $0044 | | Simon Display Health (adjusts every 4 frames to match $0045) |
| $0045 | | Simon Real Health |
| $0046 | | Floor (for stages with stair transitions) |
| $0047 | | Stun Timer (when hit by enemies) |
| $0048 | | Boss Screen (locks scrolling) |
| $0049 | | Rightward Scroll Speed |
| $004A | | Music Continuity (00 = load new BGM after stair & gate transitions) |
| $004B | | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Y-coordinate offset for solid collision<br/>&nbsp;&nbsp;&nbsp;&nbsp;Whip Collision Object<br/>&nbsp;&nbsp;&nbsp;&nbsp;Sprite Mirrored copy for rendering<br/>&nbsp;&nbsp;&nbsp;&nbsp;Subweapon ID ($015B - #08)<br/>&nbsp;&nbsp;&nbsp;&nbsp;Display Health copy for adjusting health bars gradually<br/>&nbsp;&nbsp;&nbsp;&nbsp;Crusher Y-Offset |
| $004C | | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;X-coordinate offset for solid collision<br/>&nbsp;&nbsp;&nbsp;&nbsp;Sprite Data Low Byte<br/>&nbsp;&nbsp;&nbsp;&nbsp;Enemy Drops Low Byte (indexed by [Stage-1]/3)<br/>&nbsp;&nbsp;&nbsp;&nbsp;Collision Width (max horizontal distance in collision check)<br/>&nbsp;&nbsp;&nbsp;&nbsp;Tile Solidity<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;40 = #5F<Tile ID<#6C; 80 = Tile ID is #66 |
| $004D | | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Sprite Data High Byte<br/>&nbsp;&nbsp;&nbsp;&nbsp;Enemy Drops High Byte<br/>&nbsp;&nbsp;&nbsp;&nbsp;Collision Height (max vertical distance in collision check) |
| $004E | | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Tile Position Iterator (when loading new tiles)<br/>&nbsp;&nbsp;&nbsp;&nbsp;Current Instance ID<br/>&nbsp;&nbsp;&nbsp;&nbsp;Current Crusher ID |
| $004F | | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Potential Spawner Pointer<br/>&nbsp;&nbsp;&nbsp;&nbsp;Off-screen Attribute Overflow<br/>&nbsp;&nbsp;&nbsp;&nbsp;Crusher Sequence ($001A - $004E) |
| $0051 | | Scroll Attribute Mask (ref. $0300)<br/>&nbsp;&nbsp;&nbsp;&nbsp;00 = scrolled right; ff = scrolled left |
| $0052 | | Scroll Speed |
| $0053 | | Scroll Speed subpixel |
| $005B | | Wounded Timer (for iFrames) |
| $005F | | Simon Height |
| $0063 | | Ghoul Counter (spaces Ghouls apart in Stages 01 & 20) |
| $0064 | | Weapon Multiplier |
| $006D | | Spawn Area To Load ($0075-5 or $0076+5) |
| $006F | | Randomizer |
| $0070 | | Whip Level |
| $0071 | | Hearts |
| $0072 | | Subweapon Dropped (prevents multiple subweapons dropping) |
| $0073 | | Whip Length |
| $0074 | | Whip Height |
| $0075 | | Leftward Stage Spawn Zone |
| $0076 | | Rightward Stage Spawn Zone |
| $0079 | | Subweapon Kills (until Multiplier drop) |
| $007B | | Enemy Drops ($007B & 3 determines item, ref. $004C) |
| $007D | | Invincibility Potion Timer (unused, game uses $005B instead) |
| $007F | | Ignore Sound Effect Request |
| $0080 | | Square Wave 1 Duration |
| $0081 | | Square Wave 1 Octave |
| $0082 | | Square Wave 1 Track |
| $0083 | 02 | Square Wave 1 Note Address |
| $0085 | | Square Wave 1 Volume Envelope |
| $0087 | | Square Wave 1 Volume Write |
| $0088 | | Square Wave 1 Halt |
| $0089 | | Square Wave 1 Next Duration |
| $008A | | Square Wave 1 Timbre |
| $008B | | Square Wave 1 Fade Delay |
| $008C | | Square Wave 1 Fade |
| $008D | | Square Wave 1 Fade Speed |
| $008E | 02 | Square Wave 1 Loop Address |
| $0090 | | Square Wave 2 Duration |
| $0091 | | Square Wave 2 Octave |
| $0092 | | Square Wave 2 Track |
| $0093 | 02 | Square Wave 2 Note Address |
| $0095 | | Square Wave 2 Volume Envelope |
| $0097 | | Square Wave 2 Volume Write |
| $0098 | | Square Wave 2 Halt |
| $0099 | | Square Wave 2 Next Duration |
| $009A | | Square Wave 2 Timbre |
| $009B | | Square Wave 2 Fade Delay |
| $009C | | Square Wave 2 Fade |
| $009D | | Square Wave 2 Fade Speed |
| $009E | 02 | Square Wave 2 Loop Address |
| $00A0 | | Triangle Wave Duration |
| $00A1 | | Triangle Wave Octave |
| $00A2 | | Triangle Wave Track |
| $00A3 | 02 | Triangle Wave Note Address |
| $00A5 | | Triangle Wave Linear Counter |
| $00A7 | | Audio Timer Low copy 1 |
| $00A9 | | Triangle Wave Next Duration |
| $00AB | | Audio Channel Index<br/>&nbsp;&nbsp;&nbsp;&nbsp;80 = Square 1; 90 = Square 2; A0 = Triangle<br/>&nbsp;&nbsp;&nbsp;&nbsp;B0 = Noise; C0 = Square 1 SFX; D0 = Square 2 SFX |
| $00AC | | Audio Channel Offset |
| $00AE | 02 | Triangle Wave Loop Address |
| $00B0 | | Noise Duration |
| $00B1 | | Noise Octave? |
| $00B2 | | Noise Track |
| $00B3 | 02 | Noise Note Address |
| $00B7 | | Noise Volume |
| $00B8 | | Audio Timer Low copy 2 |
| $00BA | 02 | Working Note Address (used by all channels) |
| $00BC | | Audio Timer Hi |
| $00BD | | Audio Timer Low |
| $00BE | 02 | Updated Note Address (same as $0083, $0093, $00A3, and $00B3) |
| $00C0 | | Square Wave 1 SFX Duration |
| $00C1 | | Square Wave 1 SFX Octave |
| $00C2 | | Square Wave 1 SFX Track |
| $00C3 | 02 | Square Wave 1 SFX Note Address |
| $00C5 | | Square Wave 1 SFX Volume Envelope |
| $00C7 | | Square Wave 1 SFX Volume Write |
| $00C8 | | Square Wave 1 SFX Halt |
| $00C9 | | Square Wave 1 SFX Next Duration |
| $00CA | | Square Wave 1 SFX Timbre |
| $00CB | | Square Wave 1 SFX Fade Delay |
| $00CC | | Square Wave 1 SFX Fade |
| $00CD | | Square Wave 1 SFX Fade Speed |
| $00CE | 02 | Square Wave 1 SFX Loop Address |
| $00D0 | | Square Wave 2 SFX Duration |
| $00D1 | | Square Wave 2 SFX Octave |
| $00D2 | | Square Wave 2 SFX Track |
| $00D3 | 02 | Square Wave 2 SFX Note Address |
| $00D5 | | Square Wave 2 SFX Volume Envelope |
| $00D7 | | Square Wave 2 SFX Volume Write |
| $00D8 | | Square Wave 2 SFX Halt |
| $00D9 | | Square Wave 2 SFX Next Duration |
| $00DA | | Square Wave 2 SFX Timbre |
| $00DB | | Square Wave 2 SFX Fade Delay |
| $00DC | | Square Wave 2 SFX Fade |
| $00DD | | Square Wave 2 SFX Fade Speed |
| $00DE | 02 | Square Wave 2 SFX Loop Address |
| $00E0 | 02 | Audio Track Address |
| $00E2 | | Audio Fade-Out |
| $00E3 | | Audio Fade-Out Timer |
| $00E4 | | Audio Track Offset |
| $00E5 | | Audio Track |
| $00E6 | | Channel Pointer Alternate |
| $00E7 | | Channel Pointer |
| $00EE | | Stopwatch Mute |
| $00EF | | Pause Music |
| $00F1 | 02 | Demo Behavior Address |
| $00F3 | | Demo Cycle (determines stage and behavior) |
| $00F4 | | Demo Mode |
| $00F5 | | Gamepad 1 Input Pressed |
| $00F6 | | Gamepad 2 Input Pressed |
| $00F7 | | Gamepad 1 Input Held |
| $00F8 | | Gamepad 2 Input Held |
| $00FC | 02 | PPU Scroll |
| $00FE | | PPU Mask (to change colors or disable sprites) |
| $00FF | | PPU Control |
| $0143 | | Fall Distance (stuns if greater than 7 when landing) |
| $0144 | | Secrets Found (per stage) |
| $0145 | | Secret Timer (how long Simon stands still) |
| $0146 | | Blocks Broken |
| $014A | 03 | Crusher State<br/>&nbsp;&nbsp;&nbsp;&nbsp;bit 0 = active; bit 2 = pause all crushers; bit 3 = falling |
| $014D | 03 | Crusher Y-Coordinate (top of chain) |
| $0150 | 03 | Crusher X-Coordinate Low |
| $0153 | 03 | Crusher X-Coordinate High |
| $0156 | 03 | Crusher Position<br/>&nbsp;&nbsp;&nbsp;&nbsp;bits 0-3 = vertical-offset, multiplied by 8;<br/>&nbsp;&nbsp;&nbsp;&nbsp;bits 4-7 = return position ($0156 >> 4 = $004B) |
| $015B | | Subweapon<br/>&nbsp;&nbsp;&nbsp;&nbsp;08 = Dagger; 09 = Boomerang; 0A = Rosary (cut);<br/>&nbsp;&nbsp;&nbsp;&nbsp;0B = Holy Water; 0D = Axe; 0F = Stopwatch |
| $015C | | Subweapons Locked |
| $015D | | Rosary Flash |

### Spawners indexed by position in room, modulo 06

| Address | Size | Description |
|---------|------|-------------|
| $0160 | 06 | Spawner Disabled |
| $0166 | 06 | Spawner Object |
| $016C | 06 | Spawner State |
| $0172 | 06 | Spawner X-Coordinate |
| $017E | 06 | Spawner Y-Coordinate |
| $0184 | 06 | Spawner Timer |
| $0190 | 0f | Candle Status<br/>&nbsp;&nbsp;&nbsp;&nbsp;0f = upper floor destroyed; f0 = lower floor destroyed |
| $01A9 | | Boss Real Health |
| $01AA | | Boss Display Health |
| $0200 | ff | OAM Data |

### Instances typically ordered as follows:

**Gameplay:**
- 00 = Simon; 01-02 = Whip; 03-0d = Enemies; 0e-13 = Candles;
- 14-16 = Subweapons; 17 = Hidden Treasure; 17-18 = Moving Platforms;
- 18-1b = Debris (deliberately handled even while game is paused)

**Title Screen:**
- 00 = Bat; 01 = "C" Top; 02 = "C" Bottom

**Gate Screen:**
- 00 = Simon; 01 = Cloud; 02 = Left Bat; 03 = Right Bat

**Map Screen:**
- 00 = Simon; 17 = Map Position; 18 = Target Position;

| Address | Size | Description |
|---------|------|-------------|
| $0300 | 1c | Attributes<br/>&nbsp;&nbsp;&nbsp;&nbsp;bit 0 = In-view; bit 7 = Invisible |
| $031C | 1c | Sprite Frame |
| $0338 | 1c | Pallet Offset |
| $0354 | 1c | Y-Coordinate |
| $0370 | 1c | Y-Coordinate Subpixel |
| $038C | 1c | X-Coordinate |
| $03A8 | 1c | X-Coordinate Subpixel |
| $03C4 | 1c | Vertical Speed |
| $03E0 | 1c | Vertical Speed Subpixel |
| $03FC | 1c | Horizontal Speed |
| $0418 | 1c | Horizontal Speed Subpixel |
| $0434 | 1c | Object Index<br/>&nbsp;&nbsp;&nbsp;&nbsp;Simon's Objects (just another state machine):<br/>&nbsp;&nbsp;&nbsp;&nbsp;00 = Passive; 01 = Standing Whip (and on stairs); 02 = Ducking Whip;<br/>&nbsp;&nbsp;&nbsp;&nbsp;03 = Jumping Whip; 81 = Standing Subweapon; 83 = Jumping Subweapon |
| $0450 | 1c | Sprite Mirrored |
| $046C | 1c | State<br/>&nbsp;&nbsp;&nbsp;&nbsp;Simon's States:<br/>&nbsp;&nbsp;&nbsp;&nbsp;00 = Walking; 01 = Jumping (and Air Attack); 02 = Ground Attack;<br/>&nbsp;&nbsp;&nbsp;&nbsp;03 = Ducking; 04 = Climbing Stairs; 05 = Knocked Back;<br/>&nbsp;&nbsp;&nbsp;&nbsp;06 = Approach Stairs; 07 = Dropping; 08 = Dead; 09 = Stunned; |
| $0488 | | Jump State |
| $0489 | 1b | Animation Time |
| $049F | | Moving Platform Speed (doubles per speed) |
| $04A4 | | Simon Step Count (determines walking sprite frame) |
| $04A5 | 1b | Animation Frame |
| $04C0 | 1c | Sprite Index |
| $04C2 | | Gate Bats Animation Timer (changes image every 4 frames) |
| $04C3 | | Gate Right Bat Bob Timing |
| $04DC | | Vertical Vector Address Low Byte |
| $04DF | 0b | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Bat & Medusae Base Focal Y-coordinate<br/>&nbsp;&nbsp;&nbsp;&nbsp;Simon above enemy<br/>&nbsp;&nbsp;&nbsp;&nbsp;Skeleton Motion Substate<br/>&nbsp;&nbsp;&nbsp;&nbsp;Fishman walking<br/>&nbsp;&nbsp;&nbsp;&nbsp;Bone Dragon Part Motion Substate<br/>&nbsp;&nbsp;&nbsp;&nbsp;Axe Armor Axe ID<br/>&nbsp;&nbsp;&nbsp;&nbsp;Gate Right Bat Bob Offset (add to $0533) |
| $04EA | 06 | Candle Index (for $0190,Y writes) |
| $04F0 | 03 | Subweapon Collision ID |
| $04F8 | | Vertical Vector Address High Byte |
| $04FB | 11 | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Movement Direction for moving backward<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;00 = right; 01 = left;<br/>&nbsp;&nbsp;&nbsp;&nbsp;Bone Dragon Part Vertical Offset<br/>&nbsp;&nbsp;&nbsp;&nbsp;Drop Pickup Delay (pointless) |
| $050C | 03 | Individual Subweapon Kills |
| $050F | 04 | Moving Platform X-Coordinate Subpixel |
| $0514 | | Vertical Direction |
| $0517 | 11 | Various<br/>&nbsp;&nbsp;&nbsp;&nbsp;Small Heart Focal X-coordinate<br/>&nbsp;&nbsp;&nbsp;&nbsp;Bone Dragon Part Vertical Offset Subpixel |
| $052B | | Moving Platform Left Edge |
| $0530 | | Simon Attack State (same as $046C) |
| $0531 | 15 | Spawner ID (based on 6 room positions) |
| $0533 | | Gate Right Bat Y-Origin |
| $054C | | In-Air Attack |
| $054F | 0d | Generic Timer |
| $0568 | | Whip Timer (counts up to #16) |
| $056B | 11 | Extinguish Timer (duration of flare and drop)<br/>&nbsp;&nbsp;&nbsp;&nbsp;For subweapons:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Boomerang = return time; Holy Water = burn duration |
| $057F | 02 | Moving Platform Y-coordinate Subpixel |
| $0582 | | Hidden Treasure Object<br/>&nbsp;&nbsp;&nbsp;&nbsp;00 = Coins; 01 = 1UP; 02 = Crown; 03 = Chest; 04 = Moai |
| $0584 | | Gamepad 1 Input Held Copy |
| $0587 | 11 | Item Drop |
| $059B | 02 | Moving Platform Y-Coordinate |
| $05A0 | 160 | Collision Map |
| $0700 | c0 | Tile Data Dump |
| $07F5 | | Previous Y Register (when audio loaded) |
| $07F6 | | Next Sound Effect |
| $07F8 | | Demo Gamepad Input Delay |
| $07F9 | | Demo Gamepad Input Pressed |
| $07FA | | Demo Gamepad Input Held |
| $07FC | 03 | Score ($07FE used for 1UP checks) |

---

*This documentation is based on research and analysis by the datacrystal community. For more ROM hacking resources and documentation, visit [datacrystal.romhacking.net](https://datacrystal.romhacking.net/).*
