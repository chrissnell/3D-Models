# ESP32 Snowgauge Box — Design Spec

Date: 2026-11-16
Directory: `esp32-snowgauge-box/`

## Purpose

A stout, outdoor-rated two-piece enclosure for an ESP32 board (82.5 × 60 mm) plus additional components that will be added in follow-up design rounds. Sealed with a TPU gasket; lid secured by four M4 screws into brass heat-set inserts in the box corners.

## Inputs & constraints

- **Board footprint:** 82.5 mm × 60 mm.
- **Board mounting holes:** M3, four corners.
  - Long-edge (X): 65 mm between hole centers, with 9.5 mm offset from one end and 7.5 mm from the other end of the board (asymmetric — accommodated by extra perimeter clearance, not by moving holes).
  - Short-edge (Y): 45 mm between hole centers, symmetric (7.5 mm from each short edge).
- **Headroom:** 25 mm of clear internal height above the top of the mount posts.
- **Extra cavity:** 90 mm of additional empty internal space in the +X direction *on the left of the board* (board lives at the far right of the cavity, viewed from +Z).
- **Lid attachment:** 4× M4 socket-head cap screws into M4 brass heat-set inserts, one in each corner of the box.
- **Gasket:** 3 mm TPU, printed in this repo, sits on a flat flange around the top of the box.
- **Environment:** outdoors. Everything stout — no thin walls.
- **Printer:** Bambu X1C / P1S class, 256 × 256 mm bed. Each part must fit the bed.

## Deliverables

Four artifacts, generated via the repo's `part` Customizer convention (`all`, `box`, `lid`, `gasket`, `alignment-2d`):

| File | Purpose |
|---|---|
| `esp32-snowgauge-box/3mf/esp32-snowgauge-box-box.3mf` | Enclosure base, print in ASA |
| `esp32-snowgauge-box/3mf/esp32-snowgauge-box-lid.3mf` | Lid with drip edge, print in ASA |
| `esp32-snowgauge-box/3mf/esp32-snowgauge-box-gasket.3mf` | 3 mm gasket, print in TPU 95A |
| `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf` | 1:1 paper alignment template |
| `esp32-snowgauge-box/esp32-snowgauge-box.png` | Preview PNG (all parts assembled) |

This round ships a **solid box with no cutouts** — no USB access, no cable glands, no antenna holes, no mounting flanges. Cable penetrations and the additional components (plus their mounts) will be added in later design rounds.

## Dimensions

### Cavity (interior of box)

| Axis | Value | Notes |
|---|---|---|
| X (long) | 180 mm | 82.5 mm board + 4 mm right-wall clearance + ~93.5 mm open cavity left of board |
| Y (short) | 70 mm | 60 mm board + 5 mm clearance each side |
| Z (height) | 31 mm | 6 mm post height + 25 mm headroom above post top |

### Box exterior

| Axis | Value |
|---|---|
| X | 196 mm |
| Y | 86 mm |
| Z | 36 mm (5 mm floor + 31 mm cavity) |

Fits on the 256 mm bed with room to spare.

### Wall / floor thicknesses

| Element | Thickness |
|---|---|
| Side walls | 8 mm (doubles as the gasket flange — top 8 mm of wall *is* the flange) |
| Floor | 5 mm |
| Lid | 6 mm |
| Gasket | 3 mm |

## Board mount posts (4×)

- Count: 4, one at each corner of the board footprint.
- Post OD: **8 mm**.
- Center bore: **4.2 mm diameter, 6 mm deep**, with a small lead-in chamfer (~0.5 mm × 45°) so the M3 brass heat-set insert (≈4 mm OD, 5 mm length) presses straight.
- Post height above cavity floor: **6 mm**. Board sits on top of posts.
- Terminology: the board's long axis (82.5 mm) aligns with cavity X; the board's short axis (60 mm) aligns with cavity Y. The four holes form two pairs near the two short ends of the board.
- Along the long axis (X): 65 mm between the two pairs' centers, with 7.5 mm from one short end of the board to the nearest hole pair and 9.5 mm from the other short end to the nearest hole pair (7.5 + 65 + 9.5 ≈ 82 mm vs. a nominal 82.5 mm board length; the 0.5 mm rounding goes into perimeter slop).
- Along the short axis (Y): 45 mm between holes within a pair, symmetric — each hole 7.5 mm from the nearest long edge of the board.
- Board is placed in the cavity with its right short end 4 mm from the inner right wall. By convention, the board's 7.5 mm (tight) short-end faces the right wall; the 9.5 mm (looser) short-end faces into the open 90 mm cavity.
- Posts are placed to match the real board holes, not to center the board — the asymmetry is absorbed by the extra perimeter clearance.

