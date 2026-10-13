# Contactos

[![pub package](https://img.shields.io/pub/v/contactos.svg)](https://pub.dev/packages/contactos)
[![CI](https://github.com/ziqq/contactos/actions/workflows/checkout.yml/badge.svg)](https://github.com/ziqq/contactos/actions/workflows/checkout.yml)
[![codecov](https://codecov.io/gh/ziqq/contactos/graph/badge.svg?token=S5CVNZKDAE)](https://codecov.io/gh/ziqq/contactos)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ziqq/contactos/blob/main/LICENSE)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)


## Description

A Flutter plugin to read, create, update and delete the device's contacts and
to open the native contact form and picker on Android and iOS.

<img src="https://raw.githubusercontent.com/ziqq/contactos/main/contactos/screenshots/2_contacts_list.png" width="240" alt="Contacts list"> <img src="https://raw.githubusercontent.com/ziqq/contactos/main/contactos/screenshots/3_contact_details.png" width="240" alt="Contact details"> <img src="https://raw.githubusercontent.com/ziqq/contactos/main/contactos/screenshots/4_add_contact.png" width="240" alt="Add a contact">


## Features

| Feature | Method | Android | iOS |
|---|---|:---:|:---:|
| List contacts, optionally filtered by name | `getContacts` | ✅ | ✅ |
| Find contacts by phone number | `getContactsForPhone` | ✅ | ✅ |
| Find contacts by email | `getContactsForEmail` | ✅ | ✅ |
| Load a contact avatar | `getAvatar` | ✅ | ✅ |
| Add a contact | `addContact` | ✅ | ✅ |
| Update a contact | `updateContact` | ✅ | ✅ |
| Delete a contact | `deleteContact` | ✅ | ✅ |
| Open the native "new contact" form | `openContactForm` | ✅ | ✅ |
| Open the native form for an existing contact | `openExistingContact` | ✅ | ✅ |
| Pick a contact with the native picker | `openDeviceContactPicker` | ✅ | ✅ |


## Installation

Add `contactos` to your `pubspec.yaml`:

```yaml
dependencies:
  contactos: ^2.1.0
```

| `contactos` | Dart | Flutter |
|---|---|---|
| `>=2.1.0` | `>=3.12.0 <4.0.0` | `>=3.44.0` |


## Permissions

`contactos` does not request permissions. Request the contacts permission
before calling the plugin, for example with
[permission_handler](https://pub.dev/packages/permission_handler).
Calls made without the permission fail.

### Android

Add the permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
```

### iOS

Describe why the app needs contacts in `ios/Runner/Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app requires contacts access to function properly.</string>
```

If you use `permission_handler`, also enable its contacts permission in
`ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=1',
      ]
    end
  end
end
```


## Example

```dart
import 'package:contactos/contactos.dart';

final contactos = Contactos.instance;

// All contacts. Thumbnails are loaded by default.
final contacts = await contactos.getContacts();

// Faster: load the list without thumbnails, then load avatars lazily.
final lightweight = await contactos.getContacts(withThumbnails: false);
final avatar = await contactos.getAvatar(lightweight.first);

// Search.
final johns = await contactos.getContacts(query: 'john');
final byPhone = await contactos.getContactsForPhone('+1 555 0100');
final byEmail = await contactos.getContactsForEmail('john@example.com');

// Add a contact. It needs at least a given or a family name.
await contactos.addContact(
  const Contact(
    givenName: 'John',
    familyName: 'Doe',
    phones: [Contact$Field(label: 'mobile', value: '+1 555 0100')],
    emails: [Contact$Field(label: 'work', value: 'john@example.com')],
  ),
);

// Update and delete need a contact with a valid identifier,
// for example one returned by getContacts.
final john = johns.first;
await contactos.updateContact(john.copyWith(jobTitle: 'Engineer'));
await contactos.deleteContact(john);
```

### Native forms and picker

```dart
try {
  // Create a contact in the native form.
  final created = await contactos.openContactForm();

  // Edit an existing contact in the native form.
  final edited = await contactos.openExistingContact(created);

  // Let the user pick a contact. Returns null when nothing is picked.
  final picked = await contactos.openDeviceContactPicker();
} on FormOperationException catch (error) {
  switch (error.errorCode) {
    case FormOperationErrorCode.canceled:
      // The user closed the form.
      break;
    case FormOperationErrorCode.couldNotBeOpen:
    case FormOperationErrorCode.unknown:
    case null:
      // Report the error.
      break;
  }
}
```

### Labels

Phone, email and address labels are localized by default. Pass
`iOSLocalizedLabels: false` or `androidLocalizedLabels: false` to get stable
English labels such as `mobile`, `home` and `work` instead.

A complete app is available in the
[example](https://github.com/ziqq/contactos/tree/main/contactos/example).


## Contact model

`Contact` is immutable. Use `copyWith` to change it.

| Field | Type | Notes |
|---|---|---|
| `identifier` | `String?` | Platform contact identifier |
| `displayName` | `String?` | Read only, built by the platform |
| `givenName`, `middleName`, `familyName` | `String?` | |
| `prefix`, `suffix` | `String?` | |
| `company`, `jobTitle` | `String?` | |
| `phones`, `emails` | `List<Contact$Field>?` | `label` and `value` |
| `postalAddresses` | `List<Contact$PostalAddress>?` | `street`, `city`, `postcode`, `region`, `country` |
| `birthday` | `DateTime?` | |
| `avatar` | `Uint8List?` | Thumbnail or full-size photo |
| `androidAccountType`, `androidAccountName` | `AndroidAccountType?`, `String?` | Android only |


## Changelog

See the [CHANGELOG](https://github.com/ziqq/contactos/blob/main/contactos/CHANGELOG.md).
Contribution and release workflow details are in the
[CONTRIBUTING guide](https://github.com/ziqq/contactos/blob/main/CONTRIBUTING.md).


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## License

[MIT](https://github.com/ziqq/contactos/blob/main/LICENSE)


## Funding

If you want to support the development of the library:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)
