#!/usr/bin/env bash
# list-parts.sh — extract the parts list from a multi-part .scad file.
#
# Convention: the file declares its parts via OpenSCAD's Customizer dropdown
# syntax on a variable named exactly `part`:
#
#     part = "all"; // [all, holder, cap]
#
# Output: one part name per line, in declaration order, with "all" omitted
# (since "all" is the preview/assembly view, not an exported part).
# Files without the annotation produce no output.
set -euo pipefail

file="${1:?usage: list-parts.sh <file.scad>}"

sed -nE 's|^[[:space:]]*part[[:space:]]*=[[:space:]]*"[^"]*"[[:space:]]*;[[:space:]]*//[[:space:]]*\[([^]]*)\].*|\1|p' "$file" \
    | head -n 1 \
    | tr ',' '\n' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | grep -v '^$' \
    | grep -v '^all$' || true
