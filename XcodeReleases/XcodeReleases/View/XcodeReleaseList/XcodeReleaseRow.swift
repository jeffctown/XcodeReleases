//
//  XcodeReleaseView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XcodeReleasesKit

struct XcodeReleaseRow : View {
    
    let release: XcodeRelease
    
    var body: some View {
        HStack {
            VStack {
                Image("XcodeIcon").resizable().aspectRatio(1.0, contentMode: .fit)
            }
            .frame(width: 50, height: 50, alignment: .center)
                .padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 10.0, trailing: 10.0))
            VStack(alignment: .leading) {
                Text("\(release.name) \(release.version.number ?? "??") \(release.version.release.description)").font(.headline)
                Text("Released: \(release.date.description)").font(.subheadline)
                Text("Requires: MacOS \(release.requires)+").font(.subheadline)
            }
        }
    }
}

#if DEBUG
struct XcodeReleaseRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List(mockReleases) { release in
                    XcodeReleaseRow(release: release)
                }.navigationBarTitle("Light Mode")
            }
            NavigationView {
                List(mockReleases) { release in
                    XcodeReleaseRow(release: release)
                }.navigationBarTitle("Dark Mode")
            }.colorScheme(.dark)
        }
    }
}
#endif


