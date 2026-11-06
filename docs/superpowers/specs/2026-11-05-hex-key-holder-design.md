# Hex Key Holder — Design

Wall-mounted T-handle hex key holder for a metric set (10 keys, sizes
2, 2.5, 3, 4, 4.5, 5, 5.5, 6, 8, 10 mm). Mounts to the vertical side of
a steel tool cabinet via two neodymium magnets press-fit into the back
of the plate — no screws, no drilling.

## Geometry

L-bracket in two slabs, printed as one piece:

- **Backplate** (against the cabinet wall)
  - 220 × 70 × 5 mm
  - Two cylindrical magnet pockets on the back face, Ø 14.85 × 3.3 mm
    deep, 15 mm in from each short edge, at Z = 32.5 (aligned with the
    shelf centerline for load transfer)
- **Shelf** (horizontal, cantilevers out from the backplate 30 mm up
  from the backplate's bottom edge — the 30 mm of backplate below the
  shelf is what the underside gussets anchor to)
  - 220 × 40 × 5 mm
  - Shelf attachment position: shelf underside at Z = 30 mm above the
    backplate bottom, shelf top at Z = 35 mm
  - 10 through-holes in a single row, 22 mm center-to-center, centered
    on the shelf's 40 mm depth
  - Row spans X = 11 mm to X = 209 mm (11 mm margin each end, derived
    from (220 − 9 × 22) / 2)
  - Hole diameters, in row order (left to right as viewed from the
    front):
    | Position | Key size (mm) | Hole Ø (mm) | Rationale |
    |---|---|---|---|
    | 1 | 2 | 8 | 10 mm beveled grip bottom catches |
    | 2 | 2.5 | 8 | same |
    | 3 | 3 | 8 | same |
    | 4 | 4 | 8 | same |
    | 5 | 4.5 | 8 | same |
    | 6 | 5 | 13 | 15.5 mm beveled grip bottom catches |
    | 7 | 5.5 | 13 | same |
    | 8 | 6 | 13 | same |
    | 9 | 8 | 13 | same |
    | 10 | 10 | 13 | 10 mm shaft, 1.5 mm clearance per side |
  - Engraved labels on the shelf top face, 0.6 mm deep, placed on the
    backplate-side of each hole: "2", "2.5", "3", "4", "4.5", "5",
    "5.5", "6", "8", "10". Font: `Inconsolata:style=Bold` (matches
    existing designs in this repo).
- **Gussets** (support the shelf under load, hanging below it)
  - 4 triangular ribs occupying the volume between the shelf underside
    (Z = 30) and the backplate front face (Y = 5), extending 30 mm out
    along the shelf and 30 mm down the backplate
  - Each rib: 30 mm along shelf × 30 mm down backplate × 4 mm thick
  - Positioned between hole columns at X ≈ 44, 88, 132, 176 mm so no
    rib sits directly under a hole. Hex key shafts hang through the
    holes and dangle between gussets — ribs are 4 mm thick in X,
    clearance to nearest hole center is 11 mm, so shafts (max Ø 10 mm)
    clear comfortably.

## Magnet retention

**N52 neodymium disc magnets, 15 × 3 mm, two off.**

Pocket design: Ø 14.85 mm (magnet OD − 0.15 mm) × 3.3 mm deep.
Press-fit. Magnet is seated by thumb pressure and held by friction
against the pocket walls. Optional CA glue around the rim after
seating for a permanent bond.

Pull force per magnet to steel: ~4 kg. Combined ~8 kg. Loaded holder
mass (holder + 10 keys): ~0.6 kg. Safety factor ≈ 13×.

### Why not pause-and-insert capture?

Fully-encapsulated magnet capture (pause print, drop magnet, resume)
would be stronger but is awkward for this L-geometry: the only print
orientation that fits the bed has the magnet pockets opening
downward (toward the bed) or sideways — in either case the magnet
cannot be dropped into a pause pocket. Press-fit + optional glue is
strong enough and much simpler.

## Print orientation

Backplate lies flat on the bed, **back face down**. The L-bracket
rotates so the shelf and gussets stand up as a wall perpendicular to
the bed. Gussets print as thin vertical ribs behind the standing
shelf.

Build volume used: 220 × 70 × 45 mm. Fits comfortably on a Bambu X1C
(256 × 256 × 256).

Advantages of this orientation:
- Magnet pockets are flat features on the first layers — print cleanly
  with accurate ID.
- No support required for the shelf (it stands up as a vertical wall).
- Gussets printed as thin walls perpendicular to the bed — no overhang
  issues.
- Hole labels on the shelf top face print as crisp top-layer features.

Post-processing: flip the print over, press magnets into back-face
pockets (mind polarity — mark one side of each magnet first so both
end up with the same pole facing out). Optional CA glue around the
rim.

## Parts output

Single-part design per the repo convention — **no `part` dropdown
variable**. Produces one combined 3MF at
`hex-key-holder/3mf/hex_key_holder.3mf` and one preview PNG at
`hex-key-holder/hex_key_holder.png`.

## File layout

Following the repo's one-directory-per-design convention:

```
hex-key-holder/
  hex_key_holder.scad
  hex_key_holder.png          (generated)
  3mf/
    hex_key_holder.3mf        (generated)
```

## OpenSCAD style

- `include <BOSL2/std.scad>` for primitives and rounded edges (matches
  `wire-mounts/wire_mount.scad` house style).
- `$fn = 96` for smooth circular features.
- All dimensions as named parameters at the top of the file so they
  can be tweaked without hunting through geometry code.
- Short section comments; no multi-line docstrings.

## Non-goals

- No parametric number-of-keys variation. This is a one-set holder.
- No multi-part dropdown. Single artifact.
- No countersunk screw fallback. Magnets only.
- No wall-angle adjustment, cable management, or additional tool
  slots.
