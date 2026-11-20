# Ender-5 Plus firmware upgrade: InsanityAutomation Marlin 2 (DWIN 7.4.7)

Built for **this printer only**: Ender-5 Plus, V2.2 board (ATmega2560), stock touchscreen,
Micro Swiss direct drive, PTFE-lined hotend (not all-metal), BLTouch, bilinear leveling.

Each stage is short and ends at a safe stopping point. Do them in order.

## Files

| File | What it is |
|---|---|
| `firmware/E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex` | Mainboard firmware |
| `DWIN_SET/` | Touchscreen firmware: run `./build.sh`, then use `build/DWIN_SET/` |
| `tests/test_M600_heated.gcode` | Filament-change test, for after flashing |
| `firmware/SHA256SUMS` | Checksum to confirm the firmware file is intact |

**Build settings:** e-steps 139.61 (your calibrated value), max nozzle temperature 255 °C
(PTFE-lined heatbreak; keep prints at 240 °C or below), BLTouch offset X −45 Y −5 (Micro Swiss default), filament change (`M600`) on,
filament-change lengths for direct drive (125 mm), run-out sensor **off** until you fit one.

Source: InsanityAutomation/Marlin, branch `CrealityDwin_2.0`, commit
`0766fcd082174ad38f1fbd954e964342393e7ff6`.

---

## Stage A: Prepare (nothing on the printer changes)

1. **Keep a way back.** Download the stock firmware for your printer from Creality
   (https://creality3dofficial.com/blogs/firmware-download/ender-5-plus) and keep it with
   these files. You can flash it the same way if you ever need to go back.
2. **Check the file:** in `firmware/`, run `sha256sum -c SHA256SUMS`. It should say `OK`.
3. **Install the flashing tool:** `sudo apt install avrdude`
4. **Prepare a microSD card** (8 GB or smaller works best). It must be FAT32. Most small cards
   already are. If the touchscreen update fails later, reformat it with 4096-byte clusters.
5. **Get the touchscreen files** (`./build.sh` puts them in `build/DWIN_SET/`) and copy the `DWIN_SET` folder to the **top level** of
   the card (the card should contain `DWIN_SET/`, nothing else). Eject the card properly.

Safe to stop here.

## Stage B: Touchscreen firmware

1. Turn the printer **off** and unplug it.
2. Remove the screws on the back of the touchscreen housing and take the cover off. Find the
   microSD slot on the screen's circuit board.
3. Insert the card, then power the printer on. The screen shows an update screen (often blue
   or orange, with progress text). **Wait until it stops changing** (a minute or two). Don't
   turn it off mid-update.
4. Power off, remove the card, refit the cover.

The screen may show errors or odd behaviour until the mainboard is updated. That's expected.
Safe to stop here, but do Stage C next time before printing.

## Stage C: Mainboard firmware

1. Power the printer on and connect it to your Linux computer by USB. Don't have OctoPrint,
   Pronterface or any serial console open.
2. Find the port: `ls /dev/ttyUSB* /dev/ttyACM*` (usually `/dev/ttyUSB0`).
3. Flash (in `firmware/`; replace the port if yours differs):
   ```bash
   sudo avrdude -p atmega2560 -c wiring -P /dev/ttyUSB0 -b 115200 -D -U flash:w:E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex:i
   ```
   It takes about a minute. It should end with a line like `flash verified`.
   **Don't unplug or power off while it runs.**
4. If it fails to connect: check the port, and that nothing else has it open. Retrying is safe.

Safe to stop here, but do Stage D before printing.

## Stage D: Settings (serial console)

1. Connect with your serial console (printer idle). Send these, one at a time:
   ```
   M502
   M500
   ```
   `M502` loads the new firmware's defaults (the old saved settings don't fit the new
   layout); `M500` saves them.
2. Re-apply your heater tuning and save:
   ```
   M301 P19.98 I0.88 D50.29
   M304 P204.09 I36.11 D288.40
   M500
   ```
3. Check: send `M503` and confirm the `M92` line shows `E139.61`.
4. **First homing: keep a hand near the power switch.** Send `G28`. The printer should home
   X and Y, then probe Z with the BLTouch near the bed centre. If anything grinds or moves
   the wrong way, power off and tell me what happened.

## Stage E: Z offset and bed leveling

The old firmware's Z settings don't carry over, so set the nozzle height again:

```
G28
G1 X175 Y175 F3000
M211 S0
G1 Z5
```

Then lower the nozzle in small steps with a sheet of paper under it (`G1 Z1`, `G1 Z0.5`,
`G1 Z0.2`, then `G1 Z0.1`, `G1 Z0`, `G1 Z-0.1`, ...) until the paper drags slightly. Note that
Z value (call it `z`). Then:

```
M851 Z<current offset + z>
M211 S1
M500
```

`M851` on its own shows the current offset. Example: if it shows `Z-2.00` and the paper
dragged at `G1 Z-0.35`, send `M851 Z-2.35`.

Then measure the bed and save it:

```
G28
G29
M500
```

**In OrcaSlicer:** in the Printer settings' Machine start G-code, make sure the line after
`G28` is `M420 S1` (turns the saved bed mesh on). Marlin 2 switches it off when homing.

## Stage F: Test filament change

Print `test_M600_heated.gcode` from the SD card with filament loaded. It heats to 200 °C,
then runs `M600`: follow the touchscreen to unload, load, and resume. If it resumes and moves
to the corner, filament change works, and the plugin's `pause_command` can be just `M600`.

## Updating to a newer build of this firmware

Only the mainboard changes when the touchscreen files stay the same (as for the "friendlier
touchscreen" update), so repeat **Stage C** only. Saved settings (Z offset, mesh, heater
tuning) normally survive; check with `M503` afterwards. If the printer reports an EEPROM
error, run Stage D again.

## After fitting a run-out sensor

Send `M591 S1` then `M500` to switch run-out detection on.
