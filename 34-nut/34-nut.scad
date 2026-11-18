// MaxBotix MB7544 retaining nut.
// 3/4"-14 NPS straight pipe thread per ASME B1.20.1.
//
// NOTE: "3/4"-14 NPS" is a nominal PIPE SIZE, NOT a thread diameter.
// The male thread's nominal major Ø is 1.050" = 26.67 mm.
//
// Thread form: straight 60° V, 14 TPI, right-handed. BOSL2 generates the
// helical female thread; $slop sets the diametral printing clearance.
//
// Units: mm.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 128;

// ---------- Configurable parameters ----------
major_diameter   = 26.67;       // 3/4"-14 NPS male thread major Ø (1.050")
pitch            = 25.4 / 14;   // 14 TPI → ≈ 1.8143 mm
hex_thickness    = 8;           // axial thickness of the hex body
nut_width        = 36;          // hex across flats
flange_od        = 50;          // flange outer Ø
flange_thickness = 2.5;         // flange disc thickness
flange_bevel     = 0.8;         // small chamfer on the flange's outer edge

// BOSL2 adds 4·$slop of diametral clearance to internal threads.
// 0.10 → 0.40 mm on diameter (0.20 mm radial). Bump up if the nut binds,
// down if it spins too freely.
$slop = 0.10;

total_h = hex_thickness + flange_thickness;

// Preview camera.
$vpr = [55, 0, 25];
$vpt = [0, 0, total_h / 2];
$vpd = 180;

// Printed flange-down: the flat clamping face is on the bed. The hex
// body runs the full height; threads cut through it top-to-bottom. The
// flange is a chamfered annular ring hugging the base of the hex.
union() {
    // Hex with full-height internal thread. The bottom (flange face)
    // gets no outer bevel, no internal chamfer, and no blunt-start
    // lead-in so the threads cut all the way to the flange face. The
    // top keeps its chamfer and blunt-start as a sensor lead-in.
    threaded_nut(
        nutwidth     = nut_width,
        id           = major_diameter,
        h            = total_h,
        pitch        = pitch,
        shape        = "hex",
        left_handed  = false,
        bevel1       = false,
        bevel2       = true,
        ibevel1      = false,
        ibevel2      = true,
        blunt_start1 = false,
        blunt_start2 = true,
        anchor       = BOTTOM
    );

    // Flange ring. Inner Ø sits inside the hex's inscribed circle so
    // the ring overlaps the hex everywhere and leaves no gap at the
    // corners or flats.
    difference() {
        cyl(d1 = flange_od - 2*flange_bevel,
            d2 = flange_od,
            h  = flange_thickness,
            anchor = BOTTOM);
        up(-0.01)
            cyl(d = nut_width - 1,
                h = flange_thickness + 0.02,
                anchor = BOTTOM);
    }
}

echo(str("Thread: 3/4\"-14 NPS, major Ø = ", major_diameter, " mm"));
echo(str("Pitch = ", pitch, " mm (14 TPI)"));
echo(str("Hex: ", hex_thickness, " mm × ", nut_width, " mm flats"));
echo(str("Flange: ", flange_thickness, " mm × ", flange_od, " mm Ø"));
echo(str("Total height: ", total_h, " mm"));
echo(str("Diametral clearance (4·$slop) = ", 4 * $slop, " mm"));
