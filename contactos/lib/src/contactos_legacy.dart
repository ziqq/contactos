// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// The iOS implementation of [ContactosPlatform].
///
/// This class implements the `package:contactos` functionality for iOS.
class Contactos extends ContactosPlatform {
  Contactos._({@visibleForTesting MethodChannelContactos? channel})
      : channel = channel ?? MethodChannelContactos.instance,
        super();

  /// Underlying channel-based implementation.
  final MethodChannelContactos channel;

  static Contactos? _instance;

  /// Returns the [Contactos] singleton instance.
  /// Also registers this as the default platform implementation.
  // ignore: prefer_constructors_over_static_methods
  static Contactos get instance => _instance ??= Contactos._();

  /// Registers this class as the default instance of [Contactos].
  static void registerWith() {
    ContactosPlatform.instance = Contactos.instance;
  }

  @protected
  @override
  ContactosPlatform delegateFor({
    required MethodChannelContactos channel,
  }) =>
      Contactos._(channel: channel);

  @override
  Future<void> addContact(Contact c) => channel.addContact(c);

  @override
  Future<void> deleteContact(Contact c) => channel.deleteContact(c);

  @override
  Future<void> updateContact(Contact c) => channel.updateContact(c);

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) =>
      channel.getAvatar(contact, photoHighRes: photoHighRes);

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      channel.getContacts(
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
      channel.getContactsForEmail(
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
      channel.getContactsForPhone(
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
      channel.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      channel.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      channel.openExistingContact(
        contact,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );
}
