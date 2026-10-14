#!/usr/bin/env python3
"""Runs the plugin XCTest suite from example/ios/RunnerTests and exports
Swift coverage to coverage/ios.lcov.info.

Usage: IOS_SIMULATOR_ID=<simulator-udid> test_ios_native.py
       test_ios_native.py --any-simulator

--any-simulator picks the first available iPhone simulator when
IOS_SIMULATOR_ID is not set. Use it on CI only: the store tests write the
simulator's contacts.
"""

import argparse
import json
import os
import pathlib
import subprocess
import sys
import tempfile

from export_ios_coverage import export


def any_simulator() -> str:
    devices = json.loads(
        subprocess.run(
            ['xcrun', 'simctl', 'list', 'devices', 'available', '--json'],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
    )['devices']
    for runtime in devices.values():
        for device in runtime:
            if device['isAvailable'] and device['name'].startswith('iPhone'):
                return device['udid']
    sys.exit('No iOS Simulator available')


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--any-simulator',
        action='store_true',
        help='use the first available iPhone simulator without IOS_SIMULATOR_ID',
    )
    arguments = parser.parse_args()

    package_dir = pathlib.Path(__file__).resolve().parent.parent
    simulator = os.environ.get('IOS_SIMULATOR_ID')
    if not simulator:
        if not arguments.any_simulator:
            sys.exit('Set IOS_SIMULATOR_ID to a dedicated test simulator')
        simulator = any_simulator()
    print(f'Testing on simulator {simulator}', flush=True)

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
