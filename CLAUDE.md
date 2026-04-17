# 3D-Models Repository Conventions

## Multi-Part OpenSCAD Designs

When a `.scad` file produces more than one printable part that should be
exported as a separate 3MF for Bambu Studio, declare the parts using the
OpenSCAD Customizer dropdown syntax on a variable named exactly `part`:

```openscad
part = "all"; // [all, holder, cap]

if (part == "all" || part == "holder") wire_holder();
if (part == "all" || part == "cap")    cap();
```

### Rules

- The variable MUST be named exactly `part`.
- The annotation MUST be a trailing `// [val1, val2, ...]` comment on the
  same line as the assignment (OpenSCAD Customizer syntax — gives a
  dropdown in the GUI for free).
- The list MUST include `all` as the first entry. `all` is the
  preview/assembly view; it is NOT exported.
- Each non-`all` value MUST render exactly one part, isolated at the
  origin, ready for slicing.
- The default value SHOULD be `"all"` so opening the file in OpenSCAD
  shows the full assembly.

Single-part designs do not need the annotation. They get a single
combined 3MF at `<design-dir>/3mf/<basename>.3mf` plus a preview PNG.

## Building 3MFs and Previews

The top-level `Makefile` auto-discovers all `.scad` files. Each `make` run
produces three artifacts per design:

1. One 3MF per declared part: `<design-dir>/3mf/<basename>-<part>.3mf`
2. One PNG preview rendered with `part="all"`: `<design-dir>/<basename>.png`
3. A refreshed catalog block in the root `README.md`

```
make            # build 3MFs, render previews, refresh README
make list       # show discovered designs and their parts
make <dir>      # build everything in one design directory
make readme     # refresh README catalog only
make clean      # remove generated 3MFs and previews
```

All outputs are committed as repo deliverables (no gitignore).

Override the OpenSCAD binary via the `OPENSCAD` env var if needed:

```
OPENSCAD=/path/to/openscad make
```

## Project Layout

- One directory per design at the repo root (e.g. `wire-mounts/`).
- Source `.scad` files live in the design directory.
- `3mf/` inside each design directory holds generated 3MFs and is checked
  into the repo as the shipped artifact.
- `<basename>.png` next to each `.scad` file is the auto-rendered preview.
- Shared build tooling lives in `scripts/` and the root `Makefile`.

## README Catalog

The root `README.md` contains an auto-generated design catalog between the
markers:

```
<!-- designs:start -->
<!-- designs:end -->
```

Anything you write outside those markers is preserved across `make readme`
runs — that's where project intro, build instructions, and per-design
notes belong. Inside the markers is regenerated from the discovered
designs every `make`.
