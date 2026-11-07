#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
app='build/Token Meter.app'
[[ -d "$app" ]] || { echo 'Run ./build.sh first.' >&2; exit 1; }
/usr/bin/codesign --verify --deep --strict "$app"
version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
architecture=$(lipo -archs "$app/Contents/MacOS/TokenMeter")
[[ "$architecture" == arm64 || "$architecture" == x86_64 ]] || { echo 'Unsupported package architecture.' >&2; exit 1; }
mkdir -p dist
archive="dist/Token-Meter-$version-$architecture-local-review.zip"
[[ ! -e "$archive" ]] || { echo 'Package exists; archive it before rebuilding.' >&2; exit 1; }
COPYFILE_DISABLE=1 /usr/bin/ditto -c -k --norsrc --keepParent "$app" "$archive"
(cd dist && shasum -a 256 "$(basename "$archive")" > "$(basename "$archive").sha256")
printf 'Created %s. Local review only; not a signed/notarized public release.\n' "$archive"
