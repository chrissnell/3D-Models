# gopro-battery-case

A screw-top cylindrical case that holds **6 GoPro batteries** and **16 microSD
cards** — no camera. ~104 mm diameter.

- Batteries: 6 pockets (34 × 13.5 mm, 29 mm deep).
- microSD: 16 slots (12.5 mm wide, 0.80 mm thick, 10 mm deep), spread away from the batteries so
  each card can be pinched out; some sit above/below the battery block.
- Screw-on lid over a reduced-diameter neck with a coarse round (knuckle) thread
  (3 mm pitch, ~3 turns) that prints cleanly and screws easily; flush with the
  body, with 18 mm of relief above the proud batteries/cards. (Switch
  `thread_shape` to `trapezoid` for a flat-crested ACME-style tooth.)
- Diamond knurl on both outer walls; 45° chamfers on the base bottom and lid top.

Everything is parametric — see the variables at the top of the `.scad`.

## SD slot fit-test

The original slots (`sd_slot_t = 1.0 mm`) held cards too loosely and they could
work their way out. `sd-slot-test.scad` is a small throwaway print — a block
with five slots identical to the real pocket except for thickness, stepping
0.95 → 0.90 → 0.85 → 0.80 → 0.75 mm, each identified by a row of round
indentations beside it (one dimple for slot 1, … five for slot 5). Testing
settled on **0.80 mm** (slot 4) as the tightest slot that still seats and
releases a card cleanly, so the case now uses `sd_slot_t = 0.80 mm`. The test
block is kept for reference should the fit need re-tuning.

## Parts

| Part | 3MF | Notes |
| --- | --- | --- |
| `base` | `3mf/gopro-battery-case-base.3mf` | the body |
| `lid` | `3mf/gopro-battery-case-lid.3mf` | the cap |

## Dependency

[BOSL2](https://github.com/BelfrySCAD/BOSL2) on the OpenSCAD library path
(ACME thread + diamond-knurl texture), same as `wire-mounts`.
