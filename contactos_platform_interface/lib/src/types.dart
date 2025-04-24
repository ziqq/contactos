import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Json type.
@internal // ignore: invalid_internal_annotation
typedef JSON = Map<Object?, Object?>;

/// Android account types
enum AndroidAccountType {
  /// The contact is associated with a Facebook account.
  facebook,

  /// The contact is associated with a Google account.
  google,

  /// The contact is associated with a WhatsApp account.
  whatsapp,

  /// The contact is associated with an account type other than the ones listed.
  other;

  /// Converts a string to an [AndroidAccountType].
  static AndroidAccountType? fromString(String? androidAccountType) {
    if (androidAccountType == null) return null;
    if (androidAccountType.startsWith('com.google')) {
      return AndroidAccountType.google;
    } else if (androidAccountType.startsWith('com.whatsapp')) {
      return AndroidAccountType.whatsapp;
    } else if (androidAccountType.startsWith('com.facebook')) {
      return AndroidAccountType.facebook;
    }

    /// Other account types are not supported on Android
    /// such as Samsung, htc etc...
    return AndroidAccountType.other;
  }
}

/// {@template contact_model}
/// A model representing a contact.
/// {@endtemplate}
@immutable
class Contact {
  /// {@macro contact_model}
  const Contact({
    this.identifier,
    this.displayName,
    this.givenName,
    this.middleName,
    this.prefix,
    this.suffix,
    this.familyName,
    this.company,
    this.jobTitle,
    this.emails,
    this.phones,
    this.postalAddresses,
    this.avatar,
    this.birthday,
    this.androidAccountType,
    this.androidAccountTypeRaw,
    this.androidAccountName,
  });

  /// Creates a [Contact] from a `Map<String, Object?>`.
  factory Contact.fromJson(JSON json) {
    final rawBirthday = json['birthday'];

    DateTime? birthday;
    if (rawBirthday is String &&
        rawBirthday.isNotEmpty &&
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawBirthday)) {
      birthday = DateTime.tryParse(rawBirthday);
    } else {
      birthday = null;
    }

