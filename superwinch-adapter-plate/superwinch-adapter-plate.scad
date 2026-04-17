// Superwinch Adapter Plate
// Diamond-shaped with rounded points, 5mm thick
// Three holes along major (X) axis

thickness       = 3;
major_axis      = 75;     // tip-to-tip along X
minor_axis      = 55;     // tip-to-tip along Y
point_radius    = 3;      // radius of curvature at each point

center_hole_d   = 22;     // center hole diameter
screw_hole_d    = 5.4;    // screw hole diameter
screw_spacing   = 44.45;  // screw hole center-to-center

// Hull circle centers are inset from the tips by point_radius
// so the outer extents remain exactly major_axis × minor_axis
major_half = major_axis / 2 - point_radius;  // 27 mm
minor_half = minor_axis / 2 - point_radius;  // 17 mm

module adapter_plate() {
    difference() {
        // Diamond body — hull of four rounded tips
        linear_extrude(height = thickness)
            hull() {
                translate([ major_half,  0]) circle(r = point_radius, $fn = 48);
                translate([-major_half,  0]) circle(r = point_radius, $fn = 48);
                translate([0,  minor_half]) circle(r = point_radius, $fn = 48);
                translate([0, -minor_half]) circle(r = point_radius, $fn = 48);
            }

        // Center hole (Ø22 mm)
        translate([0, 0, -0.5])
            cylinder(d = center_hole_d, h = thickness + 1, $fn = 64);

        // Screw holes (Ø5.4 mm), ±22.225 mm from center along X
        screw_x = screw_spacing / 2;
        for (sx = [-screw_x, screw_x])
            translate([sx, 0, -0.5])
                cylinder(d = screw_hole_d, h = thickness + 1, $fn = 32);
    }
}

    adapter_plate();

// For 2D PDF part printing
// projection(cut = false) adapter_plate();

