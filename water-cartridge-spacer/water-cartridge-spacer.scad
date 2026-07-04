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

// "ventilated" cuts triangular through-holes in the ring so water can flow
// axially through the gasket; "solid" is the plain ring. "all" previews the
// ventilated version.
part = "all"; // [all, solid, ventilated]

// --- Secondary: shape/strength only, does not affect the centering fit ---
wall         = 7;        // ring wall thickness (radial), grows out from the ID
height       = 5;        // part thickness (Z)

// Ventilation triangles (only used by the "ventilated" variant).
vent_tri_h   = 4;        // triangle size across the wall (radial)
vent_tri_b   = 5;        // triangle base (tangential)
vent_step    = 9;        // angular spacing between triangles (deg)
vent_round   = 0.75;     // corner-rounding radius on each triangle

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

// One ventilation triangle in the local +X frame. outward = true points the
// apex toward the outer edge, false toward the ID; alternating them makes a
// zig-zag truss.
//
// Rounding the corners (erode then dilate) leaves the flat base put but pulls
// the sharp apex inward, so the *rounded* triangle is no longer centered on
// its nominal band. A convex corner of half-angle t recedes by
// vent_round*(1-sin t)/sin t; shifting the whole triangle half of that toward
// its apex re-centers the rounded shape's radial span on ring_mid, so both
// orientations end up in the identical band between the ID and OD edges.
vent_apex_half = atan((vent_tri_b / 2) / vent_tri_h);
vent_recenter  = vent_round * (1 - sin(vent_apex_half)) / sin(vent_apex_half) / 2;

module vent_tri(outward) {
    ho = vent_tri_h / 2;
    translate([outward ? vent_recenter : -vent_recenter, 0])
        offset(r = vent_round) offset(delta = -vent_round)
            if (outward)
                polygon([[ring_mid - ho, -vent_tri_b/2],
                         [ring_mid - ho,  vent_tri_b/2],
                         [ring_mid + ho,  0]]);
            else
                polygon([[ring_mid + ho, -vent_tri_b/2],
                         [ring_mid + ho,  vent_tri_b/2],
                         [ring_mid - ho,  0]]);
}

// Triangles arrayed all the way around the ring.
module vents_2d() {
    for (a = [0 : vent_step : 359.999])
        rotate(a)
            vent_tri(round(a / vent_step) % 2 == 0);
}

module spacer_2d_vented() {
    difference() {
        spacer_2d();
        vents_2d();
    }
}

module spacer(vented = false) {
    linear_extrude(height = height)
        if (vented) spacer_2d_vented();
        else        spacer_2d();
}

if (footprint)                    spacer_2d();          // 2D outline for export
else if (part == "solid")         spacer();
else                              spacer(vented = true); // "ventilated" + "all"
