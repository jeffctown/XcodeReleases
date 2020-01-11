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
    
    var body: some View {
        NavigationView {
            List(releases) { release in
                NavigationLink(destination: XcodeReleaseDetail(release: release)) {
                    XcodeReleaseRow(release: release)
                }
            }.navigationBarTitle("Xcode Releases")
            if releases.count > 0 {
                XcodeReleaseDetail(release: releases.first!)
            } else {
                EmptyView()
            }
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
