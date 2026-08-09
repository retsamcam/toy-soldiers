#!/usr/bin/env bash
# Slice every STL to Neptune 4 gcode, ready to copy onto a USB stick.
#
#   ./scripts/slice_all.sh [output-dir]     (default: ~/Desktop/toy-soldiers-gcode)
#
# Uses our own filament profile (profiles/toy-soldiers-pla.json) rather than the
# stock one: OrcaSlicer's CLI silently assumes a "Cool Plate" and emits a 35C bed
# temperature, which is far too cold for PLA and makes prints lift off the plate.
set -euo pipefail

ORCA="${ORCA:-/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer}"
PROFILES="${PROFILES:-/Applications/OrcaSlicer.app/Contents/Resources/profiles/Elegoo}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-$HOME/Desktop/toy-soldiers-gcode}"

MACHINE="$PROFILES/machine/EN4SERIES/Elegoo Neptune 4 0.4 nozzle.json"
PROCESS="$PROFILES/process/EN4SERIES/0.20mm Standard @Elegoo N4 0.4 nozzle.json"
FILAMENT="$REPO/profiles/toy-soldiers-pla.json"

for f in "$MACHINE" "$PROCESS" "$FILAMENT" "$ORCA"; do
    [ -e "$f" ] || { echo "missing: $f" >&2; exit 1; }
done

mkdir -p "$DEST"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for stl in "$REPO"/stl/*.stl; do
    name="$(basename "$stl" .stl)"
    "$ORCA" --load-settings "$MACHINE;$PROCESS" --load-filaments "$FILAMENT" \
            --slice 0 --outputdir "$work/$name" "$stl" >/dev/null 2>&1 || true
    if [ -f "$work/$name/plate_1.gcode" ]; then
        mv "$work/$name/plate_1.gcode" "$DEST/$name.gcode"
        # Stock start gcode homes but never loads the saved auto-level mesh, so
        # bed levelling is silently ignored and a tilted bed can't be corrected
        # by Z-offset alone. Insert the load right after homing.
        sed -i '' 's/^G28 ;home$/G28 ;home\
BED_MESH_PROFILE LOAD=default ; apply saved auto-level mesh/' "$DEST/$name.gcode"
        bed=$(grep -am1 '^M190' "$DEST/$name.gcode" | sed -n 's/.*S\([0-9]*\).*/\1/p')
        time=$(grep -am1 'estimated printing time' "$DEST/$name.gcode" | sed 's/.*= //')
        printf '%-18s %-10s bed %s°C\n' "$name.gcode" "$time" "$bed"
        [ "${bed:-0}" -ge 55 ] || { echo "  ^ BED TOO COLD — check the filament profile" >&2; exit 1; }
        grep -aq 'BED_MESH_PROFILE LOAD' "$DEST/$name.gcode" || {
            echo "  ^ no bed mesh load — auto-levelling would be ignored" >&2; exit 1; }
    else
        echo "FAILED to slice: $name" >&2
        exit 1
    fi
done

echo
echo "Gcode written to $DEST — copy these onto the USB stick."
