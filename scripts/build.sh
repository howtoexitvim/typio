#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BUILD_ROOT="${HOME}/.typio/build/release"
WORKSPACE="${PROJECT_ROOT}/typio.xcworkspace"

xcodebuild -version
clang -v
rm -rf "${BUILD_ROOT}"

xcodebuild clean -workspace "${WORKSPACE}" -scheme typio

xcodebuild -workspace "${WORKSPACE}" -scheme typio -destination "generic/platform=macOS,name=Any Mac" -configuration "Release" CONFIGURATION_BUILD_DIR="${BUILD_ROOT}" BUILD_LIBRARY_FOR_DISTRIBUTION=YES
