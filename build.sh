#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
root="$PWD"
architecture="${ARCH:-$(uname -m)}"
case "$architecture" in arm64|x86_64) ;; *) echo 'ARCH must be arm64 or x86_64.' >&2; exit 1;; esac
command -v python3 >/dev/null || { echo 'Python 3 is required for build tooling.' >&2; exit 1; }
xcrun --find swiftc >/dev/null
mkdir -p build/cache build/iconset
app="$root/build/Token Meter.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
xcrun swiftc -module-cache-path "$root/build/cache" -swift-version 5 -O \
  -target "$architecture-apple-macosx13.0" -framework AppKit -framework SwiftUI \
  Source/Usage.swift Source/main.swift -o "$app/Contents/MacOS/TokenMeter"
xcrun swiftc -module-cache-path "$root/build/cache" Source/Icon.swift -o build/make-icon
build/make-icon build/iconset
python3 Source/pack_icon.py build/iconset "$app/Contents/Resources/AppIcon.icns"
cp LICENSE "$app/Contents/Resources/LICENSE.txt"
python3 - "$app/Contents/Info.plist" <<'PY'
import pathlib, plistlib, re, sys
version=pathlib.Path('VERSION').read_text().strip()
if not re.fullmatch(r'\d+\.\d+\.\d+',version): raise SystemExit('Invalid VERSION')
info={'CFBundleExecutable':'TokenMeter','CFBundleIdentifier':'local.tokenmeter.app',
'CFBundleName':'Token Meter','CFBundleDisplayName':'Token Meter','CFBundleVersion':'8',
'CFBundleShortVersionString':version,'CFBundlePackageType':'APPL','LSUIElement':True,
'LSMinimumSystemVersion':'13.0','NSHighResolutionCapable':True,'CFBundleIconFile':'AppIcon'}
with open(sys.argv[1],'wb') as f: plistlib.dump(info,f)
PY
/usr/bin/codesign --force --sign - "$app"
/usr/bin/codesign --verify --deep --strict "$app"
printf 'Built %s for %s (local ad-hoc signature; not notarized).\n' "$app" "$architecture"
