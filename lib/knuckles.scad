// Reusable male/female "knuckle" protrusions for joining 3D-printed parts.
//
// A knuckle is a bell-curve-tapered boss with a pin (male) or a matching
// socket (female) along its central Z axis. Mate a male to a female and the
// pin seats in the socket; glue goes in the socket only. First used on the
// mitered corners and hanger of led-matrix-frame-v2.
//
// Canonical orientation (used by all modules here):
//
//     Y
//     ^           tip (y = depth)
//     |         ___________
//     |        /           \
//     |       /             \
//     |      |      *        |     * = pin / socket axis at
//     |      |               |         (0, pin_axis_depth)
//     |       \_____________/
//     |        base (y = 0, width = base_w)
//     +------------------------------> X
//
//  Body is extruded in +Z from z=0 to z=t.
//  Male: pin projects in +Z above the body (z=[t, t+pin_len]).
//  Female: thru-hole along Z through the body.
//
// To mate two parts: place one in canonical orientation and rotate/translate
// the other 180° so its base points at the first's base and the pin axes
// coincide.
//
// All modules take explicit named parameters with the defaults declared
// below, so a caller can override any single dimension without having to
// pass all of them. The library has no top-level dependencies; use with
//     use <path/to/lib/knuckles.scad>
// from your own design.

// ===== Defaults =====
// Keep in sync with led-matrix-frame-v2.scad's corner_* vars so callers
// get the same mechanical fit out of the box.
knuckle_t              = 6;    // Z thickness of the knuckle body
knuckle_base_w         = 20;   // bell-curve width at the base (y=0)
knuckle_tip_w          = 12;   // bell-curve width at the tip (y=depth)
knuckle_depth          = 20;   // depth from base to tip (in +Y)
knuckle_pin_axis_depth = 10;   // depth from base to pin/socket axis
knuckle_pin_d          = 8;    // pin diameter
knuckle_pin_tol        = 0.3;  // per-side clearance between pin and socket
knuckle_pin_len        = 6;    // pin length (projecting above body)
knuckle_slices         = 10;   // bell-curve smoothness

// ===== 2D profile =====
// Bell-curve polygon in the X-Y plane. Width tapers from `base_w` at y=0 to
// `tip_w` at y=`depth` following a cosine profile (flat at the ends, steep
// in the middle). Useful on its own for making a flat gusset or decal that
// matches the knuckle silhouette.
module knuckle_profile(base_w   = knuckle_base_w,
                       tip_w    = knuckle_tip_w,
                       depth    = knuckle_depth,
                       slices   = knuckle_slices) {
    right = [
        for (i = [0 : slices])
            let(frac = i / slices,
                w    = tip_w + (base_w - tip_w) * (0.5 + 0.5 * cos(180 * frac)))
            [ w/2, depth * frac ]
    ];
    left_rev = [
        for (i = [slices : -1 : 0])
            let(frac = i / slices,
                w    = tip_w + (base_w - tip_w) * (0.5 + 0.5 * cos(180 * frac)))
            [ -w/2, depth * frac ]
    ];
    polygon(concat(right, left_rev));
}

// ===== Male knuckle: body + pin projecting in +Z =====
module knuckle_male(t              = knuckle_t,
                    base_w         = knuckle_base_w,
                    tip_w          = knuckle_tip_w,
                    depth          = knuckle_depth,
                    pin_axis_depth = knuckle_pin_axis_depth,
                    pin_d          = knuckle_pin_d,
                    pin_len        = knuckle_pin_len,
                    slices         = knuckle_slices) {
    linear_extrude(height = t)
        knuckle_profile(base_w, tip_w, depth, slices);
    translate([0, pin_axis_depth, t])
        cylinder(d = pin_d, h = pin_len);
}

// ===== Female knuckle: body with Z-axis thru-hole =====
module knuckle_female(t              = knuckle_t,
                      base_w         = knuckle_base_w,
                      tip_w          = knuckle_tip_w,
                      depth          = knuckle_depth,
                      pin_axis_depth = knuckle_pin_axis_depth,
                      pin_d          = knuckle_pin_d,
                      pin_tol        = knuckle_pin_tol,
                      slices         = knuckle_slices) {
    difference() {
        linear_extrude(height = t)
            knuckle_profile(base_w, tip_w, depth, slices);
        translate([0, pin_axis_depth, -0.1])
            cylinder(d = pin_d + 2 * pin_tol, h = t + 0.2);
    }
}

// ===== Pin tip chamfer (optional, applied by caller via difference()) =====
// Returns a thin cylinder-minus-cone shape sitting at the top of the pin,
// suitable for subtracting from a male knuckle to break the pin tip for
// easier insertion. Match `t`, `pin_axis_depth`, `pin_d`, and `pin_len` to
// the knuckle_male() call you want to chamfer.
//
//   difference() {
//       knuckle_male(...);
//       knuckle_pin_tip_chamfer(..., chamfer = 0.5);
//   }
module knuckle_pin_tip_chamfer(t              = knuckle_t,
                               pin_axis_depth = knuckle_pin_axis_depth,
                               pin_d          = knuckle_pin_d,
                               pin_len        = knuckle_pin_len,
                               chamfer        = 0.5) {
    translate([0, pin_axis_depth, t + pin_len - chamfer])
        difference() {
            cylinder(d = pin_d + 1, h = chamfer + 0.01);
            cylinder(d1 = pin_d - 2 * chamfer,
                     d2 = pin_d,
                     h  = chamfer + 0.01);
        }
}

// ===== Demo / self-test =====
// Rendering this file directly shows a male and a female knuckle facing
// each other with a small gap, so you can eyeball the fit. The library
// itself has no side effects when `use <>`-d from another file.
$fn = 48;
_demo_gap = 8;

module _knuckle_demo() {
    // Female on the left, in canonical orientation.
    translate([-_demo_gap/2 - knuckle_base_w, 0, 0])
        knuckle_female();
    // Male on the right, rotated 180° about Z so its base faces the female
    // and the pin points back toward the socket.
    translate([_demo_gap/2 + knuckle_base_w, 0, 0])
        rotate([0, 0, 180])
            knuckle_male();
}

_knuckle_demo();
