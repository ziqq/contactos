# contactos
[![pub package](https://img.shields.io/pub/v/contactos.svg)](https://pub.dartlang.org/packages/contactos)
[![codecov](https://codecov.io/gh/ziqq/contactos/graph/badge.svg?token=S5CVNZKDAE)](https://codecov.io/gh/ziqq/contactos)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)


##  Description

A Flutter plugin to access and manage the device's contacts.


<!-- <img src="https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.docs/images/full_example_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.docs/images/full_example_dark.png"  width="385px"> <img src="https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.docs/images/filtered_example_light.png" width="385px">  <img src="https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.docs/images/filtered_example_dark.png" width="385px"> -->


## Installation

To use this plugin, add `contactos` as a [dependency in your `pubspec.yaml` file](https://flutter.io/platform-plugins/).
For example:
```yaml
dependencies:
    contactos: ^0.2.0
```


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

And add PermissionGroup.contacts in your Podfile
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
`contactos` does not handle the process of asking and checking for permissions. To check and request user permission to access contacts, try using the following plugins: [permission_handler](https://pub.dartlang.org/packages/permission_handler).

If you do not request user permission or have it granted, the application will fail. For testing purposes, you can manually set the permissions for your test app in Settings for your app on the device that you are using. For Android, go to "Settings" - "Apps" - select your test app - "Permissions" - then turn "on" the slider for contacts.


## Example

```dart
// Import package
import 'package:contactos/contactos.dart';

// Get all contacts on device.
List<Contact> contacts = await Contactos.getContacts();

// Get all contacts without thumbnail (faster).
List<Contact> contacts = await Contactos.getContacts(withThumbnails: false);

// Android only: Get thumbnail for an avatar afterwards (only necessary if `withThumbnails: false` is used).
Uint8List avatar = await Contactos.getAvatar(contact);

// Get contacts matching a string.
List<Contact> johns = await Contactos.getContacts(query : "john");

// Add a contact.
// The contact must have a firstName / lastName to be successfully added.
await Contactos.addContact(newContact);

// Delete a contact.
// The contact must have a valid identifier.
await Contactos.deleteContact(contact);

// Update a contact.
// The contact must have a valid identifier.
await Contactos.updateContact(contact);

// Usage of the native device form for creating a Contact.
// Throws a error if the Form could not be open or the Operation is canceled by the User.
await Contactos.openContactForm();

// Usage of the native device form for editing a Contact.
// The contact must have a valid identifier.
// Throws a error if the Form could not be open or the Operation is canceled by the User.
await Contactos.openExistingContact(contact);


```
**Contact Model**
```dart
// Name
String displayName, givenName, middleName, prefix, suffix, familyName;

// Company
String company, jobTitle;

// Email addresses
List<Item> emails = [];

// Phone numbers
List<Item> phones = [];

// Post addresses
List<PostalAddress> postalAddresses = [];

// Contact avatar/thumbnail
Uint8List avatar;
```

![Example](https://raw.githubusercontent.com/ziqq/contactos/refs/heads/main/.docs/example.gif "Example screenshot")


## Changelog

Refer to the [Changelog](https://github.com/ziqq/contactos/blob/main/CHANGELOG.md) to get all release notes.


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## License

[MIT](https://github.com/ziqq/contactos/blob/main/LICENSE)


## Contributions

Contributions are welcome! If you find a bug or want a feature, please fill an issue.

If you want to contribute code please create a pull request under the master branch.


## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Support on Patreon](https://www.patreon.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)


##  Coverage

<img  src="https://codecov.io/gh/ziqq/contactos/graphs/sunburst.svg?token=S5CVNZKDAE"  width="375">
