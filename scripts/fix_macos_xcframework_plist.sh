#!/usr/bin/env bash
# After xcodebuild -create-xcframework, ensure CFBundleExecutable matches the
# on-disk binary name (FreeTDS) in the versioned macOS framework bundle.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FW="${ROOT}/macos/freetds/FreeTDS.xcframework/macos-arm64_x86_64/FreeTDS.framework"
PLIST="${FW}/Resources/Info.plist"

if [[ ! -f "${PLIST}" ]]; then
  echo "missing ${PLIST}" >&2
  exit 1
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable FreeTDS" "${PLIST}" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string FreeTDS" "${PLIST}"
/usr/libexec/PlistBuddy -c "Set :CFBundleName FreeTDS" "${PLIST}" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleName string FreeTDS" "${PLIST}"

if [[ ! -f "${FW}/FreeTDS" ]]; then
  echo "missing binary ${FW}/FreeTDS" >&2
  exit 1
fi

codesign --force --sign - "${FW}"
echo "fixed macos-arm64_x86_64"
