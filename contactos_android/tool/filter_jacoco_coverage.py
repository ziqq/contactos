#!/usr/bin/env python3
"""Removes lines marked with coverage:ignore comments from a JaCoCo XML report.

Supported markers, same as package:coverage for Dart:
  // coverage:ignore-line
  // coverage:ignore-start ... // coverage:ignore-end

Usage: filter_jacoco_coverage.py <report.xml> <source root>
"""

import pathlib
import re
import sys


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


def main() -> None:
    report = pathlib.Path(sys.argv[1])
    root = pathlib.Path(sys.argv[2])
    xml = report.read_text()

    def filter_package(package: re.Match[str]) -> str:
        directory = root / package.group(1)

        def filter_source(source: re.Match[str]) -> str:
            path = directory / source.group(1)
            if not path.exists():
                return source.group(0)
            ignored = ignored_lines(path)
            return re.sub(
                r'<line nr="(\d+)"[^>]*/>',
                lambda line: '' if int(line.group(1)) in ignored else line.group(0),
                source.group(0),
            )

        return re.sub(
            r'<sourcefile name="([^"]+)">.*?</sourcefile>',
            filter_source,
            package.group(0),
            flags=re.S,
        )

    xml = re.sub(
        r'<package name="([^"]+)">.*?</package>', filter_package, xml, flags=re.S
    )
    report.write_text(xml)


if __name__ == '__main__':
    main()
