// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

package flutter.plugins.contactos;

import static android.provider.ContactsContract.CommonDataKinds.StructuredPostal;
import static com.google.common.truth.Truth.assertThat;

import android.content.res.Resources;
import android.database.MatrixCursor;
import java.util.HashMap;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;

@RunWith(RobolectricTestRunner.class)
public class PostalAddressTest {

  private static MatrixCursor typeCursor(int type, String label) {
    MatrixCursor cursor =
        new MatrixCursor(new String[] {StructuredPostal.TYPE, StructuredPostal.LABEL});
    cursor.addRow(new Object[] {type, label});
    cursor.moveToFirst();
    return cursor;
  }

  private static PostalAddress address() {
    return new PostalAddress(
        "home", "1 Main St", "Springfield", "12345", "IL", "USA", StructuredPostal.TYPE_HOME);
  }

  @Test
  public void toMap_containsAllFields() {
    HashMap<String, String> map = address().toMap();

    assertThat(map).containsExactly(
        "label", "home",
        "street", "1 Main St",
        "city", "Springfield",
        "postcode", "12345",
        "region", "IL",
        "country", "USA",
        "type", String.valueOf(StructuredPostal.TYPE_HOME));
  }

  @Test
  public void toMap_fromMap_roundTrip() {
    PostalAddress original = address();

    PostalAddress restored = PostalAddress.fromMap(original.toMap());

    assertThat(restored.label).isEqualTo(original.label);
    assertThat(restored.street).isEqualTo(original.street);
    assertThat(restored.city).isEqualTo(original.city);
    assertThat(restored.postcode).isEqualTo(original.postcode);
    assertThat(restored.region).isEqualTo(original.region);
    assertThat(restored.country).isEqualTo(original.country);
    assertThat(restored.type).isEqualTo(original.type);
  }

  @Test
  public void fromMap_withoutType_usesMinusOne() {
    HashMap<String, String> map = new HashMap<>();
    map.put("label", "work");

    assertThat(PostalAddress.fromMap(map).type).isEqualTo(-1);
  }

  @Test
  public void getLabel_notLocalized_readsTypeFromCursor() {
    assertThat(PostalAddress.getLabel(null, 0, typeCursor(StructuredPostal.TYPE_HOME, null), false))
        .isEqualTo("home");
    assertThat(PostalAddress.getLabel(null, 0, typeCursor(StructuredPostal.TYPE_WORK, null), false))
        .isEqualTo("work");
    assertThat(PostalAddress.getLabel(null, 0, typeCursor(StructuredPostal.TYPE_OTHER, null), false))
        .isEqualTo("other");
  }

  @Test
  public void getLabel_customType_usesCursorLabelAsIs() {
    MatrixCursor cursor = typeCursor(StructuredPostal.TYPE_CUSTOM, "Cottage");

    assertThat(PostalAddress.getLabel(null, 0, cursor, false)).isEqualTo("Cottage");
  }

  @Test
  public void getLabel_customTypeWithoutLabel_isEmpty() {
    MatrixCursor cursor = typeCursor(StructuredPostal.TYPE_CUSTOM, null);

    assertThat(PostalAddress.getLabel(null, 0, cursor, false)).isEmpty();
  }

  @Test
  public void getLabel_localized_usesSystemLabel() {
    Resources resources = RuntimeEnvironment.getApplication().getResources();
    String expected =
        StructuredPostal.getTypeLabel(resources, StructuredPostal.TYPE_WORK, "")
            .toString()
            .toLowerCase();

    assertThat(PostalAddress.getLabel(resources, StructuredPostal.TYPE_WORK, null, true))
        .isEqualTo(expected);
  }
}
