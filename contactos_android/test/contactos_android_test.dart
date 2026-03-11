// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

import 'package:contactos_android/contactos_android.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactosPluginAndroid -', () {
    const channel = MethodChannel('github.com/ziqq/contactos');
    final log = <MethodCall>[];

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getContacts':
          case 'getContactsForEmail':
          case 'getContactsForPhone':
            return [
              {'identifier': 'id', 'displayName': 'Name'}
            ];
          case 'openContactForm':
          case 'openExistingContact':
            return {'identifier': 'id', 'displayName': 'Name'};
          case 'openDeviceContactPicker':
            return [
              {'identifier': 'id', 'displayName': 'Name'}
            ];
          case 'getAvatar':
            return Uint8List.fromList([0, 1, 2]);
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(log.clear);

    test('registerWith registers the instance', () {
      ContactosPluginAndroid.registerWith();
      expect(ContactosPlatform.instance, isA<ContactosPluginAndroid>());
    });

    group('getContacts -', () {
      test('calls method channel with correct arguments', () async {
        await ContactosPluginAndroid.instance.getContacts(
          query: 'query',
          withThumbnails: false,
          photoHighResolution: false,
          orderByGivenName: false,
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'getContacts',
            arguments: {
              'query': 'query',
              'withThumbnails': false,
              'photoHighResolution': false,
              'orderByGivenName': false,
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });

    group('getContactsForPhone -', () {
      test('calls method channel with correct arguments', () async {
        await ContactosPluginAndroid.instance.getContactsForPhone(
          '123',
          withThumbnails: false,
          photoHighResolution: false,
          orderByGivenName: false,
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'getContactsForPhone',
            arguments: {
              'phone': '123',
              'withThumbnails': false,
              'photoHighResolution': false,
              'orderByGivenName': false,
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });

    group('getContactsForEmail -', () {
      test('calls method channel with correct arguments', () async {
        await ContactosPluginAndroid.instance.getContactsForEmail(
          'test@example.com',
          withThumbnails: false,
          photoHighResolution: false,
          orderByGivenName: false,
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'getContactsForEmail',
            arguments: {
              'email': 'test@example.com',
              'withThumbnails': false,
              'photoHighResolution': false,
              'orderByGivenName': false,
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });

    group('getAvatar -', () {
      test('calls method channel with correct arguments', () async {
        const contact = Contact(identifier: 'id');
        await ContactosPluginAndroid.instance.getAvatar(
          contact,
          photoHighRes: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'getAvatar',
            arguments: {
              'contact': contact.toJson(),
              'identifier': 'id',
              'photoHighResolution': false,
            },
          ),
        );
      });
    });

    group('addContact -', () {
      test('calls method channel with correct arguments', () async {
        const contact = Contact(identifier: 'id');
        await ContactosPluginAndroid.instance.addContact(contact);

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'addContact',
            arguments: contact.toJson(),
          ),
        );
      });
    });

    group('deleteContact -', () {
      test('calls method channel with correct arguments', () async {
        const contact = Contact(identifier: 'id');
        await ContactosPluginAndroid.instance.deleteContact(contact);

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'deleteContact',
            arguments: contact.toJson(),
          ),
        );
      });
    });

    group('updateContact -', () {
      test('calls method channel with correct arguments', () async {
        const contact = Contact(identifier: 'id');
        await ContactosPluginAndroid.instance.updateContact(contact);

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'updateContact',
            arguments: contact.toJson(),
          ),
        );
      });
    });

    group('openContactForm -', () {
      test('calls method channel with correct arguments', () async {
        await ContactosPluginAndroid.instance.openContactForm(
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'openContactForm',
            arguments: {
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });

    group('openExistingContact -', () {
      test('calls method channel with correct arguments', () async {
        const contact = Contact(identifier: 'id');
        await ContactosPluginAndroid.instance.openExistingContact(
          contact,
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'openExistingContact',
            arguments: {
              'contact': contact.toJson(),
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });

    group('openDeviceContactPicker -', () {
      test('calls method channel with correct arguments', () async {
        await ContactosPluginAndroid.instance.openDeviceContactPicker(
          iOSLocalizedLabels: false,
          androidLocalizedLabels: false,
        );

        expect(log, hasLength(1));
        expect(
          log.first,
          isMethodCall(
            'openDeviceContactPicker',
            arguments: {
              'iOSLocalizedLabels': false,
              'androidLocalizedLabels': false,
            },
          ),
        );
      });
    });
  });
}
