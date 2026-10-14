// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

package flutter.plugins.contactos;

import static android.provider.ContactsContract.CommonDataKinds.Email;
import static android.provider.ContactsContract.CommonDataKinds.Phone;
import static com.google.common.truth.Truth.assertThat;

import android.content.res.Resources;
import android.database.MatrixCursor;
import java.util.HashMap;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;

@RunWith(RobolectricTestRunner.class)
public class ItemTest {

  private static MatrixCursor labelCursor(String column, String label) {
    MatrixCursor cursor = new MatrixCursor(new String[] {column});
    cursor.addRow(new Object[] {label});
    cursor.moveToFirst();
    return cursor;
  }

  private static Resources resources() {
    return RuntimeEnvironment.getApplication().getResources();
  }

  @Test
  public void toMap_containsAllFields() {
    Item item = new Item("work", "john@example.com", Email.TYPE_WORK);

    HashMap<String, String> map = item.toMap();

    assertThat(map).containsExactly(
        "label", "work",
        "value", "john@example.com",
        "type", String.valueOf(Email.TYPE_WORK));
  }

  @Test
  public void fromMap_restoresAllFields() {
    HashMap<String, String> map = new HashMap<>();
    map.put("label", "mobile");
    map.put("value", "+1 555 0100");
    map.put("type", String.valueOf(Phone.TYPE_MOBILE));

    Item item = Item.fromMap(map);

    assertThat(item.label).isEqualTo("mobile");
    assertThat(item.value).isEqualTo("+1 555 0100");
    assertThat(item.type).isEqualTo(Phone.TYPE_MOBILE);
  }

  @Test
  public void fromMap_withoutType_usesMinusOne() {
    HashMap<String, String> map = new HashMap<>();
    map.put("label", "home");
    map.put("value", "+1 555 0101");

    assertThat(Item.fromMap(map).type).isEqualTo(-1);
  }

  @Test
  public void toMap_fromMap_roundTrip() {
    Item original = new Item("home", "+1 555 0102", Phone.TYPE_HOME);

    Item restored = Item.fromMap(original.toMap());

    assertThat(restored.label).isEqualTo(original.label);
    assertThat(restored.value).isEqualTo(original.value);
    assertThat(restored.type).isEqualTo(original.type);
  }

  @Test
  public void getPhoneLabel_notLocalized_mapsKnownTypes() {
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_HOME, null, false)).isEqualTo("home");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_WORK, null, false)).isEqualTo("work");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_MOBILE, null, false)).isEqualTo("mobile");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_FAX_WORK, null, false)).isEqualTo("fax work");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_FAX_HOME, null, false)).isEqualTo("fax home");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_MAIN, null, false)).isEqualTo("main");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_COMPANY_MAIN, null, false)).isEqualTo("company");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_PAGER, null, false)).isEqualTo("pager");
    assertThat(Item.getPhoneLabel(null, Phone.TYPE_OTHER, null, false)).isEqualTo("other");
  }

  @Test
  public void getPhoneLabel_customType_usesLowercasedCursorLabel() {
    MatrixCursor cursor = labelCursor(Phone.LABEL, "Dacha");

    assertThat(Item.getPhoneLabel(null, Phone.TYPE_CUSTOM, cursor, false)).isEqualTo("dacha");
  }

  @Test
  public void getPhoneLabel_customTypeWithoutLabel_isEmpty() {
    MatrixCursor cursor = labelCursor(Phone.LABEL, null);

    assertThat(Item.getPhoneLabel(null, Phone.TYPE_CUSTOM, cursor, false)).isEmpty();
  }

  @Test
  public void getPhoneLabel_localized_usesSystemLabel() {
    String expected = Phone.getTypeLabel(resources(), Phone.TYPE_MOBILE, "").toString().toLowerCase();

    assertThat(Item.getPhoneLabel(resources(), Phone.TYPE_MOBILE, null, true)).isEqualTo(expected);
  }

  @Test
  public void getEmailLabel_notLocalized_mapsKnownTypes() {
    assertThat(Item.getEmailLabel(null, Email.TYPE_HOME, null, false)).isEqualTo("home");
    assertThat(Item.getEmailLabel(null, Email.TYPE_WORK, null, false)).isEqualTo("work");
    assertThat(Item.getEmailLabel(null, Email.TYPE_MOBILE, null, false)).isEqualTo("mobile");
    assertThat(Item.getEmailLabel(null, Email.TYPE_OTHER, null, false)).isEqualTo("other");
  }

  @Test
  public void getEmailLabel_customType_usesLowercasedCursorLabel() {
    MatrixCursor cursor = labelCursor(Email.LABEL, "Personal");

    assertThat(Item.getEmailLabel(null, Email.TYPE_CUSTOM, cursor, false)).isEqualTo("personal");
  }

  @Test
  public void getEmailLabel_customTypeWithoutLabel_isEmpty() {
    MatrixCursor cursor = labelCursor(Email.LABEL, null);

    assertThat(Item.getEmailLabel(null, Email.TYPE_CUSTOM, cursor, false)).isEmpty();
  }

  @Test
  public void getEmailLabel_localized_usesSystemLabel() {
    String expected = Email.getTypeLabel(resources(), Email.TYPE_WORK, "").toString().toLowerCase();

    assertThat(Item.getEmailLabel(resources(), Email.TYPE_WORK, null, true)).isEqualTo(expected);
  }
}
