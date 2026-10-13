// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by the license found in the LICENSE
// file.

import Contacts
import Flutter
import XCTest

@testable import contactos_foundation

final class RunnerTests: XCTestCase {
  private let plugin = ContactosPlugin()

  // MARK: - Method channel

  func testUnknownMethodIsNotImplemented() {
    let expectation = expectation(description: "result")
    plugin.handle(FlutterMethodCall(methodName: "unknown", arguments: nil)) { value in
      XCTAssertTrue((value as AnyObject) === (FlutterMethodNotImplemented as AnyObject))
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testGetAvatarWithoutIdentifierReturnsError() {
    let expectation = expectation(description: "result")
    plugin.handle(FlutterMethodCall(methodName: "getAvatar", arguments: [String: Any]())) { value in
      XCTAssertEqual((value as? FlutterError)?.code, "MISSING_ID")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Labels

  func testPhoneLabelMapsKnownLabels() {
    XCTAssertEqual(plugin.getPhoneLabel(label: "main"), CNLabelPhoneNumberMain)
    XCTAssertEqual(plugin.getPhoneLabel(label: "mobile"), CNLabelPhoneNumberMobile)
    XCTAssertEqual(plugin.getPhoneLabel(label: "iPhone"), CNLabelPhoneNumberiPhone)
    XCTAssertEqual(plugin.getPhoneLabel(label: "work"), CNLabelWork)
    XCTAssertEqual(plugin.getPhoneLabel(label: "home"), CNLabelHome)
    XCTAssertEqual(plugin.getPhoneLabel(label: "other"), CNLabelOther)
    XCTAssertEqual(plugin.getPhoneLabel(label: "dacha"), "dacha")
    XCTAssertEqual(plugin.getPhoneLabel(label: nil), "")
  }

  func testCommonLabelMapsKnownLabels() {
    XCTAssertEqual(plugin.getCommonLabel(label: "work"), CNLabelWork)
    XCTAssertEqual(plugin.getCommonLabel(label: "home"), CNLabelHome)
    XCTAssertEqual(plugin.getCommonLabel(label: "other"), CNLabelOther)
    XCTAssertEqual(plugin.getCommonLabel(label: "personal"), "personal")
    XCTAssertEqual(plugin.getCommonLabel(label: nil), "")
  }

  func testRawPhoneLabelIsInverseOfPhoneLabel() {
    for label in ["main", "mobile", "iPhone", "work", "home", "other", "dacha"] {
      XCTAssertEqual(plugin.getRawPhoneLabel(plugin.getPhoneLabel(label: label)), label)
    }
    XCTAssertEqual(plugin.getRawPhoneLabel(nil), "")
  }

  func testRawCommonLabelIsInverseOfCommonLabel() {
    for label in ["work", "home", "other", "personal"] {
      XCTAssertEqual(plugin.getRawCommonLabel(plugin.getCommonLabel(label: label)), label)
    }
    XCTAssertEqual(plugin.getRawCommonLabel(nil), "")
  }

  // MARK: - Dictionary to contact

  func testDictionaryToContactMapsSimpleFields() {
    let contact = plugin.dictionaryToContact(dictionary: [
      "givenName": "John",
      "familyName": "Doe",
      "middleName": "Q",
      "prefix": "Mr",
      "suffix": "Jr",
      "company": "Acme",
      "jobTitle": "Engineer",
      "avatar": FlutterStandardTypedData(bytes: Data([1, 2, 3])),
    ])

    XCTAssertEqual(contact.givenName, "John")
    XCTAssertEqual(contact.familyName, "Doe")
    XCTAssertEqual(contact.middleName, "Q")
    XCTAssertEqual(contact.namePrefix, "Mr")
    XCTAssertEqual(contact.nameSuffix, "Jr")
    XCTAssertEqual(contact.organizationName, "Acme")
    XCTAssertEqual(contact.jobTitle, "Engineer")
    XCTAssertEqual(contact.imageData, Data([1, 2, 3]))
  }

  func testDictionaryToContactUsesEmptyStringsForMissingFields() {
    let contact = plugin.dictionaryToContact(dictionary: [:])

    XCTAssertEqual(contact.givenName, "")
    XCTAssertEqual(contact.familyName, "")
    XCTAssertEqual(contact.organizationName, "")
    XCTAssertNil(contact.imageData)
    XCTAssertTrue(contact.phoneNumbers.isEmpty)
    XCTAssertTrue(contact.emailAddresses.isEmpty)
    XCTAssertTrue(contact.postalAddresses.isEmpty)
    XCTAssertNil(contact.birthday)
  }

  func testDictionaryToContactMapsPhonesAndSkipsEmptyValues() {
    let contact = plugin.dictionaryToContact(dictionary: [
      "phones": [
        ["label": "mobile", "value": "+1 555 0100"],
        ["label": "work"],
      ],
    ])

    XCTAssertEqual(contact.phoneNumbers.count, 1)
    XCTAssertEqual(contact.phoneNumbers.first?.label, CNLabelPhoneNumberMobile)
    XCTAssertEqual(contact.phoneNumbers.first?.value.stringValue, "+1 555 0100")
  }

  func testDictionaryToContactMapsEmails() {
    let contact = plugin.dictionaryToContact(dictionary: [
      "emails": [
        ["label": "work", "value": "john@example.com"],
        ["value": "doe@example.com"],
      ],
    ])

    XCTAssertEqual(contact.emailAddresses.count, 2)
    XCTAssertEqual(contact.emailAddresses[0].label, CNLabelWork)
    XCTAssertEqual(contact.emailAddresses[0].value as String, "john@example.com")
    XCTAssertEqual(contact.emailAddresses[1].label, "")
  }

  func testDictionaryToContactMapsPostalAddresses() {
    let contact = plugin.dictionaryToContact(dictionary: [
      "postalAddresses": [
        [
          "label": "home",
          "street": "1 Main St",
          "city": "Springfield",
          "postcode": "12345",
          "region": "IL",
          "country": "USA",
        ],
      ],
    ])

    let address = contact.postalAddresses.first
    XCTAssertEqual(address?.label, CNLabelHome)
    XCTAssertEqual(address?.value.street, "1 Main St")
    XCTAssertEqual(address?.value.city, "Springfield")
    XCTAssertEqual(address?.value.postalCode, "12345")
    XCTAssertEqual(address?.value.state, "IL")
    XCTAssertEqual(address?.value.country, "USA")
  }

  func testDictionaryToContactIgnoresMalformedBirthday() {
    let contact = plugin.dictionaryToContact(dictionary: ["birthday": "02.01.1990"])

    XCTAssertNil(contact.birthday)
  }

  func testDictionaryToContactParsesBirthday() {
    let contact = plugin.dictionaryToContact(dictionary: ["birthday": "1990-01-02"])

    XCTAssertEqual(contact.birthday?.year, 1990)
    XCTAssertEqual(contact.birthday?.month, 1)
    XCTAssertEqual(contact.birthday?.day, 2)
  }

  // MARK: - Contact to dictionary

  private func makeContact() -> CNMutableContact {
    let contact = CNMutableContact()
    contact.givenName = "John"
    contact.familyName = "Doe"
    contact.middleName = "Q"
    contact.namePrefix = "Mr"
    contact.nameSuffix = "Jr"
    contact.organizationName = "Acme"
    contact.jobTitle = "Engineer"
    contact.phoneNumbers = [
      CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: "+1 555 0100")),
      CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue: "+1 555 0101")),
    ]
    contact.emailAddresses = [
      CNLabeledValue(label: CNLabelWork, value: "john@example.com" as NSString),
    ]
    let address = CNMutablePostalAddress()
    address.street = "1 Main St"
    address.city = "Springfield"
    address.postalCode = "12345"
    address.state = "IL"
    address.country = "USA"
    contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: address)]
    return contact
  }

  func testContactToDictionaryMapsSimpleFields() {
    let result = plugin.contactToDictionary(contact: makeContact(), localizedLabels: false)

    XCTAssertNotNil(result["identifier"] as? String)
    XCTAssertEqual(result["givenName"] as? String, "John")
    XCTAssertEqual(result["familyName"] as? String, "Doe")
    XCTAssertEqual(result["middleName"] as? String, "Q")
    XCTAssertEqual(result["prefix"] as? String, "Mr")
    XCTAssertEqual(result["suffix"] as? String, "Jr")
    XCTAssertEqual(result["company"] as? String, "Acme")
    XCTAssertEqual(result["jobTitle"] as? String, "Engineer")
  }

  func testContactToDictionaryUsesRawLabels() {
    let result = plugin.contactToDictionary(contact: makeContact(), localizedLabels: false)

    let phones = result["phones"] as? [[String: String]]
    XCTAssertEqual(phones?.count, 2)
    XCTAssertEqual(phones?[0], ["label": "mobile", "value": "+1 555 0100"])
    XCTAssertEqual(phones?[1], ["label": "other", "value": "+1 555 0101"])

    let emails = result["emails"] as? [[String: String]]
    XCTAssertEqual(emails?.first, ["label": "work", "value": "john@example.com"])

    let addresses = result["postalAddresses"] as? [[String: String]]
    XCTAssertEqual(addresses?.first, [
      "label": "home",
      "street": "1 Main St",
      "city": "Springfield",
      "postcode": "12345",
      "region": "IL",
      "country": "USA",
    ])
  }

  func testContactToDictionaryUsesLocalizedLabels() {
    let result = plugin.contactToDictionary(contact: makeContact(), localizedLabels: true)

    let phones = result["phones"] as? [[String: String]]
    XCTAssertEqual(
      phones?.first?["label"],
      CNLabeledValue<NSString>.localizedString(forLabel: CNLabelPhoneNumberMobile)
    )
  }

  func testContactToDictionaryFormatsBirthday() {
    let contact = makeContact()
    contact.birthday = DateComponents(
      calendar: Calendar(identifier: .gregorian), year: 1990, month: 1, day: 2
    )

    let result = plugin.contactToDictionary(contact: contact, localizedLabels: false)

    XCTAssertEqual(result["birthday"] as? String, "1990-01-02")
  }

  func testContactToDictionaryWithoutBirthdayOmitsKey() {
    let result = plugin.contactToDictionary(contact: makeContact(), localizedLabels: false)

    XCTAssertNil(result["birthday"])
  }
}

