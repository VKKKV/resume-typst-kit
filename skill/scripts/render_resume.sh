#!/usr/bin/env bash
set -euo pipefail

# Render a resume using the bundled OrangeX4 simple-resume harness.
# Usage: render_resume.sh INPUT.typ OUTPUT.pdf [PNG_PREFIX]

if [[ $# -lt 2 || $# -gt 3 ]]; then
  printf 'Usage: %s INPUT.typ OUTPUT.pdf [PNG_PREFIX]\n' "$0" >&2
  exit 2
fi

input=$1
output=$2
prefix=$(basename "${3:-${output%.pdf}-preview}")

[[ -f "$input" ]] || { printf 'Input not found: %s\n' "$input" >&2; exit 1; }
command -v typst >/dev/null || { printf 'typst is required\n' >&2; exit 1; }
command -v pdfinfo >/dev/null || { printf 'pdfinfo is required\n' >&2; exit 1; }
command -v pdftoppm >/dev/null || { printf 'pdftoppm is required\n' >&2; exit 1; }

mkdir -p "$(dirname "$output")"
typst compile --root "$(dirname "$input")" "$input" "$output"
pages=$(pdfinfo "$output" | awk '/^[[:space:]]*Pages:/ {print $2}')
# PNG previews land next to the PDF, not in the caller's cwd
png_dir="$(dirname "$output")"
for page in $(seq 1 "$pages"); do
  pdftoppm -png -f "$page" -l "$page" -singlefile -r 150 "$output" "$png_dir/${prefix}-${page}"
done

printf 'Rendered: %s\nPages: %s\nPNG previews: %s/%s-1...N.png\n' "$output" "$pages" "$png_dir" "$prefix"
