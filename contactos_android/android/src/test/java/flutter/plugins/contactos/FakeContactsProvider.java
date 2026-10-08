// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

package flutter.plugins.contactos;

import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

/** In-memory replacement of the contacts provider for JVM tests. */
public class FakeContactsProvider extends ContentProvider {

  /** A recorded {@link #query} call. */
  static final class Query {
    final Uri uri;
    final String selection;
    final String[] selectionArgs;

    Query(Uri uri, String selection, String[] selectionArgs) {
      this.uri = uri;
      this.selection = selection;
      this.selectionArgs = selectionArgs;
    }
  }

  /** A recorded insert, update or delete. */
  static final class Write {
    final String kind;
    final Uri uri;
    final ContentValues values;
    final String selection;
    final String[] selectionArgs;

    Write(String kind, Uri uri, ContentValues values, String selection, String[] selectionArgs) {
      this.kind = kind;
      this.uri = uri;
      this.values = values;
      this.selection = selection;
      this.selectionArgs = selectionArgs;
    }
  }

  /** Rows returned for {@link ContactsContract.Data#CONTENT_URI} queries. */
  final List<ContentValues> dataRows = new ArrayList<>();

  /** Contact ids returned for phone lookups. */
  final List<String> phoneLookupIds = new ArrayList<>();

  final List<Query> queries = new ArrayList<>();
  final List<Write> writes = new ArrayList<>();
  final List<Integer> batchSizes = new ArrayList<>();

  /** When set, {@link #applyBatch} fails like a provider without permission. */
  boolean failBatches;

  /** Display photo bytes per contact id. */
  final Map<String, byte[]> displayPhotos = new java.util.HashMap<>();

  private long nextId = 100;

  @Override
  public boolean onCreate() {
    return true;
  }

  @Override
  public Cursor query(
      Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
    queries.add(new Query(uri, selection, selectionArgs));
    if (selectionArgs != null) {
      for (String argument : selectionArgs) {
        // SQLite rejects null bind values like the real contacts provider.
        if (argument == null) {
          throw new IllegalArgumentException("the bind value is null");
        }
      }
    }

    if (isPhoneLookup(uri)) {
      MatrixCursor cursor = new MatrixCursor(new String[] {BaseColumns._ID});
      for (String id : phoneLookupIds) {
        cursor.addRow(new Object[] {id});
      }
      return cursor;
    }

    if (ContactsContract.Data.CONTENT_URI.equals(uri)) {
      return dataCursor(projection);
    }

    if (isContactUri(uri)) {
      String id = uri.getLastPathSegment();
      MatrixCursor cursor = new MatrixCursor(new String[] {BaseColumns._ID});
      for (ContentValues row : dataRows) {
        if (id.equals(row.getAsString(ContactsContract.Data.CONTACT_ID))) {
          cursor.addRow(new Object[] {id});
          break;
        }
      }
      return cursor;
    }

    // Photos and any other content: nothing stored.
    return new MatrixCursor(projection != null ? projection : new String[] {BaseColumns._ID});
  }

  private Cursor dataCursor(String[] projection) {
    // Contacts columns alias each other (data1, data2...), keep each name once.
    String[] columns = new LinkedHashSet<>(java.util.Arrays.asList(projection)).toArray(new String[0]);
    MatrixCursor cursor = new MatrixCursor(columns);
    for (ContentValues row : dataRows) {
      Object[] values = new Object[columns.length];
      for (int i = 0; i < columns.length; i++) {
        values[i] = row.get(columns[i]);
      }
      cursor.addRow(values);
    }
    return cursor;
  }

  private static boolean isPhoneLookup(Uri uri) {
    String prefix = ContactsContract.PhoneLookup.CONTENT_FILTER_URI.toString();
    return uri.toString().startsWith(prefix);
  }

  private static boolean isContactUri(Uri uri) {
    List<String> segments = uri.getPathSegments();
    return ContactsContract.AUTHORITY.equals(uri.getAuthority())
        && segments.size() == 2
        && "contacts".equals(segments.get(0));
  }

  @Override
  public ContentProviderResult[] applyBatch(ArrayList<ContentProviderOperation> operations)
      throws android.content.OperationApplicationException {
    if (failBatches) {
      throw new SecurityException("Permission denial: WRITE_CONTACTS");
    }
    batchSizes.add(operations.size());
    return super.applyBatch(operations);
  }

  @Override
  public Uri insert(Uri uri, ContentValues values) {
    writes.add(new Write("insert", uri, values, null, null));
    return Uri.withAppendedPath(uri, String.valueOf(nextId++));
  }

  @Override
  public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
    writes.add(new Write("update", uri, values, selection, selectionArgs));
    return 1;
  }

  @Override
  public int delete(Uri uri, String selection, String[] selectionArgs) {
    writes.add(new Write("delete", uri, null, selection, selectionArgs));
    return 1;
  }

  @Override
  public android.os.ParcelFileDescriptor openFile(Uri uri, String mode)
      throws java.io.FileNotFoundException {
    // content://com.android.contacts/contacts/<id>/display_photo
    List<String> segments = uri.getPathSegments();
    if (segments.size() == 3 && "display_photo".equals(segments.get(2))) {
      byte[] photo = displayPhotos.get(segments.get(1));
      if (photo != null) {
        try {
          java.io.File file = java.io.File.createTempFile("photo", ".png");
          java.nio.file.Files.write(file.toPath(), photo);
          return android.os.ParcelFileDescriptor.open(
              file, android.os.ParcelFileDescriptor.MODE_READ_ONLY);
        } catch (java.io.IOException e) {
          throw new java.io.FileNotFoundException(e.getMessage());
        }
      }
    }
    throw new java.io.FileNotFoundException(uri.toString());
  }

  @Override
  public String getType(Uri uri) {
    return null;
  }

  /** Creates a data row of the given contact. */
  static ContentValues row(String contactId, String displayName, String mimeType, Map<String, Object> data) {
    ContentValues values = new ContentValues();
    values.put(ContactsContract.Data.CONTACT_ID, contactId);
    values.put(ContactsContract.Contacts.DISPLAY_NAME, displayName);
    values.put(ContactsContract.Data.MIMETYPE, mimeType);
    values.put(ContactsContract.RawContacts.ACCOUNT_TYPE, "com.google");
    values.put(ContactsContract.RawContacts.ACCOUNT_NAME, "john@gmail.com");
    for (Map.Entry<String, Object> entry : data.entrySet()) {
      Object value = entry.getValue();
      if (value instanceof Integer) {
        values.put(entry.getKey(), (Integer) value);
      } else {
        values.put(entry.getKey(), value == null ? null : value.toString());
      }
    }
    return values;
  }
}
