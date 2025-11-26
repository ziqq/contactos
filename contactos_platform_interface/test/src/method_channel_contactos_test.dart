import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MethodChannelContactos -', () {
    const channel = MethodChannel('github.com/ziqq/contactos');

    late MethodChannelContactos contactos;
    final log = <MethodCall>[];

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getContacts':
            return [
              {
                'identifier': '1',
                'displayName': 'John Doe',
                'phones': [
                  {'label': 'mobile', 'value': '+123456789'}
                ],
                'emails': [
                  {'label': 'work', 'value': 'johndoe@example.com'}
                ],
              }
            ];
          case 'getContactsForEmail':
            return [
              {
                'identifier': '2',
                'displayName': 'Jane Doe',
                'emails': [
                  {'label': 'home', 'value': 'janedoe@example.com'}
                ],
              }
            ];
          case 'getContactsForPhone':
            return [
              {
                'identifier': '3',
                'displayName': 'Alice Smith',
                'phones': [
                  {'label': 'home', 'value': '+987654321'}
                ],
              }
            ];
          case 'addContact':
          case 'deleteContact':
          case 'updateContact':
            return null;
          case 'getAvatar':
            return Uint8List.fromList([0, 1, 2, 3, 4, 5]);
          default:
            return null;
        }
      });

      contactos = MethodChannelContactos.instance;
      log.clear();
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('getContacts -', () {
      test('should return list of contacts', () async {
        final contacts = await contactos.getContacts();
        expect(contacts, isNotEmpty);
        expect(contacts.first.identifier, '1');
        expect(contacts.first.displayName, 'John Doe');
        expect(contacts.first.phones?.first.value, '+123456789');
        expect(contacts.first.emails?.first.value, 'johndoe@example.com');
        expect(log.single.method, 'getContacts');
      });
    });

    group('getContactsForEmail -', () {
      test('should return list of contacts', () async {
        final contacts =
            await contactos.getContactsForEmail('janedoe@example.com');
        expect(contacts, isNotEmpty);
        expect(contacts.first.identifier, '2');
        expect(contacts.first.displayName, 'Jane Doe');
        expect(contacts.first.emails?.first.value, 'janedoe@example.com');
        expect(log.single.method, 'getContactsForEmail');
      });
    });

    group('getContactsForPhone -', () {
      test('should return list of contacts', () async {
        final contacts = await contactos.getContactsForPhone('+987654321');
        expect(contacts, isNotEmpty);
        expect(contacts.first.identifier, '3');
        expect(contacts.first.displayName, 'Alice Smith');
        expect(contacts.first.phones?.first.value, '+987654321');
        expect(log.single.method, 'getContactsForPhone');
      });

      test('returns empty list if phone is null or empty', () async {
        var contacts = await contactos.getContactsForPhone(null);
        expect(contacts, isEmpty);

        contacts = await contactos.getContactsForPhone('');
        expect(contacts, isEmpty);
      });
    });

    group('getAvatar -', () {
      test('should return Uint8List', () async {
        final avatar =
            await contactos.getAvatar(const Contact(identifier: '1'));
        expect(avatar, isNotNull);
        expect(avatar, isA<Uint8List>());
        expect(log.single.method, 'getAvatar');
      });
    });

    group('addContact -', () {
      test('should call method channel', () async {
        await contactos.addContact(
            const Contact(identifier: '4', displayName: 'New Contact'));
        expect(log.single.method, 'addContact');
      });
    });

    group('deleteContact -', () {
      test('should call method channel', () async {
        await contactos.deleteContact(const Contact(identifier: '5'));
        expect(log.single.method, 'deleteContact');
      });
    });

    group('updateContact -', () {
      test('should call method channel', () async {
        await contactos.updateContact(
            const Contact(identifier: '6', displayName: 'Updated Contact'));
        expect(log.single.method, 'updateContact');
      });
    });

    group('openContactForm -', () {
      test('returns contact on success', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openContactForm') {
            return {'identifier': 'new_id', 'displayName': 'New Contact'};
          }
          return null;
        });

        final contact = await contactos.openContactForm();
        expect(contact.identifier, 'new_id');
        expect(contact.displayName, 'New Contact');
      });

      test('throws canceled exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openContactForm') {
            return 1; // Canceled code
          }
          return null;
        });

        expect(
          () => contactos.openContactForm(),
          throwsA(isA<FormOperationException$Canceled>()),
        );
      });

      test('throws couldNotBeOpen exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openContactForm') {
            return 2; // CouldNotBeOpen code
          }
          return null;
        });

        expect(
          () => contactos.openContactForm(),
          throwsA(isA<FormOperationException$CouldNotBeOpen>()),
        );
      });

      test('throws unknown exception for other codes', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openContactForm') {
            return 999; // Unknown code
          }
          return null;
        });

        expect(
          () => contactos.openContactForm(),
          throwsA(isA<FormOperationException$Unknown>()),
        );
      });
    });

    group('openDeviceContactPicker -', () {
      test('returns contact from list', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openDeviceContactPicker') {
            return [
              {'identifier': 'picked_id', 'displayName': 'Picked Contact'}
            ];
          }
          return null;
        });

        final contact = await contactos.openDeviceContactPicker();
        expect(contact?.identifier, 'picked_id');
      });

      test('returns null if list is empty', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openDeviceContactPicker') {
            return [];
          }
          return null;
        });

        final contact = await contactos.openDeviceContactPicker();
        expect(contact, isNull);
      });
    });

    group('openExistingContact -', () {
      test('returns updated contact', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'openExistingContact') {
            return {'identifier': 'id', 'displayName': 'Updated Name'};
          }
          return null;
        });

        final contact = await contactos
            .openExistingContact(const Contact(identifier: 'id'));
        expect(contact.displayName, 'Updated Name');
      });
    });
  });
}
