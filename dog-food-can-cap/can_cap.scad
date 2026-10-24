// Friction-fit cap for a 75 mm rolled-rim dog food can.
// Designed for TPU. The skirt is straight where it overlaps the rim with light
// clearance, then tapers inward at the open tip to snap below the rolled rim
// and cling to the can body.
// Units: mm.

$fn = 96;

// ---------- Parameters ----------
can_od          = 68;    // outer diameter of the can's rolled rim
lip_height      = 5;     // total skirt length
tip_id          = 67;    // inner diameter at the open end (the pinch)

wall_thickness  = 1.0;   // skirt wall thickness
top_thickness   = 2.5;   // closed top thickness
clearance       = 0.3;   // diametral clearance over the rim (straight section)
taper_height    = 3;     // length of inward taper at the tip

// ---------- Derived ----------
skirt_id_closed = can_od + clearance;
skirt_id_open   = tip_id;
skirt_od_closed = skirt_id_closed + 2 * wall_thickness;
skirt_od_open   = skirt_id_open   + 2 * wall_thickness;
straight_h      = lip_height - taper_height;

// ---------- Geometry ----------
// Print orientation: closed top on the build plate, skirt opens upward.
// Gives a flat first layer and prints supports-free in TPU.
module can_cap() {
    // Closed top disk
    cylinder(d = skirt_od_closed, h = top_thickness);

    // Straight skirt section (slides over the rim with light clearance)
    translate([0, 0, top_thickness])
        difference() {
            cylinder(d = skirt_od_closed, h = straight_h);
            translate([0, 0, -0.01])
                cylinder(d = skirt_id_closed, h = straight_h + 0.02);
        }

    // Tapered tip — pinches inward to snap under the rolled rim
    translate([0, 0, top_thickness + straight_h])
        difference() {
            cylinder(d1 = skirt_od_closed, d2 = skirt_od_open, h = taper_height);
            translate([0, 0, -0.01])
                cylinder(d1 = skirt_id_closed, d2 = skirt_id_open, h = taper_height + 0.02);
        }
}

can_cap();
