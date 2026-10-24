// 256x128 RGB LED matrix display frame - v2 (picture-frame style).
//
// Rework of the v1 bezel enclosure. Instead of a snap-together bezel that
// overlaps the panel face, this is a true 4-rail picture frame with mitered
// corners. The panel is captured from behind by inward tabs ("ears") that
// bolt into the panel's own M3 threaded inserts.
//
//   - Panel face is flush with the frame's front edge: no pixels covered.
//   - 4 rails join on 45-degree miters at the corners. Each corner has
//     two tiers of bell-curve "knuckles": the horizontal rail carries an
//     8 mm pin at each end, the vertical rail carries a matching socket.
//     CA glue goes in the sockets only; the miter faces stay dry.
//   - Matrix Portal S3 recesses into the bottom rail from the back.
//   - USB-C, RESET/BOOT, and the NeoPixel are exposed through small cutouts.
//
// Each horizontal rail is 268 mm long - won't fit a 256 bed in default
// orientation. Rotate to roughly 30-deg diagonal on the plate (or auto-
// arrange will usually figure it out).

include <BOSL2/std.scad>

/* [Part] */
// all = assembled preview; exploded = corners pulled apart;
// the rest are printable parts.
part = "exploded"; // [all, exploded, top_rail, bottom_rail, side_rail, hanger, alignment]

/* [Preview] */
explode_gap = 20;   // mm to pull each rail outward in the exploded view

/* [Panel] */
panel_w = 256;      // long axis (X)
panel_h = 128;      // short axis (Y)
panel_d = 14.25;    // thickness (into the frame, -Z)
panel_tol = 0.3;    // extra clearance per side when seating in frame

/* [Frame geometry] */
wall           = 6;     // perimeter wall thickness around the panel
rear_depth     = 35;    // depth behind the panel for the controller
front_lip      = 0;     // 0 = panel face flush with frame front (no bezel)
corner_r       = 2;     // outer corner rounding of each rail
front_chamfer  = 1.5;   // chamfer on the front outer edge
back_chamfer   = 1.5;   // chamfer on the back outer edge

/* [Ears - M3 panel attachment] */
// Measured insert positions on the back of the panel (panel-local X,Y).
// Each ear mounts to the nearest rail and places a hole exactly at the
// insert position so the M3 screw lines up without play.
//
// Measured from your panel:
//   B,C (top edge)   : spacing B-C = 66 mm,  C-F = 108 mm -> X=+/-33, Y=+54
//   G,F (bottom edge): spacing G-F = 66 mm,  B-G = 108 mm -> X=+/-33, Y=-54
//   A,H (left edge)  : spacing A-H = 60 mm                -> X=side_insert_x, Y=+/-30
//   D,E (right edge) : spacing D-E = 60 mm                -> X=+side_insert_x, Y=+/-30
// side_insert_x isn't in your note; measure the X coordinate of A relative
// to the panel's left edge (-128) and update if different.
// Measured: A <-> D = 240 mm center-to-center -> A,H,D,E at X = +/-120.
side_insert_x    = 120;

// Bell-curve-tapered ear: wide base at the rail, narrows smoothly to a
// tip just past the hole. Also thicker in Z (extending BACKWARD from the
// panel back - can't thicken toward the front because the panel is there).
ear_base_width   = 24;   // X (or Y for side rails) at the rail attachment
ear_tip_width    = 10;   // narrow dimension at the free tip
ear_thickness    = 10;   // ear thickness in Z (doubled; back-swept only)
ear_slices       = 10;   // bell-curve smoothness
ear_tip_past_hole = 4;   // tip extends past the hole center
ear_m3_clear     = 3.4;
ear_washer_cbore = 7;
ear_washer_depth = 1;
// Gusset that ties the ear's rear face back into the rail body. The Y-into-
// rail dimension is capped by the perimeter wall thickness; the Z-into-
// cavity dimension can be larger.
ear_gusset_back_z = 10;   // how far gusset reaches backward in Z (into rear cavity)
ear_gusset_into_rail = 4; // how far gusset reaches into the rail body (<= wall)
ear_gusset_width  = 20;   // gusset width along the rail (X for top, Y for sides)

top_inserts    = [[-33, +54], [+33, +54]];                   // B, C
bottom_inserts = [[-33, -54], [+33, -54]];                   // G, F
left_inserts   = [[-side_insert_x, +30], [-side_insert_x, -30]]; // A, H
right_inserts  = [[+side_insert_x, +30], [+side_insert_x, -30]]; // D, E

/* [Miter joint - corner knuckles] */
// Each mitered corner has two tiers of bell-curve knuckles stacked in Z.
// Horizontal rails carry pins at both ends (printed sticking up in print
// orientation), vertical rails carry matching sockets. Tier 1 sits just
// behind the panel; tier 2 sits flush with the rear face.
//
// The pin/socket axis sits INSIDE the knuckle, not at its tip - the
// knuckle extends past the pin axis so the pin is fully buried in
// material (strong attachment, complete socket wall all around).
corner_knuckle_t         = 6;    // Z thickness of each knuckle
corner_pin_d             = 8;    // pin diameter
corner_pin_tol           = 0.3;  // per-side clearance between pin and socket
corner_pin_len           = 6;    // pin length - matches knuckle_t for a thru-fit
corner_knuckle_base_w    = 20;   // bell-curve width at the rail inner edge
corner_knuckle_tip_w     = 12;   // bell-curve width at the knuckle tip
corner_knuckle_depth     = 20;   // depth from inner edge to knuckle tip
corner_pin_axis_depth    = 10;   // depth from inner edge to pin/socket axis
// Z budget: 35 mm rear cavity, 4 knuckles * 6 mm = 24 mm consumed,
// leaving 11 mm of air between tier 1 socket bottom and tier 2 pin knuckle
// top. That 11 mm is the ASSEMBLY CLEARANCE - the socket rail can be
// positioned up to 11 mm below its final Z and slid axially into
// engagement without any knuckle-to-knuckle collision.

