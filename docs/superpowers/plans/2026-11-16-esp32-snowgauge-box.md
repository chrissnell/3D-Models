# ESP32 Snowgauge Box Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an OpenSCAD design that produces a stout, outdoor-rated, gasketed project box for an 82.5 × 60 mm ESP32 board, along with a lid, a 3 mm TPU gasket, and a 1:1 paper alignment template.

**Architecture:** Single `.scad` file using the repo's `part` Customizer convention with values `all`, `box`, `lid`, `gasket`, `alignment-2d`. All geometry is parametric and anchored to the cavity floor origin. The Makefile is extended to detect the `alignment-2d` part and pipe OpenSCAD's SVG output through `rsvg-convert` to produce a PDF.

**Tech Stack:** OpenSCAD (geometry), GNU Make (build), `rsvg-convert` from `librsvg` (SVG → PDF), Bambu X1C / P1S for printing.

**Spec:** `docs/superpowers/specs/2026-11-16-esp32-snowgauge-box-design.md`

---

## File Structure

| Path | Role |
|---|---|
| `esp32-snowgauge-box/esp32-snowgauge-box.scad` | **Create.** All geometry: parameters, modules (`box`, `lid`, `gasket`, `assembly`, `alignment_2d`), dispatch. |
| `esp32-snowgauge-box/3mf/` | **Created by make.** 3MF output directory. |
| `esp32-snowgauge-box/esp32-snowgauge-box.png` | **Created by make.** Preview PNG of the assembled view. |
| `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf` | **Created by make.** 1:1 paper template. |
| `Makefile` | **Modify.** Add SVG → PDF routing for any design that declares the `alignment-2d` part. |
| `scripts/svg-to-pdf.sh` | **Create.** Thin wrapper around `rsvg-convert` so the Makefile stays clean. |
| `README.md` | **Modified by make.** Catalog block regenerates automatically on `make readme`. |

### Coordinate convention

The cavity floor's inside-front-left corner is at `(0, 0, 0)`:
- `+X` = along the long axis of the box (left → right in the viewer, 180 mm internal).
- `+Y` = along the short axis (70 mm internal).
- `+Z` = up (31 mm internal).

Everything in the `box` module is built in this frame, then the exterior walls / floor extend into `-X`, `-Y`, `-Z` as needed.

### Board placement convention

