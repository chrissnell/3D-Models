# gopro-battery-case

A screw-top cylindrical case that holds **6 GoPro batteries** and **16 microSD
cards** — no camera. ~104 mm diameter.

- Batteries: 6 pockets (34 × 13.5 mm, 29 mm deep).
- microSD: 16 slots (12.5 × 1 mm, 10 mm deep), spread away from the batteries so
  each card can be pinched out; some sit above/below the battery block.
- Screw-on lid over a reduced-diameter ACME-threaded neck (2.5 mm pitch), flush
  with the body, with 18 mm of relief above the proud batteries/cards.
- Diamond knurl on both outer walls; 45° chamfers on the base bottom and lid top.
- GoPro logo inlaid flush into the lid top for a two-colour print.

Everything is parametric — see the variables at the top of the `.scad`.

## Parts

| Part | 3MF | Notes |
| --- | --- | --- |
| `base` | `3mf/gopro-battery-case-base.3mf` | the body |
| `lid` | `3mf/gopro-battery-case-lid.3mf` | cap, includes the logo pocket |
| `logo` | `3mf/gopro-battery-case-logo.3mf` | flush logo inlay, second filament |

## Two-colour lid

`lid` already has the logo-shaped pocket in the top; `logo` is the matching
inlay, modelled at the same coordinates with its top face flush with the lid.
Load both into Bambu Studio at the same origin (Import → *Add part* to the lid,
or "load as parts"), assign a different filament to the logo, and slice. On a
single-nozzle printer use paint-by-object / multi-material; on an AMS it just
works. Set `logo_enable = false` in the `.scad` for a plain lid.

## Dependency

[BOSL2](https://github.com/BelfrySCAD/BOSL2) on the OpenSCAD library path
(ACME thread + diamond-knurl texture), same as `wire-mounts`.

## Logo asset

`GoPro_logo_light.svg` is from
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:GoPro_logo.svg).
"GoPro" and the logo are trademarks of GoPro, Inc.; included for a personal-use
replica case.
