# Architecture

`contactos` is a [federated Flutter plugin](https://flutter.dev/go/federated-plugins).
Apps depend only on `contactos`; the platform packages are endorsed
implementations that Flutter registers automatically.

```
App
 └─ Contactos.instance                      contactos
     └─ ContactosPlatform.instance          contactos_platform_interface
         ├─ ContactosPluginAndroid          contactos_android
         │   └─ MethodChannelContactos ──► ContactosPlugin.java  (Contacts Provider)
         └─ ContactosPluginFoundation       contactos_foundation
             └─ MethodChannelContactos ──► ContactosPlugin.swift (Contacts, ContactsUI)
```

## Packages

| Package | Responsibility |
|---|---|
| `contactos` | Public API. `Contactos` delegates every call to `ContactosPlatform.instance` and re-exports the models. |
| `contactos_platform_interface` | `ContactosPlatform` contract, the `MethodChannelContactos` channel client and the immutable models `Contact`, `Contact$Field`, `Contact$PostalAddress` and `FormOperationException`. |
| `contactos_android` | `ContactosPluginAndroid` (Dart) registers itself through `dartPluginClass`; `ContactosPlugin` (Java) reads and writes the Android Contacts Provider and opens the system contact screens. |
| `contactos_foundation` | `ContactosPluginFoundation` (Dart) registers itself through `dartPluginClass`; `ContactosPlugin` (Swift) uses `CNContactStore`, `CNContactViewController` and `CNContactPickerViewController`. Shipped for both CocoaPods and Swift Package Manager. |

## Method channel

Both platforms use the `github.com/ziqq/contactos` method channel with the
same method names: `getContacts`, `getContactsForPhone`, `getContactsForEmail`,
`getAvatar`, `addContact`, `updateContact`, `deleteContact`, `openContactForm`,
`openExistingContact` and `openDeviceContactPicker`.

Contacts cross the channel as maps. `Contact.fromJson` and `Contact.toJson` in
the platform interface define the Dart side; `Contact.java` and
`ContactosPlugin.contactToDictionary` / `dictionaryToContact` define the native
sides. Changing a field means changing all three.

Native form results are reported as integer error codes and mapped to
`FormOperationException` (`canceled`, `couldNotBeOpen`, `unknown`).

## Permissions

The plugin never requests permissions. Apps request them before calling the
API, usually with `permission_handler`.

## Tests

| Layer | Location | Runs in CI |
|---|---|---|
| Dart unit tests | `<package>/test/` | `package` job, every package |
| Android JVM tests (Robolectric, JaCoCo) | `contactos_android/android/src/test/` | `android` job |
| iOS XCTest (Swift coverage) | `contactos_foundation/example/ios/RunnerTests/` | `ios` job, CocoaPods and SPM |
| Screenshot generator | `contactos/example/screenshots/` | No, run `make screenshots` |
