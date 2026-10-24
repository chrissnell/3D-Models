# led-matrix-frame-v2 — wall hanger addition

Date: 2026-10-24
Target file: `led-matrix-frame-v2/led-matrix-frame-v2.scad`

## Goal

Add a way to hang the assembled frame on a wall nail, like a picture frame. Two
new female socket knuckles on the side rails receive the two pins of a new
printable "hanger" bar; the bar sits flush against the rear face of the frame
and carries a keyhole slot in the middle that drops onto a nail.

## Non-goals

- No changes to top/bottom rails, Portal mount, ears, panel geometry, mitered
  corner joint, or alignment template.
- No changes to the existing corner knuckles or their pin/socket geometry.
- No Makefile changes — the new part is picked up automatically from the
  `part = ...` Customizer dropdown.

## Hard constraints

- Center-to-center spacing of the two hanger pins MUST equal the center-to-
  center spacing of the two new sockets. Both must be driven from a single
  pair of parameters (`hanger_pin_axis_x`, `hanger_pin_axis_y`) so they cannot
  drift apart.
- Socket thru-hole on each side rail MUST be coaxial with the M3 screw hole
  in the top side-rail ear directly in front of it (ears A and D), so a long
  shaft screwdriver can drop through the socket to drive the panel screw
  during assembly.
- Bar's rear face MUST sit flush with the frame's rear face
  (`Z = -frame_depth`) when installed.

## Parameters (new `/* [Hanger] */` section)

| Name                       | Default | Meaning                                              |
|----------------------------|---------|------------------------------------------------------|
| `hanger_bar_t`             | `6`     | Bar thickness in Z. Drives the socket's Z offset.    |
| `hanger_bar_w`             | `20`    | Bar width in Y.                                      |
| `hanger_pin_axis_x`        | `side_insert_x` (= 120) | Pin axis in X (shared by socket + bar). |
| `hanger_pin_axis_y`        | `30`    | Pin axis in Y (matches top side-rail ear Y).         |
| `hanger_keyhole_round_d`   | `8`     | Nail-head drop-in opening, Ø.                        |
| `hanger_keyhole_slot_w`    | `4`     | Nail-shank slot width above the round.               |
| `hanger_keyhole_slot_h`    | `10`    | How far above the round the narrow slot extends.     |
| `hanger_pin_tip_chamfer`   | `0.5`   | Small chamfer on each pin tip for easier insertion.  |

Reused from existing design (no duplicates introduced):
`corner_pin_d`, `corner_pin_tol`, `corner_pin_len`, `corner_knuckle_t`,
`corner_knuckle_base_w`, `corner_knuckle_tip_w`, `corner_knuckle_depth`,
`inner_x`, `inner_y`, `frame_depth`, `panel_d`, `ear_thickness`,
`side_insert_x`, `wall`.

## Part 1 — Hanger socket knuckles on side rails

One per side rail (left and right). Added to `left_rail()` and `right_rail()`
unions alongside the existing `_rail_ears` and `_corner_knuckles` calls.

### Shape

Bell-curve prism, identical silhouette to the existing side-rail corner
knuckles — reuse `_corner_knuckle_poly`-style geometry so visual language stays
consistent across all socket knuckles.

- Base width in Y: `corner_knuckle_base_w = 20 mm` at the side-rail inner
  wall.
- Tip width in Y: `corner_knuckle_tip_w = 12 mm` at `corner_knuckle_depth`
  (`20 mm`) into the cavity.
- Thickness in Z: `corner_knuckle_t = 6 mm`.
- Base attaches to the side-rail inner face at `X = ±inner_x = ±128.3`.
- Tip extends `20 mm` into the cavity, ending at `X = ±108.3`.

### Position

- Pin axis X: `±hanger_pin_axis_x = ±120`. This is `8.3 mm` into the knuckle
  from the base; `~11.7 mm` of material remains past the axis for strength.
