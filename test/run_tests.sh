#!/usr/bin/env bash
# Runs the vim-sgsimpylfold test suite headlessly and exits non-zero on failure.
set -uo pipefail
cd "$(dirname "$0")/.."

export SIMPYLFOLD_TEST_OUT="$(mktemp)"
trap 'rm -f "$SIMPYLFOLD_TEST_OUT"' EXIT

vim -Nu NONE -i NONE --not-a-term \
  -c 'set rtp^=.' \
  -c 'filetype plugin on' \
  -c 'source test/test_bracket_folds.vim' \
  < /dev/null > /dev/null 2>&1

echo "---- test output ----"
cat "$SIMPYLFOLD_TEST_OUT" 2>/dev/null || echo "(no output file written; vim likely crashed)"
echo "----------------------"
grep -q 'ALL TESTS PASSED' "$SIMPYLFOLD_TEST_OUT" 2>/dev/null && { echo OK; exit 0; } || { echo FAILED; exit 1; }
