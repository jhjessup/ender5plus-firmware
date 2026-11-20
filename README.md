# Ender-5 Plus firmware (InsanityAutomation Marlin 2)

> **⚠️ For one specific printer. Don't flash this as-is on another printer.**
> These settings are tuned for this machine's hardware: Micro Swiss direct drive (e-steps
> 139.61), a PTFE-lined hotend (255 °C limit), and BLTouch offsets for this mount. On a
> different setup they can cause wrong extrusion, probing in the wrong place, or overheating.
> If you have a similar printer, use the [patch](configuration-changes.patch) and
> [build script](build.sh) as a starting point and change the settings for your hardware.
> Flash at your own risk. See [LICENSE note](#license).

Firmware configuration, flashing steps and notes for **one specific printer**:

- Creality Ender-5 Plus, V2.2 mainboard (ATmega2560), stock DWIN touchscreen
- Micro Swiss direct drive extruder (e-steps 139.61, calibrated)
- PTFE-lined hotend (**not** all-metal): max nozzle temperature 255 °C; print at 240 °C or below
- BLTouch, bilinear bed leveling
- No filament run-out sensor yet (detection is off; see FLASHING.md to enable after fitting one)

Main goal: a working filament change (`M600`) with touchscreen prompts, for the
[Pause at Weight](https://github.com/jhjessup/orcaslicer-pause-at-weight) OrcaSlicer plugin.

## Contents

| Path | What it is |
|---|---|
| `configuration-changes.patch` | All changes to InsanityAutomation's `Configuration.h` |
| `build.sh` | Rebuilds the firmware: fetches the exact source version, applies the patch, compiles |
| `firmware/` | The firmware file that was flashed, with its checksum |
| `FLASHING.md` | Step-by-step flashing and setup, stages A–F |
| `settings/` | `M503` output before (stock) and after the upgrade |
| `tests/` | Small G-code files for testing pause commands |

Base: [InsanityAutomation/Marlin](https://github.com/InsanityAutomation/Marlin), branch
`CrealityDwin_2.0`, commit `0766fcd082174ad38f1fbd954e964342393e7ff6` (DWIN 7.4.7,
Marlin bugfix-2.1.x). That branch hasn't been updated since March 2023.

## Configuration changes

- `MachineEnder5Plus`, `MicroswissDirectDrive`, `ABL_BLTOUCH`, `ABL_BI` enabled
- E-steps 139.61 instead of the Micro Swiss default 130
- `HotendAllMetal` disabled (PTFE-lined heatbreak), so `HEATER_0_MAXTEMP` is 255
- Run-out sensor detection off by default (`FIL_RUNOUT_ENABLED` false): with no sensor
  fitted, the input reads as "out of filament"

Already on in the source, not changed: filament change (`ADVANCED_PAUSE_FEATURE`, `M600`),
park on pause, `M701`/`M702` load and unload, babystepping linked to the Z probe offset.

## Rebuilding

```bash
pip install platformio py7zr
./build.sh
```

Output goes to `build/` (not committed): the `.hex` firmware and the `DWIN_SET/` touchscreen
folder. Build size: about 66% of flash, 75% of RAM.

A rebuild matches `firmware/E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex` except for the embedded
compile date and time (10 bytes), so the checksum differs but the firmware is the same.

## Notes learned along the way

- **Stock firmware (Marlin 1.1.6, SW V1.70.3) has no usable G-code pause:** `M0` pauses with
  no way to resume from the touchscreen, `M600` is ignored, `M25` is skipped or can't be
  resumed. Tested with the files in `tests/`.
- **Opening the USB serial port resets the board** (and cancels a running print). Never
  connect mid-print. `stty -F /dev/ttyUSB0 -hupcl` after plugging in stops later
  reconnections from resetting it.
- **Serial speed:** stock firmware 115200, this firmware 250000
  (`picocom -b 250000 --imap lfcrlf --echo /dev/ttyUSB0`).
- **`wait` every second** on the console is normal for this firmware when idle.
- **Motion limits:** this firmware's defaults (acceleration 2000/750, jerk 20) are much
  higher than stock (500/200, jerk 8). The stock values were restored with
  `M201 X500 Y500`, `M204 P200 R1000 T200`, `M205 X8 Y8`, `M500`.
- **OrcaSlicer:** add `M420 S1` after `G28` in the machine start G-code so the saved bed mesh
  is used (Marlin 2 turns it off when homing).
- **Run-out sensor:** the original was removed with the direct-drive upgrade. Replacement:
  Creality part 2102010417 (Ender-5 Plus filament sensor).

## License

The firmware is built from [Marlin](https://github.com/MarlinFirmware/Marlin) via
InsanityAutomation's branch, both licensed under the
[GNU GPL v3](https://github.com/InsanityAutomation/Marlin/blob/CrealityDwin_2.0/LICENSE).
The compiled firmware in `firmware/` and the configuration patch are distributed under the
same license. The full source for the build is the base commit above plus
`configuration-changes.patch`. Provided without warranty.
