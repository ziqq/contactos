// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

package flutter.plugins.contactos;

import static android.provider.ContactsContract.CommonDataKinds.Email;
import static android.provider.ContactsContract.CommonDataKinds.Event;
import static android.provider.ContactsContract.CommonDataKinds.Note;
import static android.provider.ContactsContract.CommonDataKinds.Organization;
import static android.provider.ContactsContract.CommonDataKinds.Phone;
import static android.provider.ContactsContract.CommonDataKinds.StructuredName;
import static android.provider.ContactsContract.CommonDataKinds.StructuredPostal;
import static com.google.common.truth.Truth.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.robolectric.Shadows.shadowOf;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Looper;
import android.provider.ContactsContract;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.shadows.ShadowActivity;

@RunWith(RobolectricTestRunner.class)
public class ContactosPluginTest {

  /** Records the reply of a method call. */
  private static final class RecordingResult implements MethodChannel.Result {
    boolean done;
    boolean notImplemented;
    Object value;
    String errorMessage;

    @Override
    public void success(Object result) {
      done = true;
      value = result;
    }

    @Override
    public void error(String errorCode, String errorMessage, Object errorDetails) {
      done = true;
      this.errorMessage = errorMessage;
    }

    @Override
    public void notImplemented() {
      done = true;
      notImplemented = true;
    }
  }

  private FakeContactsProvider provider;
  private ContactosPlugin plugin;
  private FlutterPlugin.FlutterPluginBinding engineBinding;

