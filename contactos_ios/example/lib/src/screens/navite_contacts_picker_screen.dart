import 'dart:developer';

import 'package:contactos_example/main.dart';
import 'package:contactos_ios/contactos_ios.dart';
import 'package:flutter/material.dart';

/// {@template navite_contacts_picker_screen}
/// NativeContactsPickerScreen widget.
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
  Contact? _contact;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickContact() async {
    try {
      final contact = await ContactosIos.instance.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels,
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
