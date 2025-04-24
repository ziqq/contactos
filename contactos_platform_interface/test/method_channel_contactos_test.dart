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

    test('getContacts should return list of contacts', () async {
      final contacts = await contactos.getContacts();
      expect(contacts, isNotEmpty);
      expect(contacts.first.identifier, '1');
      expect(contacts.first.displayName, 'John Doe');
      expect(contacts.first.phones?.first.value, '+123456789');
      expect(contacts.first.emails?.first.value, 'johndoe@example.com');
      expect(log.single.method, 'getContacts');
    });

    test('getContactsForEmail should return list of contacts', () async {
      final contacts =
          await contactos.getContactsForEmail('janedoe@example.com');
      expect(contacts, isNotEmpty);
      expect(contacts.first.identifier, '2');
      expect(contacts.first.displayName, 'Jane Doe');
      expect(contacts.first.emails?.first.value, 'janedoe@example.com');
      expect(log.single.method, 'getContactsForEmail');
    });

    test('getContactsForPhone should return list of contacts', () async {
      final contacts = await contactos.getContactsForPhone('+987654321');
      expect(contacts, isNotEmpty);
      expect(contacts.first.identifier, '3');
      expect(contacts.first.displayName, 'Alice Smith');
      expect(contacts.first.phones?.first.value, '+987654321');
      expect(log.single.method, 'getContactsForPhone');
    });

    test('getAvatar should return Uint8List', () async {
      final avatar = await contactos.getAvatar(const Contact(identifier: '1'));
      expect(avatar, isNotNull);
      expect(avatar, isA<Uint8List>());
      expect(log.single.method, 'getAvatar');
    });

    test('addContact should call method channel', () async {
      await contactos.addContact(
          const Contact(identifier: '4', displayName: 'New Contact'));
      expect(log.single.method, 'addContact');
    });

    test('deleteContact should call method channel', () async {
      await contactos.deleteContact(const Contact(identifier: '5'));
      expect(log.single.method, 'deleteContact');
    });

    test('updateContact should call method channel', () async {
      await contactos.updateContact(
          const Contact(identifier: '6', displayName: 'Updated Contact'));
      expect(log.single.method, 'updateContact');
    });
  });
}
