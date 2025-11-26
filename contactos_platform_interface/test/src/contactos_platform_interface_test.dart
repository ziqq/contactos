// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactosPlatform -', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    group('instance -', () {
      test('is MethodChannelContactos by default', () {
        expect(ContactosPlatform.instance, isA<MethodChannelContactos>());
      });

      test('cannot be implemented with `implements`', () {
        expect(
          () {
            ContactosPlatform.instance = ImplementsContactosPlatform();
          },
          throwsA(isA<AssertionError>()),
        );
      });

      test('can be extended', () {
        ContactosPlatform.instance = ExtendsContactosPlatform();
      });

      test('isMock returns false by default', () {
        // ignore: deprecated_member_use_from_same_package
        expect(ContactosPlatform.instance.isMock, isFalse);
      });
    });

    group('delegateFor', () {
      test('throws UnimplementedError', () {
        final platform = ExtendsContactosPlatform();
        ContactosPlatform.instance = platform;

        expect(
          () => ContactosPlatform.instanceFor(
            channel: MethodChannelContactos.instance,
          ),
          throwsUnimplementedError,
        );
      });
    });
  });
}

class ImplementsContactosPlatform implements ContactosPlatform {
  @override
  Future<void> addContact(Contact contact) {
    throw UnimplementedError();
  }

  @override
  ContactosPlatform delegateFor({required MethodChannelContactos channel}) {
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
  bool get isMock => true;

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
}

class ExtendsContactosPlatform extends ContactosPlatform {
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
}
