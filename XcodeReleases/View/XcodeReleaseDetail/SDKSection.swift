//
//  SDKSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XCModel

struct SDKSection: View {
    let release: Xcode

    var body: some View {
        Group {
            if release.sdks != nil && release.sdks!.count > 0 {
                Section(header: Text("SDKs")) {
                    release.sdks?.macOS?.first.map {
                        Text("MacOS SDK: \($0.number ?? "") (\($0.build))")
                    }
                    release.sdks?.tvOS?.first.map {
                        Text("tvOS SDK: \($0.number ?? "") (\($0.build))")
                    }
                    release.sdks?.iOS?.first.map {
                        Text("iOS SDK: \($0.number ?? "") (\($0.build))")
                    }
                    release.sdks?.watchOS?.first.map {
                        Text("watchOS SDK: \($0.number ?? "") (\($0.build))")
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

#if DEBUG
struct SDKSectionPreviews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<5) { index in
                SDKSection(release: mockReleases[index])
            }
        }
    }
}
#endif
