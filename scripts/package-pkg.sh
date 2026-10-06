#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ${EUID} -eq 0 ]]; then
  echo "Please run this script without sudo."
  exit 1
fi

WORKSPACE="${PROJECT_ROOT}/typio.xcworkspace"
SCHEME="typio"
APP_NAME="Typio"
BUILD_DIR="${HOME}/.typio/build/release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DIST_DIR="${PROJECT_ROOT}/dist"
PKG_SCRIPTS_DIR="${PROJECT_ROOT}/scripts/pkg-scripts"
INSTALL_LOCATION="/Library/Input Methods"
BUNDLE_ID="top.shuqihere.inputmethod.typio"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${PROJECT_ROOT}/resources/Info.plist")"
PKG_PATH="${DIST_DIR}/${APP_NAME}-${VERSION}.pkg"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/typio-pkg.XXXXXX")"
STAGE_DIR="${TMP_ROOT}/pkg-root"
COMPONENT_PLIST="${TMP_ROOT}/component.plist"

cleanup() {
  rm -rf "${TMP_ROOT}"
}
trap cleanup EXIT

echo "[1/4] Building ${APP_NAME}.app..."
if [[ -d "${BUILD_DIR}" ]]; then
  if ! rm -rf "${BUILD_DIR}" 2>/dev/null; then
    echo "Build dir has restricted files. Fixing ownership with sudo..."
    sudo chflags -R nouchg,noschg "${BUILD_DIR}" 2>/dev/null || true
    sudo chown -R "$(id -un)":staff "${BUILD_DIR}"
    rm -rf "${BUILD_DIR}"
  fi
fi
xcodebuild clean -workspace "${WORKSPACE}" -scheme "${SCHEME}" >/dev/null
xcodebuild -workspace "${WORKSPACE}" -scheme "${SCHEME}" \
  -destination "generic/platform=macOS,name=Any Mac" \
  -configuration Release \
  CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Build output not found: ${APP_PATH}"
  exit 1
fi

echo "[2/4] Preparing package payload..."
mkdir -p "${STAGE_DIR}${INSTALL_LOCATION}"
cp -R "${APP_PATH}" "${STAGE_DIR}${INSTALL_LOCATION}/${APP_NAME}.app"
find "${STAGE_DIR}" -name '._*' -delete

pkgbuild --analyze --root "${STAGE_DIR}" "${COMPONENT_PLIST}"
/usr/libexec/PlistBuddy -c "Set :0:BundleIsRelocatable false" "${COMPONENT_PLIST}"
/usr/libexec/PlistBuddy -c "Set :0:BundleHasStrictIdentifier true" "${COMPONENT_PLIST}"
/usr/libexec/PlistBuddy -c "Set :0:BundleOverwriteAction upgrade" "${COMPONENT_PLIST}"

echo "[3/4] Building installer package..."
mkdir -p "${DIST_DIR}"
rm -f "${PKG_PATH}"

if [[ -n "${INSTALLER_SIGN_IDENTITY:-}" ]]; then
  pkgbuild \
    --root "${STAGE_DIR}" \
    --component-plist "${COMPONENT_PLIST}" \
    --scripts "${PKG_SCRIPTS_DIR}" \
    --identifier "${BUNDLE_ID}" \
    --version "${VERSION}" \
    --install-location "/" \
    --sign "${INSTALLER_SIGN_IDENTITY}" \
    "${PKG_PATH}"
else
  pkgbuild \
    --root "${STAGE_DIR}" \
    --component-plist "${COMPONENT_PLIST}" \
    --scripts "${PKG_SCRIPTS_DIR}" \
    --identifier "${BUNDLE_ID}" \
    --version "${VERSION}" \
    --install-location "/" \
    "${PKG_PATH}"
fi

echo "[4/4] Done"
echo "PKG created: ${PKG_PATH}"