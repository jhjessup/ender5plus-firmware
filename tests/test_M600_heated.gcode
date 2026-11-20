; M600 filament-change test for the new firmware. Heats the nozzle (needed to unload).
; Filament must be loaded. Print from the SD card and follow the touchscreen prompts.
M117 Homing
G28
G90
G1 Z30 F600
G1 X150 Y150 F3000
M117 Heating nozzle
M109 S200           ; heat to 200 C and wait (PLA)
M117 Testing M600
M600                ; filament change: follow the screen to unload, load and resume
M117 Resumed OK
G1 X20 Y20 F3000
G4 S3
G1 X150 Y150 F3000
M104 S0             ; nozzle heater off
M117 Test finished
M84
