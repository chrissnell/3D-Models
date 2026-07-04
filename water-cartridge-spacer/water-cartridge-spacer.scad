// Water Cartridge Spacer
// A ring that sits between a water cartridge and its housing, with four
// solid semicircular lobes (bumps) at 0, 90, 180 and 270 degrees. The ring
// wall is a constant 2.5 mm.

wall         = 2.5;      // ring wall thickness
ring_outer   = 59.25;    // main ring outer radius -> Ø118.5 outer diameter
lobe_extent  = 65.125;   // outermost radius incl. lobe -> Ø130.25 extent
height       = 10;       // part thickness (Z)

// Set true to emit the flat 2D outline instead of the full part — export
// to SVG/DXF for a 1:1 paper printout to check size against the housing.
footprint    = false;

$fn = 240;

// The wall grows inward from the fixed outer radius.
ring_inner = ring_outer - wall;              // 56.75 -> Ø113.5
ring_mid   = (ring_inner + ring_outer) / 2;  // 58.0
// Solid lobe: half-disc with its flat edge on the ring centerline, so it
// fuses to the ring and its rounded tip lands on the fixed extent.
lobe_outer = lobe_extent - ring_mid;         // 7.125

// A solid semicircle opening outward along +X.
module lobe_2d() {
    intersection() {
        circle(r = lobe_outer);
        translate([0, -lobe_outer]) square([lobe_outer, 2 * lobe_outer]);
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
