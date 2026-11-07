#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/cache
xcrun swiftc -module-cache-path build/cache -swift-version 5 Source/Usage.swift tests/main.swift -o build/core-tests
build/core-tests "$(command -v python3)" "$PWD/tests/fixtures/server.py"
'build/Token Meter.app/Contents/MacOS/TokenMeter' --self-test
if [[ "${1:-}" == '--ui' ]]; then
  'build/Token Meter.app/Contents/MacOS/TokenMeter' --test-window-lifecycle
  'build/Token Meter.app/Contents/MacOS/TokenMeter' --test-drag-position
fi
