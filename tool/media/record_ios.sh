#!/usr/bin/env bash
# Records the booted iOS Simulator screen until Ctrl+C.
# Usage: tool/media/record_ios.sh [output.mov]
set -euo pipefail

output="${1:-build/media/ios.mov}"
mkdir -p "$(dirname -- "$output")"
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 || true
echo "Recording the booted simulator to $output. Press Ctrl+C to stop."
xcrun simctl io booted recordVideo --codec=h264 --force "$output"
xcrun simctl status_bar booted clear || true
