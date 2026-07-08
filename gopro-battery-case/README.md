# gopro-battery-case

A screw-top cylindrical case that holds **6 GoPro batteries** and **16 microSD
cards** — no camera. ~104 mm diameter.

- Batteries: 6 pockets (34 × 13.5 mm, 29 mm deep).
- microSD: 16 slots (12.5 × 1 mm, 10 mm deep), spread away from the batteries so
  each card can be pinched out; some sit above/below the battery block.
- Screw-on lid over a reduced-diameter neck with a coarse trapezoidal thread
  (3 mm pitch, ~3 turns) chosen to print cleanly and screw easily; flush with
  the body, with 18 mm of relief above the proud batteries/cards.
- Diamond knurl on both outer walls; 45° chamfers on the base bottom and lid top.

Everything is parametric — see the variables at the top of the `.scad`.

## Parts

| Part | 3MF | Notes |
| --- | --- | --- |
| `base` | `3mf/gopro-battery-case-base.3mf` | the body |
| `lid` | `3mf/gopro-battery-case-lid.3mf` | the cap |

## Dependency

[BOSL2](https://github.com/BelfrySCAD/BOSL2) on the OpenSCAD library path
(ACME thread + diamond-knurl texture), same as `wire-mounts`.