/// Exercises the plugin against the simulator's contact store.
///
/// `tool/test_ios_native.sh` grants the contacts permission before running.
final class ContactStoreTests: XCTestCase {
  private let plugin = ContactosPlugin()
  /// Unique family name that marks the contacts created by one test.
  private var familyName = ""

  override func setUpWithError() throws {
    try super.setUpWithError()
    XCTAssertEqual(
      CNContactStore.authorizationStatus(for: .contacts), .authorized,
      "Grant the contacts permission to the example app before running the tests."
    )
    familyName = "Contactos\(UUID().uuidString.prefix(8))"
  }

  override func tearDownWithError() throws {
    let store = CNContactStore()
    let predicate = CNContact.predicateForContacts(matchingName: familyName)
    let keys = [CNContactIdentifierKey as CNKeyDescriptor]
    let created = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
    if !created.isEmpty {
      let request = CNSaveRequest()
      for contact in created {
        if let mutable = contact.mutableCopy() as? CNMutableContact {
          request.delete(mutable)
        }
      }
      try store.execute(request)
    }
    try super.tearDownWithError()
  }

  // MARK: - Helpers

  private func invoke(_ method: String, _ arguments: Any? = nil) -> Any? {
    var value: Any?
    let expectation = expectation(description: method)
    plugin.handle(FlutterMethodCall(methodName: method, arguments: arguments)) { result in
      value = result
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
    return value
  }

  private func queryArguments(_ key: String, _ value: String) -> [String: Any] {
    [
      key: value,
      "withThumbnails": false,
      "photoHighResolution": false,
      "orderByGivenName": true,
      "iOSLocalizedLabels": false,
    ]
  }

  private func addContact(givenName: String = "John") {
    let value = invoke("addContact", [
      "givenName": givenName,
      "familyName": familyName,
      "company": "Acme",
      "jobTitle": "Engineer",
      "phones": [["label": "mobile", "value": "+1 555 0100"]],
      "emails": [["label": "work", "value": "\(familyName.lowercased())@example.com"]],
      "postalAddresses": [["label": "home", "city": "Springfield"]],
      "birthday": "1990-01-02",
    ] as [String: Any])
    XCTAssertNil(value)
  }

  private func contacts(named name: String) -> [[String: Any]] {
    invoke("getContacts", queryArguments("query", name)) as? [[String: Any]] ?? []
  }

  // MARK: - Tests

  func testAddedContactCanBeFoundByName() throws {
    addContact()

    let found = contacts(named: familyName)

    XCTAssertEqual(found.count, 1)
    let contact = try XCTUnwrap(found.first)
    XCTAssertEqual(contact["givenName"] as? String, "John")
    XCTAssertEqual(contact["familyName"] as? String, familyName)
    XCTAssertEqual(contact["company"] as? String, "Acme")
    XCTAssertEqual(contact["jobTitle"] as? String, "Engineer")
    XCTAssertEqual(contact["birthday"] as? String, "1990-01-02")
    XCTAssertEqual(
      contact["phones"] as? [[String: String]],
      [["label": "mobile", "value": "+1 555 0100"]]
    )
    let addresses = contact["postalAddresses"] as? [[String: String]]
    XCTAssertEqual(addresses?.first?["city"], "Springfield")
    XCTAssertEqual(addresses?.first?["label"], "home")
  }

  func testContactsAreOrderedByGivenName() {
    addContact(givenName: "Zed")
    addContact(givenName: "Anna")

    let names = contacts(named: familyName).compactMap { $0["givenName"] as? String }

    XCTAssertEqual(names, ["Anna", "Zed"])
  }

  func testContactCanBeFoundByEmail() {
    addContact()

    let found =
      invoke(
        "getContactsForEmail",
        queryArguments("email", "\(familyName.lowercased())@example.com")
      ) as? [[String: Any]]

    XCTAssertEqual(found?.count, 1)
    XCTAssertEqual(found?.first?["familyName"] as? String, familyName)
  }

  func testContactCanBeFoundByPhone() {
    addContact()

    let found =
      invoke("getContactsForPhone", queryArguments("phone", "+1 555 0100")) as? [[String: Any]]

    XCTAssertTrue(
      found?.contains { $0["familyName"] as? String == familyName } ?? false
    )
  }

  func testWithThumbnailsLoadsContactsWithoutPhoto() {
    addContact()
    var arguments = queryArguments("query", familyName)
    arguments["withThumbnails"] = true

    let found = invoke("getContacts", arguments) as? [[String: Any]]

    XCTAssertEqual(found?.count, 1)
    XCTAssertNil(found?.first?["avatar"])
  }

  func testUpdateContactChangesStoredFields() throws {
    addContact()
    var contact = try XCTUnwrap(contacts(named: familyName).first)
    contact["jobTitle"] = "Manager"
    contact["phones"] = [["label": "work", "value": "+1 555 0199"]]

    XCTAssertNil(invoke("updateContact", contact))

    let updated = try XCTUnwrap(contacts(named: familyName).first)
    XCTAssertEqual(updated["jobTitle"] as? String, "Manager")
    XCTAssertEqual(
      updated["phones"] as? [[String: String]],
      [["label": "work", "value": "+1 555 0199"]]
    )
  }

  func testDeleteContactRemovesIt() throws {
    addContact()
    let contact = try XCTUnwrap(contacts(named: familyName).first)

    XCTAssertNil(invoke("deleteContact", contact))

    XCTAssertTrue(contacts(named: familyName).isEmpty)
  }

  func testUpdateUnknownContactFails() {
    let value = invoke("updateContact", ["identifier": "unknown", "givenName": "Nobody"])

    XCTAssertNotNil(value as? FlutterError)
  }

  func testDeleteUnknownContactFails() {
    let value = invoke("deleteContact", ["identifier": "unknown"])

    XCTAssertNotNil(value as? FlutterError)
  }

  func testDeleteWithoutIdentifierFails() {
    let value = invoke("deleteContact", [String: Any]())

    XCTAssertNotNil(value as? FlutterError)
  }

  func testGetAvatarOfUnknownContactFails() {
    let value = invoke("getAvatar", ["identifier": "unknown"])

    XCTAssertEqual((value as? FlutterError)?.code, "FETCH_ERROR")
  }

  func testGetAvatarWithoutPhotoReturnsNil() throws {
    addContact()
    let contact = try XCTUnwrap(contacts(named: familyName).first)

    let value = invoke("getAvatar", ["identifier": contact["identifier"] as Any])

    XCTAssertNil(value)
  }

  func testOpenExistingUnknownContactCouldNotBeOpen() {
    let value = invoke("openExistingContact", [
      "contact": ["identifier": "unknown"],
      "iOSLocalizedLabels": false,
    ] as [String: Any])

    XCTAssertEqual(value as? Int, 2)
  }

  func testOpenExistingContactWithoutIdentifierCouldNotBeOpen() {
    let value = invoke("openExistingContact", [
      "contact": [String: Any](),
      "iOSLocalizedLabels": false,
    ] as [String: Any])

    XCTAssertEqual(value as? Int, 2)
  }
}
