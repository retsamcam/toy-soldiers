# Printing guide (Elegoo Neptune 4)

## Workflow

```
stl/  →  slicer (Elegoo Cura / OrcaSlicer, "Elegoo Neptune 4" profile)  →  .gcode  →  USB  →  print
```

The printer only understands `.gcode`. STLs on the USB stick will not show up
on the printer's menu.

## Generating the gcode

```sh
./scripts/slice_all.sh              # writes to ~/Desktop/toy-soldiers-gcode
./scripts/slice_all.sh /Volumes/USB # or straight onto the stick
```

**Watch the bed temperature.** OrcaSlicer's CLI assumes a "Cool Plate" unless
told otherwise and will emit `M190 S35` — a 35°C bed, far too cold for PLA, and
your prints will lift off mid-job. That's why we ship
`profiles/toy-soldiers-pla.json`, which pins 60°C on every plate type; the
script also fails loudly if a sliced file comes out below 55°C. If you slice by
hand in the OrcaSlicer GUI instead, set the plate type to **Textured PEI Plate**.

## Settings

| Setting | Value | Why |
|---|---|---|
| Layer height | 0.2mm | Good detail/speed balance at this size |
| Walls | 4 (1.6mm) | Kid-proof limbs and weapon shafts |
| Infill | 15% gyroid/grid | Plenty for solid-feeling toys |
| Supports | **OFF** | Every model is designed support-free |
| Brim/raft | None | Bases are wide and flat; textured PEI holds fine |
| Nozzle | 205°C first layer, 200°C after | PLA; PLA+ is a bit tougher if you have it |
| Bed | 60°C | 65°C if the first layer still lifts |

## Orientation (already correct in the STLs)

- **Figures** print standing upright on their base.
- **Weapons** print lying flat — do not rotate them upright; flat is the
  strong orientation and the grip bar is positioned to rest on the bed.

## Plate packing

At ~35×29mm footprint per figure you can fit a full platoon (6+ figures and
all four weapons) on the Neptune 4's 225×225 bed in one job. Figures take
roughly 2–3 hours each at 0.2mm; weapons 20–40 minutes.

## Dialling in the grip fit

Print `fit-test.stl` first (~10 min). Target: the bar clicks through the
C-opening and rotates with light friction in the hole.

- **Too tight / won't click in:** raise `GRIP_SLOT_W` to 5.5 and/or
  `GRIP_HOLE_D` to 6.2 in `scad/lib/soldier.scad`, re-run `make`.
- **Too loose / weapon droops:** drop `GRIP_HOLE_D` to 5.8.

One `make` regenerates every figure and weapon with the new fit.

## Safety

These are chunky toys with rounded edges, but printed PLA can crack into
sharp pieces under abuse and small parts are a choking hazard — not for
children under 3, and inspect prints for damage occasionally.
