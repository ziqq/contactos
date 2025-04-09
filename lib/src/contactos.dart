// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:contactos/src/types.dart';
import 'package:flutter/services.dart';

/// {@template contactos}
/// A service that provides access to the device contacts.
/// {@endtemplate}
final class Contactos {
  /// {@macro contactos}
  const Contactos._();

  // static final Contactos instance = Contactos._internal();
  // factory Contactos() => instance;

  /// {@macro contactos}
  // Contactos._internal();

  /// The [MethodChannel] used to interact with the platform side of the plugin.
  static const MethodChannel _channel =
      MethodChannel('github.com/ziqq/contactos');

  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  static Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final contacts = await _channel.invokeMethod(
      'getContacts',
      <String, dynamic>{
        'query': query,
        'withThumbnails': withThumbnails,
        'photoHighResolution': photoHighResolution,
        'orderByGivenName': orderByGivenName,
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    if (contacts is! Iterable<dynamic>) return const <Contact>[];
    return contacts
        .whereType<JSON>()
        .map(Contact.fromJson)
        .toList(growable: false);
  }

  /// Fetches all contacts, or when specified, the contacts with the phone
  /// matching [phone]
  static Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    if (phone == null || phone.isEmpty) return const <Contact>[];
    final contacts = await _channel.invokeMethod(
      'getContactsForPhone',
      <String, dynamic>{
        'phone': phone,
        'withThumbnails': withThumbnails,
        'photoHighResolution': photoHighResolution,
        'orderByGivenName': orderByGivenName,
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    if (contacts is! Iterable<dynamic>) return const <Contact>[];
    return contacts
        .whereType<JSON>()
        .map(Contact.fromJson)
        .toList(growable: false);
  }

  /// Fetches all contacts, or when specified, the contacts with the email
  /// matching [email]
  /// Works only on iOS
  static Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final contacts = await _channel.invokeMethod(
      'getContactsForEmail',
      <String, dynamic>{
        'email': email,
        'withThumbnails': withThumbnails,
        'photoHighResolution': photoHighResolution,
        'orderByGivenName': orderByGivenName,
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    if (contacts is! Iterable<dynamic>) return const <Contact>[];
    return contacts
        .whereType<JSON>()
        .map(Contact.fromJson)
        .toList(growable: false);
  }

  /// Loads the avatar for the given contact and returns it. If the user does
  /// not have an avatar, then `null` is returned in that slot. Only implemented
  /// on Android.
  static Future<Uint8List?> getAvatar(
    final Contact contact, {
    final bool photoHighRes = true,
  }) =>
      _channel.invokeMethod(
        'getAvatar',
        <String, dynamic>{
          'contact': contact.toJson(),
          'identifier': contact.identifier,
          'photoHighResolution': photoHighRes,
        },
      );

  /// Adds the [contact] to the device contact list
  static Future<void> addContact(Contact contact) =>
      _channel.invokeMethod('addContact', contact.toJson());

  /// Deletes the [contact] if it has a valid identifier
  static Future<void> deleteContact(Contact contact) =>
      _channel.invokeMethod('deleteContact', contact.toJson());

  /// Updates the [contact] if it has a valid identifier
  static Future<void> updateContact(Contact contact) =>
      _channel.invokeMethod('updateContact', contact.toJson());

  /// Opens the contact form with the fields prefilled with the values from the
  static Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final response = await _channel.invokeMethod(
      'openContactForm',
      <String, dynamic>{
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    return _convertResponse(response);
  }

  /// Opens the contact form with the fields prefilled with the values from the
  /// [contact] parameter
  static Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    dynamic response = await _channel.invokeMethod(
      'openExistingContact',
      <String, dynamic>{
        'contact': contact.toJson(),
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    return _convertResponse(response);
  }

  /// Displays the device/native contact picker dialog
  /// and returns the contact selected by the user
  static Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    var response = await _channel.invokeMethod(
      'openDeviceContactPicker',
      <String, dynamic>{
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    // response contains either :
    // - an List of contacts containing 0 or 1 contact
    // - a FormOperationErrorCode value
    if (response is Iterable<dynamic>) {
      if (response.isEmpty) return null;
      response = response.first;
    }
    return _convertResponse(response);
  }
}

Contact _convertResponse(Object? response) {
  if (response case JSON json) return Contact.fromJson(json);
  if (response case int res) {
    switch (res) {
      case 1:
        throw const FormOperationException$Canceled();
      case 2:
        throw const FormOperationException$CouldNotBeOpen();
      default:
        throw const FormOperationException$Unknown();
    }
  } else {
    throw const FormOperationException$Unknown();
  }
}
