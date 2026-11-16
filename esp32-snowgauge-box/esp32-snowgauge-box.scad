// ESP32 snowgauge project box — stout, outdoor, gasketed.
// Spec: docs/superpowers/specs/2026-11-16-esp32-snowgauge-box-design.md

/* [Part] */
// all = assembled preview; box/lid/gasket = printable 3D parts;
// alignment-2d = 1:1 paper template exported to PDF.
part = "lid"; // [all, box, lid, gasket, sensor-gasket, alignment-2d]

$fa = 2;
$fs = 0.3;

/* [Board] */
board_x        = 82.5;
board_y        = 60.0;
hole_spacing_x = 65;
hole_spacing_y = 45;
hole_edge_tight = 7.5;
hole_edge_loose = 9.5;
hole_edge_y     = 7.5;

/* [Cavity] */
cavity_x        = 190;   // 15 (right gap) + 82.5 (board) + 92.5 (open cavity)
cavity_y        =  90;
cavity_z        =  31;
board_right_gap =  15;   // clearance from board right short-end to inner right wall (fits right-side pad)
board_y_gap     =  15;   // clearance from board long edges (fits Y-side pads)

/* [Shell] */
wall_t     = 8;
floor_t    = 5;
lid_t      = 6;

/* [Mount posts — M3 heat-set] */
post_od       = 8.0;
post_h        = 6.0;
post_bore_d   = 4.2;
post_bore_h   = 6.0;
post_chamfer  = 0.5;

/* [Corner pillars — M4 heat-set] */
pillar_od           = 11.0;   // nominal boss OD (only used for insert spacing checks)
pillar_insert_d     = 5.7;
pillar_insert_depth = 9.0;
pillar_extension    = 3.0;   // height pillars project above wall top (must equal gasket_t)

// Rounded-pad pillars: each pillar is a rectangular pad in the inside wall
// corner with the cavity-facing corner filleted. The M4 insert pocket sits
// in the solid near-wall region.
pad_size            = 14;    // length along each wall from the inside corner
pad_fillet_r        =  6;    // cavity-facing corner radius
pillar_insert_offset = 4;    // M4 insert centre offset from each wall (into the pad)

/* [Lid] */
m4_clear_d      = 4.5;
m4_head_d       = 7.5;
m4_head_depth   = 4.5;

/* [Zip-tie mounting channels] */
// Two ties strap the enclosure to a 2" square post. On the box long walls,
// the channel is formed by raised rails bumped OUT from the wall so the wall
// stays full thickness at the gasket contact plane. On the lid (which has no
// gasket seal on those faces), the channel is cut in as usual.
tie_w        = 7;      // tie width (channel width along X)
tie_d        = 1.6;    // tie thickness (channel depth = rail height)
tie_rail_w   = 2;      // width of each raised rail flanking the channel
tie_x_a      = 50;     // X of the first tie (clear of the sensor hole at X=15..41)
tie_x_b      = 150;    // X of the second tie

/* [Gasket] */
gasket_t = 3;

/* [Snow sensor penetration] */
sensor_hole_d       = 26.35;   // lid clearance hole for the sensor body
sensor_hole_offset  = 28;      // centre offset from the back-left corner (same on X and Y)

/* [Sensor gasket — printable ring] */
sensor_gasket_id = 26.25;
sensor_gasket_od = 35.0;
sensor_gasket_t  = 3.0;

/* [Cable gland] */
cable_gland_d = 12.5;
cable_gland_y = 22;   // centre Y (from front wall) along the left short-edge wall
cable_gland_z = 10;   // centre Z above cavity floor

/* [Alignment PDF] */
cal_square_mm = 10;

// --- Derived ---
wall_ext_x = cavity_x + 2*wall_t;    // 201
wall_ext_y = cavity_y + 2*wall_t;    // 101
exterior_z = cavity_z + floor_t;     // 36 (walls run floor bottom -> wall top)