    return Contact(
      identifier: json['identifier'].toString(),
      displayName: json['displayName'].toString(),
      givenName: json['givenName'].toString(),
      middleName: json['middleName'].toString(),
      prefix: json['prefix'].toString(),
      suffix: json['suffix'].toString(),
      familyName: json['familyName'].toString(),
      company: json['company'].toString(),
      jobTitle: json['jobTitle'].toString(),
      androidAccountType: AndroidAccountType.fromString(
        json['androidAccountType'].toString(),
      ),
      androidAccountTypeRaw: json['androidAccountType'].toString(),
      androidAccountName: json['androidAccountName'].toString(),
      emails: (json['emails'] as List?)
          ?.map((e) => Contact$Field.fromJson(e as JSON))
          .toList(),
      phones: (json['phones'] as List?)
          ?.map((e) => Contact$Field.fromJson(e as JSON))
          .toList(),
      postalAddresses: (json['postalAddresses'] as List?)
          ?.map((e) => Contact$PostalAddress.fromJson(e as JSON))
          .toList(),
      avatar: json['avatar'] is List<int>
          ? Uint8List.fromList(json['avatar'] as List<int>)
          : null,
      birthday: birthday,
    );
  }

  /// The unique identifier for the contact.
  final String? identifier;

  /// The display name of the contact.
  final String? displayName;

  /// The given name (first name) of the contact.
  final String? givenName;

  /// The middle name of the contact.
  final String? middleName;

  /// The prefix of the contact's name (e.g., Mr., Mrs., Dr.).
  final String? prefix;

  /// The suffix of the contact's name (e.g., Jr., Sr., III).
  final String? suffix;

  /// The family name (last name) of the contact.
  final String? familyName;

  /// The company the contact is associated with.
  final String? company;

  /// The job title of the contact.
  final String? jobTitle;

  /// The raw account type on Android.
  final String? androidAccountTypeRaw;

  /// The account name on Android.
  final String? androidAccountName;

  /// The account type on Android.
  final AndroidAccountType? androidAccountType;

  /// The list of email addresses associated with the contact.
  final List<Contact$Field>? emails;

  /// The list of phone numbers associated with the contact.
  final List<Contact$Field>? phones;

  /// The list of postal addresses associated with the contact.
  final List<Contact$PostalAddress>? postalAddresses;

  /// The avatar image of the contact as a byte array.
  final Uint8List? avatar;

  /// The birthday of the contact.
  final DateTime? birthday;

  /// Creates a copy of this contact
  /// with the given fields replaced with the new values.
  @useResult
  Contact copyWith({
    String? identifier,
    String? displayName,
    String? givenName,
    String? middleName,
    String? prefix,
    String? suffix,
    String? familyName,
    String? company,
    String? jobTitle,
    String? androidAccountTypeRaw,
    String? androidAccountName,
    AndroidAccountType? androidAccountType,
    List<Contact$Field>? emails,
    List<Contact$Field>? phones,
    List<Contact$PostalAddress>? postalAddresses,
    Uint8List? avatar,
    DateTime? birthday,
  }) =>
      Contact(
        identifier: identifier ?? this.identifier,
        displayName: displayName ?? this.displayName,
        givenName: givenName ?? this.givenName,
        middleName: middleName ?? this.middleName,
        prefix: prefix ?? this.prefix,
        suffix: suffix ?? this.suffix,
        familyName: familyName ?? this.familyName,
        company: company ?? this.company,
        jobTitle: jobTitle ?? this.jobTitle,
        androidAccountTypeRaw:
            androidAccountTypeRaw ?? this.androidAccountTypeRaw,
        androidAccountName: androidAccountName ?? this.androidAccountName,
        androidAccountType: androidAccountType ?? this.androidAccountType,
        emails: emails ?? this.emails,
        phones: phones ?? this.phones,
        postalAddresses: postalAddresses ?? this.postalAddresses,
        avatar: avatar ?? this.avatar,
        birthday: birthday ?? this.birthday,
      );

  static JSON _toJson(Contact contact) {
    final emails = contact.emails;
    var $emails = <JSON>[];
    if (emails != null) {
      for (final email in emails) {
        $emails.add(Contact$Field._toJson(email));
      }
    }

    final phones = contact.phones;
    var $phones = <JSON>[];
    if (phones != null) {
      for (final phone in phones) {
        $phones.add(Contact$Field._toJson(phone));
      }
    }

    final postalAddresses = contact.postalAddresses;
    var $postalAddresses = <JSON>[];
    if (postalAddresses != null) {
      for (final address in postalAddresses) {
        $postalAddresses.add(Contact$PostalAddress._toJson(address));
      }
    }

    final contactBirthday = contact.birthday;
    final birthday = contactBirthday == null
        ? null
        : '${contactBirthday.year.toString()}-'
            '${contactBirthday.month.toString().padLeft(2, '0')}-'
            '${contactBirthday.day.toString().padLeft(2, '0')}';

    return {
      'identifier': contact.identifier,
      'displayName': contact.displayName,
      'givenName': contact.givenName,
      'middleName': contact.middleName,
      'familyName': contact.familyName,
      'avatar': contact.avatar,
      'prefix': contact.prefix,
      'suffix': contact.suffix,
      'company': contact.company,
      'jobTitle': contact.jobTitle,
      'androidAccountType': contact.androidAccountTypeRaw,
      'androidAccountName': contact.androidAccountName,
      'birthday': birthday,
      'emails': $emails,
      'phones': $phones,
      'postalAddresses': $postalAddresses,
    };
  }

  /// Converts this contact to a `Map<String, Object?>`.
  JSON toJson() => Contact._toJson(this);

  /// The contact's initials.
  String initials() => ((givenName?.isNotEmpty == true ? givenName![0] : '') +
          (familyName?.isNotEmpty == true ? familyName![0] : ''))
      .toUpperCase();

  /// The [+] operator fills in this contact's empty fields
  /// with the fields from [other]
  Contact operator +(Contact other) => Contact(
        givenName: givenName ?? other.givenName,
        middleName: middleName ?? other.middleName,
        prefix: prefix ?? other.prefix,
        suffix: suffix ?? other.suffix,
        familyName: familyName ?? other.familyName,
        company: company ?? other.company,
        jobTitle: jobTitle ?? other.jobTitle,
        androidAccountType: androidAccountType ?? other.androidAccountType,
        androidAccountName: androidAccountName ?? other.androidAccountName,
        emails: emails == null
            ? other.emails
            : emails!.toSet().union(other.emails?.toSet() ?? {}).toList(),
        phones: phones == null
            ? other.phones
            : phones!.toSet().union(other.phones?.toSet() ?? {}).toList(),
        postalAddresses: postalAddresses == null
            ? other.postalAddresses
            : postalAddresses!
                .toSet()
                .union(other.postalAddresses?.toSet() ?? {})
                .toList(),
        avatar: avatar ?? other.avatar,
        birthday: birthday ?? other.birthday,
      );

  /// Returns true if all items in this contact are identical.
  @override
  bool operator ==(Object other) =>
      other is Contact &&
      avatar == other.avatar &&
      company == other.company &&
      displayName == other.displayName &&
      givenName == other.givenName &&
      familyName == other.familyName &&
      identifier == other.identifier &&
      jobTitle == other.jobTitle &&
      androidAccountType == other.androidAccountType &&
      androidAccountName == other.androidAccountName &&
      middleName == other.middleName &&
      prefix == other.prefix &&
      suffix == other.suffix &&
      birthday == other.birthday &&
      const DeepCollectionEquality.unordered().equals(phones, other.phones) &&
      const DeepCollectionEquality.unordered().equals(emails, other.emails) &&
      const DeepCollectionEquality.unordered()
          .equals(postalAddresses, other.postalAddresses);

  @override
  int get hashCode => Object.hashAll([
        company,
        displayName,
        familyName,
        givenName,
        identifier,
        jobTitle,
        androidAccountType,
        androidAccountName,
        middleName,
        prefix,
        suffix,
        birthday,
      ].where((s) => s != null));
}

