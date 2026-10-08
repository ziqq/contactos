/// Shared widget tests for the contactos example apps.
///
/// The tests talk to the example through the real
/// `github.com/ziqq/contactos` method channel and a mocked
/// `permission_handler` channel.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _contactsChannel = MethodChannel('github.com/ziqq/contactos');
const _permissionsChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// `PermissionStatus.granted` and `PermissionStatus.denied` wire values.
const _granted = 1;
const _denied = 0;

Map<String, Object?> _contact({
  required String identifier,
  required String givenName,
  required String familyName,
  List<Map<String, String>> phones = const [],
  List<Map<String, String>> emails = const [],
  List<Map<String, String>> postalAddresses = const [],
  String company = '',
  String jobTitle = '',
}) => <String, Object?>{
  'identifier': identifier,
  'displayName': '$givenName $familyName',
  'givenName': givenName,
  'middleName': '',
  'familyName': familyName,
  'prefix': '',
  'suffix': '',
  'company': company,
  'jobTitle': jobTitle,
  'androidAccountType': '',
  'androidAccountName': '',
  'birthday': '',
  'phones': phones,
  'emails': emails,
  'postalAddresses': postalAddresses,
};

final _alice = _contact(
  identifier: '1',
  givenName: 'Alice',
  familyName: 'Johnson',
  company: 'Acme Corp',
  jobTitle: 'Product Manager',
  phones: const [
    {'label': 'mobile', 'value': '+1 555 0100'},
  ],
  emails: const [
    {'label': 'work', 'value': 'alice@acme.dev'},
  ],
  postalAddresses: const [
    {
      'label': 'work',
      'street': '1 Infinite Loop',
      'city': 'Cupertino',
      'postcode': '95014',
      'region': 'CA',
      'country': 'USA',
    },
  ],
);

final _bob = _contact(identifier: '2', givenName: 'Bob', familyName: 'Smith');

/// Fake native side of the contacts method channel.
class _FakeContactsPlatform {
  final List<MethodCall> calls = <MethodCall>[];
  List<Map<String, Object?>> contacts = <Map<String, Object?>>[_alice, _bob];
  Object? pickerResult;

  Iterable<MethodCall> callsTo(String method) =>
      calls.where((call) => call.method == method);

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'getContacts' => contacts,
      'getAvatar' => null,
      'openDeviceContactPicker' => pickerResult,
      _ => null,
    };
  }
}

