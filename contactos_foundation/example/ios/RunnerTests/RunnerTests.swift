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
