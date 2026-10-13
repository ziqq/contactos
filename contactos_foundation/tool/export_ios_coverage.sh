#!/usr/bin/env bash
# Converts the Swift plugin coverage from an .xcresult bundle to LCOV.
set -euo pipefail

package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
result="${1:?Pass the XCTest .xcresult bundle path}"
relative="contactos_foundation/darwin/contactos_foundation/Sources/contactos_foundation/ContactosPlugin.swift"
mkdir -p "$package_dir/coverage"

# Xcode may record the plugin through the example's .symlinks directory,
# so find the compiled path by its suffix instead of the real path.
compiled="$(xcrun xccov view --archive --file-list "$result" |
  grep -E '/Sources/contactos_foundation/ContactosPlugin\.swift$' | head -n 1)"
if [[ -z "$compiled" ]]; then
  echo "No Swift plugin coverage found" >&2
  exit 1
fi

# Export only the plugin; do not count Runner, generated registration, or Flutter.
xcrun xccov view --archive --file "$compiled" --json "$result" |
  jq -er --arg source "$compiled" --arg relative "$relative" '
    .[$source] | map(select(.isExecutable)) | sort_by(.line) |
    if length == 0 then error("No Swift plugin coverage found") else
      "TN:", "SF:\($relative)",
      (.[] | "DA:\(.line),\(.executionCount)"),
      "LF:\(length)", "LH:\(map(select(.executionCount > 0)) | length)",
      "end_of_record"
    end
  ' > "$package_dir/coverage/ios.lcov.info"
