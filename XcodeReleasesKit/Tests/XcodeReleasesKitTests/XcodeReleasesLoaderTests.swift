//
//  XcodeReleasesLoaderTests.swift
//
//  Created by Jeff Lett on 7/3/19.
//

import XCTest
@testable import XcodeReleasesKit

class XcodeReleasesLoaderTests: XCTestCase {
    
    func testThatLoaderLoadsAndParsesInAReasonableTime() {
        let loader = try! XcodeReleasesLoader(url: "https://www.jefflett.com/xcode-data.json")
        let expectation = XCTestExpectation(description: "Load and Parse Xcode Releases")
        
        loader.releases { result in
            switch result {
            case .success(let releases):
                print("Releases Parsed: \(releases.count)")
                XCTAssertGreaterThan(releases.count, 0)
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}


