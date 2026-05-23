#!/usr/bin/env bash
# After xcodebuild -create-xcframework, ensure CFBundleExecutable matches the
# on-disk binary name (FreeTDS). Xcode fails with "could not determine executable
# path for bundle" when the plist says FreeTDS-iOS but the binary is FreeTDS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XCFW="${ROOT}/ios/freetds/FreeTDS.xcframework"

for slice in ios-arm64 ios-arm64_x86_64-simulator; do
  fw="${XCFW}/${slice}/FreeTDS.framework"
  plist="${fw}/Info.plist"
  if [[ ! -f "${plist}" ]]; then
    echo "missing ${plist}" >&2
    exit 1
  fi
  /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable FreeTDS" "${plist}" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string FreeTDS" "${plist}"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName FreeTDS" "${plist}" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleName string FreeTDS" "${plist}"
  if [[ ! -f "${fw}/FreeTDS" ]]; then
    echo "missing binary ${fw}/FreeTDS" >&2
    exit 1
  fi
  codesign --force --sign - "${fw}"
  echo "fixed ${slice}"
done
