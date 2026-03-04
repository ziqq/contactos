// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AndroidAccountType -', () {
    group('fromString -', () {
      test('returns correct enum', () {
        expect(
          AndroidAccountType.fromString('com.google'),
          AndroidAccountType.google,
        );
        expect(
          AndroidAccountType.fromString('com.whatsapp'),
          AndroidAccountType.whatsapp,
        );
        expect(
          AndroidAccountType.fromString('com.facebook'),
          AndroidAccountType.facebook,
        );
        expect(
          AndroidAccountType.fromString('other'),
          AndroidAccountType.other,
        );
        expect(AndroidAccountType.fromString(null), null);
      });
    });
  });

  group('Contact -', () {
    group('fromJson -', () {
      test('parses correctly', () {
        final json = {
          'identifier': 'id',
          'displayName': 'Display Name',
          'givenName': 'Given',
          'middleName': 'Middle',
          'prefix': 'Mr.',
          'suffix': 'Jr.',
          'familyName': 'Family',
          'company': 'Company',
          'jobTitle': 'Job',
          'androidAccountType': 'com.google',
          'androidAccountName': 'account',
          'emails': [
            {'label': 'work', 'value': 'email@example.com'}
          ],
          'phones': [
            {'label': 'mobile', 'value': '1234567890'}
          ],
          'postalAddresses': [
            {
              'label': 'home',
              'street': 'Street',
              'city': 'City',
              'postcode': '12345',
              'region': 'Region',
              'country': 'Country',
            }
          ],
          'avatar': [1, 2, 3],
          'birthday': '2000-01-01',
        };

        final contact = Contact.fromJson(json);

        expect(contact.identifier, 'id');
        expect(contact.displayName, 'Display Name');
        expect(contact.givenName, 'Given');
        expect(contact.middleName, 'Middle');
        expect(contact.prefix, 'Mr.');
        expect(contact.suffix, 'Jr.');
        expect(contact.familyName, 'Family');
        expect(contact.company, 'Company');
        expect(contact.jobTitle, 'Job');
        expect(contact.androidAccountType, AndroidAccountType.google);
        expect(contact.androidAccountName, 'account');
        expect(contact.emails?.first.label, 'work');
        expect(contact.emails?.first.value, 'email@example.com');
        expect(contact.phones?.first.label, 'mobile');
        expect(contact.phones?.first.value, '1234567890');
        expect(contact.postalAddresses?.first.label, 'home');
        expect(contact.postalAddresses?.first.street, 'Street');
        expect(contact.avatar, Uint8List.fromList([1, 2, 3]));
        expect(contact.birthday, DateTime(2000, 1, 1));
      });

      test('handles invalid birthday', () {
        final json = {
          'birthday': 'invalid',
        };
        final contact = Contact.fromJson(json);
        expect(contact.birthday, null);
      });
    });

    group('toJson -', () {
      test('serializes correctly', () {
        final contact = Contact(
          identifier: 'id',
          displayName: 'Display Name',
          givenName: 'Given',
          middleName: 'Middle',
          prefix: 'Mr.',
          suffix: 'Jr.',
          familyName: 'Family',
          company: 'Company',
          jobTitle: 'Job',
          androidAccountType: AndroidAccountType.google,
          androidAccountTypeRaw: 'com.google',
          androidAccountName: 'account',
          emails: const [
            Contact$Field(label: 'work', value: 'email@example.com')
          ],
          phones: const [Contact$Field(label: 'mobile', value: '1234567890')],
          postalAddresses: const [
            Contact$PostalAddress(
              label: 'home',
              street: 'Street',
              city: 'City',
              postcode: '12345',
              region: 'Region',
              country: 'Country',
            )
          ],
          avatar: Uint8List.fromList([1, 2, 3]),
          birthday: DateTime(2000, 1, 1),
        );

        final json = contact.toJson();

        expect(json['identifier'], 'id');
        expect(json['displayName'], 'Display Name');
        expect(json['birthday'], '2000-01-01');
        expect(json['emails'], isA<List<dynamic>>());
        expect(json['phones'], isA<List<dynamic>>());
        expect(json['postalAddresses'], isA<List<dynamic>>());
      });
    });

    group('copyWith -', () {
      test('works correctly', () {
        const contact = Contact(identifier: 'id', givenName: 'Given');
        final copy = contact.copyWith(givenName: 'New Given');
        expect(copy.identifier, 'id');
        expect(copy.givenName, 'New Given');
      });

      test('preserves values when arguments are null', () {
        const contact = Contact(identifier: 'id', givenName: 'Given');
        final copy = contact.copyWith(identifier: 'newId');
        expect(copy.identifier, 'newId');
        expect(copy.givenName, 'Given');
      });
    });

    group('initials -', () {
      test('returns correct initials', () {
        const contact1 = Contact(givenName: 'John', familyName: 'Doe');
        expect(contact1.initials(), 'JD');

        const contact2 = Contact(givenName: 'John');
        expect(contact2.initials(), 'J');

        const contact3 = Contact(familyName: 'Doe');
        expect(contact3.initials(), 'D');

        const contact4 = Contact();
        expect(contact4.initials(), '');
      });
    });

    group('operator +', () {
      test('merges contacts', () {
        const contact1 = Contact(givenName: 'John', emails: []);
        const contact2 = Contact(
          familyName: 'Doe',
          emails: [Contact$Field(label: 'work', value: 'email')],
        );
        final merged = contact1 + contact2;
        expect(merged.givenName, 'John');
        expect(merged.familyName, 'Doe');
        expect(merged.emails?.length, 1);
      });

      test('merges contacts with existing lists', () {
        const contact1 = Contact(
          emails: [Contact$Field(label: 'home', value: 'home@email.com')],
        );
        const contact2 = Contact(
          emails: [Contact$Field(label: 'work', value: 'work@email.com')],
        );
        final merged = contact1 + contact2;
        expect(merged.emails?.length, 2);
      });

      test('merges contacts with null lists on left side', () {
        const contact1 = Contact(givenName: 'A');
        const contact2 = Contact(
          emails: [Contact$Field(label: 'a', value: 'a')],
          phones: [Contact$Field(label: 'b', value: 'b')],
          postalAddresses: [Contact$PostalAddress(street: 's')],
        );
        final merged = contact1 + contact2;
        expect(merged.emails?.length, 1);
        expect(merged.phones?.length, 1);
        expect(merged.postalAddresses?.length, 1);
      });

      test('merges contacts with non-null lists', () {
        const contact1 = Contact(
          phones: [Contact$Field(label: 'a', value: 'a')],
          postalAddresses: [Contact$PostalAddress(street: 's1')],
        );
        const contact2 = Contact(
          phones: [Contact$Field(label: 'b', value: 'b')],
          postalAddresses: [Contact$PostalAddress(street: 's2')],
        );
        final merged = contact1 + contact2;
        expect(merged.phones?.length, 2);
        expect(merged.postalAddresses?.length, 2);
      });
    });

    group('equality and hashCode -', () {
      test('works correctly', () {
        const contact1 = Contact(identifier: 'id');
        const contact2 = Contact(identifier: 'id');
        const contact3 = Contact(identifier: 'other');

        expect(contact1, contact2);
        expect(contact1.hashCode, contact2.hashCode);
        expect(contact1, isNot(contact3));
      });
    });
  });

  group(r'Contact$PostalAddress -', () {
    group('toString -', () {
      test('returns formatted address', () {
        const address = Contact$PostalAddress(
          street: 'Street',
          city: 'City',
          country: 'Country',
        );
        expect(address.toString(), 'Street, City, Country');
      });

      test('returns formatted address with all fields', () {
        const address = Contact$PostalAddress(
          street: 'Street',
          city: 'City',
          region: 'Region',
          postcode: '12345',
          country: 'Country',
        );
        expect(address.toString(), 'Street, City, Region 12345, Country');
      });

      test('returns formatted address with missing fields', () {
        const address1 = Contact$PostalAddress(city: 'City');
        expect(address1.toString(), 'City');

        const address2 = Contact$PostalAddress(region: 'Region');
        expect(address2.toString(), 'Region');

        const address3 = Contact$PostalAddress(postcode: '12345');
        expect(address3.toString(), '12345');

        const address4 = Contact$PostalAddress(country: 'Country');
        expect(address4.toString(), 'Country');
      });

      test('returns formatted address with combinations', () {
        expect(
          const Contact$PostalAddress(street: 'S', region: 'R').toString(),
          'S, R',
        );
        expect(
          const Contact$PostalAddress(street: 'S', postcode: 'P').toString(),
          'S P',
        );
        expect(
          const Contact$PostalAddress(street: 'S', country: 'C').toString(),
          'S, C',
        );
      });
    });

    group('equality and hashCode -', () {
      test('works correctly', () {
        const address1 = Contact$PostalAddress(street: 'Street');
        const address2 = Contact$PostalAddress(street: 'Street');
        const address3 = Contact$PostalAddress(street: 'Other');

        expect(address1, address2);
        expect(address1.hashCode, address2.hashCode);
        expect(address1, isNot(address3));
      });
    });

    group('copyWith -', () {
      test('works correctly', () {
        const address = Contact$PostalAddress(street: 'Street');
        final copy = address.copyWith(street: 'New Street');
        expect(copy.street, 'New Street');
      });

      test('preserves values when arguments are null', () {
        const address = Contact$PostalAddress(street: 'Street', city: 'City');
        final copy = address.copyWith(city: 'New City');
        expect(copy.street, 'Street');
        expect(copy.city, 'New City');
      });
    });
  });

  group(r'Contact$Field -', () {
    group('equality and hashCode -', () {
      test('works correctly', () {
        const field1 = Contact$Field(label: 'label', value: 'value');
        const field2 = Contact$Field(label: 'label', value: 'value');
        const field3 = Contact$Field(label: 'other', value: 'value');

        expect(field1, field2);
        expect(field1.hashCode, field2.hashCode);
        expect(field1, isNot(field3));
        expect(field1, isNot('string'));
      });
    });
  });

  group('FormOperationException -', () {
    group('toString -', () {
      test('returns correct message', () {
        const exception = FormOperationException.canceled();
        expect(exception.toString(),
            'FormOperationException: FormOperationErrorCode.canceled');
      });
    });

    group('factories -', () {
      test('create correct exceptions', () {
        expect(
          const FormOperationException.canceled(),
          isA<FormOperationException$Canceled>(),
        );
        expect(
          const FormOperationException.couldNotBeOpen(),
          isA<FormOperationException$CouldNotBeOpen>(),
        );
        expect(
          const FormOperationException.unknown(),
          isA<FormOperationException$Unknown>(),
        );
      });

      test('subclasses can be instantiated directly', () {
        expect(
          const FormOperationException$Canceled(),
          isA<FormOperationException>(),
        );
        expect(
          const FormOperationException$CouldNotBeOpen(),
          isA<FormOperationException>(),
        );
        expect(
          const FormOperationException$Unknown(),
          isA<FormOperationException>(),
        );
      });
    });
  });
}
