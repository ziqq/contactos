import 'package:contactos/contactos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group(
      'Unit_tests -',
      () => group('Contactos -', () {
        const channel = MethodChannel('github.com/ziqq/contactos');

        final log = <MethodCall>[];

        setUp(() {
          TestWidgetsFlutterBinding.ensureInitialized();
          TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            channel,
            (methodCall) async {
              log.add(methodCall);
              switch (methodCall.method) {
                case 'getContacts':
                case 'getContactsForPhone':
                case 'getContactsForEmail':
                  return [
                    {'givenName': 'givenName1'},
                    {
                      'givenName': 'givenName2',
                      'postalAddresses': [
                        {'label': 'label'}
                      ],
                      'emails': [
                        {'label': 'label'}
                      ],
                      'birthday': '1994-02-01'
                    },
                  ];
                case 'getAvatar':
                  return Uint8List.fromList([0, 1, 2, 3]);
                default:
                  return null;
              }
            },
          );
        });

        tearDown(() {
          log.clear();
          TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        test('should get contacts', () async {
          final contacts = await Contactos.instance.getContacts();
          expect(contacts.length, 2);
          expect(contacts, everyElement(isInstanceOf<Contact>()));
          expect(contacts[0].givenName, 'givenName1');
          expect(contacts[1].postalAddresses![0].label, 'label');
          expect(contacts[1].emails![0].label, 'label');
          expect(contacts[1].birthday, DateTime(1994, 2, 1));
        });

        test('should get avatar for contact identifiers', () async {
          const contact = Contact(givenName: 'givenName');

          final avatar = await Contactos.instance.getAvatar(contact);

          expect(log, <Matcher>[
            isMethodCall('getAvatar', arguments: <String, dynamic>{
              'contact': contact.toJson(),
              'identifier': contact.identifier,
              'photoHighResolution': true,
            })
          ]);

          expect(avatar, Uint8List.fromList([0, 1, 2, 3]));
        });

        group('getContactsForPhone', () {
          test('returns empty list when no phone number specified', () async {
            final contacts = await Contactos.instance.getContactsForPhone(null);
            expect(contacts.length, equals(0));
          });

          /// Tests whether phone number argument is not null and plugin call is
          /// fired.
          ///
          /// Whether contact is returned or not depends on the plaform
          /// implementation which cannot be tested in unit tests.
          test('returns contacts if phone number supplied', () async {
            final contacts =
                await Contactos.instance.getContactsForPhone('1234567890');
            expect(contacts.length, equals(2));
            expect(contacts[0].givenName, 'givenName1');
            expect(contacts[1].givenName, 'givenName2');
          });
        });

        group('getContactsForEmail', () {
          /// Just tests whether the plugin call is fired.
          test('returns contacts when email is supplied', () async {
            final contacts = await Contactos.instance.getContactsForEmail(
              'abc@example.net',
            );
            expect(contacts.length, equals(2));
            expect(contacts[0].givenName, 'givenName1');
            expect(contacts[1].givenName, 'givenName2');
          });
        });

        test('should get low-res avatar for contact identifiers', () async {
          const contact = Contact(givenName: 'givenName');

          await Contactos.instance.getAvatar(contact, photoHighRes: false);

          expect(log, <Matcher>[
            isMethodCall('getAvatar', arguments: <String, dynamic>{
              'contact': contact.toJson(),
              'identifier': contact.identifier,
              'photoHighResolution': false,
            })
          ]);
        });

        test('should add contact', () async {
          await Contactos.instance.addContact(const Contact(
            givenName: 'givenName',
            emails: [Contact$Field(label: 'label')],
            phones: [Contact$Field(label: 'label')],
            postalAddresses: [Contact$PostalAddress(label: 'label')],
          ));
          _expectMethodCall(log, 'addContact');
        });

        test('should delete contact', () async {
          await Contactos.instance.deleteContact(const Contact(
            givenName: 'givenName',
            emails: [Contact$Field(label: 'label')],
            phones: [Contact$Field(label: 'label')],
            postalAddresses: [Contact$PostalAddress(label: 'label')],
          ));
          _expectMethodCall(log, 'deleteContact');
        });

        test('should provide initials for contact', () {
          var contact1 = const Contact(
            givenName: 'givenName',
            familyName: 'familyName',
          );
          var contact2 = const Contact(givenName: 'givenName');
          var contact3 = const Contact(familyName: 'familyName');
          var contact4 = const Contact();

          expect(contact1.initials(), 'GF');
          expect(contact2.initials(), 'G');
          expect(contact3.initials(), 'F');
          expect(contact4.initials(), '');
        });

        test('should update contact', () async {
          await Contactos.instance.updateContact(const Contact(
            givenName: 'givenName',
            emails: [Contact$Field(label: 'label')],
            phones: [Contact$Field(label: 'label')],
            postalAddresses: [Contact$PostalAddress(label: 'label')],
          ));
          _expectMethodCall(log, 'updateContact');
        });

        test('should show contacts are equal', () {
          var contact1 = const Contact(
            givenName: 'givenName',
            familyName: 'familyName',
            emails: [
              Contact$Field(label: 'Home', value: 'home@example.com'),
              Contact$Field(label: 'Work', value: 'work@example.com'),
            ],
          );
          var contact2 = const Contact(
            givenName: 'givenName',
            familyName: 'familyName',
            emails: [
              Contact$Field(label: 'Work', value: 'work@example.com'),
              Contact$Field(label: 'Home', value: 'home@example.com'),
            ],
          );
          expect(contact1 == contact2, true);
          expect(contact1.hashCode, contact2.hashCode);
        });

        test('should show contacts are not equal', () {
          var contact1 = const Contact(
              givenName: 'givenName',
              familyName: 'familyName',
              emails: [
                Contact$Field(label: 'Home', value: 'home@example.com'),
                Contact$Field(label: 'Work', value: 'work@example.com'),
              ]);
          var contact2 = const Contact(
              givenName: 'givenName',
              familyName: 'familyName',
              emails: [
                Contact$Field(label: 'Office', value: 'office@example.com'),
                Contact$Field(label: 'Home', value: 'home@example.com'),
              ]);
          expect(contact1 == contact2, false);
          expect(contact1.hashCode, contact2.hashCode);
        });

        test('should produce a valid merged contact', () {
          var contact1 = const Contact(
              givenName: 'givenName',
              familyName: 'familyName',
              emails: [
                Contact$Field(label: 'Home', value: 'home@example.com'),
                Contact$Field(label: 'Work', value: 'work@example.com'),
              ],
              phones: [],
              postalAddresses: []);
          var contact2 = const Contact(familyName: 'familyName', phones: [
            Contact$Field(label: 'Mobile', value: '111-222-3344')
          ], emails: [
            Contact$Field(label: 'Mobile', value: 'mobile@example.com'),
          ], postalAddresses: [
            Contact$PostalAddress(
                label: 'Home',
                street: '1234 Middle-of Rd',
                city: 'Nowhere',
                postcode: '12345',
                region: null,
                country: null)
          ]);
          var mergedContact = const Contact(
              givenName: 'givenName',
              familyName: 'familyName',
              emails: [
                Contact$Field(label: 'Home', value: 'home@example.com'),
                Contact$Field(label: 'Mobile', value: 'mobile@example.com'),
                Contact$Field(label: 'Work', value: 'work@example.com'),
              ],
              phones: [
                Contact$Field(label: 'Mobile', value: '111-222-3344')
              ],
              postalAddresses: [
                Contact$PostalAddress(
                    label: 'Home',
                    street: '1234 Middle-of Rd',
                    city: 'Nowhere',
                    postcode: '12345',
                    region: null,
                    country: null)
              ]);

          expect(contact1 + contact2, mergedContact);
        });

        test('should provide a valid merged contact, with no extra info', () {
          var contact1 = const Contact(familyName: 'familyName');
          var contact2 = const Contact();
          expect(contact1 + contact2, contact1);
        });

        test('should provide a map of the contact', () {
          var contact =
              const Contact(givenName: 'givenName', familyName: 'familyName');
          expect(contact.toJson(), {
            'identifier': null,
            'displayName': null,
            'givenName': 'givenName',
            'middleName': null,
            'familyName': 'familyName',
            'prefix': null,
            'suffix': null,
            'company': null,
            'jobTitle': null,
            'androidAccountType': null,
            'androidAccountName': null,
            'emails': const <Contact$Field>[],
            'phones': const <Contact$Field>[],
            'postalAddresses': const <Contact$PostalAddress>[],
            'avatar': null,
            'birthday': null
          });
        });
      }),
    );

void _expectMethodCall(List<MethodCall> log, String methodName) {
  expect(log, <Matcher>[
    isMethodCall(
      methodName,
      arguments: <String, dynamic>{
        'identifier': null,
        'displayName': null,
        'givenName': 'givenName',
        'middleName': null,
        'familyName': null,
        'prefix': null,
        'suffix': null,
        'company': null,
        'jobTitle': null,
        'androidAccountType': null,
        'androidAccountName': null,
        'emails': [
          {'label': 'label', 'value': null}
        ],
        'phones': [
          {'label': 'label', 'value': null}
        ],
        'postalAddresses': [
          {
            'label': 'label',
            'street': null,
            'city': null,
            'postcode': null,
            'region': null,
            'country': null
          }
        ],
        'avatar': null,
        'birthday': null
      },
    ),
  ]);
}
