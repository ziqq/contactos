// Copyright 2025 The Anton Ustinoff <a.a.ustinoff@gmail.com>.
// All rights reserved. Use of this source code is
// governed by a MIT-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:contactos_platform_interface/types.dart';
import 'package:flutter/services.dart';

/// The [MethodChannel] used to interact with the platform side of the plugin.
const MethodChannel _kChannel = MethodChannel('github.com/ziqq/contactos');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class MethodChannelContactos extends ContactosPlatform {
  @override
  Future<void> addContact(Contact contact) =>
      _kChannel.invokeMethod('addContact', contact.toMap());

  @override
  Future<void> deleteContact(Contact contact) =>
      _kChannel.invokeMethod('deleteContact', contact.toMap());

  @override
  Future<void> updateContact(Contact contact) =>
      _kChannel.invokeMethod('updateContact', contact.toMap());

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) =>
      _kChannel.invokeMethod(
        'getAvatar',
        <String, dynamic>{
          'contact': contact.toMap(),
          'identifier': contact.identifier,
          'photoHighResolution': photoHighRes,
        },
      );

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final result = await _kChannel.invokeMethod(
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
    if (result case List<JSON> contacts) {
      return contacts
          .whereType<JSON>()
          .map(Contact.fromJson)
          .toList(growable: false);
    }
    return <Contact>[];
  }

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final result = await _kChannel.invokeMethod(
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
    if (result case List<JSON> contacts) {
      return contacts
          .whereType<JSON>()
          .map(Contact.fromJson)
          .toList(growable: false);
    }
    return <Contact>[];
  }

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    if (phone == null || phone.isEmpty) return List.empty();
    final result = await _kChannel.invokeMethod(
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
    if (result case List<JSON> contacts) {
      return contacts
          .whereType<JSON>()
          .map(Contact.fromJson)
          .toList(growable: false);
    }
    return <Contact>[];
  }

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final result = await _kChannel.invokeMethod(
      'openContactForm',
      <String, dynamic>{
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    return _handleFormOperation(result);
  }

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    var result = await _kChannel.invokeMethod(
      'openDeviceContactPicker',
      <String, dynamic>{
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    // result contains either :
    // - an List of contacts containing 0 or 1 contact
    // - a FormOperationErrorCode value
    if (result case List<Contact?> resultList) {
      if (resultList.isEmpty) return null;
      result = resultList.first;
    }
    return _handleFormOperation(result);
  }

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    dynamic result = await _kChannel.invokeMethod(
      'openExistingContact',
      <String, dynamic>{
        'contact': contact.toMap(),
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    return _handleFormOperation(result);
  }
}

// ignore: avoid_annotating_with_dynamic
Contact _handleFormOperation(dynamic result) {
  if (result case int resultInt) {
    switch (resultInt) {
      case 1:
        throw const FormOperationException.canceled();
      case 2:
        throw const FormOperationException.couldNotBeOpen();
      default:
        throw const FormOperationException.unknown();
    }
  } else if (result case JSON json) {
    return Contact.fromJson(json);
  } else {
    throw const FormOperationException.unknown();
  }
}
