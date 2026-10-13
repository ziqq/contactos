#!/usr/bin/env bash
# Runs the plugin XCTest suite from example/ios/RunnerTests and exports
# Swift coverage to coverage/ios.lcov.info.
set -euo pipefail

package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
simulator="${IOS_SIMULATOR_ID:?Set IOS_SIMULATOR_ID to a dedicated test simulator}"

mkdir -p "$package_dir/example/build"
results="$(mktemp -d "$package_dir/example/build/native-ios-results-XXXXXX")"
xcodebuild test \
  -workspace "$package_dir/example/ios/Runner.xcworkspace" \
  -scheme Runner -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator" \
  -derivedDataPath "$package_dir/example/build/native-ios" \
  -resultBundlePath "$results/Tests.xcresult" \
  -enableCodeCoverage YES -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO

bash "$package_dir/tool/export_ios_coverage.sh" "$results/Tests.xcresult"
