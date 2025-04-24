import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:contactos_example/main.dart';
import 'package:contactos_ios/contactos_ios.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// {@template contacts_list_screen}
/// Contacts list screen widget.
/// {@endtemplate}
class ContactsListScreen extends StatefulWidget {
  /// {@macro contacts_list_screen}
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListScreen> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    // var contacts = (await Contactos.getContactsForPhone("8554964652"));

    // Load without thumbnails initially.
    final contacts = await ContactosIos.instance.getContacts(
      iOSLocalizedLabels: iOSLocalizedLabels,
      withThumbnails: false,
    );

    setState(() => _contacts = contacts);

    // Lazy load thumbnails after rendering initial contacts.
    for (var contact in _contacts ?? contacts) {
      await ContactosIos.instance.getAvatar(contact).then((avatar) {
        setState(() => contact = contact.copyWith(avatar: avatar));
      });
    }
  }

  Future<void> updateContact() async {
    var ninja = _contacts
        ?.firstWhereOrNull((c) => c.familyName?.startsWith('Ninja') ?? false);
    if (ninja == null) return;
    await ContactosIos.instance.updateContact(ninja);
    await refreshContacts();
  }

  Future<void> _openContactForm() async {
    try {
      var _ = await ContactosIos.instance.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels,
      );
      await refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.unknown:
        case FormOperationErrorCode.canceled:
        case FormOperationErrorCode.couldNotBeOpen:
        default:
          log(e.errorCode.toString());
      }
    }
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    var id = _contacts?.indexWhere((c) => c.identifier == contact.identifier);
    if (id == null || id < 0) return;
    _contacts?[id] = contact;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Contacts Plugin Example'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.create),
              onPressed: _openContactForm,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed('/add').then((_) {
              refreshContacts();
            });
          },
        ),
        body: SafeArea(
          child: _contacts != null
              ? ListView.builder(
                  itemCount: _contacts?.length ?? 0,
                  itemBuilder: (context, index) {
                    final contact = _contacts?.elementAt(index);
                    if (contact == null) return const SizedBox.shrink();
                    return ListTile(
                      onTap: () {
                        final route = MaterialPageRoute<void>(
                          builder: (context) => _ContactDetailsPage(
                            contact,
                            onContactDeviceSave: contactOnDeviceHasBeenUpdated,
                          ),
                        );
                        Navigator.of(context).push(route);
                      },
                      leading: (contact.avatar != null &&
                              (contact.avatar?.length ?? 0) > 0)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar!),
                            )
                          : CircleAvatar(child: Text(contact.initials())),
                      title: Text(contact.displayName ?? ''),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      );
}

class _ContactDetailsPage extends StatefulWidget {
  const _ContactDetailsPage(
    this._contact, {
    this.onContactDeviceSave,
    super.key, // ignore: unused_element_parameter
  });

  final Contact _contact;
  final void Function(Contact)? onContactDeviceSave;

