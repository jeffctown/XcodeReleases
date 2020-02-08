//
//  XcodeReleasesEnvironment.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 12/25/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation

struct XcodeReleasesEnvironment {
    let apiUrl: String
}

protocol NeedsEnvironment {
    func environment() -> XcodeReleasesEnvironment
}

extension NeedsEnvironment {
    static func environment() -> XcodeReleasesEnvironment {
        #if DEBUG && targetEnvironment(simulator)
        return XcodeReleasesEnvironment(apiUrl: "http://localhost:8080")
        #else
        return XcodeReleasesEnvironment(apiUrl: "https://xcodereleases.jefflett.com")
        #endif
    }
    
    func environment() -> XcodeReleasesEnvironment {
        Self.environment()
    }
}
