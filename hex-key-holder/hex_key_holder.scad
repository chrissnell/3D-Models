// Hex key holder — wall-mount, magnetic.
// Holds a 10-piece metric T-handle hex key set
// (2, 2.5, 3, 4, 4.5, 5, 5.5, 6, 8, 10 mm).
// Mounts to the vertical side of a steel tool cabinet via two
// press-fit N52 15x3 mm magnets.
//
// Coordinate convention (model is built in "in use" orientation):
//   +X : row direction (long axis of the design)
//   +Y : perpendicular to the wall, pointing away from the cabinet
//   +Z : vertical, up
//
// Units: mm.

include <BOSL2/std.scad>

$fn = 96;

// ---------- Backplate ----------
backplate_w       = 220;   // along X
backplate_t       = 5;     // along Y (thickness, into +Y)
backplate_h       = 70;    // along Z

// ---------- Shelf ----------
shelf_w           = 220;   // along X
shelf_depth       = 40;    // along Y, extends from backplate front face (+Y)
shelf_t           = 5;     // along Z (shelf thickness)
shelf_z           = 30;    // shelf underside sits at this Z (30 mm up from backplate bottom)

// ---------- Key holes ----------
hole_count        = 10;
hole_spacing      = 22;                                   // center-to-center
hole_margin       = (shelf_w - (hole_count - 1) * hole_spacing) / 2; // 11 mm
hole_center_y_off = shelf_depth / 2;                      // offset from backplate front face
hole_dia_small    = 8;                                    // keys 2 .. 4.5
hole_dia_large    = 13;                                   // keys 5 .. 10
key_labels        = ["2","2.5","3","4","4.5","5","5.5","6","8","10"];
small_hole_count  = 5;

// ---------- Labels ----------
label_depth       = 0.6;
label_font        = "Inconsolata:style=Bold";
label_size        = 5;
label_y_offset    = -10;  // relative to hole center (toward the backplate, -Y)

// ---------- Magnets ----------
magnet_od         = 15;
magnet_t          = 3;
magnet_pocket_od  = magnet_od - 0.15;   // press-fit interference
magnet_pocket_d   = magnet_t + 0.3;     // small over-depth for seating
magnet_edge_inset = 15;                  // X distance from each short edge
magnet_z          = shelf_z + shelf_t / 2;  // aligned with shelf centerline (Z = 32.5)

// ---------- Gussets ----------
gusset_count      = 4;
gusset_run        = 30;    // along +Y (how far out along the shelf)
gusset_rise       = 30;    // along +Z (how far down the backplate)
gusset_t          = 4;     // along X (thickness)
// Midpoints between hole columns (between holes 2-3, 4-5, 6-7, 8-9);
// hole centers at X = 11, 33, 55, 77, 99, 121, 143, 165, 187, 209.
gusset_x_centers  = [44, 88, 132, 176];

// ---------- Entry point ----------

// Backplate stands vertical in use. Modelled from the origin:
//   X : 0 .. backplate_w
//   Y : 0 .. backplate_t     (back face at Y=0 against the cabinet wall)
//   Z : 0 .. backplate_h
module backplate() {
    difference() {
        cube([backplate_w, backplate_t, backplate_h]);

        // Two magnet pockets on the back face (Y=0), opening into -Y.
        // Oriented so the cylinder axis points in -Y: rotate [-90, 0, 0]
        // puts a +Z cylinder along -Y. Start slightly into the solid
        // (+0.01) to avoid a zero-thickness face.
        for (x = [magnet_edge_inset, backplate_w - magnet_edge_inset]) {
            translate([x, 0.01, magnet_z])
                rotate([90, 0, 0])
                    cylinder(h = magnet_pocket_d + 0.02, d = magnet_pocket_od);
        }
    }
}

module hex_key_holder() {
    backplate();
}

hex_key_holder();