/// Runs the widget tests shared by every contactos example app.
///
/// [app] builds the example's root widget. The example must show the home,
/// contacts list, contact details, add contact and native picker screens
/// that all contactos examples share.
void runExampleAppTests(Widget Function() app) {
  late _FakeContactsPlatform platform;
  late int permissionStatus;

  setUp(() {
    platform = _FakeContactsPlatform();
    permissionStatus = _granted;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger
      ..setMockMethodCallHandler(_contactsChannel, platform.handle)
      ..setMockMethodCallHandler(
        _permissionsChannel,
        (call) async => switch (call.method) {
          'checkPermissionStatus' => permissionStatus,
          'requestPermissions' => <int, int>{
            for (final permission in call.arguments as List<Object?>)
              permission! as int: permissionStatus,
          },
          _ => null,
        },
      );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_contactsChannel, null)
      ..setMockMethodCallHandler(_permissionsChannel, null);
  });

  Future<void> openContactsList(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacts list'));
    await tester.pumpAndSettle();
  }

  group('Home', () {
    testWidgets('shows the example entry points', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Contacts Plugin Example'), findsOneWidget);
      expect(find.text('Contacts list'), findsOneWidget);
      expect(find.text('Native Contacts picker'), findsOneWidget);
    });

    testWidgets('reports a denied contacts permission', (tester) async {
      permissionStatus = _denied;

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Access to contact data denied'), findsOneWidget);
    });

    testWidgets('does not open the list without permission', (tester) async {
      permissionStatus = _denied;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contacts list'));
      await tester.pumpAndSettle();

      expect(platform.callsTo('getContacts'), isEmpty);
      expect(find.text('Alice Johnson'), findsNothing);
    });
  });

  group('Contacts list', () {
    testWidgets('shows contacts loaded without thumbnails', (tester) async {
      await openContactsList(tester);

      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);
      expect(find.text('AJ'), findsOneWidget);
      expect(find.text('BS'), findsOneWidget);

      final getContacts = platform.callsTo('getContacts').single;
      expect(
        (getContacts.arguments as Map<Object?, Object?>)['withThumbnails'],
        isFalse,
      );
    });

    testWidgets('loads avatars lazily for every contact', (tester) async {
      await openContactsList(tester);

      final identifiers = platform
          .callsTo('getAvatar')
          .map(
            (call) => (call.arguments as Map<Object?, Object?>)['identifier'],
          )
          .toList();
      expect(identifiers, unorderedEquals(<String>['1', '2']));
    });

    testWidgets('shows an empty list without contacts', (tester) async {
      platform.contacts = <Map<String, Object?>>[];

      await openContactsList(tester);

      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('opens contact details', (tester) async {
      await openContactsList(tester);

      await tester.tap(find.text('Alice Johnson'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Johnson'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('Product Manager'), findsOneWidget);
      expect(find.text('1 Infinite Loop'), findsOneWidget);
      expect(find.text('Cupertino'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('alice@acme.dev'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('+1 555 0100'), findsOneWidget);
      expect(find.text('alice@acme.dev'), findsOneWidget);
    });

    testWidgets('deletes the opened contact', (tester) async {
      await openContactsList(tester);
      await tester.tap(find.text('Alice Johnson'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      final delete = platform.callsTo('deleteContact').single;
      expect((delete.arguments as Map<Object?, Object?>)['identifier'], '1');
    });
  });

  group('Add contact', () {
    testWidgets('sends the entered contact to the platform', (tester) async {
      await openContactsList(tester);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      Future<void> enter(String label, String value) async {
        final field = find.widgetWithText(TextFormField, label);
        await tester.scrollUntilVisible(
          field,
          100,
          // The form list, not the text fields' own scrollables.
          scrollable: find
              .descendant(
                of: find.byType(Form),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.enterText(field, value);
      }

      await enter('First name', 'John');
      await enter('Middle name', 'Q');
      await enter('Last name', 'Doe');
      await enter('Phone', '+1 555 0199');
      await enter('E-mail', 'doe@example.com');
      await enter('Company', 'Globex');
      await enter('City', 'Springfield');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      final added =
          platform.callsTo('addContact').single.arguments
              as Map<Object?, Object?>;
      expect(added['givenName'], 'John');
      expect(added['middleName'], 'Q');
      expect(added['familyName'], 'Doe');
      expect(added['company'], 'Globex');
      expect(added['phones'], [
        {'label': 'mobile', 'value': '+1 555 0199'},
      ]);
      expect(added['emails'], [
        {'label': 'work', 'value': 'doe@example.com'},
      ]);
      final addresses = added['postalAddresses']! as List<Object?>;
      final address = addresses.single! as Map<Object?, Object?>;
      expect(address['label'], 'Home');
      expect(address['city'], 'Springfield');

      // The list is reloaded after returning from the form.
      expect(find.text('Add a contact'), findsNothing);
      expect(platform.callsTo('getContacts'), hasLength(2));
    });
  });

  group('Native contacts picker', () {
    Future<void> openPicker(WidgetTester tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Native Contacts picker'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the picked contact', (tester) async {
      platform.pickerResult = <Object?>[_alice];
      await openPicker(tester);

      await tester.tap(find.text('Pick a contact'));
      await tester.pumpAndSettle();

      expect(platform.callsTo('openDeviceContactPicker'), hasLength(1));
      expect(find.text('Contact selected: Alice Johnson'), findsOneWidget);
    });

    testWidgets('shows nothing when no contact is picked', (tester) async {
      platform.pickerResult = <Object?>[];
      await openPicker(tester);

      await tester.tap(find.text('Pick a contact'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Contact selected'), findsNothing);
    });

    testWidgets('ignores a canceled picker', (tester) async {
      // FormOperationErrorCode.canceled
      platform.pickerResult = 1;
      await openPicker(tester);

      await tester.tap(find.text('Pick a contact'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Contact selected'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
