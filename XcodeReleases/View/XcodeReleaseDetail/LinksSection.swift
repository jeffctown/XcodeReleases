//
//  LinksSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XCModel

struct LinksSection: View {
    let release: Xcode

    var body: some View {
        Group {
            if release.links?.notes?.url != nil {
                Section(header: Text("Links")) {
                    WebViewButton(text: "Release Notes", url: release.links!.notes!.url)
                }
            } else {
                EmptyView()
            }
        }
    }
}

#if DEBUG
struct LinksSection_Previews: PreviewProvider {
    static var previews: some View {
        List(0..<5) { index in
            LinksSection(release: mockReleases[index])
        }
    }
}
#endif