/* [Matrix Portal S3 recess] */
// The Portal mounts under a pad on the inside of the bottom rail with its
// COMPONENT side (HUB75, USB-C, buttons, LEDs) facing TOWARD the back of
// the frame. Pad holds the bosses facing down; Portal clean side faces up
// toward the panel. A back-wall section anchors the whole mount box to the
// bed during printing.
// Portal rotated 90 deg from the stock Adafruit orientation. The board's
// LONG axis now runs in Y (perpendicular to the bottom rail), with the
// USB-C port and RESET/UP/DOWN buttons on the -Y short edge so they sit
// against the frame's outer wall. A channel through that wall gives
// cable + finger access to all of them in one cutout.
//
// All dimensions measured from the Adafruit 5778 board drawing:
//   board: 2.50 x 1.75 in = 63.50 x 44.45 mm
//   hole pattern (4 corners): 1.60 x 0.78 in = 40.64 x 19.81 mm
// After the 90 deg rotation: long axis along Y, short axis along X.
portal_x_offset       = 85;    // keeps the pad clear of the G/F ears
portal_hole_dx        = 19.81; // X (short-axis) spacing of mounting holes
portal_hole_dy        = 40.64; // Y (long-axis) spacing of mounting holes
portal_board_w        = 44.45; // X extent (short board dim)
portal_board_h        = 63.50; // Y extent (long board dim) - starts at frame outer face
portal_board_t        = 1.6;
portal_component_h    = 15;
portal_boss_od        = 10;
// Boss height brings the Portal clean side up to the lower edge of the
// access window (model Z=-29). Portal body then sits across the window
// so the USB-C port and switches are reachable through the opening.
portal_boss_h         = 7;
portal_insert_d       = 4.8;    // 0.2 mm smaller than a 5mm-OD M3 insert so
                                // the knurls bite as the barrel heat-sets in
portal_insert_depth   = 5;
portal_pad_t          = 6;
// Pad -Y edge is flush with the frame's outer face. Pad +Y edge is
// trimmed to the +Y edge of the upper bosses so it doesn't encroach on
// the Molex connector that starts just past the upper mounting holes.
//   = usb_edge_to_hole (8.5) + hole_dy (40.64) + boss_od/2 (5) = 54.14
portal_pad_y_inset    = 54.14;
// Pad X extent is asymmetric so the +X side clears the bottom-right
// corner knuckle. -X side keeps the original 5 mm margin past the board
// edge; +X side only extends 3 mm past the right-side boss outer edge.
portal_pad_left_x     = portal_x_offset - portal_board_w/2 - 5;   // 57.775
portal_pad_right_x    = 107;                                       // 3.4 mm past right boss edge
portal_pad_width      = portal_pad_right_x - portal_pad_left_x;    // 49.225
portal_pad_center_x   = (portal_pad_left_x + portal_pad_right_x) / 2;
panel_to_pad_gap      = 2;
portal_back_wall_t    = 3;
portal_box_margin     = 2;

// Access channel through the bottom rail outer wall for USB-C + buttons.
// Positioned so its lower edge (in print orientation) sits right at the
// top of the bosses (model Z=-29.25), extending 6 mm "above" the bosses
// in print view (deeper into frame in model = -Z direction).
access_channel_w      = 44.45;  // match board width
access_channel_h      = 6;      // 6 mm tall - just enough for USB-C clearance
access_channel_z      = -32.25; // Z center: (-29.25 + -35.25) / 2

/* [Hanger] */
// Shared pin axis for both the female socket knuckles (on the side rails)
// and the male pins on the hanger bar. Single source of truth so socket
// spacing and pin spacing can never drift. X MUST equal `side_insert_x`
// so the socket thru-hole is coaxial with the top side-rail ear's M3 hole
// (lets a long-shaft screwdriver drop through the socket to drive the
// panel screw during assembly).
hanger_pin_axis_x       = side_insert_x; // 120 — aligned with ears A & D
hanger_pin_axis_y       = 30;            // matches ear Y on side rails

hanger_bar_t            = 6;             // bar thickness in Z (drives socket Z offset)
hanger_bar_w            = 20;            // bar width in Y

hanger_pin_tip_chamfer  = 0.5;           // 45° break on pin tip for easier entry

// Keyhole slot in bar: round opening at bottom (nail head drops in), narrow
// slot rising upward (nail shank catches as frame slides down).
hanger_keyhole_round_d  = 8;             // Ø of nail-head drop-in
hanger_keyhole_slot_w   = 4;             // nail-shank slot width
hanger_keyhole_slot_h   = 10;            // how far the slot extends above the round