board_right_x = cavity_x - board_right_gap;
board_back_y  = cavity_y - board_y_gap;
board_left_x  = board_right_x - board_x;
board_front_y = board_back_y  - board_y;

function post_positions() = [
    [board_right_x - hole_edge_tight,                    board_back_y  - hole_edge_y],
    [board_right_x - hole_edge_tight,                    board_front_y + hole_edge_y],
    [board_right_x - hole_edge_tight - hole_spacing_x,   board_back_y  - hole_edge_y],
    [board_right_x - hole_edge_tight - hole_spacing_x,   board_front_y + hole_edge_y]
];

// M4 insert centres sit in the thick near-wall portion of each corner pad,
// offset pillar_insert_offset from both inner wall surfaces.
function pillar_positions() = [
    [pillar_insert_offset,              pillar_insert_offset],
    [cavity_x - pillar_insert_offset,   pillar_insert_offset],
    [pillar_insert_offset,              cavity_y - pillar_insert_offset],
    [cavity_x - pillar_insert_offset,   cavity_y - pillar_insert_offset]
];

// Signs mapping each corner (in pillar_positions order) to its direction of
// pad extension from the inside wall corner into the cavity.
function pad_signs() = [[ 1,  1], [-1,  1], [ 1, -1], [-1, -1]];
function pad_corners() = [
    [0, 0],
    [cavity_x, 0],
    [0, cavity_y],
    [cavity_x, cavity_y]
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
assert(wall_ext_x <= 256 && wall_ext_y <= 256,
    "box exterior must fit on the 256 mm bed");
assert(pillar_extension == gasket_t,
    "pillar_extension must equal gasket_t so pillar tops sit flush with gasket top");
assert(board_right_gap >= pad_size + 1,
    "board right edge collides with right-side corner pads — increase board_right_gap");
assert(board_y_gap >= pad_size + 1,
    "board long edges collide with Y-side corner pads — increase board_y_gap");
assert(pad_fillet_r < pad_size,
    "pad_fillet_r must be smaller than pad_size");
assert(pillar_insert_offset + pillar_insert_d/2 + 1.5 <= pad_size,
    "M4 pocket wall too thin — move pillar_insert_offset or grow pad_size");

module mount_post() {
    difference() {
        cylinder(h = post_h, d = post_od);
        translate([0, 0, post_h - post_bore_h])
            cylinder(h = post_bore_h + 0.01, d = post_bore_d);
        translate([0, 0, post_h - post_chamfer])
            cylinder(h = post_chamfer + 0.01,
                     d1 = post_bore_d,
                     d2 = post_bore_d + 2*post_chamfer);
    }
}

// 2D rounded pad footprint, anchored at (0, 0) with the inside wall corner
// there and the pad body extending +X +Y into the cavity. The cavity-facing
// corner (at (pad_size, pad_size)) is filleted to pad_fillet_r.
module corner_pad_2d() {
    hull() {
        square([pad_size,        0.01]);
        square([    0.01,    pad_size]);
        translate([pad_size - pad_fillet_r, pad_size - pad_fillet_r])
            circle(r = pad_fillet_r);
    }
}

module box() {
    pillar_h = cavity_z + pillar_extension;

    difference() {
        union() {
            // Shell: brick with cavity carved out
            difference() {
                translate([-wall_t, -wall_t, -floor_t])
                    cube([wall_ext_x, wall_ext_y, exterior_z]);
                translate([0, 0, 0])
                    cube([cavity_x, cavity_y, cavity_z + 1]);
            }
            // Mount posts (board standoffs)
            for (p = post_positions())
                translate([p[0], p[1], 0]) mount_post();
            // Four rounded corner pads — M4 inserts live at the top of these.
            for (i = [0 : 3]) {
                c = pad_corners()[i];
                s = pad_signs()[i];
                translate([c[0], c[1], 0])
                    linear_extrude(pillar_h)
                        scale([s[0], s[1]]) corner_pad_2d();
            }
            // Zip-tie bosses: raised slabs on each long wall. Extend up
            // through the gasket Z-range so the channel meets the lid boss
            // flush — no wall-top material appears above the channel.
            tie_boss_w = tie_w + 2*tie_rail_w;
            boss_h    = cavity_z + floor_t + gasket_t;   // floor bottom to gasket top
            for (xc = [tie_x_a, tie_x_b]) {
                translate([xc - tie_boss_w/2, -wall_t - tie_d, -floor_t])
                    cube([tie_boss_w, tie_d, boss_h]);
                translate([xc - tie_boss_w/2, cavity_y + wall_t, -floor_t])
                    cube([tie_boss_w, tie_d, boss_h]);
            }
        }
        // M4 insert pockets as a final subtract so wall material can't fill
        // them in.
        for (p = pillar_positions())
            translate([p[0], p[1], pillar_h - pillar_insert_depth])
                cylinder(h = pillar_insert_depth + 0.01, d = pillar_insert_d);
        // Cable gland: horizontal hole through the left short-edge wall.
        translate([-wall_t - 1, cable_gland_y, cable_gland_z])
            rotate([0, 90, 0])
                cylinder(h = wall_t + 2, d = cable_gland_d);
        // Zip-tie channels: cut out of the bumped-out bosses on each long
        // wall, back to the original wall surface. Cut spans the full boss
        // height (floor bottom to gasket top) so the channel is open-ended.
        for (xc = [tie_x_a, tie_x_b]) {
            translate([xc - tie_w/2, -wall_t - tie_d - 0.01, -floor_t - 0.01])
                cube([tie_w, tie_d + 0.01, cavity_z + floor_t + gasket_t + 0.02]);
            translate([xc - tie_w/2, cavity_y + wall_t, -floor_t - 0.01])
                cube([tie_w, tie_d + 0.01, cavity_z + floor_t + gasket_t + 0.02]);
        }
    }
}

module gasket() {
    // Simple rectangular ring: outer edge at wall exterior, inner cutout at
    // cavity opening. No bolt holes — the four pillars project up through
    // the open centre of the gasket, so the bolts never pierce it.
    difference() {
        translate([-wall_t, -wall_t, 0])
            cube([wall_ext_x, wall_ext_y, gasket_t]);
        translate([0, 0, -1])
            cube([cavity_x, cavity_y, gasket_t + 2]);
    }
}

module lid() {
    // Flat plate flush with the box exterior (no overhang, no drip edge).
    tie_boss_w = tie_w + 2*tie_rail_w;
    difference() {
        union() {
            translate([-wall_t, -wall_t, 0])
                cube([wall_ext_x, wall_ext_y, lid_t]);
            // Zip-tie bosses on both long edges — match the box bosses so
            // the channel is continuous from box bottom to lid top.
            for (xc = [tie_x_a, tie_x_b]) {
                translate([xc - tie_boss_w/2, -wall_t - tie_d, 0])
                    cube([tie_boss_w, tie_d, lid_t]);
                translate([xc - tie_boss_w/2, cavity_y + wall_t, 0])
                    cube([tie_boss_w, tie_d, lid_t]);
            }
        }
        // M4 clearance holes at pillar positions, counterbored on top face.
        for (p = pillar_positions()) {
            translate([p[0], p[1], -1])
                cylinder(h = lid_t + 2, d = m4_clear_d);
            translate([p[0], p[1], lid_t - m4_head_depth])
                cylinder(h = m4_head_depth + 1, d = m4_head_d);
        }
        // Snow sensor pass-through at the back-left corner (away from board).
        translate([sensor_hole_offset,
                   cavity_y - sensor_hole_offset,
                   -1])
            cylinder(h = lid_t + 2, d = sensor_hole_d);
        // Zip-tie channels: cut back through the bosses to the lid edge,
        // plus a channel across the top face (ground-facing in use).
        for (xc = [tie_x_a, tie_x_b]) {
            // Top face channel — extends over the boss bumps on each edge.
            translate([xc - tie_w/2, -wall_t - tie_d - 0.01, lid_t - tie_d])
                cube([tie_w, wall_ext_y + 2*tie_d + 0.02, tie_d + 1]);
            // Front edge boss channel
            translate([xc - tie_w/2, -wall_t - tie_d - 0.01, -1])
                cube([tie_w, tie_d + 0.01, lid_t + 2]);
            // Back edge boss channel
            translate([xc - tie_w/2, cavity_y + wall_t, -1])
                cube([tie_w, tie_d + 0.01, lid_t + 2]);
        }
    }
}

module sensor_gasket() {
    // Flat round ring for sealing around the snow sensor at the lid face.
    difference() {
        cylinder(h = sensor_gasket_t, d = sensor_gasket_od);
        translate([0, 0, -1])
            cylinder(h = sensor_gasket_t + 2, d = sensor_gasket_id);
    }
}

module assembly() {
    box();
    // Main gasket sits on wall top (z = cavity_z).
    translate([0, 0, cavity_z])
        color("IndianRed") gasket();
    // Lid sits on gasket top (z = cavity_z + gasket_t) — same plane as pillar tops.
    translate([0, 0, cavity_z + gasket_t])
        color("LightGray") lid();
    // Sensor gasket sits on top of the lid, concentric with the sensor hole.
    translate([sensor_hole_offset,
               cavity_y - sensor_hole_offset,
               cavity_z + gasket_t + lid_t])
        color("IndianRed") sensor_gasket();
}

module alignment_2d() {
    line_w = 0.3;
    dash_w = 0.3;
    hairline = 0.2;

    // Cavity outline
    difference() {
        square([cavity_x, cavity_y]);
        translate([line_w, line_w])
            square([cavity_x - 2*line_w, cavity_y - 2*line_w]);
    }

    // Board outline — dashed
    translate([board_left_x, board_front_y]) {
        dashes_x = floor(board_x / 4);
        dashes_y = floor(board_y / 4);
        for (i = [0 : dashes_x - 1])
            translate([i*4, 0]) square([2, dash_w]);
        for (i = [0 : dashes_x - 1])
            translate([i*4, board_y - dash_w]) square([2, dash_w]);
        for (i = [0 : dashes_y - 1])
            translate([0, i*4]) square([dash_w, 2]);
        for (i = [0 : dashes_y - 1])
            translate([board_x - dash_w, i*4]) square([dash_w, 2]);
    }

    // Board mount-post footprints
    for (p = post_positions()) {
        translate(p) difference() {
            circle(d = post_od);
            circle(d = post_od - 2*line_w);
        }
        translate(p) square([post_od + 4, line_w], center = true);
        translate(p) square([line_w, post_od + 4], center = true);
    }

    // Rounded corner-pad footprints (outline only) + insert crosshairs
    for (i = [0 : 3]) {
        c = pad_corners()[i];
        s = pad_signs()[i];
        translate(c) scale([s[0], s[1]]) difference() {
            corner_pad_2d();
            offset(delta = -line_w) corner_pad_2d();
        }
    }
    for (p = pillar_positions()) {
        translate(p) difference() {
            circle(d = pillar_insert_d);
            circle(d = pillar_insert_d - 2*line_w);
        }
        translate(p) square([pillar_insert_d + 3, line_w], center = true);
        translate(p) square([line_w, pillar_insert_d + 3], center = true);
    }

    // Calibration square
    translate([5, 5]) difference() {
        square([cal_square_mm, cal_square_mm]);
        translate([line_w, line_w])
            square([cal_square_mm - 2*line_w, cal_square_mm - 2*line_w]);
    }

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

// Dispatch
if      (part == "all")          assembly();
else if (part == "box")          box();
else if (part == "lid")          lid();
else if (part == "gasket")        gasket();
else if (part == "sensor-gasket") sensor_gasket();
else if (part == "alignment-2d")  alignment_2d();