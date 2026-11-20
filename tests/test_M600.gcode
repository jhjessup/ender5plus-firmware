; Pause test for Ender-5 Plus: tests "M600". No heating, no extrusion.
; Print from the SD card and watch the screen.
M117 Homing
G28                 ; home all axes
G90
G1 Z30 F600         ; lower the bed 30 mm
G1 X150 Y150 F3000  ; move to the middle
M117 Pausing with M600
G4 S3               ; wait 3 s so you can read the screen
M600
; ---- after the pause ----
M117 Resumed OK
G1 X20 Y20 F3000    ; move to a corner: this means it resumed (or never paused)
G4 S3
G1 X150 Y150 F3000
M117 Test finished
M84                 ; motors off
