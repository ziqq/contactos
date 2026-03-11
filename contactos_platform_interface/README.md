# contactos_platform_interface

[![pub package](https://img.shields.io/pub/v/contactos_platform_interface.svg)](https://pub.dev/packages/contactos_platform_interface)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A common platform interface for the [`contactos`](https://pub.dev/packages/contactos) plugin.

This interface allows platform-specific implementations of the `contactos`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

## Architecture

The `contactos` plugin uses the [federated plugin architecture](https://flutter.dev/go/federated-plugins).

- **`contactos`**: The app-facing package that developers depend on.
- **`contactos_platform_interface`**: This package. It declares the interface that platform packages must implement.
- **`contactos_android`**, **`contactos_foundation`**: Platform-specific implementations.

## Usage

To implement a new platform-specific implementation of `contactos`, extend
[`ContactosPlatform`](lib/src/contactos_platform_interface.dart) with implementations that perform the platform-specific behaviors.

### Example

```dart
class ContactosWindows extends ContactosPlatform {
  static void registerWith() {
    ContactosPlatform.instance = ContactosWindows();
  }

  @override
  Future<List<Contact>> getContacts({String? query, ...}) {
    // Implementation for Windows
  }

  // ... implement other methods
}
```


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## License

[MIT](https://github.com/ziqq/contactos/blob/main/LICENSE)