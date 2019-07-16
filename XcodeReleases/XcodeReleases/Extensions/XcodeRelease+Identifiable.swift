//
//  XcodeRelease+Identifiable.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XcodeReleasesKit

extension XcodeRelease: Identifiable {
    public var id: String {
        return "\(self.date.year)-\(self.date.month)-\(self.date.day)-\(self.version.build)-\(self.version.number ?? "-1")"
    }
}
