# Contributing

Thanks for contributing to `contactos`.

This repository is a federated Flutter plugin monorepo:

- `contactos` — app-facing package
- `contactos_platform_interface` — shared platform contract and models
- `contactos_android` — Android implementation
- `contactos_foundation` — iOS implementation

See [docs/architecture.md](docs/architecture.md) for how they fit together.


## Toolchain

Use either [mise](https://mise.jdx.dev) or [FVM](https://fvm.app).

### mise

[`mise.toml`](mise.toml) pins the latest stable Flutter and Temurin 17 (needed
for Android builds and JVM tests). CI installs the same toolchain.

```sh
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc

mise install
mise current
flutter --version
```

Without shell activation, prefix commands with `mise exec --`:

```sh
mise exec -- make all
```

### FVM

[`.fvmrc`](.fvmrc) maps the `development` flavor to `stable` and `production`
to the minimum supported SDK (`3.44.0`). Use FVM to check changes against the
minimum SDK:

```sh
fvm use production
```

The Makefiles prefer `fvm` when it is installed and fall back to the
`flutter` and `dart` found on `PATH` (for example, from mise).


## Setup

```sh
make get
```


## Development workflow

Run the full pipeline before opening a pull request:

```sh
make all        # format + analyze + pana + unit tests
make precommit  # same as make all
```

Useful root targets:

| Command | What it does |
|---|---|
| `make format` | Format all packages, tools and examples |
| `make format-check` | Fail on unformatted code, like CI |
| `make analyze` | Analyze all packages with fatal infos and warnings |
| `make check` | Analyze and run pana for all packages |
| `make test-unit` | Run Dart unit tests for all packages |
| `make publish-check` | Dry-run `pub publish` for all packages |

Each package has a `Makefile` with the same targets:

```sh
cd contactos_android && make all
```


## Native tests

### Android

JVM tests with Robolectric live in
`contactos_android/android/src/test/` and run through the Android example:

```sh
cd contactos_android
make test-android-native
```

The JaCoCo report is written to
`contactos_android/example/build/contactos_android/reports/jacoco/`.

### iOS (macOS only)

XCTest cases live in the `RunnerTests` target of
`contactos_foundation/example/ios`. Pass a dedicated simulator:

```sh
cd contactos_foundation
IOS_SIMULATOR_ID=<simulator-udid> make test-ios-native
```

Swift coverage is exported to `contactos_foundation/coverage/ios.lcov.info`.
List simulators with `xcrun simctl list devices available`.


## Screenshots and screen recordings

### Screenshots

The example app screenshots in `contactos/screenshots/` are rendered by a
widget test with demo contacts. They are used by the READMEs and by the
`screenshots` field of `contactos/pubspec.yaml`. Regenerate them after UI
changes:

```sh
make screenshots
```

### Video

Record the example app on a booted iOS Simulator or a connected Android
device, then convert the recording to README media (`.github/images/example.mp4`,
`.webp` and `.gif`). `ffmpeg` is required.

```sh
cd contactos/example && flutter run   # in a separate terminal

make record-ios OUT=build/media/ios.mov          # Ctrl+C to stop
make record-android OUT=build/media/android.mp4  # Ctrl+C to stop, max 180 s

make media IN=build/media/ios.mov NAME=example
```

The recording scripts set a clean status bar (9:41, full battery) while
recording. Tune the preview size with `WIDTH=` and `FPS=` (defaults: 320 px,
15 fps).


## Release workflow

Versions are released per package.

1. Update the package `version` in its `pubspec.yaml`.
2. Add a `## <version>` entry at the top of the package `CHANGELOG.md`.
3. Update README documentation if SDK requirements, setup steps or behavior
   changed.
4. Run `make publish-check` from a clean git state.
5. Merge to `main`, then create and push the package tag:

   ```sh
   make tag PKG=contactos_android
   ```

Release dependencies before the packages that use them:
`contactos_platform_interface` first (only when it changed), then
`contactos_android` and `contactos_foundation`, then `contactos`.

### Tags

| Package | Tag |
|---|---|
| `contactos` | `contactos-v<version>` |
| `contactos_android` | `contactos-android-v<version>` |
| `contactos_foundation` | `contactos-foundation-v<version>` |
| `contactos_platform_interface` | `contactos-platform-interface-v<version>` |

Pushing a tag runs [`.github/workflows/publish.yml`](.github/workflows/publish.yml).
It checks that the tag, the pubspec version and the first CHANGELOG entry
match, validates the package (format, analyzer, tests, pana score of at least
150) and publishes it to pub.dev with
[automated publishing](https://dart.dev/tools/pub/automated-publishing) (GitHub
OIDC, no stored credentials). It then creates a GitHub release from the
CHANGELOG entry, moves released issues to `done` and sends a notification.

Automated publishing must be enabled once per package on pub.dev
(**Admin → Automated publishing**) for the `ziqq/contactos` repository with
the tag pattern from the table above, for example
`contactos-android-v{{version}}`.


## Known external warning

Example app builds may show a warning for `permission_handler_apple` and Swift
Package Manager support. It comes from an external dependency and is not a
release blocker.


## Pull requests

Keep pull requests focused. Include:

- what changed
- why it changed
- what validation you ran
