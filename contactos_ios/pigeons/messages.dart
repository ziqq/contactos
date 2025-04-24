// Copyright 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  swiftOut: 'ios/contactos/Sources/contactos/messages.g.swift',
  copyrightHeader: 'pigeons/copyright_header.txt',
))
class SharedPreferencesPigeonOptions {
  SharedPreferencesPigeonOptions({
    this.suiteName,
  });
  String? suiteName;
}

@HostApi(dartHostTestHandler: 'TestSharedPreferencesAsyncApi')
abstract class UserDefaultsApi {
  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Fetches all contacts, or when specified, the contacts with the phone
  /// matching [phone]
  Future<List<Contact>> getContactsForPhone(
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
  Future<List<Contact>> getContactsForEmail(
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
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true});

  /// Adds the [contact] to the device contact list
  Future<void> addContact(Contact contact);

  /// Deletes the [contact] if it has a valid identifier
  Future<void> deleteContact(Contact contact);

  /// Updates the [contact] if it has a valid identifier
  Future<void> updateContact(Contact contact);

  /// Opens the contact form with the fields prefilled with the values from the
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Opens the contact form with the fields prefilled with the values from the
  /// [contact] parameter
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  // Displays the device/native contact picker dialog and returns the contact selected by the user
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });
}
