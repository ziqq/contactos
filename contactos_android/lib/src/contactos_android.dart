// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:contactos_platform_interface/method_channel_contactos.dart';
import 'package:contactos_platform_interface/types.dart';
import 'package:flutter/foundation.dart';

/// The Android implementation of [ContactosPlatform].
///
/// This class implements the `package:contactos` functionality for Android.
class ContactosAndroid extends ContactosPlatform {
  /// Creates a new plugin implementation instance.
  ContactosAndroid({
    @visibleForOverriding MethodChannelContactos? methodChannel,
  }) : _methodChannel = methodChannel ?? MethodChannelContactos();

  final MethodChannelContactos _methodChannel;

  /// Registers this class as the default instance of [ContactosPlatform].
  static void registerWith() {
    ContactosPlatform.instance = ContactosAndroid();
  }

  @override
  Future<void> addContact(Contact contact) =>
      _methodChannel.addContact(contact);

  @override
  Future<void> deleteContact(Contact contact) =>
      _methodChannel.deleteContact(contact);

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) =>
      _methodChannel.getAvatar(contact, photoHighRes: photoHighRes);

  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _methodChannel.getContacts(
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
      _methodChannel.getContactsForEmail(
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
      _methodChannel.getContactsForPhone(
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
      _methodChannel.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _methodChannel.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _methodChannel.openExistingContact(
        contact,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  @override
  Future<void> updateContact(Contact contact) =>
      _methodChannel.updateContact(contact);
}