- Board right short-end sits at `x = cavity_x - board_right_gap` (right-wall clearance 4 mm).
- Board back (far-Y) edge sits at `y = cavity_y - 5` mm.
- The board's **7.5 mm (tight) short-end** faces +X (the inner right wall). The **9.5 mm (loose) short-end** faces −X (into the open 90 mm cavity).
- Post centres (board-local, measured from the board's right short-end and back long-edge):
  - P1: `( 7.5,  7.5)` — back-right
  - P2: `( 7.5, 52.5)` — front-right (60 − 7.5 = 52.5)
  - P3: `(72.5,  7.5)` — back-left (7.5 + 65 = 72.5)
  - P4: `(72.5, 52.5)` — front-left

Each task below shows the exact code and command. Where a step says "render and inspect", run OpenSCAD, open the generated PNG/3MF in Preview or Bambu Studio, and eyeball it against the spec — this is the equivalent of running a test for geometry work.

---

## Task 1: Scaffold the design directory and `.scad` file

**Files:**
- Create: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Create the design directory and empty .scad with the `part` declaration**

Create `esp32-snowgauge-box/esp32-snowgauge-box.scad` with:

```openscad
// ESP32 snowgauge project box — stout, outdoor, gasketed.
// Spec: docs/superpowers/specs/2026-11-16-esp32-snowgauge-box-design.md

/* [Part] */
// all = assembled preview; box/lid/gasket = printable 3D parts;
// alignment-2d = 1:1 paper template exported to PDF.
part = "all"; // [all, box, lid, gasket, alignment-2d]

$fa = 2;
$fs = 0.3;

// Dispatch — filled in by later tasks.
if (part == "all") {}
else if (part == "box") {}
else if (part == "lid") {}
else if (part == "gasket") {}
else if (part == "alignment-2d") {}
```

- [ ] **Step 2: Verify `make list` discovers the new design and all five parts**

Run: `make list`
Expected: Output includes
```
esp32-snowgauge-box/esp32-snowgauge-box.scad
  - box
  - lid
  - gasket
  - alignment-2d
```
(`all` is omitted by the parts script — that's correct.)

- [ ] **Step 3: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: scaffold .scad with Customizer parts"
```

---

## Task 2: Define parameters and post-position helpers

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad` (parameters block + helpers)

- [ ] **Step 1: Add parameters below the `part` block (before the dispatch)**

Insert this block after the `$fs = 0.3;` line and before the `// Dispatch` comment:

```openscad
/* [Board] */
board_x        = 82.5;   // long axis of the board
board_y        = 60.0;   // short axis of the board
hole_spacing_x = 65;     // long-axis centre-to-centre
hole_spacing_y = 45;     // short-axis centre-to-centre
hole_edge_tight = 7.5;   // tight-end: distance from short-edge to nearest hole
hole_edge_loose = 9.5;   // loose-end: distance from other short-edge to nearest hole
hole_edge_y     = 7.5;   // long-edge to nearest hole (symmetric)

/* [Cavity] */
cavity_x        = 180;   // internal X
cavity_y        =  70;   // internal Y
cavity_z        =  31;   // internal Z (post height + 25 mm headroom)
board_right_gap =   4;   // clearance from board right short-end to inner right wall
board_y_gap     =   5;   // clearance from board long edges to long inner walls

/* [Shell] */
wall_t     = 8;   // side wall thickness (doubles as gasket flange width)
floor_t    = 5;   // floor thickness
lid_t      = 6;   // lid thickness

/* [Mount posts — M3 heat-set] */
post_od       = 8.0;
post_h        = 6.0;
post_bore_d   = 4.2;
post_bore_h   = 6.0;
post_chamfer  = 0.5;

/* [Corner bosses — M4 heat-set] */
boss_od           = 11.0;
boss_insert_d     = 5.7;
boss_insert_depth = 9.0;

/* [Lid] */
lid_overhang    = 2;    // XY oversize on every side vs. box exterior
drip_lip_h      = 3;    // vertical height of the drip-edge lip
drip_lip_t      = 2;    // thickness of the drip-edge lip
m4_clear_d      = 4.5;
m4_head_d       = 7.5;  // counterbore diameter
m4_head_depth   = 4.5;  // counterbore depth

/* [Gasket] */
gasket_t = 3;

/* [Alignment PDF] */
cal_square_mm = 10;   // calibration-square edge length (must measure 10 mm on paper)
```

- [ ] **Step 2: Add derived dimensions and helper functions below the parameters**

Append below the parameter block (still before dispatch):

```openscad
// --- Derived ---
exterior_x = cavity_x + 2*wall_t;    // 196
exterior_y = cavity_y + 2*wall_t;    // 86
exterior_z = cavity_z + floor_t;     // 36

// Board is anchored so its right short-end is `board_right_gap` from inner right wall.
// Board origin here = board's back-right corner in cavity coords.
board_right_x = cavity_x - board_right_gap;        // right edge of board, cavity-X
board_back_y  = cavity_y - board_y_gap;            // back edge of board, cavity-Y
board_left_x  = board_right_x - board_x;           // left edge of board
board_front_y = board_back_y  - board_y;           // front edge of board

// Hole positions in cavity-XY. Tight end (7.5 mm) faces +X (inner right wall).
function post_positions() = [
    [board_right_x - hole_edge_tight,                    board_back_y  - hole_edge_y],                 // P1 back-right
    [board_right_x - hole_edge_tight,                    board_front_y + hole_edge_y],                 // P2 front-right
    [board_right_x - hole_edge_tight - hole_spacing_x,   board_back_y  - hole_edge_y],                 // P3 back-left
    [board_right_x - hole_edge_tight - hole_spacing_x,   board_front_y + hole_edge_y]                  // P4 front-left
];

// Corner-boss centres in cavity-XY (centred in the 8 mm wall corner).
function boss_positions() = [
    [-wall_t/2,            -wall_t/2],
    [ cavity_x + wall_t/2, -wall_t/2],
    [-wall_t/2,             cavity_y + wall_t/2],
    [ cavity_x + wall_t/2,  cavity_y + wall_t/2]
];

// --- Invariants ---
assert(hole_edge_tight + hole_spacing_x + hole_edge_loose <= board_x + 0.5,
    "hole positions exceed board length");
assert(2*hole_edge_y + hole_spacing_y == board_y,
    "short-axis hole offsets don't match board width");
assert(cavity_x >= board_x + board_right_gap + 90,
    "cavity_x must leave 90 mm cavity left of board plus right-side gap");
assert(cavity_y >= board_y + 2*board_y_gap,
    "cavity_y must leave board_y_gap clearance on both long edges");
assert(exterior_x <= 256 && exterior_y <= 256,
    "box exterior must fit on the 256 mm bed");
```

- [ ] **Step 3: Render the file to confirm it parses and asserts pass**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    --imgsize=400,300 \
    -D 'part="all"' \
    -o /tmp/esp32-snowgauge-box-check.png \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: exits 0 with no `ERROR: Assertion ...` lines on stderr. (The output image will be empty because no dispatch is wired yet — that's fine.)

- [ ] **Step 4: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: parameters, derived dims, post-position helpers"
```

---

## Task 3: Implement the `box` module

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Add the `box()` module above the dispatch**

Insert this module after the invariants block and before the `// Dispatch` comment:

```openscad
module mount_post() {
    difference() {
        cylinder(h = post_h, d = post_od);
        translate([0, 0, post_h - post_bore_h])
            cylinder(h = post_bore_h + 0.01, d = post_bore_d);
        // small lead-in chamfer at the mouth of the bore
        translate([0, 0, post_h - post_chamfer])
            cylinder(h = post_chamfer + 0.01,
                     d1 = post_bore_d,
                     d2 = post_bore_d + 2*post_chamfer);
    }
}

module corner_boss(h) {
    // Full-height corner pillar with an M4 insert pocket opening on top.
    difference() {
        cylinder(h = h, d = boss_od);
        translate([0, 0, h - boss_insert_depth])
            cylinder(h = boss_insert_depth + 0.01, d = boss_insert_d);
    }
}

module box() {
    // Outer shell: subtract the cavity from a solid brick, union the posts
    // and corner bosses, then clip any boss material that pokes outside the
    // exterior footprint.
    difference() {
        union() {
            // Solid outer brick anchored so cavity-XY origin sits at (wall_t, wall_t)
            // in exterior coords. Shift the whole brick so cavity origin aligns.
            translate([-wall_t, -wall_t, -floor_t])
                cube([exterior_x, exterior_y, exterior_z]);

            // Mount posts sit on the cavity floor (z = 0).
            for (p = post_positions())
                translate([p[0], p[1], 0]) mount_post();

            // Corner bosses run full exterior height (from floor bottom to flange top).
            for (p = boss_positions())
                translate([p[0], p[1], -floor_t]) corner_boss(exterior_z);
        }

        // Cavity carve-out.
        translate([0, 0, 0])
            cube([cavity_x, cavity_y, cavity_z + 1]);  // +1 so top opens cleanly
    }

    // NOTE: corner bosses will protrude outside the exterior footprint by
    // (boss_od/2 - wall_t/2) = 1.5 mm. That protrusion gets trimmed by the
    // intersection in the next step.
}
```

- [ ] **Step 2: Wrap `box()` output in an intersection so bosses stay inside the exterior footprint**

Replace the `module box()` body with:

```openscad
module box() {
    intersection() {
        union() {
            difference() {
                union() {
                    translate([-wall_t, -wall_t, -floor_t])
                        cube([exterior_x, exterior_y, exterior_z]);
                    for (p = post_positions())
                        translate([p[0], p[1], 0]) mount_post();
                    for (p = boss_positions())
                        translate([p[0], p[1], -floor_t]) corner_boss(exterior_z);
                }
                translate([0, 0, 0])
                    cube([cavity_x, cavity_y, cavity_z + 1]);
            }
            // (nothing extra in the union — placeholder for future ribs if needed)
        }
        // Trim to exterior footprint so bosses don't bulge outside.
        translate([-wall_t, -wall_t, -floor_t - 1])
            cube([exterior_x, exterior_y, exterior_z + 2]);
    }
}
```

- [ ] **Step 3: Wire `box` into the dispatch**

Change the dispatch line:

```openscad
else if (part == "box") {}
```

to:

```openscad
else if (part == "box") box();
```

- [ ] **Step 4: Render the box as a 3MF and confirm it exports cleanly**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    -o /tmp/snowgauge-box.3mf \
    -D 'part="box"' \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: exits 0, file `/tmp/snowgauge-box.3mf` exists and is non-empty. Open it in Bambu Studio or Preview and visually confirm:
- Four mount posts inside the cavity, clustered toward the +X end.
- Four corner bosses at the exterior corners with pockets on top.
- 180 × 70 × 31 mm internal cavity, 196 × 86 × 36 mm exterior.

- [ ] **Step 5: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: box shell with posts and corner bosses"
```

---

## Task 4: Implement the `lid` module

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Add the `lid()` module above the dispatch**

Insert after `module box() { ... }`:

```openscad
module lid() {
    // Lid is modelled top-up: flat plate 6 mm thick, drip-edge lip hanging
    // down from the perimeter of the underside. XY frame is cavity-origin
    // (same as the box) so corner-boss positions match.
    lid_x = exterior_x + 2*lid_overhang;
    lid_y = exterior_y + 2*lid_overhang;

    difference() {
        union() {
            // Flat plate
            translate([-wall_t - lid_overhang, -wall_t - lid_overhang, 0])
                cube([lid_x, lid_y, lid_t]);
            // Drip-edge lip: rectangular ring hanging below the plate
            translate([-wall_t - lid_overhang, -wall_t - lid_overhang, -drip_lip_h])
                difference() {
                    cube([lid_x, lid_y, drip_lip_h]);
                    translate([drip_lip_t, drip_lip_t, -1])
                        cube([lid_x - 2*drip_lip_t,
                              lid_y - 2*drip_lip_t,
                              drip_lip_h + 2]);
                }
        }
        // M4 clearance holes + counterbores at the four corner-boss centres.
        for (p = boss_positions()) {
            translate([p[0], p[1], -drip_lip_h - 1])
                cylinder(h = drip_lip_h + lid_t + 2, d = m4_clear_d);
            translate([p[0], p[1], lid_t - m4_head_depth])
                cylinder(h = m4_head_depth + 1, d = m4_head_d);
        }
    }
}
```

- [ ] **Step 2: Wire `lid` into the dispatch**

Change:

```openscad
else if (part == "lid") {}
```

to:

```openscad
else if (part == "lid") lid();
```

- [ ] **Step 3: Render the lid and visually confirm**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    -o /tmp/snowgauge-lid.3mf \
    -D 'part="lid"' \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: 3MF exists, non-empty. Open and verify:
- 200 × 90 × 6 mm flat plate with a 3 mm lip on the underside perimeter.
- Lip wall thickness 2 mm.
- Four counterbored M4 clearance holes at the corners (centres match the box corner bosses).

- [ ] **Step 4: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: lid with drip edge and M4 counterbores"
```

---

## Task 5: Implement the `gasket` module

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Add the `gasket()` module above the dispatch**

Insert after `module lid() { ... }`:

```openscad
module gasket() {
    // Flat 3 mm ring matching the box flange outline (196 × 86) with a
    // 180 × 70 cutout and four M4 clearance holes.
    difference() {
        translate([-wall_t, -wall_t, 0])
            cube([exterior_x, exterior_y, gasket_t]);
        // Cavity opening
        translate([0, 0, -1])
            cube([cavity_x, cavity_y, gasket_t + 2]);
        // Four M4 clearance holes
        for (p = boss_positions())
            translate([p[0], p[1], -1])
                cylinder(h = gasket_t + 2, d = m4_clear_d);
    }
}
```

- [ ] **Step 2: Wire `gasket` into the dispatch**

Change:

```openscad
else if (part == "gasket") {}
```

to:

```openscad
else if (part == "gasket") gasket();
```

- [ ] **Step 3: Render and verify**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    -o /tmp/snowgauge-gasket.3mf \
    -D 'part="gasket"' \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: 196 × 86 × 3 mm ring with a 180 × 70 cutout and 4 corner holes.

- [ ] **Step 4: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: TPU gasket part"
```

---

## Task 6: Implement the assembled `all` preview

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Add the `assembly()` module**

Insert after `module gasket() { ... }`:

```openscad
module assembly() {
    box();
    // Gasket sits on the flange top (z = cavity_z).
    translate([0, 0, cavity_z])
        color("IndianRed") gasket();
    // Lid sits on top of the gasket.
    translate([0, 0, cavity_z + gasket_t])
        color("LightGray") lid();
}
```

- [ ] **Step 2: Wire the `all` dispatch**

Change:

```openscad
if (part == "all") {}
```

to:

```openscad
if (part == "all") assembly();
```

- [ ] **Step 3: Render the preview PNG**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    --imgsize=1200,900 \
    -D 'part="all"' \
    -o esp32-snowgauge-box/esp32-snowgauge-box.png \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: PNG created. Open it and confirm box + red gasket + grey lid stacked correctly.

- [ ] **Step 4: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad esp32-snowgauge-box/esp32-snowgauge-box.png
git commit -m "esp32-snowgauge-box: assembled preview"
```

---

## Task 7: Implement the 2D `alignment-2d` projection

**Files:**
- Modify: `esp32-snowgauge-box/esp32-snowgauge-box.scad`

- [ ] **Step 1: Add the `alignment_2d()` module**

Insert after `module assembly() { ... }`:

```openscad
module alignment_2d() {
    // 2D content, all in cavity-XY coords.
    line_w = 0.3;      // visible stroke width on paper
    dash_w = 0.3;
    hairline = 0.2;

    // Cavity outline — thin solid rectangle
    translate([0, 0]) difference() {
        square([cavity_x, cavity_y]);
        translate([line_w, line_w])
            square([cavity_x - 2*line_w, cavity_y - 2*line_w]);
    }

    // Board outline — dashed
    translate([board_left_x, board_front_y]) {
        dashes_x = floor(board_x / 4);
        dashes_y = floor(board_y / 4);
        // top and bottom edges
        for (i = [0 : dashes_x - 1])
            translate([i*4, 0]) square([2, dash_w]);
        for (i = [0 : dashes_x - 1])
            translate([i*4, board_y - dash_w]) square([2, dash_w]);
        // left and right edges
        for (i = [0 : dashes_y - 1])
            translate([0, i*4]) square([dash_w, 2]);
        for (i = [0 : dashes_y - 1])
            translate([board_x - dash_w, i*4]) square([dash_w, 2]);
    }

    // Post footprints (8 mm OD rings) + crosshairs
    for (p = post_positions()) {
        translate(p) difference() {
            circle(d = post_od);
            circle(d = post_od - 2*line_w);
        }
        translate(p) square([post_od + 4, line_w], center = true);
        translate(p) square([line_w, post_od + 4], center = true);
    }

    // Corner-boss footprints (11 mm OD rings, thin "ref" lines)
    for (p = boss_positions())
        translate(p) difference() {
            circle(d = boss_od);
            circle(d = boss_od - 2*hairline);
        }

    // 10 mm calibration square — solid outlined square in the lower-left
    // corner of the cavity frame, inside the cavity so it's always on the sheet.
    translate([5, 5]) difference() {
        square([cal_square_mm, cal_square_mm]);
        translate([line_w, line_w])
            square([cal_square_mm - 2*line_w, cal_square_mm - 2*line_w]);
    }

    // Labels — text() outputs filled glyphs, exported as paths by OpenSCAD SVG.
    translate([5, 5 + cal_square_mm + 2])
        text("Print at 100% — square must measure 10 mm",
             size = 3, font = "Liberation Sans");
    translate([board_left_x, board_front_y - 5])
        text(str("hole spacing: ", hole_spacing_x, " x ", hole_spacing_y, " mm"),
             size = 3, font = "Liberation Sans");
    translate([board_left_x, board_back_y + 2])
        text(str("edge offsets: ", hole_edge_loose, " / ", hole_edge_tight,
                 " mm long-axis, ", hole_edge_y, " mm short-axis"),
             size = 3, font = "Liberation Sans");
}
```

- [ ] **Step 2: Wire the `alignment-2d` dispatch**

Change:

```openscad
else if (part == "alignment-2d") {}
```

to:

```openscad
else if (part == "alignment-2d") alignment_2d();
```

- [ ] **Step 3: Export the SVG and open it**

Run:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
    -o /tmp/snowgauge-alignment.svg \
    -D 'part="alignment-2d"' \
    esp32-snowgauge-box/esp32-snowgauge-box.scad
```
Expected: SVG created. Open it in a browser or Preview. Verify:
- Cavity rectangle.
- Dashed board outline.
- Four post rings with crosshairs clustered on the +X end.
- Four boss rings at the corners.
- Calibration square + label.
- Dimension labels readable.

- [ ] **Step 4: Measure the calibration square in the SVG (sanity check)**

Open `/tmp/snowgauge-alignment.svg` in a text editor and look at the root `<svg>` element's `width` / `height` / `viewBox`. They should be in units that map 1 mm → 1 unit. If OpenSCAD emits a non-`mm` unit the next task (SVG → PDF) will correct the scaling, but note which units came out so you catch surprises early.

Run:
```bash
head -5 /tmp/snowgauge-alignment.svg
```

- [ ] **Step 5: Commit**

```bash
git add esp32-snowgauge-box/esp32-snowgauge-box.scad
git commit -m "esp32-snowgauge-box: 2D alignment template"
```

---

## Task 8: Add SVG → PDF pipeline

**Files:**
- Create: `scripts/svg-to-pdf.sh`
- Modify: `Makefile`

- [ ] **Step 1: Verify `rsvg-convert` is installed**

Run: `which rsvg-convert && rsvg-convert --version`
Expected: a path like `/opt/homebrew/bin/rsvg-convert` and a version line.

If missing:
```bash
brew install librsvg
```

- [ ] **Step 2: Create `scripts/svg-to-pdf.sh`**

Create the file with:

```bash
#!/usr/bin/env bash
# svg-to-pdf.sh — convert an OpenSCAD-emitted SVG to a 1:1 PDF.
# Usage: svg-to-pdf.sh <input.svg> <output.pdf>
#
# OpenSCAD SVG exports use `mm` as the user unit. rsvg-convert's --format pdf
# preserves the native units, so a 10 mm calibration square in the .scad ends
# up as a 10 mm square on the page.
set -euo pipefail

in="${1:?usage: svg-to-pdf.sh <input.svg> <output.pdf>}"
out="${2:?usage: svg-to-pdf.sh <input.svg> <output.pdf>}"

rsvg-convert --format=pdf --output="$out" "$in"
```

Then:
```bash
chmod +x scripts/svg-to-pdf.sh
```

- [ ] **Step 3: Teach the Makefile about the `alignment-2d` part**

Open `Makefile`. Locate the `multi_part_rules` define (the block beginning `define multi_part_rules`). Replace it with:

```make
# Multi-part design: one 3MF per declared part.
# Parts named `alignment-2d` get routed through SVG → PDF instead of 3MF.
# Args: $(1)=scad path, $(2)=space-separated parts list
define multi_part_rules
ALL_3MF += $(foreach p,$(filter-out alignment-2d,$(2)),$(dir $(1))3mf/$(basename $(notdir $(1)))-$(p).3mf)

ifneq ($(filter alignment-2d,$(2)),)
ALL_PDF += $(dir $(1))$(basename $(notdir $(1)))-alignment.pdf

$(dir $(1))$(basename $(notdir $(1)))-alignment.pdf: $(1)
	@mkdir -p $$(@D)
	$$(OPENSCAD) -o $$(@:.pdf=.svg) -D 'part="alignment-2d"' $$<
	$(CURDIR)/scripts/svg-to-pdf.sh $$(@:.pdf=.svg) $$@
	@rm -f $$(@:.pdf=.svg)
endif

$(dir $(1))3mf/$(basename $(notdir $(1)))-%.3mf: $(1)
	@mkdir -p $$(@D)
	$$(OPENSCAD) -o $$@ -D 'part="$$*"' $$<
endef
```

- [ ] **Step 4: Add `ALL_PDF` to the top of the Makefile and include it in `all`**

Near the top of the file, find:

```make
ALL_3MF :=
ALL_PNG :=
```

Change to:

```make
ALL_3MF :=
ALL_PNG :=
ALL_PDF :=
```

Then find:

```make
all: $(ALL_3MF) $(ALL_PNG) readme
```

Change to:

```make
all: $(ALL_3MF) $(ALL_PNG) $(ALL_PDF) readme
```

And in the `clean` target, change:

```make
clean:
	rm -f $(ALL_3MF) $(ALL_PNG)
```

to:

```make
clean:
	rm -f $(ALL_3MF) $(ALL_PNG) $(ALL_PDF)
```

- [ ] **Step 5: Run `make list` and `make esp32-snowgauge-box`**

Run: `make list`
Expected: the five parts (`box`, `lid`, `gasket`, `alignment-2d`) still listed for the design.

Run: `make esp32-snowgauge-box`
Expected: three 3MFs, one PNG, and one PDF produced:
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-box.3mf`
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-lid.3mf`
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-gasket.3mf`
- `esp32-snowgauge-box/esp32-snowgauge-box.png`
- `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf`

- [ ] **Step 6: Verify the PDF measures 1:1**

Open `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf` in Preview. Zoom to actual size (⌘0 then ⌘1 in Preview) and use the Tools → Show Inspector → Measure (or print a test page). The 10 mm calibration square must measure 10 mm with a ruler.

If the PDF is scaled wrong (square measures ≠ 10 mm), check which unit OpenSCAD emitted in the SVG header. `rsvg-convert` honours `mm` natively; if the header is unitless, add `--page-width=<X>mm --page-height=<Y>mm --fit` flags to the `rsvg-convert` call in `scripts/svg-to-pdf.sh` where `X`, `Y` are the SVG viewBox dimensions in mm.

- [ ] **Step 7: Commit**

```bash
git add scripts/svg-to-pdf.sh Makefile
git commit -m "make: route alignment-2d parts through SVG -> PDF"
```

---

## Task 9: Final build, catalog refresh, and artifact commit

**Files:**
- Modify (by make): `README.md`
- Create (by make): `esp32-snowgauge-box/3mf/*.3mf`, `esp32-snowgauge-box/esp32-snowgauge-box.png`, `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf`

- [ ] **Step 1: Clean and rebuild from scratch**

Run:
```bash
make clean
make
```
Expected: exits 0. All designs rebuild. No errors.

- [ ] **Step 2: Confirm the catalog block was updated**

Run: `grep -A2 "esp32-snowgauge-box" README.md | head -10`
Expected: a catalog entry for the new design appears between the `<!-- designs:start -->` / `<!-- designs:end -->` markers.

- [ ] **Step 3: Visual review of the generated artifacts**

Open each file and eyeball it:
- `esp32-snowgauge-box/esp32-snowgauge-box.png` — stacked box + gasket + lid preview.
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-box.3mf` — load in Bambu Studio; confirm posts/bosses/cavity.
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-lid.3mf` — flat plate with drip lip and counterbored holes.
- `esp32-snowgauge-box/3mf/esp32-snowgauge-box-gasket.3mf` — 196 × 86 × 3 ring with a 180 × 70 cutout.
- `esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf` — print a page, lay the board on it, verify holes align with post crosshairs.

- [ ] **Step 4: Commit all generated artifacts**

```bash
git add esp32-snowgauge-box/3mf \
        esp32-snowgauge-box/esp32-snowgauge-box.png \
        esp32-snowgauge-box/esp32-snowgauge-box-alignment.pdf \
        README.md
git commit -m "esp32-snowgauge-box: ship 3MFs, preview, and 1:1 alignment PDF"
```

---

## Self-Review Checklist (completed before handoff)

- **Spec coverage:** every section of the spec (purpose, cavity dims, posts, bosses, flange, lid, gasket, alignment PDF, assembly stack-up) maps to a task above. ✅
- **No placeholders:** no TBD/TODO markers; every step has either exact code or an exact command with expected output. ✅
- **Type/name consistency:** `post_positions()`, `boss_positions()`, `mount_post()`, `corner_boss()`, `box()`, `lid()`, `gasket()`, `assembly()`, `alignment_2d()` used identically everywhere. ✅
- **Conventions:** `part` Customizer variable with `"all"` default and `all` first in the list; outputs follow repo layout. ✅
- **Bed fit assert** present (`exterior_x <= 256 && exterior_y <= 256`). ✅
