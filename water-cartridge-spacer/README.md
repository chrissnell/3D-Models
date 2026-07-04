# Water Cartridge Spacer

An improved internal spacer for the **CR Spotless DIW-20** deionized water
softener unit. It sits between the resin cartridge and the housing, keeping
the cartridge centered and correctly seated.

The part is a thin-wall ring with four solid semicircular lobes bumping
outward at 0°, 90°, 180°, and 270°.

## Dimensions

| Feature            | Value            |
| ------------------ | ---------------- |
| Ring outer         | Ø120.5 mm        |
| Ring inner         | Ø112.0 mm        |
| Wall thickness     | 4.25 mm          |
| Lobe extent (tip)  | Ø136.25 mm       |
| Height (thickness) | 5 mm             |

## Files

- `water-cartridge-spacer.scad` — parametric OpenSCAD source. Edit `wall`,
  `ring_outer`, `lobe_extent`, and `height` at the top to re-size.
- `3mf/water-cartridge-spacer.3mf` — sliceable mesh for Bambu Studio.
- `water-cartridge-spacer.png` — preview render.
- `water-cartridge-spacer-footprint.svg` / `.dxf` — flat 1:1 outline
  (set `-D footprint=true`) for size validation against the housing.
- `water-cartridge-spacer-footprint-actual-size.pdf` — 1:1 printable
  footprint; fits a single US Letter / A4 sheet.
- `water-cartridge-spacer-footprint-letter-tiled.pdf` — the same outline
  tiled across US Letter pages with a 100 mm calibration square.
- `scripts/make_footprint_pdf.py` — regenerates the print PDFs from the SVG.

## Printing

PLA or PETG at 100% scale. Before committing to the full 5 mm part, print
the footprint PDF at **100% / Actual Size** (not "Fit to Page") and check it
against the DIW-20 housing — the 100 mm calibration square confirms scale.
