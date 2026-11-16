// ESP32 snowgauge project box — stout, outdoor, gasketed.
// Spec: docs/superpowers/specs/2026-11-16-esp32-snowgauge-box-design.md

/* [Part] */
// all = assembled preview; box/lid/gasket = printable 3D parts;
// alignment-2d = 1:1 paper template exported to PDF.
part = "all"; // [all, box, lid, gasket, alignment-2d]

$fa = 2;
$fs = 0.3;

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
    intersection() {
        union() {
            // Shell: brick with cavity carved out
            difference() {
                translate([-wall_t, -wall_t, -floor_t])
                    cube([exterior_x, exterior_y, exterior_z]);
                translate([0, 0, 0])
                    cube([cavity_x, cavity_y, cavity_z + 1]);
            }
            // Mount posts sit on the cavity floor (added after cavity carve-out).
            for (p = post_positions())
                translate([p[0], p[1], 0]) mount_post();
            // Corner bosses run full exterior height.
            for (p = boss_positions())
                translate([p[0], p[1], -floor_t]) corner_boss(exterior_z);
        }
        // Trim to exterior footprint so bosses don't bulge outside.
        translate([-wall_t, -wall_t, -floor_t - 1])
            cube([exterior_x, exterior_y, exterior_z + 2]);
    }
}

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

module assembly() {
    box();
    // Gasket sits on the flange top (z = cavity_z).
    translate([0, 0, cavity_z])
        color("IndianRed") gasket();
    // Lid sits on top of the gasket.
    translate([0, 0, cavity_z + gasket_t])
        color("LightGray") lid();
}

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

// Dispatch — filled in by later tasks.
if (part == "all") assembly();
else if (part == "box") box();
else if (part == "lid") lid();
else if (part == "gasket") gasket();
else if (part == "alignment-2d") alignment_2d();
