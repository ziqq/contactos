// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(ContactosPlatform, () {
    test('disallows implementing interface', () {
      expect(
        () {
          ContactosPlatform.instance = IllegalImplementation();
        },
        // In versions of `package:plugin_platform_interface` prior to fixing
        // https://github.com/flutter/flutter/issues/109339, an attempt to
        // implement a platform interface using `implements` would sometimes
        // throw a `NoSuchMethodError` and other times throw an
        // `AssertionError`. After the issue is fixed, an `AssertionError` will
        // always be thrown. For the purpose of this test, we don't really care
        // what exception is thrown, so just allow any exception.
        throwsA(anything),
      );
    });

    test('supports MockPlatformInterfaceMixin', () {
      ContactosPlatform.instance = MockContactosPlatformImplementation();
    });
  });
}

/// An implementation using `implements` that isn't a mock, which isn't allowed.
class IllegalImplementation implements ContactosPlatform {
  // Intentionally declare self as not a mock to trigger the
  // compliance check.
  @override
  bool get isMock => false;

  @override
  Future<void> addContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  ContactosPlatform delegateFor({required MethodChannelContactos channel}) {
    throw UnimplementedError();
  }
}

class MockContactosPlatformImplementation
    with MockPlatformInterfaceMixin
    implements ContactosPlatform {
  @override
  bool get isMock => false;

  @override
  Future<void> addContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  ContactosPlatform delegateFor({required MethodChannelContactos channel}) {
    throw UnimplementedError();
  }
}
