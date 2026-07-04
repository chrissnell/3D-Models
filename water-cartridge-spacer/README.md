# Water Cartridge Spacer

An improved internal spacer for the **CR Spotless DIW-20** deionized water
softener unit. It sits between the resin cartridge and the housing, keeping
the cartridge centered and correctly seated.

The part is a ring with four solid semicircular lobes bumping outward at 0°,
90°, 180°, and 270°. Only two diameters matter for the fit — the inner hole
(`inner_diameter`) and the circle through the lobe tips (`outer_diameter`);
everything else derives from those.

## Variants

Set with the `part` dropdown (OpenSCAD Customizer) or `-D part=...`:

- **solid** — plain ring.
- **ventilated** — triangular through-holes cut in the ring wall so water
  can flow axially through the gasket.

## Dimensions

| Feature            | Value            |
| ------------------ | ---------------- |
| Ring outer         | Ø120.5 mm        |
| Ring inner         | Ø106.5 mm        |
| Wall thickness     | 7.0 mm           |
| Lobe extent (tip)  | Ø133.0 mm        |
| Height (thickness) | 5 mm             |

## Files

- `water-cartridge-spacer.scad` — parametric OpenSCAD source. Edit
  `inner_diameter` and `outer_diameter` at the top to re-size; `wall`,
  `height`, and the `vent_*` values are secondary knobs.
- `3mf/water-cartridge-spacer-solid.3mf` /
  `3mf/water-cartridge-spacer-ventilated.3mf` — sliceable meshes for Bambu
  Studio.
- `water-cartridge-spacer.png` — preview render.
- `water-cartridge-spacer-footprint.svg` / `.dxf` — flat 1:1 outline
  (set `-D footprint=true`) for size validation against the housing.
- `water-cartridge-spacer-footprint-actual-size.pdf` — 1:1 printable
  footprint; fits a single US Letter / A4 sheet.
- `water-cartridge-spacer-footprint-letter-tiled.pdf` — the same outline
  tiled across US Letter pages with a 100 mm calibration square.
- `scripts/make_footprint_pdf.py` — regenerates the print PDFs from the SVG.

## Printing

ASA or PETG at 100% scale. Recommend 18% infill and gyroid pattern.
Before committing to the full 5 mm part, print the footprint PDF at 
**100% / Actual Size** (not "Fit to Page") and check it against the
DIW-20 housing — the 100 mm calibration square confirms scale.
