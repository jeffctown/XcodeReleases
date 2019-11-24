//
//  XcodeReleaseDetail.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XcodeReleasesKit

struct XcodeReleaseDetail : View {
    
    let release: XcodeRelease
    
    var body: some View {
        Form {
            ReleaseInfoSection(release: release)
            SDKSection(release: release)
            LinksSection(release: release)
        }.navigationBarTitle("\(release.name) \(release.version.number ?? "") \(release.version.release.description)")
    }
}

#if DEBUG
struct XcodeReleaseDetail_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                XcodeReleaseDetail(release: mockReleases[0])
            }
            NavigationView {
                XcodeReleaseDetail(release: mockReleases[1])
            }.colorScheme(.dark)
        }
    }
}
#endif
