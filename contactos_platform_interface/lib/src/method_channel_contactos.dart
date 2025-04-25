// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:contactos_platform_interface/src/types.dart';
import 'package:flutter/services.dart';

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class MethodChannelContactos extends ContactosPlatform {
  /// Create an instance of [MethodChannelContactos].
  MethodChannelContactos._();

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  // ignore: prefer_constructors_over_static_methods
  static MethodChannelContactos get instance => MethodChannelContactos._();

  /// The [MethodChannel] used to interact with the platform side of the plugin.
  static const MethodChannel _channel = MethodChannel(
    'github.com/ziqq/contactos',
  );

  @override
  Future<void> addContact(Contact contact) =>
      _channel.invokeMethod('addContact', contact.toJson());

  @override
  Future<void> deleteContact(Contact contact) =>
      _channel.invokeMethod('deleteContact', contact.toJson());

  @override
  Future<void> updateContact(Contact contact) =>
      _channel.invokeMethod('updateContact', contact.toJson());

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) =>
      _channel.invokeMethod(
        'getAvatar',
        <String, dynamic>{
          'contact': contact.toJson(),
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

  @override
  Future<List<Contact>> getContactsForEmail(
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

  @override
  Future<List<Contact>> getContactsForPhone(
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

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async {
    final result = await _channel.invokeMethod(
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
    var result = await _channel.invokeMethod(
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
    final result = await _channel.invokeMethod(
      'openExistingContact',
      <String, dynamic>{
        'contact': contact.toJson(),
        'iOSLocalizedLabels': iOSLocalizedLabels,
        'androidLocalizedLabels': androidLocalizedLabels,
      },
    );
    return _handleFormOperation(result);
  }
}

Contact _handleFormOperation(Object? result) {
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
