#!/bin/bash
# Rebuild the vendored marisa 0.2.6 library and native dictionary tools.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="${ROOT}/vendor/marisa-trie"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/typio-marisa.XXXXXX")"
trap 'rm -rf "${WORK}"' EXIT
SDK="$(xcrun --sdk macosx --show-sdk-path)"
mkdir -p "${VENDOR}/lib" "${ROOT}/build/marisa"
for arch in arm64 x86_64; do
  mkdir -p "${WORK}/${arch}"
  while IFS= read -r source; do
    object="${WORK}/${arch}/$(basename "${source}" .cc).o"
    xcrun clang++ -std=c++11 -O2 -arch "${arch}" -isysroot "${SDK}" \
      -mmacosx-version-min=11.0 -ffile-prefix-map="${ROOT}/=" -I"${VENDOR}/include" -I"${VENDOR}/source/lib" \
      -c "${source}" -o "${object}"
  done < <(find "${VENDOR}/source/lib" -name '*.cc' | sort)
  xcrun libtool -static -o "${WORK}/${arch}/libmarisa.a" "${WORK}/${arch}"/*.o
done
xcrun lipo -create "${WORK}/arm64/libmarisa.a" "${WORK}/x86_64/libmarisa.a" \
  -output "${VENDOR}/lib/libmarisa.a"
for tool in marisa-build marisa-dump; do
  xcrun clang++ -std=c++11 -O2 -isysroot "${SDK}" -mmacosx-version-min=11.0 \
    -ffile-prefix-map="${ROOT}/=" -I"${VENDOR}/include" -I"${VENDOR}/source/lib" -I"${VENDOR}/source/tools" \
    "${VENDOR}/source/tools/${tool}.cc" "${VENDOR}/source/tools/cmdopt.cc" \
    "${VENDOR}/lib/libmarisa.a" -o "${ROOT}/build/marisa/${tool}"
done
xcrun lipo -info "${VENDOR}/lib/libmarisa.a"
