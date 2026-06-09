# Contactos Plugin for Flutter
[![pub package](https://img.shields.io/pub/v/contactos.svg)](https://pub.dev/packages/contactos)
[![codecov](https://codecov.io/gh/ziqq/contactos/graph/badge.svg?token=KRHRN8QVXJ)](https://codecov.io/gh/ziqq/contactos)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)


## Description

A Flutter plugin to access and manage the device's contacts.

This plugin uses the [federated plugin architecture](https://flutter.dev/go/federated-plugins). The main packages are:

| Package | Description | Pub |
|---|---|---|
| [`contactos`](contactos/) | App-facing package | [![pub](https://img.shields.io/pub/v/contactos.svg)](https://pub.dev/packages/contactos) |
| [`contactos_platform_interface`](contactos_platform_interface/) | Platform interface | [![pub](https://img.shields.io/pub/v/contactos_platform_interface.svg)](https://pub.dev/packages/contactos_platform_interface) |
| [`contactos_android`](contactos_android/) | Android implementation | [![pub](https://img.shields.io/pub/v/contactos_android.svg)](https://pub.dev/packages/contactos_android) |
| [`contactos_foundation`](contactos_foundation/) | iOS implementation | [![pub](https://img.shields.io/pub/v/contactos_foundation.svg)](https://pub.dev/packages/contactos_foundation) |


## Package Structure

The repository is a multi-package monorepo:

```
contactos/
├── contactos/                                     # App-facing package (what users depend on)
│   ├── lib/
│   │   ├── contactos.dart                         # Public API barrel file
│   │   └── src/
│   │       ├── contactos.dart                     # Contactos class (delegates to platform)
│   │       └── contactos_legacy.dart.             # Legacy API (deprecated)
│   ├── example/                                   # Example app
│   └── test/
├── contactos_platform_interface/                  # Platform interface (abstract contract)
│   ├── lib/
│   │   ├── contactos_platform_interface.dart
│   │   └── src/
│   │       ├── contactos_platform_interface.dart  # ContactosPlatform abstract class
│   │       ├── method_channel_contactos.dart      # MethodChannel implementation
│   │       └── types.dart                         # Contact, Contact$Field, Contact$PostalAddress, etc.
│   └── test/
├── contactos_android/                             # Android implementation
│   ├── android/                                   # Native Android code (Java/Kotlin)
│   ├── lib/
│   │   └── src/
│   │       └── contactos_android.dart  # ContactosPluginAndroid
│   └── test/
├── contactos_foundation/                          # iOS (Darwin) implementation
│   ├── darwin/                                    # Native iOS code (Swift/ObjC)
│   ├── lib/
│   │   └── src/
│   │       └── contactos_foundation.dart          # ContactosPluginFoundation
│   └── test/
├── AGENTS.md                                      # This file — agent conventions
├── CLAUDE.md                                      # Claude-specific instructions
├── Makefile                                       # Root-level make targets
└── .fvmrc                                         # FVM Flutter version config
```


## Installation

To use this plugin, add `contactos` as a [dependency in your `pubspec.yaml` file](https://flutter.dev/to/using-packages).
For example:
```yaml
dependencies:
    contactos: ^latest_version
```

Starting with `contactos 2.1.0`, the app-facing package requires Dart `>=3.12.1 <4.0.0` and Flutter `>=3.44.1`. The Android implementation package `contactos_android 0.1.0` requires Flutter `>=3.44.1`.


## Permissions

### Android
Add the following permissions to your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
```

### iOS
Set the `NSContactsUsageDescription` in your `Info.plist` file.
```xml
<key>NSContactsUsageDescription</key>
<string>This app requires contacts access to function properly.</string>
```

And add PermissionGroup.contacts in your Podfile:
```Ruby
target.build_configurations.each do |config|
    config.build_settings
    ['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',

        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=1',
    ]
end
```


**Note**
`contactos` does not handle the process of asking and checking for permissions. To check and request user permission to access contacts, try using the following plugins: [permission_handler](https://pub.dev/packages/permission_handler).

If you do not request user permission or have it granted, the application will fail. For testing purposes, you can manually set the permissions for your test app in Settings for your app on the device that you are using. For Android, go to "Settings" - "Apps" - select your test app - "Permissions" - then turn "on" the slider for contacts.


## Example

```dart
// Import package
import 'package:contactos/contactos.dart';

// Get all contacts on device.
List<Contact> contacts = await Contactos.instance.getContacts();

// Get all contacts without thumbnail (faster).
List<Contact> contacts = await Contactos.instance.getContacts(withThumbnails: false);

// Android only: Get thumbnail for an avatar afterwards (only necessary if `withThumbnails: false` is used).
Uint8List avatar = await Contactos.instance.getAvatar(contact);

// Get contacts matching a string.
List<Contact> johns = await Contactos.instance.getContacts(query: "john");

// Add a contact.
// The contact must have a firstName / lastName to be successfully added.
await Contactos.instance.addContact(newContact);

// Delete a contact.
// The contact must have a valid identifier.
await Contactos.instance.deleteContact(contact);

// Update a contact.
// The contact must have a valid identifier.
await Contactos.instance.updateContact(contact);

// Usage of the native device form for creating a Contact.
// Throws an error if the form could not be opened or the operation is canceled by the user.
await Contactos.instance.openContactForm();

// Usage of the native device form for editing a Contact.
// The contact must have a valid identifier.
// Throws an error if the form could not be opened or the operation is canceled by the user.
await Contactos.instance.openExistingContact(contact);
```

**Contact Model**
```dart
// Name
String displayName, givenName, middleName, prefix, suffix, familyName;

// Company
String company, jobTitle;

// Email addresses
List<Contact$Field> emails = [];

// Phone numbers
List<Contact$Field> phones = [];

// Post addresses
List<Contact$PostalAddress> postalAddresses = [];

// Contact avatar/thumbnail
Uint8List avatar;
```

![Example](https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.github/images/example.gif "Example screenshot")


## Development

This project uses [FVM](https://fvm.app/) for Flutter version management. See `.fvmrc` for the configured version.

```bash
# Get dependencies for all packages
make get

# Full pipeline: format + check + test-unit
make all

# Run before committing
make precommit
```

See each package's `Makefile` for per-package targets.


## Changelog

Each package has its own changelog:

- [contactos/CHANGELOG.md](contactos/CHANGELOG.md)
- [contactos_platform_interface/CHANGELOG.md](contactos_platform_interface/CHANGELOG.md)
- [contactos_android/CHANGELOG.md](contactos_android/CHANGELOG.md)
- [contactos_foundation/CHANGELOG.md](contactos_foundation/CHANGELOG.md)


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## License

[MIT](https://github.com/ziqq/contactos/blob/main/LICENSE)


## Contributions

Contributions are welcome! If you find a bug or want a feature, please fill an issue.

If you want to contribute code please create a pull request.


## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)


## Coverage

<img src="https://codecov.io/gh/ziqq/contactos/graphs/sunburst.svg?token=KRHRN8QVXJ" width="375">
