// microSD slot fit-test block for the GoPro battery+SD case.
//
// The production slots (sd_slot_t = 1.0 mm in gopro-battery-case.scad) hold the
// cards a touch too loosely, so they work their way out. Cards are retained by
// friction on their flat faces, i.e. by the *thickness* of the slot — not its
// width or depth. This block prints five slots side by side, identical to the
// real pocket in every way except thickness, which steps down in 0.05 mm
// increments. Push a microSD into each, find the tightest one that still seats
// and releases cleanly, and we'll rebuild the case with that sd_slot_t.
//
// The chosen thickness is engraved beside each slot (e.g. "0.90").

/* [Slot geometry — mirrors gopro-battery-case.scad] */
sd_slot_w     = 12.5;  // slot width along Y (card width) — unchanged from the case
sd_slot_depth = 10;    // pocket depth — unchanged from the case
corner_round  = 2;     // fillet radius of the pocket corners — unchanged

/* [Test sweep] */
// Thicknesses to try, loosest -> tightest. The case currently uses 1.0 and is
// too loose, so the sweep starts just under it.
thicknesses = [0.95, 0.90, 0.85, 0.80, 0.75];
slot_pitch  = 12;      // centre-to-centre spacing of the slots along X

/* [Block] */
floor_h  = 3;          // solid material under the deepest slot
margin_x = 5;          // end material past the outermost slots
margin_y = 6;          // material past the slot ends (label lives here)

/* [Label] */
label_size  = 3;       // engraved digit height
label_depth = 0.6;     // engraving depth

/* [Quality] */
$fa = 2;
$fs = 0.4;

// ---------------------------------------------------------------------------

eps = 0.05;
n   = len(thicknesses);

block_h = sd_slot_depth + floor_h;
block_x = (n - 1) * slot_pitch + 2 * margin_x;
block_y = sd_slot_w + 2 * margin_y;

// X positions of the n slots, centred on the origin.
function slot_x(i) = (i - (n - 1) / 2) * slot_pitch;

// Vertical pocket open at the top, rounded vertical corners — the exact
// geometry used for the microSD pockets in the production case.
module rounded_slot(sx, sy, depth) {
    r = min(corner_round, min(sx, sy) / 2 - 0.01);
    translate([0, 0, -depth])
        linear_extrude(depth + eps)
            offset(r = r) offset(delta = -r)
                square([sx, sy], center = true);
}

// "0.95"-style label engraved into the top face just past a slot's Y end.
module slot_label(txt, x) {
    translate([x, -(sd_slot_w / 2 + margin_y / 2 + label_size / 2), block_h - label_depth])
        linear_extrude(label_depth + eps)
            text(txt, size = label_size, halign = "center", valign = "center",
                 font = "Liberation Sans:style=Bold");
}

module test_block() {
    difference() {
        // Solid block.
        translate([0, 0, block_h / 2])
            cube([block_x, block_y, block_h], center = true);
        // One graduated slot per thickness, cut from the top face down.
        for (i = [0 : n - 1])
            translate([slot_x(i), 0, block_h])
                rounded_slot(thicknesses[i], sd_slot_w, sd_slot_depth);
        // Engraved thickness beside each slot.
        for (i = [0 : n - 1])
            slot_label(str(thicknesses[i]), slot_x(i));
    }
}

test_block();
