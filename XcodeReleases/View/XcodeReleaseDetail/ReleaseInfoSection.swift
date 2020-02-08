//
//  ReleaseInfoSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XCModel

struct ReleaseInfoSection : View {
    let release: Xcode
    
    var body: some View {
        return Section(header: Text("Release Info")) {
            Text("Name: \(release.name)")
            Text("Date Released: \(release.date.description)")
            if release.version.number != nil {
                Text("Version Number: \(release.version.number!)")
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
            Text("Build Number: \(release.version.build)")
            Text("Release: \(release.version.release.description)")
            Text("Requires: MacOS \(release.requires)+")
        }
    }
}

#if DEBUG
struct ReleaseInfoSection_Previews : PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<3) { index in
                ReleaseInfoSection(release: mockReleases[index])
            }
        }
    }
}
#endif
