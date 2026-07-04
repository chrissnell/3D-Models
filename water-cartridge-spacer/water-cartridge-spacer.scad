// Water Cartridge Spacer
// A thin uniform-wall ring that sits between a water cartridge and its
// housing, with four semicircular lobes (bumps) looping outward at 0, 90,
// 180 and 270 degrees. Wall thickness is a constant 5 mm throughout.

wall         = 5;        // uniform wall thickness
ring_outer   = 59.25;    // main ring outer radius -> Ø118.5 outer diameter
lobe_extent  = 65.125;   // outermost radius incl. lobe -> Ø130.25 extent
height       = 10;       // part thickness (Z)

// Set true to emit the flat 2D outline instead of the full part — export
// to SVG/DXF for a 1:1 paper printout to check size against the housing.
footprint    = false;

$fn = 240;

// The 5 mm wall grows inward from the outer radius.
ring_inner = ring_outer - wall;              // 54.25 -> Ø108.5
ring_mid   = (ring_inner + ring_outer) / 2;  // 56.75
// Lobe loop is stitched onto the ring at its centerline so the two
// equal-thickness walls stay flush; its tip lands on the fixed extent.
lobe_outer = lobe_extent - ring_mid;         // 8.375
lobe_inner = lobe_outer - wall;              // 3.375

// A semicircular half-annulus opening outward along +X.
module lobe_2d() {
    difference() {
        intersection() {
            circle(r = lobe_outer);
            translate([0, -lobe_outer]) square([lobe_outer, 2 * lobe_outer]);
        }
        circle(r = lobe_inner);
    }
}

module spacer_2d() {
    union() {
        // Main ring
        difference() {
            circle(r = ring_outer);
            circle(r = ring_inner);
        }
        // Four outward lobes
        for (a = [0, 90, 180, 270])
            rotate(a)
                translate([ring_mid, 0])
                    lobe_2d();
    }
}

module spacer() {
    linear_extrude(height = height)
        spacer_2d();
}

if (footprint) spacer_2d();  // 2D outline for SVG/DXF export
else           spacer();