- Pin axis Y: `+hanger_pin_axis_y = +30` (same side on both rails).
- Knuckle Y footprint: base `[+20, +40]`, tip `[+24, +36]`. Clear of the
  top-pair knuckle base footprint `[+44.3, +64.3]`.
- Knuckle Z range: `[-frame_depth + hanger_bar_t, -frame_depth + hanger_bar_t
  + corner_knuckle_t] = [-43.25, -37.25]` with defaults. Shifted forward
  (`+Z`) by `hanger_bar_t` from a rear-flush position so the socket mouth sits
  exactly at the bar's front face.

### Socket

- Thru-hole along Z through the full knuckle thickness.
- Diameter: `corner_pin_d + 2 * corner_pin_tol = 8.6 mm`. Reuses the proven
  corner-joint tolerance.
- Centered on `(±hanger_pin_axis_x, +hanger_pin_axis_y)`.
- Being a thru-hole, the socket doubles as a screwdriver service port when
  the bar is NOT installed.

### Screwdriver service port — alignment check

With defaults:

- Hanger socket thru-hole: coaxial along Z at `(±120, +30)`, open from
  `Z = -43.25` back to `Z = -37.25`.
- Top side-rail ear (A / D) M3 clearance hole: coaxial along Z at
  `(±120, +30)`, open from `Z = -panel_d - ear_thickness = -24.25` back to
  `Z = -panel_d = -14.25`.
- Rear cavity between them (`Z = -37.25` to `Z = -24.25`): `13 mm` of empty
  space. A long-shaft #1 Phillips reaches through the socket, across the
  cavity, through the ear hole, and seats in the M3 insert on the panel.

### Module organization

Add a single new module:

```openscad
module _hanger_socket_knuckle(sx) { ... }
```

Called once from `left_rail()` (`sx = -1`) and once from `right_rail()`
(`sx = +1`, via the existing `mirror([1,0,0]) left_rail()` call — so adding
it to `left_rail()` is sufficient). Reuses the bell-curve polygon helper so
the silhouette matches the corner knuckles exactly.

## Part 2 — Hanger bar (new printable part `"hanger"`)

### Dispatch

Extend the Customizer dropdown and the `if (part == ...)` dispatch at the top
of the file:

```openscad
part = "exploded"; // [all, exploded, top_rail, bottom_rail, side_rail, hanger]
...
if (part == "hanger")        printable_hanger();
```

Note: `alignment` is intentionally omitted from the Customizer dropdown
because it is a 2D template (not exportable to 3MF) and would otherwise
break `make`. The `if (part == "alignment") alignment_template();` dispatch
line is retained so the template can still be generated via
`openscad -o out.svg -D 'part="alignment"' ...` when needed.

Also render the hanger in the assembled/exploded preview (`assembled_preview`)
so a user opening the file in Customizer sees the full picture.

### Geometry (in installed position — same coord system as the rails)

- Rectangular strap:
  - X extent: `[-inner_x, +inner_x] = [-128.3, +128.3]`
    → length `inner_w ≈ 256.6 mm`. Bar is **flush with the inner faces of the
    side rails** on both ends.
  - Y extent: centered on `+hanger_pin_axis_y`, width `hanger_bar_w`
    → `[+20, +40]`.
  - Z extent: `[-frame_depth, -frame_depth + hanger_bar_t] = [-49.25, -43.25]`.
- Pins (2×):
  - Ø `corner_pin_d = 8 mm`, length `corner_pin_len = 6 mm`.
  - Base at bar's front face (`Z = -frame_depth + hanger_bar_t = -43.25`),
    projecting `+Z` into the cavity, ending at `Z = -37.25`.
  - Axis at `(±hanger_pin_axis_x, +hanger_pin_axis_y) = (±120, +30)`. Pin
    bases sit `~8.3 mm` inboard of the bar ends, so a full 8 mm Ø pin is
    entirely supported by the bar material.
  - Tip chamfer: `hanger_pin_tip_chamfer = 0.5 mm` 45° break on the leading
    edge for easier socket entry.
