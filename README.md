# Toy Soldiers — parametric 3D-printable figures

Chunky Lego-style toy soldiers (~70mm tall) with **swappable weapons**, designed
as code. Every figure has a standard C-grip hand; every weapon has a matching
grip bar — so any soldier can hold any weapon, including ones you design.

Built for the Elegoo Neptune 4 but prints on any FDM printer with a
100×100mm+ bed. **No supports needed on any model.**

| Figures | Weapons |
|---|---|
| `rifleman` — standing at the ready | `rifle` |
| `officer` — peaked cap, arm raised | `pistol` |
| `heavy` — backpack, bazooka at the shoulder | `bazooka`, `knife` |

## Quick start (just want to print?)

1. Grab the `.stl` files from the [`stl/`](stl/) folder — no software needed
   beyond a slicer.
2. Open one in your slicer (Elegoo Cura, OrcaSlicer, or PrusaSlicer) with your
   printer's profile — e.g. **Neptune 4**.
3. Slice and save the resulting `.gcode` file to your USB drive.
4. Print. See [docs/printing.md](docs/printing.md) for settings.

**Print `fit-test.stl` first** — it's a 10-minute print of one hand and one
grip bar. If the bar snaps in firmly, print everything else. If not, tweak two
numbers (see below) — every printer is a little different.

## The three file types (what goes on the USB?)

- **`.scad`** — the *source code*. Human-readable text; edit with the free
  [OpenSCAD](https://openscad.org). This is what you fork and remix.
- **`.stl`** — the 3D *mesh* exported from the code. This is what you open in
  a slicer. Universal, but not directly printable.
- **`.gcode`** — *machine instructions* produced by your slicer for your
  specific printer and filament. **This is the only file the printer reads —
  the USB drive gets `.gcode`, never `.stl`.** We don't ship gcode because
  it's specific to one printer + filament combo; slice your own.

## Remixing (the fun part)

All dimensions live as named parameters in
[`scad/lib/soldier.scad`](scad/lib/soldier.scad). The grip contract is three
constants:

```openscad
GRIP_BAR_D  = 5.6;  // weapon grip-bar diameter
GRIP_HOLE_D = 6.0;  // hand hole (0.4mm clearance for FDM)
GRIP_SLOT_W = 5.3;  // C-opening; the bar snaps through the front
```

Any weapon whose bar uses `GRIP_BAR_D` fits every figure. To design a new
weapon, copy `scad/weapons/rifle.scad`, draw a new flat silhouette out of
`rrect()` calls, and place `grip_bar()` where the hand goes. New poses are a
new `arm()` case in the library.

Rebuild everything with:

```sh
make          # renders stl/ + previews/  (needs OpenSCAD installed)
make check    # sanity-checks sizes against the printer bed
```

On macOS: `brew install --cask openscad@snapshot`. On Linux:
`apt install openscad` (then `make OPENSCAD=openscad`).

## Design rules (why the models look the way they do)

- **No supports:** every overhang is ≤45°, boots rest on the base, helmet
  brims are chamfered, weapons print lying flat with the bar tangent to the bed.
- **Kid-proof:** minimum 1.6mm walls; weapons are printed flat so layer lines
  run along the barrel (the strong direction).
- **Obviously toys:** blocky, rounded, Lego-like proportions throughout.

## License

MIT — print, remix, sell, whatever. Attribution appreciated, not required.