  @Before
  public void setUp() {
    provider =
        Robolectric.setupContentProvider(FakeContactsProvider.class, ContactsContract.AUTHORITY);
    engineBinding = mock(FlutterPlugin.FlutterPluginBinding.class);
    when(engineBinding.getApplicationContext()).thenReturn(RuntimeEnvironment.getApplication());
    when(engineBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    plugin = new ContactosPlugin();
    plugin.onAttachedToEngine(engineBinding);
  }

  @After
  public void tearDown() {
    plugin.onDetachedFromEngine(engineBinding);
  }

  // region Helpers

  private RecordingResult call(String method, Object arguments) {
    RecordingResult result = new RecordingResult();
    plugin.onMethodCall(new MethodCall(method, arguments), result);
    // Queries run on a background executor and reply on the main looper.
    for (int i = 0; i < 500 && !result.done; i++) {
      shadowOf(Looper.getMainLooper()).idle();
      if (!result.done) {
        try {
          Thread.sleep(10);
        } catch (InterruptedException e) {
          throw new AssertionError(e);
        }
      }
    }
    assertThat(result.done).isTrue();
    return result;
  }

  private static HashMap<String, Object> queryArguments(String key, String value) {
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put(key, value);
    arguments.put("withThumbnails", false);
    arguments.put("photoHighResolution", false);
    arguments.put("orderByGivenName", true);
    arguments.put("androidLocalizedLabels", false);
    return arguments;
  }

  private static Map<String, Object> data(Object... keyValues) {
    Map<String, Object> map = new HashMap<>();
    for (int i = 0; i < keyValues.length; i += 2) {
      map.put((String) keyValues[i], keyValues[i + 1]);
    }
    return map;
  }

  private void addJohnDoe() {
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            StructuredName.CONTENT_ITEM_TYPE,
            data(
                StructuredName.GIVEN_NAME, "John",
                StructuredName.MIDDLE_NAME, "Q",
                StructuredName.FAMILY_NAME, "Doe",
                StructuredName.PREFIX, "Mr",
                StructuredName.SUFFIX, "Jr")));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            Phone.CONTENT_ITEM_TYPE,
            data(Phone.NUMBER, "+1 555 0100", Phone.TYPE, Phone.TYPE_MOBILE)));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            Phone.CONTENT_ITEM_TYPE,
            data(Phone.NUMBER, "", Phone.TYPE, Phone.TYPE_HOME)));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            Email.CONTENT_ITEM_TYPE,
            data(Email.ADDRESS, "john@example.com", Email.TYPE, Email.TYPE_WORK)));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            Organization.CONTENT_ITEM_TYPE,
            data(Organization.COMPANY, "Acme", Organization.TITLE, "Engineer")));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            StructuredPostal.CONTENT_ITEM_TYPE,
            data(
                StructuredPostal.TYPE, StructuredPostal.TYPE_HOME,
                StructuredPostal.STREET, "1 Main St",
                StructuredPostal.CITY, "Springfield",
                StructuredPostal.POSTCODE, "12345",
                StructuredPostal.REGION, "IL",
                StructuredPostal.COUNTRY, "USA")));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1", "John Doe", Note.CONTENT_ITEM_TYPE, data(Note.NOTE, "Met at a conference")));
    provider.dataRows.add(
        FakeContactsProvider.row(
            "1",
            "John Doe",
            Event.CONTENT_ITEM_TYPE,
            data(Event.TYPE, Event.TYPE_BIRTHDAY, Event.START_DATE, "1990-01-02")));
  }

  private void addAlice() {
    provider.dataRows.add(
        FakeContactsProvider.row(
            "2",
            "Alice Smith",
            StructuredName.CONTENT_ITEM_TYPE,
            data(StructuredName.GIVEN_NAME, "Alice", StructuredName.FAMILY_NAME, "Smith")));
  }

  @SuppressWarnings("unchecked")
  private static List<Map<String, Object>> contacts(RecordingResult result) {
    return (List<Map<String, Object>>) result.value;
  }

  private static HashMap<String, Object> contactArguments(String identifier) {
    HashMap<String, Object> contact = new HashMap<>();
    contact.put("identifier", identifier);
    contact.put("givenName", "John");
    contact.put("middleName", "Q");
    contact.put("familyName", "Doe");
    contact.put("company", "Acme");
    contact.put("jobTitle", "Engineer");
    contact.put("note", "note");
    contact.put("birthday", "1990-01-02");
    contact.put("avatar", new byte[0]);
    ArrayList<HashMap<String, String>> phones = new ArrayList<>();
    HashMap<String, String> phone = new HashMap<>();
    phone.put("label", "mobile");
    phone.put("value", "+1 555 0100");
    phone.put("type", String.valueOf(Phone.TYPE_MOBILE));
    phones.add(phone);
    HashMap<String, String> custom = new HashMap<>();
    custom.put("label", "dacha");
    custom.put("value", "+1 555 0101");
    custom.put("type", String.valueOf(Phone.TYPE_CUSTOM));
    phones.add(custom);
    contact.put("phones", phones);
    ArrayList<HashMap<String, String>> emails = new ArrayList<>();
    HashMap<String, String> email = new HashMap<>();
    email.put("label", "work");
    email.put("value", "john@example.com");
    email.put("type", String.valueOf(Email.TYPE_WORK));
    emails.add(email);
    contact.put("emails", emails);
    ArrayList<HashMap<String, String>> addresses = new ArrayList<>();
    HashMap<String, String> address = new HashMap<>();
    address.put("label", "home");
    address.put("street", "1 Main St");
    address.put("city", "Springfield");
    address.put("type", String.valueOf(StructuredPostal.TYPE_HOME));
    addresses.add(address);
    contact.put("postalAddresses", addresses);
    return contact;
  }

  private List<FakeContactsProvider.Write> writes(String kind, String mimeType) {
    List<FakeContactsProvider.Write> matching = new ArrayList<>();
    for (FakeContactsProvider.Write write : provider.writes) {
      if (!write.kind.equals(kind)) continue;
      String writeMimeType =
          write.values != null
              ? write.values.getAsString(ContactsContract.Data.MIMETYPE)
              : (write.selectionArgs != null && write.selectionArgs.length > 1
                  ? write.selectionArgs[1]
                  : null);
      if (mimeType == null || mimeType.equals(writeMimeType)) matching.add(write);
    }
    return matching;
  }

  private ActivityPluginBinding attachActivity(Activity activity) {
    ActivityPluginBinding binding = mock(ActivityPluginBinding.class);
    when(binding.getActivity()).thenReturn(activity);
    plugin.onAttachedToActivity(binding);
    return binding;
  }

  private PluginRegistry.ActivityResultListener activityResultListener(
      ActivityPluginBinding binding) {
    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(binding).addActivityResultListener(captor.capture());
    return captor.getValue();
  }

  private static void registerHandler(Intent intent) {
    ResolveInfo info = new ResolveInfo();
    info.activityInfo = new ActivityInfo();
    info.activityInfo.packageName = "com.android.contacts";
    info.activityInfo.name = "ContactEditor";
    shadowOf(RuntimeEnvironment.getApplication().getPackageManager())
        .addResolveInfoForIntent(intent, info);
    shadowOf(RuntimeEnvironment.getApplication().getPackageManager())
        .addOrUpdateActivity(info.activityInfo);
  }

  // endregion

  // region Reading contacts

  @Test
  public void getContacts_mapsEveryDataKindOfAContact() {
    addJohnDoe();

    RecordingResult result = call("getContacts", queryArguments("query", null));

    List<Map<String, Object>> contacts = contacts(result);
    assertThat(contacts).hasSize(1);
    Map<String, Object> john = contacts.get(0);
    assertThat(john).containsEntry("identifier", "1");
    assertThat(john).containsEntry("displayName", "John Doe");
    assertThat(john).containsEntry("givenName", "John");
    assertThat(john).containsEntry("middleName", "Q");
    assertThat(john).containsEntry("familyName", "Doe");
    assertThat(john).containsEntry("prefix", "Mr");
    assertThat(john).containsEntry("suffix", "Jr");
    assertThat(john).containsEntry("company", "Acme");
    assertThat(john).containsEntry("jobTitle", "Engineer");
    assertThat(john).containsEntry("note", "Met at a conference");
    assertThat(john).containsEntry("birthday", "1990-01-02");
    assertThat(john).containsEntry("androidAccountType", "com.google");
    assertThat(john).containsEntry("androidAccountName", "john@gmail.com");

    // The phone row with an empty number is skipped.
    assertThat((List<?>) john.get("phones")).hasSize(1);
    Map<?, ?> phone = (Map<?, ?>) ((List<?>) john.get("phones")).get(0);
    assertThat(phone.get("label")).isEqualTo("mobile");
    assertThat(phone.get("value")).isEqualTo("+1 555 0100");

    Map<?, ?> email = (Map<?, ?>) ((List<?>) john.get("emails")).get(0);
    assertThat(email.get("label")).isEqualTo("work");
    assertThat(email.get("value")).isEqualTo("john@example.com");

    Map<?, ?> address = (Map<?, ?>) ((List<?>) john.get("postalAddresses")).get(0);
    assertThat(address.get("label")).isEqualTo("home");
    assertThat(address.get("street")).isEqualTo("1 Main St");
    assertThat(address.get("city")).isEqualTo("Springfield");
    assertThat(address.get("postcode")).isEqualTo("12345");
    assertThat(address.get("region")).isEqualTo("IL");
    assertThat(address.get("country")).isEqualTo("USA");
  }

  @Test
  public void getContacts_ordersByGivenName() {
    addJohnDoe();
    addAlice();

    List<Map<String, Object>> contacts =
        contacts(call("getContacts", queryArguments("query", null)));

    assertThat(contacts).hasSize(2);
    assertThat(contacts.get(0).get("givenName")).isEqualTo("Alice");
    assertThat(contacts.get(1).get("givenName")).isEqualTo("John");
  }

  @Test
  public void getContacts_keepsProviderOrderWhenNotSorting() {
    addJohnDoe();
    addAlice();
    HashMap<String, Object> arguments = queryArguments("query", null);
    arguments.put("orderByGivenName", false);

    List<Map<String, Object>> contacts = contacts(call("getContacts", arguments));

    assertThat(contacts.get(0).get("givenName")).isEqualTo("John");
    assertThat(contacts.get(1).get("givenName")).isEqualTo("Alice");
  }

  @Test
  public void getContacts_withQuery_filtersByDisplayNamePrefix() {
    call("getContacts", queryArguments("query", "jo"));

    FakeContactsProvider.Query query = provider.queries.get(0);
    assertThat(query.uri).isEqualTo(ContactsContract.Data.CONTENT_URI);
    assertThat(query.selection)
        .isEqualTo(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY + " LIKE ?");
    assertThat(query.selectionArgs).asList().containsExactly("jo%");
  }

  @Test
  public void getContacts_withThumbnails_returnsEmptyAvatarWithoutPhoto() {
    addJohnDoe();
    HashMap<String, Object> arguments = queryArguments("query", null);
    arguments.put("withThumbnails", true);

    List<Map<String, Object>> contacts = contacts(call("getContacts", arguments));

    assertThat((byte[]) contacts.get(0).get("avatar")).isEmpty();
  }

  @Test
  public void getContactsForEmail_filtersByAddress() {
    addJohnDoe();

    List<Map<String, Object>> contacts =
        contacts(call("getContactsForEmail", queryArguments("email", "john@")));

    assertThat(contacts).hasSize(1);
    FakeContactsProvider.Query query = provider.queries.get(0);
    assertThat(query.selection).isEqualTo(Email.ADDRESS + " LIKE ?");
    assertThat(query.selectionArgs).asList().containsExactly("%john@%");
  }

  @Test
  public void getContactsForEmail_withEmptyEmail_returnsNoContacts() {
    List<Map<String, Object>> contacts =
        contacts(call("getContactsForEmail", queryArguments("email", "")));

    assertThat(contacts).isEmpty();
    assertThat(provider.queries).isEmpty();
  }

  @Test
  public void getContactsForPhone_looksUpIdsThenLoadsContacts() {
    addJohnDoe();
    provider.phoneLookupIds.add("1");

    List<Map<String, Object>> contacts =
        contacts(call("getContactsForPhone", queryArguments("phone", "+1 555 0100")));

    assertThat(contacts).hasSize(1);
    assertThat(provider.queries).hasSize(2);
    assertThat(provider.queries.get(0).uri.toString())
        .startsWith(ContactsContract.PhoneLookup.CONTENT_FILTER_URI.toString());
    assertThat(provider.queries.get(1).selection)
        .isEqualTo(ContactsContract.Data.CONTACT_ID + " IN (1)");
  }

  @Test
  public void getContactsForPhone_withoutMatches_returnsNoContacts() {
    List<Map<String, Object>> contacts =
        contacts(call("getContactsForPhone", queryArguments("phone", "+1 555 0199")));

    assertThat(contacts).isEmpty();
    assertThat(provider.queries).hasSize(1);
  }

  @Test
  public void getAvatar_withoutPhoto_returnsNull() {
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("contact", contactArguments("1"));
    arguments.put("photoHighResolution", true);

    RecordingResult result = call("getAvatar", arguments);

    assertThat(result.value).isNull();
  }

  @Test
  public void unknownMethod_isNotImplemented() {
    RecordingResult result = call("unknown", null);

    assertThat(result.notImplemented).isTrue();
  }

  // endregion

  // region Writing contacts

  @Test
  public void addContact_insertsRawContactAndEveryDataKind() {
    RecordingResult result = call("addContact", contactArguments(null));

    assertThat(result.errorMessage).isNull();
    assertThat(provider.batchSizes).hasSize(1);
    assertThat(writes("insert", null).get(0).uri)
        .isEqualTo(ContactsContract.RawContacts.CONTENT_URI);

    FakeContactsProvider.Write name = writes("insert", StructuredName.CONTENT_ITEM_TYPE).get(0);
    assertThat(name.values.getAsString(StructuredName.GIVEN_NAME)).isEqualTo("John");
    assertThat(name.values.getAsString(StructuredName.MIDDLE_NAME)).isEqualTo("Q");
    assertThat(name.values.getAsString(StructuredName.FAMILY_NAME)).isEqualTo("Doe");
    // Data rows reference the inserted raw contact.
    assertThat(name.values.getAsLong(ContactsContract.Data.RAW_CONTACT_ID)).isNotNull();

    List<FakeContactsProvider.Write> phones = writes("insert", Phone.CONTENT_ITEM_TYPE);
    assertThat(phones).hasSize(2);
    assertThat(phones.get(0).values.getAsInteger(Phone.TYPE)).isEqualTo(Phone.TYPE_MOBILE);
    assertThat(phones.get(1).values.getAsInteger(Phone.TYPE)).isEqualTo(Phone.TYPE_CUSTOM);
    assertThat(phones.get(1).values.getAsString(Phone.LABEL)).isEqualTo("dacha");

    assertThat(writes("insert", Email.CONTENT_ITEM_TYPE)).hasSize(1);
    assertThat(writes("insert", StructuredPostal.CONTENT_ITEM_TYPE)).hasSize(1);
    FakeContactsProvider.Write organization =
        writes("insert", Organization.CONTENT_ITEM_TYPE).get(0);
    assertThat(organization.values.getAsString(Organization.COMPANY)).isEqualTo("Acme");
    FakeContactsProvider.Write birthday = writes("insert", Event.CONTENT_ITEM_TYPE).get(0);
    assertThat(birthday.values.getAsString(Event.START_DATE)).isEqualTo("1990-01-02");
  }

  @Test
  public void addContact_whenProviderFails_returnsError() {
    provider.failBatches = true;

    RecordingResult result = call("addContact", contactArguments(null));

    assertThat(result.errorMessage).isEqualTo("Failed to add the contact");
  }

  @Test
  public void deleteContact_deletesRawContactsOfTheContact() {
    RecordingResult result = call("deleteContact", contactArguments("7"));

    assertThat(result.errorMessage).isNull();
    FakeContactsProvider.Write delete = writes("delete", null).get(0);
    assertThat(delete.uri).isEqualTo(ContactsContract.RawContacts.CONTENT_URI);
    assertThat(delete.selection).isEqualTo(ContactsContract.RawContacts.CONTACT_ID + "=?");
    assertThat(delete.selectionArgs).asList().containsExactly("7");
  }

  @Test
  public void deleteContact_whenProviderFails_returnsError() {
    provider.failBatches = true;

    RecordingResult result = call("deleteContact", contactArguments("7"));

    assertThat(result.errorMessage).startsWith("Failed to delete the contact");
  }

  @Test
  public void updateContact_replacesDataAndUpdatesName() {
    RecordingResult result = call("updateContact", contactArguments("7"));

    assertThat(result.errorMessage).isNull();
    // Organization, phones, emails, note, addresses and photo are replaced.
    assertThat(writes("delete", null)).hasSize(6);
    for (FakeContactsProvider.Write delete : writes("delete", null)) {
      assertThat(delete.selectionArgs[0]).isEqualTo("7");
    }
    FakeContactsProvider.Write name = writes("update", null).get(0);
    assertThat(name.selectionArgs)
        .asList()
        .containsExactly("7", StructuredName.CONTENT_ITEM_TYPE)
        .inOrder();
    assertThat(name.values.getAsString(StructuredName.GIVEN_NAME)).isEqualTo("John");
    assertThat(writes("insert", Phone.CONTENT_ITEM_TYPE)).hasSize(2);
    assertThat(writes("insert", Email.CONTENT_ITEM_TYPE)).hasSize(1);
    assertThat(writes("insert", StructuredPostal.CONTENT_ITEM_TYPE)).hasSize(1);
    FakeContactsProvider.Write organization =
        writes("insert", Organization.CONTENT_ITEM_TYPE).get(0);
    assertThat(organization.values.getAsString(ContactsContract.Data.RAW_CONTACT_ID))
        .isEqualTo("7");
  }

  @Test
  public void updateContact_whenProviderFails_returnsError() {
    provider.failBatches = true;

    RecordingResult result = call("updateContact", contactArguments("7"));

    assertThat(result.errorMessage).startsWith("Failed to update the contact");
  }

  // endregion

  // region Native forms and picker

  private static HashMap<String, Object> formArguments() {
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("androidLocalizedLabels", false);
    return arguments;
  }

  @Test
  public void openContactForm_withoutContactsApp_couldNotBeOpen() {
    attachActivity(Robolectric.buildActivity(Activity.class).setup().get());

    RecordingResult result = call("openContactForm", formArguments());

    assertThat(result.value).isEqualTo(2);
  }

  @Test
  public void openContactForm_returnsTheSavedContact() {
    addJohnDoe();
    Intent insert = new Intent(Intent.ACTION_INSERT, ContactsContract.Contacts.CONTENT_URI);
    registerHandler(insert);
    Activity activity = Robolectric.buildActivity(Activity.class).setup().get();
    ActivityPluginBinding binding = attachActivity(activity);
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(new MethodCall("openContactForm", formArguments()), result);

    ShadowActivity.IntentForResult started =
        shadowOf(activity).getNextStartedActivityForResult();
    assertThat(started.intent.getAction()).isEqualTo(Intent.ACTION_INSERT);
    assertThat(result.done).isFalse();

    Intent saved =
        new Intent().setData(Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, "1"));
    activityResultListener(binding)
        .onActivityResult(started.requestCode, Activity.RESULT_OK, saved);

    assertThat(((Map<?, ?>) result.value).get("givenName")).isEqualTo("John");
  }

  @Test
  public void openContactForm_canceled() {
    Intent insert = new Intent(Intent.ACTION_INSERT, ContactsContract.Contacts.CONTENT_URI);
    registerHandler(insert);
    Activity activity = Robolectric.buildActivity(Activity.class).setup().get();
    ActivityPluginBinding binding = attachActivity(activity);
    RecordingResult result = new RecordingResult();
    plugin.onMethodCall(new MethodCall("openContactForm", formArguments()), result);
    ShadowActivity.IntentForResult started =
        shadowOf(activity).getNextStartedActivityForResult();

    activityResultListener(binding)
        .onActivityResult(started.requestCode, Activity.RESULT_CANCELED, null);

    assertThat(result.value).isEqualTo(1);
  }

  @Test
  public void openExistingContact_unknownContact_couldNotBeOpen() {
    attachActivity(Robolectric.buildActivity(Activity.class).setup().get());
    HashMap<String, Object> arguments = formArguments();
    arguments.put("contact", contactArguments("404"));

    RecordingResult result = call("openExistingContact", arguments);

    assertThat(result.value).isEqualTo(2);
  }

  @Test
  public void openExistingContact_opensTheEditor() {
    addJohnDoe();
    Uri contactUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, "1");
    Intent edit = new Intent(Intent.ACTION_EDIT);
    edit.setDataAndType(contactUri, ContactsContract.Contacts.CONTENT_ITEM_TYPE);
    registerHandler(edit);
    Activity activity = Robolectric.buildActivity(Activity.class).setup().get();
    attachActivity(activity);
    HashMap<String, Object> arguments = formArguments();
    arguments.put("contact", contactArguments("1"));
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(new MethodCall("openExistingContact", arguments), result);

    Intent started = shadowOf(activity).getNextStartedActivityForResult().intent;
    assertThat(started.getAction()).isEqualTo(Intent.ACTION_EDIT);
    assertThat(started.getData()).isEqualTo(contactUri);
  }

  @Test
  public void openDeviceContactPicker_returnsThePickedContact() {
    addJohnDoe();
    Intent pick = new Intent(Intent.ACTION_PICK);
    pick.setType(ContactsContract.Contacts.CONTENT_TYPE);
    registerHandler(pick);
    Activity activity = Robolectric.buildActivity(Activity.class).setup().get();
    ActivityPluginBinding binding = attachActivity(activity);
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(new MethodCall("openDeviceContactPicker", formArguments()), result);
    ShadowActivity.IntentForResult started =
        shadowOf(activity).getNextStartedActivityForResult();
    assertThat(started.intent.getAction()).isEqualTo(Intent.ACTION_PICK);

    Intent picked =
        new Intent().setData(Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, "1"));
    activityResultListener(binding)
        .onActivityResult(started.requestCode, Activity.RESULT_OK, picked);
    for (int i = 0; i < 500 && !result.done; i++) {
      shadowOf(Looper.getMainLooper()).idle();
      try {
        Thread.sleep(10);
      } catch (InterruptedException e) {
        throw new AssertionError(e);
      }
    }

    List<?> contacts = (List<?>) result.value;
    assertThat(contacts).hasSize(1);
    assertThat(((Map<?, ?>) contacts.get(0)).get("givenName")).isEqualTo("John");
  }

  @Test
  public void openDeviceContactPicker_canceled() {
    Intent pick = new Intent(Intent.ACTION_PICK);
    pick.setType(ContactsContract.Contacts.CONTENT_TYPE);
    registerHandler(pick);
    Activity activity = Robolectric.buildActivity(Activity.class).setup().get();
    ActivityPluginBinding binding = attachActivity(activity);
    RecordingResult result = new RecordingResult();
    plugin.onMethodCall(new MethodCall("openDeviceContactPicker", formArguments()), result);
    ShadowActivity.IntentForResult started =
        shadowOf(activity).getNextStartedActivityForResult();

    activityResultListener(binding)
        .onActivityResult(started.requestCode, Activity.RESULT_CANCELED, null);

    assertThat(result.value).isEqualTo(1);
  }

  @Test
  public void detachFromActivity_removesTheResultListener() {
    ActivityPluginBinding binding =
        attachActivity(Robolectric.buildActivity(Activity.class).setup().get());
    PluginRegistry.ActivityResultListener listener = activityResultListener(binding);

    plugin.onDetachedFromActivity();

    verify(binding).removeActivityResultListener(listener);
  }

  // endregion
}
