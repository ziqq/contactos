// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForOverriding;

/// The iOS and macOS implementation of [ContactosPlatform].
///
/// This class implements the `package:contactos`
/// functionality for iOS and macOS.
class ContactosPluginFoundation extends ContactosPlatform {
  /// Creates a new plugin for iOS and macOS implementation instance.
  ContactosPluginFoundation._({
    @visibleForOverriding MethodChannelContactos? channel,
  }) : _channel = channel ?? MethodChannelContactos.instance;

  /// Returns an instance using a specified [MethodChannelContactos].
  factory ContactosPluginFoundation._instanceFor({
    @visibleForOverriding MethodChannelContactos? channel,
  }) =>
      ContactosPluginFoundation._(channel: channel);

  /// Returns the default instance
  /// of [ContactosPluginFoundation].
  static ContactosPluginFoundation get instance => _instance;

  /// Returns an instance using the default [ContactosPluginFoundation].
  static final ContactosPluginFoundation _instance =
      ContactosPluginFoundation._instanceFor();

  /// The channel used to interact with the platform side of the plugin.
  final MethodChannelContactos _channel;

  /// Registers this class
  /// as the default instance of [ContactosPla].
  static void registerWith() {
    ContactosPlatform.instance = ContactosPluginFoundation.instance;
  }

  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.getContacts(
        query: query,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  /// Fetches all contacts, or when specified, the contacts with the phone
  /// matching [phone]
  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.getContactsForPhone(
        phone,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  /// Fetches all contacts, or when specified, the contacts with the email
  /// matching [email]
  /// Works only on iOS
  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.getContactsForEmail(
        email,
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
        orderByGivenName: orderByGivenName,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  /// Loads the avatar for the given contact and returns it. If the user does
  /// not have an avatar, then `null` is returned in that slot. Only implemented
  /// on Android.
  @override
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true}) =>
      _channel.getAvatar(contact, photoHighRes: photoHighRes);

  /// Adds the [contact] to the device contact list
  @override
  Future<void> addContact(Contact contact) => _channel.addContact(contact);

  /// Deletes the [contact] if it has a valid identifier
  @override
  Future<void> deleteContact(Contact contact) =>
      _channel.deleteContact(contact);

  /// Updates the [contact] if it has a valid identifier
  @override
  Future<void> updateContact(Contact contact) =>
      _channel.updateContact(contact);

  /// Opens the contact form with the fields prefilled with the values from the
  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  /// Opens the contact form with the fields prefilled with the values from the
  /// [contact] parameter
  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.openExistingContact(
        contact,
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );

  /// Displays the device/native contact picker dialog
  /// and returns the contact selected by the user
  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) =>
      _channel.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels,
        androidLocalizedLabels: androidLocalizedLabels,
      );
}
