// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/contactos.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  javaOut:
      'android/src/main/java/flutter/plugins/contactos/generated/Contactos.g.java',
  javaOptions: JavaOptions(
    package: 'flutter.plugins.contactos.generated',
    className: 'Contactos',
  ),
  kotlinOut:
      'android/src/main/kotlin/flutter/plugins/contactos/generated/Contactos.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'flutter.plugins.contactos.generated',
    errorClassName: 'ContactosError',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
// @HostApi(dartHostTestHandler: 'TestContactosApi')
abstract class ContactosApi {
  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  void getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Fetches all contacts, or when specified, the contacts with the phone
  /// matching [phone]
  void getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Fetches all contacts, or when specified, the contacts with the email
  /// matching [email]
  /// Works only on iOS
  void getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Loads the avatar for the given contact and returns it. If the user does
  /// not have an avatar, then `null` is returned in that slot. Only implemented
  /// on Android.
  void getAvatar(Map<String, Object?> contact, {bool photoHighRes = true});

  /// Adds the [contact] to the device contact list
  void addContact(Map<String, Object?> contact);

  /// Deletes the [contact] if it has a valid identifier
  void deleteContact(Map<String, Object?> contact);

  /// Updates the [contact] if it has a valid identifier
  void updateContact(Map<String, Object?> contact);

  /// Opens the contact form with the fields prefilled with the values from the
  void openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Opens the contact form with the fields prefilled with the values from the
  /// [contact] parameter
  void openExistingContact(
    Map<String, Object?> contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  // Displays the device/native contact picker dialog and returns the contact selected by the user
  void openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });
}
