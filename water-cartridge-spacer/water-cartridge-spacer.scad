// Water Cartridge Spacer
// A thin uniform-wall ring that sits between a water cartridge and its
// housing, with four semicircular lobes (bumps) looping outward at 0, 90,
// 180 and 270 degrees. Wall thickness is a constant 3.5 mm throughout.

ring_inner   = 110;    // main ring inner radius
ring_outer   = 113.5;  // main ring outer radius
lobe_inner   = 10;     // lobe inner radius
lobe_outer   = 13.5;   // lobe outer radius
height       = 10;     // part thickness (Z)

$fn = 240;

// Wall centerlines: the lobe loop is stitched onto the main ring at its
// centerline radius so the two equal-thickness (3.5 mm) walls stay flush.
ring_mid = (ring_inner + ring_outer) / 2;  // 111.75

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

spacer();
