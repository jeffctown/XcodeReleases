//
//  XcodeReleasesList.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import XcodeReleasesKit

struct XcodeReleaseList : View {
    @EnvironmentObject private var appState: AppState
    @State var releases: [XcodeRelease] = []
    
    
    #if !os(watchOS)
    var body: some View {
        NavigationView {
            self.innerBody
        }
    }
    #else // watchOS doesn't have NavigationView (yet?).
    var body: some View {
        self.innerBody
    }
    #endif
    
    var innerBody: some View {
        Group {
            List(releases) { release in
                NavigationLink(destination: XcodeReleaseDetail(release: release)) {
                    XcodeReleaseRow(release: release)
                }
            }.navigationBarTitle("Xcode Releases")
            #if !os(watchOS) // This shows both on watchOS, but not on iOS.
            // this is needed for iPad, so it shows something in the detail view in its master detail thing.
            if releases.count > 0 {
                XcodeReleaseDetail(release: releases.first!)
            } else {
                EmptyView()
            }
            #endif
        }.onAppear() {
            self.appState.releasesService.refresh()
        }.onReceive(appState.releasesService.$releases) { releases in
            self.releases = releases
        }
    }
}

#if DEBUG
struct XcodeReleaseList_Previews : PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.releasesService.releases = Array(mockReleases[0..<10])
        return XcodeReleaseList().environmentObject(state)
    }
}
#endif
