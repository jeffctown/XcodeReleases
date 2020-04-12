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
                    if release.sdks?.macOS?.first?.number != nil || release.sdks?.macOS?.first?.build != nil {
                        Text("MacOS SDK: \(release.sdks!.macOS!.first!.number ?? "") (\(release.sdks!.macOS!.first!.build))")
                    } else {
                        EmptyView()
                    }
                    if release.sdks?.tvOS?.first?.number != nil || release.sdks?.tvOS?.first?.build != nil {
                        Text("tvOS SDK: \(release.sdks!.tvOS!.first!.number ?? "") (\(release.sdks!.tvOS!.first!.build))")
                    } else {
                        EmptyView()
                    }
                    if release.sdks?.iOS?.first?.number != nil || release.sdks?.iOS?.first?.build != nil {
                        Text("iOS SDK: \(release.sdks!.iOS!.first!.number ?? "") (\(release.sdks!.iOS!.first!.build))")
                    } else {
                        EmptyView()
                    }
                    if release.sdks?.watchOS?.first?.number != nil || release.sdks?.watchOS?.first?.build != nil {
                        Text("watchOS SDK: \(release.sdks!.watchOS!.first!.number ?? "") (\(release.sdks!.watchOS!.first!.build))")
                    } else {
                        EmptyView()
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