## Corner M4 bosses (4×, lid fasteners)

- Built into the 8 mm wall corners as thickened pillars running the full box height.
- Boss OD: **11 mm** at the corners (provides ~3 mm minimum wall around the insert).
- Insert pocket: **5.7 mm diameter, 9 mm deep**, opening on the **top** face of the flange. Sized for standard M4 brass heat-set inserts (≈6 mm OD, 8 mm length).
- Top face of the boss is **flush** with the top of the flange so the gasket sits flat.
- No through-hole below the insert pocket — pocket is a blind bore from the top.

## Gasket flange

- The top 8 mm of wall thickness *is* the flange: a flat rectangular rim with inner edge at the cavity opening (180 × 70 mm) and outer edge at the box exterior (196 × 86 mm).
- No draft, no ribs on the top face. The surface must be flat enough for the TPU gasket to seal.
- Four M4 insert pockets open through this flange face (one per corner, from the Corner M4 Bosses section).

## Lid

- Material: ASA.
- Thickness: **6 mm**.
- Outer footprint: **200 × 90 mm** — 2 mm oversize on every side vs. the box exterior.
- **Drip edge:** a 3 mm tall × 2 mm thick lip around the full perimeter of the *underside*, so the lid overhangs the box by 2 mm and water drips past the gasket seam instead of wicking in.
- Four M4 clearance holes at the corners:
  - Through-hole: 4.5 mm diameter.
  - Counterbore on top face: ~7.5 mm diameter × 4.5 mm deep for an M4 socket-head cap screw head (sits flush or slightly recessed).
- Underside is flat — the 25 mm board headroom is all inside the box; the lid adds no cavity depth.

## Gasket

- Material: TPU 95A, printed on this project's Bambu printer.
- Thickness: **3 mm**.
- Outer footprint: **196 × 86 mm** — matches the box flange outline.
- Inner cutout: **180 × 70 mm** — matches the cavity opening.
- Four 4.5 mm clearance holes at the corners for the M4 lid screws (same XY positions as the lid holes and box inserts).
- Print guidance (noted for the user — not enforced by geometry): 100% infill, 0.2 mm layers or ironed top, concentric or monotonic top/bottom pattern to minimize seal leaks.

## Alignment PDF (test-print template)

A 1:1 scale top-down template, printed on paper, used to verify the board holes line up with the designed post centers before trusting the 3MF.

**Contents:**
- Cavity outline (180 × 70 mm) — thin solid line.
- Board outline (82.5 × 60 mm) in the as-mounted position — dashed line.
- Four mount-post footprints: 8 mm OD circles with crosshairs at centers.
- Four corner M4 boss footprints: 11 mm OD circles — thin line, labeled "ref".
- A **10 mm calibration square** in one corner with the label "Print at 100% — square must measure 10 mm".
- Dimensioned callouts for the 65 × 45 mm hole spacing and 7.5 / 9.5 mm edge offsets.

**Toolchain:**
- OpenSCAD `part = "alignment-2d"` branch emits a 2D `projection()` at the post-top plane plus labeled annotations.
- Makefile detects the `alignment-2d` part and routes it through: `openscad -o foo.svg` → `rsvg-convert -f pdf -o foo.pdf foo.svg`.
- The Makefile change is scoped to designs that declare the `alignment-2d` part — no impact on other designs.

## Assembly stack-up

| Layer | Z range |
|---|---|
| Floor | 0 – 5 mm |
| Cavity (walls run 5 – 41 mm) | 5 – 36 mm |
| Flange top face | 36 mm |
| Gasket (compressed ~10%) | 36 – ~38.7 mm |
| Lid (drip edge wraps down past 36 mm) | ~38.7 – ~44.7 mm |

Assembled height ≈ 45 mm.

## Convention compliance

- `part` Customizer variable with values `[all, box, lid, gasket, alignment-2d]`, default `"all"`.
- `all` renders the assembled view (box + gasket + lid, exploded or stacked) for preview PNG rendering; it is not exported as a 3MF.
- Each non-`all` 3D value isolates one printable part at the origin, oriented for direct slicing.
- `alignment-2d` renders a 2D scene for SVG export (handled by the Makefile).
- Source `.scad` lives in the design directory. 3MFs ship under `3mf/`. Preview PNG and alignment PDF sit next to the `.scad`.

## Out of scope for this round

- USB-C access port.
- Cable glands.
- Antenna / display cutouts.
- Mounts for the additional components that will share the cavity.
- External mounting flanges / bracket / U-bolt attachments.

Each will be addressed in a follow-up design round.
