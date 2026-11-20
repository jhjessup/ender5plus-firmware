#!/usr/bin/env bash
# Rebuild this printer's firmware from InsanityAutomation's source plus configuration-changes.patch.
# Needs: git, python3, PlatformIO (pip install platformio), py7zr (pip install py7zr) for the screen files.
# Output: build/E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex and build/DWIN_SET/ (touchscreen files).
set -euo pipefail

REPO=https://github.com/InsanityAutomation/Marlin
BRANCH=CrealityDwin_2.0
COMMIT=0766fcd082174ad38f1fbd954e964342393e7ff6   # the exact version this build is based on
HERE=$(cd "$(dirname "$0")" && pwd)
SRC="$HERE/build/marlin"
OUT="$HERE/build"

mkdir -p "$OUT"
if [ ! -d "$SRC/.git" ]; then
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$SRC"
fi
cd "$SRC"
if [ "$(git rev-parse HEAD)" != "$COMMIT" ]; then
  git fetch --depth 1 origin "$COMMIT"
  git checkout -q "$COMMIT"
fi
git checkout -q -- .                       # start clean, then apply our changes
git apply "$HERE/configuration-changes.patch"

pio run -e mega2560
cp .pio/build/mega2560/mega2560_DW7.4.7.hex "$OUT/E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex"

python3 -c "import py7zr,sys; py7zr.SevenZipFile(sys.argv[1]).extractall(sys.argv[2])" \
  CombinedLandscapeDwin_TM3D_V8.7z "$OUT"

echo "Built: $OUT/E5P_MicroSwissDD_BLT_BIL_DW7.4.7.hex and $OUT/DWIN_SET/"