// ===== Hanger invariants (fail fast at render time) =====
assert(hanger_pin_axis_x == side_insert_x,
       "hanger_pin_axis_x MUST equal side_insert_x so the socket thru-hole \
is coaxial with the top side-rail ear's M3 hole (screwdriver service port).");
assert(hanger_bar_t >= corner_knuckle_t,
       "hanger_bar_t must be >= corner_knuckle_t; otherwise the socket would \
not sit forward enough for the pin to reach it with the bar flush to the back.");
assert(hanger_pin_axis_y + corner_knuckle_base_w < inner_y - corner_pin_axis_depth,
       "hanger knuckle Y footprint must stay clear of the top-pair corner knuckle base; move hanger_pin_axis_y inboard or reduce corner_knuckle_base_w.");
assert(hanger_pin_axis_y > 0,
       "hanger_pin_axis_y must be positive; the hanger is designed to hang from the upper half of the side rails.");
assert(hanger_keyhole_slot_w < hanger_keyhole_round_d,
       "keyhole slot must be narrower than the round drop-in opening or the nail head would fall through the slot.");

// Socket thru-hole must be coaxial with the top side-rail ears (A, D).
// If this fires, the service-port screwdriver access is broken.
_hanger_sock_center = [hanger_pin_axis_x, hanger_pin_axis_y];
_top_side_ear       = [side_insert_x, 30];
assert(_hanger_sock_center == _top_side_ear,
       "Hanger socket center is not coaxial with the top side-rail ear.");

$fn = 48;

// ===== Derived =====
outer_w     = panel_w + 2 * wall;         // 268
outer_h     = panel_h + 2 * wall;         // 140
frame_depth = panel_d + rear_depth;       // 49.25 total depth in Z
inner_w     = panel_w + 2 * panel_tol;    // tolerance-adjusted panel pocket
inner_h     = panel_h + 2 * panel_tol;
inner_x     = inner_w / 2;                // = +/- 128.3
inner_y     = inner_h / 2;                // = +/- 64.3
outer_x     = outer_w / 2;                // +/- 134
outer_y     = outer_h / 2;                // +/- 70

// Mitered rail footprints (looking down the -Z axis, panel face plane).
// Each rail is a trapezoidal prism extruded in -Z by frame_depth.
//
// Top rail: outer edge at Y=+outer_y, inner edge at Y=+inner_y,
//           ends mitered to meet the side rails at the corners.
// Side rails similar, rotated 90.

// ===== Part dispatch =====
if (part == "all")           assembled_preview(gap = 0);
if (part == "exploded")      assembled_preview(gap = explode_gap);
if (part == "top_rail")      printable_rail("top");
if (part == "bottom_rail")   printable_rail("bottom");
if (part == "side_rail")     printable_rail("left");
if (part == "hanger")        printable_hanger();
if (part == "alignment")     alignment_template();

// =====================================================================
// Preview assembly - rails in place around the (ghost) panel.
// =====================================================================
module assembled_preview(gap = 0) {
    // In exploded mode each rail is pulled outward by `gap` perpendicular
    // to its own long axis.
    translate([0,  gap, 0]) top_rail();
    translate([0, -gap, 0]) bottom_rail();
    translate([-gap, 0, 0]) left_rail();
    translate([ gap, 0, 0]) right_rail();
    // Ghost panel: face at Z=0, extends into -Z by panel_d.
    %translate([0, 0, -panel_d/2])
        cube([panel_w, panel_h, panel_d], center = true);
}

// =====================================================================
// Printable rail - rotated so it sits bezel-equivalent (front) down.
// =====================================================================
module printable_rail(which) {
    // All rails are modeled with their front face at Z=0 and body in -Z.
    // For printing we want the front face DOWN on the bed, so a 180-deg
    // rotation about X maps the model's +Y and -Z into the bed-friendly
    // orientation (front face sits at print Z=0, back of frame at Z=frame_depth).
    // No translate needed - rotate alone puts the piece at Z=0 to Z=frame_depth.
    rotate([180, 0, 0])
        if (which == "top")    top_rail();
        else if (which == "bottom") bottom_rail();
        else                   left_rail();  // side rails are symmetric
}

// =====================================================================
// Individual rails. Each rail's trapezoidal footprint comes from
// _rail_footprint(). All rails are extruded in -Z by frame_depth.
// =====================================================================
module top_rail() {
    union() {
        _rail_body("top");
        _rail_ears("top");
        _corner_knuckles("top");
    }
}

module bottom_rail() {
    difference() {
        union() {
            _rail_body("bottom");
            _rail_ears("bottom");
            _corner_knuckles("bottom");
            _portal_pad();
        }
        _portal_peripheral_cutouts();
        // Air clearance through the Portal pad where it would otherwise
        // cover the G/F ear's M3 screw path.
        _bottom_ear_screw_clearances();
    }
}

module _bottom_ear_screw_clearances() {
    // Column of air at each bottom-ear hole position, spanning from
    // slightly below the ear up through the panel plane. Carves a clean
    // channel through the Portal pad (and anything else in the way).
    clear_d = ear_m3_clear + 1;    // slight extra over the ear's own hole
    for (ins = bottom_inserts)
        translate([ins[0], ins[1], -panel_d - ear_thickness - 1])
            cylinder(d = clear_d, h = ear_thickness + panel_d + 2);
}

