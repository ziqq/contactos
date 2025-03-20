import 'dart:developer';

import 'package:contactos_android/contactos_android.dart';
import 'package:contactos_example/main.dart';
import 'package:contactos_platform_interface/types.dart';
import 'package:flutter/material.dart';

/// {@template navite_contacts_picker_screen}
/// A screen that allows users to pick a contact from the device's contacts.
/// {@endtemplate}
class NativeContactsPickerScreen extends StatefulWidget {
  /// {@macro navite_contacts_picker_screen}
  const NativeContactsPickerScreen({super.key});

  @override
  State<NativeContactsPickerScreen> createState() =>
      _NativeContactsPickerScreenState();
}

class _NativeContactsPickerScreenState
    extends State<NativeContactsPickerScreen> {
  final ContactosAndroid _contactos = ContactosAndroid();
  Contact? _contact;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickContact() async {
    try {
      final contact = await _contactos.openDeviceContactPicker(
        iOSLocalizedLabels: kiOSLocalizedLabels,
      );
      setState(() => _contact = contact);
    } on Object catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Contacts Picker Example')),
        body: SafeArea(
            child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickContact,
              child: const Text('Pick a contact'),
            ),
            if (_contact != null)
              Text('Contact selected: ${_contact?.displayName}'),
          ],
        )),
      );
}