  @override
  State<_ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<_ContactDetailsPage> {
  Future<void> _openExistingContactOnDevice(BuildContext context) async {
    try {
      final contact = await ContactosIos.instance.openExistingContact(
        widget._contact,
        iOSLocalizedLabels: iOSLocalizedLabels,
      );
      if (widget.onContactDeviceSave != null) {
        widget.onContactDeviceSave?.call(contact);
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.unknown:
        case FormOperationErrorCode.canceled:
        case FormOperationErrorCode.couldNotBeOpen:
        default:
          log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget._contact.displayName ?? ''),
          actions: <Widget>[
            /* IconButton(
              icon: Icon(Icons.share),
              onPressed: () => shareVCFCard(context, contact: _contact),
            ), */
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ContactosIos.instance.deleteContact(widget._contact);
              },
            ),
            IconButton(
              icon: const Icon(Icons.update),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _UpdateContactsPage(
                    contact: widget._contact,
                  ),
                ),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _openExistingContactOnDevice(context)),
          ],
        ),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Name'),
                trailing: Text(widget._contact.givenName ?? ''),
              ),
              ListTile(
                title: const Text('Middle name'),
                trailing: Text(widget._contact.middleName ?? ''),
              ),
              ListTile(
                title: const Text('Family name'),
                trailing: Text(widget._contact.familyName ?? ''),
              ),
              ListTile(
                title: const Text('Prefix'),
                trailing: Text(widget._contact.prefix ?? ''),
              ),
              ListTile(
                title: const Text('Suffix'),
                trailing: Text(widget._contact.suffix ?? ''),
              ),
              ListTile(
                title: const Text('Birthday'),
                trailing: Text(widget._contact.birthday != null
                    ? DateFormat('dd-MM-yyyy').format(widget._contact.birthday!)
                    : ''),
              ),
              ListTile(
                title: const Text('Company'),
                trailing: Text(widget._contact.company ?? ''),
              ),
              ListTile(
                title: const Text('Job'),
                trailing: Text(widget._contact.jobTitle ?? ''),
              ),
              ListTile(
                title: const Text('Account Type'),
                trailing: Text((widget._contact.androidAccountType != null)
                    ? widget._contact.androidAccountType.toString()
                    : ''),
              ),
              _AddressesTile(widget._contact.postalAddresses!),
              _ItemsTile('Phones', widget._contact.phones!),
              _ItemsTile('Emails', widget._contact.emails!)
            ],
          ),
        ),
      );
}

@immutable
class _AddressesTile extends StatelessWidget {
  const _AddressesTile(
    this._addresses, {
    super.key, // ignore: unused_element_parameter
  });

  final List<Contact$PostalAddress> _addresses;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ListTile(title: Text('Addresses')),
          Column(
            children: [
              for (final a in _addresses)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Street'),
                        trailing: Text(a.street ?? ''),
                      ),
                      ListTile(
                        title: const Text('Postcode'),
                        trailing: Text(a.postcode ?? ''),
                      ),
                      ListTile(
                        title: const Text('City'),
                        trailing: Text(a.city ?? ''),
                      ),
                      ListTile(
                        title: const Text('Region'),
                        trailing: Text(a.region ?? ''),
                      ),
                      ListTile(
                        title: const Text('Country'),
                        trailing: Text(a.country ?? ''),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
}

class _ItemsTile extends StatelessWidget {
  const _ItemsTile(
    this._title,
    this._items, {
    super.key, // ignore: unused_element_parameter
  });

  final List<Contact$Field> _items;
  final String _title;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(title: Text(_title)),
          Column(
            children: [
              for (final i in _items)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    title: Text(i.label ?? ''),
                    trailing: Text(i.value ?? ''),
                  ),
                ),
            ],
          ),
        ],
      );
}

