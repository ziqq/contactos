import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Json type.
typedef JSON = Map<Object?, Object?>;

/// Android account types
enum AndroidAccountType {
  facebook,
  google,
  whatsapp,
  other;

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

/// {@template contact}
/// A class representing a contact.
/// {@endtemplate}
@immutable
class Contact {
  /// {@macro contact}
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

  factory Contact.fromJson(JSON json) {
    final avatarRaw = json['avatar'];
    final emailsRaw = json['emails'];
    final phonesRaw = json['phones'];
    final birthdayRaw = json['birthday'];
    final postalAddressRaw = json['postalAddresses'];

    DateTime? birthday;
    if (birthdayRaw is String &&
        birthdayRaw.isNotEmpty &&
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthdayRaw)) {
      birthday = DateTime.tryParse(birthdayRaw);
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
      emails: (emailsRaw != null && emailsRaw is List)
          ? emailsRaw
              .whereType<JSON>()
              .map((e) => Item.fromMap(e))
              .toList(growable: false)
          : const [],
      phones: (phonesRaw != null && phonesRaw is List)
          ? phonesRaw
              .whereType<JSON>()
              .map((e) => Item.fromMap(e))
              .toList(growable: false)
          : const [],
      postalAddresses: (postalAddressRaw != null && postalAddressRaw is List)
          ? postalAddressRaw
              .whereType<JSON>()
              .map((e) => PostalAddress.fromMap(e))
              .toList(growable: false)
          : const [],
      avatar: (avatarRaw != null && avatarRaw is List<int>)
          ? Uint8List.fromList(avatarRaw)
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
  final List<Item>? emails;

  /// The list of phone numbers associated with the contact.
  final List<Item>? phones;

  /// The list of postal addresses associated with the contact.
  final List<PostalAddress>? postalAddresses;

  /// The avatar image of the contact as a byte array.
  final Uint8List? avatar;

  /// The birthday of the contact.
  final DateTime? birthday;

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
    List<Item>? emails,
    List<Item>? phones,
    List<PostalAddress>? postalAddresses,
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

  static JSON _toMap(Contact contact) {
    var emails = <JSON>[];

    for (final Item email in contact.emails ?? []) {
      emails.add(Item._toMap(email));
    }
    var phones = <JSON>[];
    for (final Item phone in contact.phones ?? []) {
      phones.add(Item._toMap(phone));
    }
    var postalAddresses = <JSON>[];
    for (final PostalAddress address in contact.postalAddresses ?? []) {
      postalAddresses.add(PostalAddress._toMap(address));
    }

    final birthday = contact.birthday == null
        ? null
        : "${contact.birthday!.year.toString()}-${contact.birthday!.month.toString().padLeft(2, '0')}-${contact.birthday!.day.toString().padLeft(2, '0')}";

    return {
      'identifier': contact.identifier,
      'displayName': contact.displayName,
      'givenName': contact.givenName,
      'middleName': contact.middleName,
      'familyName': contact.familyName,
      'prefix': contact.prefix,
      'suffix': contact.suffix,
      'company': contact.company,
      'jobTitle': contact.jobTitle,
      'androidAccountType': contact.androidAccountTypeRaw,
      'androidAccountName': contact.androidAccountName,
      'emails': emails,
      'phones': phones,
      'postalAddresses': postalAddresses,
      'avatar': contact.avatar,
      'birthday': birthday
    };
  }

  JSON toMap() => Contact._toMap(this);

  /// The contact's initials.
  String initials() => ((givenName?.isNotEmpty == true ? givenName![0] : '') +
          (familyName?.isNotEmpty == true ? familyName![0] : ''))
      .toUpperCase();

  /// The [+] operator fills in this contact's empty fields with the fields from [other]
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
/// A class representing a postal address.
/// {@endtemplate}
@immutable
class PostalAddress {
  /// {@macro postal_address}
  const PostalAddress({
    this.label,
    this.street,
    this.city,
    this.postcode,
    this.region,
    this.country,
  });

  factory PostalAddress.fromMap(JSON json) => PostalAddress(
        label: json['label'].toString(),
        street: json['street'].toString(),
        city: json['city'].toString(),
        postcode: json['postcode'].toString(),
        region: json['region'].toString(),
        country: json['country'].toString(),
      );

  // The label of the postal address (e.g., "home", "work")
  final String? label;

  // The street name and number of the postal address
  final String? street;

  // The city of the postal address
  final String? city;

  // The postal code of the postal address
  final String? postcode;

  // The region or state of the postal address
  final String? region;

  // The country of the postal address
  final String? country;

  @useResult
  PostalAddress copyWith({
    String? label,
    String? street,
    String? city,
    String? postcode,
    String? region,
    String? country,
  }) =>
      PostalAddress(
        label: label ?? this.label,
        street: street ?? this.street,
        city: city ?? this.city,
        postcode: postcode ?? this.postcode,
        region: region ?? this.region,
        country: country ?? this.country,
      );

  @override
  bool operator ==(Object other) =>
      other is PostalAddress &&
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

  static JSON _toMap(PostalAddress address) => {
        'label': address.label,
        'street': address.street,
        'city': address.city,
        'postcode': address.postcode,
        'region': address.region,
        'country': address.country
      };

  @override
  String toString() {
    String finalString = '';
    if (street != null) {
      finalString += street!;
    }
    if (city != null) {
      if (finalString.isNotEmpty) {
        finalString += ', $city';
      } else {
        finalString += city!;
      }
    }
    if (region != null) {
      if (finalString.isNotEmpty) {
        finalString += ', $region';
      } else {
        finalString += region!;
      }
    }
    if (postcode != null) {
      if (finalString.isNotEmpty) {
        finalString += ' $postcode';
      } else {
        finalString += postcode!;
      }
    }
    if (country != null) {
      if (finalString.isNotEmpty) {
        finalString += ', ${country!}';
      } else {
        finalString += country!;
      }
    }
    return finalString;
  }
}

/// {@template item}
/// Item class used for contact fields which only have a [label] and
/// a [value], such as emails and phone numbers
/// {@endtemplate}
@immutable
class Item {
  /// {@macro item}
  const Item({this.label, this.value});

  factory Item.fromMap(JSON json) => Item(
        label: json['label'].toString(),
        value: json['value'].toString(),
      );

  final String? label, value;

  @override
  bool operator ==(Object other) =>
      other is Item && label == other.label && value == other.value;

  @override
  int get hashCode => Object.hash(label, value);

  static JSON _toMap(Item item) => {'label': item.label, 'value': item.value};
}

/// {@template form_operation_error_code}
/// Error codes for form operations
/// {@endtemplate}
enum FormOperationErrorCode {
  FORM_OPERATION_CANCELED,
  FORM_COULD_NOT_BE_OPEN,
  FORM_OPERATION_UNKNOWN_ERROR
}

/// {@template form_operation_exception}
/// Exception thrown when a form operation fails
/// {@endtemplate}
@immutable
class FormOperationException implements Exception {
  /// {@macro form_operation_exception}
  const FormOperationException({this.errorCode});

  const factory FormOperationException.canceled() =
      FormOperationException$Canceled;

  const factory FormOperationException.couldNotBeOpen() =
      FormOperationException$Canceled;

  const factory FormOperationException.unknown() =
      FormOperationException$Canceled;

  /// The error code associated with this exception
  final FormOperationErrorCode? errorCode;

  @override
  String toString() => 'FormOperationException: $errorCode';
}

@immutable
class FormOperationException$Canceled extends FormOperationException {
  const FormOperationException$Canceled()
      : super(errorCode: FormOperationErrorCode.FORM_OPERATION_CANCELED);
}

@immutable
class FormOperationException$CouldNotBeOpen extends FormOperationException {
  const FormOperationException$CouldNotBeOpen()
      : super(errorCode: FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN);
}

@immutable
class FormOperationException$Unknown extends FormOperationException {
  const FormOperationException$Unknown()
      : super(errorCode: FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR);
}
