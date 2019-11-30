//
//  XcodeReleasesList.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import SwiftUIPullToRefresh
import XcodeReleasesKit

struct XcodeReleaseList : View {
    @EnvironmentObject private var appState: AppState
    
    @State private var showSettings = false
    
    var service: XcodeReleasesService {
        XcodeReleasesService(releases: $appState.releases)
    }

    var body: some View {
        RefreshableNavigationView(title: "XcodeReleases", action: {
            self.service.refresh()
        }) {
            ForEach(self.service.releases, id: \.id) { release in
                NavigationLink(destination: XcodeReleaseDetail(release: release)) {
                    XcodeReleaseRow(release: release)
                }
            }
        }.onAppear() {
            self.service.refresh()
        }
    }
}

#if DEBUG
struct XcodeReleaseList_Previews : PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.releases = Array(mockReleases[0..<10])
        return XcodeReleaseList().environmentObject(state)
    }
}
#endif
