//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import XCModel

struct SettingsView : View {
    
    @EnvironmentObject private var appState: AppState
    @State var links: [Link] = []
    @State var isLoadingLinks: Bool = false
    @State var hasLinksError: Bool = false
    @State var linksLoadingError: XcodeReleasesApi.ApiError? = nil
    
    @State private var notificationState: NotificationState = .notDetermined
    @State private var isSaving: Bool = false
    
    #if os(watchOS)
    var body: some View {
        self.innerBody
    }
    #else
    var body: some View {
        NavigationView {
            self.innerBody
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    #endif
    
    var innerBody: some View {
        Group {
            List {
                NotificationSection(notificationState: notificationState, isSaving: $isSaving)
                AboutSection(version: InfoPList.version, build: InfoPList.build, links: self.links)
            }.onReceive(appState.notificationState) { setting in
                self.notificationState = setting
            }.onReceive(appState.userNotifications.$isSavingNotificationState) { isSaving in
                self.isSaving = isSaving
            }.onReceive(appState.linksService.$links) { links in
                self.links = links
            }.onReceive(appState.linksService.$isLoading) { isLoading in
                self.isLoadingLinks = isLoading
            }.navigationBarTitle("Settings")
        }
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}
#endif

