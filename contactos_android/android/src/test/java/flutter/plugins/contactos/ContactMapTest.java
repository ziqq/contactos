// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

package flutter.plugins.contactos;

import static com.google.common.truth.Truth.assertThat;

import java.util.ArrayList;
import java.util.HashMap;
import org.junit.Test;

public class ContactMapTest {

  private static Contact contact() {
    Contact contact = new Contact("42");
    contact.displayName = "John Doe";
    contact.givenName = "John";
    contact.middleName = "Q";
    contact.familyName = "Doe";
    contact.prefix = "Mr";
    contact.suffix = "Jr";
    contact.company = "Acme";
    contact.jobTitle = "Engineer";
    contact.note = "note";
    contact.birthday = "1990-01-02";
    contact.androidAccountType = "com.google";
    contact.androidAccountName = "john@example.com";
    contact.avatar = new byte[] {1, 2, 3};
    contact.emails.add(new Item("work", "john@example.com", 2));
    contact.phones.add(new Item("mobile", "+1 555 0100", 2));
    contact.postalAddresses.add(
        new PostalAddress("home", "1 Main St", "Springfield", "12345", "IL", "USA", 1));
    return contact;
  }

  @Test
  public void toMap_containsScalarFields() {
    HashMap<String, Object> map = contact().toMap();

    assertThat(map).containsEntry("identifier", "42");
    assertThat(map).containsEntry("displayName", "John Doe");
    assertThat(map).containsEntry("givenName", "John");
    assertThat(map).containsEntry("middleName", "Q");
    assertThat(map).containsEntry("familyName", "Doe");
    assertThat(map).containsEntry("prefix", "Mr");
    assertThat(map).containsEntry("suffix", "Jr");
    assertThat(map).containsEntry("company", "Acme");
    assertThat(map).containsEntry("jobTitle", "Engineer");
    assertThat(map).containsEntry("note", "note");
    assertThat(map).containsEntry("birthday", "1990-01-02");
    assertThat(map).containsEntry("androidAccountType", "com.google");
    assertThat(map).containsEntry("androidAccountName", "john@example.com");
    assertThat((byte[]) map.get("avatar")).isEqualTo(new byte[] {1, 2, 3});
  }

  @Test
  public void toMap_serializesCollections() {
    HashMap<String, Object> map = contact().toMap();

    assertThat((ArrayList<?>) map.get("emails")).hasSize(1);
    assertThat((ArrayList<?>) map.get("phones")).hasSize(1);
    assertThat((ArrayList<?>) map.get("postalAddresses")).hasSize(1);
  }

  @Test
  public void toMap_withoutCollections_returnsEmptyLists() {
    HashMap<String, Object> map = new Contact("1").toMap();

    assertThat((ArrayList<?>) map.get("emails")).isEmpty();
    assertThat((ArrayList<?>) map.get("phones")).isEmpty();
    assertThat((ArrayList<?>) map.get("postalAddresses")).isEmpty();
  }

  @Test
  public void fromMap_restoresFieldsAndCollections() {
    Contact original = contact();

    Contact restored = Contact.fromMap(original.toMap());

    assertThat(restored.identifier).isEqualTo(original.identifier);
    assertThat(restored.givenName).isEqualTo(original.givenName);
    assertThat(restored.middleName).isEqualTo(original.middleName);
    assertThat(restored.familyName).isEqualTo(original.familyName);
    assertThat(restored.prefix).isEqualTo(original.prefix);
    assertThat(restored.suffix).isEqualTo(original.suffix);
    assertThat(restored.company).isEqualTo(original.company);
    assertThat(restored.jobTitle).isEqualTo(original.jobTitle);
    assertThat(restored.note).isEqualTo(original.note);
    assertThat(restored.birthday).isEqualTo(original.birthday);
    assertThat(restored.androidAccountType).isEqualTo(original.androidAccountType);
    assertThat(restored.androidAccountName).isEqualTo(original.androidAccountName);
    assertThat(restored.avatar).isEqualTo(original.avatar);
    assertThat(restored.emails).hasSize(1);
    assertThat(restored.emails.get(0).value).isEqualTo("john@example.com");
    assertThat(restored.phones).hasSize(1);
    assertThat(restored.phones.get(0).value).isEqualTo("+1 555 0100");
    assertThat(restored.postalAddresses).hasSize(1);
    assertThat(restored.postalAddresses.get(0).city).isEqualTo("Springfield");
  }

  @Test
  public void fromMap_withoutCollections_keepsEmptyLists() {
    HashMap<String, Object> map = new HashMap<>();
    map.put("identifier", "7");

    Contact contact = Contact.fromMap(map);

    assertThat(contact.identifier).isEqualTo("7");
    assertThat(contact.emails).isEmpty();
    assertThat(contact.phones).isEmpty();
    assertThat(contact.postalAddresses).isEmpty();
  }
}