module left_rail() {
    union() {
        _rail_body("left");
        _rail_ears("left");
        _corner_knuckles("left");
        _hanger_socket_knuckle(-1);
    }
}

module right_rail() {
    // Mirror of left_rail about X=0.
    mirror([1, 0, 0]) left_rail();
}

module _rail_body(which) {
    // Rail body = trapezoid-in-plan extruded in -Z by frame_depth.
    translate([0, 0, -frame_depth])
        linear_extrude(height = frame_depth)
            _rail_footprint(which);
}

// Footprint polygon in the X-Y plane for one rail.
// Vertices run outer-corner -> outer-corner -> inner-corner -> inner-corner.
module _rail_footprint(which) {
    if (which == "top") {
        polygon([
            [-outer_x, +outer_y],
            [+outer_x, +outer_y],
            [+inner_x, +inner_y],
            [-inner_x, +inner_y],
        ]);
    } else if (which == "bottom") {
        polygon([
            [-outer_x, -outer_y],
            [-inner_x, -inner_y],
            [+inner_x, -inner_y],
            [+outer_x, -outer_y],
        ]);
    } else if (which == "left") {
        polygon([
            [-outer_x, -outer_y],
            [-inner_x, -inner_y],
            [-inner_x, +inner_y],
            [-outer_x, +outer_y],
        ]);
    } else {  // right
        polygon([
            [+outer_x, -outer_y],
            [+outer_x, +outer_y],
            [+inner_x, +inner_y],
            [+inner_x, -inner_y],
        ]);
    }
}

// =====================================================================
// Ears - small tabs projecting inward from a rail at Z=-panel_d, giving
// the panel's threaded inserts a place to meet M3 screws.
// =====================================================================
module _rail_ears(which) {
    inserts =
        which == "top"    ? top_inserts
      : which == "bottom" ? bottom_inserts
      : which == "left"   ? left_inserts
      : which == "right"  ? right_inserts
      :                     [];
    orient_y = (which == "top" || which == "bottom");
    for (ins = inserts)
        _ear_at(ins[0], ins[1], orient_y);
}

// Place an ear so the M3 clearance hole lands exactly at (hx, hy, -panel_d).
// The ear has a bell-curve silhouette (wide at the rail attachment, narrow
// at the tip), is doubled in Z thickness relative to the first version, and
// carries a triangular gusset tying the ear's rear face into the rail body.
module _ear_at(hx, hy, orient_y) {
    difference() {
        union() {
            if (orient_y) {
                sgn    = sign(hy);
                base_y = sgn * inner_y;
                tip_y  = hy - sgn * ear_tip_past_hole;
                translate([0, 0, -panel_d - ear_thickness/2])
                    linear_extrude(height = ear_thickness, center = true)
                        _ear_poly_h(hx, base_y, tip_y);
                _ear_gusset_h(hx, base_y, sgn);
                _ear_side_gussets_h(hx, base_y, sgn);
            } else {
                sgn    = sign(hx);
                base_x = sgn * inner_x;
                tip_x  = hx - sgn * ear_tip_past_hole;
                translate([0, 0, -panel_d - ear_thickness/2])
                    linear_extrude(height = ear_thickness, center = true)
                        _ear_poly_v(hy, base_x, tip_x);
                _ear_gusset_v(hy, base_x, sgn);
                _ear_side_gussets_v(hy, base_x, sgn);
            }
        }
        // M3 clearance straight through at the actual insert location.
        translate([hx, hy, -panel_d - ear_thickness/2])
            cylinder(d = ear_m3_clear, h = ear_thickness + 2, center = true);
        // Washer counterbore on the back face (-Z side).
        translate([hx, hy, -panel_d - ear_thickness + ear_washer_depth/2 - 0.01])
            cylinder(d = ear_washer_cbore,
                     h = ear_washer_depth + 0.02, center = true);
    }
}

// Bell-curve 2D polygon: width tapers from ear_base_width (at base_y) to
// ear_tip_width (at tip_y) following a cosine-interpolated profile.
module _ear_poly_h(hx, base_y, tip_y) {
    right = [
        for (i = [0 : ear_slices])
            let(frac = i / ear_slices,
                w    = ear_tip_width + (ear_base_width - ear_tip_width)
                       * (0.5 + 0.5 * cos(180 * frac)))
            [hx + w/2, base_y + (tip_y - base_y) * frac]
    ];
    left_rev = [
        for (i = [ear_slices : -1 : 0])
            let(frac = i / ear_slices,
                w    = ear_tip_width + (ear_base_width - ear_tip_width)
                       * (0.5 + 0.5 * cos(180 * frac)))
            [hx - w/2, base_y + (tip_y - base_y) * frac]
    ];
    polygon(concat(right, left_rev));
}

// Side-rail variant: polygon runs along X, width in Y.
module _ear_poly_v(hy, base_x, tip_x) {
    bot = [
        for (i = [0 : ear_slices])
            let(frac = i / ear_slices,
                w    = ear_tip_width + (ear_base_width - ear_tip_width)
                       * (0.5 + 0.5 * cos(180 * frac)))
            [base_x + (tip_x - base_x) * frac, hy - w/2]
    ];
    top_rev = [
        for (i = [ear_slices : -1 : 0])
            let(frac = i / ear_slices,
                w    = ear_tip_width + (ear_base_width - ear_tip_width)
                       * (0.5 + 0.5 * cos(180 * frac)))
            [base_x + (tip_x - base_x) * frac, hy + w/2]
    ];
    polygon(concat(bot, top_rev));
}

