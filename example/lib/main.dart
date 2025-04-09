import 'dart:async';
import 'dart:developer';

import 'package:contactos_example/src/screens/contacts_list_screen.dart';
import 'package:contactos_example/src/screens/navite_contacts_picker_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// iOS only: Localized labels language setting
/// is equal to CFBundleDevelopmentRegion value (Info.plist) of the iOS project
/// Set kiOSLocalizedLabels=false if you always want english labels
/// whatever is the CFBundleDevelopmentRegion value.
const kiOSLocalizedLabels = false;

void main() => runZonedGuarded<void>(
      () => runApp(const ContactsExampleApp()),
      (error, stackTrace) => log('Top level exception: $error\n$stackTrace'),
    );

/// {@template main}
/// A simple example app that demonstrates how to use the Contactos plugin.
/// {@endtemplate}
class ContactsExampleApp extends StatelessWidget {
  /// {@macro main}
  const ContactsExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: const _HomePage(),
        routes: <String, WidgetBuilder>{
          '/add': (_) => const AddContactScreen(),
          '/contacts-list': (_) => const ContactsListScreen(),
          '/native-contacts-picker': (_) => const NativeContactsPickerScreen(),
        },
      );
}

class _HomePage extends StatefulWidget {
  const _HomePage({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<_HomePage> createState() => __HomePageState();
}

class __HomePageState extends State<_HomePage> {
  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions([String? routeName]) async {
    final navigator = Navigator.of(context);
    final permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) await navigator.pushNamed(routeName);
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    final status = await Permission.contacts.status;
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.permanentlyDenied) {
      return await Permission.contacts.request();
    } else {
      return status;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    Widget? content;
    if (permissionStatus == PermissionStatus.denied) {
      content = const Text('Access to contact data denied');
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      content = const Text('Contact data not available on device');
    }
    if (content == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: content));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Contactos Plugin Example'),
          forceMaterialTransparency: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoButton.filled(
                  child: const Text('Contacts list'),
                  onPressed: () => _askPermissions('/contacts-list'),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  child: const Text('Native Contacts picker'),
                  onPressed: () => _askPermissions('/native-contacts-picker'),
                ),
              ],
            ),
          ),
        ),
      );
}
