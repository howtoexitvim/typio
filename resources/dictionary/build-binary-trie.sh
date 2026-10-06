#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TOOL="${ROOT}/build/marisa/marisa-build"
if [[ ! -x "${TOOL}" ]]; then
  echo "Run bash scripts/build-marisa.sh first." >&2
  exit 1
fi
"${TOOL}" --binary-tail "${ROOT}/resources/dictionary/google_227800_words.txt" \
  --output="${ROOT}/resources/dictionary/google_227800_words.bin"