// Gusset for top/bottom rail ears: triangular prism filling the "crook"
// between the ear's rear face (Z = -panel_d - ear_thickness) and the rail
// body behind it. Extends INTO the rail body (direction = +sgn in Y) and
// BACKWARD (-Z) by ear_gusset_depth. Width along X is ear_gusset_width.
module _ear_gusset_h(hx, base_y, sgn) {
    into = min(ear_gusset_into_rail, wall - 1);
    back = ear_gusset_back_z;
    tiny = 0.1;
    hull() {
        translate([hx, base_y, -panel_d - ear_thickness])
            cube([ear_gusset_width, tiny, tiny], center = true);
        translate([hx, base_y + sgn * into, -panel_d - ear_thickness])
            cube([ear_gusset_width, tiny, tiny], center = true);
        translate([hx, base_y, -panel_d - ear_thickness - back])
            cube([ear_gusset_width, tiny, tiny], center = true);
    }
}

module _ear_gusset_v(hy, base_x, sgn) {
    into = min(ear_gusset_into_rail, wall - 1);
    back = ear_gusset_back_z;
    tiny = 0.1;
    hull() {
        translate([base_x, hy, -panel_d - ear_thickness])
            cube([tiny, ear_gusset_width, tiny], center = true);
        translate([base_x + sgn * into, hy, -panel_d - ear_thickness])
            cube([tiny, ear_gusset_width, tiny], center = true);
        translate([base_x, hy, -panel_d - ear_thickness - back])
            cube([tiny, ear_gusset_width, tiny], center = true);
    }
}

// Side gussets at the X-extremes of a top/bottom ear's base - triangular
// prisms braced against twisting the ear sideways. Thin extent in Y (inside
// the rail body), triangular profile in X-Z.
module _ear_side_gussets_h(hx, base_y, sgn) {
    into  = min(ear_gusset_into_rail, wall - 1);
    back  = ear_gusset_back_z;
    along = ear_gusset_back_z;
    tiny  = 0.1;
    for (side = [-1, +1]) {
        hull() {
            translate([hx + side * ear_base_width/2,
                       base_y + sgn * into/2,
                       -panel_d - ear_thickness])
                cube([tiny, into, tiny], center = true);
            translate([hx + side * (ear_base_width/2 + along),
                       base_y + sgn * into/2,
                       -panel_d - ear_thickness])
                cube([tiny, into, tiny], center = true);
            translate([hx + side * ear_base_width/2,
                       base_y + sgn * into/2,
                       -panel_d - ear_thickness - back])
                cube([tiny, into, tiny], center = true);
        }
    }
}

// Side rail version - gussets at the Y-extremes of a side ear's base.
module _ear_side_gussets_v(hy, base_x, sgn) {
    into  = min(ear_gusset_into_rail, wall - 1);
    back  = ear_gusset_back_z;
    along = ear_gusset_back_z;
    tiny  = 0.1;
    for (side = [-1, +1]) {
        hull() {
            translate([base_x + sgn * into/2,
                       hy + side * ear_base_width/2,
                       -panel_d - ear_thickness])
                cube([into, tiny, tiny], center = true);
            translate([base_x + sgn * into/2,
                       hy + side * (ear_base_width/2 + along),
                       -panel_d - ear_thickness])
                cube([into, tiny, tiny], center = true);
            translate([base_x + sgn * into/2,
                       hy + side * ear_base_width/2,
                       -panel_d - ear_thickness - back])
                cube([into, tiny, tiny], center = true);
        }
    }
}

// =====================================================================
// Corner knuckles - bell-curve protrusions at each mitered corner that
// carry an 8 mm pin (horizontal rails) or socket (vertical rails) along
// the Z axis. Two tiers per corner: one just behind the panel plane,
// one flush with the rear face.
//
// Z geometry (model coords; panel face at Z=0, rear face at Z=-49.25):
//
//   tier 1 pin knuckle    Z = -panel_d           to -panel_d - knuckle_t
//   tier 1 socket knuckle Z = -panel_d - kn_t    to -panel_d - 2*kn_t
//           + pin from the pin knuckle's bottom down through the socket
//   tier 2 pin knuckle    Z = -(fd - 2*kn_t)     to -(fd - kn_t)
//   tier 2 socket knuckle Z = -(fd - kn_t)       to -fd           (rear flush)
//           + pin from the pin knuckle's bottom down through the socket
//
// where fd = frame_depth and kn_t = corner_knuckle_t.
// =====================================================================
module _corner_knuckles(which) {
    corners =
        which == "top"    ? [[+1, +1], [-1, +1]]
      : which == "bottom" ? [[+1, -1], [-1, -1]]
      : which == "left"   ? [[-1, +1], [-1, -1]]
      :                     [[+1, +1], [+1, -1]];
    is_pin = (which == "top" || which == "bottom");
    for (c = corners)
        _corner_knuckle_at(c[0], c[1], which, is_pin);
}

