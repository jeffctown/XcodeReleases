//
//  XcodeReleaseTests.swift
//  
//
//  Created by Jeff Lett on 7/14/19.
//

import Foundation

import XCTest
@testable import XcodeReleasesKit

class XcodeReleaseTests: XCTestCase {
    
    func testEqualityOfReleasesIgnoresId() {
        let testName = "Xcoooode"
        let testNumber = "67.10.2"
        let testBuild = "sakjdhf@#"
        var testRelease = XcodeRelease(
            name: testName,
            date: Date(year: 2019, month: 1, day: 20),
            version: Version(
                number: testNumber,
                build: testBuild,
                release: .gm),
            requires: "",
            sdks: SDKs(
                macOS: [],
                tvOS: [],
                iOS: [],
                watchOS: []),
            links: Links(
                notes: Url(url: ""),
                download: Url(url: "")))
        var testRelease2 = XcodeRelease(
            name: testName,
            date: Date(year: 2019, month: 1, day: 20),
            version: Version(
                number: testNumber,
                build: testBuild,
                release: .gm),
            requires: "",
            sdks: SDKs(
                macOS: [],
                tvOS: [],
                iOS: [],
                watchOS: []),
            links: Links(
                notes: Url(url: ""),
                download: Url(url: "")))
        XCTAssertTrue(testRelease == testRelease2)
        testRelease.id = 9287
        XCTAssertTrue(testRelease == testRelease2)
        testRelease2.id = 126
        XCTAssertTrue(testRelease == testRelease2)
    }
}
