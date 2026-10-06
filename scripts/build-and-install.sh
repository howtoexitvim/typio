#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ${EUID} -eq 0 ]]; then
  echo "Please run this script without sudo. It will request sudo only for install steps."
  exit 1
fi

WORKSPACE="${PROJECT_ROOT}/typio.xcworkspace"
SCHEME="typio"
BUILD_DIR="${HOME}/.typio/build/release"
APP_NAME="Typio"
INSTALL_DIR="/Library/Input Methods"

echo "[1/4] Cleaning old build output..."
if [[ -d "${BUILD_DIR}" ]]; then
  if ! rm -rf "${BUILD_DIR}" 2>/dev/null; then
    echo "Build dir has restricted files. Fixing ownership with sudo..."
    sudo chflags -R nouchg,noschg "${BUILD_DIR}" 2>/dev/null || true
    sudo chown -R "$(id -un)":staff "${BUILD_DIR}"
    rm -rf "${BUILD_DIR}"
  fi
fi

echo "[2/4] Building ${APP_NAME}.app..."
xcodebuild clean -workspace "${WORKSPACE}" -scheme "${SCHEME}" >/dev/null
xcodebuild -workspace "${WORKSPACE}" -scheme "${SCHEME}" \
  -destination "generic/platform=macOS,name=Any Mac" \
  -configuration Release \
  CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "[3/4] Replacing installed input method..."
pkill -x Typio || true
sudo rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
sudo cp -R "${BUILD_DIR}/${APP_NAME}.app" "${INSTALL_DIR}/${APP_NAME}.app"

echo "[4/4] Registering and activating input source..."
"${INSTALL_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}" --install
killall TextInputMenuAgent || true

echo "Done. If System Settings still shows old cached name, remove old source once and add typio again."
echo "If Typio does not appear immediately, log out and log in once."