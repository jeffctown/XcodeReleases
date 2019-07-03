//
//  LinksSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XcodeReleasesKit

struct LinksSection : View {
    let release: XcodeRelease
    
    var body: some View {
        Section(header: Text("Links")) {
            if release.links?.notes?.url != nil {
                PresentationLink(destination: SafariView(url: URL(string: release.links!.notes!.url)!)) {
                    Text("Release Notes")
                }
            } else {
                EmptyView()
            }
        }
    }
}

#if DEBUG
struct LinksSection_Previews : PreviewProvider {
    static var previews: some View {
        List(0..<5) { index in
            LinksSection(release: mockReleases[index])
        }
    }
}
#endif
