# gopro-battery-case

A screw-top cylindrical case that holds **6 GoPro batteries** and **16 microSD
cards** — no camera. ~104 mm diameter.

- Batteries: 6 pockets (34 × 13.5 mm, 29 mm deep).
- microSD: 16 slots (12.5 × 1 mm, 10 mm deep), spread away from the batteries so
  each card can be pinched out; some sit above/below the battery block.
- Screw-on lid over a reduced-diameter neck with a coarse round (knuckle) thread
  (3 mm pitch, ~3 turns) that prints cleanly and screws easily; flush with the
  body, with 18 mm of relief above the proud batteries/cards. (Switch
  `thread_shape` to `trapezoid` for a flat-crested ACME-style tooth.)
- Diamond knurl on both outer walls; 45° chamfers on the base bottom and lid top.

Everything is parametric — see the variables at the top of the `.scad`.

## SD slot fit-test

The production microSD slots (`sd_slot_t = 1.0 mm`) hold cards a touch too
loosely and they can work their way out. `sd-slot-test.scad` is a small
throwaway print — a block with five slots identical to the real pocket except
for thickness, stepping 0.95 → 0.90 → 0.85 → 0.80 → 0.75 mm (engraved beside
each). Print it, find the tightest slot that still seats and releases a card
cleanly, then set the case's `sd_slot_t` to that value and rebuild.

## Parts

| Part | 3MF | Notes |
| --- | --- | --- |
| `base` | `3mf/gopro-battery-case-base.3mf` | the body |
| `lid` | `3mf/gopro-battery-case-lid.3mf` | the cap |

## Dependency

[BOSL2](https://github.com/BelfrySCAD/BOSL2) on the OpenSCAD library path
(ACME thread + diamond-knurl texture), same as `wire-mounts`.
