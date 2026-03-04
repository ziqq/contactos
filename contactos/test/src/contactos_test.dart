// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:contactos/contactos.dart';
import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockContactosPlatform extends ContactosPlatform
    with MockPlatformInterfaceMixin {
  List<Contact> contacts = [];
  Contact? lastAddedContact;
  Contact? lastDeletedContact;
  Contact? lastUpdatedContact;
  Contact? lastAvatarContact;
  bool? lastAvatarHighRes;

  @override
  Future<void> addContact(Contact c) async {
    lastAddedContact = c;
  }

  @override
  Future<void> deleteContact(Contact c) async {
    lastDeletedContact = c;
  }

  @override
  Future<void> updateContact(Contact c) async {
    lastUpdatedContact = c;
  }

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) async {
    lastAvatarContact = contact;
    lastAvatarHighRes = photoHighRes;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      contacts;

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      contacts
          .where((c) => c.emails?.any((e) => e.value == email) ?? false)
          .toList();

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      contacts
          .where((c) => c.phones?.any((p) => p.value == phone) ?? false)
          .toList();

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      const Contact(identifier: 'new_contact');

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      const Contact(identifier: 'picked_contact');

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async =>
      contact;
}

void main() {
  group('Contactos -', () {
    late MockContactosPlatform mockPlatform;
    late Contactos contactos;

    setUp(() {
      mockPlatform = MockContactosPlatform();
      contactos = Contactos.custom(mockPlatform);
    });

    group('instance -', () {
      test('returns the default instance', () {
        expect(Contactos.instance, isA<Contactos>());
      });
    });

    group('addContact -', () {
      test('delegates to platform', () async {
        const contact = Contact(identifier: '1', displayName: 'Test');
        await contactos.addContact(contact);
        expect(mockPlatform.lastAddedContact, contact);
      });
    });

    group('deleteContact -', () {
      test('delegates to platform', () async {
        const contact = Contact(identifier: '1', displayName: 'Test');
        await contactos.deleteContact(contact);
        expect(mockPlatform.lastDeletedContact, contact);
      });
    });

    group('updateContact -', () {
      test('delegates to platform', () async {
        const contact = Contact(identifier: '1', displayName: 'Test');
        await contactos.updateContact(contact);
        expect(mockPlatform.lastUpdatedContact, contact);
      });
    });

    group('getAvatar -', () {
      test('delegates to platform', () async {
        const contact = Contact(identifier: '1', displayName: 'Test');
        final result = await contactos.getAvatar(contact, photoHighRes: false);
        expect(mockPlatform.lastAvatarContact, contact);
        expect(mockPlatform.lastAvatarHighRes, false);
        expect(result, isNotNull);
      });
    });

    group('getContacts -', () {
      test('delegates to platform', () async {
        mockPlatform.contacts = [
          const Contact(identifier: '1', displayName: 'Test')
        ];
        final result = await contactos.getContacts();
        expect(result.length, 1);
        expect(result.first.identifier, '1');
      });
    });

    group('getContactsForEmail -', () {
      test('delegates to platform', () async {
        mockPlatform.contacts = [
          const Contact(
            identifier: '1',
            displayName: 'Test',
            emails: [Contact$Field(value: 'test@example.com')],
          ),
          const Contact(identifier: '2', displayName: 'Test 2'),
        ];
        final result = await contactos.getContactsForEmail('test@example.com');
        expect(result.length, 1);
        expect(result.first.identifier, '1');
      });
    });

    group('getContactsForPhone -', () {
      test('delegates to platform', () async {
        mockPlatform.contacts = [
          const Contact(
            identifier: '1',
            displayName: 'Test',
            phones: [Contact$Field(value: '123456')],
          ),
          const Contact(identifier: '2', displayName: 'Test 2'),
        ];
        final result = await contactos.getContactsForPhone('123456');
        expect(result.length, 1);
        expect(result.first.identifier, '1');
      });
    });

    group('openContactForm -', () {
      test('delegates to platform', () async {
        final result = await contactos.openContactForm();
        expect(result.identifier, 'new_contact');
      });
    });

    group('openDeviceContactPicker -', () {
      test('delegates to platform', () async {
        final result = await contactos.openDeviceContactPicker();
        expect(result?.identifier, 'picked_contact');
      });
    });

    group('openExistingContact -', () {
      test('delegates to platform', () async {
        const contact = Contact(identifier: '1', displayName: 'Test');
        final result = await contactos.openExistingContact(contact);
        expect(result, contact);
      });
    });
  });
}
