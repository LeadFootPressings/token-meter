#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
destination="$HOME/Applications"
login=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --destination) [[ $# -ge 2 ]] || exit 2; destination="$2"; shift 2 ;;
    --login) login=true; shift ;;
    *) echo 'Usage: ./install.sh [--destination DIRECTORY] [--login]' >&2; exit 2 ;;
  esac
done
app="$destination/Token Meter.app"
agent="$HOME/Library/LaunchAgents/local.tokenmeter.app.plist"
[[ -d 'build/Token Meter.app' ]] || { echo 'Run ./build.sh first.' >&2; exit 1; }
[[ ! -e "$app" && ! -L "$app" ]] || { echo 'Existing app found; refusing to overwrite it.' >&2; exit 1; }
if $login; then
  [[ "$destination" == "$HOME/Applications" ]] || { echo '--login requires the default destination.' >&2; exit 1; }
  [[ ! -e "$agent" && ! -L "$agent" ]] || { echo 'Existing login launcher found; refusing to overwrite it.' >&2; exit 1; }
fi
/usr/bin/codesign --verify --deep --strict 'build/Token Meter.app'
mkdir -p "$destination"
/usr/bin/ditto 'build/Token Meter.app' "$app"
/usr/bin/codesign --verify --deep --strict "$app"
if $login; then
  mkdir -p "$(dirname "$agent")"
  python3 - "$agent" "$app" <<'PY'
import plistlib,sys
with open(sys.argv[1],'xb') as f:
    plistlib.dump({'Label':'local.tokenmeter.app','ProgramArguments':[sys.argv[2]+'/Contents/MacOS/TokenMeter'],'RunAtLoad':True,'ProcessType':'Interactive'},f)
PY
  chmod 644 "$agent"
  if ! launchctl bootstrap "gui/$(id -u)" "$agent"; then
    echo 'App copied; login launcher could not be loaded. See docs/DISTRIBUTION.md for recovery.' >&2
    exit 1
  fi
fi
printf 'Installed %s. Login startup: %s.\n' "$app" "$login"
