# contactos_platform_interface

A common platform interface for the [`contactos`][1] plugin.

This interface allows platform-specific implementations of the `contactos`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `contactos`, extend
[`ContactosPlatform`][2] with implementations that perform the platform-specific behaviors,
and when you register your plugin.

Please note that the plugin tooling only registers the native and/or Dart classes
listed in your package's `pubspec.yaml`, so if you intend to implement more than
one class, you will need to manually register the second class
(as can be seen in the Android and iOS implementations).

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../contactos
[2]: lib/contactos_platform_interface.dart