/// {@template postal_address}
/// A model representing a postal address.
/// {@endtemplate}
@immutable
class Contact$PostalAddress {
  /// {@macro postal_address}
  const Contact$PostalAddress({
    this.label,
    this.street,
    this.city,
    this.postcode,
    this.region,
    this.country,
  });

  /// Creates a [Contact$PostalAddress] from a `Map<String, Object?>`.
  /// {@macro postal_address}
  factory Contact$PostalAddress.fromJson(JSON json) => Contact$PostalAddress(
        label: json['label'].toString(),
        street: json['street'].toString(),
        city: json['city'].toString(),
        postcode: json['postcode'].toString(),
        region: json['region'].toString(),
        country: json['country'].toString(),
      );

  /// The label of the postal address (e.g., "home", "work")
  final String? label;

  /// The street name and number of the postal address
  final String? street;

  /// The city of the postal address
  final String? city;

  /// The postal code of the postal address
  final String? postcode;

  /// The region or state of the postal address
  final String? region;

  /// The country of the postal address
  final String? country;

  /// Creates a copy of this postal address
  @useResult
  Contact$PostalAddress copyWith({
    String? label,
    String? street,
    String? city,
    String? postcode,
    String? region,
    String? country,
  }) =>
      Contact$PostalAddress(
        label: label ?? this.label,
        street: street ?? this.street,
        city: city ?? this.city,
        postcode: postcode ?? this.postcode,
        region: region ?? this.region,
        country: country ?? this.country,
      );

  @override
  bool operator ==(Object other) =>
      other is Contact$PostalAddress &&
      city == other.city &&
      country == other.country &&
      label == other.label &&
      postcode == other.postcode &&
      region == other.region &&
      street == other.street;

  @override
  int get hashCode => Object.hashAll([
        label,
        street,
        city,
        country,
        region,
        postcode,
      ].where((s) => s != null));

