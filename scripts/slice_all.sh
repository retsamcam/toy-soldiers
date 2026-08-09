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
        # Stock start gcode homes but never loads a bed mesh. Set MESH=load to
        # apply a saved profile, or MESH=calibrate to probe fresh each print
        # (~2 min). Default is off: LOAD errors out with "Unknown profile" on
        # printers that have never saved one, which aborts the job.
        case "${MESH:-off}" in
            load)      mesh_cmd='BED_MESH_PROFILE LOAD=default' ;;
            calibrate) mesh_cmd='BED_MESH_CALIBRATE' ;;
            off)       mesh_cmd='' ;;
            *) echo "MESH must be off, load, or calibrate" >&2; exit 1 ;;
        esac
        [ -z "$mesh_cmd" ] || sed -i '' "s/^G28 ;home\$/G28 ;home\\
$mesh_cmd ; bed mesh/" "$DEST/$name.gcode"
        bed=$(grep -am1 '^M190' "$DEST/$name.gcode" | sed -n 's/.*S\([0-9]*\).*/\1/p')
        time=$(grep -am1 'estimated printing time' "$DEST/$name.gcode" | sed 's/.*= //')
        printf '%-18s %-10s bed %s°C\n' "$name.gcode" "$time" "$bed"
        [ "${bed:-0}" -ge 55 ] || { echo "  ^ BED TOO COLD — check the filament profile" >&2; exit 1; }
    else
        echo "FAILED to slice: $name" >&2
        exit 1
    fi
done

echo
echo "Gcode written to $DEST — copy these onto the USB stick."