- **Teardrop keyhole** (cut all the way through in Z, centered on bar in X) —
  formed by a 2D `hull()` of two circles:
  - Wide (lower) lobe: Ø `hanger_keyhole_round_d = 8 mm`, center at
    `(0, +hanger_pin_axis_y)`. Big enough for the nail head to drop through.
  - Narrow (upper) lobe: Ø `hanger_keyhole_slot_w = 4 mm`, center at
    `(0, +hanger_pin_axis_y + hanger_keyhole_slot_h) = (0, +40)`. Big enough
    for the nail shank only.
  - The hull produces a smooth tapered opening — wide at the bottom,
    narrowing to a tip at the top.
  - Hanging sequence: nail head drops into the wide lobe → frame weight pulls
    frame down → nail rides up (relative to the bar) into the narrow lobe →
    nail head is now behind the sub-head-sized region of the bar and cannot
    pull back through → frame locked on nail.

### Install position vs. print position

- Modeled in installed position (back face flush with frame rear at
  `Z = -frame_depth`), consistent with how the rails are modeled.
- `printable_hanger()` rotates/translates for bed-friendly orientation:
  bar flat on the bed, pins pointing `+Z` on the printer. Footprint
  `~256.6 × 20 mm` is right at the edge of the user's 256 × 256 bed and
  must be rotated ~15° diagonally on the plate to fit with clearance.

### Module organization

```openscad
module hanger()           { ... }  // installed position, in frame coords
module printable_hanger() { ... }  // bed-friendly orientation for export
```

`assembled_preview(gap)` calls `hanger()` so the preview shows it in place.
In exploded view, pull the hanger `-Z` by `gap` to show it coming off the
back face.

## Assembly / install order

1. Print rails and hanger bar.
2. Dry-fit or glue the four rails together via the mitered corner joints.
3. Place the panel in the frame.
4. Drive the four side-rail ear M3 screws:
   - **Top-left (A) and top-right (D)**: insert a long-shaft screwdriver
     through the new hanger socket thru-hole.
   - **Bottom-left (H) and bottom-right (E)**: unchanged from current flow.
5. Drive the top/bottom-rail ear M3 screws (B, C, F, G) — unchanged.
6. Install the hanger bar last: lay it flat against the frame rear with pins
   over the sockets, press forward (`+Z`) until the bar seats flat against
   the rear face. `corner_pin_tol = 0.3 mm` gives a secure press fit.

## Hanging on wall

1. Drive a nail / drywall screw into the wall at the desired height.
2. Lift frame; drop the keyhole round opening over the nail head.
3. Let the frame slide down — the nail shank catches in the narrow slot
   `10 mm` above and the frame's weight locks it in place.

## Build / tooling impact

- `make` auto-discovers the `hanger` entry in the `part = [...]` dropdown
  and produces `led-matrix-frame-v2/3mf/led-matrix-frame-v2-hanger.3mf`
  alongside the existing per-part 3MFs.
- Preview PNG re-renders from `part = "all"`, which includes the hanger.
- README catalog regenerates automatically.
- No `Makefile` edits, no `scripts/` edits.

## Risks / open questions

- **Pin press-fit force on a 6 mm bar**: the bar is 6 mm thick in Z around
  the pin base, and the pin is 8 mm Ø. Standard FDM should hold under the
  weight of a 1–2 kg frame hung from the keyhole; the shear load on each
  pin is only the frame's half-weight at the wall-nail reaction. No design
  change proposed; flagged for post-print validation.
- **Bar removal**: pulling the bar straight off `-Z` works; `0.3 mm` per-side
  tolerance is the same friction fit used throughout the frame. If the fit
  is too tight in practice, bumping `corner_pin_tol` is a global knob —
  consider a hanger-specific `hanger_pin_tol` override only if needed.
- **Keyhole dimensions**: tuned for a typical 3–3.5 mm shank drywall screw
  / finish nail with a ~6 mm head. If the user wants a specific fastener
  spec, the four `hanger_keyhole_*` parameters cover it without code
  changes.