module _corner_knuckle_at(sx, sy, which, is_pin) {
    kn_t = corner_knuckle_t;
    // Tier 1 (behind panel): pin knuckle sits right at the panel back,
    // socket knuckle below it. Pin extends -Z into the socket.
    t1_pin_top  = -panel_d;
    t1_pin_bot  = t1_pin_top - kn_t;
    t1_sock_top = t1_pin_bot;
    t1_sock_bot = t1_sock_top - kn_t;
    // Tier 2 (rear flush): socket knuckle's bottom coincides with the
    // rear face; pin knuckle sits above it.
    t2_sock_bot = -frame_depth;
    t2_sock_top = t2_sock_bot + kn_t;
    t2_pin_bot  = t2_sock_top;
    t2_pin_top  = t2_pin_bot + kn_t;

    if (is_pin) {
        _corner_pin_knuckle(sx, sy, which, t1_pin_top, t1_pin_bot);
        _corner_pin_knuckle(sx, sy, which, t2_pin_top, t2_pin_bot);
    } else {
        _corner_socket_knuckle(sx, sy, which, t1_sock_top, t1_sock_bot);
        _corner_socket_knuckle(sx, sy, which, t2_sock_top, t2_sock_bot);
    }
}

// Pin knuckle: bell-curve prism with the pin fully merged into it. The
// pin axis sits at corner_pin_axis_depth into the knuckle (knuckle tip
// extends past the pin by corner_knuckle_depth - corner_pin_axis_depth),
// so the pin's base is wrapped by material on all sides.
module _corner_pin_knuckle(sx, sy, which, z_top, z_bot) {
    ax = sx * (inner_x - corner_pin_axis_depth);
    ay = sy * (inner_y - corner_pin_axis_depth);
    orient_y = (which == "top" || which == "bottom");
    translate([0, 0, z_bot])
        linear_extrude(height = z_top - z_bot)
            _corner_knuckle_poly(sx, sy, orient_y);
    // Pin stub projects toward the frame rear (-Z in model = +Z in print).
    translate([ax, ay, z_bot - corner_pin_len])
        cylinder(d = corner_pin_d, h = corner_pin_len + 0.01);
}

// Socket knuckle: bell-curve prism with a cylindrical thru-hole drilled
// along the pin axis. Material surrounds the socket on all sides because
// the axis sits inside the knuckle, not at its tip.
module _corner_socket_knuckle(sx, sy, which, z_top, z_bot) {
    ax = sx * (inner_x - corner_pin_axis_depth);
    ay = sy * (inner_y - corner_pin_axis_depth);
    orient_y = (which == "top" || which == "bottom");
    difference() {
        translate([0, 0, z_bot])
            linear_extrude(height = z_top - z_bot)
                _corner_knuckle_poly(sx, sy, orient_y);
        translate([ax, ay, z_bot - 0.1])
            cylinder(d = corner_pin_d + 2 * corner_pin_tol,
                     h = (z_top - z_bot) + 0.2);
    }
}

// Bell-curve 2D polygon anchored to a rail's inner edge. Base runs along
// the rail inner edge, tip extends inward by corner_knuckle_depth; width
// tapers from base_w to tip_w. The pin/socket axis sits at depth
// corner_pin_axis_depth (shallower than knuckle_depth) so there is
// knuckle material on both sides of the axis in the depth direction.
module _corner_knuckle_poly(sx, sy, orient_y) {
    base = corner_knuckle_base_w;
    tip  = corner_knuckle_tip_w;
    kd   = corner_knuckle_depth;
    if (orient_y) {
        base_y = sy * inner_y;
        tip_y  = sy * (inner_y - kd);
        ax     = sx * (inner_x - corner_pin_axis_depth);
        right = [
            for (i = [0 : ear_slices])
                let(frac = i / ear_slices,
                    w    = tip + (base - tip) * (0.5 + 0.5 * cos(180 * frac)))
                [ax + w/2, base_y + (tip_y - base_y) * frac]
        ];
        left_rev = [
            for (i = [ear_slices : -1 : 0])
                let(frac = i / ear_slices,
                    w    = tip + (base - tip) * (0.5 + 0.5 * cos(180 * frac)))
                [ax - w/2, base_y + (tip_y - base_y) * frac]
        ];
        polygon(concat(right, left_rev));
    } else {
        base_x = sx * inner_x;
        tip_x  = sx * (inner_x - kd);
        ay     = sy * (inner_y - corner_pin_axis_depth);
        bot = [
            for (i = [0 : ear_slices])
                let(frac = i / ear_slices,
                    w    = tip + (base - tip) * (0.5 + 0.5 * cos(180 * frac)))
                [base_x + (tip_x - base_x) * frac, ay - w/2]
        ];
        top_rev = [
            for (i = [ear_slices : -1 : 0])
                let(frac = i / ear_slices,
                    w    = tip + (base - tip) * (0.5 + 0.5 * cos(180 * frac)))
                [base_x + (tip_x - base_x) * frac, ay + w/2]
        ];
        polygon(concat(bot, top_rev));
    }
}

