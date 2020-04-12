//
//  XcodeReleasesList.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import XCModel

struct XcodeReleaseList: View {
    @EnvironmentObject private var appState: AppState
    @State var releases: [Xcode] = []
    @State var isLoading: Bool = false
    @State var hasError: Bool = false
    @State var loadingError: XcodeReleasesApi.ApiError?

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

    var loadingView: some View {
        Group {
            Text("Loading...").font(.subheadline)
        }
    }

    var emptyView: some View {
        Group {
            VStack {
                Text("No Releases Found.").font(.callout).padding()
                Button(action: {
                    self.appState.releasesService.refresh()
                }) {
                    Text("Refresh")
                }
            }
        }
    }

    // this is needed for iPad, so it shows something in the detail view in its master detail thing.
    var detailView: some View {
        Group {
            if releases.count > 0 {
                XcodeReleaseDetail(release: releases.first!)
            }
        }
    }

    var innerBody: some View {
        Group {
            if self.releases.count > 0 {
                List {
                    if self.isLoading {
                        self.loadingView
                    }
                    ForEach(releases) { release in
                        NavigationLink(destination: XcodeReleaseDetail(release: release)) {
                            XcodeReleaseRow(release: release)
                        }
                    }
                }
            } else if self.isLoading {
                self.loadingView
            } else {
                self.emptyView
            }
            #if !os(watchOS) // This displays and looks bad on watchOS.
            self.detailView
            #endif
        }.onReceive(appState.releasesService.$isLoading) { isLoading in
            self.isLoading = isLoading
        }.onReceive(appState.releasesService.$loadingError) { loadingError in
            self.loadingError = loadingError
            self.hasError = loadingError != nil
        }.onReceive(appState.releasesService.$releases) { releases in
            self.releases = releases
        }.navigationBarTitle("Xcode Releases")
            .alert(isPresented: self.$hasError) { () -> Alert in
                return Alert(title: Text(loadingError!.localizedDescription), dismissButton: Alert.Button.default(Text("OK"), action: {
                    print("*** Clearing Error")
                    self.hasError = false
                    self.loadingError = nil
                }))
        }
    }
}

#if DEBUG
struct XcodeReleaseListPreviews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.releasesService.releases = Array(mockReleases[0..<10])
        return XcodeReleaseList().environmentObject(state)
    }
}
#endif
