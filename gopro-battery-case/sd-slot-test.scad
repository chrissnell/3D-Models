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
// Slots are packed tight to keep the print small. Each slot is identified by a
// row of round indentations ("inverse bumps") beside it: one dimple for slot 1,
// two for slot 2, and so on up to five — count the dimples to read the slot.

/* [Slot geometry — mirrors gopro-battery-case.scad] */
sd_slot_w     = 12.5;  // slot width along Y (card width) — unchanged from the case
sd_slot_depth = 10;    // pocket depth — unchanged from the case
corner_round  = 2;     // fillet radius of the pocket corners — unchanged

/* [Test sweep] */
// Thicknesses to try, loosest -> tightest. The case currently uses 1.0 and is
// too loose, so the sweep starts just under it.
thicknesses = [0.95, 0.90, 0.85, 0.80, 0.75];
slot_pitch  = 5.5;     // centre-to-centre spacing of the slots along X (tight)

/* [Block] */
floor_h  = 3;          // solid material under the deepest slot
margin_x = 3;          // end material past the outermost slots
gap_y    = 2;          // clear top surface between a slot end and its dimples
edge_y   = 2;          // material past the dimple row

/* [Slot-number dimples] */
dimple_pitch = 3.0;    // spacing between dimples in a row (clear of each other)
dimple_r     = 1.4;    // radius of the indenting sphere
dimple_depth = 0.8;    // how deep each dimple cuts into the top face

/* [Quality] */
$fa = 2;
$fs = 0.4;

// ---------------------------------------------------------------------------

eps = 0.05;
n   = len(thicknesses);

block_h = sd_slot_depth + floor_h;

// The dimple row sits in the +Y margin, running along Y so it stays narrow in X
// and lets the slots pack tightly. Reserve enough Y for the longest row (n=5).
row_len   = (n - 1) * dimple_pitch;                 // span of the 5-dimple row
row_y0    = sd_slot_w / 2 + gap_y + dimple_r;       // Y of the first (nearest) dimple
block_x   = (n - 1) * slot_pitch + 2 * margin_x;
block_y   = (row_y0 + row_len + dimple_r + edge_y)   // +Y side carries the dimples
          + (sd_slot_w / 2 + margin_x);              // -Y side is plain margin
block_y0  = -(sd_slot_w / 2 + margin_x);             // block min-Y (keeps slots put)

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

// A count of round indentations for slot i (i = 0 -> one dimple), carved into
// the top face as a row running in +Y beside the slot.
module slot_dimples(i) {
    count = i + 1;
    for (k = [0 : count - 1])
        translate([slot_x(i), row_y0 + k * dimple_pitch, block_h + dimple_r - dimple_depth])
            sphere(r = dimple_r);
}

module test_block() {
    difference() {
        // Solid block, sized so slots stay centred on X and the dimple rows fit.
        translate([-block_x / 2, block_y0, 0])
            cube([block_x, block_y, block_h]);
        // One graduated slot per thickness, cut from the top face down.
        for (i = [0 : n - 1])
            translate([slot_x(i), 0, block_h])
                rounded_slot(thicknesses[i], sd_slot_w, sd_slot_depth);
        // Slot-number dimples: 1..n indentations beside each slot.
        for (i = [0 : n - 1])
            slot_dimples(i);
    }
}

test_block();
