// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

// ignore_for_file: sort_constructors_first

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// {@template contactos}
/// The iOS implementation of [ContactosPlatform].
///
/// This class implements the `package:contactos` functionality for iOS.
/// {@endtemplate}
class Contactos extends ContactosPlatform {
  /// Use [SharePlus.instance] to access the [share] method.
  /// {@macro contactos}
  Contactos._(this._platform);

  /// Platform interface
  final ContactosPlatform _platform;

  /// Singleton instance (instance API).
  static Contactos? _instance;

  /// The default instance of [Contactos].
  static final Contactos instance =
      _instance ??= Contactos._(ContactosPlatform.instance);

  /// Create a custom instance of [Contactos].
  /// Use this constructor for testing purposes only.
  @visibleForTesting
  factory Contactos.custom(ContactosPlatform platform) => Contactos._(platform);

  @override
  Future<void> addContact(Contact c) => _platform.addContact(c);

  @override
  Future<void> deleteContact(Contact c) => _platform.deleteContact(c);

  @override
  Future<void> updateContact(Contact c) => _platform.updateContact(c);

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) =>
      _platform.getAvatar(contact, photoHighRes: photoHighRes);

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.getContacts(
        query: query,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.getContactsForEmail(
        email,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.getContactsForPhone(
        phone,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _platform.openExistingContact(
        contact,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );
}
