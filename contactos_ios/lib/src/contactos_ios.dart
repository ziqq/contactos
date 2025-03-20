import 'dart:typed_data';

import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:contactos_platform_interface/types.dart';

/// iOS and macOS implementation of contactos.
class ContactosIOS extends ContactosPlatform {
  /// Registers this class as the default instance of
  /// [ContactosPlatform].
  static void registerWith() {
    ContactosPlatform.instance = ContactosIOS();
    // A temporary work-around for having two plugins contained in a single package.
    ContactosIOS.registerWith();
  }

  @override
  Future<void> addContact(Contact contact) {
    // TODO: implement addContact
    throw UnimplementedError();
  }

  @override
  Future<void> deleteContact(Contact contact) {
    // TODO: implement deleteContact
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true}) {
    // TODO: implement getAvatar
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContacts(
      {String? query,
      bool withThumbnails = true,
      bool photoHighResolution = true,
      bool orderByGivenName = true,
      bool iOSLocalizedLabels = true,
      bool androidLocalizedLabels = true}) {
    // TODO: implement getContacts
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForEmail(String email,
      {bool withThumbnails = true,
      bool photoHighResolution = true,
      bool orderByGivenName = true,
      bool iOSLocalizedLabels = true,
      bool androidLocalizedLabels = true}) {
    // TODO: implement getContactsForEmail
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>> getContactsForPhone(String? phone,
      {bool withThumbnails = true,
      bool photoHighResolution = true,
      bool orderByGivenName = true,
      bool iOSLocalizedLabels = true,
      bool androidLocalizedLabels = true}) {
    // TODO: implement getContactsForPhone
    throw UnimplementedError();
  }

  @override
  Future<Contact> openContactForm(
      {bool iOSLocalizedLabels = true, bool androidLocalizedLabels = true}) {
    // TODO: implement openContactForm
    throw UnimplementedError();
  }

  @override
  Future<Contact?> openDeviceContactPicker(
      {bool iOSLocalizedLabels = true, bool androidLocalizedLabels = true}) {
    // TODO: implement openDeviceContactPicker
    throw UnimplementedError();
  }

  @override
  Future<Contact> openExistingContact(Contact contact,
      {bool iOSLocalizedLabels = true, bool androidLocalizedLabels = true}) {
    // TODO: implement openExistingContact
    throw UnimplementedError();
  }

  @override
  Future<void> updateContact(Contact contact) {
    // TODO: implement updateContact
    throw UnimplementedError();
  }
}