/// {@template add_contact_screen}
/// Add contact screen.
/// {@endtemplate}
class AddContactScreen extends StatefulWidget {
  /// {@macro add_contact_screen}
  const AddContactScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<StatefulWidget> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Contact$PostalAddress address = const Contact$PostalAddress(label: 'Home');
  Contact contact = const Contact();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Add a contact'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _formKey.currentState?.save();
                final newContact = contact.copyWith(postalAddresses: [address]);
                ContactosIos.instance.addContact(newContact);
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.save, color: Colors.white),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First name'),
                  onSaved: (v) => contact.copyWith(givenName: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Middle name'),
                  onSaved: (v) => contact.copyWith(middleName: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last name'),
                  onSaved: (v) => contact = contact.copyWith(familyName: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Prefix'),
                  onSaved: (v) => contact = contact.copyWith(prefix: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Suffix'),
                  onSaved: (v) => contact = contact.copyWith(suffix: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onSaved: (v) => contact = contact.copyWith(phones: [
                    Contact$Field(
                      label: 'mobile',
                      value: v,
                    )
                  ]),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  onSaved: (v) => contact = contact.copyWith(
                    emails: [Contact$Field(label: 'work', value: v)],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Company'),
                  onSaved: (v) => contact = contact.copyWith(company: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Job'),
                  onSaved: (v) => contact = contact.copyWith(jobTitle: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Street'),
                  onSaved: (v) => address = address.copyWith(street: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'City'),
                  onSaved: (v) => address = address.copyWith(city: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Region'),
                  onSaved: (v) => address = address.copyWith(region: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Postal code'),
                  onSaved: (v) => address = address.copyWith(postcode: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Country'),
                  onSaved: (v) => address = address.copyWith(country: v),
                ),
              ],
            ),
          ),
        ),
      );
}

class _UpdateContactsPage extends StatefulWidget {
  const _UpdateContactsPage({
    @required this.contact,
    super.key, // ignore: unused_element_parameter
  });

  final Contact? contact;

  @override
  State<_UpdateContactsPage> createState() => __UpdateContactsPageState();
}

class __UpdateContactsPageState extends State<_UpdateContactsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Contact$PostalAddress address = const Contact$PostalAddress(label: 'Home');
  Contact? contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Update Contact'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: () async {
                _formKey.currentState?.save();
                final navigator = Navigator.of(context);
                final newContact =
                    contact?.copyWith(postalAddresses: [address]);
                if (newContact == null) return;
                await ContactosIos.instance.updateContact(newContact);
                await navigator.pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactsListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: contact?.givenName ?? '',
                  decoration: const InputDecoration(labelText: 'First name'),
                  onSaved: (v) => contact = contact?.copyWith(givenName: v),
                ),
                TextFormField(
                  initialValue: contact?.middleName ?? '',
                  decoration: const InputDecoration(labelText: 'Middle name'),
                  onSaved: (v) => contact = contact?.copyWith(middleName: v),
                ),
                TextFormField(
                  initialValue: contact?.familyName ?? '',
                  decoration: const InputDecoration(labelText: 'Last name'),
                  onSaved: (v) => contact = contact?.copyWith(familyName: v),
                ),
                TextFormField(
                  initialValue: contact?.prefix ?? '',
                  decoration: const InputDecoration(labelText: 'Prefix'),
                  onSaved: (v) => contact = contact?.copyWith(prefix: v),
                ),
                TextFormField(
                  initialValue: contact?.suffix ?? '',
                  decoration: const InputDecoration(labelText: 'Suffix'),
                  onSaved: (v) => contact = contact?.copyWith(suffix: v),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onSaved: (v) => contact = contact?.copyWith(
                      phones: [Contact$Field(label: 'mobile', value: v)]),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  onSaved: (v) => contact = contact?.copyWith(
                    emails: [Contact$Field(label: 'work', value: v)],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  initialValue: contact?.company ?? '',
                  decoration: const InputDecoration(labelText: 'Company'),
                  onSaved: (v) => contact = contact?.copyWith(company: v),
                ),
                TextFormField(
                  initialValue: contact?.jobTitle ?? '',
                  decoration: const InputDecoration(labelText: 'Job'),
                  onSaved: (v) => contact = contact?.copyWith(jobTitle: v),
                ),
                TextFormField(
                  initialValue: address.street ?? '',
                  decoration: const InputDecoration(labelText: 'Street'),
                  onSaved: (v) => address = address.copyWith(street: v),
                ),
                TextFormField(
                  initialValue: address.city ?? '',
                  decoration: const InputDecoration(labelText: 'City'),
                  onSaved: (v) => address = address.copyWith(city: v),
                ),
                TextFormField(
                  initialValue: address.region ?? '',
                  decoration: const InputDecoration(labelText: 'Region'),
                  onSaved: (v) => address = address.copyWith(region: v),
                ),
                TextFormField(
                  initialValue: address.postcode ?? '',
                  decoration: const InputDecoration(labelText: 'Postal code'),
                  onSaved: (v) => address = address.copyWith(postcode: v),
                ),
                TextFormField(
                  initialValue: address.country ?? '',
                  decoration: const InputDecoration(labelText: 'Country'),
                  onSaved: (v) => address = address.copyWith(country: v),
                ),
              ],
            ),
          ),
        ),
      );
}
