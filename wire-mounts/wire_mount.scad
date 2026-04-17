// Wire cable mount v2 (BOSL2 threads)
// Units: mm

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// ---------- Parameters ----------
$fn = 96;

// Base plate
plate_size       = 55;
plate_thickness  = 4;
plate_corner_r   = 5;

// Post (cylinder)
post_total_h     = 23;   // total height above plate
post_dia         = 30;   // unthreaded (lower) section
thread_dia       = 25;   // major (nominal) diameter of threaded section
thread_h         = 10;   // length of threaded section
thread_pitch     = 2;

// Wire trench
wire_dia         = 11.5;
wire_center_z    = plate_thickness + 6;  // wire centerline above origin
trench_length    = post_dia + 8;         // ensure cut clears the post

// Cap
cap_od           = 30;
cap_thread_h     = 10;
cap_top_h        = 2;
cap_clearance    = 0.4;   // diametral clearance for printed threads
knurl            = true;   // diamond knurl on cap OD (BOSL2 texture)
knurl_size       = 3.0;    // target tile size in mm (diamond pitch)
knurl_depth      = 0.9;    // groove depth — deeper = grippier

// Plate labels (engraved into top face, flanking the post along Y)
label_front       = "NW5W";
label_back        = "LMR-4";
label_depth       = 0.6;      // how deep the text sinks below plate top
label_font        = "Inconsolata:style=Bold";
label_size_front  = 5;
label_size_back   = 5;
label_y_offset    = 21;       // distance from plate center to text center

// ---------- Geometry helpers ----------
module rounded_plate(size, r, h) {
    linear_extrude(height = h)
        offset(r = r) offset(r = -r)
            square([size, size], center = true);
}

module wire_channel(wd, z_center, length, top_z) {
    hull() {
        translate([0, 0, z_center])
            rotate([90, 0, 0])
                cylinder(d = wd, h = length, center = true);
        translate([0, 0, top_z - 0.01])
            cube([wd, length, 0.02], center = true);
    }
}

// Engraved text on the plate's top face. Returns a cutter volume that sinks
// label_depth into the top surface; intended to be subtracted, not unioned.
//module plate_labels() {
//    translate([0, label_y_offset, plate_thickness - label_depth])
//        linear_extrude(height = label_depth + 0.05)
//            text(label_front, size = label_size_front,
//                 halign = "center", valign = "center",
//                 font = label_font);
//
//    translate([0, -label_y_offset, plate_thickness - label_depth])
//        linear_extrude(height = label_depth + 0.05)
//            text(label_back, size = label_size_back,
//                 halign = "center", valign = "center",
//                 font = label_font);
//}

// ---------- Wire holder (base) ----------
module wire_holder() {
    difference() {
        union() {
            rounded_plate(plate_size, plate_corner_r, plate_thickness);

            // Smooth lower section of post
            translate([0, 0, plate_thickness])
                cylinder(d = post_dia,
                         h = post_total_h - thread_h);

            // Threaded upper section (BOSL2)
            translate([0, 0, plate_thickness + post_total_h - thread_h])
                threaded_rod(
                    d      = thread_dia,
                    l      = thread_h,
                    pitch  = thread_pitch,
                    bevel2 = true,
                    anchor = BOTTOM,
                    $fn    = 96
                );
        }

        wire_channel(wd       = wire_dia,
                     z_center = wire_center_z,
                     length   = trench_length,
                     top_z    = plate_thickness + post_total_h + 1);

        // Engrave labels into the plate top
        plate_labels();
    }
}

// ---------- Cap ----------
// The cap blank uses BOSL2's textured cyl() so the diamond knurl is baked
// into the OD itself — no separate cutter pass, cleaner mesh, much grippier
// than vertical grooves.
module cap_blank() {
    cap_total_h = cap_thread_h + cap_top_h;
    if (knurl)
        cyl(d         = cap_od,
            h         = cap_total_h,
            texture   = "diamonds",
            tex_size  = [knurl_size, knurl_size],
            tex_depth = knurl_depth,
            style     = "concave",
            anchor    = BOTTOM,
            $fn       = 96);
    else
        cylinder(d = cap_od, h = cap_total_h);
}

module cap() {
    difference() {
        cap_blank();

        // Internal thread cut via BOSL2 (internal=true inverts profile for nut).
        // Bottom sits 1 mm below the cap so the open face is cleanly cut;
        // top reaches z = cap_thread_h, leaving cap_top_h of solid material.
        translate([0, 0, -1])
            threaded_rod(
                d        = thread_dia + cap_clearance,
                l        = cap_thread_h + 1,
                pitch    = thread_pitch,
                internal = true,
                bevel1   = true,
                anchor   = BOTTOM,
                $fn      = 96
            );
    }
}

// ---------- Layout ----------
// "all" renders the assembly for preview; per-part values export a single
// printable for slicing. Driven by the top-level Makefile (see CLAUDE.md).
part = "all"; // [all, holder, cap]

if (part == "all" || part == "holder")
    wire_holder();

if (part == "all" || part == "cap")
    translate([part == "cap" ? 0 : 60, 0, 0])
        cap();
