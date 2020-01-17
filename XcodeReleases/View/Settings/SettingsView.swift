//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI

struct SettingsView : View {
    
    @EnvironmentObject private var appState: AppState
    
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
                AboutSection(version: InfoPList.version, build: InfoPList.build)
            }.onReceive(appState.notificationState) { setting in
                self.notificationState = setting
            }.onReceive(appState.userNotifications.$isSavingNotificationState) { isSaving in
                self.isSaving = isSaving
            }.onAppear() {
                self.appState.userNotifications.checkAuthorizationStatus()
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

