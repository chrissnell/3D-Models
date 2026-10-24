// Marbles screw-top container
// 90 mm smooth cylinder with a coarse round-profile thread (BOSL2), same
// thread family the gopro-battery-case uses. Body 50 mm tall, lid 15 mm tall.
//
// Multi-colour lid workflow (Bambu Studio):
//   The lid ships as TWO printable bodies:
//     * marbles-container-lid.3mf       - lid shell with a shallow text
//                                          pocket in the top face
//     * marbles-container-lid-text.3mf  - solid "marbles" tile that drops
//                                          into that pocket exactly flush
//   Both are pre-oriented for TOP-DOWN printing (top face on the build plate)
//   and share the same origin.
//
//   In Bambu Studio:
//     1. File > Import > marbles-container-lid.3mf         (lid body)
//     2. Right-click the lid > "Add Part" > pick
//        marbles-container-lid-text.3mf                    (text tile)
//     3. Assign filament 1 to the lid, filament 2 to the text tile.
//     4. Slice and print. No filament change, no bridging - the tile IS
//        the flush multi-colour text.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Part] */
// all = assembled preview; base/lid/lid-text are the printable parts.
part = "lid"; // [all, base, lid, lid-text]

/* [Body] */
body_d      = 90;    // outer diameter
body_h      = 50;    // total base height (including threaded neck)
neck_major  = 84;    // thread major (crest) diameter at the neck
barrel_id   = 82;    // interior diameter through the barrel section
neck_id     = 76;    // interior diameter through the neck (clear of the thread root)
floor_h     = 2;     // solid floor thickness
taper_h     = 3;     // 45 deg taper between barrel_id and neck_id for printability

/* [Lid] */
lid_top     = 4;     // solid roof thickness (must exceed text_depth)
lid_relief  = 2;     // clearance between the neck top and the lid roof

/* [Thread] */
// Coarse round (knuckle) thread - fat, forgiving teeth that print cleanly
// and seat in a few turns. Matches the gopro-battery-case profile family.
thread_shape  = "round"; // [round, trapezoid]
thread_pitch  = 3;    // tooth spacing (mm)
thread_turns  = 3;    // turns -> neck_h = turns * pitch = 9 mm engagement
thread_depth  = 1.8;  // radial tooth depth
thread_angle  = 30;   // trapezoid only
thread_starts = 1;    // lead starts
slop          = 0.25; // radial clearance added to the internal (lid) thread

/* [Knurling] */
knurl       = false;  // smooth wall by default; flip on for a diamond-knurled grip
knurl_size  = 4;

/* [Edges] */
edge_chamfer = 3;

/* [Text] */
// Bold sans-serif label. The lid pocket and the text tile share this
// depth so they mate flush. 0.8 mm at 0.2 mm layer height gives the
// tile a comfortable four-layer foot on the build plate.
text_str    = "marbles";
text_font   = "Liberation Sans:style=Bold";
text_size   = 12;
text_depth  = 0.8;

/* [Quality] */
$fa = 2;
$fs = 0.6;

// ---------------------------------------------------------------------------

neck_h = thread_turns * thread_pitch;         // 9 mm
lid_h  = neck_h + lid_relief + lid_top;       // 15 mm total lid height
eps    = 0.05;

module knurled_wall(d, h, cham_b=0, cham_t=0) {
    band_h = h - cham_b - cham_t;
    up(cham_b) {
        if (knurl)
            cyl(d=d, h=band_h, texture="diamonds", tex_size=[knurl_size, knurl_size],
                style="concave", anchor=BOTTOM);
        else
            cyl(d=d, h=band_h, anchor=BOTTOM);
    }
    if (cham_b > 0) cyl(d1=d - 2*cham_b, d2=d, h=cham_b, anchor=BOTTOM);
    if (cham_t > 0) up(h - cham_t) cyl(d1=d, d2=d - 2*cham_t, h=cham_t, anchor=BOTTOM);
}

// Rounded (knuckle) tooth: smooth cosine from root->crest->root over one pitch.
function round_profile() =
    let(n = 32, a = thread_depth / thread_pitch)
    [ for (i = [0:n]) let(x = -0.5 + i/n) [x, -a * 0.5 * (1 - cos(360 * x))] ];

module neck_thread(l, internal=false) {
    sl = internal ? slop : 0;
    if (thread_shape == "round")
        generic_threaded_rod(
            d=neck_major, l=l, pitch=thread_pitch, profile=round_profile(),
            starts=thread_starts, internal=internal, $slop=sl, anchor=BOTTOM);
    else
        trapezoidal_threaded_rod(
            d=neck_major, l=l, pitch=thread_pitch,
            thread_angle=thread_angle, thread_depth=thread_depth, starts=thread_starts,
            internal=internal, $slop=sl, anchor=BOTTOM);
}

module base() {
    lower_h    = body_h - neck_h;
    barrel_int = lower_h - floor_h - taper_h;
    difference() {
        union() {
            knurled_wall(body_d, lower_h, cham_b=edge_chamfer);
            up(lower_h) neck_thread(neck_h);
        }
        up(floor_h) cyl(d=barrel_id, h=barrel_int + eps, anchor=BOTTOM);
        up(floor_h + barrel_int)
            cyl(d1=barrel_id, d2=neck_id, h=taper_h, anchor=BOTTOM);
        up(lower_h - eps)
            cyl(d=neck_id, h=neck_h + 2*eps, anchor=BOTTOM);
    }
}

// 2D text profile shared by the pocket and the tile so they mate exactly.
module text_2d() {
    text(text_str, size=text_size, font=text_font,
         halign="center", valign="center");
}

module lid_body() {
    // Modelled opening-down: opening at z=0, roof at z=lid_h.
    thread_h = neck_h;
    cavity_h = neck_h + lid_relief;
    relief_d = neck_major + 1;
    difference() {
        knurled_wall(body_d, lid_h, cham_t=edge_chamfer);
        up(thread_h - eps)
            cyl(d=relief_d, h=cavity_h - thread_h + eps, anchor=BOTTOM);
        neck_thread(thread_h + eps, internal=true);
        // Pocket for the text tile - cut just above the top face so the tile's
        // top ends up flush with the outer surface.
        translate([0, 0, lid_h - text_depth])
            linear_extrude(text_depth + eps) text_2d();
    }
    assert(text_depth < lid_top, "text_depth must be less than lid_top");
}

module lid_text() {
    // Positive tile that fills the lid pocket exactly.
    translate([0, 0, lid_h - text_depth])
        linear_extrude(text_depth) text_2d();
}

// Flip opening-down modelling into top-down print orientation:
// the top face lands on the build plate, the opening faces up.
// Must be a rotation (chirality-preserving), NOT a mirror - mirroring
// flips the thread helix handedness, so a mirrored RH internal thread
// becomes LH and won't mate with the base's RH external thread.
module lid_print_orient() {
    translate([0, 0, lid_h]) rotate([180, 0, 0]) children();
}

module assembly() {
    base();
    shoulder_z = body_h - neck_h;
    translate([0, 0, shoulder_z]) {
        color("SlateBlue") lid_body();
        // Preview only: lift the tile 0.4 mm so the label reads clearly
        // even in F5 preview / without colour support. The exported
        // "lid" and "lid-text" parts stay perfectly flush.
        color("Gold") translate([0, 0, 0.4]) lid_text();
    }
}

// --- Printable parts (Customizer / Makefile) ---
if      (part == "all")      assembly();               // preview (not exported)
else if (part == "base")     base();
else if (part == "lid")      lid_print_orient() lid_body();
else if (part == "lid-text") lid_print_orient() lid_text();
