// Water Cartridge Spacer
// An adapter that centers a cylinder inside a larger cylinder (CR Spotless
// DIW-20 water softener). A ring with four solid semicircular lobes at 0,
// 90, 180 and 270 degrees.
//
// Only two dimensions matter for the fit, and both are diameters:
//   inner_diameter -> the hole that slips over the inner cylinder
//   outer_diameter -> the circle through the lobe tips, which seats against
//                     the bore of the outer cylinder

inner_diameter = 106.5;  // ID (over the inner cylinder)
outer_diameter = 133;    // across the lobe tips (into the outer bore)

// --- Secondary: shape/strength only, does not affect the centering fit ---
wall         = 7;        // ring wall thickness (radial), grows out from the ID
height       = 5;        // part thickness (Z)

// Set true to emit the flat 2D outline instead of the full part — export
// to SVG/DXF for a 1:1 paper printout to check size against the housing.
footprint    = false;

$fn = 240;

// Derived radii.
ring_inner = inner_diameter / 2;             // 53.25
ring_outer = ring_inner + wall;              // 60.25
lobe_extent = outer_diameter / 2;            // 66.5 -> lobe tips
ring_mid   = (ring_inner + ring_outer) / 2;  // 56.75
// Solid lobe: half-disc with its flat edge on the ring centerline, so it
// fuses to the ring and its rounded tip lands on the outer_diameter.
lobe_outer = lobe_extent - ring_mid;         // 9.75

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
