import 'dart:typed_data';

import 'package:contactos_platform_interface/method_channel_contactos.dart';
import 'package:contactos_platform_interface/types.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of contactos must implement.
///
/// Platform implementations should extend this class rather than implement it as `contactos`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [ContactosPlatform] methods.
abstract class ContactosPlatform extends PlatformInterface {
  /// Constructs a ContactosPlatform.
  ContactosPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [ContactosPlatform] to use.
  ///
  /// Defaults to [MethodChannelContactos].
  static ContactosPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [ContactosPlatform] when they register themselves.
  static set instance(ContactosPlatform instance) {
    if (!instance.isMock) {
      PlatformInterface.verify(instance, _token);
    }
    _instance = instance;
  }

  static ContactosPlatform _instance = MethodChannelContactos();

  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  @Deprecated('Use MockPlatformInterfaceMixin instead')
  bool get isMock => false;

  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Fetches all contacts, or when specified, the contacts with the phone
  /// matching [phone]
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Fetches all contacts, or when specified, the contacts with the email
  /// matching [email]
  /// Works only on iOS
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Loads the avatar for the given contact and returns it. If the user does
  /// not have an avatar, then `null` is returned in that slot. Only implemented
  /// on Android.
  Future<Uint8List?> getAvatar(Contact contact, {bool photoHighRes = true});

  /// Adds the [contact] to the device contact list
  Future<void> addContact(Contact contact);

  /// Deletes the [contact] if it has a valid identifier
  Future<void> deleteContact(Contact contact);

  /// Updates the [contact] if it has a valid identifier
  Future<void> updateContact(Contact contact);

  /// Opens the contact form with the fields prefilled with the values from the
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  /// Opens the contact form with the fields prefilled with the values from the
  /// [contact] parameter
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });

  // Displays the device/native contact picker dialog and returns the contact selected by the user
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  });
}
