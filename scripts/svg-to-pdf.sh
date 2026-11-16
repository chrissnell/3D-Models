#!/usr/bin/env bash
# svg-to-pdf.sh — convert an OpenSCAD-emitted SVG to a 1:1 PDF.
# Usage: svg-to-pdf.sh <input.svg> <output.pdf>
#
# OpenSCAD SVG exports use `mm` as the user unit. rsvg-convert's --format pdf
# preserves the native units, so a 10 mm calibration square in the .scad ends
# up as a 10 mm square on the page.
set -euo pipefail

in="${1:?usage: svg-to-pdf.sh <input.svg> <output.pdf>}"
out="${2:?usage: svg-to-pdf.sh <input.svg> <output.pdf>}"

rsvg-convert --format=pdf --output="$out" "$in"
