//
//  XcodeReleaseDetail.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XCModel

struct XcodeReleaseDetail: View {

    let release: Xcode

    var body: some View {
        Form {
            ReleaseInfoSection(release: release)
            SDKSection(release: release)
            #if !os(watchOS) // NO Webview in watchOS
            LinksSection(release: release)
            #endif
        }.navigationBarTitle("\(release.name) \(release.version.number ?? "") \(release.version.release.description)")
    }
}

#if DEBUG
struct XcodeReleaseDetailPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            XcodeReleaseDetail(release: mockReleases[0])
            XcodeReleaseDetail(release: mockReleases[1]).colorScheme(.dark)
        }
    }
}
#endif
