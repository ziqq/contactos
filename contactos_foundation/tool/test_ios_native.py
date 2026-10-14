#!/usr/bin/env python3
"""Runs the plugin XCTest suite from example/ios/RunnerTests and exports
Swift coverage to coverage/ios.lcov.info.

Usage: IOS_SIMULATOR_ID=<simulator-udid> test_ios_native.py
"""

import os
import pathlib
import subprocess
import sys
import tempfile

from export_ios_coverage import export


def main() -> None:
    package_dir = pathlib.Path(__file__).resolve().parent.parent
    simulator = os.environ.get('IOS_SIMULATOR_ID')
    if not simulator:
        sys.exit('Set IOS_SIMULATOR_ID to a dedicated test simulator')

    # The store tests read and write the simulator's contacts.
    # Booting an already booted simulator fails, which is fine.
    subprocess.run(
        ['xcrun', 'simctl', 'boot', simulator], stderr=subprocess.DEVNULL
    )
    subprocess.run(
        [
            'xcrun', 'simctl', 'privacy', simulator, 'grant', 'contacts',
            'flutter.plugins.contactos.contactsServiceExample',
        ],
        check=True,
    )

    build = package_dir / 'example' / 'build'
    build.mkdir(parents=True, exist_ok=True)
    results = tempfile.mkdtemp(prefix='native-ios-results-', dir=build)
    result = f'{results}/Tests.xcresult'
    subprocess.run(
        [
            'xcodebuild', 'test',
            '-workspace', str(package_dir / 'example/ios/Runner.xcworkspace'),
            '-scheme', 'Runner', '-configuration', 'Debug',
            '-destination', f'platform=iOS Simulator,id={simulator}',
            '-derivedDataPath', str(build / 'native-ios'),
            '-resultBundlePath', result,
            '-enableCodeCoverage', 'YES', '-parallel-testing-enabled', 'NO',
            'CODE_SIGNING_ALLOWED=NO',
        ],
        check=True,
    )

    export(result)


if __name__ == '__main__':
    main()
