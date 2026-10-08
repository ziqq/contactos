#!/usr/bin/env bash
# Records the connected Android device or emulator screen until Ctrl+C
# (Android limits a single recording to 180 seconds).
# Usage: tool/media/record_android.sh [output.mp4]
set -euo pipefail

output="${1:-build/media/android.mp4}"
remote="/sdcard/contactos-recording.mp4"
mkdir -p "$(dirname -- "$output")"

adb shell settings put global sysui_demo_allowed 1
adb shell am broadcast -a com.android.systemui.demo -e command enter >/dev/null
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941 >/dev/null
adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false >/dev/null
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false >/dev/null

finish() {
  # Give screenrecord time to finalize the file before pulling it.
  sleep 2
  adb pull "$remote" "$output"
  adb shell rm -f "$remote"
  adb shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
  echo "Saved $output"
}
trap finish EXIT

echo "Recording the device to $output. Press Ctrl+C to stop."
adb shell screenrecord --bit-rate 8000000 "$remote" || true
