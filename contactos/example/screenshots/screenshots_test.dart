// Generates README and pub.dev screenshots of the example app.
//
// Run from the example directory:
//   flutter test screenshots/screenshots_test.dart
//
// The images are written to SCREENSHOTS_DIR
// (defaults to ../screenshots).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:contactos_example/main.dart';
import 'package:contactos_platform_interface/contactos_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _contacts = <Contact>[
  Contact(
    identifier: '1',
    displayName: 'Alice Johnson',
    givenName: 'Alice',
    familyName: 'Johnson',
    company: 'Acme Corp',
    jobTitle: 'Product Manager',
    phones: [Contact$Field(label: 'mobile', value: '+1 555 0100')],
    emails: [Contact$Field(label: 'work', value: 'alice@acme.dev')],
    postalAddresses: [
      Contact$PostalAddress(
        label: 'work',
        street: '1 Infinite Loop',
        city: 'Cupertino',
        postcode: '95014',
        region: 'CA',
        country: 'USA',
      ),
    ],
  ),
  Contact(
    identifier: '2',
    displayName: 'Bob Smith',
    givenName: 'Bob',
    familyName: 'Smith',
    phones: [Contact$Field(label: 'home', value: '+1 555 0101')],
  ),
  Contact(
    identifier: '3',
    displayName: 'Carol Williams',
    givenName: 'Carol',
    familyName: 'Williams',
    emails: [Contact$Field(label: 'home', value: 'carol@example.com')],
  ),
  Contact(
    identifier: '4',
    displayName: 'David Brown',
    givenName: 'David',
    familyName: 'Brown',
  ),
  Contact(
    identifier: '5',
    displayName: 'Emma Davis',
    givenName: 'Emma',
    familyName: 'Davis',
  ),
  Contact(
    identifier: '6',
    displayName: 'Frank Miller',
    givenName: 'Frank',
    familyName: 'Miller',
  ),
];

class _FakeContactosPlatform extends ContactosPlatform {
  @override
  Future<List<Contact>> getContacts({
    String? query,
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) async => _contacts.toList();

  @override
  Future<Uint8List?> getAvatar(
    Contact contact, {
    bool photoHighRes = true,
  }) async => null;

  @override
  Future<List<Contact>> getContactsForPhone(
    String? phone, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) => throw UnimplementedError();

  @override
  Future<List<Contact>> getContactsForEmail(
    String email, {
    bool withThumbnails = true,
    bool photoHighResolution = true,
    bool orderByGivenName = true,
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) => throw UnimplementedError();

  @override
  Future<void> addContact(Contact contact) => throw UnimplementedError();

  @override
  Future<void> deleteContact(Contact contact) => throw UnimplementedError();

  @override
  Future<void> updateContact(Contact contact) => throw UnimplementedError();

  @override
  Future<Contact> openContactForm({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) => throw UnimplementedError();

  @override
  Future<Contact> openExistingContact(
    Contact contact, {
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) => throw UnimplementedError();

  @override
  Future<Contact?> openDeviceContactPicker({
    bool iOSLocalizedLabels = true,
    bool androidLocalizedLabels = true,
  }) => throw UnimplementedError();
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('FLUTTER_ROOT is not set.');
  final fonts = Directory('$root/bin/cache/artifacts/material_fonts');
  Future<ByteData> read(File file) async =>
      ByteData.sublistView(await file.readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final file in fonts.listSync().whereType<File>()) {
    if (file.path.contains('Roboto-')) roboto.addFont(read(file));
  }
  await roboto.load();

  final icons = FontLoader('MaterialIcons')
    ..addFont(read(File('${fonts.path}/MaterialIcons-Regular.otf')));
  await icons.load();
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  final directory = Directory(
    Platform.environment['SCREENSHOTS_DIR'] ?? '../screenshots',
  )..createSync(recursive: true);
  final view = tester.view;
  await tester.runAsync(() async {
    final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    // The root layer already applies the device pixel ratio.
    final image = await layer.toImage(Offset.zero & view.physicalSize);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(
      '${directory.path}/$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    // Render like a release build on a touch device.
    WidgetsApp.debugAllowBannerOverride = false;
    ContactosPlatform.instance = _FakeContactosPlatform();
    // Report the contacts permission as granted.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => switch (call.method) {
            'checkPermissionStatus' => 1,
            'requestPermissions' => <int, int>{
              for (final p in call.arguments as List<Object?>) p! as int: 1,
            },
            _ => null,
          },
        );
  });

  testWidgets('screenshots', (tester) async {
    // iPhone 15 Pro: 1179x2556 physical pixels at 3x.
    tester.view
      ..physicalSize = const Size(1179, 2556)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    // flutter_test draws shadows as solid outlines by default.
    debugDisableShadows = false;
    try {
      await tester.pumpWidget(const ContactsExampleApp());
      await _capture(tester, '1_home');

      await tester.tap(find.text('Contacts list'));
      await _capture(tester, '2_contacts_list');

      await tester.tap(find.text('Alice Johnson'));
      await _capture(tester, '3_contact_details');

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await _capture(tester, '4_add_contact');
    } finally {
      debugDisableShadows = true;
    }
  });
}
