## 0.7.0
- **ADDED**: Bump gradle plugin version
- **ADDED**: `getAvatar` for `iOS`


## [0.6.3]

- **ADDED**: Android `getContactsByEmail`


## [0.6.2]

- **REFACTOR**: All usages of Iterable to use List
- **FIXED**: Issue "import <contactos/contactos-Swift.h> is missing"


## [0.6.1]

- **FIXED**: Issue of add & edit contact on android 30 i.e. 11


## [0.6.0]

- **FIXED**: AsyncTask error due to permission


## [0.5.0-nullsafety.0]

- **CHANGED**: Migrated to null safety in preview mode


## [0.4.6]

- **FIXED**: openExistingContact in Android and in example


## [0.4.5]

- **FIXED**: crashing where activity result coming back from another plugin and not handled
- **FIXED**: swift syntax error in UIActivityIndicatorView.init
- **ADDED**: new functionality openDeviceContactPicker. Function opens native device contact picker corresponding on each native platform (Android or iOS); user can then search and select a specific contact.


## [0.4.4]

- **FIXED**: swift function name
- **ADDED**: parameter iOSLocalizedLabels to openContactForm and openExistingContact


## [0.4.3]

- **FIXED**: getContactsForEmail with iOSLocalizedLabels


## [0.4.2]

- **ADDED**: Two methods have been added to handle creating and editing contacts with device contact form


## [0.4.1]

- **ADDED**: Android: retrieve correct custom phone labels
- **ADDED**: iOS: add localizedLabels parameter to avoid labels translations
- **ADDED**: Android: retrieve correct custom phone labels (refactor)
- **FIXED**: recognize emails predefined labels (work,home,other) when adding a contact to device contacts
- **FIXED**: issue: birthday not imported (Android only)
- **FIXED**: issue: birthday not imported (iOS only) and export the same data as Android '--MM-dd' for birthday without year
- **FIXED**: contacts_test as it was broken from staging branch
- **FIXED**: slowness in get contact for iOS 11+
- **FIXED**: getContacts with phoneQuery to use predicates which are available from iOS 11


## [0.4.0]

- **CHANGED**: Migrated the plugin to android v2 embedding and migrated androidx for example app


## [0.3.10]

- **CHANGED**: Expose the raw account type (e.g. "com.google" or "com.skype") and account name on Android
- **ADDED**: additional labels for work, home, and other for PhoneLabel
- **ADDED**: additional labels for work, home, and other for PostalAddress


## [0.3.9]

- **CHANGED**: Expose androidAccountType as enum in dart. * Only supported for Android.


## [0.3.8]

- **ADDED**: displayName parameter to Contact Constructor


## [0.3.7]

- **CHANGED**: Expose account_type from android


## [0.3.6]

- **ADDED**: the birthday property in the contact class, display it in the example app (@ZaraclaJ)
- **ADDED**: missing birthday property in the contact class (@ZaraclaJ)
- **REMOVED**: redundant equals operator and hashing (@kmccmk9)
- **ADDED**: toString, equals operator and hashcode (@kmccmk9)


## [0.3.5]

- **ADDED**: `getAvatar()` API to lazily retrieve contact avatars * Only implemented for Android.


## [0.3.4]

- **FIXED**: Contact.java comparison to guard NPEs


## [0.3.3]

- **ADDED**: Example app, references to notes field removed in v0.3.1


## [0.3.2]

- **FIXED**: `swift_version` error
- **REMOVED**: Executable file attributes
- **REMOVED**: References to notes field removed in v0.3.1


## [0.3.1]

- **ADDED**: Order by given name, now contacts come sorted from the device
- **REMOVED**: Notes field due to iOS 13 blocking access


## [0.3.0]

- **ADDED**: Closed image streams and cursors on Android


## [0.2.8]

- **ADDED**: Avatar image - was not working. * Android.
- **ADDED**: iOS - update avatar image. * Android custom phone label - adding label other then predefined ones sets the label to specified value.
- **ADDED**: iOS - on getContacts get the higher resolution image (photoHighResolution). Only when withThumbnails is true. photoHighResolution set to default when getting contact. Default is photoHighResolution = true because if you update the contact after getting, it will update the original size picture.
* Android and iOS - getContactsForPhone(String phone, {bool withThumbnails = true, bool photoHighResolution = true}) - gets the contacts with phone filter. * Android


## [0.2.7]

- **REMOVED**: `path_provider`


## [0.2.6]

- **CHANGED**: Updated example app
- **REMOVED**: `share_extend`
- **FIXED**: Bugs


## [0.2.5]

- **ADDED**: Notes support, and updateContact for Android fix
- **ADDED**: Note support for iOS
- **ADDED**: Public method to convert contact to map using the static _toMap
- **CHANGED**: Tests
- **CHANGED**: Example app
- **FIXED**: Bugs


## [0.2.4]

- **ADDED**: Support for more phone labels
- **FIXED**: Bugs


## [0.2.3]

- **ADDED**: permission handling to example app
- **FIXED**: build errors for Android & iOS


## [0.2.2]

* **ADDED:** Update Contact for iOS & Android
- **ADDED**: updateContact method to contactos.dart
- **ADDED**: updateContact method to SwiftContactsServicePlugin.swift
- **ADDED**: unit testing for the updateContact method
- **FIXED**: formatting discrepancies in the example app (making code easier to read)
- **FIXED**: formatting discrepancies in contactos.dart (making code easier to read)
- **CHANGED**: Example app to show updateContacts method
- **CHANGED**: PostalAddress.java and Contact.java (wasn't working properly)
- **ADDED**: `updateContact` method to ContactsServicePlugin.java


## [0.2.1]

* **Breaking:** Updated dependencies


## [0.2.0]

* **Breaking:** Updated to support AndroidX


## [0.1.1]

- **ADDED**: Ability to Share VCF Card


## [0.1.0]

- **CHANGED**: Pubspec version and maintainer info for Dart Pub


## [0.0.9]

- **FIXED**: Issue when fetching contacts on Android


## [0.0.8]

- **FIXED**: Issue with phones being added to emails on Android
- **CHANGED**: Plugin for dart 2


## [0.0.7]

- **FIXED**: PlatformException on iOS
- **ADDED**: Refresh to the contacts list in the sample app when you add a contact
- **ADDED**: Return more meaningful errors when addContact() fails on iOS


## [0.0.6]

- **ADDED**: Contact thumbnails


## [0.0.5]

- **FIXED**: dart 2 compatibility


## [0.0.4]

- **ADDED**: `deleteContact(Contact c)` for Android and iOS


## [0.0.3]

- **ADDED**: `addContact(Contact c)` for Android and iOS


## [0.0.2]

- **ADDED**: Retrieving contacts' prefixes and suffixes


## [0.0.1]

- **ADDED**: All contacts can be retrieved
- **ADDED**: Contacts matching a string can be retrieved
