#!/usr/bin/env python3
"""Converts the Swift plugin coverage from an .xcresult bundle to LCOV.

Lines marked with coverage:ignore comments are skipped, same markers as
package:coverage for Dart:
  // coverage:ignore-line
  // coverage:ignore-start ... // coverage:ignore-end

Usage: export_ios_coverage.py <Tests.xcresult>
"""

import json
import pathlib
import subprocess
import sys

RELATIVE_SOURCE = (
    'contactos_foundation/Sources/contactos_foundation/ContactosPlugin.swift'
)
COMPILED_SUFFIX = '/Sources/contactos_foundation/ContactosPlugin.swift'


def ignored_lines(source: pathlib.Path) -> set[int]:
    ignored: set[int] = set()
    inside = False
    for number, line in enumerate(source.read_text().splitlines(), start=1):
        if 'coverage:ignore-start' in line:
            inside = True
        if inside or 'coverage:ignore-line' in line:
            ignored.add(number)
        if 'coverage:ignore-end' in line:
            inside = False
    return ignored


def xccov(*arguments: str) -> str:
    return subprocess.run(
        ['xcrun', 'xccov', 'view', '--archive', *arguments],
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def export(result: str) -> None:
    """Writes coverage/ios.lcov.info from the [result] bundle."""
    package_dir = pathlib.Path(__file__).resolve().parent.parent

    # Xcode may record the plugin through the example's .symlinks directory,
    # so find the compiled path by its suffix instead of the real path.
    compiled = next(
        (
            path
            for path in xccov('--file-list', result).splitlines()
            if path.endswith(COMPILED_SUFFIX)
        ),
        None,
    )
    if compiled is None:
        sys.exit('No Swift plugin coverage found')

    # Export only the plugin; do not count Runner, generated registration,
    # or Flutter.
    ignored = ignored_lines(package_dir / 'darwin' / RELATIVE_SOURCE)
    lines = sorted(
        (
            line
            for line in json.loads(
                xccov('--file', compiled, '--json', result)
            )[compiled]
            if line['isExecutable'] and line['line'] not in ignored
        ),
        key=lambda line: line['line'],
    )
    if not lines:
        sys.exit('No Swift plugin coverage found')

    hit = sum(1 for line in lines if line['executionCount'] > 0)
    lcov = [
        'TN:',
        f'SF:contactos_foundation/darwin/{RELATIVE_SOURCE}',
        *(f'DA:{line["line"]},{line["executionCount"]}' for line in lines),
        f'LF:{len(lines)}',
        f'LH:{hit}',
        'end_of_record',
    ]
    coverage = package_dir / 'coverage'
    coverage.mkdir(exist_ok=True)
    (coverage / 'ios.lcov.info').write_text('\n'.join(lcov) + '\n')


def main() -> None:
    export(sys.argv[1])


if __name__ == '__main__':
    main()
