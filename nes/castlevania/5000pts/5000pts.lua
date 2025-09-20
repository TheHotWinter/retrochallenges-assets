-- BizHawk Lua script to display "Hello World" on screen
while true do
    gui.text(10, 10, "Hello World")
    emu.frameadvance()
end