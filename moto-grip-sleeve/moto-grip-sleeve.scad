// Motorcycle grip sleeve.
// Slides over a 22.2mm handlebar (1mm knurling) and expands the OD to 25.5mm
// so a grip can be fit over it. Capped on the outboard end. The inboard
// (open) end has two "ears" that the steel band clamp slides over and
// squeezes to lock the sleeve to the bar. A lip at the tip of each ear
// retains the clamp.

/* [Handlebar fit] */
bar_od       = 22.2;
sleeve_id    = 22.4;    // +0.2mm over bar — snug slide fit, knurling bites in

/* [Sleeve body] */
sleeve_od    = 26.0;    // OD the grip slides onto
sleeve_len   = 126;     // total length of the sleeve (cap included)
cap_thk      = 3.3;     // axial thickness of the closed end
cap_round    = 1.5;     // fillet radius on the outer cap edge (so it doesn't dig into the grip)

/* [Clamp ears] */
ear_protrude = 10;      // how far the ears stick out past the open end
ear_od       = sleeve_od; // OD under the clamp — flush with sleeve body
lip_od       = 28.0;      // OD of the retaining lip at the ear tip
lip_thk      = 2;       // axial thickness of the lip (clamp is 8mm wide)
ear_half_arc = 30;      // half-angle of each ear (deg) -> 60° per ear
                        // = 2-to-4 o'clock and 8-to-10 o'clock

$fa = 2;
$fs = 0.3;

// Layout along +Z (open end at the bottom, cap at the top):
//   z = 0                            .. ear_protrude          : ears only
//   z = ear_protrude                 .. ear_protrude+sleeve_len: hollow tube + cap

module sleeve() {
    difference() {
        union() {
            translate([0, 0, ear_protrude])
                rotate_extrude($fn = 128)
                    sleeve_body_profile();

            ear_ring(z0 = 0,       h = lip_thk,                od = lip_od);
            ear_ring(z0 = lip_thk, h = ear_protrude - lip_thk, od = ear_od);
        }

        // Bore for the handlebar — open at the ear end, closed by the cap.
        translate([0, 0, -0.01])
            cylinder(h = ear_protrude + sleeve_len - cap_thk + 0.01,
                     d = sleeve_id);
    }
}

module sleeve_body_profile() {
    // 2D profile in (r, z) for rotate_extrude: solid cylinder with a
    // quarter-round fillet on the outer top (cap) edge.
    r = sleeve_od / 2;
    h = sleeve_len;
    f = cap_round;
    steps = 24;
    arc = [ for (i = [0:steps])
        let(a = i * 90 / steps)
        [r - f + f * cos(a), h - f + f * sin(a)] ];
    polygon(concat([[0, 0], [r, 0]], arc, [[0, h]]));
}

module ear_ring(z0, h, od) {
    for (ang = [0, 180])
        rotate([0, 0, ang])
            translate([0, 0, z0])
                intersection() {
                    cylinder(h = h, d = od);
                    rotate([0, 0, -ear_half_arc])
                        pie(h = h, r = od, a = 2 * ear_half_arc);
                }
}

module pie(h, r, a) {
    steps = max(2, ceil(a / 2));
    pts = concat(
        [[0, 0]],
        [ for (i = [0:steps]) let(th = i * a / steps)
            [r * cos(th), r * sin(th)] ]
    );
    linear_extrude(h) polygon(pts);
}

sleeve();