// =====================================================================
// Hanger socket knuckle — one per side rail, sits on the inner wall of
// the rail. Same bell-curve silhouette as the corner knuckles. Socket
// is a thru-hole along Z; the matching pin on the hanger bar enters
// from -Z (back of frame). The knuckle is shifted forward (+Z) by
// `hanger_bar_t` so its socket mouth sits exactly at the bar's front
// face when the bar is flush with the rear of the frame.
//
// sx = -1 for left rail; the right-rail version is produced automatically
// by the existing `right_rail() { mirror([1,0,0]) left_rail(); }` call.
// =====================================================================
module _hanger_socket_knuckle(sx) {
    base_w = corner_knuckle_base_w;
    tip_w  = corner_knuckle_tip_w;
    kd     = corner_knuckle_depth;
    kn_t   = corner_knuckle_t;

    base_x = sx * inner_x;
    tip_x  = sx * (inner_x - kd);
    ax     = sx * hanger_pin_axis_x;
    ay     = hanger_pin_axis_y;

    z_bot  = -frame_depth + hanger_bar_t;
    z_top  = z_bot + kn_t;

    // Bell-curve polygon in X-Y, extruded in Z. Base on the rail's inner
    // wall (centered on ay in Y, width tapering from base_w to tip_w as
    // X moves from base_x to tip_x).
    bot = [
        for (i = [0 : ear_slices])
            let(frac = i / ear_slices,
                w    = tip_w + (base_w - tip_w) * (0.5 + 0.5 * cos(180 * frac)))
            [base_x + (tip_x - base_x) * frac, ay - w/2]
    ];
    top_rev = [
        for (i = [ear_slices : -1 : 0])
            let(frac = i / ear_slices,
                w    = tip_w + (base_w - tip_w) * (0.5 + 0.5 * cos(180 * frac)))
            [base_x + (tip_x - base_x) * frac, ay + w/2]
    ];

    difference() {
        translate([0, 0, z_bot])
            linear_extrude(height = z_top - z_bot)
                polygon(concat(bot, top_rev));
        // Thru-hole socket along Z. Oversize by 0.1 top & bottom for clean
        // boolean subtraction.
        translate([ax, ay, z_bot - 0.1])
            cylinder(d = corner_pin_d + 2 * corner_pin_tol,
                     h = (z_top - z_bot) + 0.2);
    }
}

// =====================================================================
// Matrix Portal S3 - a flat mounting plate braced by two triangular
// gussets. Portal attaches to the plate's bottom face (facing OUT the
// back of the frame) via 4 M3 heat-set inserts in bosses that hang
// DOWN from the plate. The word "CONTROLLER" is engraved on the
// mounting face so the correct side is unambiguous.
// =====================================================================

function _portal_pad_top_z() = -panel_d - panel_to_pad_gap;
function _portal_pad_bot_z() = _portal_pad_top_z() - portal_pad_t;
// Pad -Y edge flush with the frame's outer face (Y=-outer_y). Pad extends
// inward (+Y) by `portal_pad_y_inset`.
function _portal_pad_center_y()   = -outer_y + portal_pad_y_inset / 2;
// Mounting holes are off-center on the board. Distances measured on-center:
//   usb_edge_to_hole  = 8.5 mm from the USB/switch edge (board -Y, at frame)
//   pads_edge_to_hole = 16 mm  from the pads edge      (board +X in frame)
usb_edge_to_hole  = 8.5;
pads_edge_to_hole = 16;
function _portal_hole_pattern_center_y() =
    -outer_y + usb_edge_to_hole + portal_hole_dy / 2;
// Pads edge lands on the -X side of the pad in frame coords after the
// board rotation. Nearest hole sits `pads_edge_to_hole` mm in from the
// pad's -X side.
function _portal_hole_pattern_center_x() =
    portal_x_offset - portal_board_w/2
                   + pads_edge_to_hole + portal_hole_dx / 2;

module _portal_pad() {
    pad_cy = _portal_pad_center_y();
    pad_tz = _portal_pad_top_z();
    pad_bz = _portal_pad_bot_z();
    pad_cz = (pad_tz + pad_bz) / 2;
    difference() {
        union() {
            translate([portal_pad_center_x, pad_cy, pad_cz])
                cuboid([portal_pad_width, portal_pad_y_inset,
                        portal_pad_t],
                       rounding = 2,
                       // Round only the two FAR corners (toward panel
                       // center) - keep the two RAIL-side corners sharp
                       // so the fillet and glue surface are maximized.
                       edges = [BACK+LEFT, BACK+RIGHT]);
            _portal_pad_gussets(pad_bz);
            _portal_bosses(pad_bz);
        }
        _portal_boss_pilots(pad_bz);
        _portal_controller_label(pad_cy, pad_bz);
    }
}

// Small continuous fillet along the full pad-to-rail junction. Replaces
// the earlier bulky side gussets - this hugs the inside corner and
// stiffens the attachment without encroaching on the Portal footprint.
module _portal_pad_gussets(pad_bz) {
    fillet = 4;                                      // Y and Z extent of fillet
    tiny = 0.1;
    hull() {
        // Corner where the pad bottom meets the rail inner wall.
        translate([portal_pad_center_x, -inner_y, pad_bz])
            cube([portal_pad_width, tiny, tiny], center = true);
        // Extended inward along the pad bottom by `fillet`.
        translate([portal_pad_center_x, -inner_y + fillet, pad_bz])
            cube([portal_pad_width, tiny, tiny], center = true);
        // Extended downward along the rail inner wall by `fillet`.
        translate([portal_pad_center_x, -inner_y, pad_bz - fillet])
            cube([portal_pad_width, tiny, tiny], center = true);
    }
}

