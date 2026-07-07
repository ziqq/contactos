# Contributing

Thanks for contributing to `contactos`.

This repository is a federated Flutter plugin monorepo with these packages:

- `contactos` — app-facing package
- `contactos_android` — Android implementation
- `contactos_foundation` — iOS implementation
- `contactos_platform_interface` — shared platform contract

## Prerequisites

- Flutter is managed with [FVM](https://fvm.app/).
- Use the Flutter version defined in `.fvmrc`.
- Run commands from the repository root unless noted otherwise.

## Setup

Install dependencies for all packages:

```sh
make get
```

## Development Workflow

Before opening a pull request, run the full local validation pipeline:

```sh
make all
```

This runs:

- formatting
- analysis
- unit tests

You can also run the pre-commit alias:

```sh
make precommit
```

## Package-Specific Commands

Each package has its own `Makefile` with the same targets. Examples:

```sh
cd contactos && make all
cd contactos_android && make all
cd contactos_foundation && make all
cd contactos_platform_interface && make all
```

## Release Notes

When a package changes in a way that should be released:

- update the package version in its `pubspec.yaml`
- add an entry to that package's `CHANGELOG.md`
- update README documentation if SDK requirements, setup steps, or release behavior changed

## Release Validation

Run a dry-run publish check from the repository root:

```sh
make publish-check
```

Run this from a clean git state when possible. `dart pub publish --dry-run` warns if modified files are still uncommitted.

## Release Order

Publish dependent packages before packages that consume them.

Publish `contactos_platform_interface` first only when it changed.

## GitHub Publish Workflow

The repository includes a GitHub Actions workflow at `.github/workflows/publish.yml`.

It supports:

- manual dispatch with package selection
- tag-based publishing

The root package can be published with either `v<version>` or `contactos-v<version>`. Federated packages use kebab-case tags.

Current tag patterns include:

- `contactos-v<version>`
- `contactos-android-v<version>`
- `contactos-foundation-v<version>`
- `contactos-platform-interface-v<version>`

## Known External Warning

Example app builds may still show a warning for `permission_handler_apple` and Swift Package Manager support. This warning comes from an external dependency and is not currently treated as a release blocker for this repository.

## Pull Requests

Please keep pull requests focused. Include:

- what changed
- why it changed
- what validation you ran