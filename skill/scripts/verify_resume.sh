#!/usr/bin/env bash
set -euo pipefail

# Validate a rendered resume.
# Usage: verify_resume.sh RESUME.pdf [EXPECTED_PAGES] [REQUIRED_TEXTS_FILE] [FORBIDDEN_TEXTS_FILE]
#
# REQUIRED_TEXTS_FILE  — one required substring per line (defaults to the bundled
#   baseline identity: name / city / email / key section headings).
# FORBIDDEN_TEXTS_FILE — one forbidden substring per line (defaults to the bundled
#   blacklisted team names). An empty file skips the corresponding check.

if [[ $# -lt 1 || $# -gt 4 ]]; then
  printf 'Usage: %s RESUME.pdf [EXPECTED_PAGES] [REQUIRED_TEXTS_FILE] [FORBIDDEN_TEXTS_FILE]\n' "$0" >&2
  exit 2
fi

pdf=$1
expected=
required_file=
forbidden_file=
# $2 为纯数字时按 EXPECTED_PAGES 解析; 否则视为 REQUIRED_TEXTS_FILE,
# 允许用户跳过页数直接传核对清单 (数值比较消除前导零误判)
if [[ $# -ge 2 ]] && [[ $2 =~ ^[0-9]+$ ]]; then
  expected=$2
  required_file=${3:-}
  forbidden_file=${4:-}
else
  required_file=${2:-}
  forbidden_file=${3:-}
fi

[[ -f "$pdf" ]] || { printf 'PDF not found: %s\n' "$pdf" >&2; exit 1; }
for cmd in pdfinfo pdftotext pdffonts; do
  command -v "$cmd" >/dev/null || { printf '%s is required\n' "$cmd" >&2; exit 1; }
done

pages=$(pdfinfo "$pdf" | awk '/^[[:space:]]*Pages:/ {print $2}')
[[ -n "$pages" ]] || { printf 'Could not read page count\n' >&2; exit 1; }
if [[ -n "$expected" && "$pages" -ne "$expected" ]]; then
  printf 'Expected %s pages, got %s\n' "$expected" "$pages" >&2
  exit 1
fi

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/resume-verify.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
text="$tmpdir/text.txt"

if [[ -z "$required_file" ]]; then
  required_file="$tmpdir/required.txt"
  cat > "$required_file" <<'EOF'
李华
上海
li.hua@example.com
竞赛经历
项目经历
EOF
fi
if [[ -z "$forbidden_file" ]]; then
  forbidden_file="$tmpdir/forbidden.txt"
  cat > "$forbidden_file" <<'EOF'
secret-team-alias
secret-account-alias
EOF
fi

pdftotext -layout "$pdf" "$text"

if [[ -s "$required_file" ]]; then
  while IFS= read -r needle || [[ -n "$needle" ]]; do
    [[ -z "$needle" ]] && continue
    grep -Fq -- "$needle" "$text" || { printf 'Missing text: %s\n' "$needle" >&2; exit 1; }
  done < "$required_file"
  printf 'Required text: OK\n'
else
  printf 'Required text: skipped (empty file)\n'
fi

if [[ -s "$forbidden_file" ]]; then
  while IFS= read -r needle || [[ -n "$needle" ]]; do
    [[ -z "$needle" ]] && continue
    if grep -Fq -- "$needle" "$text"; then
      printf 'Forbidden text found: %s\n' "$needle" >&2
      exit 1
    fi
  done < "$forbidden_file"
  printf 'Forbidden texts: OK\n'
else
  printf 'Forbidden texts: skipped (empty file)\n'
fi

printf 'PDF: %s\nPages: %s\nFonts:\n' "$pdf" "$pages"
pdffonts "$pdf"