module _portal_bosses(pad_bz) {
    hole_cx = _portal_hole_pattern_center_x();
    hole_cy = _portal_hole_pattern_center_y();
    for (sx = [-1, 1], sy = [-1, 1])
        translate([hole_cx + sx * portal_hole_dx/2,
                   hole_cy + sy * portal_hole_dy/2,
                   pad_bz - portal_boss_h])
            cylinder(d = portal_boss_od, h = portal_boss_h);
}

module _portal_boss_pilots(pad_bz) {
    hole_cx = _portal_hole_pattern_center_x();
    hole_cy = _portal_hole_pattern_center_y();
    pilot_h = portal_boss_h + 2;
    bottom_z = pad_bz - portal_boss_h - 0.1;
    for (sx = [-1, 1], sy = [-1, 1])
        translate([hole_cx + sx * portal_hole_dx/2,
                   hole_cy + sy * portal_hole_dy/2,
                   bottom_z])
            cylinder(d = portal_insert_d, h = pilot_h + 0.1);
}

// Engrave "CONTROLLER" into the pad's bottom face (the Portal mounting
// surface). 0.6 mm deep, centered on the pad, oriented so it reads
// correctly when looking at the pad from -Z (back of the frame).
module _portal_controller_label(pad_cy, pad_bz) {
    engrave_depth = 0.6;
    text_size     = 4;
    // Position above pad_bz by (engrave_depth - 0.01) so the cut extends
    // 0.01 below pad_bz for clean subtraction, up by engrave_depth total.
    // Mirror the text in X so after the print_rail flip (rotate 180 about
    // X, which flips Y as well), it reads correctly from the Portal-mount
    // side of the pad.
    translate([portal_pad_center_x, pad_cy, pad_bz - 0.01])
        linear_extrude(height = engrave_depth + 0.01)
            mirror([1, 0, 0])
                text("CONTROLLER", size = text_size,
                     halign = "center", valign = "center",
                     font = "Liberation Sans:style=Bold");
}

module _portal_peripheral_cutouts() {
    // Wide access channel through the bottom rail's outer wall giving
    // simultaneous access to the USB-C port and all three switches that
    // are on the Portal's -Y edge after the 90-degree rotation.
    y_start = -outer_y - 1;
    y_end   = -inner_y + 1;
    y_mid   = (y_start + y_end) / 2;
    y_span  = y_end - y_start;
    translate([portal_x_offset, y_mid, access_channel_z])
        cuboid([access_channel_w, y_span, access_channel_h],
               rounding = 2, edges = "X");
}

// =====================================================================
// 2D alignment template. Print at 1:1 scale on paper and lay against the
// back of the panel to verify insert positions line up with the ear holes.
// Rendered as 2D (projection) so OpenSCAD exports SVG natively.
// =====================================================================
module alignment_template() {
    stroke_w   = 0.4;   // line thickness
    tick_half  = 4;     // mark size at insert positions
    corner_tick = 8;    // registration marks at the panel corners
    outer_margin = 20;  // page margin around the frame outline for scale/labels
    // Outer frame outline (stroke only).
    _ring(outer_w, outer_h, stroke_w);
    // Panel outline (should sit inside the frame).
    _ring(panel_w, panel_h, stroke_w);
    // Big + marks at each panel corner for registration.
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * panel_w/2, sy * panel_h/2])
            _plus(corner_tick, stroke_w);
    // Marks at each insert position: a cross with a small filled dot in
    // the middle so you can see the exact hole center.
    for (p = concat(top_inserts, bottom_inserts, left_inserts, right_inserts)) {
        translate(p) {
            _plus(tick_half, stroke_w);
            circle(d = 0.8);
        }
    }
    // Matrix Portal footprint outline.
    pad_center_y = -inner_y + portal_pad_y_inset / 2;
    translate([portal_x_offset, pad_center_y])
        _ring(portal_board_w, portal_board_h, stroke_w);
    // Portal bolt positions.
    for (sx = [-1, 1], sy = [-1, 1])
        translate([portal_x_offset + sx * portal_hole_dx/2,
                   pad_center_y + sy * portal_hole_dy/2])
            circle(d = 1.5);
    // Scale bar in the bottom-left corner (outside the frame outline).
    translate([-outer_w/2, -outer_h/2 - 10]) {
        square([50, 0.5]);
        translate([0, -3]) square([0.5, 3]);
        translate([50, -3]) square([0.5, 3]);
    }
}

// Rectangular ring (box outline) centered on origin.
module _ring(w, h, t) {
    difference() {
        square([w, h], center = true);
        square([w - 2*t, h - 2*t], center = true);
    }
}

// Small plus-sign mark centered on origin.
module _plus(arm, t) {
    square([2*arm, t], center = true);
    square([t, 2*arm], center = true);
}

// =====================================================================
// Hanger — spans the frame's interior width across the back, pins engage
// the two new side-rail sockets, keyhole slot in the middle hangs on a
// wall nail. See docs/superpowers/specs/2026-10-24-led-matrix-frame-v2-
// hanger-design.md
// =====================================================================
module printable_hanger() {
    // STUB — replaced in Task 4. Visible placeholder cube.
    color("orange")
        cube([2 * hanger_pin_axis_x, hanger_bar_w, hanger_bar_t], center = true);
}
