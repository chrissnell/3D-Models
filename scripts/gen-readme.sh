#!/usr/bin/env bash
# gen-readme.sh — regenerate the design catalog block in README.md.
#
# Discovers every .scad file (outside 3mf/, scratch/, .git/) and emits a
# section for each between the markers:
#
#     <!-- designs:start -->
#     <!-- designs:end -->
#
# Each section shows the design's preview PNG plus links to its 3MF parts.
# README.md is created with a starter template if it doesn't exist.
# The file is only rewritten if its contents actually changed, so this is
# safe to run from `make` without dirtying git on every invocation.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

readme="README.md"
list_parts="$repo_root/scripts/list-parts.sh"
start_marker="<!-- designs:start -->"
end_marker="<!-- designs:end -->"

scad_files=()
while IFS= read -r f; do
    scad_files+=("$f")
done < <(find . -name '*.scad' -not -path '*/3mf/*' -not -path '*/.git/*' -not -path '*/scratch/*' \
         | sed 's|^\./||' | sort)

# Build the catalog body.
catalog=""
prev_dir=""
for f in "${scad_files[@]}"; do
    dir=$(dirname "$f")
    base=$(basename "$f" .scad)

    # Group multi-file dirs under a single H2 header.
    if [ "$dir" != "$prev_dir" ]; then
        catalog+=$'\n'"## ${dir}"$'\n'
        prev_dir="$dir"
    fi

    catalog+=$'\n'"![${dir}/${base}](${dir}/${base}.png)"$'\n'

    catalog+=$'\n'"**Source:** [${base}.scad](${f})"$'\n'

    parts=$("$list_parts" "$f")
    if [ -n "$parts" ]; then
        links=""
        while IFS= read -r p; do
            link="${dir}/3mf/${base}-${p}.3mf"
            if [ -z "$links" ]; then
                links="[${p}](${link})"
            else
                links="${links} · [${p}](${link})"
            fi
        done <<< "$parts"
        catalog+="**3MF:** ${links}"$'\n'
    else
        catalog+="**3MF:** [${base}](${dir}/3mf/${base}.3mf)"$'\n'
    fi
done

# Initialize README.md if missing.
if [ ! -f "$readme" ]; then
    cat > "$readme" <<EOF
# 3D-Models

A catalog ofmy 3D-printable designs. Each entry below is auto-generated from
the source \`.scad\` files.

# Designs

${start_marker}
${end_marker}
EOF
fi

if ! grep -qF "$start_marker" "$readme" || ! grep -qF "$end_marker" "$readme"; then
    echo "gen-readme: $readme is missing the catalog markers" >&2
    echo "  expected: $start_marker ... $end_marker" >&2
    exit 1
fi

# Replace content between the markers (inclusive of trailing/leading blank lines).
# Use a body file rather than -v: BSD awk on macOS rejects newlines in -v values.
tmp=$(mktemp)
body_file=$(mktemp)
trap 'rm -f "$tmp" "$body_file"' EXIT
printf '%s\n' "$catalog" > "$body_file"

awk -v start="$start_marker" -v end="$end_marker" -v body_file="$body_file" '
    $0 == start {
        print
        while ((getline line < body_file) > 0) print line
        close(body_file)
        skip = 1
        next
    }
    $0 == end { print; skip = 0; next }
    !skip     { print }
' "$readme" > "$tmp"

if cmp -s "$tmp" "$readme"; then
    exit 0
fi

mv "$tmp" "$readme"
trap - EXIT
echo "gen-readme: updated $readme"
