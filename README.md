# Contactos

[![pub package](https://img.shields.io/pub/v/contactos.svg)](https://pub.dev/packages/contactos)
[![CI](https://github.com/ziqq/contactos/actions/workflows/checkout.yml/badge.svg)](https://github.com/ziqq/contactos/actions/workflows/checkout.yml)
[![codecov](https://codecov.io/gh/ziqq/contactos/graph/badge.svg?token=KRHRN8QVXJ)](https://codecov.io/gh/ziqq/contactos)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)


## Description

A Flutter plugin to read, create, update and delete the device's contacts and
to open the native contact form and picker on Android and iOS.

<img src="contactos/screenshots/2_contacts_list.png" width="240" alt="Contacts list"> <img src="contactos/screenshots/3_contact_details.png" width="240" alt="Contact details"> <img src="contactos/screenshots/4_add_contact.png" width="240" alt="Add a contact">

![Example](.github/images/example.gif "Example app")

**Usage, permissions and the API reference are in the
[`contactos` README](contactos/README.md).**

```dart
import 'package:contactos/contactos.dart';

final contacts = await Contactos.instance.getContacts(withThumbnails: false);
```


## Packages

The plugin uses the [federated plugin architecture](https://flutter.dev/go/federated-plugins).

| Package | Description | Pub |
|---|---|---|
| [`contactos`](contactos/) | App-facing package | [![pub](https://img.shields.io/pub/v/contactos.svg)](https://pub.dev/packages/contactos) |
| [`contactos_platform_interface`](contactos_platform_interface/) | Platform interface and models | [![pub](https://img.shields.io/pub/v/contactos_platform_interface.svg)](https://pub.dev/packages/contactos_platform_interface) |
| [`contactos_android`](contactos_android/) | Android implementation (Java, Contacts Provider) | [![pub](https://img.shields.io/pub/v/contactos_android.svg)](https://pub.dev/packages/contactos_android) |
| [`contactos_foundation`](contactos_foundation/) | iOS implementation (Swift, Contacts framework) | [![pub](https://img.shields.io/pub/v/contactos_foundation.svg)](https://pub.dev/packages/contactos_foundation) |

See [docs/architecture.md](docs/architecture.md) for how the packages fit together.


## Repository structure

```
contactos/
├── contactos/                     # App-facing package
│   ├── example/                   # Example app (also renders the screenshots)
│   └── screenshots/               # README and pub.dev screenshots
├── contactos_platform_interface/  # ContactosPlatform, MethodChannelContactos, models
├── contactos_android/             # Android implementation
│   ├── android/                   # Java plugin and JVM tests
│   └── example/
├── contactos_foundation/          # iOS implementation
│   ├── darwin/                    # Swift plugin (CocoaPods and Swift Package Manager)
│   ├── example/                   # Example app with the RunnerTests XCTest target
│   └── tool/                      # iOS native test and coverage scripts
├── tool/media/                    # Screen recording and media conversion scripts
├── docs/                          # Architecture notes
├── mise.toml                      # Toolchain for mise
├── .fvmrc                         # Toolchain for FVM
└── Makefile                       # Repository-wide make targets
```


## Development

Install the toolchain with [mise](https://mise.jdx.dev) or
[FVM](https://fvm.app), then validate everything:

```sh
mise install   # or: fvm use
make get
make all       # format + analyze + pana + unit tests
```

The Makefiles use `fvm` when it is installed and the SDK from `PATH`
otherwise. See [CONTRIBUTING.md](CONTRIBUTING.md) for the toolchain setup,
native tests, screenshots, screen recordings and the release workflow, and
[.github/AUTOMATION.md](.github/AUTOMATION.md) for CI, publishing, labels and
notifications.


## Changelog

Each package has its own changelog:

- [contactos](contactos/CHANGELOG.md)
- [contactos_platform_interface](contactos_platform_interface/CHANGELOG.md)
- [contactos_android](contactos_android/CHANGELOG.md)
- [contactos_foundation](contactos_foundation/CHANGELOG.md)


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## License

[MIT](LICENSE)


## Contributions

Contributions are welcome! If you find a bug or want a feature, please open an
[issue](https://github.com/ziqq/contactos/issues). To contribute code, read
[CONTRIBUTING.md](CONTRIBUTING.md) and open a pull request.


## Funding

If you want to support the development of the library:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)


## Coverage

<img src="https://codecov.io/gh/ziqq/contactos/graphs/sunburst.svg?token=KRHRN8QVXJ" width="375">
