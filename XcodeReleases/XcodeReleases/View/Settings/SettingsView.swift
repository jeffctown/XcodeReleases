//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct SettingsView : View {
    @EnvironmentObject private var appState: AppState
    @State var showingAlert = false
    @State var authorizationStatus: UNAuthorizationStatus = .notDetermined
    let userNotifications: UserNotifications
    
    var body: some View {
        List {
            NotificationSection(
                pushToken: $appState.pushToken,
                authorizationStatus: $authorizationStatus,
                showingAlert: $showingAlert,
                register: userNotifications.register)
            AboutSection(version: InfoPList.version, build: InfoPList.build)
        }.onReceive(userNotifications.authorizationStatus, perform: { status in
            self.authorizationStatus = status
        }).onAppear() {
            self.userNotifications.checkAuthorizationStatus()
        }.navigationBarTitle("Settings")
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(userNotifications: UserNotifications()).environmentObject(AppState())
        }
    }
}
#endif