  static JSON _toJson(Contact$PostalAddress address) => {
        'label': address.label,
        'street': address.street,
        'city': address.city,
        'postcode': address.postcode,
        'region': address.region,
        'country': address.country
      };

  @override
  String toString() {
    var finalString = StringBuffer();
    if (street != null) finalString.write(street);
    if (city != null) {
      if (finalString.isNotEmpty) {
        finalString.write(', $city');
      } else {
        finalString.write(city);
      }
    }
    if (region != null) {
      if (finalString.isNotEmpty) {
        finalString.write(', $region');
      } else {
        finalString.write(region);
      }
    }
    if (postcode != null) {
      if (finalString.isNotEmpty) {
        finalString.write(' $postcode');
      } else {
        finalString.write(postcode);
      }
    }
    if (country != null) {
      if (finalString.isNotEmpty) {
        finalString.write(', $country');
      } else {
        finalString.write(country);
      }
    }
    return finalString.toString();
  }
}

/// {@template item}
/// Contact$Field class used for contact fields which only have a [label] and
/// a [value], such as emails and phone numbers
/// {@endtemplate}
@immutable
class Contact$Field {
  /// {@macro item}
  const Contact$Field({this.label, this.value});

  /// Creates an [Contact$Field] from a `Map<String, Object?>`.
  /// {@macro item}
  factory Contact$Field.fromJson(JSON json) => Contact$Field(
        label: json['label'].toString(),
        value: json['value'].toString(),
      );

  /// The label of the item (e.g., "home", "work")
  final String? label;

  /// The value of the item (e.g., an email address, phone number)
  final String? value;

  @override
  bool operator ==(Object other) =>
      other is Contact$Field && label == other.label && value == other.value;

  @override
  int get hashCode => Object.hash(label, value);

  static JSON _toJson(Contact$Field item) =>
      {'label': item.label, 'value': item.value};
}

/// {@template form_operation_error_code}
/// Error codes for form operations
/// {@endtemplate}
enum FormOperationErrorCode {
  /// The form operation was canceled
  canceled,

  /// The form operation could not be open
  couldNotBeOpen,

  /// An unknown error occurred
  unknown,
}

/// {@template form_operation_exception}
/// Exception thrown when a form operation fails
/// {@endtemplate}
@immutable
class FormOperationException implements Exception {
  /// {@macro form_operation_exception}
  const FormOperationException({this.errorCode});

  /// Creates a [FormOperationException]
  /// with a [FormOperationErrorCode.canceled]
  /// {@macro form_operation_exception}
  const factory FormOperationException.canceled() =
      FormOperationException$Canceled;

  /// Creates a [FormOperationException]
  /// with a [FormOperationErrorCode.couldNotBeOpen]
  /// {@macro form_operation_exception}
  const factory FormOperationException.couldNotBeOpen() =
      FormOperationException$Canceled;

  /// Creates a [FormOperationException]
  /// with a [FormOperationErrorCode.unknown]
  /// {@macro form_operation_exception}
  const factory FormOperationException.unknown() =
      FormOperationException$Canceled;

  /// The error code associated with this exception
  final FormOperationErrorCode? errorCode;

  @override
  String toString() => 'FormOperationException: $errorCode';
}

/// Exception thrown when a form operation is canceled
/// {@macro form_operation_exception}
@immutable
class FormOperationException$Canceled extends FormOperationException {
  /// {@macro form_operation_exception}
  const FormOperationException$Canceled()
      : super(errorCode: FormOperationErrorCode.canceled);
}

/// Exception thrown when a form operation could not be open
/// {@macro form_operation_exception}
@immutable
class FormOperationException$CouldNotBeOpen extends FormOperationException {
  /// {@macro form_operation_exception}
  const FormOperationException$CouldNotBeOpen()
      : super(errorCode: FormOperationErrorCode.couldNotBeOpen);
}

/// Exception thrown when a form operation fails with an unknown error
/// {@macro form_operation_exception}
@immutable
class FormOperationException$Unknown extends FormOperationException {
  /// {@macro form_operation_exception}
  const FormOperationException$Unknown()
      : super(errorCode: FormOperationErrorCode.unknown);
}
