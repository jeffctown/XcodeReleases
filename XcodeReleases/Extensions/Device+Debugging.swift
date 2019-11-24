//
//  Device+Debugging.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import XcodeReleasesKit

extension Device: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Device \(self.id ?? -1): \(self.type) \(self.token)"
    }
}
