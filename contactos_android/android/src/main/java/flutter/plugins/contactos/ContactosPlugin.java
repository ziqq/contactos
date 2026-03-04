// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package flutter.plugins.contactos;

import android.content.ContentProviderOperation;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.app.Activity.RESULT_CANCELED;
import static android.provider.ContactsContract.CommonDataKinds;
import static android.provider.ContactsContract.CommonDataKinds.Email;
import static android.provider.ContactsContract.CommonDataKinds.Organization;
import static android.provider.ContactsContract.CommonDataKinds.Phone;
import static android.provider.ContactsContract.CommonDataKinds.StructuredName;
import static android.provider.ContactsContract.CommonDataKinds.StructuredPostal;

/**
 * Updated ContactosPlugin, using PluginRegistry.ActivityResultListener and ExecutorService
 * instead of ActivityPluginBinding.ActivityResultListener and AsyncTask.
 */
public class ContactosPlugin implements
        MethodChannel.MethodCallHandler,
        FlutterPlugin,
        ActivityAware
{
    private static final int FORM_OPERATION_CANCELED = 1;
    private static final int FORM_COULD_NOT_BE_OPEN = 2;

    private static final String LOG_TAG = "contacts";

    private ContentResolver contentResolver;
    private BaseContactosDelegate delegate;
    private MethodChannel methodChannel;
    private Resources resources;

    // Thread pool for asynchronous operations (replacement for AsyncTask)
    private final ExecutorService executor = new ThreadPoolExecutor(
            0,
            10,
            60,
            TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(1000)
    );

    // Handler for returning the result to the main (UI) thread
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    // region FlutterPlugin
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.resources = binding.getApplicationContext().getResources();
        initInstance(binding.getBinaryMessenger(), binding.getApplicationContext());
        this.delegate = new ContactosDelegate(binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (methodChannel != null) {
            methodChannel.setMethodCallHandler(null);
            methodChannel = null;
        }
        contentResolver = null;
        delegate = null;
        resources = null;
    }
    // endregion

    // region ActivityAware
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        if (delegate instanceof ContactosDelegate) {
            ((ContactosDelegate) delegate).bindToActivity(binding);
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        if (delegate instanceof ContactosDelegate) {
            ((ContactosDelegate) delegate).unbindActivity();
        }
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        if (delegate instanceof ContactosDelegate) {
            ((ContactosDelegate) delegate).bindToActivity(binding);
        }
    }

    @Override
    public void onDetachedFromActivity() {
        if (delegate instanceof ContactosDelegate) {
            ((ContactosDelegate) delegate).unbindActivity();
        }
    }
    // endregion

    // region Initialization
    private void initInstance(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "github.com/ziqq/contactos");
        methodChannel.setMethodCallHandler(this);
        contentResolver = context.getContentResolver();
    }
    // endregion

    // region MethodCallHandler
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getContacts": {
                final String query = call.argument("query");
                final boolean withThumbnails = call.argument("withThumbnails");
                final boolean orderByGivenName = call.argument("orderByGivenName");
                final boolean photoHighResolution = call.argument("photoHighResolution");
                final boolean androidLocalizedLabels = call.argument("androidLocalizedLabels");

                getContacts(
                        "getContacts",
                        query,
                        withThumbnails,
                        photoHighResolution,
                        orderByGivenName,
                        androidLocalizedLabels,
                        result
                );
                break;
            }
            case "getContactsForPhone": {
                final String phone = call.argument("phone");
                final boolean withThumbnails = call.argument("withThumbnails");
                final boolean photoHighResolution = call.argument("photoHighResolution");
                final boolean orderByGivenName = call.argument("orderByGivenName");
                final boolean androidLocalizedLabels = call.argument("androidLocalizedLabels");

                getContacts(
                        "getContactsForPhone",
                        phone,
                        withThumbnails,
                        photoHighResolution,
                        orderByGivenName,
                        androidLocalizedLabels,
                        result
                );
                break;
            }
            case "getContactsForEmail": {
                final String email = call.argument("email");
                final boolean withThumbnails = call.argument("withThumbnails");
                final boolean photoHighResolution = call.argument("photoHighResolution");
                final boolean orderByGivenName = call.argument("orderByGivenName");
                final boolean androidLocalizedLabels = call.argument("androidLocalizedLabels");

                getContacts(
                        "getContactsForEmail",
                        email,
                        withThumbnails,
                        photoHighResolution,
                        orderByGivenName,
                        androidLocalizedLabels,
                        result
                );
                break;
            }
            case "getAvatar": {
                final HashMap map = call.argument("contact");
                final boolean photoHighResolution = call.argument("photoHighResolution");
                final Contact contact = Contact.fromMap(map);
                getAvatar(contact, photoHighResolution, result);
                break;
            }
            case "addContact": {
                final Contact contact = Contact.fromMap((HashMap) call.arguments);
                if (addContact(contact)) {
                    result.success(null);
                } else {
                    result.error(null, "Failed to add the contact", null);
                }
                break;
            }
            case "deleteContact": {
                final Contact contact = Contact.fromMap((HashMap) call.arguments);
                if (deleteContact(contact)) {
                    result.success(null);
                } else {
                    result.error(null, "Failed to delete the contact, make sure it has a valid identifier", null);
                }
                break;
            }
            case "updateContact": {
                final Contact contact = Contact.fromMap((HashMap) call.arguments);
                if (updateContact(contact)) {
                    result.success(null);
                } else {
                    result.error(null, "Failed to update the contact, make sure it has a valid identifier", null);
                }
                break;
            }
            case "openExistingContact": {
                final HashMap map = call.argument("contact");
                final boolean localizedLabels = call.argument("androidLocalizedLabels");
                final Contact contact = Contact.fromMap(map);
                if (delegate != null) {
                    delegate.setResult(result);
                    delegate.setLocalizedLabels(localizedLabels);
                    delegate.openExistingContact(contact);
                } else {
                    result.success(FORM_COULD_NOT_BE_OPEN);
                }
                break;
            }
            case "openContactForm": {
                final boolean localizedLabels = call.argument("androidLocalizedLabels");
                if (delegate != null) {
                    delegate.setResult(result);
                    delegate.setLocalizedLabels(localizedLabels);
                    delegate.openContactForm();
                } else {
                    result.success(FORM_COULD_NOT_BE_OPEN);
                }
                break;
            }
            case "openDeviceContactPicker": {
                final boolean localizedLabels = call.argument("androidLocalizedLabels");
                openDeviceContactPicker(result, localizedLabels);
                break;
            }
            default: {
                result.notImplemented();
            }
        }
    }
    // endregion

    // region Asynchronous contact retrieval (AsyncTask replacement)
    private static final String[] PROJECTION = {
            ContactsContract.Data.CONTACT_ID,
            ContactsContract.Profile.DISPLAY_NAME,
            ContactsContract.Contacts.Data.MIMETYPE,
            ContactsContract.RawContacts.ACCOUNT_TYPE,
            ContactsContract.RawContacts.ACCOUNT_NAME,
            StructuredName.DISPLAY_NAME,
            StructuredName.GIVEN_NAME,
            StructuredName.MIDDLE_NAME,
            StructuredName.FAMILY_NAME,
            StructuredName.PREFIX,
            StructuredName.SUFFIX,
            CommonDataKinds.Note.NOTE,
            Phone.NUMBER,
            Phone.TYPE,
            Phone.LABEL,
            Email.ADDRESS,
            Email.TYPE,
            Email.LABEL,
            Organization.COMPANY,
            Organization.TITLE,
            StructuredPostal.FORMATTED_ADDRESS,
            StructuredPostal.TYPE,
            StructuredPostal.LABEL,
            StructuredPostal.STREET,
            StructuredPostal.POBOX,
            StructuredPostal.NEIGHBORHOOD,
            StructuredPostal.CITY,
            StructuredPostal.REGION,
            StructuredPostal.POSTCODE,
            StructuredPostal.COUNTRY,
    };

    // A unified method for getting contacts in the background.
    private void getContacts(
            final String callMethod,
            final String param,
            final boolean withThumbnails,
            final boolean photoHighResolution,
            final boolean orderByGivenName,
            final boolean localizedLabels,
            final MethodChannel.Result result
    ) {
        executor.execute(() -> {
            ArrayList<Contact> contacts;

            switch (callMethod) {
                case "openDeviceContactPicker":
                    contacts = getContactsFrom(getCursor(null, param), localizedLabels);
                    break;
                case "getContacts":
                    contacts = getContactsFrom(getCursor(param, null), localizedLabels);
                    break;
                case "getContactsForPhone":
                    contacts = getContactsFrom(getCursorForPhone(param), localizedLabels);
                    break;
                case "getContactsForEmail":
                    contacts = getContactsFrom(getCursorForEmail(param), localizedLabels);
                    break;
                default:
                    contacts = null;
                    break;
            }

            if (contacts != null && withThumbnails) {
                for (Contact c : contacts) {
                    byte[] avatar = loadContactPhotoHighRes(c.identifier, photoHighResolution, contentResolver);
                    c.avatar = (avatar != null) ? avatar : new byte[0];
                }
            }

            if (contacts != null && orderByGivenName) {
                Collections.sort(contacts, Comparator.naturalOrder());
            }

            final ArrayList<HashMap> contactMaps = new ArrayList<>();
            if (contacts != null) {
                for (Contact c : contacts) {
                    contactMaps.add(c.toMap());
                }
            }

            // Returning the result to the main thread
            mainHandler.post(() -> {
                if (contacts == null) {
                    result.notImplemented();
                } else {
                    result.success(contactMaps);
                }
            });
        });
    }
    // endregion

    private void openDeviceContactPicker(MethodChannel.Result result, boolean localizedLabels) {
        if (delegate != null) {
            delegate.setResult(result);
            delegate.setLocalizedLabels(localizedLabels);
            delegate.openContactPicker();
        } else {
            result.success(FORM_COULD_NOT_BE_OPEN);
        }
    }

    private ArrayList<Contact> getContactsFrom(Cursor cursor, boolean localizedLabels) {
        HashMap<String, Contact> map = new LinkedHashMap<>();

        if (cursor != null) {
            while (cursor.moveToNext()) {
                String contactId = cursor.getString(cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID));
                if (!map.containsKey(contactId)) {
                    map.put(contactId, new Contact(contactId));
                }
                Contact contact = map.get(contactId);

                String mimeType = cursor.getString(cursor.getColumnIndex(ContactsContract.Data.MIMETYPE));
                contact.displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
                contact.androidAccountType = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE));
                contact.androidAccountName = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME));

                if (CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    contact.givenName = cursor.getString(cursor.getColumnIndex(StructuredName.GIVEN_NAME));
                    contact.middleName = cursor.getString(cursor.getColumnIndex(StructuredName.MIDDLE_NAME));
                    contact.familyName = cursor.getString(cursor.getColumnIndex(StructuredName.FAMILY_NAME));
                    contact.prefix = cursor.getString(cursor.getColumnIndex(StructuredName.PREFIX));
                    contact.suffix = cursor.getString(cursor.getColumnIndex(StructuredName.SUFFIX));
                }
                else if (CommonDataKinds.Note.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    contact.note = cursor.getString(cursor.getColumnIndex(CommonDataKinds.Note.NOTE));
                }
                else if (CommonDataKinds.Phone.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    String phoneNumber = cursor.getString(cursor.getColumnIndex(Phone.NUMBER));
                    if (!TextUtils.isEmpty(phoneNumber)) {
                        int type = cursor.getInt(cursor.getColumnIndex(Phone.TYPE));
                        String label = Item.getPhoneLabel(resources, type, cursor, localizedLabels);
                        contact.phones.add(new Item(label, phoneNumber, type));
                    }
                }
                else if (CommonDataKinds.Email.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    String email = cursor.getString(cursor.getColumnIndex(Email.ADDRESS));
                    int type = cursor.getInt(cursor.getColumnIndex(Email.TYPE));
                    if (!TextUtils.isEmpty(email)) {
                        String label = Item.getEmailLabel(resources, type, cursor, localizedLabels);
                        contact.emails.add(new Item(label, email, type));
                    }
                }
                else if (CommonDataKinds.Organization.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    contact.company = cursor.getString(cursor.getColumnIndex(Organization.COMPANY));
                    contact.jobTitle = cursor.getString(cursor.getColumnIndex(Organization.TITLE));
                }
                else if (CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    int type = cursor.getInt(cursor.getColumnIndex(StructuredPostal.TYPE));
                    String label = PostalAddress.getLabel(resources, type, cursor, localizedLabels);
                    String street = cursor.getString(cursor.getColumnIndex(StructuredPostal.STREET));
                    String city = cursor.getString(cursor.getColumnIndex(StructuredPostal.CITY));
                    String postcode = cursor.getString(cursor.getColumnIndex(StructuredPostal.POSTCODE));
                    String region = cursor.getString(cursor.getColumnIndex(StructuredPostal.REGION));
                    String country = cursor.getString(cursor.getColumnIndex(StructuredPostal.COUNTRY));
                    contact.postalAddresses.add(
                            new PostalAddress(label, street, city, postcode, region, country, type)
                    );
                }
                else if (CommonDataKinds.Event.CONTENT_ITEM_TYPE.equals(mimeType)) {
                    int eventType = cursor.getInt(cursor.getColumnIndex(CommonDataKinds.Event.TYPE));
                    if (eventType == CommonDataKinds.Event.TYPE_BIRTHDAY) {
                        contact.birthday = cursor.getString(cursor.getColumnIndex(CommonDataKinds.Event.START_DATE));
                    }
                }
            }
            cursor.close();
        }

        return new ArrayList<>(map.values());
    }

    private Cursor getCursor(String query, String rawContactId) {
        String selection = "(" +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.Data.MIMETYPE + "=? OR " +
                ContactsContract.RawContacts.ACCOUNT_TYPE + "=?" +
                ")";
        ArrayList<String> selectionArgs = new ArrayList<>(Arrays.asList(
                CommonDataKinds.Note.CONTENT_ITEM_TYPE,
                Email.CONTENT_ITEM_TYPE,
                Phone.CONTENT_ITEM_TYPE,
                StructuredName.CONTENT_ITEM_TYPE,
                Organization.CONTENT_ITEM_TYPE,
                StructuredPostal.CONTENT_ITEM_TYPE,
                CommonDataKinds.Event.CONTENT_ITEM_TYPE,
                ContactsContract.RawContacts.ACCOUNT_TYPE
        ));

        if (query != null) {
            // Search by DISPLAY_NAME_PRIMARY
            selection = ContactsContract.Contacts.DISPLAY_NAME_PRIMARY + " LIKE ?";
            selectionArgs.clear();
            selectionArgs.add(query + "%");
        }
        if (rawContactId != null) {
            selectionArgs.add(rawContactId);
            selection += " AND " + ContactsContract.Data.CONTACT_ID + " =?";
        }
        return contentResolver.query(
                ContactsContract.Data.CONTENT_URI,
                PROJECTION,
                selection,
                selectionArgs.toArray(new String[0]),
                null
        );
    }

    private Cursor getCursorForPhone(String phone) {
        if (phone == null || phone.isEmpty()) return null;

        Uri uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(phone)
        );
        String[] projection = new String[]{BaseColumns._ID};

        ArrayList<String> contactIds = new ArrayList<>();
        Cursor phoneCursor = contentResolver.query(uri, projection, null, null, null);
        if (phoneCursor != null) {
            while (phoneCursor.moveToNext()) {
                int idIndex = phoneCursor.getColumnIndex(BaseColumns._ID);
                if (idIndex >= 0) {
                    contactIds.add(phoneCursor.getString(idIndex));
                }
            }
            phoneCursor.close();
        }

        if (!contactIds.isEmpty()) {
            String contactIdsList = contactIds.toString().replace("[", "(").replace("]", ")");
            String contactSelection = ContactsContract.Data.CONTACT_ID + " IN " + contactIdsList;
            return contentResolver.query(
                    ContactsContract.Data.CONTENT_URI,
                    PROJECTION,
                    contactSelection,
                    null,
                    null
            );
        }
        return null;
    }

    private Cursor getCursorForEmail(String email) {
        if (email == null || email.isEmpty()) return null;
        String selection = Email.ADDRESS + " LIKE ?";
        String[] selectionArgs = new String[]{"%" + email + "%"};
        return contentResolver.query(
                ContactsContract.Data.CONTENT_URI,
                PROJECTION,
                selection,
                selectionArgs,
                null
        );
    }

    // region Working with avatar (replacement of AsyncTask)
    private void getAvatar(final Contact contact, final boolean highRes, final MethodChannel.Result result) {
        executor.execute(() -> {
            byte[] avatar = loadContactPhotoHighRes(contact.identifier, highRes, contentResolver);
            mainHandler.post(() -> result.success(avatar));
        });
    }

    private static byte[] loadContactPhotoHighRes(
            final String identifier,
            final boolean photoHighResolution,
            final ContentResolver resolver
    ) {
        try {
            if (identifier == null || identifier.isEmpty()) {
                return null;
            }
            long contactId = Long.parseLong(identifier);
            Uri uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId);
            InputStream input = ContactsContract.Contacts.openContactPhotoInputStream(
                    resolver, uri, photoHighResolution
            );
            if (input == null) return null;

            Bitmap bitmap = BitmapFactory.decodeStream(input);
            input.close();

            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte[] bytes = stream.toByteArray();
            stream.close();
            return bytes;
        } catch (IOException ex) {
            Log.e(LOG_TAG, ex.getMessage());
            return null;
        }
    }
    // endregion

    // region CRUD: addContact, deleteContact, updateContact
    private boolean addContact(Contact contact) {
        try {
            ArrayList<ContentProviderOperation> ops = new ArrayList<>();

            ContentProviderOperation.Builder op = ContentProviderOperation
                    .newInsert(ContactsContract.RawContacts.CONTENT_URI)
                    .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, null)
                    .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, null);
            ops.add(op.build());

            // Name
            op = ContentProviderOperation
                    .newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                    .withValue(StructuredName.GIVEN_NAME, contact.givenName)
                    .withValue(StructuredName.MIDDLE_NAME, contact.middleName)
                    .withValue(StructuredName.FAMILY_NAME, contact.familyName)
                    .withValue(StructuredName.PREFIX, contact.prefix)
                    .withValue(StructuredName.SUFFIX, contact.suffix);
            ops.add(op.build());

            // Note
            op = ContentProviderOperation
                    .newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Note.CONTENT_ITEM_TYPE)
                    .withValue(CommonDataKinds.Note.NOTE, contact.note);
            ops.add(op.build());

            // Organization
            op = ContentProviderOperation
                    .newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
                    .withValue(Organization.COMPANY, contact.company)
                    .withValue(Organization.TITLE, contact.jobTitle);
            ops.add(op.build());

            // Photo
            op = ContentProviderOperation
                    .newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.IS_SUPER_PRIMARY, 1)
                    .withValue(ContactsContract.CommonDataKinds.Photo.PHOTO, contact.avatar)
                    .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE);
            ops.add(op.build());
            op.withYieldAllowed(true);

            // Phones
            for (Item phone : contact.phones) {
                op = ContentProviderOperation
                        .newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                        .withValue(CommonDataKinds.Phone.NUMBER, phone.value);

                if (phone.type == CommonDataKinds.Phone.TYPE_CUSTOM) {
                    op.withValue(CommonDataKinds.Phone.TYPE, CommonDataKinds.BaseTypes.TYPE_CUSTOM);
                    op.withValue(CommonDataKinds.Phone.LABEL, phone.label);
                } else {
                    op.withValue(CommonDataKinds.Phone.TYPE, phone.type);
                }
                ops.add(op.build());
            }

            // E-mail
            for (Item email : contact.emails) {
                op = ContentProviderOperation
                        .newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Email.CONTENT_ITEM_TYPE)
                        .withValue(CommonDataKinds.Email.ADDRESS, email.value)
                        .withValue(CommonDataKinds.Email.TYPE, email.type);
                ops.add(op.build());
            }

            // Addresses
            for (PostalAddress address : contact.postalAddresses) {
                op = ContentProviderOperation
                        .newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
                        .withValue(CommonDataKinds.StructuredPostal.TYPE, address.type)
                        .withValue(CommonDataKinds.StructuredPostal.LABEL, address.label)
                        .withValue(CommonDataKinds.StructuredPostal.STREET, address.street)
                        .withValue(CommonDataKinds.StructuredPostal.CITY, address.city)
                        .withValue(CommonDataKinds.StructuredPostal.REGION, address.region)
                        .withValue(CommonDataKinds.StructuredPostal.POSTCODE, address.postcode)
                        .withValue(CommonDataKinds.StructuredPostal.COUNTRY, address.country);
                ops.add(op.build());
            }

            // Birthday
            op = ContentProviderOperation
                    .newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Event.CONTENT_ITEM_TYPE)
                    .withValue(CommonDataKinds.Event.TYPE, CommonDataKinds.Event.TYPE_BIRTHDAY)
                    .withValue(CommonDataKinds.Event.START_DATE, contact.birthday);
            ops.add(op.build());

            contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean deleteContact(Contact contact) {
        try {
            ArrayList<ContentProviderOperation> ops = new ArrayList<>();
            ops.add(ContentProviderOperation
                    .newDelete(ContactsContract.RawContacts.CONTENT_URI)
                    .withSelection(
                            ContactsContract.RawContacts.CONTACT_ID + "=?",
                            new String[]{String.valueOf(contact.identifier)}
                    )
                    .build());
            contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean updateContact(Contact contact) {
        try {
            ArrayList<ContentProviderOperation> ops = new ArrayList<>();
            ContentProviderOperation.Builder op;

            // Removed old data (except for the name)
            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.Organization.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.Phone.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.Email.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.Note.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            // Photo
            op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.Photo.CONTENT_ITEM_TYPE}
                    );
            ops.add(op.build());

            // Update name
            op = ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI)
                    .withSelection(
                            ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                            new String[]{contact.identifier, CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE}
                    )
                    .withValue(StructuredName.GIVEN_NAME, contact.givenName)
                    .withValue(StructuredName.MIDDLE_NAME, contact.middleName)
                    .withValue(StructuredName.FAMILY_NAME, contact.familyName)
                    .withValue(StructuredName.PREFIX, contact.prefix)
                    .withValue(StructuredName.SUFFIX, contact.suffix);
            ops.add(op.build());

            // Add new organization
            op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
                    .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                    .withValue(Organization.TYPE, Organization.TYPE_WORK)
                    .withValue(Organization.COMPANY, contact.company)
                    .withValue(Organization.TITLE, contact.jobTitle);
            ops.add(op.build());

            // Note
            op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Note.CONTENT_ITEM_TYPE)
                    .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                    .withValue(CommonDataKinds.Note.NOTE, contact.note);
            ops.add(op.build());

            // Photo
            op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                    .withValue(ContactsContract.Data.IS_SUPER_PRIMARY, 1)
                    .withValue(CommonDataKinds.Photo.PHOTO, contact.avatar)
                    .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Photo.CONTENT_ITEM_TYPE);
            ops.add(op.build());

            // Phone's
            for (Item phone : contact.phones) {
                op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                        .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                        .withValue(Phone.NUMBER, phone.value);

                if (phone.type == CommonDataKinds.Phone.TYPE_CUSTOM) {
                    op.withValue(CommonDataKinds.Phone.TYPE, CommonDataKinds.BaseTypes.TYPE_CUSTOM);
                    op.withValue(CommonDataKinds.Phone.LABEL, phone.label);
                } else {
                    op.withValue(CommonDataKinds.Phone.TYPE, phone.type);
                }
                ops.add(op.build());
            }

            // Email
            for (Item email : contact.emails) {
                op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Email.CONTENT_ITEM_TYPE)
                        .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                        .withValue(CommonDataKinds.Email.ADDRESS, email.value)
                        .withValue(CommonDataKinds.Email.TYPE, email.type);
                ops.add(op.build());
            }

            // Addresses
            for (PostalAddress address : contact.postalAddresses) {
                op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
                        .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
                        .withValue(CommonDataKinds.StructuredPostal.TYPE, address.type)
                        .withValue(StructuredPostal.STREET, address.street)
                        .withValue(StructuredPostal.CITY, address.city)
                        .withValue(StructuredPostal.REGION, address.region)
                        .withValue(StructuredPostal.POSTCODE, address.postcode)
                        .withValue(StructuredPostal.COUNTRY, address.country);
                ops.add(op.build());
            }

            contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
            return true;
        } catch (Exception e) {
            Log.e("TAG", "Exception encountered while updating contact: ", e);
            return false;
        }
    }
    // endregion

    // region Deleates for ActivityResult
    private class BaseContactosDelegate implements PluginRegistry.ActivityResultListener {
        private static final int REQUEST_OPEN_CONTACT_FORM = 52941;
        private static final int REQUEST_OPEN_EXISTING_CONTACT = 52942;
        private static final int REQUEST_OPEN_CONTACT_PICKER = 52943;

        private MethodChannel.Result result;
        private boolean localizedLabels;

        void setResult(MethodChannel.Result result) {
            this.result = result;
        }

        void setLocalizedLabels(boolean localizedLabels) {
            this.localizedLabels = localizedLabels;
        }

        void finishWithResult(Object value) {
            if (this.result != null) {
                this.result.success(value);
                this.result = null;
            }
        }

        @Override
        public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
            if (requestCode == REQUEST_OPEN_EXISTING_CONTACT || requestCode == REQUEST_OPEN_CONTACT_FORM) {
                try {
                    if (intent != null && intent.getData() != null) {
                        Uri ur = intent.getData();
                        finishWithResult(getContactByIdentifier(ur.getLastPathSegment()));
                    } else {
                        finishWithResult(FORM_OPERATION_CANCELED);
                    }
                } catch (NullPointerException e) {
                    finishWithResult(FORM_OPERATION_CANCELED);
                }
                return true;
            }

            if (requestCode == REQUEST_OPEN_CONTACT_PICKER) {
                if (resultCode == RESULT_CANCELED) {
                    finishWithResult(FORM_OPERATION_CANCELED);
                    return true;
                }
                if (intent == null) {
                    finishWithResult(FORM_COULD_NOT_BE_OPEN);
                    return true;
                }
                Uri contactUri = intent.getData();
                if (contactUri == null) {
                    finishWithResult(FORM_COULD_NOT_BE_OPEN);
                    return true;
                }
                Cursor cursor = contentResolver.query(contactUri, null, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    String id = contactUri.getLastPathSegment();
                    getContacts("openDeviceContactPicker", id, false, false, false, this.localizedLabels, this.result);
                } else {
                    Log.e(LOG_TAG, "onActivityResult: cursor.moveToFirst() == false");
                    finishWithResult(FORM_OPERATION_CANCELED);
                }
                if (cursor != null) cursor.close();
                return true;
            }

            finishWithResult(FORM_COULD_NOT_BE_OPEN);
            return false;
        }

        void openExistingContact(Contact contact) {
            String identifier = contact.identifier;
            try {
                HashMap contactMapFromDevice = getContactByIdentifier(identifier);
                if (contactMapFromDevice != null) {
                    Uri uri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, identifier);
                    Intent intent = new Intent(Intent.ACTION_EDIT);
                    intent.setDataAndType(uri, ContactsContract.Contacts.CONTENT_ITEM_TYPE);
                    intent.putExtra("finishActivityOnSaveCompleted", true);
                    startIntent(intent, REQUEST_OPEN_EXISTING_CONTACT);
                } else {
                    finishWithResult(FORM_COULD_NOT_BE_OPEN);
                }
            } catch (Exception e) {
                finishWithResult(FORM_COULD_NOT_BE_OPEN);
            }
        }

        void openContactForm() {
            try {
                Intent intent = new Intent(Intent.ACTION_INSERT, ContactsContract.Contacts.CONTENT_URI);
                intent.putExtra("finishActivityOnSaveCompleted", true);
                startIntent(intent, REQUEST_OPEN_CONTACT_FORM);
            } catch (Exception e) {
                finishWithResult(FORM_COULD_NOT_BE_OPEN);
            }
        }

        void openContactPicker() {
            Intent intent = new Intent(Intent.ACTION_PICK);
            intent.setType(ContactsContract.Contacts.CONTENT_TYPE);
            startIntent(intent, REQUEST_OPEN_CONTACT_PICKER);
        }

        void startIntent(Intent intent, int request) {
            // Overridden in the successor ContactosDelegate
        }

        HashMap getContactByIdentifier(String identifier) {
            Cursor cursor = contentResolver.query(
                    ContactsContract.Data.CONTENT_URI,
                    PROJECTION,
                    ContactsContract.RawContacts.CONTACT_ID + " = ?",
                    new String[]{identifier},
                    null
            );
            ArrayList<Contact> matchingContacts;
            try {
                matchingContacts = getContactsFrom(cursor, localizedLabels);
            } finally {
                if (cursor != null) cursor.close();
            }
            if (!matchingContacts.isEmpty()) {
                return matchingContacts.get(0).toMap();
            }
            return null;
        }
    }

    private class ContactosDelegate extends BaseContactosDelegate {
        private final Context context;
        private ActivityPluginBinding activityPluginBinding;

        ContactosDelegate(Context context) {
            this.context = context;
        }

        void bindToActivity(ActivityPluginBinding binding) {
            this.activityPluginBinding = binding;
            this.activityPluginBinding.addActivityResultListener(this);
        }

        void unbindActivity() {
            if (this.activityPluginBinding != null) {
                this.activityPluginBinding.removeActivityResultListener(this);
            }
            this.activityPluginBinding = null;
        }

        @Override
        void startIntent(Intent intent, int request) {
            if (this.activityPluginBinding != null) {
                if (intent.resolveActivity(context.getPackageManager()) != null) {
                    this.activityPluginBinding.getActivity().startActivityForResult(intent, request);
                } else {
                    finishWithResult(FORM_COULD_NOT_BE_OPEN);
                }
            } else {
                context.startActivity(intent);
            }
        }
    }
    // endregion
}