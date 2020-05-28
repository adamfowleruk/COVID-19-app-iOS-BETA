//
//  ContentURLsTests.swift
//  SonarTests
//
//  Created by NHSX on 5/18/20
//  Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Sonar

class ContentURLsTests: XCTestCase {
    func testBookTest_withCode() throws {
        let url = ContentURLs.shared.bookTest(referenceCode: "1234-abcd")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.path, "/cta-start")
        XCTAssertEqual(components.host, "self-referral.test-for-coronavirus.service.gov.uk")
        // We don't care what order the params end up in.
        let queryItems = (try XCTUnwrap(components.queryItems)).sorted { (a, b) -> Bool in
            return a.name < b.name
        }
        XCTAssertEqual(queryItems, [
            URLQueryItem(name: "ctaToken", value: "1234-abcd"),
        ])
    }
    
    func testBookTest_withoutCode() throws {
        let url = ContentURLs.shared.bookTest(referenceCode: nil)
        XCTAssertEqual(url, URL(string: "https://self-referral.test-for-coronavirus.service.gov.uk/cta-start"))
    }
}
